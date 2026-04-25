"""
Student management views for admin dashboard.
Provides full student management capabilities including status changes and deletion processing.
"""
import logging
import uuid
from django.db import transaction
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.generics import ListAPIView, RetrieveAPIView
from rest_framework.pagination import PageNumberPagination
from rest_framework.response import Response

from apps.core.responses import success_response, error_response
from apps.administration.permissions import IsAdminUser
from apps.administration.filters import StudentFilter
from apps.administration.serializers.student_serializers import (
    StudentListSerializer, StudentDetailSerializer, StudentStatusUpdateSerializer,
    DeletionRequestSerializer
)
from apps.users.models import User, AuditLog
from apps.cv.serializers import CVProfileSerializer

# Application logger
app_logger = logging.getLogger('app')


class StudentPagination(PageNumberPagination):
    """Custom pagination for student lists"""
    page_size = 20
    page_size_query_param = 'page_size'
    max_page_size = 100


class StudentListView(ListAPIView):
    """
    GET /api/v1/admin/students/
    List all students with search, filtering, and pagination.
    """
    serializer_class = StudentListSerializer
    permission_classes = [IsAdminUser]
    pagination_class = StudentPagination
    filter_backends = [DjangoFilterBackend]
    filterset_class = StudentFilter
    
    def get_queryset(self):
        """Optimized queryset with prefetch for CV data"""
        return User.objects.select_related('cv_profile').prefetch_related(
            'cv_profile__generated_cvs'
        ).filter(role='student').order_by('-created_at')
    
    def list(self, request, *args, **kwargs):
        """Override to log admin access and format response"""
        app_logger.info(f"Admin {request.user.email} accessed student list")
        
        response = super().list(request, *args, **kwargs)
        
        # Format response with pagination metadata
        return success_response(
            message="Students retrieved successfully.",
            data={
                'count': response.data['count'],
                'total_pages': (response.data['count'] + self.pagination_class.page_size - 1) // self.pagination_class.page_size,
                'current_page': int(request.GET.get('page', 1)),
                'next': response.data['next'],
                'previous': response.data['previous'],
                'results': response.data['results'],
            }
        )


class StudentDetailView(RetrieveAPIView):
    """
    GET /api/v1/admin/students/<uuid:pk>/
    Get full student detail including CV completion and generation history.
    """
    serializer_class = StudentDetailSerializer
    permission_classes = [IsAdminUser]
    lookup_field = 'pk'
    
    def get_queryset(self):
        """Optimized queryset with all related data"""
        return User.objects.select_related('cv_profile').prefetch_related(
            'cv_profile__generated_cvs'
        ).filter(role='student')
    
    def retrieve(self, request, *args, **kwargs):
        """Override to log admin access"""
        instance = self.get_object()
        app_logger.info(f"Admin {request.user.email} accessed student detail for {instance.email}")
        
        serializer = self.get_serializer(instance)
        return success_response(
            message="Student details retrieved successfully.",
            data=serializer.data
        )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def student_cv_detail(request, pk):
    """
    GET /api/v1/admin/students/<uuid:pk>/cv/
    Get the full CV data of a specific student (read-only).
    """
    try:
        student = User.objects.select_related('cv_profile').get(
            pk=pk, role='student'
        )
    except User.DoesNotExist:
        return error_response(
            message="Student not found.",
            status_code=status.HTTP_404_NOT_FOUND
        )
    
    app_logger.info(f"Admin {request.user.email} accessed CV data for student {student.email}")
    
    try:
        cv_profile = student.cv_profile
        serializer = CVProfileSerializer(cv_profile)
        
        return success_response(
            message="Student CV data retrieved successfully.",
            data=serializer.data
        )
    except:
        return success_response(
            message="Student has no CV data yet.",
            data=None
        )


@api_view(['PATCH'])
@permission_classes([IsAdminUser])
def update_student_status(request, pk):
    """
    PATCH /api/v1/admin/students/<uuid:pk>/status/
    Change student account status with validation and audit logging.
    """
    try:
        student = User.objects.get(pk=pk, role='student')
    except User.DoesNotExist:
        return error_response(
            message="Student not found.",
            status_code=status.HTTP_404_NOT_FOUND
        )
    
    # Prevent admin from changing their own status
    if student.id == request.user.id:
        return error_response(
            message="Cannot change your own account status.",
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    serializer = StudentStatusUpdateSerializer(student, data=request.data, partial=True)
    
    if not serializer.is_valid():
        return error_response(
            message="Validation failed.",
            details=serializer.errors,
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    old_status = student.status
    new_status = serializer.validated_data['status']
    reason = serializer.validated_data.get('reason', '')
    
    # Update student status
    student.status = new_status
    student.save(update_fields=['status', 'updated_at'])
    
    # Create audit log entry
    AuditLog.objects.create(
        student=student,
        action=AuditLog.Action.ACCOUNT_SUSPENDED if new_status == User.Status.SUSPENDED else AuditLog.Action.ACCOUNT_REACTIVATED,
        ip_address=request.META.get('REMOTE_ADDR', 'Unknown'),
        user_agent=request.META.get('HTTP_USER_AGENT', 'Unknown'),
        extra_data={
            'old_status': old_status,
            'new_status': new_status,
            'reason': reason,
            'changed_by_admin': request.user.email,
        }
    )
    
    app_logger.info(
        f"Admin {request.user.email} changed student {student.email} status "
        f"from {old_status} to {new_status}. Reason: {reason}"
    )
    
    return success_response(
        message=f"Student status updated to {new_status}.",
        data={
            'student_id': student.id,
            'old_status': old_status,
            'new_status': new_status,
            'reason': reason,
        }
    )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def deletion_requests_list(request):
    """
    GET /api/v1/admin/students/deletion-requests/
    List all students who have requested data deletion.
    """
    app_logger.info(f"Admin {request.user.email} accessed deletion requests list")
    
    students = User.objects.filter(
        deletion_requested_at__isnull=False,
        is_deleted=False,
        role='student'
    ).order_by('deletion_requested_at')
    
    serializer = DeletionRequestSerializer(students, many=True)
    
    return success_response(
        message="Deletion requests retrieved successfully.",
        data=serializer.data
    )


@api_view(['POST'])
@permission_classes([IsAdminUser])
def process_deletion_request(request, pk):
    """
    POST /api/v1/admin/students/<uuid:pk>/process-deletion/
    Admin confirms and processes a student deletion request.
    Anonymizes data instead of hard deletion.
    """
    try:
        student = User.objects.get(pk=pk, role='student')
    except User.DoesNotExist:
        return error_response(
            message="Student not found.",
            status_code=status.HTTP_404_NOT_FOUND
        )
    
    # Prevent admin from processing their own deletion
    if student.id == request.user.id:
        return error_response(
            message="Cannot process your own deletion request.",
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if deletion was requested
    if not student.deletion_requested_at:
        return error_response(
            message="Student has not requested deletion.",
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    # Check if already processed
    if student.is_deleted:
        return error_response(
            message="Deletion request already processed.",
            status_code=status.HTTP_400_BAD_REQUEST
        )
    
    # Process deletion atomically
    try:
        with transaction.atomic():
            # Store original data for logging
            original_email = student.email
            original_name = student.full_name
            
            # Anonymize student data
            anonymous_uuid = str(uuid.uuid4())[:8]
            student.full_name = "Deleted User"
            student.email = f"deleted_{anonymous_uuid}@deleted.com"
            student.student_id = f"DELETED_{anonymous_uuid}"
            student.phone = ""
            student.address = ""
            student.linkedin = ""
            student.github = ""
            student.portfolio = ""
            student.is_deleted = True
            student.deleted_at = timezone.now()
            student.status = User.Status.DEACTIVATED
            
            # Clear CV profile data if exists
            try:
                cv_profile = student.cv_profile
                cv_profile.phone = ""
                cv_profile.address = ""
                cv_profile.city = ""
                cv_profile.country = ""
                cv_profile.summary = ""
                cv_profile.linkedin = ""
                cv_profile.github = ""
                cv_profile.portfolio = ""
                if cv_profile.photo:
                    cv_profile.photo.delete()
                    cv_profile.photo = None
                cv_profile.save()
                
                # Delete generated CV files from disk
                for generated_cv in cv_profile.generated_cvs.all():
                    if generated_cv.file_path:
                        try:
                            import os
                            if os.path.exists(generated_cv.file_path):
                                os.remove(generated_cv.file_path)
                        except Exception as e:
                            app_logger.error(f"Failed to delete CV file {generated_cv.file_path}: {e}")
                    
                    # Clear file path but keep record for audit
                    generated_cv.file_path = ""
                    generated_cv.save(update_fields=['file_path'])
                
            except Exception as e:
                app_logger.error(f"Error anonymizing CV data for {original_email}: {e}")
            
            student.save()
            
            # Create final audit log
            AuditLog.objects.create(
                student=student,
                action=AuditLog.Action.ACCOUNT_DELETED,
                ip_address=request.META.get('REMOTE_ADDR', 'Unknown'),
                user_agent=request.META.get('HTTP_USER_AGENT', 'Unknown'),
                extra_data={
                    'processed_by_admin': request.user.email,
                    'original_email': original_email,
                    'original_name': original_name,
                    'deletion_requested_at': student.deletion_requested_at.isoformat(),
                    'processed_at': student.deleted_at.isoformat(),
                }
            )
            
            app_logger.info(
                f"Admin {request.user.email} processed deletion request for "
                f"{original_email} ({original_name}). Data anonymized."
            )
            
            return success_response(
                message="Deletion request processed successfully. Student data has been anonymized.",
                data={
                    'student_id': student.id,
                    'processed_at': student.deleted_at,
                    'anonymized_email': student.email,
                }
            )
            
    except Exception as e:
        app_logger.error(f"Error processing deletion for student {pk}: {e}")
        return error_response(
            message="Failed to process deletion request. Please try again.",
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        )