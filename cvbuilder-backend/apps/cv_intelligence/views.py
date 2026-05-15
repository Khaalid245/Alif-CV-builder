"""
CV Intelligence API Views.
Provides endpoints for CV analysis, scoring, and suggestions.
"""
import logging
import time
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes

from apps.core.responses import success_response, error_response
from apps.cv.models import CVProfile
from apps.users.models import AuditLog
from .services import CVAnalysisService
from .serializers import (
    CVAnalysisSerializer, ContentSuggestionSerializer, ValidationIssueSerializer,
    CVIntelligenceDashboardSerializer, CVAnalysisRequestSerializer,
    ApplySuggestionSerializer, ResolveIssueSerializer
)
from .exceptions import (
    CVIntelligenceValidator, CVIntelligenceErrorHandler, handle_cv_intelligence_errors
)

logger = logging.getLogger(__name__)


class CVAnalysisView(APIView):
    """
    POST /api/v1/cv/analyze/
    Perform comprehensive CV analysis and return detailed feedback.
    """
    permission_classes = [IsAuthenticated]
    
    @handle_cv_intelligence_errors
    def post(self, request):
        start_time = time.time()
        
        # Validate request data
        request_serializer = CVAnalysisRequestSerializer(data=request.data)
        if not request_serializer.is_valid():
            return error_response(
                'Invalid request parameters.',
                request_serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )
        
        validated_data = CVIntelligenceValidator.validate_analysis_request(
            request.user, request_serializer.validated_data
        )
        # Get user's CV profile
        cv_profile = CVProfile.objects.prefetch_related(
            'educations', 'experiences', 'skills', 
            'languages', 'projects', 'certifications'
        ).filter(student=request.user).first()
        
        CVIntelligenceValidator.validate_cv_profile(cv_profile)
            
        # Perform analysis
        analysis_service = CVAnalysisService()
        analysis_results = analysis_service.analyze_cv_comprehensive(
            request.user, cv_profile
        )
        
        # Log performance metrics
        duration = time.time() - start_time
        CVIntelligenceErrorHandler.log_analysis_metrics(
            request.user, analysis_results, duration
        )
            
        # Log the analysis
        AuditLog.log(
            request.user,
            AuditLog.Action.CV_UPDATED,
            request,
            extra_data={
                'action': 'cv_analysis',
                'score': analysis_results['overall_score'],
                'grade': analysis_results['grade'],
                'duration': duration
            }
        )
        
        return success_response(
            'CV analysis completed successfully.',
            analysis_results
        )


class CVScoreView(APIView):
    """
    GET /api/v1/cv/score/
    Get the latest CV analysis score and breakdown.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            analysis_service = CVAnalysisService()
            latest_analysis = analysis_service.get_latest_analysis(request.user)
            
            if not latest_analysis:
                return success_response(
                    'No CV analysis found. Run analysis first.',
                    {'analysis_available': False}
                )
            
            return success_response(
                'CV score retrieved successfully.',
                {
                    'analysis_available': True,
                    **latest_analysis
                }
            )
            
        except Exception as e:
            logger.error(f'Failed to get CV score for user {request.user.email}: {str(e)}')
            return error_response(
                'Failed to retrieve CV score.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ContentSuggestionsView(APIView):
    """
    GET /api/v1/cv/suggestions/
    Get content improvement suggestions for the user's CV.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            section_type = request.query_params.get('section')
            
            analysis_service = CVAnalysisService()
            suggestions = analysis_service.get_content_suggestions(request.user, section_type)
            
            return success_response(
                'Content suggestions retrieved successfully.',
                {
                    'suggestions': suggestions,
                    'total_count': len(suggestions),
                    'filtered_by_section': section_type
                }
            )
            
        except Exception as e:
            logger.error(f'Failed to get content suggestions for user {request.user.email}: {str(e)}')
            return error_response(
                'Failed to retrieve content suggestions.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ApplySuggestionView(APIView):
    """
    POST /api/v1/cv/suggestions/<suggestion_id>/apply/
    Mark a content suggestion as applied.
    """
    permission_classes = [IsAuthenticated]
    
    @handle_cv_intelligence_errors
    def post(self, request, suggestion_id):
        # Validate suggestion
        CVIntelligenceValidator.validate_suggestion_id(suggestion_id, request.user)
        
        # Validate request data
        serializer = ApplySuggestionSerializer(data=request.data)
        if not serializer.is_valid():
            return error_response(
                'Invalid request data.',
                serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )
        analysis_service = CVAnalysisService()
        success = analysis_service.apply_suggestion(
            request.user, suggestion_id
        )
        
        if success:
            return success_response(
                'Suggestion marked as applied successfully.',
                {'suggestion_id': suggestion_id, 'applied': True}
            )
        else:
            return error_response(
                'Failed to apply suggestion.',
                status_code=status.HTTP_400_BAD_REQUEST
            )


class ValidationIssuesView(APIView):
    """
    GET /api/v1/cv/issues/
    Get validation issues found in the user's CV.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            resolved = request.query_params.get('resolved', 'false').lower() == 'true'
            
            analysis_service = CVAnalysisService()
            issues = analysis_service.get_validation_issues(request.user, resolved)
            
            return success_response(
                'Validation issues retrieved successfully.',
                {
                    'issues': issues,
                    'total_count': len(issues),
                    'showing_resolved': resolved
                }
            )
            
        except Exception as e:
            logger.error(f'Failed to get validation issues for user {request.user.email}: {str(e)}')
            return error_response(
                'Failed to retrieve validation issues.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class ResolveIssueView(APIView):
    """
    POST /api/v1/cv/issues/<issue_id>/resolve/
    Mark a validation issue as resolved.
    """
    permission_classes = [IsAuthenticated]
    
    @handle_cv_intelligence_errors
    def post(self, request, issue_id):
        # Validate issue
        CVIntelligenceValidator.validate_issue_id(issue_id, request.user)
        
        # Validate request data
        serializer = ResolveIssueSerializer(data=request.data)
        if not serializer.is_valid():
            return error_response(
                'Invalid request data.',
                serializer.errors,
                status_code=status.HTTP_400_BAD_REQUEST
            )
        analysis_service = CVAnalysisService()
        success = analysis_service.resolve_issue(
            request.user, issue_id
        )
        
        if success:
            return success_response(
                'Issue marked as resolved successfully.',
                {'issue_id': issue_id, 'resolved': True}
            )
        else:
            return error_response(
                'Failed to resolve issue.',
                status_code=status.HTTP_400_BAD_REQUEST
            )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cv_intelligence_dashboard(request):
    """
    GET /api/v1/cv/intelligence/dashboard/
    Get comprehensive CV intelligence dashboard data.
    """
    try:
        analysis_service = CVAnalysisService()
        
        # Get latest analysis
        latest_analysis = analysis_service.get_latest_analysis(request.user)
        
        # Get pending suggestions and issues
        suggestions = analysis_service.get_content_suggestions(request.user)
        issues = analysis_service.get_validation_issues(request.user, resolved=False)
        
        dashboard_data = {
            'analysis': latest_analysis,
            'pending_suggestions': len(suggestions),
            'pending_issues': len(issues),
            'top_suggestions': suggestions[:3],  # Top 3 suggestions
            'critical_issues': [issue for issue in issues if issue['severity'] == 'critical'][:3],
            'last_updated': latest_analysis['analysis_date'] if latest_analysis else None
        }
        
        return success_response(
            'CV intelligence dashboard data retrieved successfully.',
            dashboard_data
        )
        
    except Exception as e:
        logger.error(f'Failed to get dashboard data for user {request.user.email}: {str(e)}')
        return error_response(
            'Failed to retrieve dashboard data.',
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        )