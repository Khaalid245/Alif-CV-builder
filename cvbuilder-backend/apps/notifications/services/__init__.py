"""
Core notification service for EduCV.
Handles notification creation, sending, and management with configurable behavior.
"""
import logging
from typing import Dict, List, Optional, Any, Union
from django.db import transaction
from django.core.mail import send_mail, EmailMultiAlternatives
from django.template.loader import render_to_string
from django.utils import timezone
from django.contrib.contenttypes.models import ContentType
from django.conf import settings

from ..models import (
    Notification, NotificationTemplate, NotificationBatch,
    NotificationEvent, UserNotificationPreference, NotificationConfiguration
)

logger = logging.getLogger(__name__)


class NotificationService:
    """
    Enterprise-grade notification service.
    Handles all notification operations with configurable behavior.
    """
    
    def __init__(self):
        self._config = None
    
    @property
    def config(self):
        """Lazy-load configuration to avoid database access during app initialization."""
        if self._config is None:
            self._config = self._get_configuration()
        return self._config
    
    @config.setter
    def config(self, value):
        """Allow setting configuration."""
        self._config = value
    
    def _get_configuration(self) -> NotificationConfiguration:
        """Get or create notification configuration."""
        config, created = NotificationConfiguration.objects.get_or_create(
            defaults={
                'email_enabled': True,
                'email_rate_limit': 100,
                'in_app_enabled': True,
                'max_notifications_per_user': 1000,
                'auto_cleanup_enabled': True,
                'cleanup_after_days': 90,
                'batch_size': 100,
            }
        )
        if created:
            logger.info("Created default notification configuration")
        return config
    
    def create_notification(
        self,
        user: 'User',
        notification_type: str,
        title: str = None,
        message: str = None,
        template_name: str = None,
        context: Dict[str, Any] = None,
        channel: str = 'both',
        priority: str = 'normal',
        related_object: Any = None,
        send_immediately: bool = True
    ) -> List[Notification]:
        """
        Create and optionally send notification(s).
        
        Args:
            user: Target user
            notification_type: Type of notification
            title: Custom title (overrides template)
            message: Custom message (overrides template)
            template_name: Template to use
            context: Template context variables
            channel: 'in_app', 'email', or 'both'
            priority: Notification priority
            related_object: Related model instance
            send_immediately: Whether to send immediately
            
        Returns:
            List of created Notification instances
        """
        try:
            context = context or {}
            notifications = []
            
            # Get template if specified
            template = None
            if template_name:
                try:
                    template = NotificationTemplate.objects.get(
                        name=template_name,
                        is_active=True
                    )
                except NotificationTemplate.DoesNotExist:
                    logger.warning(f"Template '{template_name}' not found")
            
            # Get user preferences
            preferences = self._get_user_preferences(user)
            
            # Determine channels to use
            channels = self._resolve_channels(channel, template)
            
            # Create notifications for each channel
            for ch in channels:
                if not self._should_send_notification(preferences, notification_type, ch):
                    continue
                
                notification = self._create_single_notification(
                    user=user,
                    notification_type=notification_type,
                    channel=ch,
                    title=title,
                    message=message,
                    template=template,
                    context=context,
                    priority=priority,
                    related_object=related_object
                )
                
                notifications.append(notification)
                
                # Log creation event
                self._log_event(
                    event_type=NotificationEvent.EventType.NOTIFICATION_CREATED,
                    description=f"Notification created: {notification.title}",
                    notification=notification,
                    user=user
                )
            
            # Send immediately if requested
            if send_immediately:
                for notification in notifications:
                    self.send_notification(notification)
            
            logger.info(f"Created {len(notifications)} notifications for user {user.id}")
            return notifications
            
        except Exception as e:
            logger.error(f"Failed to create notification: {str(e)}")
            raise
    
    def _create_single_notification(
        self,
        user: 'User',
        notification_type: str,
        channel: str,
        title: str,
        message: str,
        template: NotificationTemplate,
        context: Dict[str, Any],
        priority: str,
        related_object: Any
    ) -> Notification:
        """Create a single notification instance."""
        
        # Render content from template or use provided content
        if template:
            rendered_title = template.render_title(context) if not title else title
            rendered_message = template.render_message(context) if not message else message
            email_subject = template.render_email_subject(context) if channel == 'email' else ''
        else:
            rendered_title = title or 'Notification'
            rendered_message = message or ''
            email_subject = title or 'Notification'
        
        # Get related object content type
        content_type = None
        object_id = None
        if related_object:
            content_type = ContentType.objects.get_for_model(related_object)
            object_id = str(related_object.pk)
        
        # Create notification
        notification = Notification.objects.create(
            user=user,
            template=template,
            title=rendered_title,
            message=rendered_message,
            notification_type=notification_type,
            channel=channel,
            priority=priority,
            content_type=content_type,
            object_id=object_id,
            context_data=context,
            email_subject=email_subject
        )
        
        return notification
    
    def send_notification(self, notification: Notification) -> bool:
        """
        Send a single notification.
        
        Args:
            notification: Notification instance to send
            
        Returns:
            True if sent successfully, False otherwise
        """
        try:
            if notification.channel == 'email':
                return self._send_email_notification(notification)
            elif notification.channel == 'in_app':
                return self._send_in_app_notification(notification)
            else:
                logger.error(f"Unknown notification channel: {notification.channel}")
                return False
                
        except Exception as e:
            logger.error(f"Failed to send notification {notification.id}: {str(e)}")
            notification.mark_as_failed(str(e))
            return False
    
    def _send_email_notification(self, notification: Notification) -> bool:
        """Send email notification."""
        if not self.config.email_enabled:
            logger.info("Email notifications are disabled globally")
            return False
        
        try:
            # Check rate limiting
            if not self._check_email_rate_limit(notification.user):
                logger.warning(f"Email rate limit exceeded for user {notification.user.id}")
                notification.mark_as_failed("Rate limit exceeded")
                return False
            
            # Prepare email content
            subject = notification.email_subject or notification.title
            message = notification.message
            
            # Render HTML content if template has it
            html_content = None
            if notification.template and notification.template.email_html_template:
                html_content = notification.template.email_html_template.format(
                    **notification.context_data
                )
            
            # Send email
            if html_content:
                email = EmailMultiAlternatives(
                    subject=subject,
                    body=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    to=[notification.user.email]
                )
                email.attach_alternative(html_content, "text/html")
                email.send()
            else:
                send_mail(
                    subject=subject,
                    message=message,
                    from_email=settings.DEFAULT_FROM_EMAIL,
                    recipient_list=[notification.user.email],
                    fail_silently=False
                )
            
            notification.mark_as_sent()
            
            # Log event
            self._log_event(
                event_type=NotificationEvent.EventType.NOTIFICATION_SENT,
                description=f"Email sent: {notification.title}",
                notification=notification,
                user=notification.user
            )
            
            logger.info(f"Email notification sent to {notification.user.email}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email notification: {str(e)}")
            notification.mark_as_failed(str(e))
            return False
    
    def _send_in_app_notification(self, notification: Notification) -> bool:
        """Send in-app notification (just mark as sent since it's stored in DB)."""
        if not self.config.in_app_enabled:
            logger.info("In-app notifications are disabled globally")
            return False
        
        try:
            notification.mark_as_sent()
            
            # Log event
            self._log_event(
                event_type=NotificationEvent.EventType.NOTIFICATION_SENT,
                description=f"In-app notification sent: {notification.title}",
                notification=notification,
                user=notification.user
            )
            
            # Cleanup old notifications if needed
            self._cleanup_user_notifications(notification.user)
            
            logger.info(f"In-app notification sent to user {notification.user.id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send in-app notification: {str(e)}")
            notification.mark_as_failed(str(e))
            return False
    
    def create_bulk_notification(
        self,
        users: List['User'],
        notification_type: str,
        template_name: str,
        context: Dict[str, Any] = None,
        name: str = None,
        description: str = '',
        created_by: 'User' = None,
        scheduled_at: timezone.datetime = None
    ) -> NotificationBatch:
        """
        Create bulk notification batch.
        
        Args:
            users: List of target users
            notification_type: Type of notification
            template_name: Template to use
            context: Template context variables
            name: Batch name
            description: Batch description
            created_by: User who created the batch
            scheduled_at: When to send (None = immediate)
            
        Returns:
            NotificationBatch instance
        """
        try:
            # Get template
            template = NotificationTemplate.objects.get(
                name=template_name,
                is_active=True
            )
            
            # Create batch
            batch = NotificationBatch.objects.create(
                name=name or f"Bulk {notification_type} - {timezone.now()}",
                description=description,
                template=template,
                context_data=context or {},
                scheduled_at=scheduled_at,
                created_by=created_by,
                total_notifications=len(users)
            )
            
            # Add target users
            batch.target_users.set(users)
            
            # Log event
            self._log_event(
                event_type=NotificationEvent.EventType.BATCH_CREATED,
                description=f"Batch created: {batch.name}",
                batch=batch,
                user=created_by
            )
            
            # Process immediately if not scheduled
            if not scheduled_at:
                self.process_notification_batch(batch)
            
            logger.info(f"Created notification batch {batch.id} for {len(users)} users")
            return batch
            
        except Exception as e:
            logger.error(f"Failed to create bulk notification: {str(e)}")
            raise
    
    def process_notification_batch(self, batch: NotificationBatch) -> bool:
        """
        Process a notification batch.
        
        Args:
            batch: NotificationBatch to process
            
        Returns:
            True if processed successfully
        """
        try:
            batch.status = NotificationBatch.Status.PROCESSING
            batch.started_at = timezone.now()
            batch.save()
            
            # Log event
            self._log_event(
                event_type=NotificationEvent.EventType.BATCH_STARTED,
                description=f"Batch processing started: {batch.name}",
                batch=batch
            )
            
            sent_count = 0
            failed_count = 0
            
            # Process users in batches
            users = batch.target_users.all()
            batch_size = self.config.batch_size
            
            for i in range(0, len(users), batch_size):
                user_batch = users[i:i + batch_size]
                
                for user in user_batch:
                    try:
                        notifications = self.create_notification(
                            user=user,
                            notification_type=batch.template.notification_type,
                            template_name=batch.template.name,
                            context=batch.context_data,
                            send_immediately=True
                        )
                        
                        if notifications:
                            sent_count += len(notifications)
                        else:
                            failed_count += 1
                            
                    except Exception as e:
                        logger.error(f"Failed to send notification to user {user.id}: {str(e)}")
                        failed_count += 1
                
                # Update progress
                batch.sent_notifications = sent_count
                batch.failed_notifications = failed_count
                batch.save(update_fields=['sent_notifications', 'failed_notifications'])
            
            # Mark as completed
            batch.status = NotificationBatch.Status.COMPLETED
            batch.completed_at = timezone.now()
            batch.save()
            
            # Log completion
            self._log_event(
                event_type=NotificationEvent.EventType.BATCH_COMPLETED,
                description=f"Batch completed: {batch.name} (sent: {sent_count}, failed: {failed_count})",
                batch=batch
            )
            
            logger.info(f"Batch {batch.id} completed: {sent_count} sent, {failed_count} failed")
            return True
            
        except Exception as e:
            logger.error(f"Failed to process batch {batch.id}: {str(e)}")
            batch.status = NotificationBatch.Status.FAILED
            batch.save()
            return False
    
    def mark_notification_as_read(
        self,
        notification: Notification,
        user: 'User' = None,
        ip_address: str = None
    ) -> bool:
        """
        Mark notification as read.
        
        Args:
            notification: Notification to mark as read
            user: User who read it (for audit)
            ip_address: IP address for audit
            
        Returns:
            True if marked successfully
        """
        try:
            if notification.is_read:
                return True
            
            notification.mark_as_read()
            
            # Log event
            self._log_event(
                event_type=NotificationEvent.EventType.NOTIFICATION_READ,
                description=f"Notification read: {notification.title}",
                notification=notification,
                user=user or notification.user,
                ip_address=ip_address
            )
            
            logger.info(f"Notification {notification.id} marked as read")
            return True
            
        except Exception as e:
            logger.error(f"Failed to mark notification as read: {str(e)}")
            return False
    
    def get_user_notifications(
        self,
        user: 'User',
        channel: str = None,
        status: str = None,
        unread_only: bool = False,
        limit: int = None
    ) -> List[Notification]:
        """
        Get notifications for a user.
        
        Args:
            user: Target user
            channel: Filter by channel
            status: Filter by status
            unread_only: Only unread notifications
            limit: Maximum number to return
            
        Returns:
            List of Notification instances
        """
        queryset = Notification.objects.filter(user=user)
        
        if channel:
            queryset = queryset.filter(channel=channel)
        
        if status:
            queryset = queryset.filter(status=status)
        
        if unread_only:
            queryset = queryset.exclude(status=Notification.Status.READ)
        
        if limit:
            queryset = queryset[:limit]
        
        return list(queryset.select_related('template'))
    
    def _get_user_preferences(self, user: 'User') -> UserNotificationPreference:
        """Get or create user notification preferences."""
        preferences, created = UserNotificationPreference.objects.get_or_create(
            user=user,
            defaults={
                'email_notifications_enabled': True,
                'in_app_notifications_enabled': True,
            }
        )
        return preferences
    
    def _resolve_channels(self, channel: str, template: NotificationTemplate) -> List[str]:
        """Resolve which channels to use based on input and template."""
        if template and template.channel != 'both':
            return [template.channel]
        
        if channel == 'both':
            return ['in_app', 'email']
        elif channel in ['in_app', 'email']:
            return [channel]
        else:
            return ['in_app']  # Default fallback
    
    def _should_send_notification(
        self,
        preferences: UserNotificationPreference,
        notification_type: str,
        channel: str
    ) -> bool:
        """Check if notification should be sent based on user preferences."""
        return preferences.allows_notification(notification_type, channel)
    
    def _check_email_rate_limit(self, user: 'User') -> bool:
        """Check if user has exceeded email rate limit."""
        # Simple rate limiting - count emails sent in last hour
        one_hour_ago = timezone.now() - timezone.timedelta(hours=1)
        recent_emails = Notification.objects.filter(
            user=user,
            channel='email',
            sent_at__gte=one_hour_ago
        ).count()
        
        return recent_emails < self.config.email_rate_limit
    
    def _cleanup_user_notifications(self, user: 'User'):
        """Cleanup old notifications for a user if limit exceeded."""
        if not self.config.auto_cleanup_enabled:
            return
        
        total_notifications = Notification.objects.filter(user=user).count()
        
        if total_notifications > self.config.max_notifications_per_user:
            # Delete oldest read notifications
            excess_count = total_notifications - self.config.max_notifications_per_user
            old_notifications = Notification.objects.filter(
                user=user,
                status=Notification.Status.READ
            ).order_by('created_at')[:excess_count]
            
            deleted_count = len(old_notifications)
            for notification in old_notifications:
                notification.delete()
            
            logger.info(f"Cleaned up {deleted_count} old notifications for user {user.id}")
    
    def _log_event(
        self,
        event_type: str,
        description: str,
        notification: Notification = None,
        batch: NotificationBatch = None,
        user: 'User' = None,
        ip_address: str = None,
        metadata: Dict = None
    ):
        """Log notification event for audit purposes."""
        try:
            NotificationEvent.objects.create(
                event_type=event_type,
                description=description,
                notification=notification,
                batch=batch,
                user=user,
                ip_address=ip_address,
                metadata=metadata or {}
            )
        except Exception as e:
            logger.error(f"Failed to log notification event: {str(e)}")


# Global service instance
notification_service = NotificationService()