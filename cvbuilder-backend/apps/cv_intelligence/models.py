"""
CV Intelligence Models - Enhanced analysis and scoring system.
Tracks comprehensive CV analysis, section scores, and recommendations.
"""
import uuid
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone


class CVAnalysis(models.Model):
    """
    Comprehensive CV analysis results with detailed scoring breakdown.
    Stores the complete analysis state for a user's CV at a point in time.
    """
    
    class Grade(models.TextChoices):
        EXCELLENT = 'excellent', 'Excellent (90-100)'
        GOOD = 'good', 'Good (75-89)'
        AVERAGE = 'average', 'Average (60-74)'
        NEEDS_IMPROVEMENT = 'needs_improvement', 'Needs Improvement (40-59)'
        POOR = 'poor', 'Poor (0-39)'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='cv_analyses'
    )
    
    # Overall Scores
    overall_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Overall CV score (0-100)'
    )
    grade = models.CharField(max_length=20, choices=Grade.choices)
    submission_ready = models.BooleanField(
        default=False,
        help_text='Whether CV meets minimum submission standards'
    )
    
    # Section Scores
    profile_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        help_text='Profile completeness and quality score'
    )
    experience_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        help_text='Experience section quality score'
    )
    education_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        help_text='Education section quality score'
    )
    skills_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        help_text='Skills section quality and relevance score'
    )
    projects_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0,
        help_text='Projects section quality score'
    )
    
    # Analysis Metadata
    total_issues = models.IntegerField(default=0)
    critical_issues = models.IntegerField(default=0)
    total_recommendations = models.IntegerField(default=0)
    
    # Detailed Analysis Data (JSON)
    analysis_data = models.JSONField(
        default=dict,
        help_text='Detailed analysis results and metrics'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'cv_analyses'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at']),
            models.Index(fields=['overall_score']),
            models.Index(fields=['grade']),
        ]
    
    def __str__(self):
        return f'CV Analysis - {self.user.email} ({self.grade})'


class AnalysisIssue(models.Model):
    """
    Individual issues found during CV analysis.
    Each issue represents a specific problem with actionable recommendations.
    """
    
    class Severity(models.TextChoices):
        CRITICAL = 'critical', 'Critical'
        HIGH = 'high', 'High'
        MEDIUM = 'medium', 'Medium'
        LOW = 'low', 'Low'
        INFO = 'info', 'Info'
    
    class IssueType(models.TextChoices):
        MISSING_CONTENT = 'missing_content', 'Missing Content'
        POOR_FORMATTING = 'poor_formatting', 'Poor Formatting'
        WEAK_LANGUAGE = 'weak_language', 'Weak Language'
        INSUFFICIENT_DETAIL = 'insufficient_detail', 'Insufficient Detail'
        OUTDATED_SKILLS = 'outdated_skills', 'Outdated Skills'
        GRAMMAR_ERROR = 'grammar_error', 'Grammar Error'
        INCONSISTENT_FORMAT = 'inconsistent_format', 'Inconsistent Format'
        MISSING_QUANTIFICATION = 'missing_quantification', 'Missing Quantification'
    
    class Section(models.TextChoices):
        PROFILE = 'profile', 'Profile'
        EXPERIENCE = 'experience', 'Experience'
        EDUCATION = 'education', 'Education'
        SKILLS = 'skills', 'Skills'
        PROJECTS = 'projects', 'Projects'
        LANGUAGES = 'languages', 'Languages'
        CERTIFICATIONS = 'certifications', 'Certifications'
        OVERALL = 'overall', 'Overall'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    analysis = models.ForeignKey(
        CVAnalysis,
        on_delete=models.CASCADE,
        related_name='issues'
    )
    
    # Issue Details
    issue_type = models.CharField(max_length=30, choices=IssueType.choices)
    severity = models.CharField(max_length=10, choices=Severity.choices)
    section = models.CharField(max_length=20, choices=Section.choices)
    
    # Content
    title = models.CharField(max_length=200)
    description = models.TextField()
    recommendation = models.TextField()
    
    # Context
    field_name = models.CharField(max_length=100, blank=True, default='')
    current_value = models.TextField(blank=True, default='')
    suggested_value = models.TextField(blank=True, default='')
    
    # Status
    resolved = models.BooleanField(default=False)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'cv_analysis_issues'
        ordering = ['severity', '-created_at']
        indexes = [
            models.Index(fields=['analysis', 'severity']),
            models.Index(fields=['section', 'issue_type']),
            models.Index(fields=['resolved']),
        ]
    
    def __str__(self):
        return f'{self.severity.title()} - {self.title}'
    
    def resolve(self):
        """Mark this issue as resolved."""
        self.resolved = True
        self.resolved_at = timezone.now()
        self.save(update_fields=['resolved', 'resolved_at'])


class ContentRecommendation(models.Model):
    """
    Specific content improvement recommendations generated by the analysis engine.
    Provides actionable suggestions for enhancing CV content.
    """
    
    class RecommendationType(models.TextChoices):
        CONTENT_ENHANCEMENT = 'content_enhancement', 'Content Enhancement'
        QUANTIFICATION = 'quantification', 'Add Quantification'
        ACTION_VERBS = 'action_verbs', 'Stronger Action Verbs'
        SKILL_ADDITION = 'skill_addition', 'Add Relevant Skills'
        EXPERIENCE_DETAIL = 'experience_detail', 'More Experience Detail'
        ACHIEVEMENT_FOCUS = 'achievement_focus', 'Focus on Achievements'
        FORMATTING_IMPROVEMENT = 'formatting_improvement', 'Formatting Improvement'
        KEYWORD_OPTIMIZATION = 'keyword_optimization', 'Keyword Optimization'
    
    class Priority(models.TextChoices):
        HIGH = 'high', 'High Priority'
        MEDIUM = 'medium', 'Medium Priority'
        LOW = 'low', 'Low Priority'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    analysis = models.ForeignKey(
        CVAnalysis,
        on_delete=models.CASCADE,
        related_name='recommendations'
    )
    
    # Recommendation Details
    recommendation_type = models.CharField(max_length=30, choices=RecommendationType.choices)
    priority = models.CharField(max_length=10, choices=Priority.choices)
    section = models.CharField(max_length=20, choices=AnalysisIssue.Section.choices)
    
    # Content
    title = models.CharField(max_length=200)
    description = models.TextField()
    example = models.TextField(blank=True, default='')
    
    # Context
    target_field = models.CharField(max_length=100, blank=True, default='')
    current_content = models.TextField(blank=True, default='')
    suggested_content = models.TextField(blank=True, default='')
    
    # Impact
    expected_score_improvement = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(50)],
        default=0,
        help_text='Expected score improvement if implemented'
    )
    
    # Status
    applied = models.BooleanField(default=False)
    applied_at = models.DateTimeField(null=True, blank=True)
    dismissed = models.BooleanField(default=False)
    dismissed_at = models.DateTimeField(null=True, blank=True)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'cv_content_recommendations'
        ordering = ['priority', '-expected_score_improvement', '-created_at']
        indexes = [
            models.Index(fields=['analysis', 'priority']),
            models.Index(fields=['section', 'recommendation_type']),
            models.Index(fields=['applied', 'dismissed']),
        ]
    
    def __str__(self):
        return f'{self.priority.title()} - {self.title}'
    
    def apply(self):
        """Mark this recommendation as applied."""
        self.applied = True
        self.applied_at = timezone.now()
        self.save(update_fields=['applied', 'applied_at'])
    
    def dismiss(self):
        """Mark this recommendation as dismissed."""
        self.dismissed = True
        self.dismissed_at = timezone.now()
        self.save(update_fields=['dismissed', 'dismissed_at'])


class AnalysisConfiguration(models.Model):
    """
    Configuration settings for the CV analysis engine.
    Allows dynamic adjustment of scoring weights and thresholds.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    
    # Scoring Weights (must sum to 100)
    profile_weight = models.IntegerField(
        default=20,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    experience_weight = models.IntegerField(
        default=30,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    education_weight = models.IntegerField(
        default=20,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    skills_weight = models.IntegerField(
        default=20,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    projects_weight = models.IntegerField(
        default=10,
        validators=[MinValueValidator(0), MaxValueValidator(100)]
    )
    
    # Submission Readiness Thresholds
    minimum_overall_score = models.IntegerField(
        default=60,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Minimum overall score for submission readiness'
    )
    minimum_section_scores = models.JSONField(
        default=dict,
        help_text='Minimum scores required for each section'
    )
    
    # Analysis Parameters
    configuration_data = models.JSONField(
        default=dict,
        help_text='Additional configuration parameters'
    )
    
    # Status
    is_active = models.BooleanField(default=False)
    is_default = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'cv_analysis_configurations'
        ordering = ['-is_default', '-is_active', 'name']
    
    def __str__(self):
        return f'{self.name} {"(Default)" if self.is_default else ""}'
    
    def save(self, *args, **kwargs):
        # Ensure only one default configuration
        if self.is_default:
            AnalysisConfiguration.objects.filter(is_default=True).update(is_default=False)
        super().save(*args, **kwargs)
    
    @classmethod
    def get_active_config(cls):
        """Get the active configuration for analysis."""
        return cls.objects.filter(is_active=True, is_default=True).first() or cls.get_default_config()
    
    @classmethod
    def get_default_config(cls):
        """Get or create the default configuration."""
        config, created = cls.objects.get_or_create(
            name='Default Configuration',
            defaults={
                'description': 'Default CV analysis configuration',
                'is_active': True,
                'is_default': True,
                'minimum_section_scores': {
                    'profile': 40,
                    'experience': 50,
                    'education': 40,
                    'skills': 40,
                    'projects': 30,
                }
            }
        )
        return config