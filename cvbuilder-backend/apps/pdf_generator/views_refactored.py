"""
Refactored PDF Generator views with configurable pagination and limits.
All hardcoded values are now configurable via AppConfig.
"""
import logging
from pathlib import Path

from django.db import transaction
from django.http import FileResponse
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.throttling import UserRateThrottle
from rest_framework.views import APIView
from rest_framework.pagination import PageNumberPagination

from apps.core.responses import success_response, error_response
from apps.core.config import AppConfig
from apps.cv.models import CVProfile, GeneratedCV
from apps.users.models import AuditLog
from .serializers import GeneratedCVSerializer
from .services import CVGenerationService, CVGenerationError

logger = logging.getLogger(__name__)


class PDFGenerationThrottle(UserRateThrottle):
    """
    Configurable throttle for PDF generation.
    Rate limit is now configurable via environment variables.
    """
    scope = 'pdf_generation'


class ConfigurablePagination(PageNumberPagination):
    """
    Configurable pagination class that uses AppConfig values.
    """
    page_size = AppConfig.DEFAULT_PAGE_SIZE
    page_size_query_param = 'page_size'
    max_page_size = AppConfig.MAX_PAGE_SIZE


class GenerateCVView(APIView):
    """
    POST /api/v1/cv/generate/
    Generates configurable number of CV PDFs for the authenticated student.
    Template types are now configurable via AppConfig.
    """
    permission_classes = [IsAuthenticated]
    throttle_classes = [PDFGenerationThrottle]

    def post(self, request):
        service = CVGenerationService(request.user)

        try:
            # Get configurable template types
            template_types = AppConfig.TEMPLATE_TYPES
            results = service.generate_all(template_types=template_types)
        except CVGenerationError as exc:
            return error_response(str(exc), status_code=status.HTTP_400_BAD_REQUEST)

        # Save GeneratedCV records and audit log atomically
        with transaction.atomic():
            cv = CVProfile.objects.get(student=request.user)
            generated_cvs = []
            for result in results:
                record = GeneratedCV.objects.create(
                    cv=cv,
                    template=result['template'],
                    file_path=result['file_path'],
                    file_size=result['file_size'],
                )
                generated_cvs.append(record)

            AuditLog.log(
                request.user,
                AuditLog.Action.PDF_GENERATED,
                request,
                extra_data={'templates': [r['template'] for r in results]},
            )
        
        # Use configurable success message
        template_count = len(template_types)
        logger.info(f'{template_count} CVs generated for student: %s', request.user.email)

        serializer = GeneratedCVSerializer(
            generated_cvs, many=True, context={'request': request}
        )

        return success_response(
            f'Your {template_count} CVs have been generated successfully.',
            {
                'generated_at': generated_cvs[0].generated_at,
                'cvs': serializer.data,
                'template_types': template_types,
            },
            status.HTTP_201_CREATED,
        )


class DownloadCVView(APIView):
    """
    GET /api/v1/cv/download/<uuid:pk>/
    Serves the actual PDF file for download.
    Filename format is now configurable.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request, pk):
        # Ownership enforced — student can only access their own records
        record = GeneratedCV.objects.filter(pk=pk, cv__student=request.user).first()
        if not record:
            return error_response(
                'CV not found.',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        # Reconstruct absolute path from MEDIA_ROOT + stored relative path
        from django.conf import settings
        pdf_path = Path(settings.MEDIA_ROOT) / record.file_path
        if not pdf_path.exists():
            logger.error('PDF file missing on disk: %s | record id: %s', pdf_path, pk)
            return error_response(
                'PDF file not found. Please regenerate your CV.',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        # Increment download counter
        record.download_count += 1
        record.save(update_fields=['download_count'])

        AuditLog.log(
            request.user,
            AuditLog.Action.PDF_DOWNLOADED,
            request,
            extra_data={'template': record.template, 'generated_cv_id': str(pk)},
        )

        # Use configurable filename format
        app_name = config('APP_NAME', default='EduCV')
        filename_format = config('PDF_FILENAME_FORMAT', default='{app_name}_{template}_{student_id}.pdf')
        filename = filename_format.format(
            app_name=app_name,
            template=record.get_template_display(),
            student_id=request.user.student_id
        )
        
        return FileResponse(
            pdf_path.open('rb'),
            content_type='application/pdf',
            as_attachment=True,
            filename=filename,
        )


class CVHistoryView(APIView):
    """
    GET /api/v1/cv/history/
    Returns all previously generated CVs with configurable pagination.
    """
    permission_classes = [IsAuthenticated]
    pagination_class = ConfigurablePagination

    def get(self, request):
        records = GeneratedCV.objects.filter(
            cv__student=request.user
        ).order_by('-generated_at')

        # Use configurable pagination
        paginator = self.pagination_class()
        page = paginator.paginate_queryset(records, request)

        serializer = GeneratedCVSerializer(
            page, many=True, context={'request': request}
        )
        
        return success_response(
            'CV generation history retrieved successfully.',
            {
                'count': paginator.page.paginator.count,
                'total_pages': paginator.page.paginator.num_pages,
                'current_page': paginator.page.number,
                'next': paginator.get_next_link(),
                'previous': paginator.get_previous_link(),
                'results': serializer.data,
                'pagination_config': {
                    'page_size': paginator.page_size,
                    'max_page_size': paginator.max_page_size,
                }
            },
        )