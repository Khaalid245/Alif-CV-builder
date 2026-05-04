"""
CV and PDF management views for admin dashboard.
Provides oversight of generated CVs and CV completion statistics.
"""
import logging
from django.db.models import Count, Q
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.decorators import api_view, permission_classes
from rest_framework.generics import ListAPIView
from rest_framework.pagination import PageNumberPagination

from apps.core.responses import success_response
from apps.administration.permissions import IsAdminUser
from apps.administration.filters import GeneratedCVFilter
from apps.administration.serializers.cv_serializers import GeneratedCVAdminSerializer
from apps.cv.models import GeneratedCV, CVProfile

# Application logger
app_logger = logging.getLogger('app')


class GeneratedCVPagination(PageNumberPagination):
    """Custom pagination for generated CV lists"""
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class GeneratedCVListView(ListAPIView):
    """
    GET /api/v1/admin/cvs/generated/
    List all generated CVs across all students with filtering.
    """
    serializer_class = GeneratedCVAdminSerializer
    permission_classes = [IsAdminUser]
    pagination_class = GeneratedCVPagination
    filter_backends = [DjangoFilterBackend]
    filterset_class = GeneratedCVFilter
    
    def get_queryset(self):
        """Optimized queryset with student data"""
        return GeneratedCV.objects.select_related(
            'cv__student'
        ).order_by('-generated_at')
    
    def list(self, request, *args, **kwargs):
        """Override to log admin access and format response"""
        app_logger.info(f"Admin {request.user.email} accessed generated CVs list")
        
        queryset = self.filter_queryset(self.get_queryset())
        page = self.paginate_queryset(queryset)

        if page is not None:
            serializer = self.get_serializer(page, many=True)
            paginator = self.paginator
            return success_response(
                message="Generated CVs retrieved successfully.",
                data={
                    'count': paginator.page.paginator.count,
                    'total_pages': paginator.page.paginator.num_pages,
                    'current_page': paginator.page.number,
                    'next': paginator.get_next_link(),
                    'previous': paginator.get_previous_link(),
                    'results': serializer.data,
                }
            )

        serializer = self.get_serializer(queryset, many=True)
        return success_response(
            message="Generated CVs retrieved successfully.",
            data={'count': queryset.count(), 'total_pages': 1,
                  'current_page': 1, 'next': None,
                  'previous': None, 'results': serializer.data}
        )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def popular_sections_stats(request):
    """
    GET /api/v1/admin/cvs/stats/popular-sections/
    Returns percentage of students who have filled each CV section.
    """
    app_logger.info(f"Admin {request.user.email} accessed popular sections statistics")
    
    # Get total number of CV profiles
    total_profiles = CVProfile.objects.count()
    
    if total_profiles == 0:
        return success_response(
            message="No CV profiles found.",
            data={
                'education': 0,
                'experience': 0,
                'skills': 0,
                'languages': 0,
                'projects': 0,
                'certifications': 0,
                'summary': 0,
                'photo': 0,
            }
        )
    
    # Calculate section completion percentages using aggregation
    section_stats = CVProfile.objects.aggregate(
        # Education: at least 1 education entry
        education_filled=Count('id', filter=Q(educations__isnull=False), distinct=True),
        
        # Experience: at least 1 experience entry
        experience_filled=Count('id', filter=Q(experiences__isnull=False), distinct=True),
        
        # Skills: at least 1 skill entry
        skills_filled=Count('id', filter=Q(skills__isnull=False), distinct=True),
        
        # Languages: at least 1 language entry
        languages_filled=Count('id', filter=Q(languages__isnull=False), distinct=True),
        
        # Projects: at least 1 project entry
        projects_filled=Count('id', filter=Q(projects__isnull=False), distinct=True),
        
        # Certifications: at least 1 certification entry
        certifications_filled=Count('id', filter=Q(certifications__isnull=False), distinct=True),
        
        # Summary: non-empty summary field
        summary_filled=Count('id', filter=~Q(summary='') & ~Q(summary__isnull=True)),
        
        # Photo: has uploaded photo
        photo_filled=Count('id', filter=Q(photo__isnull=False) & ~Q(photo='')),
    )
    
    # Calculate percentages
    data = {}
    for section, count in section_stats.items():
        section_name = section.replace('_filled', '')
        percentage = round((count / total_profiles) * 100, 1)
        data[section_name] = percentage
    
    return success_response(
        message="CV section popularity statistics retrieved successfully.",
        data=data
    )