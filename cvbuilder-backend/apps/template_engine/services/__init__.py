"""
Template Engine services for EduCV.
Enterprise-grade business logic for template management, selection,
rendering, and performance analytics.
"""
import json
import time
from typing import Dict, List, Optional, Tuple, Any
from datetime import datetime, timedelta
from django.db import transaction
from django.db.models import Q, Count, Avg, F, Sum
from django.utils import timezone
from django.core.cache import cache
from django.template import Template as DjangoTemplate, Context
from django.template.loader import get_template
from django.conf import settings
import logging

from ..models import (
    Template, Industry, Role, TemplateCategory, SectionConfiguration,
    BrandingConfiguration, UserTemplatePreference, TemplateUsage,
    TemplatePerformanceMetric, TemplateRecommendation
)
from apps.cv.models import CVProfile

logger = logging.getLogger(__name__)


class TemplateSelectionService:
    """Service for intelligent template selection and recommendations."""

    @staticmethod
    def get_recommended_templates(user, limit: int = 10) -> List[Template]:
        """Get personalized template recommendations for a user."""
        cache_key = f"template_recommendations_{user.id}_{limit}"
        cached_result = cache.get(cache_key)
        if cached_result:
            return cached_result

        try:
            # Get user preferences
            preferences = UserTemplatePreference.objects.filter(user=user).first()
            
            # Base query for active templates
            base_query = Template.objects.filter(status=Template.Status.ACTIVE)
            
            # Industry-based recommendations
            industry_templates = []
            if preferences and preferences.preferred_industries.exists():
                industry_templates = list(base_query.filter(
                    industries__in=preferences.preferred_industries.all()
                ).distinct()[:limit//2])
            
            # Role-based recommendations
            role_templates = []
            if preferences and preferences.preferred_roles.exists():
                role_templates = list(base_query.filter(
                    roles__in=preferences.preferred_roles.all()
                ).distinct()[:limit//2])
            
            # Popular templates (fallback)
            popular_templates = list(base_query.order_by('-usage_count')[:limit])
            
            # Combine and deduplicate
            recommended = []
            seen_ids = set()
            
            for template_list in [industry_templates, role_templates, popular_templates]:
                for template in template_list:
                    if template.id not in seen_ids and len(recommended) < limit:
                        recommended.append(template)
                        seen_ids.add(template.id)
            
            # Cache for 1 hour
            cache.set(cache_key, recommended, 3600)
            return recommended
            
        except Exception as e:
            logger.error(f"Error getting template recommendations: {e}")
            return list(Template.objects.filter(status=Template.Status.ACTIVE)[:limit])

    @staticmethod
    def get_templates_by_industry(industry_slug: str, limit: int = 20) -> List[Template]:
        """Get templates filtered by industry."""
        try:
            return list(Template.objects.filter(
                status=Template.Status.ACTIVE,
                industries__slug=industry_slug
            ).select_related('category').prefetch_related('industries', 'roles')[:limit])
        except Exception as e:
            logger.error(f"Error getting templates by industry {industry_slug}: {e}")
            return []

    @staticmethod
    def get_templates_by_role(role_slug: str, limit: int = 20) -> List[Template]:
        """Get templates filtered by role."""
        try:
            return list(Template.objects.filter(
                status=Template.Status.ACTIVE,
                roles__slug=role_slug
            ).select_related('category').prefetch_related('industries', 'roles')[:limit])
        except Exception as e:
            logger.error(f"Error getting templates by role {role_slug}: {e}")
            return []

    @staticmethod
    def search_templates(query: str, filters: Dict[str, Any] = None) -> List[Template]:
        """Search templates with optional filters."""
        try:
            base_query = Template.objects.filter(status=Template.Status.ACTIVE)
            
            # Text search
            if query:
                base_query = base_query.filter(
                    Q(name__icontains=query) |
                    Q(description__icontains=query) |
                    Q(category__name__icontains=query)
                )
            
            # Apply filters
            if filters:
                if 'category' in filters:
                    base_query = base_query.filter(category__slug=filters['category'])
                if 'layout_type' in filters:
                    base_query = base_query.filter(layout_type=filters['layout_type'])
                if 'is_premium' in filters:
                    base_query = base_query.filter(is_premium=filters['is_premium'])
            
            return list(base_query.select_related('category')
                       .prefetch_related('industries', 'roles')[:50])
                       
        except Exception as e:
            logger.error(f"Error searching templates: {e}")
            return []


class TemplateRenderingService:
    """Service for template rendering and customization."""

    @staticmethod
    def render_template(template: Template, cv_profile: CVProfile, 
                       custom_branding: Dict[str, Any] = None) -> Tuple[str, Dict[str, Any]]:
        """Render a template with CV data and optional custom branding."""
        start_time = time.time()
        
        try:
            # Get template sections in order
            sections = SectionConfiguration.objects.filter(
                template=template,
                is_visible=True
            ).order_by('order')
            
            # Get branding configuration
            branding = template.branding if hasattr(template, 'branding') else None
            if custom_branding and branding:
                # Apply custom branding overrides
                for key, value in custom_branding.items():
                    if hasattr(branding, key):
                        setattr(branding, key, value)
            
            # Prepare context data
            context_data = {
                'cv': cv_profile,
                'template': template,
                'sections': sections,
                'branding': branding,
                'user': cv_profile.student,
                'generated_at': timezone.now(),
            }
            
            # Render HTML template
            django_template = DjangoTemplate(template.html_template)
            context = Context(context_data)
            rendered_html = django_template.render(context)
            
            # Calculate render time
            render_time_ms = int((time.time() - start_time) * 1000)
            
            # Prepare metadata
            metadata = {
                'render_time_ms': render_time_ms,
                'template_id': str(template.id),
                'template_version': template.version,
                'sections_count': sections.count(),
                'has_custom_branding': bool(custom_branding),
            }
            
            return rendered_html, metadata
            
        except Exception as e:
            logger.error(f"Error rendering template {template.id}: {e}")
            raise

    @staticmethod
    def get_template_preview(template: Template) -> str:
        """Generate a preview of the template with sample data."""
        try:
            # Create sample CV data for preview
            sample_context = {
                'cv': {
                    'student': {'first_name': 'John', 'last_name': 'Doe', 'email': 'john.doe@example.com'},
                    'phone': '+1 (555) 123-4567',
                    'address': '123 Main St',
                    'city': 'New York',
                    'country': 'USA',
                    'summary': 'Experienced professional with expertise in multiple domains.',
                    'linkedin': 'https://linkedin.com/in/johndoe',
                    'github': 'https://github.com/johndoe',
                },
                'template': template,
                'sections': SectionConfiguration.objects.filter(template=template, is_visible=True).order_by('order'),
                'branding': getattr(template, 'branding', None),
                'is_preview': True,
            }
            
            django_template = DjangoTemplate(template.html_template)
            context = Context(sample_context)
            return django_template.render(context)
            
        except Exception as e:
            logger.error(f"Error generating template preview {template.id}: {e}")
            return f"<div class='error'>Preview unavailable: {str(e)}</div>"

    @staticmethod
    def validate_template_html(html_content: str) -> Tuple[bool, List[str]]:
        """Validate template HTML for security and correctness."""
        errors = []
        
        try:
            # Basic HTML validation
            django_template = DjangoTemplate(html_content)
            
            # Check for required template variables
            required_vars = ['cv', 'template', 'sections']
            for var in required_vars:
                if f'{{{{{ var }' not in html_content:
                    errors.append(f"Missing required template variable: {var}")
            
            # Security checks
            dangerous_tags = ['<script', '<iframe', '<object', '<embed']
            for tag in dangerous_tags:
                if tag.lower() in html_content.lower():
                    errors.append(f"Dangerous HTML tag detected: {tag}")
            
            return len(errors) == 0, errors
            
        except Exception as e:
            errors.append(f"Template syntax error: {str(e)}")
            return False, errors


class TemplateAnalyticsService:
    """Service for template performance analytics and insights."""

    @staticmethod
    def track_template_usage(template: Template, user, action: str, 
                           context_data: Dict[str, Any] = None) -> TemplateUsage:
        """Track template usage for analytics."""
        try:
            usage_data = {
                'template': template,
                'user': user,
                'action': action,
            }
            
            if context_data:
                usage_data.update({
                    'user_agent': context_data.get('user_agent', ''),
                    'ip_address': context_data.get('ip_address'),
                    'session_id': context_data.get('session_id', ''),
                    'render_time_ms': context_data.get('render_time_ms'),
                    'file_size_bytes': context_data.get('file_size_bytes'),
                })
            
            usage = TemplateUsage.objects.create(**usage_data)
            
            # Update template usage count for popular templates
            if action == TemplateUsage.Action.GENERATE:
                Template.objects.filter(id=template.id).update(usage_count=F('usage_count') + 1)
            
            return usage
            
        except Exception as e:
            logger.error(f"Error tracking template usage: {e}")
            raise

    @staticmethod
    def get_template_performance_metrics(template: Template, 
                                       days: int = 30) -> Dict[str, Any]:
        """Get performance metrics for a template."""
        try:
            end_date = timezone.now().date()
            start_date = end_date - timedelta(days=days)
            
            # Get usage statistics
            usage_stats = TemplateUsage.objects.filter(
                template=template,
                created_at__date__gte=start_date
            ).aggregate(
                total_previews=Count('id', filter=Q(action=TemplateUsage.Action.PREVIEW)),
                total_generations=Count('id', filter=Q(action=TemplateUsage.Action.GENERATE)),
                total_downloads=Count('id', filter=Q(action=TemplateUsage.Action.DOWNLOAD)),
                unique_users=Count('user', distinct=True),
                avg_render_time=Avg('render_time_ms'),
                avg_file_size=Avg('file_size_bytes'),
            )
            
            # Calculate conversion rate
            previews = usage_stats['total_previews'] or 0
            generations = usage_stats['total_generations'] or 0
            conversion_rate = (generations / previews * 100) if previews > 0 else 0
            
            # Get daily metrics
            daily_metrics = TemplatePerformanceMetric.objects.filter(
                template=template,
                date__gte=start_date
            ).order_by('date')
            
            return {
                'template_id': str(template.id),
                'template_name': template.name,
                'period_days': days,
                'usage_stats': usage_stats,
                'conversion_rate': round(conversion_rate, 2),
                'daily_metrics': list(daily_metrics.values()),
                'total_favorites': template.favorited_by_users.count(),
            }
            
        except Exception as e:
            logger.error(f"Error getting template performance metrics: {e}")
            return {}

    @staticmethod
    def aggregate_daily_metrics(date: datetime.date = None) -> None:
        """Aggregate daily performance metrics for all templates."""
        if not date:
            date = timezone.now().date() - timedelta(days=1)
        
        try:
            with transaction.atomic():
                # Get all active templates
                templates = Template.objects.filter(status=Template.Status.ACTIVE)
                
                for template in templates:
                    # Calculate metrics for the date
                    usage_data = TemplateUsage.objects.filter(
                        template=template,
                        created_at__date=date
                    ).aggregate(
                        total_previews=Count('id', filter=Q(action=TemplateUsage.Action.PREVIEW)),
                        total_generations=Count('id', filter=Q(action=TemplateUsage.Action.GENERATE)),
                        total_downloads=Count('id', filter=Q(action=TemplateUsage.Action.DOWNLOAD)),
                        unique_users=Count('user', distinct=True),
                        avg_render_time=Avg('render_time_ms'),
                        avg_file_size=Avg('file_size_bytes'),
                    )
                    
                    # Calculate conversion rate
                    previews = usage_data['total_previews'] or 0
                    generations = usage_data['total_generations'] or 0
                    conversion_rate = (generations / previews) if previews > 0 else 0
                    
                    # Get favorite count
                    favorite_count = template.favorited_by_users.count()
                    
                    # Create or update metric
                    TemplatePerformanceMetric.objects.update_or_create(
                        template=template,
                        date=date,
                        defaults={
                            'total_previews': usage_data['total_previews'] or 0,
                            'total_generations': usage_data['total_generations'] or 0,
                            'total_downloads': usage_data['total_downloads'] or 0,
                            'unique_users': usage_data['unique_users'] or 0,
                            'avg_render_time_ms': usage_data['avg_render_time'],
                            'avg_file_size_bytes': usage_data['avg_file_size'],
                            'favorite_count': favorite_count,
                            'conversion_rate': conversion_rate,
                        }
                    )
                    
            logger.info(f"Aggregated daily metrics for {date}")
            
        except Exception as e:
            logger.error(f"Error aggregating daily metrics for {date}: {e}")
            raise

    @staticmethod
    def get_popular_templates(limit: int = 10, days: int = 30) -> List[Dict[str, Any]]:
        """Get most popular templates based on usage metrics."""
        try:
            end_date = timezone.now().date()
            start_date = end_date - timedelta(days=days)
            
            # Get templates with usage statistics
            popular_templates = Template.objects.filter(
                status=Template.Status.ACTIVE
            ).annotate(
                recent_usage=Count(
                    'usage_logs',
                    filter=Q(
                        usage_logs__created_at__date__gte=start_date,
                        usage_logs__action=TemplateUsage.Action.GENERATE
                    )
                ),
                total_favorites=Count('favorited_by_users')
            ).order_by('-recent_usage', '-total_favorites')[:limit]
            
            result = []
            for template in popular_templates:
                result.append({
                    'id': str(template.id),
                    'name': template.name,
                    'category': template.category.name,
                    'recent_usage': template.recent_usage,
                    'total_favorites': template.total_favorites,
                    'total_usage': template.usage_count,
                })
            
            return result
            
        except Exception as e:
            logger.error(f"Error getting popular templates: {e}")
            return []


class TemplateRecommendationService:
    """Service for AI-powered template recommendations."""

    @staticmethod
    def generate_recommendations(user, limit: int = 5) -> List[TemplateRecommendation]:
        """Generate personalized template recommendations."""
        try:
            recommendations = []
            
            # Get user's CV profile for content-based recommendations
            cv_profile = getattr(user, 'cv_profile', None)
            
            # Industry-based recommendations
            industry_recs = TemplateRecommendationService._get_industry_recommendations(
                user, cv_profile, limit=2
            )
            recommendations.extend(industry_recs)
            
            # Usage-based recommendations
            usage_recs = TemplateRecommendationService._get_usage_based_recommendations(
                user, limit=2
            )
            recommendations.extend(usage_recs)
            
            # Popular templates (fallback)
            if len(recommendations) < limit:
                popular_recs = TemplateRecommendationService._get_popular_recommendations(
                    user, limit - len(recommendations)
                )
                recommendations.extend(popular_recs)
            
            return recommendations[:limit]
            
        except Exception as e:
            logger.error(f"Error generating recommendations for user {user.id}: {e}")
            return []

    @staticmethod
    def _get_industry_recommendations(user, cv_profile, limit: int) -> List[TemplateRecommendation]:
        """Get industry-based recommendations."""
        recommendations = []
        
        try:
            # Get user's preferred industries or infer from CV
            preferred_industries = []
            
            preferences = UserTemplatePreference.objects.filter(user=user).first()
            if preferences:
                preferred_industries = list(preferences.preferred_industries.all())
            
            # If no preferences, try to infer from CV experience
            if not preferred_industries and cv_profile:
                # This is a simplified inference - in production, you'd use ML
                tech_keywords = ['software', 'developer', 'engineer', 'programmer', 'tech']
                experiences = cv_profile.experiences.all()
                
                for exp in experiences:
                    job_title_lower = exp.job_title.lower()
                    if any(keyword in job_title_lower for keyword in tech_keywords):
                        tech_industry = Industry.objects.filter(slug='technology').first()
                        if tech_industry:
                            preferred_industries.append(tech_industry)
                        break
            
            # Get templates for preferred industries
            if preferred_industries:
                templates = Template.objects.filter(
                    status=Template.Status.ACTIVE,
                    industries__in=preferred_industries
                ).distinct()[:limit]
                
                for template in templates:
                    rec = TemplateRecommendation.objects.create(
                        user=user,
                        template=template,
                        recommendation_type=TemplateRecommendation.RecommendationType.INDUSTRY_BASED,
                        confidence_score=0.8,
                        reasoning=f"Matches your industry preferences",
                        algorithm_version="1.0"
                    )
                    recommendations.append(rec)
            
        except Exception as e:
            logger.error(f"Error getting industry recommendations: {e}")
        
        return recommendations

    @staticmethod
    def _get_usage_based_recommendations(user, limit: int) -> List[TemplateRecommendation]:
        """Get usage pattern-based recommendations."""
        recommendations = []
        
        try:
            # Find similar users based on template usage
            user_templates = TemplateUsage.objects.filter(
                user=user,
                action=TemplateUsage.Action.GENERATE
            ).values_list('template_id', flat=True)
            
            if user_templates:
                # Find users who used similar templates
                similar_users = TemplateUsage.objects.filter(
                    template_id__in=user_templates,
                    action=TemplateUsage.Action.GENERATE
                ).exclude(user=user).values_list('user_id', flat=True).distinct()
                
                # Get templates used by similar users but not by current user
                recommended_templates = TemplateUsage.objects.filter(
                    user_id__in=similar_users,
                    action=TemplateUsage.Action.GENERATE
                ).exclude(
                    template_id__in=user_templates
                ).values('template').annotate(
                    usage_count=Count('id')
                ).order_by('-usage_count')[:limit]
                
                for item in recommended_templates:
                    template = Template.objects.get(id=item['template'])
                    rec = TemplateRecommendation.objects.create(
                        user=user,
                        template=template,
                        recommendation_type=TemplateRecommendation.RecommendationType.COLLABORATIVE,
                        confidence_score=0.7,
                        reasoning=f"Users with similar preferences also used this template",
                        algorithm_version="1.0"
                    )
                    recommendations.append(rec)
            
        except Exception as e:
            logger.error(f"Error getting usage-based recommendations: {e}")
        
        return recommendations

    @staticmethod
    def _get_popular_recommendations(user, limit: int) -> List[TemplateRecommendation]:
        """Get popular template recommendations as fallback."""
        recommendations = []
        
        try:
            # Get most popular templates that user hasn't used
            used_templates = TemplateUsage.objects.filter(user=user).values_list('template_id', flat=True)
            
            popular_templates = Template.objects.filter(
                status=Template.Status.ACTIVE
            ).exclude(
                id__in=used_templates
            ).order_by('-usage_count')[:limit]
            
            for template in popular_templates:
                rec = TemplateRecommendation.objects.create(
                    user=user,
                    template=template,
                    recommendation_type=TemplateRecommendation.RecommendationType.USAGE_BASED,
                    confidence_score=0.5,
                    reasoning=f"Popular template with {template.usage_count} uses",
                    algorithm_version="1.0"
                )
                recommendations.append(rec)
                
        except Exception as e:
            logger.error(f"Error getting popular recommendations: {e}")
        
        return recommendations