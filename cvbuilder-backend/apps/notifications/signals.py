"""
Django signals for automatic notification triggering.
Event-driven notifications based on system events.
"""
import logging
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from apps.cv.models import CVProfile, GeneratedCV
from apps.workflow.models import WorkflowInstance
from apps.version_history.models import CVVersion
from .services import notification_service
from .models import NotificationEvent

logger = logging.getLogger(__name__)
User = get_user_model()


def get_request_user():
    """
    Get current user from thread-local storage.
    This is a simplified approach - in production, you might use
    django-crum or similar middleware to track the current user.
    """
    # For now, return None - the service will handle this gracefully
    return None


def get_request_metadata():
    """
    Get request metadata (IP, user agent) from thread-local storage.
    This is a simplified approach for the implementation.
    """
    return {
        'ip_address': None,
        'user_agent': ''
    }


@receiver(post_save, sender=CVProfile)
def notify_cv_profile_changes(sender, instance, created, **kwargs):
    """Notify when CV profile is created or updated."""
    try:
        user = instance.student
        
        if created:
            # CV created notification
            notification_service.create_notification(
                user=user,
                notification_type='cv_created',
                template_name='cv_created',
                context={
                    'user_name': user.get_full_name() or user.email,
                    'cv_id': str(instance.id),
                    'completion_percentage': instance.completion_percentage
                },
                related_object=instance,
                send_immediately=True
            )
        else:
            # CV updated notification
            notification_service.create_notification(
                user=user,
                notification_type='cv_updated',
                template_name='cv_updated',
                context={
                    'user_name': user.get_full_name() or user.email,
                    'cv_id': str(instance.id),
                    'completion_percentage': instance.completion_percentage
                },
                related_object=instance,
                send_immediately=True
            )
            
            # Check if CV is now complete (100%)
            if instance.completion_percentage == 100:
                notification_service.create_notification(
                    user=user,
                    notification_type='cv_completed',
                    template_name='cv_completed',
                    context={
                        'user_name': user.get_full_name() or user.email,
                        'cv_id': str(instance.id)
                    },
                    related_object=instance,
                    priority='high',
                    send_immediately=True
                )
        
    except Exception as e:
        logger.error(f"Failed to send CV profile notification: {str(e)}")


@receiver(post_save, sender=GeneratedCV)
def notify_pdf_generated(sender, instance, created, **kwargs):
    """Notify when PDF is generated."""
    if not created:
        return
    
    try:
        user = instance.cv.student
        
        notification_service.create_notification(
            user=user,
            notification_type='pdf_generated',
            template_name='pdf_generated',
            context={
                'user_name': user.get_full_name() or user.email,
                'template_name': instance.template.title(),
                'cv_id': str(instance.cv.id),
                'download_url': f'/api/v1/cv/download/{instance.id}/'
            },
            related_object=instance,
            priority='high',
            send_immediately=True
        )
        
    except Exception as e:
        logger.error(f"Failed to send PDF generation notification: {str(e)}")


@receiver(post_save, sender=WorkflowInstance)
def notify_workflow_changes(sender, instance, created, **kwargs):
    """Notify when workflow status changes."""
    try:
        user = instance.cv_profile.student
        
        if created:
            # New workflow instance
            notification_service.create_notification(
                user=user,
                notification_type='workflow_changed',
                template_name='workflow_started',
                context={
                    'user_name': user.get_full_name() or user.email,
                    'workflow_name': instance.workflow_config.name,
                    'current_state': instance.current_state.name,
                    'cv_id': str(instance.cv_profile.id)
                },
                related_object=instance,
                send_immediately=True
            )
        else:
            # Workflow state changed
            notification_service.create_notification(
                user=user,
                notification_type='workflow_changed',
                template_name='workflow_state_changed',
                context={
                    'user_name': user.get_full_name() or user.email,
                    'workflow_name': instance.workflow_config.name,
                    'current_state': instance.current_state.name,
                    'cv_id': str(instance.cv_profile.id)
                },
                related_object=instance,
                priority='normal',
                send_immediately=True
            )
        
    except Exception as e:
        logger.error(f"Failed to send workflow notification: {str(e)}")


@receiver(post_save, sender=CVVersion)
def notify_version_changes(sender, instance, created, **kwargs):
    """Notify when CV version is created (especially for restores)."""
    if not created:
        return
    
    try:
        user = instance.cv_profile.student
        
        # Only notify for restore operations
        if instance.change_type == 'restore':
            notification_service.create_notification(
                user=user,
                notification_type='version_restored',
                template_name='version_restored',
                context={
                    'user_name': user.get_full_name() or user.email,
                    'version_number': instance.version_number,
                    'cv_id': str(instance.cv_profile.id),
                    'change_summary': instance.change_summary
                },
                related_object=instance,
                priority='normal',
                send_immediately=True
            )
        
    except Exception as e:
        logger.error(f"Failed to send version notification: {str(e)}")


@receiver(post_save, sender=User)
def notify_account_changes(sender, instance, created, **kwargs):
    """Notify when user account is created or updated."""
    try:
        if created:
            # Welcome notification for new users
            notification_service.create_notification(
                user=instance,
                notification_type='account_updated',
                template_name='welcome_user',
                context={
                    'user_name': instance.get_full_name() or instance.email,
                    'platform_name': 'EduCV'
                },
                related_object=instance,
                priority='high',
                send_immediately=True
            )
        else:
            # Account updated notification (only for significant changes)
            # You might want to track specific field changes here
            pass
        
    except Exception as e:
        logger.error(f"Failed to send account notification: {str(e)}")


# Custom signal for system maintenance notifications
def send_system_maintenance_notification(
    message: str,
    scheduled_time: str = None,
    affected_services: list = None,
    priority: str = 'high'
):
    """
    Send system maintenance notification to all users.
    This is a custom function that can be called from management commands.
    """
    try:
        users = User.objects.filter(is_active=True)
        
        notification_service.create_bulk_notification(
            users=list(users),
            notification_type='system_maintenance',
            template_name='system_maintenance',
            context={
                'message': message,
                'scheduled_time': scheduled_time or 'Soon',
                'affected_services': affected_services or ['CV Builder'],
                'platform_name': 'EduCV'
            },
            name=f"System Maintenance - {scheduled_time or 'Immediate'}",
            description="System maintenance notification to all users"
        )
        
        logger.info(f"System maintenance notification sent to {len(users)} users")
        
    except Exception as e:
        logger.error(f"Failed to send system maintenance notification: {str(e)}")


# Custom signal for security alerts
def send_security_alert(
    user: User,
    alert_type: str,
    details: dict,
    ip_address: str = None
):
    """
    Send security alert notification.
    This can be called from authentication views or security middleware.
    """
    try:
        notification_service.create_notification(
            user=user,
            notification_type='security_alert',
            template_name='security_alert',
            context={
                'user_name': user.get_full_name() or user.email,
                'alert_type': alert_type,
                'ip_address': ip_address or 'Unknown',
                'timestamp': details.get('timestamp', 'Now'),
                'action_taken': details.get('action_taken', 'None')
            },
            priority='urgent',
            channel='both',  # Always send both email and in-app for security
            send_immediately=True
        )
        
        logger.warning(f"Security alert sent to user {user.id}: {alert_type}")
        
    except Exception as e:
        logger.error(f"Failed to send security alert: {str(e)}")


# Custom signal for analysis completion
def notify_analysis_completed(cv_profile, analysis_results):
    """
    Notify when CV intelligence analysis is completed.
    This can be called from the CV intelligence service.
    """
    try:
        user = cv_profile.student
        
        notification_service.create_notification(
            user=user,
            notification_type='analysis_completed',
            template_name='analysis_completed',
            context={
                'user_name': user.get_full_name() or user.email,
                'cv_id': str(cv_profile.id),
                'overall_score': analysis_results.get('overall_score', 0),
                'recommendations_count': len(analysis_results.get('recommendations', [])),
                'analysis_url': f'/cv/analysis/{cv_profile.id}/'
            },
            related_object=cv_profile,
            priority='normal',
            send_immediately=True
        )
        
        logger.info(f"Analysis completion notification sent to user {user.id}")
        
    except Exception as e:
        logger.error(f"Failed to send analysis completion notification: {str(e)}")