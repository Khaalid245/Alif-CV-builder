"""
Template Engine serializers for EduCV.
Comprehensive serializers for all template-related API endpoints
with proper validation and nested relationships.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    Industry, Role, TemplateCategory, Template, SectionConfiguration,
    BrandingConfiguration, UserTemplatePreference, TemplateUsage,
    TemplatePerformanceMetric, TemplateRecommendation
)

User = get_user_model()


class IndustrySerializer(serializers.ModelSerializer):
    """Serializer for Industry model."""
    
    class Meta:
        model = Industry
        fields = ['id', 'name', 'slug', 'description', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


class RoleSerializer(serializers.ModelSerializer):
    """Serializer for Role model."""
    
    industry = IndustrySerializer(read_only=True)
    industry_id = serializers.UUIDField(write_only=True)
    
    class Meta:
        model = Role
        fields = ['id', 'name', 'slug', 'industry', 'industry_id', 'description', 'is_active', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']


class TemplateCategorySerializer(serializers.ModelSerializer):
    """Serializer for TemplateCategory model."""
    
    templates_count = serializers.SerializerMethodField()
    
    class Meta:
        model = TemplateCategory
        fields = ['id', 'name', 'slug', 'description', 'is_active', 'templates_count', 'created_at', 'updated_at']
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def get_templates_count(self, obj):
        return obj.templates.filter(status=Template.Status.ACTIVE).count()


class SectionConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for SectionConfiguration model."""
    
    class Meta:
        model = SectionConfiguration
        fields = [
            'id', 'section_type', 'display_name', 'is_required', 'is_visible',
            'order', 'css_classes', 'custom_html', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class BrandingConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for BrandingConfiguration model."""
    
    class Meta:
        model = BrandingConfiguration
        fields = [
            'id', 'primary_color', 'secondary_color', 'accent_color', 'text_color',
            'background_color', 'font_family', 'heading_font', 'font_size_base',
            'margin_top', 'margin_bottom', 'section_spacing', 'custom_css',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_primary_color(self, value):
        """Validate hex color format."""
        if not value.startswith('#') or len(value) != 7:
            raise serializers.ValidationError("Color must be in hex format (#RRGGBB)")
        return value
    
    def validate_secondary_color(self, value):
        return self.validate_primary_color(value)
    
    def validate_accent_color(self, value):
        return self.validate_primary_color(value)
    
    def validate_text_color(self, value):
        return self.validate_primary_color(value)
    
    def validate_background_color(self, value):
        return self.validate_primary_color(value)


class TemplateListSerializer(serializers.ModelSerializer):
    """Lightweight serializer for template lists."""
    
    category = TemplateCategorySerializer(read_only=True)
    industries = IndustrySerializer(many=True, read_only=True)
    roles = RoleSerializer(many=True, read_only=True)
    is_favorited = serializers.SerializerMethodField()
    
    class Meta:
        model = Template
        fields = [
            'id', 'name', 'slug', 'description', 'category', 'industries', 'roles',
            'layout_type', 'version', 'status', 'is_premium', 'usage_count',
            'is_favorited', 'created_at', 'updated_at', 'published_at'
        ]
        read_only_fields = ['id', 'usage_count', 'created_at', 'updated_at', 'published_at']
    
    def get_is_favorited(self, obj):
        """Check if template is favorited by current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.favorited_by_users.filter(id=request.user.id).exists()
        return False


class TemplateDetailSerializer(serializers.ModelSerializer):
    """Detailed serializer for template CRUD operations."""
    
    category = TemplateCategorySerializer(read_only=True)
    category_id = serializers.UUIDField(write_only=True)
    industries = IndustrySerializer(many=True, read_only=True)
    industry_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False
    )
    roles = RoleSerializer(many=True, read_only=True)
    role_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False
    )
    sections = SectionConfigurationSerializer(many=True, read_only=True)
    branding = BrandingConfigurationSerializer(read_only=True)
    is_favorited = serializers.SerializerMethodField()
    
    class Meta:
        model = Template
        fields = [
            'id', 'name', 'slug', 'description', 'category', 'category_id',
            'industries', 'industry_ids', 'roles', 'role_ids', 'layout_type',
            'html_template', 'css_styles', 'version', 'parent_template',
            'status', 'is_premium', 'usage_count', 'sections', 'branding',
            'is_favorited', 'created_at', 'updated_at', 'published_at'
        ]
        read_only_fields = ['id', 'usage_count', 'created_at', 'updated_at', 'published_at']
    
    def get_is_favorited(self, obj):
        """Check if template is favorited by current user."""
        request = self.context.get('request')
        if request and request.user.is_authenticated:
            return obj.favorited_by_users.filter(id=request.user.id).exists()
        return False
    
    def validate_html_template(self, value):
        """Validate HTML template content."""
        from .services import TemplateRenderingService
        
        is_valid, errors = TemplateRenderingService.validate_template_html(value)
        if not is_valid:
            raise serializers.ValidationError(f"Invalid template HTML: {'; '.join(errors)}")
        return value
    
    def create(self, validated_data):
        """Create template with relationships."""
        industry_ids = validated_data.pop('industry_ids', [])
        role_ids = validated_data.pop('role_ids', [])
        
        template = Template.objects.create(**validated_data)
        
        if industry_ids:
            template.industries.set(Industry.objects.filter(id__in=industry_ids))
        if role_ids:
            template.roles.set(Role.objects.filter(id__in=role_ids))
        
        return template
    
    def update(self, instance, validated_data):
        """Update template with relationships."""
        industry_ids = validated_data.pop('industry_ids', None)
        role_ids = validated_data.pop('role_ids', None)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if industry_ids is not None:
            instance.industries.set(Industry.objects.filter(id__in=industry_ids))
        if role_ids is not None:
            instance.roles.set(Role.objects.filter(id__in=role_ids))
        
        return instance


class UserTemplatePreferenceSerializer(serializers.ModelSerializer):
    """Serializer for UserTemplatePreference model."""
    
    preferred_industries = IndustrySerializer(many=True, read_only=True)
    preferred_industry_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False
    )
    preferred_roles = RoleSerializer(many=True, read_only=True)
    preferred_role_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False
    )
    favorite_templates = TemplateListSerializer(many=True, read_only=True)
    favorite_template_ids = serializers.ListField(
        child=serializers.UUIDField(),
        write_only=True,
        required=False
    )
    default_template = TemplateListSerializer(read_only=True)
    default_template_id = serializers.UUIDField(write_only=True, required=False, allow_null=True)
    
    class Meta:
        model = UserTemplatePreference
        fields = [
            'id', 'preferred_industries', 'preferred_industry_ids',
            'preferred_roles', 'preferred_role_ids', 'favorite_templates',
            'favorite_template_ids', 'default_template', 'default_template_id',
            'section_order_preferences', 'hidden_sections',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def update(self, instance, validated_data):
        """Update preferences with relationships."""
        preferred_industry_ids = validated_data.pop('preferred_industry_ids', None)
        preferred_role_ids = validated_data.pop('preferred_role_ids', None)
        favorite_template_ids = validated_data.pop('favorite_template_ids', None)
        
        for attr, value in validated_data.items():
            setattr(instance, attr, value)
        instance.save()
        
        if preferred_industry_ids is not None:
            instance.preferred_industries.set(Industry.objects.filter(id__in=preferred_industry_ids))
        if preferred_role_ids is not None:
            instance.preferred_roles.set(Role.objects.filter(id__in=preferred_role_ids))
        if favorite_template_ids is not None:
            instance.favorite_templates.set(Template.objects.filter(id__in=favorite_template_ids))
        
        return instance


class TemplateUsageSerializer(serializers.ModelSerializer):
    """Serializer for TemplateUsage model."""
    
    template = TemplateListSerializer(read_only=True)
    user_email = serializers.CharField(source='user.email', read_only=True)
    
    class Meta:
        model = TemplateUsage
        fields = [
            'id', 'template', 'user_email', 'action', 'user_agent',
            'ip_address', 'session_id', 'render_time_ms', 'file_size_bytes',
            'created_at'
        ]
        read_only_fields = ['id', 'created_at']


class TemplatePerformanceMetricSerializer(serializers.ModelSerializer):
    """Serializer for TemplatePerformanceMetric model."""
    
    template_name = serializers.CharField(source='template.name', read_only=True)
    
    class Meta:
        model = TemplatePerformanceMetric
        fields = [
            'id', 'template_name', 'date', 'total_previews', 'total_generations',
            'total_downloads', 'unique_users', 'avg_render_time_ms',
            'avg_file_size_bytes', 'favorite_count', 'conversion_rate',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class TemplateRecommendationSerializer(serializers.ModelSerializer):
    """Serializer for TemplateRecommendation model."""
    
    template = TemplateListSerializer(read_only=True)
    
    class Meta:
        model = TemplateRecommendation
        fields = [
            'id', 'template', 'recommendation_type', 'confidence_score',
            'reasoning', 'algorithm_version', 'context_data',
            'is_viewed', 'is_clicked', 'is_used', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class TemplateRenderRequestSerializer(serializers.Serializer):
    """Serializer for template rendering requests."""
    
    template_id = serializers.UUIDField()
    custom_branding = serializers.JSONField(required=False, default=dict)
    
    def validate_template_id(self, value):
        """Validate template exists and is active."""
        try:
            template = Template.objects.get(id=value, status=Template.Status.ACTIVE)
            return value
        except Template.DoesNotExist:
            raise serializers.ValidationError("Template not found or not active")
    
    def validate_custom_branding(self, value):
        """Validate custom branding data."""
        if not isinstance(value, dict):
            raise serializers.ValidationError("Custom branding must be a JSON object")
        
        # Validate color fields if present
        color_fields = ['primary_color', 'secondary_color', 'accent_color', 'text_color', 'background_color']
        for field in color_fields:
            if field in value:
                color = value[field]
                if not isinstance(color, str) or not color.startswith('#') or len(color) != 7:
                    raise serializers.ValidationError(f"{field} must be a valid hex color (#RRGGBB)")
        
        return value


class TemplateSearchSerializer(serializers.Serializer):
    """Serializer for template search requests."""
    
    query = serializers.CharField(required=False, allow_blank=True, max_length=100)
    category = serializers.SlugField(required=False)
    industry = serializers.SlugField(required=False)
    role = serializers.SlugField(required=False)
    layout_type = serializers.ChoiceField(choices=Template.Layout.choices, required=False)
    is_premium = serializers.BooleanField(required=False)
    limit = serializers.IntegerField(min_value=1, max_value=50, default=20)


class TemplateAnalyticsSerializer(serializers.Serializer):
    """Serializer for template analytics requests."""
    
    template_id = serializers.UUIDField(required=False)
    days = serializers.IntegerField(min_value=1, max_value=365, default=30)
    metric_type = serializers.ChoiceField(
        choices=['usage', 'performance', 'popular', 'conversion'],
        default='usage'
    )


class BulkTemplateActionSerializer(serializers.Serializer):
    """Serializer for bulk template actions."""
    
    template_ids = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1,
        max_length=50
    )
    action = serializers.ChoiceField(
        choices=['activate', 'deactivate', 'archive', 'delete']
    )
    
    def validate_template_ids(self, value):
        """Validate all template IDs exist."""
        existing_count = Template.objects.filter(id__in=value).count()
        if existing_count != len(value):
            raise serializers.ValidationError("Some template IDs do not exist")
        return value