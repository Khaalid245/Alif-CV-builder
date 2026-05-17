"""
Analytics and Benchmarking Models for EduCV.
Enterprise-grade analytics system for tracking CV performance, peer benchmarking,
and comprehensive metrics aggregation.
"""
import uuid
from datetime import datetime, timedelta
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey
from django.core.serializers.json import DjangoJSONEncoder


class AnalyticsConfiguration(models.Model):
    """
    Global configuration for analytics system.
    Controls calculation parameters, benchmarking settings, and aggregation rules.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Configuration metadata
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    version = models.CharField(max_length=20, default='1.0.0')
    
    # Score calculation settings
    score_calculation_enabled = models.BooleanField(default=True)
    benchmarking_enabled = models.BooleanField(default=True)
    trend_analysis_enabled = models.BooleanField(default=True)
    
    # Aggregation settings
    daily_aggregation_enabled = models.BooleanField(default=True)
    weekly_aggregation_enabled = models.BooleanField(default=True)
    monthly_aggregation_enabled = models.BooleanField(default=True)
    
    # Retention settings
    raw_data_retention_days = models.IntegerField(default=365)
    aggregated_data_retention_days = models.IntegerField(default=1095)  # 3 years
    
    # Benchmarking parameters
    peer_group_size = models.IntegerField(
        default=100,
        validators=[MinValueValidator(10), MaxValueValidator(1000)],
        help_text="Number of peers to include in benchmarking calculations"
    )
    
    # Configuration data
    calculation_weights = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text="Weights for different score components"
    )
    
    benchmarking_criteria = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text="Criteria for peer group selection"
    )
    
    # Status
    is_active = models.BooleanField(default=False)
    is_default = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'analytics_configurations'
        ordering = ['-is_default', '-is_active', 'name']
        indexes = [
            models.Index(fields=['is_active'], name='idx_analytics_config_active'),
            models.Index(fields=['is_default'], name='idx_analytics_config_default'),
        ]
    
    def __str__(self):
        return f"{self.name} {'(Default)' if self.is_default else ''}"
    
    def save(self, *args, **kwargs):
        # Ensure only one default configuration
        if self.is_default:
            AnalyticsConfiguration.objects.filter(is_default=True).update(is_default=False)
        super().save(*args, **kwargs)
    
    @classmethod
    def get_active_config(cls):
        """Get the active configuration for analytics."""
        return cls.objects.filter(is_active=True, is_default=True).first() or cls.get_default_config()
    
    @classmethod
    def get_default_config(cls):
        """Get or create the default configuration."""
        config, created = cls.objects.get_or_create(
            name='Default Analytics Configuration',
            defaults={
                'description': 'Default analytics and benchmarking configuration',
                'is_active': True,
                'is_default': True,
                'calculation_weights': {
                    'completion_percentage': 0.3,
                    'overall_score': 0.4,
                    'section_scores': 0.2,
                    'improvement_rate': 0.1
                },
                'benchmarking_criteria': {
                    'education_level': True,
                    'field_of_study': True,
                    'experience_years': True,
                    'location': False
                }
            }
        )
        return config


class ScoreSnapshot(models.Model):
    """
    Point-in-time snapshot of a user's CV scores and metrics.
    Used for trend analysis and historical tracking.
    """
    
    class SnapshotType(models.TextChoices):
        MANUAL = 'manual', 'Manual'
        AUTOMATIC = 'automatic', 'Automatic'
        TRIGGERED = 'triggered', 'Triggered'
        SCHEDULED = 'scheduled', 'Scheduled'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # User reference
    user = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='score_snapshots'
    )
    
    # Snapshot metadata
    snapshot_type = models.CharField(max_length=15, choices=SnapshotType.choices)
    trigger_event = models.CharField(max_length=100, blank=True, default='')
    
    # Core scores
    overall_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Overall CV score at snapshot time'
    )
    completion_percentage = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='CV completion percentage at snapshot time'
    )
    
    # Section scores
    profile_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    experience_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    education_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    skills_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    projects_score = models.IntegerField(
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        default=0
    )
    
    # Derived metrics
    submission_ready = models.BooleanField(default=False)
    grade = models.CharField(max_length=20, blank=True, default='')
    
    # Benchmarking data
    percentile_rank = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        help_text='Percentile rank among peers'
    )
    peer_group_size = models.IntegerField(default=0)
    
    # Additional metrics
    metrics_data = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Additional calculated metrics and metadata'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'analytics_score_snapshots'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at'], name='idx_snapshots_user_created'),
            models.Index(fields=['overall_score'], name='idx_snapshots_overall_score'),
            models.Index(fields=['percentile_rank'], name='idx_snapshots_percentile'),
            models.Index(fields=['created_at'], name='idx_snapshots_created'),
        ]
    
    def __str__(self):
        return f"Score Snapshot - {self.user.email} ({self.overall_score})"


class BenchmarkingGroup(models.Model):
    """
    Defines peer groups for benchmarking comparisons.
    Groups users based on similar characteristics for fair comparison.
    """
    
    class GroupType(models.TextChoices):
        EDUCATION_LEVEL = 'education_level', 'Education Level'
        FIELD_OF_STUDY = 'field_of_study', 'Field of Study'
        EXPERIENCE_YEARS = 'experience_years', 'Experience Years'
        LOCATION = 'location', 'Location'
        CUSTOM = 'custom', 'Custom'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Group definition
    name = models.CharField(max_length=200)
    group_type = models.CharField(max_length=20, choices=GroupType.choices)
    description = models.TextField(blank=True, default='')
    
    # Criteria
    criteria = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Criteria for group membership'
    )
    
    # Members
    users = models.ManyToManyField(
        'users.User',
        through='BenchmarkingGroupMembership',
        related_name='benchmarking_groups'
    )
    
    # Statistics
    member_count = models.IntegerField(default=0)
    average_score = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True
    )
    median_score = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True
    )
    
    # Status
    is_active = models.BooleanField(default=True)
    auto_update = models.BooleanField(
        default=True,
        help_text='Automatically update group membership based on criteria'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    last_calculated_at = models.DateTimeField(null=True, blank=True)
    
    class Meta:
        db_table = 'analytics_benchmarking_groups'
        ordering = ['group_type', 'name']
        indexes = [
            models.Index(fields=['group_type'], name='idx_bench_groups_type'),
            models.Index(fields=['is_active'], name='idx_bench_groups_active'),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.member_count} members)"


class BenchmarkingGroupMembership(models.Model):
    """
    Through model for benchmarking group membership with additional metadata.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    user = models.ForeignKey('users.User', on_delete=models.CASCADE)
    group = models.ForeignKey(BenchmarkingGroup, on_delete=models.CASCADE)
    
    # Membership metadata
    joined_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)
    
    # User's position in group
    current_rank = models.IntegerField(null=True, blank=True)
    current_percentile = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True
    )
    
    class Meta:
        db_table = 'analytics_benchmarking_memberships'
        unique_together = ['user', 'group']
        indexes = [
            models.Index(fields=['group', 'is_active'], name='idx_memberships_group_active'),
            models.Index(fields=['current_rank'], name='idx_memberships_rank'),
        ]


class MetricDefinition(models.Model):
    """
    Defines custom metrics that can be calculated and tracked.
    Allows for flexible metric definitions without code changes.
    """
    
    class MetricType(models.TextChoices):
        SCORE = 'score', 'Score'
        PERCENTAGE = 'percentage', 'Percentage'
        COUNT = 'count', 'Count'
        RATIO = 'ratio', 'Ratio'
        DURATION = 'duration', 'Duration'
        CUSTOM = 'custom', 'Custom'
    
    class AggregationType(models.TextChoices):
        SUM = 'sum', 'Sum'
        AVERAGE = 'average', 'Average'
        MEDIAN = 'median', 'Median'
        MIN = 'min', 'Minimum'
        MAX = 'max', 'Maximum'
        COUNT = 'count', 'Count'
        PERCENTILE = 'percentile', 'Percentile'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Metric definition
    name = models.CharField(max_length=100, unique=True)
    display_name = models.CharField(max_length=200)
    description = models.TextField()
    
    # Type and calculation
    metric_type = models.CharField(max_length=15, choices=MetricType.choices)
    aggregation_type = models.CharField(max_length=15, choices=AggregationType.choices)
    
    # Calculation parameters
    calculation_formula = models.TextField(
        help_text='Formula or method for calculating this metric'
    )
    source_fields = models.JSONField(
        default=list,
        help_text='List of source fields/models used in calculation'
    )
    
    # Display settings
    unit = models.CharField(max_length=20, blank=True, default='')
    decimal_places = models.IntegerField(default=2)
    format_string = models.CharField(max_length=50, blank=True, default='')
    
    # Benchmarking
    is_benchmarkable = models.BooleanField(default=True)
    higher_is_better = models.BooleanField(default=True)
    
    # Status
    is_active = models.BooleanField(default=True)
    is_system_metric = models.BooleanField(
        default=False,
        help_text='System-defined metric that cannot be deleted'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'analytics_metric_definitions'
        ordering = ['name']
        indexes = [
            models.Index(fields=['is_active'], name='idx_metrics_active'),
            models.Index(fields=['metric_type'], name='idx_metrics_type'),
        ]
    
    def __str__(self):
        return self.display_name


class AggregatedMetric(models.Model):
    """
    Stores pre-calculated aggregated metrics for performance.
    Reduces the need for complex real-time calculations.
    """
    
    class AggregationPeriod(models.TextChoices):
        DAILY = 'daily', 'Daily'
        WEEKLY = 'weekly', 'Weekly'
        MONTHLY = 'monthly', 'Monthly'
        QUARTERLY = 'quarterly', 'Quarterly'
        YEARLY = 'yearly', 'Yearly'
    
    class Scope(models.TextChoices):
        GLOBAL = 'global', 'Global'
        GROUP = 'group', 'Group'
        USER = 'user', 'User'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Metric reference
    metric_definition = models.ForeignKey(
        MetricDefinition,
        on_delete=models.CASCADE,
        related_name='aggregated_values'
    )
    
    # Aggregation metadata
    period = models.CharField(max_length=15, choices=AggregationPeriod.choices)
    scope = models.CharField(max_length=10, choices=Scope.choices)
    period_start = models.DateTimeField()
    period_end = models.DateTimeField()
    
    # Scope references
    user = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='aggregated_metrics'
    )
    group = models.ForeignKey(
        BenchmarkingGroup,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='aggregated_metrics'
    )
    
    # Calculated values
    value = models.DecimalField(max_digits=15, decimal_places=6)
    sample_count = models.IntegerField(default=0)
    
    # Statistical data
    min_value = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    max_value = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    std_deviation = models.DecimalField(max_digits=15, decimal_places=6, null=True, blank=True)
    
    # Additional data
    metadata = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Additional aggregation metadata'
    )
    
    # Timestamps
    calculated_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'analytics_aggregated_metrics'
        ordering = ['-period_start']
        unique_together = [
            ['metric_definition', 'period', 'scope', 'period_start', 'user', 'group']
        ]
        indexes = [
            models.Index(fields=['metric_definition', 'period'], name='idx_agg_metrics_def_period'),
            models.Index(fields=['user', 'period_start'], name='idx_agg_metrics_user_period'),
            models.Index(fields=['group', 'period_start'], name='idx_agg_metrics_group_period'),
            models.Index(fields=['period_start'], name='idx_agg_metrics_period_start'),
        ]
    
    def __str__(self):
        scope_str = f"{self.user.email}" if self.user else f"Group: {self.group.name}" if self.group else "Global"
        return f"{self.metric_definition.display_name} - {scope_str} ({self.period})"


class TrendAnalysis(models.Model):
    """
    Stores trend analysis results for users and groups.
    Tracks performance changes over time with statistical analysis.
    """
    
    class TrendDirection(models.TextChoices):
        IMPROVING = 'improving', 'Improving'
        DECLINING = 'declining', 'Declining'
        STABLE = 'stable', 'Stable'
        VOLATILE = 'volatile', 'Volatile'
    
    class TrendStrength(models.TextChoices):
        STRONG = 'strong', 'Strong'
        MODERATE = 'moderate', 'Moderate'
        WEAK = 'weak', 'Weak'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Subject of analysis
    user = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='trend_analyses'
    )
    group = models.ForeignKey(
        BenchmarkingGroup,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='trend_analyses'
    )
    
    # Metric being analyzed
    metric_definition = models.ForeignKey(
        MetricDefinition,
        on_delete=models.CASCADE,
        related_name='trend_analyses'
    )
    
    # Analysis period
    analysis_start = models.DateTimeField()
    analysis_end = models.DateTimeField()
    data_points = models.IntegerField(default=0)
    
    # Trend results
    trend_direction = models.CharField(max_length=15, choices=TrendDirection.choices)
    trend_strength = models.CharField(max_length=15, choices=TrendStrength.choices)
    
    # Statistical measures
    slope = models.DecimalField(
        max_digits=15,
        decimal_places=6,
        help_text='Linear regression slope'
    )
    r_squared = models.DecimalField(
        max_digits=5,
        decimal_places=4,
        validators=[MinValueValidator(0), MaxValueValidator(1)],
        help_text='Coefficient of determination'
    )
    
    # Change metrics
    absolute_change = models.DecimalField(max_digits=15, decimal_places=6)
    percentage_change = models.DecimalField(max_digits=8, decimal_places=4)
    
    # Volatility measures
    volatility_score = models.DecimalField(
        max_digits=8,
        decimal_places=4,
        validators=[MinValueValidator(0)],
        help_text='Measure of score volatility'
    )
    
    # Predictions
    predicted_next_value = models.DecimalField(
        max_digits=15,
        decimal_places=6,
        null=True,
        blank=True
    )
    confidence_interval = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Confidence intervals for predictions'
    )
    
    # Analysis metadata
    analysis_data = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Detailed analysis results and intermediate calculations'
    )
    
    # Timestamps
    calculated_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'analytics_trend_analyses'
        ordering = ['-calculated_at']
        indexes = [
            models.Index(fields=['user', 'metric_definition'], name='idx_trends_user_metric'),
            models.Index(fields=['group', 'metric_definition'], name='idx_trends_group_metric'),
            models.Index(fields=['trend_direction'], name='idx_trends_direction'),
            models.Index(fields=['calculated_at'], name='idx_trends_calculated'),
        ]
    
    def __str__(self):
        subject = self.user.email if self.user else f"Group: {self.group.name}"
        return f"Trend Analysis - {subject} - {self.metric_definition.display_name}"


class AnalyticsEvent(models.Model):
    """
    Tracks analytics-related events for audit and debugging purposes.
    Records all significant analytics operations and calculations.
    """
    
    class EventType(models.TextChoices):
        SNAPSHOT_CREATED = 'snapshot_created', 'Snapshot Created'
        BENCHMARK_CALCULATED = 'benchmark_calculated', 'Benchmark Calculated'
        TREND_ANALYZED = 'trend_analyzed', 'Trend Analyzed'
        METRIC_AGGREGATED = 'metric_aggregated', 'Metric Aggregated'
        GROUP_UPDATED = 'group_updated', 'Group Updated'
        CONFIGURATION_CHANGED = 'configuration_changed', 'Configuration Changed'
        DATA_CLEANUP = 'data_cleanup', 'Data Cleanup'
        CALCULATION_ERROR = 'calculation_error', 'Calculation Error'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Event details
    event_type = models.CharField(max_length=25, choices=EventType.choices)
    description = models.TextField()
    
    # Related objects (generic foreign key)
    content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )
    object_id = models.CharField(max_length=255, null=True, blank=True)
    related_object = GenericForeignKey('content_type', 'object_id')
    
    # User context
    user = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='analytics_events'
    )
    
    # Technical details
    execution_time_ms = models.IntegerField(null=True, blank=True)
    memory_usage_mb = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True
    )
    
    # Event data
    event_data = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text='Additional event-specific data'
    )
    
    # Error information
    error_message = models.TextField(blank=True, default='')
    stack_trace = models.TextField(blank=True, default='')
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'analytics_events'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['event_type'], name='idx_analytics_events_type'),
            models.Index(fields=['user', '-created_at'], name='idx_analytics_events_user'),
            models.Index(fields=['created_at'], name='idx_analytics_events_created'),
        ]
    
    def __str__(self):
        return f"{self.event_type} - {self.created_at}"


class AnalyticsCache(models.Model):
    """
    Caching layer for expensive analytics calculations.
    Improves performance by storing frequently accessed computed results.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Cache key and metadata
    cache_key = models.CharField(max_length=255, unique=True, db_index=True)
    cache_type = models.CharField(max_length=50)
    description = models.CharField(max_length=200, blank=True, default='')
    
    # Cached data
    cached_data = models.JSONField(
        encoder=DjangoJSONEncoder,
        help_text='Cached calculation results'
    )
    
    # Cache metadata
    calculation_time_ms = models.IntegerField(default=0)
    data_size_bytes = models.IntegerField(default=0)
    hit_count = models.IntegerField(default=0)
    
    # Expiration
    expires_at = models.DateTimeField()
    is_expired = models.BooleanField(default=False)
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    last_accessed_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'analytics_cache'
        ordering = ['-last_accessed_at']
        indexes = [
            models.Index(fields=['cache_type'], name='idx_analytics_cache_type'),
            models.Index(fields=['expires_at'], name='idx_analytics_cache_expires'),
            models.Index(fields=['is_expired'], name='idx_analytics_cache_expired'),
        ]
    
    def __str__(self):
        return f"Cache: {self.cache_key}"
    
    def is_valid(self):
        """Check if cache entry is still valid."""
        return not self.is_expired and timezone.now() < self.expires_at
    
    def invalidate(self):
        """Mark cache entry as expired."""
        self.is_expired = True
        self.save(update_fields=['is_expired'])