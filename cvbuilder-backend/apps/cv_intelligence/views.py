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
from django.http import FileResponse, Http404
from django.conf import settings
from pathlib import Path

from apps.core.responses import success_response, error_response
from apps.cv.models import CVProfile
from .validators import CVValidator
from .models import CVAnalysis, CVAnalysisHistory
from .serializers import CVAnalysisHistoryListSerializer, CVAnalysisHistorySerializer
from .services import CVAnalysisService
from .benchmarking_service import CVBenchmarkingService
from .export_service import CVAnalysisExportService, CVAnalysisExportError

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
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to get CV analysis for user {request.user.id}: {str(e)}')
            return error_response(
                'Failed to retrieve CV analysis.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request):
        """Perform comprehensive CV analysis and return detailed feedback."""
        try:
            logger.info(f'Starting CV analysis for user {request.user.id}')
            
            # Get user's CV profile
            logger.info(f'Fetching CV profile for user {request.user.id}')
            cv_profile = CVProfile.objects.prefetch_related(
                'educations', 'experiences', 'skills', 
                'languages', 'projects', 'certifications'
            ).filter(student=request.user).first()
            
            if not cv_profile:
                logger.warning(f'No CV profile found for user {request.user.id}')
                return error_response(
                    'Please create or upload your CV first.',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            logger.info(f'CV profile found for user {request.user.id}: {cv_profile.id}')
            
            # Check if CV has minimum required content
            has_basic_info = bool(request.user.full_name)
            has_contact = bool(request.user.email or cv_profile.phone)
            has_content = (
                cv_profile.educations.exists() or 
                cv_profile.experiences.exists() or 
                cv_profile.skills.exists()
            )
            
            logger.info(f'CV content check for user {request.user.id}: basic_info={has_basic_info}, contact={has_contact}, content={has_content}')
            
            if not (has_basic_info and has_contact and has_content):
                logger.warning(f'Insufficient CV content for user {request.user.id}')
                return error_response(
                    'Your CV needs more information. Please add your basic details, contact information, and at least one section (education, experience, or skills).',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Perform validation
            logger.info(f'Starting CV validation for user {request.user.id}')
            validator = CVValidator()
            results = validator.validate_cv_profile(cv_profile)
            logger.info(f'CV validation completed for user {request.user.id}, overall_score: {results.get("overall_score", "N/A")}')
            
            # Use service to handle analysis and history saving
            logger.info(f'Starting comprehensive analysis for user {request.user.id}')
            service = CVAnalysisService()
            analysis_result = service.analyze_cv_comprehensive(request.user, cv_profile)
            logger.info(f'Comprehensive analysis completed for user {request.user.id}')
            
            # Get the saved analysis for response
            logger.info(f'Fetching saved analysis for user {request.user.id}')
            analysis = CVAnalysis.objects.filter(user=request.user).first()
            
            if not analysis:
                logger.error(f'No analysis record found after creation for user {request.user.id}')
                return error_response(
                    'Analysis completed but could not retrieve results.',
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            logger.info(f'CV analysis completed successfully for user {request.user.id}, analysis_id: {analysis.id}')
            
            return success_response(
                'CV analysis completed successfully.',
                self._format_analysis_response(analysis)
            )
            
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'CV analysis failed for user {request.user.id}: {str(e)}', exc_info=True)
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
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to get CV score for user {request.user.id}: {str(e)}')
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
        # SECURITY: Don't log user email, use user ID instead
        logger.error(f'Failed to get dashboard data for user {request.user.id}: {str(e)}')
        return error_response(
            'Failed to retrieve dashboard data.',
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
        )


class CVAnalysisHistoryView(APIView):
    """
    GET /api/v1/cv/intelligence/analysis/history/
    Get paginated list of CV analysis history for the authenticated user.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get analysis history for the authenticated user."""
        try:
            # Get query parameters
            limit = min(int(request.GET.get('limit', 20)), 50)  # Max 50 records
            offset = int(request.GET.get('offset', 0))
            
            # Get history records
            history_queryset = CVAnalysisHistory.objects.filter(user=request.user)
            total_count = history_queryset.count()
            
            history_records = history_queryset[offset:offset + limit]
            
            # Serialize the data
            serializer = CVAnalysisHistoryListSerializer(history_records, many=True)
            
            return success_response(
                'Analysis history retrieved successfully.',
                {
                    'results': serializer.data,
                    'count': len(serializer.data),
                    'total': total_count,
                    'has_next': (offset + limit) < total_count,
                    'has_previous': offset > 0
                }
            )
            
        except ValueError:
            return error_response(
                'Invalid pagination parameters.',
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to get analysis history for user {request.user.id}: {str(e)}')
            return error_response(
                'Failed to retrieve analysis history.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CVAnalysisHistoryDetailView(APIView):
    """
    GET /api/v1/cv/intelligence/analysis/history/<uuid>/
    Get detailed view of a specific analysis history record.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request, history_id):
        """Get detailed analysis history record."""
        try:
            history_record = CVAnalysisHistory.objects.get(
                id=history_id,
                user=request.user
            )
            
            serializer = CVAnalysisHistorySerializer(history_record)
            
            return success_response(
                'Analysis history detail retrieved successfully.',
                serializer.data
            )
            
        except CVAnalysisHistory.DoesNotExist:
            return error_response(
                'Analysis history record not found.',
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to get analysis history detail for user {request.user.id}: {str(e)}')
            return error_response(
                'Failed to retrieve analysis history detail.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CVAnalysisExportView(APIView):
    """
    GET /api/v1/cv/export-analysis/
    Export CV analysis results as a professional PDF report.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Generate and return a PDF report of the user's CV analysis."""
        try:
            # Initialize export service
            export_service = CVAnalysisExportService(request.user)
            
            # Generate the PDF report
            report_info = export_service.generate_analysis_report()
            
            # SECURITY: Use Django's safe_join to prevent path traversal
            from django.utils._os import safe_join
            from django.core.exceptions import SuspiciousOperation
            
            try:
                # Sanitize the file path string
                file_path_str = str(report_info['file_path'])
                file_path_str = ''.join(char for char in file_path_str if ord(char) >= 32 or char in '\t')
                
                # Use safe_join to securely construct the path
                file_path = safe_join(settings.MEDIA_ROOT, file_path_str)
                
                if not file_path:
                    logger.warning(f'Path traversal attempt detected for user {request.user.id}')
                    return error_response(
                        'Invalid file path.',
                        status_code=status.HTTP_400_BAD_REQUEST
                    )
                
                file_path = Path(file_path)
                
            except (ValueError, SuspiciousOperation) as e:
                logger.warning(f'Path traversal attempt detected for user {request.user.id}: {str(e)}')
                return error_response(
                    'Invalid file path.',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            if not file_path.exists():
                return error_response(
                    'Generated report file not found.',
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            # SECURITY: Use context manager for proper file handling
            try:
                with open(file_path, 'rb') as pdf_file:
                    response = FileResponse(
                        pdf_file,
                        as_attachment=True,
                        filename=report_info['filename'],
                        content_type='application/pdf'
                    )
                    
                    # Add custom headers
                    response['Content-Length'] = report_info['file_size']
                    response['X-Generated-At'] = report_info['generated_at']
                    
                    # SECURITY: Sanitize filename for logging
                    safe_filename = report_info['filename'].replace('\n', '').replace('\r', '')
                    logger.info(f'Analysis report downloaded by user {request.user.id}: {safe_filename}')
                    
                    return response
            except IOError as e:
                logger.error(f'File access error for user {request.user.id}: {str(e)}')
                return error_response(
                    'Failed to access report file.',
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
        except CVAnalysisExportError as e:
            return error_response(
                str(e),
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to export analysis for user {request.user.id}: {str(e)}')
            return error_response(
                'Failed to generate analysis report. Please try again.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CVBenchmarkingView(APIView):
    """
    GET /api/v1/cv/benchmarking/
    Get comprehensive benchmarking data for the authenticated user.
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get benchmarking data for the authenticated user."""
        try:
            # Get query parameters
            comparison_group = request.GET.get('group', None)
            
            # Validate comparison group
            valid_groups = ['faculty', 'major', 'year', 'experience']
            if comparison_group and comparison_group not in valid_groups:
                return error_response(
                    f'Invalid comparison group. Valid options: {", ".join(valid_groups)}',
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Get benchmarking data
            benchmarking_service = CVBenchmarkingService()
            benchmark_data = benchmarking_service.get_user_benchmarking_data(
                user=request.user,
                comparison_group=comparison_group
            )
            
            return success_response(
                'Benchmarking data retrieved successfully.',
                benchmark_data
            )
            
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to get benchmarking data for user {request.user.id}: {str(e)}')
            return error_response(
                'Failed to retrieve benchmarking data.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )