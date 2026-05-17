"""
URL patterns for Version History API.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    CVVersionViewSet, VersionDiffViewSet, VersionActionViewSet,
    VersionConfigurationView, VersionCleanupLogViewSet
)

# Create router for ViewSets
router = DefaultRouter()
router.register(r'versions', CVVersionViewSet, basename='cv-versions')
router.register(r'diffs', VersionDiffViewSet, basename='version-diffs')
router.register(r'actions', VersionActionViewSet, basename='version-actions')
router.register(r'cleanup-logs', VersionCleanupLogViewSet, basename='cleanup-logs')

app_name = 'version_history'

urlpatterns = [
    # ViewSet routes
    path('', include(router.urls)),
    
    # Configuration management
    path('config/', VersionConfigurationView.as_view(), name='version-config'),
]