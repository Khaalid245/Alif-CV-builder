"""
API v1 router.
Each app registers its own URLs here.
Add new app URL includes in this file as phases are completed.
"""
from django.urls import path, include
from apps.core.health_checks import health_check, readiness_check, liveness_check

urlpatterns = [
    # Health checks (no auth required)
    path('health/', health_check, name='health_check'),
    path('ready/', readiness_check, name='readiness_check'),
    path('live/', liveness_check, name='liveness_check'),

    # Phase 2 — Authentication
    path('auth/', include('apps.users.urls')),

    # Phase 3 — CV Data + Phase 4 — PDF Generation (both under /cv/)
    path('cv/', include('apps.cv.urls')),
    path('cv/', include('apps.pdf_generator.urls')),

    # Phase 5 — Admin Dashboard
    path('administration/', include('apps.administration.urls')),
]
