"""
PDF Generator views for EduCV.
Keeps all business logic in services.py — views only handle HTTP concerns.
"""
import logging
from pathlib import Path

from django.db import transaction
from django.http import FileResponse
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.throttling import UserRateThrottle
from rest_framework.views import APIView

from apps.core.responses import success_response, error_response
from apps.cv.models import CVProfile, GeneratedCV
from apps.users.models import AuditLog
from .serializers import GeneratedCVSerializer
from .services import CVGenerationService, CVGenerationError

logger = logging.getLogger(__name__)


class PDFGenerationThrottle(UserRateThrottle):
    """
    Custom throttle for PDF generation.
    Limits each student to 10 generation requests per hour.
    PDF generation is CPU-intensive — this protects the server.
    """
    scope = 'pdf_generation'


class GenerateCVView(APIView):
    """
    POST /api/v1/cv/generate/
    Generates all 3 CV PDFs for the authenticated student.
    Uses the student's existing CV data — no request body needed.
    Returns download URLs for all 3 templates.
    """
    permission_classes = [IsAuthenticated]
    throttle_classes   = [PDFGenerationThrottle]

    def post(self, request):
        service = CVGenerationService(request.user)

        try:
            results = service.generate_all()
        except CVGenerationError as exc:
            return error_response(str(exc), status_code=status.HTTP_400_BAD_REQUEST)

        # Save GeneratedCV records and audit log atomically
        with transaction.atomic():
            cv = CVProfile.objects.get(student=request.user)
            generated_cvs = []
            for result in results:
                record = GeneratedCV.objects.create(
                    cv        = cv,
                    template  = result['template'],
                    file_path = result['file_path'],
                    file_size = result['file_size'],
                )
                generated_cvs.append(record)

            AuditLog.log(
                request.user,
                AuditLog.Action.PDF_GENERATED,
                request,
                extra_data={'templates': [r['template'] for r in results]},
            )
        logger.info('3 CVs generated for student: %s', request.user.email)

        serializer = GeneratedCVSerializer(
            generated_cvs, many=True, context={'request': request}
        )

        return success_response(
            'Your CVs have been generated successfully.',
            {
                'generated_at': generated_cvs[0].generated_at,
                'cvs': serializer.data,
            },
            status.HTTP_201_CREATED,
        )


class DownloadCVView(APIView):
    """
    GET /api/v1/cv/download/<uuid:pk>/
    Serves the actual PDF file for download.
    Security: students can only download their own CVs.
    Increments download_count on each access.
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

        filename = f'EduCV_{record.get_template_display()}_{request.user.student_id}.pdf'
        return FileResponse(
            pdf_path.open('rb'),
            content_type='application/pdf',
            as_attachment=True,
            filename=filename,
        )


class CVHistoryView(APIView):
    """
    GET /api/v1/cv/history/
    Returns all previously generated CVs for the authenticated student.
    Ordered by most recent first. Supports ?page and ?page_size query params.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        from rest_framework.pagination import PageNumberPagination

        records = GeneratedCV.objects.filter(
            cv__student=request.user
        ).order_by('-generated_at')

        paginator = PageNumberPagination()
        paginator.page_size = 20
        paginator.page_size_query_param = 'page_size'
        paginator.max_page_size = 100
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
            },
        )
