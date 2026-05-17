"""
Dynamic Template Engine models for EduCV.
Enterprise-grade template system with industry-specific layouts,
role-based selection, versioning, and performance analytics.
"""
import uuid
import json
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.core.exceptions import ValidationError

User = get_user_model()


class Industry(models.Model):
    """Industry categories for template targeting."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_industries'
        ordering = ['name']

    def __str__(self):
        return self.name


class Role(models.Model):
    """Job roles for template targeting."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    industry = models.ForeignKey(Industry, on_delete=models.CASCADE, related_name='roles')
    description = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_roles'
        ordering = ['industry__name', 'name']

    def __str__(self):
        return f"{self.name} ({self.industry.name})"


class TemplateCategory(models.Model):
    """Template categories for organization."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True, default='')
    is_active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_categories'
        ordering = ['name']

    def __str__(self):
        return self.name


class Template(models.Model):
    """Core template definition with versioning and targeting."""
    
    class Status(models.TextChoices):
        DRAFT = 'draft', 'Draft'
        ACTIVE = 'active', 'Active'
        DEPRECATED = 'deprecated', 'Deprecated'
        ARCHIVED = 'archived', 'Archived'

    class Layout(models.TextChoices):
        SINGLE_COLUMN = 'single_column', 'Single Column'
        TWO_COLUMN = 'two_column', 'Two Column'
        THREE_COLUMN = 'three_column', 'Three Column'
        MODERN_GRID = 'modern_grid', 'Modern Grid'
        TIMELINE = 'timeline', 'Timeline'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100)
    slug = models.SlugField(max_length=100, unique=True)
    description = models.TextField(blank=True, default='')
    
    # Template targeting
    category = models.ForeignKey(TemplateCategory, on_delete=models.CASCADE, related_name='templates')
    industries = models.ManyToManyField(Industry, blank=True, related_name='templates')
    roles = models.ManyToManyField(Role, blank=True, related_name='templates')
    
    # Layout configuration
    layout_type = models.CharField(max_length=20, choices=Layout.choices, default=Layout.SINGLE_COLUMN)
    
    # Template files
    html_template = models.TextField(help_text='HTML template content')
    css_styles = models.TextField(blank=True, default='', help_text='CSS styles for template')
    
    # Versioning
    version = models.CharField(max_length=20, default='1.0.0')
    parent_template = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='versions')
    
    # Status and metadata
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.DRAFT)
    is_premium = models.BooleanField(default=False)
    usage_count = models.IntegerField(default=0)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    published_at = models.DateTimeField(null=True, blank=True)

    class Meta:
        db_table = 'templates'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status', 'is_premium'], name='idx_template_status_premium'),
            models.Index(fields=['category', 'status'], name='idx_template_category_status'),
        ]

    def __str__(self):
        return f"{self.name} v{self.version}"

    def clean(self):
        """Validate template data."""
        if self.status == self.Status.ACTIVE and not self.html_template:
            raise ValidationError("Active templates must have HTML content")

    def save(self, *args, **kwargs):
        if self.status == self.Status.ACTIVE and not self.published_at:
            self.published_at = timezone.now()
        super().save(*args, **kwargs)


class SectionConfiguration(models.Model):
    """Configurable CV sections for templates."""
    
    class SectionType(models.TextChoices):
        PERSONAL_INFO = 'personal_info', 'Personal Information'
        SUMMARY = 'summary', 'Professional Summary'
        EDUCATION = 'education', 'Education'
        EXPERIENCE = 'experience', 'Work Experience'
        SKILLS = 'skills', 'Skills'
        LANGUAGES = 'languages', 'Languages'
        PROJECTS = 'projects', 'Projects'
        CERTIFICATIONS = 'certifications', 'Certifications'
        REFERENCES = 'references', 'References'
        CUSTOM = 'custom', 'Custom Section'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    template = models.ForeignKey(Template, on_delete=models.CASCADE, related_name='sections')
    section_type = models.CharField(max_length=20, choices=SectionType.choices)
    display_name = models.CharField(max_length=100)
    is_required = models.BooleanField(default=False)
    is_visible = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    
    # Section styling
    css_classes = models.CharField(max_length=200, blank=True, default='')
    custom_html = models.TextField(blank=True, default='')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_sections'
        ordering = ['template', 'order']
        constraints = [
            models.UniqueConstraint(
                fields=['template', 'section_type'], 
                name='unique_section_per_template'
            )
        ]

    def __str__(self):
        return f"{self.template.name} - {self.display_name}"


class BrandingConfiguration(models.Model):
    """Custom branding and styling for templates."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    template = models.OneToOneField(Template, on_delete=models.CASCADE, related_name='branding')
    
    # Color scheme
    primary_color = models.CharField(max_length=7, default='#2563eb', help_text='Hex color code')
    secondary_color = models.CharField(max_length=7, default='#64748b', help_text='Hex color code')
    accent_color = models.CharField(max_length=7, default='#0ea5e9', help_text='Hex color code')
    text_color = models.CharField(max_length=7, default='#1e293b', help_text='Hex color code')
    background_color = models.CharField(max_length=7, default='#ffffff', help_text='Hex color code')
    
    # Typography
    font_family = models.CharField(max_length=100, default='Inter, sans-serif')
    heading_font = models.CharField(max_length=100, default='Inter, sans-serif')
    font_size_base = models.IntegerField(default=14, validators=[MinValueValidator(10), MaxValueValidator(20)])
    
    # Spacing and layout
    margin_top = models.IntegerField(default=20, validators=[MinValueValidator(0), MaxValueValidator(100)])
    margin_bottom = models.IntegerField(default=20, validators=[MinValueValidator(0), MaxValueValidator(100)])
    section_spacing = models.IntegerField(default=15, validators=[MinValueValidator(0), MaxValueValidator(50)])
    
    # Custom CSS
    custom_css = models.TextField(blank=True, default='')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_branding'

    def __str__(self):
        return f"Branding for {self.template.name}"


class UserTemplatePreference(models.Model):
    """User preferences for template selection."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='template_preferences')
    
    # Preferred industries and roles
    preferred_industries = models.ManyToManyField(Industry, blank=True, related_name='preferred_by_users')
    preferred_roles = models.ManyToManyField(Role, blank=True, related_name='preferred_by_users')
    
    # Template preferences
    favorite_templates = models.ManyToManyField(Template, blank=True, related_name='favorited_by_users')
    default_template = models.ForeignKey(Template, on_delete=models.SET_NULL, null=True, blank=True, related_name='default_for_users')
    
    # Section preferences
    section_order_preferences = models.JSONField(default=dict, blank=True)
    hidden_sections = models.JSONField(default=list, blank=True)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'user_template_preferences'

    def __str__(self):
        return f"Preferences for {self.user.email}"


class TemplateUsage(models.Model):
    """Track template usage for analytics."""
    
    class Action(models.TextChoices):
        PREVIEW = 'preview', 'Preview'
        GENERATE = 'generate', 'Generate PDF'
        DOWNLOAD = 'download', 'Download'
        FAVORITE = 'favorite', 'Add to Favorites'
        UNFAVORITE = 'unfavorite', 'Remove from Favorites'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    template = models.ForeignKey(Template, on_delete=models.CASCADE, related_name='usage_logs')
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='template_usage')
    action = models.CharField(max_length=15, choices=Action.choices)
    
    # Context data
    user_agent = models.TextField(blank=True, default='')
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    session_id = models.CharField(max_length=100, blank=True, default='')
    
    # Performance metrics
    render_time_ms = models.IntegerField(null=True, blank=True, help_text='Rendering time in milliseconds')
    file_size_bytes = models.IntegerField(null=True, blank=True, help_text='Generated file size in bytes')
    
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'template_usage'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['template', 'action'], name='idx_usage_template_action'),
            models.Index(fields=['user', 'created_at'], name='idx_usage_user_created'),
            models.Index(fields=['created_at'], name='idx_usage_created'),
        ]

    def __str__(self):
        return f"{self.user.email} - {self.action} - {self.template.name}"


class TemplatePerformanceMetric(models.Model):
    """Aggregated performance metrics for templates."""
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    template = models.ForeignKey(Template, on_delete=models.CASCADE, related_name='performance_metrics')
    
    # Time period
    date = models.DateField()
    
    # Usage metrics
    total_previews = models.IntegerField(default=0)
    total_generations = models.IntegerField(default=0)
    total_downloads = models.IntegerField(default=0)
    unique_users = models.IntegerField(default=0)
    
    # Performance metrics
    avg_render_time_ms = models.FloatField(null=True, blank=True)
    avg_file_size_bytes = models.FloatField(null=True, blank=True)
    
    # Quality metrics
    favorite_count = models.IntegerField(default=0)
    conversion_rate = models.FloatField(default=0.0, help_text='Preview to generation conversion rate')
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_performance_metrics'
        ordering = ['-date']
        constraints = [
            models.UniqueConstraint(
                fields=['template', 'date'], 
                name='unique_template_metric_per_date'
            )
        ]

    def __str__(self):
        return f"{self.template.name} - {self.date}"


class TemplateRecommendation(models.Model):
    """AI-powered template recommendations for users."""
    
    class RecommendationType(models.TextChoices):
        INDUSTRY_BASED = 'industry_based', 'Industry Based'
        ROLE_BASED = 'role_based', 'Role Based'
        USAGE_BASED = 'usage_based', 'Usage Pattern Based'
        COLLABORATIVE = 'collaborative', 'Collaborative Filtering'
        CONTENT_BASED = 'content_based', 'Content Based'

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='template_recommendations')
    template = models.ForeignKey(Template, on_delete=models.CASCADE, related_name='recommendations')
    
    recommendation_type = models.CharField(max_length=20, choices=RecommendationType.choices)
    confidence_score = models.FloatField(validators=[MinValueValidator(0.0), MaxValueValidator(1.0)])
    reasoning = models.TextField(blank=True, default='')
    
    # Recommendation metadata
    algorithm_version = models.CharField(max_length=20, default='1.0')
    context_data = models.JSONField(default=dict, blank=True)
    
    # Interaction tracking
    is_viewed = models.BooleanField(default=False)
    is_clicked = models.BooleanField(default=False)
    is_used = models.BooleanField(default=False)
    
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        db_table = 'template_recommendations'
        ordering = ['-confidence_score', '-created_at']
        indexes = [
            models.Index(fields=['user', 'confidence_score'], name='idx_rec_user_confidence'),
            models.Index(fields=['template', 'recommendation_type'], name='idx_rec_template_type'),
        ]

    def __str__(self):
        return f"Recommend {self.template.name} to {self.user.email} ({self.confidence_score:.2f})"