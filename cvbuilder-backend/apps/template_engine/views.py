"""
Template Engine views for EduCV.
Comprehensive REST API endpoints for template management,
selection, rendering, and analytics.
"""
from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from django.db.models import Q, Count, Avg
from django.utils import timezone
from django.core.cache import cache
from django.shortcuts import get_object_or_404
import logging

from apps.core.responses import success_response, error_response
from apps.core.permissions import IsStudentUser, IsAdminUser
from .models import (
    Industry, Role, TemplateCategory, Template, SectionConfiguration,
    BrandingConfiguration, UserTemplatePreference, TemplateUsage,
    TemplatePerformanceMetric, TemplateRecommendation
)
from .serializers import (
    IndustrySerializer, RoleSerializer, TemplateCategorySerializer,
    TemplateListSerializer, TemplateDetailSerializer, SectionConfigurationSerializer,
    BrandingConfigurationSerializer, UserTemplatePreferenceSerializer,
    TemplateUsageSerializer, TemplatePerformanceMetricSerializer,
    TemplateRecommendationSerializer, TemplateRenderRequestSerializer,
    TemplateSearchSerializer, TemplateAnalyticsSerializer, BulkTemplateActionSerializer
)
from .permissions import (
    IsAdminOrReadOnly, IsTemplateOwnerOrAdmin, CanUseTemplate,
    CanManageOwnPreferences, CanViewTemplateAnalytics, CanManageTemplateCategories,
    CanBulkManageTemplates, CanViewSystemAnalytics, AdminOnlyPermission,
    StudentOnlyPermission, TemplateEnginePermissionMixin
)
from .services import (
    TemplateSelectionService, TemplateRenderingService, TemplateAnalyticsService,
    TemplateRecommendationService
)

logger = logging.getLogger(__name__)


class IndustryViewSet(viewsets.ModelViewSet):
    """ViewSet for managing industries."""
    
    queryset = Industry.objects.all()
    serializer_class = IndustrySerializer
    permission_classes = [CanManageTemplateCategories]
    lookup_field = 'slug'
    
    def get_queryset(self):
        """Filter active industries for non-admin users."""
        if self.request.user.is_staff or self.request.user.is_superuser:
            return Industry.objects.all()
        return Industry.objects.filter(is_active=True)
    
    def list(self, request, *args, **kwargs):
        """List all industries."""
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return success_response(
                data=serializer.data,
                message="Industries retrieved successfully"
            )
        except Exception as e:
            logger.error(f"Error listing industries: {e}")
            return error_response("Failed to retrieve industries")


class RoleViewSet(viewsets.ModelViewSet):
    """ViewSet for managing roles."""
    
    queryset = Role.objects.select_related('industry').all()
    serializer_class = RoleSerializer
    permission_classes = [CanManageTemplateCategories]
    lookup_field = 'slug'
    
    def get_queryset(self):
        """Filter active roles for non-admin users."""
        queryset = Role.objects.select_related('industry')
        
        if not (self.request.user.is_staff or self.request.user.is_superuser):
            queryset = queryset.filter(is_active=True, industry__is_active=True)
        
        # Filter by industry if provided
        industry_slug = self.request.query_params.get('industry')
        if industry_slug:
            queryset = queryset.filter(industry__slug=industry_slug)
        
        return queryset
    
    def list(self, request, *args, **kwargs):
        """List roles with optional industry filtering."""
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return success_response(
                data=serializer.data,
                message="Roles retrieved successfully"
            )
        except Exception as e:
            logger.error(f"Error listing roles: {e}")
            return error_response("Failed to retrieve roles")


class TemplateCategoryViewSet(viewsets.ModelViewSet):
    """ViewSet for managing template categories."""
    
    queryset = TemplateCategory.objects.all()
    serializer_class = TemplateCategorySerializer
    permission_classes = [CanManageTemplateCategories]
    lookup_field = 'slug'
    
    def get_queryset(self):
        """Filter active categories for non-admin users."""
        if self.request.user.is_staff or self.request.user.is_superuser:
            return TemplateCategory.objects.all()
        return TemplateCategory.objects.filter(is_active=True)
    
    def list(self, request, *args, **kwargs):
        """List all template categories."""
        try:
            queryset = self.get_queryset()
            serializer = self.get_serializer(queryset, many=True)
            return success_response(
                data=serializer.data,
                message="Template categories retrieved successfully"
            )
        except Exception as e:
            logger.error(f"Error listing template categories: {e}")
            return error_response("Failed to retrieve template categories")


class TemplateViewSet(TemplateEnginePermissionMixin, viewsets.ModelViewSet):
    """ViewSet for managing templates."""
    
    queryset = Template.objects.select_related('category').prefetch_related(
        'industries', 'roles', 'sections', 'branding'
    ).all()
    lookup_field = 'slug'
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action in ['list', 'recommendations', 'popular']:
            return TemplateListSerializer
        return TemplateDetailSerializer
    
    def get_queryset(self):
        """Filter templates based on user permissions."""
        queryset = Template.objects.select_related('category').prefetch_related(
            'industries', 'roles', 'sections', 'branding'
        )
        
        # Non-admin users can only see active templates
        if not (self.request.user.is_staff or self.request.user.is_superuser):
            queryset = queryset.filter(status=Template.Status.ACTIVE)
        
        return queryset
    
    def list(self, request, *args, **kwargs):
        """List templates with filtering and search."""
        try:
            queryset = self.get_queryset()
            
            # Apply filters
            category = request.query_params.get('category')
            if category:
                queryset = queryset.filter(category__slug=category)
            
            industry = request.query_params.get('industry')
            if industry:
                queryset = queryset.filter(industries__slug=industry)
            
            role = request.query_params.get('role')
            if role:
                queryset = queryset.filter(roles__slug=role)
            
            layout_type = request.query_params.get('layout_type')
            if layout_type:
                queryset = queryset.filter(layout_type=layout_type)
            
            is_premium = request.query_params.get('is_premium')
            if is_premium is not None:
                queryset = queryset.filter(is_premium=is_premium.lower() == 'true')
            
            # Search
            search = request.query_params.get('search')
            if search:
                queryset = queryset.filter(
                    Q(name__icontains=search) |
                    Q(description__icontains=search) |
                    Q(category__name__icontains=search)
                )
            
            # Pagination
            page = self.paginate_queryset(queryset)
            if page is not None:
                serializer = self.get_serializer(page, many=True)
                return self.get_paginated_response(serializer.data)
            
            serializer = self.get_serializer(queryset, many=True)
            return success_response(
                data=serializer.data,
                message="Templates retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error listing templates: {e}")
            return error_response("Failed to retrieve templates")
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a single template."""
        try:
            instance = self.get_object()
            serializer = self.get_serializer(instance)
            return success_response(
                data=serializer.data,
                message="Template retrieved successfully"
            )
        except Exception as e:
            logger.error(f"Error retrieving template: {e}")
            return error_response("Template not found")
    
    @action(detail=True, methods=['post'], permission_classes=[CanUseTemplate])
    def preview(self, request, slug=None):
        """Generate template preview."""
        try:
            template = self.get_object()
            
            # Track usage
            TemplateAnalyticsService.track_template_usage(
                template=template,
                user=request.user,
                action=TemplateUsage.Action.PREVIEW,
                context_data={
                    'user_agent': request.META.get('HTTP_USER_AGENT', ''),
                    'ip_address': request.META.get('REMOTE_ADDR'),
                }
            )
            
            # Generate preview
            preview_html = TemplateRenderingService.get_template_preview(template)
            
            return success_response(
                data={'preview_html': preview_html},
                message="Template preview generated successfully"
            )
            
        except Exception as e:
            logger.error(f"Error generating template preview: {e}")
            return error_response("Failed to generate template preview")
    
    @action(detail=True, methods=['post'], permission_classes=[CanUseTemplate])
    def render(self, request, slug=None):
        """Render template with user's CV data."""
        try:
            template = self.get_object()
            
            # Validate request data
            serializer = TemplateRenderRequestSerializer(data=request.data)
            if not serializer.is_valid():
                return error_response(
                    message="Invalid request data",
                    details=serializer.errors
                )
            
            # Get user's CV profile
            cv_profile = getattr(request.user, 'cv_profile', None)
            if not cv_profile:
                return error_response("CV profile not found. Please complete your CV first.")
            
            # Render template
            custom_branding = serializer.validated_data.get('custom_branding', {})
            rendered_html, metadata = TemplateRenderingService.render_template(
                template=template,
                cv_profile=cv_profile,
                custom_branding=custom_branding
            )
            
            # Track usage
            TemplateAnalyticsService.track_template_usage(
                template=template,
                user=request.user,
                action=TemplateUsage.Action.GENERATE,
                context_data={
                    'user_agent': request.META.get('HTTP_USER_AGENT', ''),
                    'ip_address': request.META.get('REMOTE_ADDR'),
                    'render_time_ms': metadata.get('render_time_ms'),
                }
            )
            
            return success_response(
                data={
                    'rendered_html': rendered_html,
                    'metadata': metadata
                },
                message="Template rendered successfully"
            )
            
        except Exception as e:
            logger.error(f"Error rendering template: {e}")
            return error_response("Failed to render template")
    
    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated])
    def favorite(self, request, slug=None):
        """Add template to user's favorites."""
        try:
            template = self.get_object()
            
            # Get or create user preferences
            preferences, created = UserTemplatePreference.objects.get_or_create(
                user=request.user
            )
            
            # Add to favorites
            preferences.favorite_templates.add(template)
            
            # Track usage
            TemplateAnalyticsService.track_template_usage(
                template=template,
                user=request.user,
                action=TemplateUsage.Action.FAVORITE
            )
            
            return success_response(
                message="Template added to favorites successfully"
            )
            
        except Exception as e:
            logger.error(f"Error adding template to favorites: {e}")
            return error_response("Failed to add template to favorites")
    
    @action(detail=True, methods=['delete'], permission_classes=[permissions.IsAuthenticated])
    def unfavorite(self, request, slug=None):
        """Remove template from user's favorites."""
        try:
            template = self.get_object()
            
            # Get user preferences
            preferences = UserTemplatePreference.objects.filter(user=request.user).first()
            if preferences:
                preferences.favorite_templates.remove(template)
            
            # Track usage
            TemplateAnalyticsService.track_template_usage(
                template=template,
                user=request.user,
                action=TemplateUsage.Action.UNFAVORITE
            )
            
            return success_response(
                message="Template removed from favorites successfully"
            )
            
        except Exception as e:
            logger.error(f"Error removing template from favorites: {e}")
            return error_response("Failed to remove template from favorites")
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def recommendations(self, request):
        """Get personalized template recommendations."""
        try:
            limit = int(request.query_params.get('limit', 10))
            templates = TemplateSelectionService.get_recommended_templates(
                user=request.user,
                limit=limit
            )
            
            serializer = self.get_serializer(templates, many=True)
            return success_response(
                data=serializer.data,
                message="Template recommendations retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error getting template recommendations: {e}")
            return error_response("Failed to get template recommendations")
    
    @action(detail=False, methods=['get'], permission_classes=[permissions.IsAuthenticated])
    def popular(self, request):
        """Get popular templates."""
        try:
            limit = int(request.query_params.get('limit', 10))
            days = int(request.query_params.get('days', 30))
            
            popular_data = TemplateAnalyticsService.get_popular_templates(
                limit=limit,
                days=days
            )
            
            return success_response(
                data=popular_data,
                message="Popular templates retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error getting popular templates: {e}")
            return error_response("Failed to get popular templates")
    
    @action(detail=False, methods=['post'], permission_classes=[CanBulkManageTemplates])
    def bulk_action(self, request):
        """Perform bulk actions on templates."""
        try:
            serializer = BulkTemplateActionSerializer(data=request.data)
            if not serializer.is_valid():
                return error_response(
                    message="Invalid request data",
                    details=serializer.errors
                )
            
            template_ids = serializer.validated_data['template_ids']
            action = serializer.validated_data['action']
            
            templates = Template.objects.filter(id__in=template_ids)
            
            if action == 'activate':
                templates.update(status=Template.Status.ACTIVE)
            elif action == 'deactivate':
                templates.update(status=Template.Status.DEPRECATED)
            elif action == 'archive':
                templates.update(status=Template.Status.ARCHIVED)
            elif action == 'delete':
                templates.delete()
            
            return success_response(
                message=f"Bulk {action} completed successfully for {len(template_ids)} templates"
            )
            
        except Exception as e:
            logger.error(f"Error performing bulk action: {e}")
            return error_response("Failed to perform bulk action")


class UserTemplatePreferenceViewSet(viewsets.ModelViewSet):
    """ViewSet for managing user template preferences."""
    
    serializer_class = UserTemplatePreferenceSerializer
    permission_classes = [CanManageOwnPreferences]
    
    def get_queryset(self):
        """Return only current user's preferences."""
        return UserTemplatePreference.objects.filter(user=self.request.user)
    
    def get_object(self):
        """Get or create user preferences."""
        preferences, created = UserTemplatePreference.objects.get_or_create(
            user=self.request.user
        )
        return preferences
    
    def list(self, request, *args, **kwargs):
        """Get user's template preferences."""
        try:
            preferences = self.get_object()
            serializer = self.get_serializer(preferences)
            return success_response(
                data=serializer.data,
                message="Template preferences retrieved successfully"
            )
        except Exception as e:
            logger.error(f"Error retrieving template preferences: {e}")
            return error_response("Failed to retrieve template preferences")
    
    def update(self, request, *args, **kwargs):
        """Update user's template preferences."""
        try:
            preferences = self.get_object()
            serializer = self.get_serializer(preferences, data=request.data, partial=True)
            
            if serializer.is_valid():
                serializer.save()
                return success_response(
                    data=serializer.data,
                    message="Template preferences updated successfully"
                )
            
            return error_response(
                message="Invalid preference data",
                details=serializer.errors
            )
            
        except Exception as e:
            logger.error(f"Error updating template preferences: {e}")
            return error_response("Failed to update template preferences")


class TemplateAnalyticsViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for template analytics and metrics."""
    
    permission_classes = [CanViewTemplateAnalytics]
    
    @action(detail=False, methods=['get'], permission_classes=[CanViewSystemAnalytics])
    def overview(self, request):
        """Get system-wide template analytics overview."""
        try:
            # Get basic statistics
            total_templates = Template.objects.filter(status=Template.Status.ACTIVE).count()
            total_usage = TemplateUsage.objects.count()
            total_users = TemplateUsage.objects.values('user').distinct().count()
            
            # Get popular templates
            popular_templates = TemplateAnalyticsService.get_popular_templates(limit=5)
            
            data = {
                'total_templates': total_templates,
                'total_usage': total_usage,
                'total_users': total_users,
                'popular_templates': popular_templates,
            }
            
            return success_response(
                data=data,
                message="Analytics overview retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error getting analytics overview: {e}")
            return error_response("Failed to get analytics overview")
    
    @action(detail=True, methods=['get'])
    def template_metrics(self, request, pk=None):
        """Get metrics for a specific template."""
        try:
            template = get_object_or_404(Template, pk=pk)
            days = int(request.query_params.get('days', 30))
            
            metrics = TemplateAnalyticsService.get_template_performance_metrics(
                template=template,
                days=days
            )
            
            return success_response(
                data=metrics,
                message="Template metrics retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error getting template metrics: {e}")
            return error_response("Failed to get template metrics")


class TemplateRecommendationViewSet(viewsets.ReadOnlyModelViewSet):
    """ViewSet for template recommendations."""
    
    serializer_class = TemplateRecommendationSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        """Return recommendations for current user."""
        return TemplateRecommendation.objects.filter(
            user=self.request.user
        ).select_related('template').order_by('-confidence_score', '-created_at')
    
    def list(self, request, *args, **kwargs):
        """Get user's template recommendations."""
        try:
            # Generate fresh recommendations if needed
            existing_count = self.get_queryset().count()
            if existing_count < 5:
                TemplateRecommendationService.generate_recommendations(
                    user=request.user,
                    limit=10
                )
            
            queryset = self.get_queryset()[:10]  # Limit to top 10
            serializer = self.get_serializer(queryset, many=True)
            
            return success_response(
                data=serializer.data,
                message="Template recommendations retrieved successfully"
            )
            
        except Exception as e:
            logger.error(f"Error getting template recommendations: {e}")
            return error_response("Failed to get template recommendations")
    
    @action(detail=True, methods=['patch'])
    def mark_viewed(self, request, pk=None):
        """Mark recommendation as viewed."""
        try:
            recommendation = self.get_object()
            recommendation.is_viewed = True
            recommendation.save(update_fields=['is_viewed', 'updated_at'])
            
            return success_response(
                message="Recommendation marked as viewed"
            )
            
        except Exception as e:
            logger.error(f"Error marking recommendation as viewed: {e}")
            return error_response("Failed to update recommendation")
    
    @action(detail=True, methods=['patch'])
    def mark_clicked(self, request, pk=None):
        """Mark recommendation as clicked."""
        try:
            recommendation = self.get_object()
            recommendation.is_clicked = True
            recommendation.save(update_fields=['is_clicked', 'updated_at'])
            
            return success_response(
                message="Recommendation marked as clicked"
            )
            
        except Exception as e:
            logger.error(f"Error marking recommendation as clicked: {e}")
            return error_response("Failed to update recommendation")