"""
CV Intelligence Exception Handling and Validation.
Provides robust error handling and input validation.
"""
import logging
from typing import Dict, Any, Optional
from django.core.exceptions import ValidationError
from rest_framework import status
from rest_framework.response import Response

logger = logging.getLogger(__name__)


class CVIntelligenceException(Exception):
    """Base exception for CV Intelligence operations."""
    
    def __init__(self, message: str, error_code: str = None, details: Dict = None):
        self.message = message
        self.error_code = error_code or 'CV_INTELLIGENCE_ERROR'
        self.details = details or {}
        super().__init__(self.message)


class CVAnalysisException(CVIntelligenceException):
    """Exception raised during CV analysis operations."""
    pass


class CVValidationException(CVIntelligenceException):
    """Exception raised during CV validation operations."""
    pass


class ConfigurationException(CVIntelligenceException):
    """Exception raised for configuration errors."""
    pass


class CVIntelligenceValidator:
    """
    Validates inputs and system state for CV intelligence operations.
    """
    
    @staticmethod
    def validate_cv_profile(cv_profile) -> bool:
        """Validate that CV profile exists and has minimum required data."""
        if not cv_profile:
            raise CVValidationException(
                "CV profile not found",
                error_code='CV_PROFILE_NOT_FOUND'
            )
        
        if not cv_profile.student:
            raise CVValidationException(
                "CV profile has no associated student",
                error_code='CV_PROFILE_INVALID'
            )
        
        return True
    
    @staticmethod
    def validate_analysis_request(user, request_data: Dict) -> Dict:
        """Validate CV analysis request parameters."""
        validated_data = {}
        
        # Validate analysis type
        analysis_type = request_data.get('analysis_type', 'comprehensive')
        valid_types = ['comprehensive', 'quick', 'suggestions_only']
        if analysis_type not in valid_types:
            raise CVValidationException(
                f"Invalid analysis type: {analysis_type}",
                error_code='INVALID_ANALYSIS_TYPE',
                details={'valid_types': valid_types}
            )
        validated_data['analysis_type'] = analysis_type
        
        # Validate target industry
        target_industry = request_data.get('target_industry', '')
        if target_industry:
            from .config import IndustryConfig
            valid_industries = IndustryConfig.get_available_industries()
            if target_industry not in valid_industries:
                raise CVValidationException(
                    f"Invalid target industry: {target_industry}",
                    error_code='INVALID_INDUSTRY',
                    details={'valid_industries': valid_industries}
                )
        validated_data['target_industry'] = target_industry
        
        # Validate include_suggestions
        include_suggestions = request_data.get('include_suggestions', True)
        if not isinstance(include_suggestions, bool):
            raise CVValidationException(
                "include_suggestions must be a boolean",
                error_code='INVALID_BOOLEAN_VALUE'
            )
        validated_data['include_suggestions'] = include_suggestions
        
        return validated_data
    
    @staticmethod
    def validate_suggestion_id(suggestion_id: str, user) -> bool:
        """Validate that suggestion exists and belongs to user."""
        from .models import ContentSuggestion
        
        try:
            suggestion = ContentSuggestion.objects.get(id=suggestion_id, user=user)
            if suggestion.applied:
                raise CVValidationException(
                    "Suggestion has already been applied",
                    error_code='SUGGESTION_ALREADY_APPLIED'
                )
            return True
        except ContentSuggestion.DoesNotExist:
            raise CVValidationException(
                "Suggestion not found or access denied",
                error_code='SUGGESTION_NOT_FOUND'
            )
    
    @staticmethod
    def validate_issue_id(issue_id: str, user) -> bool:
        """Validate that issue exists and belongs to user."""
        from .models import ValidationIssue
        
        try:
            issue = ValidationIssue.objects.get(id=issue_id, user=user)
            if issue.resolved:
                raise CVValidationException(
                    "Issue has already been resolved",
                    error_code='ISSUE_ALREADY_RESOLVED'
                )
            return True
        except ValidationIssue.DoesNotExist:
            raise CVValidationException(
                "Issue not found or access denied",
                error_code='ISSUE_NOT_FOUND'
            )


class CVIntelligenceErrorHandler:
    """
    Centralized error handling for CV intelligence operations.
    """
    
    @staticmethod
    def handle_exception(exception: Exception, request=None, user=None) -> Response:
        """Handle exceptions and return appropriate API response."""
        
        # Log the error with sanitized inputs
        sanitized_exception = str(exception)[:200].replace('\n', ' ').replace('\r', '')
        logger.error(
            f'CV Intelligence error: {type(exception).__name__}: {sanitized_exception}',
            extra={
                'user_id': str(user.id) if user else None,
                'exception_type': type(exception).__name__,
                'request_path': request.path if request else None
            },
            exc_info=True
        )
        
        # Handle CV Intelligence specific exceptions
        if isinstance(exception, CVIntelligenceException):
            return Response({
                'success': False,
                'message': exception.message,
                'error': {
                    'code': exception.error_code,
                    'message': exception.message,
                    'details': exception.details
                }
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Handle validation errors
        if isinstance(exception, ValidationError):
            return Response({
                'success': False,
                'message': 'Validation failed',
                'error': {
                    'code': 'VALIDATION_ERROR',
                    'message': 'Validation failed',
                    'details': exception.message_dict if hasattr(exception, 'message_dict') else {'detail': str(exception)}
                }
            }, status=status.HTTP_400_BAD_REQUEST)
        
        # Handle unexpected errors
        return Response({
            'success': False,
            'message': 'An unexpected error occurred',
            'error': {
                'code': 'INTERNAL_ERROR',
                'message': 'An unexpected error occurred. Please try again.',
                'details': {}
            }
        }, status=status.HTTP_500_INTERNAL_SERVER_ERROR)
    
    @staticmethod
    def log_analysis_metrics(user, analysis_results: Dict, duration: float):
        """Log analysis performance metrics."""
        # Sanitize grade value to prevent log injection
        grade = str(analysis_results.get('grade', 'Unknown')).replace('\n', '').replace('\r', '')
        
        logger.info(
            "CV analysis completed",
            extra={
                'user_id': str(user.id),
                'overall_score': analysis_results.get('overall_score'),
                'grade': grade,
                'duration_seconds': duration,
                'total_issues': analysis_results.get('total_issues', 0),
                'total_suggestions': analysis_results.get('total_suggestions', 0)
            }
        )


def handle_cv_intelligence_errors(func):
    """
    Decorator for CV intelligence views to handle errors consistently.
    """
    def wrapper(self, request, *args, **kwargs):
        try:
            return func(self, request, *args, **kwargs)
        except Exception as e:
            return CVIntelligenceErrorHandler.handle_exception(
                e, request=request, user=getattr(request, 'user', None)
            )
    return wrapper