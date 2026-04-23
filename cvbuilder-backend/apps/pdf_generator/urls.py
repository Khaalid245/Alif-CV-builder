"""
PDF Generator URL patterns.
Mounted under /api/v1/cv/ via config/api_router.py.
"""
from django.urls import path
from .views import GenerateCVView, DownloadCVView, CVHistoryView

urlpatterns = [
    path('generate/', GenerateCVView.as_view(), name='cv-generate'),
    path('download/<uuid:pk>/', DownloadCVView.as_view(), name='cv-download'),
    path('history/', CVHistoryView.as_view(), name='cv-history'),
]
