"""
CV Validator Service - Analyzes CV content quality without external dependencies.
Uses rule-based algorithms to identify issues and suggest improvements.
"""
import re
from typing import Dict, List


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
        'technical': [
            'Developed', 'Implemented', 'Designed', 'Built', 'Created',
            'Architected', 'Programmed', 'Engineered', 'Configured', 'Deployed'
        ]
    }
    
    def __init__(self):
        self.issues = []
        self.suggestions = []
    
    def validate_cv_profile(self, cv_profile) -> Dict:
        """
        Comprehensive CV validation.
        Returns detailed analysis with scores and suggestions.
        """
        self.issues = []
        self.suggestions = []
        
        # Validate each section with detailed scoring
        profile_score = self._validate_profile_section(cv_profile)
        experience_score = self._validate_experiences(cv_profile.experiences.all())
        education_score = self._validate_education(cv_profile.educations.all())
        skills_score = self._validate_skills(cv_profile.skills.all())
        projects_score = self._validate_projects(cv_profile.projects.all())
        
        # Calculate overall score using weights
        total_score = (
            profile_score * 0.25 +
            experience_score * 0.25 +
            education_score * 0.20 +
            skills_score * 0.15 +
            projects_score * 0.15
        )
        
        grade = self._get_grade_for_score(total_score)
        
        # Determine submission readiness
        is_submission_ready = (
            total_score >= 70 and
            profile_score >= 60 and
            experience_score >= 60 and
            education_score >= 60 and
            skills_score >= 60 and
            projects_score >= 50
        )
        
        # Categorize recommendations
        recommendations = self._categorize_recommendations()
        
        return {
            'overall_score': round(total_score),
            'grade': grade,
            'is_submission_ready': is_submission_ready,
            'score_breakdown': {
                'profile': profile_score,
                'experience': experience_score,
                'education': education_score,
                'skills': skills_score,
                'projects': projects_score
            },
            'issues': self.issues,
            'suggestions': self.suggestions,
            'recommendations': recommendations,
            'priority_improvements': self._get_priority_improvements()
        }
    
    def _validate_profile_section(self, cv_profile) -> int:
        """Validate complete profile section including contact info and summary."""
        score = 0
        
        # Contact information (40 points)
        if cv_profile.phone: score += 10
        else:
            self.issues.append({
                'type': 'missing_content',
                'severity': 'high',
                'section': 'profile',
                'message': 'Phone number missing',
                'suggestion': 'Add your phone number for employer contact'
            })
        
        if cv_profile.city: score += 10
        else:
            self.issues.append({
                'type': 'missing_content',
                'severity': 'medium',
                'section': 'profile',
                'message': 'City location missing',
                'suggestion': 'Add your city for location-based opportunities'
            })
        
        if cv_profile.country: score += 10
        else:
            self.issues.append({
                'type': 'missing_content',
                'severity': 'medium',
                'section': 'profile',
                'message': 'Country missing',
                'suggestion': 'Add your country for international opportunities'
            })
        
        if cv_profile.address: score += 10
        else:
            self.suggestions.append({
                'type': 'optional_content',
                'section': 'profile',
                'message': 'Consider adding full address',
                'suggestion': 'Full address can be helpful for local employers'
            })
        
        # Professional summary (30 points)
        summary_score = self._validate_summary(cv_profile.summary)
        score += int(summary_score * 0.3)  # Convert to 30-point scale
        
        # Online presence (20 points)
        if cv_profile.linkedin: score += 10
        else:
            self.issues.append({
                'type': 'missing_content',
                'severity': 'medium',
                'section': 'profile',
                'message': 'LinkedIn profile missing',
                'suggestion': 'Add LinkedIn profile to showcase professional network'
            })
        
        if cv_profile.github or cv_profile.portfolio: score += 10
        else:
            self.suggestions.append({
                'type': 'enhancement',
                'section': 'profile',
                'message': 'Consider adding GitHub or portfolio link',
                'suggestion': 'Showcase your work with GitHub or portfolio links'
            })
        
        # Photo (10 points)
        if cv_profile.photo: score += 10
        else:
            self.suggestions.append({
                'type': 'optional_content',
                'section': 'profile',
                'message': 'Consider adding professional photo',
                'suggestion': 'Professional photo can make your CV more memorable'
            })
        
        return min(score, 100)
    
    def _validate_projects(self, projects) -> int:
        """Validate projects section quality (0-100 points)."""
        if not projects:
            self.issues.append({
                'type': 'missing_section',
                'severity': 'medium',
                'section': 'projects',
                'message': 'No projects listed',
                'suggestion': 'Add 2-3 relevant projects to showcase your skills'
            })
            return 0
        
        project_count = len(projects)
        score = 0
        
        # Basic presence (40 points)
        score += 40
        
        # Quantity bonus (30 points)
        if project_count >= 3: score += 30
        elif project_count >= 2: score += 20
        else:
            self.suggestions.append({
                'type': 'enhancement',
                'section': 'projects',
                'message': f'Only {project_count} project(s) listed',
                'suggestion': 'Add 2-3 projects for better demonstration of skills'
            })
        
        # Quality assessment (30 points)
        detailed_projects = 0
        linked_projects = 0
        
        for project in projects:
            if project.description and len(project.description.split()) >= 20:
                detailed_projects += 1
            else:
                self.issues.append({
                    'type': 'insufficient_detail',
                    'severity': 'medium',
                    'section': 'projects',
                    'message': f'Project "{project.title}" needs more detail',
                    'suggestion': 'Add detailed description with technologies used and outcomes'
                })
            
            if project.link:
                linked_projects += 1
        
        # Quality scoring
        if detailed_projects == project_count: score += 15
        elif detailed_projects >= project_count // 2: score += 10
        
        if linked_projects >= project_count // 2: score += 15
        elif linked_projects >= 1: score += 10
        else:
            self.suggestions.append({
                'type': 'enhancement',
                'section': 'projects',
                'message': 'Consider adding project links',
                'suggestion': 'Include GitHub repositories or live demo links'
            })
        
        return min(score, 100)
    
    def _categorize_recommendations(self) -> Dict:
        """Categorize issues and suggestions into recommendation levels."""
        recommendations = {
            'critical': [],
            'important': [],
            'suggestions': [],
            'strengths': []
        }
        
        # Categorize issues
        for issue in self.issues:
            if issue['severity'] == 'critical':
                recommendations['critical'].append(issue['suggestion'])
            elif issue['severity'] == 'high':
                recommendations['important'].append(issue['suggestion'])
            else:
                recommendations['suggestions'].append(issue['suggestion'])
        
        # Add general suggestions
        for suggestion in self.suggestions:
            if suggestion['type'] in ['enhancement', 'quantification']:
                recommendations['suggestions'].append(suggestion['suggestion'])
        
        # Identify strengths (sections with high scores would be added here)
        # This could be enhanced based on individual section scores
        
        return recommendations
    
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
        
        word_count = len(summary.split())
        score = 0
        
        # Length check (20 points)
        if word_count < 15:
            self.issues.append({
                'type': 'too_short',
                'severity': 'medium',
                'section': 'summary',
                'message': f'Summary too short ({word_count} words)',
                'suggestion': 'Expand to 20-50 words for optimal impact'
            })
            score += 5
        elif word_count > 80:
            self.issues.append({
                'type': 'too_long',
                'severity': 'low',
                'section': 'summary',
                'message': f'Summary too long ({word_count} words)',
                'suggestion': 'Condense to 20-50 words for better readability'
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
                'message': 'Missing job title or company for experience entry',
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
        score = 0
        word_count = len(description.split())
        
        # Length check (25 points)
        if word_count < 10:
            self.issues.append({
                'type': 'too_short',
                'severity': 'medium',
                'section': section,
                'message': f'Description too short ({word_count} words)',
                'suggestion': 'Expand with specific achievements and responsibilities (20-100 words)'
            })
            score += 5
        elif word_count > 150:
            self.issues.append({
                'type': 'too_long',
                'severity': 'low',
                'section': section,
                'message': f'Description too long ({word_count} words)',
                'suggestion': 'Condense to key achievements (20-100 words)'
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
        if not education_entries:
            self.issues.append({
                'type': 'missing_section',
                'severity': 'high',
                'section': 'education',
                'message': 'No education entries',
                'suggestion': 'Add your educational background'
            })
            return 0
        
        score = 60  # Base score for having education
        
        for edu in education_entries:
            if edu.degree and edu.institution and edu.field_of_study:
                score += 20
            else:
                self.issues.append({
                    'type': 'incomplete_info',
                    'severity': 'medium',
                    'section': 'education',
                    'message': 'Incomplete education information',
                    'suggestion': 'Include degree, field of study, and institution'
                })
            
            if edu.gpa and edu.gpa >= 3.5:
                score += 10  # Bonus for good GPA
            
            if edu.description:
                score += 10  # Bonus for additional details
        
        return min(score, 100)
    
    def _validate_skills(self, skills) -> int:
        """Validate skills section quality."""
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
        
        # Quantity scoring
        if skill_count < 3:
            self.suggestions.append({
                'type': 'insufficient_content',
                'section': 'skills',
                'message': f'Only {skill_count} skills listed',
                'suggestion': 'Add 5-10 relevant skills for better coverage'
            })
            score += 30
        elif skill_count > 15:
            self.suggestions.append({
                'type': 'too_many',
                'section': 'skills',
                'message': f'{skill_count} skills may be too many',
                'suggestion': 'Focus on 5-10 most relevant skills'
            })
            score += 70
        else:
            score += 80
        
        # Category diversity
        categories = set(skill.category for skill in skills)
        if len(categories) > 1:
            score += 20  # Bonus for diverse skill categories
        
        return min(score, 100)
    
    def _validate_completeness(self, cv_profile) -> int:
        """Validate overall CV completeness."""
        score = 0
        
        # Required sections
        if cv_profile.summary:
            score += 20
        if cv_profile.experiences.exists():
            score += 30
        if cv_profile.educations.exists():
            score += 25
        if cv_profile.skills.exists():
            score += 15
        
        # Optional but valuable sections
        if cv_profile.projects.exists():
            score += 5
        if cv_profile.certifications.exists():
            score += 5
        
        return min(score, 100)
    
    def _get_grade_for_score(self, score: float) -> str:
        """Convert numerical score to letter grade."""
        if score >= 90:
            return 'A'
        elif score >= 80:
            return 'B'
        elif score >= 70:
            return 'C'
        elif score >= 60:
            return 'D'
        else:
            return 'F'
    
    def _get_priority_improvements(self) -> List[Dict]:
        """Get top 3 priority improvements based on impact."""
        # Sort issues by severity and potential impact
        critical_issues = [issue for issue in self.issues if issue['severity'] == 'critical']
        high_issues = [issue for issue in self.issues if issue['severity'] == 'high']
        medium_issues = [issue for issue in self.issues if issue['severity'] == 'medium']
        
        priority_list = critical_issues + high_issues + medium_issues
        return priority_list[:3]  # Top 3 priorities