"""
URL patterns for CV Intelligence API endpoints.
All endpoints require authentication and provide CV analysis features.
"""
from django.urls import path
from .views import (
    CVAnalysisView,
    CVScoreView,
    ContentSuggestionsView,
    ApplySuggestionView,
    ValidationIssuesView,
    ResolveIssueView,
    cv_intelligence_dashboard,
)

app_name = 'cv_intelligence'

urlpatterns = [
    # CV Analysis
    path('analyze/', CVAnalysisView.as_view(), name='cv_analyze'),
    path('score/', CVScoreView.as_view(), name='cv_score'),
    
    # Content Suggestions
    path('suggestions/', ContentSuggestionsView.as_view(), name='content_suggestions'),
    path('suggestions/<uuid:suggestion_id>/apply/', ApplySuggestionView.as_view(), name='apply_suggestion'),
    
    # Validation Issues
    path('issues/', ValidationIssuesView.as_view(), name='validation_issues'),
    path('issues/<uuid:issue_id>/resolve/', ResolveIssueView.as_view(), name='resolve_issue'),
    
    # Dashboard
    path('dashboard/', cv_intelligence_dashboard, name='intelligence_dashboard'),
]