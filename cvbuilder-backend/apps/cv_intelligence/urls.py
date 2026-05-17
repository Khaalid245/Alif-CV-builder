"""
URL patterns for CV Intelligence API endpoints.
"""
from django.urls import path
from .views import CVAnalysisView, CVScoreView, cv_intelligence_dashboard

app_name = 'cv_intelligence'

urlpatterns = [
    # CV Analysis
    path('analyze/', CVAnalysisView.as_view(), name='cv_analyze'),
    path('score/', CVScoreView.as_view(), name='cv_score'),
    path('dashboard/', cv_intelligence_dashboard, name='intelligence_dashboard'),
]