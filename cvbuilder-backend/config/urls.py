"""
Root URL configuration for EduCV.
All API endpoints are versioned under /api/v1/.
"""
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from apps.core.health_checks import health_check

urlpatterns = [
    # Health check (no auth required)
    path('health/', health_check, name='health-check'),
    
    # Django admin (internal use only)
    path('admin/', admin.site.urls),

    # API v1 — all application endpoints
    path('api/v1/', include('config.api_router')),
]

# Serve media files in development (WeasyPrint-generated PDFs)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
