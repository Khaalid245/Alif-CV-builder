"""
CV Intelligence models for tracking analysis and suggestions.
"""
import uuid
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()


class CVAnalysis(models.Model):
    """
    Stores comprehensive CV analysis results.
    Tracks scoring, feedback, and improvement suggestions.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='cv_analyses')
    
    # Scoring breakdown
    overall_score = models.IntegerField(default=0, help_text='Overall CV score (0-100)')
    completeness_score = models.IntegerField(default=0, help_text='Completeness score (0-25)')
    quality_score = models.IntegerField(default=0, help_text='Content quality score (0-40)')
    skills_score = models.IntegerField(default=0, help_text='Skills relevance score (0-20)')
    format_score = models.IntegerField(default=0, help_text='Format optimization score (0-15)')
    
    # Analysis data
    analysis_data = models.JSONField(default=dict, help_text='Detailed feedback and suggestions')
    grade = models.CharField(max_length=2, default='F', help_text='Letter grade (A-F)')
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'cv_analyses'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at'], name='idx_cv_analysis_user_date'),
            models.Index(fields=['overall_score'], name='idx_cv_analysis_score'),
        ]
    
    def __str__(self):
        return f'CV Analysis - {self.user.email} - Score: {self.overall_score}'


class ContentSuggestion(models.Model):
    """
    Stores content enhancement suggestions for CV sections.
    Tracks what improvements were suggested and whether they were applied.
    """
    
    class SectionType(models.TextChoices):
        SUMMARY = 'summary', 'Professional Summary'
        EXPERIENCE = 'experience', 'Work Experience'
        EDUCATION = 'education', 'Education'
        SKILLS = 'skills', 'Skills'
        PROJECTS = 'projects', 'Projects'
        CERTIFICATIONS = 'certifications', 'Certifications'
    
    class SuggestionType(models.TextChoices):
        CONTENT_ENHANCEMENT = 'content_enhancement', 'Content Enhancement'
        WEAK_LANGUAGE = 'weak_language', 'Weak Language Fix'
        QUANTIFICATION = 'quantification', 'Add Quantification'
        ACTION_VERBS = 'action_verbs', 'Improve Action Verbs'
        LENGTH_IMPROVEMENT = 'length_improvement', 'Length Improvement'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='content_suggestions')
    
    # Suggestion details
    section_type = models.CharField(max_length=50, choices=SectionType.choices)
    suggestion_type = models.CharField(max_length=50, choices=SuggestionType.choices)
    
    # Content
    original_content = models.TextField(help_text='Original content before enhancement')
    suggested_content = models.TextField(help_text='AI-enhanced content suggestion')
    improvement_reason = models.TextField(help_text='Explanation of why this improvement helps')
    
    # Tracking
    applied = models.BooleanField(default=False, help_text='Whether user applied this suggestion')
    applied_at = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'content_suggestions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'section_type'], name='idx_suggestion_user_section'),
            models.Index(fields=['applied'], name='idx_suggestion_applied'),
        ]
    
    def __str__(self):
        return f'{self.get_suggestion_type_display()} - {self.section_type} - {self.user.email}'


class ValidationIssue(models.Model):
    """
    Tracks validation issues found in CV content.
    Helps identify common problems and track improvements.
    """
    
    class IssueType(models.TextChoices):
        TOO_SHORT = 'too_short', 'Content Too Short'
        WEAK_LANGUAGE = 'weak_language', 'Weak Language Used'
        NO_QUANTIFICATION = 'no_quantification', 'Missing Numbers/Metrics'
        POOR_GRAMMAR = 'poor_grammar', 'Grammar Issues'
        MISSING_SECTION = 'missing_section', 'Missing Required Section'
        INCOMPLETE_INFO = 'incomplete_info', 'Incomplete Information'
    
    class Severity(models.TextChoices):
        LOW = 'low', 'Low'
        MEDIUM = 'medium', 'Medium'
        HIGH = 'high', 'High'
        CRITICAL = 'critical', 'Critical'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='validation_issues')
    
    # Issue details
    issue_type = models.CharField(max_length=50, choices=IssueType.choices)
    severity = models.CharField(max_length=10, choices=Severity.choices, default=Severity.MEDIUM)
    section_type = models.CharField(max_length=50)
    
    # Description and solution
    description = models.TextField(help_text='Description of the issue')
    suggestion = models.TextField(help_text='How to fix this issue')
    
    # Tracking
    resolved = models.BooleanField(default=False)
    resolved_at = models.DateTimeField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'validation_issues'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', 'resolved'], name='idx_issue_user_resolved'),
            models.Index(fields=['severity'], name='idx_issue_severity'),
        ]
    
    def __str__(self):
        return f'{self.get_issue_type_display()} - {self.severity} - {self.user.email}'