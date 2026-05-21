"""
CV Analysis Service - Main orchestrator for CV intelligence features.
Coordinates validation, scoring, and suggestion generation.
"""
import logging
from typing import Dict, List
from django.utils import timezone
from django.db import transaction

from .models import CVAnalysis, ContentRecommendation, AnalysisIssue, CVAnalysisHistory
from .validators import CVValidator
from .benchmarking_service import CVBenchmarkingService

logger = logging.getLogger(__name__)


class CVAnalysisService:
    """
    Main service for CV analysis and intelligence features.
    Provides comprehensive CV evaluation without external dependencies.
    """
    
    def __init__(self):
        self.validator = CVValidator()
    
    def analyze_cv_comprehensive(self, user, cv_profile) -> Dict:
        """
        Perform comprehensive CV analysis and store results.
        Returns analysis data and saves to database.
        """
        try:
            logger.info(f'Starting comprehensive analysis for user {user.id}')
            
            # Run validation analysis
            logger.info(f'Running validation analysis for user {user.id}')
            validation_results = self.validator.validate_cv_profile(cv_profile)
            logger.info(f'Validation completed for user {user.id}, overall_score: {validation_results.get("overall_score", "N/A")}')
            
            # Create analysis record
            logger.info(f'Creating analysis record for user {user.id}')
            with transaction.atomic():
                score_breakdown = validation_results.get('score_breakdown', {})
                logger.info(f'Score breakdown for user {user.id}: {score_breakdown}')
                
                # Delete existing analysis for this user
                CVAnalysis.objects.filter(user=user).delete()
                logger.info(f'Deleted existing analysis records for user {user.id}')
                
                analysis = CVAnalysis.objects.create(
                    user=user,
                    overall_score=validation_results['overall_score'],
                    profile_score=score_breakdown.get('profile', 0),
                    experience_score=score_breakdown.get('experience', 0),
                    education_score=score_breakdown.get('education', 0),
                    skills_score=score_breakdown.get('skills', 0),
                    projects_score=score_breakdown.get('projects', 0),
                    total_issues=len(validation_results.get('issues', [])),
                    critical_issues=len([i for i in validation_results.get('issues', []) if i.get('severity') == 'critical']),
                    total_recommendations=len(validation_results.get('suggestions', [])),
                    analysis_data=validation_results,
                    grade=validation_results['grade'],
                    submission_ready=validation_results.get('is_submission_ready', False)
                )
                logger.info(f'Analysis record created for user {user.id}, analysis_id: {analysis.id}')
                
                # Store analysis issues
                logger.info(f'Storing analysis issues for user {user.id}')
                self._store_analysis_issues(user, validation_results['issues'])
                logger.info(f'Analysis issues stored for user {user.id}')
                
                # Generate content suggestions
                logger.info(f'Generating content suggestions for user {user.id}')
                self._generate_content_recommendations(user, cv_profile, validation_results)
                logger.info(f'Content suggestions generated for user {user.id}')
                
                # Save analysis history
                logger.info(f'Saving analysis history for user {user.id}')
                self._save_analysis_history(user, validation_results)
                logger.info(f'Analysis history saved for user {user.id}')
            
            logger.info(f'CV analysis completed for user {user.id} - Score: {validation_results["overall_score"]}')
            
            return {
                'analysis_id': str(analysis.id),
                'overall_score': validation_results['overall_score'],
                'grade': validation_results['grade'],
                'score_breakdown': validation_results['score_breakdown'],
                'priority_improvements': validation_results['priority_improvements'],
                'total_issues': len(validation_results['issues']),
                'total_suggestions': len(validation_results['suggestions']),
                'analysis_date': analysis.created_at.isoformat()
            }
            
        except Exception as e:
            logger.error(f'CV analysis failed for user {user.id}: {str(e)}', exc_info=True)
            raise
    
    def get_latest_analysis(self, user) -> Dict:
        """Get the most recent CV analysis for a user."""
        try:
            analysis = CVAnalysis.objects.filter(user=user).first()
            if not analysis:
                return None
            
            return {
                'analysis_id': str(analysis.id),
                'overall_score': analysis.overall_score,
                'grade': analysis.grade,
                'score_breakdown': {
                    'profile': analysis.profile_score,
                    'experience': analysis.experience_score,
                    'education': analysis.education_score,
                    'skills': analysis.skills_score,
                    'projects': analysis.projects_score
                },
                'detailed_feedback': analysis.analysis_data,
                'analysis_date': analysis.created_at.isoformat(),
                'last_updated': analysis.updated_at.isoformat()
            }
            
        except Exception as e:
            logger.error(f'Failed to get latest analysis for user {user.id}: {str(e)}')
            return None
    
    def get_content_recommendations(self, user, section_type=None) -> List[Dict]:
        """Get content recommendations for a user, optionally filtered by section."""
        try:
            recommendations_query = ContentRecommendation.objects.filter(user=user, applied=False)
            
            if section_type:
                recommendations_query = recommendations_query.filter(section=section_type)
            
            recommendations = recommendations_query.order_by('-created_at')[:10]  # Latest 10
            
            return [
                {
                    'id': str(recommendation.id),
                    'section': recommendation.section,
                    'recommendation_type': recommendation.recommendation_type,
                    'title': recommendation.title,
                    'description': recommendation.description,
                    'current_content': recommendation.current_content,
                    'suggested_content': recommendation.suggested_content,
                    'created_at': recommendation.created_at.isoformat()
                }
                for recommendation in recommendations
            ]
            
        except Exception as e:
            logger.error(f'Failed to get content recommendations for user {user.id}: {str(e)}')
            return []
    
    def apply_recommendation(self, user, recommendation_id: str) -> bool:
        """Mark a content recommendation as applied."""
        try:
            recommendation = ContentRecommendation.objects.get(
                id=recommendation_id,
                user=user,
                applied=False
            )
            
            recommendation.applied = True
            recommendation.applied_at = timezone.now()
            recommendation.save(update_fields=['applied', 'applied_at'])
            
            logger.info(f'Recommendation {recommendation_id} applied by user {user.id}')
            return True
            
        except ContentRecommendation.DoesNotExist:
            logger.warning(f'Recommendation {recommendation_id} not found for user {user.id}')
            return False
        except Exception as e:
            logger.error(f'Failed to apply recommendation {recommendation_id} for user {user.id}: {str(e)}')
            return False
    
    def get_analysis_issues(self, user, resolved=False) -> List[Dict]:
        """Get analysis issues for a user."""
        try:
            issues = AnalysisIssue.objects.filter(
                user=user,
                resolved=resolved
            ).order_by('-created_at')[:20]  # Latest 20
            
            return [
                {
                    'id': str(issue.id),
                    'issue_type': issue.issue_type,
                    'severity': issue.severity,
                    'section': issue.section,
                    'title': issue.title,
                    'description': issue.description,
                    'recommendation': issue.recommendation,
                    'created_at': issue.created_at.isoformat()
                }
                for issue in issues
            ]
            
        except Exception as e:
            logger.error(f'Failed to get analysis issues for user {user.id}: {str(e)}')
            return []
    
    def resolve_issue(self, user, issue_id: str) -> bool:
        """Mark an analysis issue as resolved."""
        try:
            issue = AnalysisIssue.objects.get(
                id=issue_id,
                user=user,
                resolved=False
            )
            
            issue.resolved = True
            issue.resolved_at = timezone.now()
            issue.save(update_fields=['resolved', 'resolved_at'])
            
            logger.info(f'Issue {issue_id} resolved by user {user.id}')
            return True
            
        except AnalysisIssue.DoesNotExist:
            logger.warning(f'Issue {issue_id} not found for user {user.id}')
            return False
        except Exception as e:
            logger.error(f'Failed to resolve issue {issue_id} for user {user.id}: {str(e)}')
            return False
    
    def _store_analysis_issues(self, user, issues: List[Dict]):
        """Store analysis issues in the database."""
        # Clear old unresolved issues for this user
        AnalysisIssue.objects.filter(user=user, resolved=False).delete()
        
        issue_objects = [
            AnalysisIssue(
                user=user,
                issue_type=issue.get('type', 'missing_content'),
                severity=issue.get('severity', 'medium'),
                section=issue.get('section', 'overall'),
                title=issue.get('title', issue['message'][:100] if 'message' in issue else 'Issue'),
                description=issue.get('message', 'No description available'),
                recommendation=issue.get('suggestion', 'No recommendation available')
            )
            for issue in issues
        ]
        
        if issue_objects:
            AnalysisIssue.objects.bulk_create(issue_objects)
    
    def _generate_content_recommendations(self, user, cv_profile, validation_results):
        """Generate and store content recommendations based on validation results."""
        # Clear old unapplied recommendations
        ContentRecommendation.objects.filter(user=user, applied=False).delete()
        
        recommendation_objects = []
        
        # Generate recommendations based on validation results
        for suggestion in validation_results.get('suggestions', []):
            if suggestion.get('type') == 'quantification':
                recommendation_objects.append(
                    ContentRecommendation(
                        user=user,
                        section=suggestion.get('section', 'overall'),
                        recommendation_type='quantification',
                        priority='high',
                        title='Add Quantifiable Metrics',
                        description='Adding specific numbers and metrics makes your achievements more credible and impactful.',
                        current_content=suggestion.get('original', ''),
                        suggested_content=suggestion.get('suggestion', '')
                    )
                )
        
        # Generate experience enhancement recommendations
        if hasattr(cv_profile, 'experiences'):
            for exp in cv_profile.experiences.all():
                if exp.description and len(exp.description.split()) < 15:
                    recommendation_objects.append(
                        ContentRecommendation(
                            user=user,
                            section='experience',
                            recommendation_type='experience_detail',
                            priority='medium',
                            title='Expand Experience Description',
                            description='Expanding your experience description with specific achievements and responsibilities makes your CV more compelling.',
                            current_content=exp.description,
                            suggested_content=self._enhance_experience_description(exp.description)
                        )
                    )
        
        if recommendation_objects:
            ContentRecommendation.objects.bulk_create(recommendation_objects)
    
    def _enhance_experience_description(self, description: str) -> str:
        """Enhance experience description with better structure and content."""
        if not description:
            return "• Developed and implemented key solutions that improved team efficiency\n• Collaborated with cross-functional teams to deliver high-quality results\n• Achieved measurable outcomes through strategic planning and execution"
        
        # Simple enhancement - add bullet points and action verbs
        lines = [line.strip() for line in description.split('\n') if line.strip()]
        enhanced_lines = []
        
        for line in lines:
            if not line.startswith('•'):
                # Add bullet point and ensure it starts with action verb
                if not any(line.lower().startswith(verb.lower()) for verb_list in self.validator.ACTION_VERBS.values() for verb in verb_list):
                    line = f"Developed {line.lower()}"
                enhanced_lines.append(f"• {line}")
            else:
                enhanced_lines.append(line)
        
        return '\n'.join(enhanced_lines) if enhanced_lines else description
    
    def _save_analysis_history(self, user, validation_results):
        """Save analysis results to history for tracking progress over time."""
        try:
            # Extract section scores from validation results
            section_scores = validation_results.get('score_breakdown', {})
            
            # Calculate readiness score (average of key sections)
            key_sections = ['completeness', 'experience', 'skills']
            readiness_scores = [section_scores.get(section, 0) for section in key_sections if section in section_scores]
            readiness_score = sum(readiness_scores) / len(readiness_scores) if readiness_scores else 0
            
            # Determine readiness grade
            if readiness_score >= 90:
                readiness_grade = 'A+'
            elif readiness_score >= 85:
                readiness_grade = 'A'
            elif readiness_score >= 80:
                readiness_grade = 'B+'
            elif readiness_score >= 75:
                readiness_grade = 'B'
            elif readiness_score >= 70:
                readiness_grade = 'C+'
            elif readiness_score >= 65:
                readiness_grade = 'C'
            else:
                readiness_grade = 'D'
            
            # Extract recommendations
            recommendations = validation_results.get('suggestions', [])
            
            # Extract strengths and weaknesses
            strengths = validation_results.get('strengths', [])
            weaknesses = validation_results.get('issues', [])
            
            # Create history record
            CVAnalysisHistory.objects.create(
                user=user,
                overall_score=validation_results['overall_score'],
                readiness_score=readiness_score,
                readiness_grade=readiness_grade,
                section_scores=section_scores,
                recommendations=recommendations,
                strengths=strengths,
                weaknesses=weaknesses,
                analysis_version='1.0',
                total_recommendations=len(recommendations)
            )
            
            logger.info(f'Analysis history saved for user {user.id}')
            
            # Invalidate benchmarking cache since new analysis affects rankings
            benchmarking_service = CVBenchmarkingService()
            benchmarking_service.invalidate_cache(user.id)
            
        except Exception as e:
            logger.error(f'Failed to save analysis history for user {user.id}: {str(e)}')
            # Don't raise exception as this is not critical for the main analysis flow
    
    def get_analysis_history(self, user, limit=20):
        """Get analysis history for a user."""
        try:
            history = CVAnalysisHistory.objects.filter(user=user)[:limit]
            
            return [
                {
                    'id': str(record.id),
                    'overall_score': float(record.overall_score),
                    'readiness_score': float(record.readiness_score) if record.readiness_score else None,
                    'readiness_grade': record.readiness_grade,
                    'section_scores': record.section_scores,
                    'recommendations': record.recommendations,
                    'strengths': record.strengths,
                    'weaknesses': record.weaknesses,
                    'total_recommendations': record.total_recommendations,
                    'created_at': record.created_at.isoformat(),
                    'formatted_date': record.formatted_date
                }
                for record in history
            ]
            
        except Exception as e:
            logger.error(f'Failed to get analysis history for user {user.id}: {str(e)}')
            return []