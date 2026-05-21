"""
Django signals for automatic analytics tracking.
Event-driven analytics based on system events.
"""
import logging
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from apps.cv.models import CVProfile, GeneratedCV
from apps.cv_intelligence.models import CVAnalysis
from .services import analytics_service
from .models import AnalyticsEvent

logger = logging.getLogger(__name__)
User = get_user_model()


@receiver(post_save, sender=CVAnalysis)
def create_snapshot_on_analysis(sender, instance, created, **kwargs):
    """Create analytics snapshot when CV analysis is completed."""
    try:
        if created:
            # Create automatic snapshot when new analysis is completed
            analytics_service.create_score_snapshot(
                user=instance.user,
                snapshot_type='automatic',
                trigger_event='cv_analysis_completed'
            )
            
            logger.info(f"Created analytics snapshot for user {instance.user.id} after CV analysis")
            
    except Exception as e:
        logger.error(f"Failed to create snapshot after CV analysis: {str(e)}")


@receiver(post_save, sender=CVProfile)
def create_snapshot_on_cv_update(sender, instance, created, **kwargs):
    """Create analytics snapshot when CV profile is significantly updated."""
    try:
        # Only create snapshot if completion percentage changed significantly
        if not created and hasattr(instance, '_previous_completion'):
            completion_change = abs(instance.completion_percentage - instance._previous_completion)
            
            # Create snapshot if completion changed by 10% or more
            if completion_change >= 10:
                analytics_service.create_score_snapshot(
                    user=instance.student,
                    snapshot_type='triggered',
                    trigger_event='cv_completion_milestone'
                )
                
                logger.info(f"Created analytics snapshot for user {instance.student.id} after CV update")
        
        # Store current completion for next comparison
        instance._previous_completion = instance.completion_percentage
        
    except Exception as e:
        logger.error(f"Failed to create snapshot after CV update: {str(e)}")


@receiver(post_save, sender=GeneratedCV)
def create_snapshot_on_pdf_generation(sender, instance, created, **kwargs):
    """Create analytics snapshot when PDF is generated."""
    try:
        if created:
            analytics_service.create_score_snapshot(
                user=instance.cv.student,
                snapshot_type='triggered',
                trigger_event='pdf_generated'
            )
            
            logger.info(f"Created analytics snapshot for user {instance.cv.student.id} after PDF generation")
            
    except Exception as e:
        logger.error(f"Failed to create snapshot after PDF generation: {str(e)}")


@receiver(post_save, sender=User)
def create_initial_snapshot_for_new_user(sender, instance, created, **kwargs):
    """Create initial analytics snapshot for new users."""
    try:
        if created and hasattr(instance, 'cv_profile'):
            # Create initial snapshot for new user
            analytics_service.create_score_snapshot(
                user=instance,
                snapshot_type='automatic',
                trigger_event='user_registration'
            )
            
            logger.info(f"Created initial analytics snapshot for new user {instance.id}")
            
    except Exception as e:
        logger.error(f"Failed to create initial snapshot for new user: {str(e)}")


# Custom signal functions for manual triggering

def trigger_weekly_snapshots():
    """
    Create weekly snapshots for all active users.
    This function can be called from a scheduled task.
    """
    try:
        active_users = User.objects.filter(
            is_active=True,
            cv_profile__isnull=False
        )
        
        created_count = 0
        for user in active_users:
            try:
                analytics_service.create_score_snapshot(
                    user=user,
                    snapshot_type='scheduled',
                    trigger_event='weekly_scheduled_snapshot'
                )
                created_count += 1
            except Exception as e:
                logger.error(f"Failed to create weekly snapshot for user {user.id}: {str(e)}")
        
        logger.info(f"Created {created_count} weekly snapshots")
        return created_count
        
    except Exception as e:
        logger.error(f"Failed to create weekly snapshots: {str(e)}")
        return 0


def trigger_benchmarking_update():
    """
    Update all benchmarking groups.
    This function can be called from a scheduled task.
    """
    try:
        result = analytics_service.update_benchmarking_groups()
        logger.info(f"Updated benchmarking groups: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to update benchmarking groups: {str(e)}")
        return {'error': str(e)}


def trigger_metrics_aggregation():
    """
    Calculate aggregated metrics for all periods.
    This function can be called from a scheduled task.
    """
    try:
        results = {}
        
        # Calculate daily aggregations
        daily_result = analytics_service.calculate_aggregated_metrics(period='daily')
        results['daily'] = daily_result
        
        # Calculate weekly aggregations
        weekly_result = analytics_service.calculate_aggregated_metrics(period='weekly')
        results['weekly'] = weekly_result
        
        # Calculate monthly aggregations
        monthly_result = analytics_service.calculate_aggregated_metrics(period='monthly')
        results['monthly'] = monthly_result
        
        logger.info(f"Calculated aggregated metrics: {results}")
        return results
        
    except Exception as e:
        logger.error(f"Failed to calculate aggregated metrics: {str(e)}")
        return {'error': str(e)}


def trigger_data_cleanup():
    """
    Clean up old analytics data.
    This function can be called from a scheduled task.
    """
    try:
        result = analytics_service.cleanup_old_data(dry_run=False)
        logger.info(f"Cleaned up analytics data: {result}")
        return result
        
    except Exception as e:
        logger.error(f"Failed to cleanup analytics data: {str(e)}")
        return {'error': str(e)}