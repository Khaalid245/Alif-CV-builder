"""
URL configuration for Analytics API.
Provides REST endpoints for analytics, benchmarking, and dashboard operations.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    ScoreSnapshotViewSet, BenchmarkingGroupViewSet, MetricDefinitionViewSet,
    AnalyticsEventViewSet, CreateSnapshotView, TrendAnalysisView,
    BenchmarkingView, CompletionStatisticsView, AnalyticsConfigurationView,
    AnalyticsDashboardView, AdminDashboardView
)

app_name = 'analytics'

# Create router for viewsets
router = DefaultRouter()
router.register(r'snapshots', ScoreSnapshotViewSet, basename='snapshots')
router.register(r'benchmarking-groups', BenchmarkingGroupViewSet, basename='benchmarking-groups')
router.register(r'metrics', MetricDefinitionViewSet, basename='metrics')
router.register(r'events', AnalyticsEventViewSet, basename='events')

urlpatterns = [
    # ViewSet routes
    path('', include(router.urls)),
    
    # Custom API views
    path('snapshots/create/', CreateSnapshotView.as_view(), name='create-snapshot'),
    path('trends/analyze/', TrendAnalysisView.as_view(), name='trend-analysis'),
    path('benchmarking/compare/', BenchmarkingView.as_view(), name='peer-benchmarking'),
    path('statistics/completion/', CompletionStatisticsView.as_view(), name='completion-statistics'),
    path('configuration/', AnalyticsConfigurationView.as_view(), name='configuration'),
    path('dashboard/', AnalyticsDashboardView.as_view(), name='user-dashboard'),
    path('dashboard/admin/', AdminDashboardView.as_view(), name='admin-dashboard'),
]