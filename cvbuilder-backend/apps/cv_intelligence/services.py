"""
CV Analysis Service - Main orchestrator for CV intelligence features.
Coordinates validation, scoring, and suggestion generation.
"""
import logging
from typing import Dict, List
from django.utils import timezone
from django.db import transaction

from .models import CVAnalysis, ContentSuggestion, ValidationIssue
from .validators import CVValidator

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
            # Run validation analysis
            validation_results = self.validator.validate_cv_profile(cv_profile)
            
            # Create analysis record
            with transaction.atomic():
                analysis = CVAnalysis.objects.create(
                    user=user,
                    overall_score=validation_results['overall_score'],
                    completeness_score=validation_results['score_breakdown']['completeness'],
                    quality_score=validation_results['score_breakdown']['experience'],
                    skills_score=validation_results['score_breakdown']['skills'],
                    format_score=validation_results['score_breakdown']['summary'],
                    analysis_data=validation_results,
                    grade=validation_results['grade']
                )
                
                # Store validation issues
                self._store_validation_issues(user, validation_results['issues'])
                
                # Generate content suggestions
                self._generate_content_suggestions(user, cv_profile, validation_results)
            
            logger.info(f'CV analysis completed for user {user.email} - Score: {validation_results["overall_score"]}')
            
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
            logger.error(f'CV analysis failed for user {user.email}: {str(e)}')
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
                    'completeness': analysis.completeness_score,
                    'quality': analysis.quality_score,
                    'skills': analysis.skills_score,
                    'format': analysis.format_score
                },
                'detailed_feedback': analysis.analysis_data,
                'analysis_date': analysis.created_at.isoformat(),
                'last_updated': analysis.updated_at.isoformat()
            }
            
        except Exception as e:
            logger.error(f'Failed to get latest analysis for user {user.email}: {str(e)}')
            return None
    
    def get_content_suggestions(self, user, section_type=None) -> List[Dict]:
        """Get content suggestions for a user, optionally filtered by section."""
        try:
            suggestions_query = ContentSuggestion.objects.filter(user=user, applied=False)
            
            if section_type:
                suggestions_query = suggestions_query.filter(section_type=section_type)
            
            suggestions = suggestions_query.order_by('-created_at')[:10]  # Latest 10
            
            return [
                {
                    'id': str(suggestion.id),
                    'section_type': suggestion.section_type,
                    'suggestion_type': suggestion.suggestion_type,
                    'original_content': suggestion.original_content,
                    'suggested_content': suggestion.suggested_content,
                    'improvement_reason': suggestion.improvement_reason,
                    'created_at': suggestion.created_at.isoformat()
                }
                for suggestion in suggestions
            ]
            
        except Exception as e:
            logger.error(f'Failed to get content suggestions for user {user.email}: {str(e)}')
            return []
    
    def apply_suggestion(self, user, suggestion_id: str) -> bool:
        """Mark a content suggestion as applied."""
        try:
            suggestion = ContentSuggestion.objects.get(
                id=suggestion_id,
                user=user,
                applied=False
            )
            
            suggestion.applied = True
            suggestion.applied_at = timezone.now()
            suggestion.save(update_fields=['applied', 'applied_at'])
            
            logger.info(f'Suggestion {suggestion_id} applied by user {user.email}')
            return True
            
        except ContentSuggestion.DoesNotExist:
            logger.warning(f'Suggestion {suggestion_id} not found for user {user.email}')
            return False
        except Exception as e:
            logger.error(f'Failed to apply suggestion {suggestion_id} for user {user.email}: {str(e)}')
            return False
    
    def get_validation_issues(self, user, resolved=False) -> List[Dict]:
        """Get validation issues for a user."""
        try:
            issues = ValidationIssue.objects.filter(
                user=user,
                resolved=resolved
            ).order_by('-created_at')[:20]  # Latest 20
            
            return [
                {
                    'id': str(issue.id),
                    'issue_type': issue.issue_type,
                    'severity': issue.severity,
                    'section_type': issue.section_type,
                    'description': issue.description,
                    'suggestion': issue.suggestion,
                    'created_at': issue.created_at.isoformat()
                }
                for issue in issues
            ]
            
        except Exception as e:
            logger.error(f'Failed to get validation issues for user {user.email}: {str(e)}')
            return []
    
    def resolve_issue(self, user, issue_id: str) -> bool:
        """Mark a validation issue as resolved."""
        try:
            issue = ValidationIssue.objects.get(
                id=issue_id,
                user=user,
                resolved=False
            )
            
            issue.resolved = True
            issue.resolved_at = timezone.now()
            issue.save(update_fields=['resolved', 'resolved_at'])
            
            logger.info(f'Issue {issue_id} resolved by user {user.email}')
            return True
            
        except ValidationIssue.DoesNotExist:
            logger.warning(f'Issue {issue_id} not found for user {user.email}')
            return False
        except Exception as e:
            logger.error(f'Failed to resolve issue {issue_id} for user {user.email}: {str(e)}')
            return False
    
    def _store_validation_issues(self, user, issues: List[Dict]):
        """Store validation issues in the database."""
        # Clear old unresolved issues for this user
        ValidationIssue.objects.filter(user=user, resolved=False).delete()
        
        issue_objects = [
            ValidationIssue(
                user=user,
                issue_type=issue['type'],
                severity=issue['severity'],
                section_type=issue['section'],
                description=issue['message'],
                suggestion=issue['suggestion']
            )
            for issue in issues
        ]
        
        if issue_objects:
            ValidationIssue.objects.bulk_create(issue_objects)
    
    def _generate_content_suggestions(self, user, cv_profile, validation_results):
        """Generate and store content suggestions based on validation results."""
        # Clear old unapplied suggestions
        ContentSuggestion.objects.filter(user=user, applied=False).delete()
        
        suggestion_objects = []
        
        # Generate suggestions based on validation results
        for suggestion in validation_results['suggestions']:
            if suggestion['type'] == 'quantification':
                suggestion_objects.append(
                    ContentSuggestion(
                        user=user,
                        section_type=suggestion['section'],
                        suggestion_type=ContentSuggestion.SuggestionType.QUANTIFICATION,
                        original_content=suggestion.get('original', ''),
                        suggested_content=suggestion['suggestion'],
                        improvement_reason='Adding specific numbers and metrics makes your achievements more credible and impactful.'
                    )
                )
        
        # Generate experience enhancement suggestions
        for exp in cv_profile.experiences.all():
            if exp.description and len(exp.description.split()) < 15:
                suggestion_objects.append(
                    ContentSuggestion(
                        user=user,
                        section_type=ContentSuggestion.SectionType.EXPERIENCE,
                        suggestion_type=ContentSuggestion.SuggestionType.LENGTH_IMPROVEMENT,
                        original_content=exp.description,
                        suggested_content=self._enhance_experience_description(exp.description),
                        improvement_reason='Expanding your experience description with specific achievements and responsibilities makes your CV more compelling.'
                    )
                )
        
        if suggestion_objects:
            ContentSuggestion.objects.bulk_create(suggestion_objects)
    
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