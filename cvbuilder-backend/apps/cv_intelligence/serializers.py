"""
Serializers for CV Intelligence API responses.
Ensures consistent data format for frontend integration.
"""
from rest_framework import serializers
from .models import CVAnalysis, ContentSuggestion, ValidationIssue


class CVAnalysisSerializer(serializers.ModelSerializer):
    """Serializer for CV analysis results."""
    
    score_breakdown = serializers.SerializerMethodField()
    priority_improvements = serializers.SerializerMethodField()
    
    class Meta:
        model = CVAnalysis
        fields = [
            'id', 'overall_score', 'grade', 'score_breakdown',
            'priority_improvements', 'analysis_data', 'created_at'
        ]
        read_only_fields = fields
    
    def get_score_breakdown(self, obj):
        """Get formatted score breakdown."""
        return {
            'completeness': {
                'score': obj.completeness_score,
                'max_score': 25,
                'percentage': round((obj.completeness_score / 25) * 100)
            },
            'quality': {
                'score': obj.quality_score,
                'max_score': 40,
                'percentage': round((obj.quality_score / 40) * 100)
            },
            'skills': {
                'score': obj.skills_score,
                'max_score': 20,
                'percentage': round((obj.skills_score / 20) * 100)
            },
            'format': {
                'score': obj.format_score,
                'max_score': 15,
                'percentage': round((obj.format_score / 15) * 100)
            }
        }
    
    def get_priority_improvements(self, obj):
        """Get top 3 priority improvements."""
        analysis_data = obj.analysis_data or {}
        return analysis_data.get('priority_improvements', [])[:3]


class ContentSuggestionSerializer(serializers.ModelSerializer):
    """Serializer for content suggestions."""
    
    section_display = serializers.CharField(source='get_section_type_display', read_only=True)
    suggestion_display = serializers.CharField(source='get_suggestion_type_display', read_only=True)
    
    class Meta:
        model = ContentSuggestion
        fields = [
            'id', 'section_type', 'section_display', 'suggestion_type', 
            'suggestion_display', 'original_content', 'suggested_content',
            'improvement_reason', 'applied', 'created_at'
        ]
        read_only_fields = fields


class ValidationIssueSerializer(serializers.ModelSerializer):
    """Serializer for validation issues."""
    
    issue_display = serializers.CharField(source='get_issue_type_display', read_only=True)
    severity_display = serializers.CharField(source='get_severity_display', read_only=True)
    
    class Meta:
        model = ValidationIssue
        fields = [
            'id', 'issue_type', 'issue_display', 'severity', 'severity_display',
            'section_type', 'description', 'suggestion', 'resolved', 'created_at'
        ]
        read_only_fields = fields


class CVScoreSummarySerializer(serializers.Serializer):
    """Serializer for CV score summary."""
    
    overall_score = serializers.IntegerField()
    grade = serializers.CharField()
    improvement_potential = serializers.IntegerField()
    last_analysis_date = serializers.DateTimeField()
    
    # Score breakdown
    completeness_percentage = serializers.IntegerField()
    quality_percentage = serializers.IntegerField()
    skills_percentage = serializers.IntegerField()
    format_percentage = serializers.IntegerField()
    
    # Quick stats
    total_issues = serializers.IntegerField()
    critical_issues = serializers.IntegerField()
    pending_suggestions = serializers.IntegerField()


class CVIntelligenceDashboardSerializer(serializers.Serializer):
    """Serializer for CV intelligence dashboard data."""
    
    # Current analysis
    current_analysis = CVAnalysisSerializer(allow_null=True)
    
    # Quick metrics
    overall_score = serializers.IntegerField(allow_null=True)
    grade = serializers.CharField(allow_null=True)
    improvement_potential = serializers.IntegerField(allow_null=True)
    
    # Issues and suggestions
    pending_issues = serializers.IntegerField()
    critical_issues = serializers.IntegerField()
    pending_suggestions = serializers.IntegerField()
    
    # Recent activity
    top_suggestions = ContentSuggestionSerializer(many=True)
    critical_issues_list = ValidationIssueSerializer(many=True)
    
    # Progress tracking
    last_analysis_date = serializers.DateTimeField(allow_null=True)
    analysis_available = serializers.BooleanField()


class CVAnalysisRequestSerializer(serializers.Serializer):
    """Serializer for CV analysis request."""
    
    include_suggestions = serializers.BooleanField(default=True)
    target_industry = serializers.CharField(required=False, allow_blank=True)
    analysis_type = serializers.ChoiceField(
        choices=[
            ('comprehensive', 'Comprehensive Analysis'),
            ('quick', 'Quick Score Only'),
            ('suggestions_only', 'Suggestions Only')
        ],
        default='comprehensive'
    )


class ApplySuggestionSerializer(serializers.Serializer):
    """Serializer for applying a suggestion."""
    
    feedback = serializers.CharField(required=False, allow_blank=True)
    rating = serializers.IntegerField(min_value=1, max_value=5, required=False)


class ResolveIssueSerializer(serializers.Serializer):
    """Serializer for resolving an issue."""
    
    resolution_notes = serializers.CharField(required=False, allow_blank=True)
    was_helpful = serializers.BooleanField(default=True)