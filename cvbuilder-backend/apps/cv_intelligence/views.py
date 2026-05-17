"""
CV Intelligence API Views.
Minimal working implementation for CV analysis.
"""
import logging
from typing import Dict
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView
from rest_framework.decorators import api_view, permission_classes

from apps.core.responses import success_response, error_response
from apps.cv.models import CVProfile
from .validators import CVValidator
from .models import CVAnalysis

logger = logging.getLogger(__name__)


class CVAnalysisView(APIView):
    """
    GET  /api/v1/cv/analyze/ → Get existing analysis or create new one
    POST /api/v1/cv/analyze/ → Force new analysis
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get existing analysis or create new one if none exists."""
        try:
            # Check for existing analysis
            analysis = CVAnalysis.objects.filter(user=request.user).first()
            
            if analysis:
                return success_response(
                    'CV analysis retrieved successfully.',
                    self._format_analysis_response(analysis)
                )
            
            # No existing analysis, create new one
            return self.post(request)
            
        except Exception as e:
            logger.error(f'Failed to get CV analysis for user {request.user.email}: {str(e)}')
            return error_response(
                'Failed to retrieve CV analysis.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request):
        """Perform comprehensive CV analysis and return detailed feedback."""
        try:
            # Get user's CV profile
            cv_profile = CVProfile.objects.prefetch_related(
                'educations', 'experiences', 'skills', 
                'languages', 'projects', 'certifications'
            ).filter(student=request.user).first()
            
            if not cv_profile:
                return error_response(
                    'CV profile not found. Please create your CV first.',
                    status_code=status.HTTP_404_NOT_FOUND
                )
            
            # Perform validation
            validator = CVValidator()
            results = validator.validate_cv_profile(cv_profile)
            
            # Save analysis to database
            analysis, created = CVAnalysis.objects.update_or_create(
                user=request.user,
                defaults={
                    'overall_score': results['overall_score'],
                    'profile_score': results['score_breakdown']['profile'],
                    'experience_score': results['score_breakdown']['experience'],
                    'education_score': results['score_breakdown']['education'],
                    'skills_score': results['score_breakdown']['skills'],
                    'projects_score': results['score_breakdown']['projects'],
                    'submission_ready': results['is_submission_ready'],
                    'analysis_data': results,
                    'grade': results['grade'],
                    'total_issues': len(results['issues']),
                    'critical_issues': len([i for i in results['issues'] if i['severity'] == 'critical']),
                    'total_recommendations': len(results['recommendations']['critical']) + 
                                           len(results['recommendations']['important']) + 
                                           len(results['recommendations']['suggestions'])
                }
            )
            
            action = 'updated' if not created else 'created'
            logger.info(f'CV analysis {action} for user {request.user.email} - Score: {results["overall_score"]}')
            
            return success_response(
                'CV analysis completed successfully.',
                self._format_analysis_response(analysis)
            )
            
        except Exception as e:
            logger.error(f'CV analysis failed for user {request.user.email}: {str(e)}')
            return error_response(
                'CV analysis failed. Please try again.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _format_analysis_response(self, analysis: CVAnalysis) -> Dict:
        """Format analysis object into API response."""
        analysis_data = analysis.analysis_data or {}
        
        return {
            'id': str(analysis.id),
            'overall_score': analysis.overall_score,
            'profile_score': analysis.profile_score,
            'experience_score': analysis.experience_score,
            'education_score': analysis.education_score,
            'skills_score': analysis.skills_score,
            'projects_score': analysis.projects_score,
            'grade': analysis.grade,
            'is_submission_ready': analysis.submission_ready,
            'recommendations': analysis_data.get('recommendations', {
                'critical': [],
                'important': [],
                'suggestions': [],
                'strengths': []
            }),
            'total_issues': analysis.total_issues,
            'critical_issues': analysis.critical_issues,
            'total_recommendations': analysis.total_recommendations,
            'analyzed_at': analysis.created_at.isoformat(),
            'last_updated': analysis.updated_at.isoformat()
        }


class CVScoreView(APIView):
    """
    GET /api/v1/cv/score/
    Get the latest CV analysis score and detailed breakdown.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        try:
            analysis = CVAnalysis.objects.filter(user=request.user).first()
            
            if not analysis:
                return success_response(
                    'No CV analysis found. Run analysis first.',
                    {'analysis_available': False}
                )
            
            analysis_data = analysis.analysis_data or {}
            
            return success_response(
                'CV score retrieved successfully.',
                {
                    'analysis_available': True,
                    'analysis_id': str(analysis.id),
                    'overall_score': analysis.overall_score,
                    'grade': analysis.grade,
                    'is_submission_ready': analysis.submission_ready,
                    'score_breakdown': {
                        'profile': analysis.profile_score,
                        'experience': analysis.experience_score,
                        'education': analysis.education_score,
                        'skills': analysis.skills_score,
                        'projects': analysis.projects_score
                    },
                    'summary': {
                        'total_issues': analysis.total_issues,
                        'critical_issues': analysis.critical_issues,
                        'total_recommendations': analysis.total_recommendations
                    },
                    'recommendations': analysis_data.get('recommendations', {}),
                    'analysis_date': analysis.created_at.isoformat(),
                    'last_updated': analysis.updated_at.isoformat()
                }
            )
            
        except Exception as e:
            logger.error(f'Failed to get CV score for user {request.user.email}: {str(e)}')
            return error_response(
                'Failed to retrieve CV score.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def cv_intelligence_dashboard(request):
    """
    GET /api/v1/cv/dashboard/
    Get comprehensive CV intelligence dashboard data.
    """
    try:
        analysis = CVAnalysis.objects.filter(user=request.user).first()
        
        dashboard_data = {
            'analysis_available': analysis is not None,
            'overall_score': analysis.overall_score if analysis else 0,
            'grade': analysis.grade if analysis else 'F',
            'pending_suggestions': 0,
            'pending_issues': 0,
            'last_updated': analysis.created_at.isoformat() if analysis else None
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