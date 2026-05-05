"""
Health check views for system monitoring.
Provides basic and detailed system health information.
"""
import logging
import os
from django.conf import settings
from django.db import connection
from django.utils import timezone
from rest_framework import status
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response

from apps.core.responses import success_response, error_response
from apps.administration.permissions import IsAdminUser
from apps.users.models import User, AuditLog
from apps.cv.models import CVProfile, GeneratedCV

# Application logger
app_logger = logging.getLogger('app')


@api_view(['GET'])
@permission_classes([AllowAny])
def basic_health_check(request):
    """
    GET /api/v1/admin/health/
    Basic system health check for monitoring tools.
    No authentication required.
    """
    try:
        # Test database connection
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            db_status = "connected"
    except Exception as e:
        app_logger.error(f"Database health check failed: {e}")
        db_status = "disconnected"
    
    # Test media storage accessibility
    try:
        media_root = settings.MEDIA_ROOT
        if os.path.exists(media_root) and os.access(media_root, os.W_OK):
            storage_status = "accessible"
        else:
            storage_status = "inaccessible"
    except Exception as e:
        app_logger.error(f"Media storage health check failed: {e}")
        storage_status = "error"
    
    # Determine overall status
    overall_status = "healthy" if db_status == "connected" and storage_status == "accessible" else "unhealthy"
    
    data = {
        "status": overall_status,
        "version": getattr(settings, 'APP_VERSION', '1.0.0'),
        "database": db_status,
        "media_storage": storage_status,
        "timestamp": timezone.now().isoformat(),
    }
    
    # Return appropriate HTTP status
    http_status = status.HTTP_200_OK if overall_status == "healthy" else status.HTTP_503_SERVICE_UNAVAILABLE
    
    return Response({
        "success": overall_status == "healthy",
        "message": f"System is {overall_status}",
        "data": data
    }, status=http_status)


@api_view(['GET'])
@permission_classes([IsAdminUser])
def detailed_health_check(request):
    """
    GET /api/v1/admin/health/detailed/
    Detailed system health information for admin monitoring.
    Requires admin authentication.
    """
    app_logger.info(f"Admin {request.user.email} accessed detailed health check")
    
    try:
        # Database health and record counts
        try:
            with connection.cursor() as cursor:
                cursor.execute("SELECT 1")
                db_status = "connected"
            
            # Get record counts efficiently
            record_counts = {
                "students": User.objects.filter(role='student').count(),
                "cv_profiles": CVProfile.objects.count(),
                "generated_cvs": GeneratedCV.objects.count(),
                "audit_logs": AuditLog.objects.count(),
            }
        except Exception as e:
            app_logger.error(f"Database detailed check failed: {e}")
            db_status = "error"
            record_counts = {"error": str(e)}
        
        # Storage health and file counts
        try:
            media_root = settings.MEDIA_ROOT
            generated_cvs_path = os.path.join(media_root, 'generated_cvs')
            
            if os.path.exists(media_root) and os.access(media_root, os.W_OK):
                storage_status = "accessible"
                
                # Count generated CV files
                cv_files_count = 0
                if os.path.exists(generated_cvs_path):
                    cv_files_count = len([f for f in os.listdir(generated_cvs_path) 
                                        if os.path.isfile(os.path.join(generated_cvs_path, f))])
            else:
                storage_status = "inaccessible"
                cv_files_count = 0
                
        except Exception as e:
            app_logger.error(f"Storage detailed check failed: {e}")
            storage_status = "error"
            cv_files_count = 0
        
        # Application information
        import django
        application_info = {
            "version": getattr(settings, 'APP_VERSION', '1.0.0'),
            "django_version": django.get_version(),
            "debug_mode": settings.DEBUG,
            "university": getattr(settings, 'UNIVERSITY_NAME', 'EduCV University'),
        }
        
        # Determine overall status
        overall_status = "healthy" if db_status == "connected" and storage_status == "accessible" else "unhealthy"
        
        data = {
            "status": overall_status,
            "database": {
                "status": db_status,
                "total_records": record_counts,
            },
            "storage": {
                "status": storage_status,
                "generated_cvs_count": cv_files_count,
            },
            "application": application_info,
        }
        
        return success_response(
            message=f"Detailed system health: {overall_status}",
            data=data
        )
        
    except Exception as e:
        app_logger.error(f"Detailed health check failed: {e}")
        return error_response(
            message="Health check failed",
            details={"error": str(e)},
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        )