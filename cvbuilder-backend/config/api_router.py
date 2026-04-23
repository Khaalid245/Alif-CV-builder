"""
API v1 router.
Each app registers its own URLs here.
Add new app URL includes in this file as phases are completed.
"""
from django.urls import path, include

urlpatterns = [
    # Phase 2 — Authentication
    path('auth/', include('apps.users.urls')),

    # Phase 3 — CV Data + Phase 4 — PDF Generation (both under /cv/)
    path('cv/', include('apps.cv.urls')),
    path('cv/', include('apps.pdf_generator.urls')),

    # Phase 5 — Admin Dashboard
    path('administration/', include('apps.administration.urls')),
]
