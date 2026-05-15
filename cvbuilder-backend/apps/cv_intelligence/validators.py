"""
CV Validator Service - Analyzes CV content quality without external dependencies.
Uses rule-based algorithms to identify issues and suggest improvements.
"""
import re
from typing import Dict, List, Tuple
from django.utils import timezone
from .config import CVIntelligenceConfig, IndustryConfig


class CVValidator:
    """
    Validates CV content quality using algorithmic analysis.
    No AI models or external APIs required.
    """
    
    # Weak phrases that should be replaced
    WEAK_PHRASES = [
        'responsible for', 'worked on', 'helped with', 'assisted with',
        'was involved in', 'participated in', 'contributed to', 'dealt with',
        'handled', 'did', 'performed', 'executed'
    ]
    
    # Strong action verbs by category
    ACTION_VERBS = {
        'leadership': [
            'Led', 'Managed', 'Supervised', 'Coordinated', 'Directed',
            'Oversaw', 'Guided', 'Mentored', 'Facilitated', 'Orchestrated'
        ],
        'technical': [
            'Developed', 'Implemented', 'Designed', 'Built', 'Created',
            'Architected', 'Programmed', 'Engineered', 'Configured', 'Deployed'
        ],
        'analysis': [
            'Analyzed', 'Researched', 'Evaluated', 'Assessed', 'Investigated',
            'Examined', 'Studied', 'Reviewed', 'Audited', 'Measured'
        ],
        'improvement': [
            'Optimized', 'Enhanced', 'Improved', 'Streamlined', 'Increased',
            'Reduced', 'Accelerated', 'Maximized', 'Minimized', 'Upgraded'
        ],
        'achievement': [
            'Achieved', 'Accomplished', 'Delivered', 'Exceeded', 'Surpassed',
            'Completed', 'Attained', 'Secured', 'Won', 'Earned'
        ]
    }
    
    def __init__(self):
        self.issues = []
        self.suggestions = []
        self.score_breakdown = {}
    
    def validate_cv_profile(self, cv_profile) -> Dict:
        """
        Comprehensive CV validation.
        Returns detailed analysis with scores and suggestions.
        """
        self.issues = []
        self.suggestions = []
        self.score_breakdown = {}
        
        # Validate each section
        summary_score = self._validate_summary(cv_profile.summary)
        experience_score = self._validate_experiences(cv_profile.experiences.all())
        education_score = self._validate_education(cv_profile.educations.all())
        skills_score = self._validate_skills(cv_profile.skills.all())
        completeness_score = self._validate_completeness(cv_profile)
        
        # Calculate overall score using configurable weights
        config = CVIntelligenceConfig
        total_score = (
            summary_score * config.get_scoring_weight('summary') +
            experience_score * config.get_scoring_weight('experience') +
            education_score * config.get_scoring_weight('education') +
            skills_score * config.get_scoring_weight('skills') +
            completeness_score * config.get_scoring_weight('completeness')
        )
        
        return {
            'overall_score': round(total_score),
            'grade': config.get_grade_for_score(total_score),
            'score_breakdown': {
                'summary': summary_score,
                'experience': experience_score,
                'education': education_score,
                'skills': skills_score,
                'completeness': completeness_score
            },
            'issues': self.issues,
            'suggestions': self.suggestions,
            'priority_improvements': self._get_priority_improvements()
        }
    
    def _validate_summary(self, summary: str) -> int:
        """Validate professional summary quality (0-100 points)."""
        if not summary or not summary.strip():
            self.issues.append({
                'type': 'missing_section',
                'severity': 'high',
                'section': 'summary',
                'message': 'Professional summary is missing',
                'suggestion': 'Add a 2-3 sentence professional summary highlighting your key strengths'
            })
            return 0
        
        config = CVIntelligenceConfig
        word_count = len(summary.split())
        min_words = config.get_content_threshold('summary', 'min_words')
        max_words = config.get_content_threshold('summary', 'max_words')
        
        score = 0  # Initialize score
        
        # Length check (20 points)
        if word_count < min_words:
            self.issues.append({
                'type': 'too_short',
                'severity': 'medium',
                'section': 'summary',
                'message': f'Summary too short ({word_count} words)',
                'suggestion': f'Expand to {config.get_content_threshold("summary", "optimal_min")}-{config.get_content_threshold("summary", "optimal_max")} words for optimal impact'
            })
            score += 5
        elif word_count > max_words:
            self.issues.append({
                'type': 'too_long',
                'severity': 'low',
                'section': 'summary',
                'message': f'Summary too long ({word_count} words)',
                'suggestion': f'Condense to {config.get_content_threshold("summary", "optimal_min")}-{config.get_content_threshold("summary", "optimal_max")} words for better readability'
            })
            score += 15
        else:
            score += 20
        
        # Content quality (40 points)
        summary_lower = summary.lower()
        
        # Check for weak language
        weak_found = any(phrase in summary_lower for phrase in self.WEAK_PHRASES)
        if weak_found:
            self.issues.append({
                'type': 'weak_language',
                'severity': 'medium',
                'section': 'summary',
                'message': 'Contains weak language',
                'suggestion': 'Use strong action verbs and specific achievements'
            })
            score += 15
        else:
            score += 25
        
        # Check for quantification
        has_numbers = bool(re.search(r'\d+', summary))
        if not has_numbers:
            self.suggestions.append({
                'type': 'quantification',
                'section': 'summary',
                'message': 'Consider adding specific numbers or achievements',
                'suggestion': 'Include years of experience, team sizes, or key metrics'
            })
            score += 10
        else:
            score += 15
        
        # Grammar and structure (40 points)
        sentences = summary.split('.')
        if len(sentences) < 2:
            self.issues.append({
                'type': 'structure',
                'severity': 'low',
                'section': 'summary',
                'message': 'Summary should contain 2-3 sentences',
                'suggestion': 'Break into multiple sentences for better flow'
            })
            score += 20
        else:
            score += 40
        
        return min(score, 100)
    
    def _validate_experiences(self, experiences) -> int:
        """Validate work experience quality (0-100 points)."""
        if not experiences:
            self.issues.append({
                'type': 'missing_section',
                'severity': 'critical',
                'section': 'experience',
                'message': 'No work experience entries',
                'suggestion': 'Add at least one work experience entry'
            })
            return 0
        
        total_score = 0
        experience_count = len(experiences)
        
        for exp in experiences:
            exp_score = self._validate_single_experience(exp)
            total_score += exp_score
        
        # Average score across all experiences
        avg_score = total_score / experience_count if experience_count > 0 else 0
        
        # Bonus for multiple experiences
        if experience_count >= 2:
            avg_score = min(avg_score + 10, 100)
        
        return round(avg_score)
    
    def _validate_single_experience(self, experience) -> int:
        """Validate a single work experience entry."""
        score = 0
        
        # Basic information completeness (30 points)
        if experience.job_title and experience.company:
            score += 20
        else:
            self.issues.append({
                'type': 'incomplete_info',
                'severity': 'high',
                'section': 'experience',
                'message': f'Missing job title or company for experience entry',
                'suggestion': 'Ensure all experience entries have job title and company'
            })
        
        if experience.start_date:
            score += 10
        else:
            self.issues.append({
                'type': 'incomplete_info',
                'severity': 'medium',
                'section': 'experience',
                'message': 'Missing start date for experience',
                'suggestion': 'Add start date for all experience entries'
            })
        
        # Description quality (70 points)
        if not experience.description or not experience.description.strip():
            self.issues.append({
                'type': 'missing_content',
                'severity': 'high',
                'section': 'experience',
                'message': f'No description for {experience.job_title}',
                'suggestion': 'Add 2-4 bullet points describing key achievements and responsibilities'
            })
            return score
        
        desc_score = self._validate_description(experience.description, 'experience')
        score += desc_score
        
        return min(score, 100)
    
    def _validate_description(self, description: str, section: str) -> int:
        """Validate description quality for any section."""
        config = CVIntelligenceConfig
        score = 0
        word_count = len(description.split())
        min_words = config.get_content_threshold('experience_description', 'min_words')
        max_words = config.get_content_threshold('experience_description', 'max_words')
        
        # Length check (25 points)
        if word_count < min_words:
            self.issues.append({
                'type': 'too_short',
                'severity': 'medium',
                'section': section,
                'message': f'Description too short ({word_count} words)',
                'suggestion': f'Expand with specific achievements and responsibilities ({config.get_content_threshold("experience_description", "optimal_min")}-{config.get_content_threshold("experience_description", "optimal_max")} words)'
            })
            score += 5
        elif word_count > max_words:
            self.issues.append({
                'type': 'too_long',
                'severity': 'low',
                'section': section,
                'message': f'Description too long ({word_count} words)',
                'suggestion': f'Condense to key achievements ({config.get_content_threshold("experience_description", "optimal_min")}-{config.get_content_threshold("experience_description", "optimal_max")} words)'
            })
            score += 20
        else:
            score += 25
        
        # Weak language check (25 points)
        desc_lower = description.lower()
        weak_phrases_found = [phrase for phrase in self.WEAK_PHRASES if phrase in desc_lower]
        
        if weak_phrases_found:
            self.issues.append({
                'type': 'weak_language',
                'severity': 'medium',
                'section': section,
                'message': f'Weak language detected: {", ".join(weak_phrases_found[:2])}',
                'suggestion': f'Replace with strong action verbs: {", ".join(self.ACTION_VERBS["technical"][:3])}'
            })
            score += 10
        else:
            score += 25
        
        # Quantification check (20 points)
        has_numbers = bool(re.search(r'\d+', description))
        if not has_numbers:
            self.suggestions.append({
                'type': 'quantification',
                'section': section,
                'message': 'Consider adding specific metrics',
                'suggestion': 'Include numbers, percentages, timeframes, or team sizes'
            })
            score += 10
        else:
            score += 20
        
        return score
    
    def _validate_education(self, education_entries) -> int:
        """Validate education section quality."""
        config = CVIntelligenceConfig
        if not education_entries:
            self.issues.append({
                'type': 'missing_section',
                'severity': 'high',
                'section': 'education',
                'message': 'No education entries',
                'suggestion': 'Add your educational background'
            })
            return 0
        
        score = config.get_education_threshold('base_score')  # Base score for having education
        
        for edu in education_entries:
            if edu.degree and edu.institution and edu.field_of_study:
                score += config.get_education_threshold('complete_info_bonus')
            else:
                self.issues.append({
                    'type': 'incomplete_info',
                    'severity': 'medium',
                    'section': 'education',
                    'message': 'Incomplete education information',
                    'suggestion': 'Include degree, field of study, and institution'
                })
            
            if edu.gpa and edu.gpa >= config.get_education_threshold('good_gpa_threshold'):
                score += config.get_education_threshold('good_gpa_bonus')  # Bonus for good GPA
            
            if edu.description:
                score += config.get_education_threshold('description_bonus')  # Bonus for additional details
        
        return min(score, 100)
    
    def _validate_skills(self, skills) -> int:
        """Validate skills section quality."""
        config = CVIntelligenceConfig
        if not skills:
            self.issues.append({
                'type': 'missing_section',
                'severity': 'medium',
                'section': 'skills',
                'message': 'No skills listed',
                'suggestion': 'Add relevant technical and soft skills'
            })
            return 0
        
        skill_count = len(skills)
        score = 0
        min_count = config.get_skills_threshold('min_count')
        max_count = config.get_skills_threshold('max_count')
        optimal_min = config.get_skills_threshold('optimal_min')
        optimal_max = config.get_skills_threshold('optimal_max')
        
        # Quantity scoring
        if skill_count < min_count:
            self.suggestions.append({
                'type': 'insufficient_content',
                'section': 'skills',
                'message': f'Only {skill_count} skills listed',
                'suggestion': f'Add {optimal_min}-{optimal_max} relevant skills for better coverage'
            })
            score += 30
        elif skill_count > max_count:
            self.suggestions.append({
                'type': 'too_many',
                'section': 'skills',
                'message': f'{skill_count} skills may be too many',
                'suggestion': f'Focus on {optimal_min}-{optimal_max} most relevant skills'
            })
            score += 70
        else:
            score += config.get_scoring_points('skills', 'base_points')
        
        # Category diversity
        categories = set(skill.category for skill in skills)
        if len(categories) > 1:
            score += config.get_scoring_points('skills', 'diversity_bonus')  # Bonus for diverse skill categories
        
        return min(score, 100)
    
    def _validate_completeness(self, cv_profile) -> int:
        """Validate overall CV completeness."""
        config = CVIntelligenceConfig
        score = 0
        
        # Required sections
        if cv_profile.summary:
            score += config.get_scoring_points('completeness', 'summary_points')
        if cv_profile.experiences.exists():
            score += config.get_scoring_points('completeness', 'experience_points')
        if cv_profile.educations.exists():
            score += config.get_scoring_points('completeness', 'education_points')
        if cv_profile.skills.exists():
            score += config.get_scoring_points('completeness', 'skills_points')
        
        # Optional but valuable sections
        if cv_profile.projects.exists():
            score += config.get_scoring_points('completeness', 'projects_bonus')
        if cv_profile.certifications.exists():
            score += config.get_scoring_points('completeness', 'certifications_bonus')
        
        return min(score, 100)

    
    def _get_priority_improvements(self) -> List[Dict]:
        """Get top 3 priority improvements based on impact."""
        # Sort issues by severity and potential impact
        critical_issues = [issue for issue in self.issues if issue['severity'] == 'critical']
        high_issues = [issue for issue in self.issues if issue['severity'] == 'high']
        medium_issues = [issue for issue in self.issues if issue['severity'] == 'medium']
        
        priority_list = critical_issues + high_issues + medium_issues
        return priority_list[:3]  # Top 3 priorities