"""
CV Content Analysis Engine for EduCV.
Provides deterministic scoring and recommendations for CV sections.
"""
import re
from datetime import date, timedelta
from typing import Dict, List, Tuple
from django.db.models import Count
from .models import CVProfile, CVAnalysis


class CVAnalysisService:
    """
    Intelligent CV content analysis engine.
    Scores each section 0-100 and generates actionable recommendations.
    """
    
    # Scoring weights for overall calculation
    SECTION_WEIGHTS = {
        'profile': 0.25,
        'education': 0.20,
        'experience': 0.25,
        'skills': 0.15,
        'projects': 0.15,
    }
    
    # Minimum score thresholds
    MIN_SUBMISSION_SCORE = 70
    MIN_SECTION_SCORE = 60
    
    def __init__(self, cv_profile: CVProfile):
        self.cv = cv_profile
        self._load_sections()
    
    def _load_sections(self):
        """Load all CV sections with counts in a single query."""
        self.counts = CVProfile.objects.filter(pk=self.cv.pk).aggregate(
            edu_count=Count('educations', distinct=True),
            exp_count=Count('experiences', distinct=True),
            ski_count=Count('skills', distinct=True),
            lan_count=Count('languages', distinct=True),
            pro_count=Count('projects', distinct=True),
            cer_count=Count('certifications', distinct=True),
        )
    
    def analyze(self) -> CVAnalysis:
        """
        Performs complete CV analysis and returns/saves results.
        """
        # Calculate section scores
        profile_score = self._analyze_profile()
        education_score = self._analyze_education()
        experience_score = self._analyze_experience()
        skills_score = self._analyze_skills()
        projects_score = self._analyze_projects()
        
        # Calculate overall score
        overall_score = int(
            profile_score * self.SECTION_WEIGHTS['profile'] +
            education_score * self.SECTION_WEIGHTS['education'] +
            experience_score * self.SECTION_WEIGHTS['experience'] +
            skills_score * self.SECTION_WEIGHTS['skills'] +
            projects_score * self.SECTION_WEIGHTS['projects']
        )
        
        # Determine submission readiness
        is_ready = (
            overall_score >= self.MIN_SUBMISSION_SCORE and
            all(score >= self.MIN_SECTION_SCORE for score in [
                profile_score, education_score, experience_score, skills_score, projects_score
            ])
        )
        
        # Generate recommendations
        recommendations = self._generate_recommendations({
            'profile': profile_score,
            'education': education_score,
            'experience': experience_score,
            'skills': skills_score,
            'projects': projects_score,
            'overall': overall_score,
        })
        
        # Save or update analysis
        analysis, _ = CVAnalysis.objects.update_or_create(
            cv=self.cv,
            defaults={
                'profile_score': profile_score,
                'education_score': education_score,
                'experience_score': experience_score,
                'skills_score': skills_score,
                'projects_score': projects_score,
                'overall_score': overall_score,
                'is_submission_ready': is_ready,
                'recommendations': recommendations,
            }
        )
        
        return analysis
    
    def _analyze_profile(self) -> int:
        """Analyze profile section (contact info, summary, links)."""
        score = 0
        
        # Contact information (40 points)
        if self.cv.phone: score += 10
        if self.cv.city: score += 10
        if self.cv.country: score += 10
        if self.cv.address: score += 10
        
        # Professional summary (30 points)
        if self.cv.summary:
            summary_len = len(self.cv.summary.strip())
            if summary_len >= 100: score += 30
            elif summary_len >= 50: score += 20
            elif summary_len >= 20: score += 10
        
        # Online presence (20 points)
        if self.cv.linkedin: score += 10
        if self.cv.github or self.cv.portfolio: score += 10
        
        # Photo (10 points)
        if self.cv.photo: score += 10
        
        return min(score, 100)
    
    def _analyze_education(self) -> int:
        """Analyze education section."""
        edu_count = self.counts['edu_count']
        
        if edu_count == 0:
            return 0
        
        score = 0
        educations = self.cv.educations.all()
        
        # Basic presence (40 points)
        score += 40
        
        # Multiple entries bonus (20 points)
        if edu_count >= 2: score += 20
        
        # Quality indicators (40 points)
        for edu in educations:
            # GPA provided (10 points per entry, max 20)
            if edu.gpa and score < 80: score += 10
            
            # Description provided (10 points per entry, max 20)
            if edu.description and len(edu.description.strip()) >= 50 and score < 80:
                score += 10
        
        return min(score, 100)
    
    def _analyze_experience(self) -> int:
        """Analyze work experience section."""
        exp_count = self.counts['exp_count']
        
        if exp_count == 0:
            return 0
        
        score = 0
        experiences = self.cv.experiences.all()
        
        # Basic presence (30 points)
        score += 30
        
        # Multiple entries (30 points)
        if exp_count >= 2: score += 15
        if exp_count >= 3: score += 15
        
        # Experience duration and quality (40 points)
        total_months = 0
        detailed_count = 0
        
        for exp in experiences:
            # Calculate duration
            start = exp.start_date
            end = exp.end_date or date.today()
            months = (end.year - start.year) * 12 + (end.month - start.month)
            total_months += max(months, 0)
            
            # Check for detailed descriptions
            if exp.description and len(exp.description.strip()) >= 100:
                detailed_count += 1
        
        # Duration scoring (20 points)
        if total_months >= 24: score += 20
        elif total_months >= 12: score += 15
        elif total_months >= 6: score += 10
        elif total_months >= 3: score += 5
        
        # Description quality (20 points)
        if detailed_count >= exp_count: score += 20
        elif detailed_count >= exp_count // 2: score += 10
        
        return min(score, 100)
    
    def _analyze_skills(self) -> int:
        """Analyze skills section."""
        ski_count = self.counts['ski_count']
        
        if ski_count == 0:
            return 0
        
        score = 0
        skills = self.cv.skills.all()
        
        # Basic presence (30 points)
        score += 30
        
        # Quantity scoring (30 points)
        if ski_count >= 8: score += 30
        elif ski_count >= 6: score += 25
        elif ski_count >= 4: score += 20
        elif ski_count >= 2: score += 15
        
        # Diversity and quality (40 points)
        categories = set(skill.category for skill in skills)
        advanced_count = sum(1 for skill in skills if skill.level in ['advanced', 'expert'])
        
        # Category diversity (20 points)
        if len(categories) >= 3: score += 20
        elif len(categories) >= 2: score += 15
        elif len(categories) >= 1: score += 10
        
        # Advanced skills (20 points)
        if advanced_count >= 3: score += 20
        elif advanced_count >= 2: score += 15
        elif advanced_count >= 1: score += 10
        
        return min(score, 100)
    
    def _analyze_projects(self) -> int:
        """Analyze projects section."""
        pro_count = self.counts['pro_count']
        
        if pro_count == 0:
            return 0
        
        score = 0
        projects = self.cv.projects.all()
        
        # Basic presence (40 points)
        score += 40
        
        # Multiple projects (30 points)
        if pro_count >= 3: score += 30
        elif pro_count >= 2: score += 20
        
        # Quality indicators (30 points)
        detailed_count = 0
        linked_count = 0
        
        for project in projects:
            if project.description and len(project.description.strip()) >= 100:
                detailed_count += 1
            if project.link:
                linked_count += 1
        
        # Detailed descriptions (15 points)
        if detailed_count >= pro_count: score += 15
        elif detailed_count >= pro_count // 2: score += 10
        
        # Project links (15 points)
        if linked_count >= pro_count // 2: score += 15
        elif linked_count >= 1: score += 10
        
        return min(score, 100)
    
    def _generate_recommendations(self, scores: Dict[str, int]) -> Dict:
        """Generate actionable recommendations based on scores."""
        recommendations = {
            'critical': [],
            'important': [],
            'suggestions': [],
            'strengths': [],
        }
        
        # Critical issues (score < 40)
        for section, score in scores.items():
            if section == 'overall':
                continue
                
            if score < 40:
                recommendations['critical'].extend(
                    self._get_critical_recommendations(section, score)
                )
        
        # Important improvements (score 40-69)
        for section, score in scores.items():
            if section == 'overall':
                continue
                
            if 40 <= score < 70:
                recommendations['important'].extend(
                    self._get_important_recommendations(section, score)
                )
        
        # General suggestions (score 70-89)
        for section, score in scores.items():
            if section == 'overall':
                continue
                
            if 70 <= score < 90:
                recommendations['suggestions'].extend(
                    self._get_suggestion_recommendations(section, score)
                )
        
        # Identify strengths (score >= 90)
        for section, score in scores.items():
            if section == 'overall':
                continue
                
            if score >= 90:
                recommendations['strengths'].append(
                    f"Excellent {section} section - well detailed and comprehensive"
                )
        
        # Overall recommendations
        if scores['overall'] < self.MIN_SUBMISSION_SCORE:
            recommendations['critical'].append(
                f"Overall CV score ({scores['overall']}%) is below submission threshold ({self.MIN_SUBMISSION_SCORE}%)"
            )
        
        return recommendations
    
    def _get_critical_recommendations(self, section: str, score: int) -> List[str]:
        """Get critical recommendations for low-scoring sections."""
        if section == 'profile':
            return [
                "Add missing contact information (phone, city, country)",
                "Write a professional summary (at least 100 words)",
                "Add LinkedIn profile and portfolio/GitHub links",
            ]
        elif section == 'education':
            return ["Add at least one education entry with complete details"]
        elif section == 'experience':
            return ["Add work experience, internships, or relevant positions"]
        elif section == 'skills':
            return ["Add at least 4-6 relevant skills with appropriate levels"]
        elif section == 'projects':
            return ["Add at least 2-3 projects with detailed descriptions"]
        return []
    
    def _get_important_recommendations(self, section: str, score: int) -> List[str]:
        """Get important recommendations for medium-scoring sections."""
        if section == 'profile':
            return [
                "Expand professional summary to 100+ words",
                "Add professional photo",
                "Include GitHub or portfolio link",
            ]
        elif section == 'education':
            return [
                "Add GPA if above 3.0",
                "Include relevant coursework or achievements",
                "Add multiple education entries if applicable",
            ]
        elif section == 'experience':
            return [
                "Add more detailed job descriptions (100+ words each)",
                "Include additional work experience or internships",
                "Quantify achievements with numbers and results",
            ]
        elif section == 'skills':
            return [
                "Add more skills (aim for 6-8 total)",
                "Include skills from different categories",
                "Mark advanced skills appropriately",
            ]
        elif section == 'projects':
            return [
                "Add more projects (aim for 3+ total)",
                "Write detailed project descriptions (100+ words)",
                "Include project links or repositories",
            ]
        return []
    
    def _get_suggestion_recommendations(self, section: str, score: int) -> List[str]:
        """Get suggestions for good-scoring sections."""
        if section == 'profile':
            return ["Consider adding address for local opportunities"]
        elif section == 'education':
            return ["Add relevant coursework or academic projects"]
        elif section == 'experience':
            return ["Highlight leadership roles and key achievements"]
        elif section == 'skills':
            return ["Group skills by category for better organization"]
        elif section == 'projects':
            return ["Add recent projects to show current skills"]
        return []