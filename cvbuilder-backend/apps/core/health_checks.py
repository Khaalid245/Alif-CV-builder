"""
Health check endpoint for EduCV application monitoring.
Provides detailed health status for load balancers and monitoring systems.
"""
from django.http import JsonResponse
from django.db import connection
from django.core.cache import cache
from django.conf import settings
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import AllowAny
from apps.core.metrics import update_active_users
import time


@api_view(['GET'])
@permission_classes([AllowAny])
def health_check(request):
    """
    Comprehensive health check endpoint.
    Returns 200 if all systems are healthy, 503 if any critical system is down.
    """
    start_time = time.time()
    health_status = {
        'status': 'healthy',
        'timestamp': time.time(),
        'checks': {}
    }
    
    overall_healthy = True
    
    # Database connectivity check
    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        health_status['checks']['database'] = {
            'status': 'healthy',
            'message': 'Database connection successful'
        }
    except Exception as e:
        health_status['checks']['database'] = {
            'status': 'unhealthy',
            'message': f'Database connection failed: {str(e)}'
        }
        overall_healthy = False
    
    # Cache connectivity check (if configured)
    try:
        cache_key = 'health_check_test'
        cache.set(cache_key, 'test_value', 30)
        cached_value = cache.get(cache_key)
        
        if cached_value == 'test_value':
            health_status['checks']['cache'] = {
                'status': 'healthy',
                'message': 'Cache is working'
            }
        else:
            health_status['checks']['cache'] = {
                'status': 'unhealthy',
                'message': 'Cache read/write failed'
            }
            overall_healthy = False
            
    except Exception as e:
        health_status['checks']['cache'] = {
            'status': 'unhealthy',
            'message': f'Cache error: {str(e)}'
        }
        # Cache is not critical, don't mark as unhealthy
    
    # Disk space check
    try:
        import shutil
        media_usage = shutil.disk_usage(settings.MEDIA_ROOT)
        free_space_gb = media_usage.free / (1024**3)
        
        if free_space_gb > 1.0:  # At least 1GB free
            health_status['checks']['disk_space'] = {
                'status': 'healthy',
                'message': f'Free space: {free_space_gb:.1f}GB'
            }
        else:
            health_status['checks']['disk_space'] = {
                'status': 'warning',
                'message': f'Low disk space: {free_space_gb:.1f}GB'
            }
            
    except Exception as e:
        health_status['checks']['disk_space'] = {
            'status': 'unknown',
            'message': f'Could not check disk space: {str(e)}'
        }
    
    # Update metrics
    try:
        update_active_users()
        health_status['checks']['metrics'] = {
            'status': 'healthy',
            'message': 'Metrics updated successfully'
        }
    except Exception as e:
        health_status['checks']['metrics'] = {
            'status': 'warning',
            'message': f'Metrics update failed: {str(e)}'
        }
    
    # Calculate response time
    response_time = time.time() - start_time
    health_status['response_time_ms'] = round(response_time * 1000, 2)
    
    # Set overall status
    if not overall_healthy:
        health_status['status'] = 'unhealthy'
        status_code = 503
    else:
        status_code = 200
    
    return JsonResponse(health_status, status=status_code)


@api_view(['GET'])
@permission_classes([AllowAny])
def readiness_check(request):
    """
    Readiness check for Kubernetes/container orchestration.
    Returns 200 when the application is ready to serve traffic.
    """
    try:
        # Quick database check
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
            cursor.fetchone()
        
        return JsonResponse({
            'status': 'ready',
            'timestamp': time.time()
        })
        
    except Exception as e:
        return JsonResponse({
            'status': 'not_ready',
            'error': str(e),
            'timestamp': time.time()
        }, status=503)


@api_view(['GET'])
@permission_classes([AllowAny])
def liveness_check(request):
    """
    Liveness check for Kubernetes/container orchestration.
    Returns 200 if the application process is alive.
    """
    return JsonResponse({
        'status': 'alive',
        'timestamp': time.time()
    })