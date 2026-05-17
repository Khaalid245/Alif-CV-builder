"""
Serializers for Analytics API.
Handles serialization of analytics data, benchmarking results, and metrics.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.utils.html import escape

from .models import (
    AnalyticsConfiguration, ScoreSnapshot, BenchmarkingGroup,
    BenchmarkingGroupMembership, MetricDefinition, AggregatedMetric,
    TrendAnalysis, AnalyticsEvent, AnalyticsCache
)

User = get_user_model()


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user info for analytics."""
    
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name']
        read_only_fields = fields


class AnalyticsConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for analytics configuration."""
    
    class Meta:
        model = AnalyticsConfiguration
        fields = [
            'id', 'name', 'description', 'version', 'score_calculation_enabled',
            'benchmarking_enabled', 'trend_analysis_enabled', 'daily_aggregation_enabled',
            'weekly_aggregation_enabled', 'monthly_aggregation_enabled',
            'raw_data_retention_days', 'aggregated_data_retention_days',
            'peer_group_size', 'calculation_weights', 'benchmarking_criteria',
            'is_active', 'is_default', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_calculation_weights(self, value):
        """Validate calculation weights."""
        if not isinstance(value, dict):
            raise serializers.ValidationError("Calculation weights must be a dictionary.")
        
        # Check that weights are numeric and sum to 1.0
        total_weight = sum(float(v) for v in value.values() if isinstance(v, (int, float)))
        if abs(total_weight - 1.0) > 0.01:  # Allow small floating point errors
            raise serializers.ValidationError("Calculation weights must sum to 1.0.")
        
        return value


class ScoreSnapshotListSerializer(serializers.ModelSerializer):
    """Serializer for score snapshot list view."""
    
    time_ago = serializers.SerializerMethodField()
    grade_display = serializers.SerializerMethodField()
    
    class Meta:
        model = ScoreSnapshot
        fields = [
            'id', 'snapshot_type', 'trigger_event', 'overall_score',
            'completion_percentage', 'submission_ready', 'grade',
            'grade_display', 'percentile_rank', 'peer_group_size',
            'time_ago', 'created_at'
        ]
        read_only_fields = fields
    
    def get_time_ago(self, obj):
        """Calculate human-readable time ago."""
        now = timezone.now()
        diff = now - obj.created_at
        
        if diff.days > 0:
            return escape(f"{diff.days} day{'s' if diff.days > 1 else ''} ago")
        elif diff.seconds > 3600:
            hours = diff.seconds // 3600
            return escape(f"{hours} hour{'s' if hours > 1 else ''} ago")
        elif diff.seconds > 60:
            minutes = diff.seconds // 60
            return escape(f"{minutes} minute{'s' if minutes > 1 else ''} ago")
        else:
            return escape("Just now")
    
    def get_grade_display(self, obj):
        """Get human-readable grade display."""
        grade_mapping = {
            'excellent': 'Excellent',
            'good': 'Good',
            'average': 'Average',
            'needs_improvement': 'Needs Improvement',
            'poor': 'Poor'
        }
        return escape(grade_mapping.get(obj.grade, obj.grade.title()))


class ScoreSnapshotDetailSerializer(serializers.ModelSerializer):
    """Serializer for detailed score snapshot view."""
    
    user = UserBasicSerializer(read_only=True)
    time_ago = serializers.SerializerMethodField()
    grade_display = serializers.SerializerMethodField()
    section_scores = serializers.SerializerMethodField()
    
    class Meta:
        model = ScoreSnapshot
        fields = [
            'id', 'user', 'snapshot_type', 'trigger_event', 'overall_score',
            'completion_percentage', 'profile_score', 'experience_score',
            'education_score', 'skills_score', 'projects_score',
            'submission_ready', 'grade', 'grade_display', 'percentile_rank',
            'peer_group_size', 'metrics_data', 'section_scores',
            'time_ago', 'created_at'
        ]
        read_only_fields = fields
    
    def get_time_ago(self, obj):
        """Calculate human-readable time ago."""
        return ScoreSnapshotListSerializer().get_time_ago(obj)
    
    def get_grade_display(self, obj):
        """Get human-readable grade display."""
        return ScoreSnapshotListSerializer().get_grade_display(obj)
    
    def get_section_scores(self, obj):
        """Get section scores as a structured object."""
        return {
            'profile': obj.profile_score,
            'experience': obj.experience_score,
            'education': obj.education_score,
            'skills': obj.skills_score,
            'projects': obj.projects_score
        }


class BenchmarkingGroupSerializer(serializers.ModelSerializer):
    """Serializer for benchmarking groups."""
    
    group_type_display = serializers.SerializerMethodField()
    
    class Meta:
        model = BenchmarkingGroup
        fields = [
            'id', 'name', 'group_type', 'group_type_display', 'description',
            'criteria', 'member_count', 'average_score', 'median_score',
            'is_active', 'auto_update', 'created_at', 'updated_at',
            'last_calculated_at'
        ]
        read_only_fields = [
            'id', 'member_count', 'average_score', 'median_score',
            'created_at', 'updated_at', 'last_calculated_at'
        ]
    
    def get_group_type_display(self, obj):
        """Get human-readable group type."""
        return escape(obj.get_group_type_display())


class BenchmarkingGroupMembershipSerializer(serializers.ModelSerializer):
    """Serializer for group membership."""
    
    user = UserBasicSerializer(read_only=True)
    group = BenchmarkingGroupSerializer(read_only=True)
    
    class Meta:
        model = BenchmarkingGroupMembership
        fields = [
            'id', 'user', 'group', 'joined_at', 'is_active',
            'current_rank', 'current_percentile'
        ]
        read_only_fields = fields


class MetricDefinitionSerializer(serializers.ModelSerializer):
    """Serializer for metric definitions."""
    
    metric_type_display = serializers.SerializerMethodField()
    aggregation_type_display = serializers.SerializerMethodField()
    
    class Meta:
        model = MetricDefinition
        fields = [
            'id', 'name', 'display_name', 'description', 'metric_type',
            'metric_type_display', 'aggregation_type', 'aggregation_type_display',
            'calculation_formula', 'source_fields', 'unit', 'decimal_places',
            'format_string', 'is_benchmarkable', 'higher_is_better',
            'is_active', 'is_system_metric', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'is_system_metric', 'created_at', 'updated_at']
    
    def get_metric_type_display(self, obj):
        """Get human-readable metric type."""
        return escape(obj.get_metric_type_display())
    
    def get_aggregation_type_display(self, obj):
        """Get human-readable aggregation type."""
        return escape(obj.get_aggregation_type_display())
    
    def validate_name(self, value):
        """Validate metric name uniqueness."""
        if self.instance and self.instance.name == value:
            return value
        
        if MetricDefinition.objects.filter(name=value).exists():
            raise serializers.ValidationError("Metric with this name already exists.")
        
        return value


class AggregatedMetricSerializer(serializers.ModelSerializer):
    """Serializer for aggregated metrics."""
    
    metric_definition = MetricDefinitionSerializer(read_only=True)
    user = UserBasicSerializer(read_only=True)
    group = BenchmarkingGroupSerializer(read_only=True)
    period_display = serializers.SerializerMethodField()
    scope_display = serializers.SerializerMethodField()
    
    class Meta:
        model = AggregatedMetric
        fields = [
            'id', 'metric_definition', 'period', 'period_display',
            'scope', 'scope_display', 'period_start', 'period_end',
            'user', 'group', 'value', 'sample_count', 'min_value',
            'max_value', 'std_deviation', 'metadata', 'calculated_at'
        ]
        read_only_fields = fields
    
    def get_period_display(self, obj):
        """Get human-readable period."""
        return escape(obj.get_period_display())
    
    def get_scope_display(self, obj):
        """Get human-readable scope."""
        return escape(obj.get_scope_display())


class TrendAnalysisSerializer(serializers.ModelSerializer):
    """Serializer for trend analysis results."""
    
    user = UserBasicSerializer(read_only=True)
    group = BenchmarkingGroupSerializer(read_only=True)
    metric_definition = MetricDefinitionSerializer(read_only=True)
    trend_direction_display = serializers.SerializerMethodField()
    trend_strength_display = serializers.SerializerMethodField()
    
    class Meta:
        model = TrendAnalysis
        fields = [
            'id', 'user', 'group', 'metric_definition', 'analysis_start',
            'analysis_end', 'data_points', 'trend_direction',
            'trend_direction_display', 'trend_strength', 'trend_strength_display',
            'slope', 'r_squared', 'absolute_change', 'percentage_change',
            'volatility_score', 'predicted_next_value', 'confidence_interval',
            'analysis_data', 'calculated_at'
        ]
        read_only_fields = fields
    
    def get_trend_direction_display(self, obj):
        """Get human-readable trend direction."""
        return escape(obj.get_trend_direction_display())
    
    def get_trend_strength_display(self, obj):
        """Get human-readable trend strength."""
        return escape(obj.get_trend_strength_display())


class AnalyticsEventSerializer(serializers.ModelSerializer):
    """Serializer for analytics events (audit log)."""
    
    user = UserBasicSerializer(read_only=True)
    event_type_display = serializers.SerializerMethodField()
    related_object_info = serializers.SerializerMethodField()
    
    class Meta:
        model = AnalyticsEvent
        fields = [
            'id', 'event_type', 'event_type_display', 'description',
            'user', 'related_object_info', 'execution_time_ms',
            'memory_usage_mb', 'event_data', 'error_message',
            'created_at'
        ]
        read_only_fields = fields
    
    def get_event_type_display(self, obj):
        """Get human-readable event type."""
        return escape(obj.get_event_type_display())
    
    def get_related_object_info(self, obj):
        """Get basic info about related object."""
        if obj.related_object:
            return {
                'type': escape(obj.content_type.model),
                'id': escape(str(obj.object_id)),
                'name': escape(str(obj.related_object))
            }
        return None


class ScoreTrendSerializer(serializers.Serializer):
    """Serializer for score trend analysis results."""
    
    trend_direction = serializers.CharField(read_only=True)
    trend_strength = serializers.CharField(read_only=True)
    metric = serializers.CharField(read_only=True)
    period_days = serializers.IntegerField(read_only=True)
    data_points = serializers.IntegerField(read_only=True)
    start_value = serializers.FloatField(read_only=True)
    end_value = serializers.FloatField(read_only=True)
    min_value = serializers.FloatField(read_only=True)
    max_value = serializers.FloatField(read_only=True)
    average_value = serializers.FloatField(read_only=True)
    slope = serializers.FloatField(read_only=True)
    r_squared = serializers.FloatField(read_only=True)
    absolute_change = serializers.FloatField(read_only=True)
    percentage_change = serializers.FloatField(read_only=True)
    volatility = serializers.FloatField(read_only=True)
    snapshots = serializers.ListField(read_only=True)
    message = serializers.CharField(read_only=True, required=False)


class PeerBenchmarkingSerializer(serializers.Serializer):
    """Serializer for peer benchmarking results."""
    
    group_name = serializers.CharField(read_only=True)
    group_type = serializers.CharField(read_only=True)
    member_count = serializers.IntegerField(read_only=True)
    user_score = serializers.IntegerField(read_only=True)
    user_rank = serializers.IntegerField(read_only=True)
    user_percentile = serializers.FloatField(read_only=True)
    group_average = serializers.FloatField(read_only=True)
    group_median = serializers.FloatField(read_only=True)
    group_min = serializers.FloatField(read_only=True)
    group_max = serializers.FloatField(read_only=True)
    performance_vs_average = serializers.FloatField(read_only=True)
    performance_vs_median = serializers.FloatField(read_only=True)


class CompletionStatisticsSerializer(serializers.Serializer):
    """Serializer for completion statistics."""
    
    period_days = serializers.IntegerField(read_only=True)
    group_type = serializers.CharField(read_only=True, allow_null=True)
    summary_statistics = serializers.DictField(read_only=True)
    completion_distribution = serializers.DictField(read_only=True)
    score_distribution = serializers.DictField(read_only=True)


class CreateSnapshotSerializer(serializers.Serializer):
    """Serializer for creating score snapshots."""
    
    user_id = serializers.UUIDField(required=False)
    snapshot_type = serializers.ChoiceField(
        choices=ScoreSnapshot.SnapshotType.choices,
        default='manual'
    )
    trigger_event = serializers.CharField(max_length=100, required=False, default='')
    
    def validate_user_id(self, value):
        """Validate that user exists."""
        if value:
            try:
                User.objects.get(id=value)
            except User.DoesNotExist:
                raise serializers.ValidationError("User not found.")
        return value


class TrendAnalysisRequestSerializer(serializers.Serializer):
    """Serializer for trend analysis requests."""
    
    user_id = serializers.UUIDField(required=False)
    days = serializers.IntegerField(min_value=7, max_value=365, default=30)
    metric = serializers.ChoiceField(
        choices=[
            ('overall_score', 'Overall Score'),
            ('completion_percentage', 'Completion Percentage'),
            ('profile_score', 'Profile Score'),
            ('experience_score', 'Experience Score'),
            ('education_score', 'Education Score'),
            ('skills_score', 'Skills Score'),
            ('projects_score', 'Projects Score'),
        ],
        default='overall_score'
    )
    
    def validate_user_id(self, value):
        """Validate that user exists."""
        if value:
            try:
                User.objects.get(id=value)
            except User.DoesNotExist:
                raise serializers.ValidationError("User not found.")
        return value


class BenchmarkingRequestSerializer(serializers.Serializer):
    """Serializer for benchmarking requests."""
    
    user_id = serializers.UUIDField(required=False)
    group_types = serializers.ListField(
        child=serializers.ChoiceField(choices=BenchmarkingGroup.GroupType.choices),
        required=False,
        default=list
    )
    
    def validate_user_id(self, value):
        """Validate that user exists."""
        if value:
            try:
                User.objects.get(id=value)
            except User.DoesNotExist:
                raise serializers.ValidationError("User not found.")
        return value


class CompletionStatisticsRequestSerializer(serializers.Serializer):
    """Serializer for completion statistics requests."""
    
    group_type = serializers.ChoiceField(
        choices=BenchmarkingGroup.GroupType.choices,
        required=False,
        allow_null=True
    )
    time_period = serializers.IntegerField(
        min_value=1,
        max_value=365,
        default=30
    )


class AnalyticsDashboardSerializer(serializers.Serializer):
    """Serializer for analytics dashboard data."""
    
    user_summary = serializers.DictField(read_only=True)
    recent_snapshots = ScoreSnapshotListSerializer(many=True, read_only=True)
    trend_analysis = ScoreTrendSerializer(read_only=True)
    benchmarking_summary = serializers.DictField(read_only=True)
    completion_stats = CompletionStatisticsSerializer(read_only=True)
    system_metrics = serializers.DictField(read_only=True)


class AdminDashboardSerializer(serializers.Serializer):
    """Serializer for administrative dashboard data."""
    
    platform_overview = serializers.DictField(read_only=True)
    user_engagement = serializers.DictField(read_only=True)
    score_distributions = serializers.DictField(read_only=True)
    trend_summaries = serializers.DictField(read_only=True)
    benchmarking_insights = serializers.DictField(read_only=True)
    system_performance = serializers.DictField(read_only=True)
    recent_events = AnalyticsEventSerializer(many=True, read_only=True)