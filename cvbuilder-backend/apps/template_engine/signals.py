"""
Template Engine signals for EduCV.
Automatic event handling for template usage tracking,
analytics updates, and system maintenance.
"""
from django.db.models.signals import post_save, post_delete, m2m_changed
from django.dispatch import receiver
from django.utils import timezone
from django.core.cache import cache
from django.db import models
import logging

from .models import (
    Template, TemplateUsage, UserTemplatePreference, 
    TemplateRecommendation, TemplatePerformanceMetric
)

logger = logging.getLogger(__name__)


@receiver(post_save, sender=Template)
def handle_template_save(sender, instance, created, **kwargs):
    """Handle template creation and updates."""
    try:
        # Clear template-related caches
        cache_patterns = [
            f"template_recommendations_*",
            f"template_list_*",
            f"popular_templates_*",
        ]
        
        for pattern in cache_patterns:
            cache.delete_many(cache.keys(pattern))
        
        # Log template changes
        action = "created" if created else "updated"
        logger.info(f"Template {instance.name} (ID: {instance.id}) was {action}")
        
        # If template is published, clear user recommendations to trigger refresh
        if instance.status == Template.Status.ACTIVE and not created:
            TemplateRecommendation.objects.filter(
                template=instance,
                created_at__lt=timezone.now() - timezone.timedelta(days=7)
            ).delete()
            
    except Exception as e:
        logger.error(f"Error handling template save signal: {e}")


@receiver(post_delete, sender=Template)
def handle_template_delete(sender, instance, **kwargs):
    """Handle template deletion."""
    try:
        # Clear caches
        cache.clear()
        
        # Log deletion
        logger.info(f"Template {instance.name} (ID: {instance.id}) was deleted")
        
    except Exception as e:
        logger.error(f"Error handling template delete signal: {e}")


@receiver(post_save, sender=TemplateUsage)
def handle_template_usage(sender, instance, created, **kwargs):
    """Handle template usage tracking."""
    if not created:
        return
    
    try:
        # Update template usage count for generation actions
        if instance.action == TemplateUsage.Action.GENERATE:
            Template.objects.filter(id=instance.template.id).update(
                usage_count=models.F('usage_count') + 1
            )
        
        # Clear recommendation caches for the user
        cache.delete(f"template_recommendations_{instance.user.id}_*")
        
        # Log usage
        logger.info(
            f"Template usage tracked: {instance.user.email} - "
            f"{instance.action} - {instance.template.name}"
        )
        
    except Exception as e:
        logger.error(f"Error handling template usage signal: {e}")


@receiver(m2m_changed, sender=UserTemplatePreference.favorite_templates.through)
def handle_favorite_change(sender, instance, action, pk_set, **kwargs):
    """Handle changes to user's favorite templates."""
    try:
        if action in ['post_add', 'post_remove']:
            # Clear user's recommendation cache
            cache.delete(f"template_recommendations_{instance.user.id}_*")
            
            # Log favorite changes
            action_name = "added to" if action == 'post_add' else "removed from"
            template_count = len(pk_set) if pk_set else 0
            logger.info(
                f"{template_count} templates {action_name} favorites for user {instance.user.email}"
            )
            
    except Exception as e:
        logger.error(f"Error handling favorite change signal: {e}")


@receiver(m2m_changed, sender=UserTemplatePreference.preferred_industries.through)
def handle_industry_preference_change(sender, instance, action, **kwargs):
    """Handle changes to user's industry preferences."""
    try:
        if action in ['post_add', 'post_remove', 'post_clear']:
            # Clear user's recommendation cache
            cache.delete(f"template_recommendations_{instance.user.id}_*")
            
            # Delete old recommendations to trigger fresh generation
            TemplateRecommendation.objects.filter(
                user=instance.user,
                recommendation_type=TemplateRecommendation.RecommendationType.INDUSTRY_BASED
            ).delete()
            
            logger.info(f"Industry preferences updated for user {instance.user.email}")
            
    except Exception as e:
        logger.error(f"Error handling industry preference change signal: {e}")


@receiver(m2m_changed, sender=UserTemplatePreference.preferred_roles.through)
def handle_role_preference_change(sender, instance, action, **kwargs):
    """Handle changes to user's role preferences."""
    try:
        if action in ['post_add', 'post_remove', 'post_clear']:
            # Clear user's recommendation cache
            cache.delete(f"template_recommendations_{instance.user.id}_*")
            
            # Delete old recommendations to trigger fresh generation
            TemplateRecommendation.objects.filter(
                user=instance.user,
                recommendation_type=TemplateRecommendation.RecommendationType.ROLE_BASED
            ).delete()
            
            logger.info(f"Role preferences updated for user {instance.user.email}")
            
    except Exception as e:
        logger.error(f"Error handling role preference change signal: {e}")


@receiver(post_save, sender=TemplateRecommendation)
def handle_recommendation_save(sender, instance, created, **kwargs):
    """Handle recommendation creation and updates."""
    if not created:
        return
    
    try:
        # Log recommendation creation
        logger.info(
            f"Recommendation created: {instance.template.name} for {instance.user.email} "
            f"(confidence: {instance.confidence_score:.2f})"
        )
        
        # Clean up old recommendations for the user (keep only latest 20)
        old_recommendations = TemplateRecommendation.objects.filter(
            user=instance.user
        ).order_by('-created_at')[20:]
        
        if old_recommendations:
            TemplateRecommendation.objects.filter(
                id__in=[rec.id for rec in old_recommendations]
            ).delete()
            
    except Exception as e:
        logger.error(f"Error handling recommendation save signal: {e}")


# Cache invalidation helpers
def clear_template_caches():
    """Clear all template-related caches."""
    try:
        cache_keys = cache.keys("template_*")
        if cache_keys:
            cache.delete_many(cache_keys)
        logger.info("Template caches cleared")
    except Exception as e:
        logger.error(f"Error clearing template caches: {e}")


def clear_user_recommendation_cache(user_id):
    """Clear recommendation cache for a specific user."""
    try:
        cache_keys = cache.keys(f"template_recommendations_{user_id}_*")
        if cache_keys:
            cache.delete_many(cache_keys)
        logger.info(f"Recommendation cache cleared for user {user_id}")
    except Exception as e:
        logger.error(f"Error clearing user recommendation cache: {e}")


# Signal to handle CV profile updates (affects recommendations)
try:
    from apps.cv.models import CVProfile
    
    @receiver(post_save, sender=CVProfile)
    def handle_cv_profile_update(sender, instance, **kwargs):
        """Handle CV profile updates that might affect template recommendations."""
        try:
            # Clear user's recommendation cache
            cache.delete(f"template_recommendations_{instance.student.id}_*")
            
            # Delete content-based recommendations to trigger refresh
            TemplateRecommendation.objects.filter(
                user=instance.student,
                recommendation_type=TemplateRecommendation.RecommendationType.CONTENT_BASED
            ).delete()
            
            logger.info(f"CV profile updated for user {instance.student.email}, recommendations refreshed")
            
        except Exception as e:
            logger.error(f"Error handling CV profile update signal: {e}")
            
except ImportError:
    # CV app not available, skip this signal
    pass