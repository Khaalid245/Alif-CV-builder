"""
URL patterns for CV Intelligence API endpoints.
"""
from django.urls import path
from .views import (
    CVAnalysisView, CVScoreView, cv_intelligence_dashboard,
    CVAnalysisHistoryView, CVAnalysisHistoryDetailView, 
    CVBenchmarkingView, CVAnalysisExportView
)

app_name = 'cv_intelligence'

urlpatterns = [
    # CV Analysis
    path('analyze/', CVAnalysisView.as_view(), name='cv_analyze'),
    path('score/', CVScoreView.as_view(), name='cv_score'),
    path('dashboard/', cv_intelligence_dashboard, name='intelligence_dashboard'),
    
    # Analysis History
    path('analysis/history/', CVAnalysisHistoryView.as_view(), name='analysis_history'),
    path('analysis/history/<uuid:history_id>/', CVAnalysisHistoryDetailView.as_view(), name='analysis_history_detail'),
    
    # Benchmarking
    path('benchmarking/', CVBenchmarkingView.as_view(), name='benchmarking'),
    
    # Export
    path('export-analysis/', CVAnalysisExportView.as_view(), name='export_analysis'),
]