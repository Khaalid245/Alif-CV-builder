"""
Notifications models for EduCV.
Enterprise-grade notification system with templates, preferences, and audit logging.
"""
import uuid
import json
from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey
from django.core.serializers.json import DjangoJSONEncoder
from django.utils import timezone


class NotificationConfiguration(models.Model):
    """
    Global configuration for notification system.
    Allows runtime configuration without code changes.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Email settings
    email_enabled = models.BooleanField(
        default=True,
        help_text="Enable email notifications globally"
    )
    email_rate_limit = models.IntegerField(
        default=100,
        help_text="Maximum emails per hour per user"
    )
    
    # In-app notification settings
    in_app_enabled = models.BooleanField(
        default=True,
        help_text="Enable in-app notifications"
    )
    max_notifications_per_user = models.IntegerField(
        default=1000,
        help_text="Maximum notifications to keep per user"
    )
    
    # Cleanup settings
    auto_cleanup_enabled = models.BooleanField(
        default=True,
        help_text="Automatically cleanup old notifications"
    )
    cleanup_after_days = models.IntegerField(
        default=90,
        help_text="Delete read notifications after N days"
    )
    
    # Batch processing
    batch_size = models.IntegerField(
        default=100,
        help_text="Batch size for bulk operations"
    )
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_configurations'
    
    def __str__(self):
        return f"Notification Config (email: {self.email_enabled}, in-app: {self.in_app_enabled})"


class NotificationTemplate(models.Model):
    """
    Configurable notification templates for different event types.
    Supports both email and in-app notifications.
    """
    
    class NotificationType(models.TextChoices):
        CV_CREATED = 'cv_created', 'CV Created'
        CV_UPDATED = 'cv_updated', 'CV Updated'
        CV_COMPLETED = 'cv_completed', 'CV Completed'
        PDF_GENERATED = 'pdf_generated', 'PDF Generated'
        WORKFLOW_CHANGED = 'workflow_changed', 'Workflow Status Changed'
        VERSION_RESTORED = 'version_restored', 'Version Restored'
        ANALYSIS_COMPLETED = 'analysis_completed', 'Analysis Completed'
        SYSTEM_MAINTENANCE = 'system_maintenance', 'System Maintenance'
        ACCOUNT_UPDATED = 'account_updated', 'Account Updated'
        SECURITY_ALERT = 'security_alert', 'Security Alert'
        CUSTOM = 'custom', 'Custom Notification'
    
    class Channel(models.TextChoices):
        IN_APP = 'in_app', 'In-App'
        EMAIL = 'email', 'Email'
        BOTH = 'both', 'Both'
    
    class Priority(models.TextChoices):
        LOW = 'low', 'Low'
        NORMAL = 'normal', 'Normal'
        HIGH = 'high', 'High'
        URGENT = 'urgent', 'Urgent'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Template identification
    name = models.CharField(max_length=100, unique=True)
    notification_type = models.CharField(
        max_length=30,
        choices=NotificationType.choices,
        db_index=True
    )
    
    # Template content
    title_template = models.CharField(
        max_length=255,
        help_text="Template for notification title (supports variables)"
    )
    message_template = models.TextField(
        help_text="Template for notification message (supports variables)"
    )
    
    # Email-specific content
    email_subject_template = models.CharField(
        max_length=255,
        blank=True,
        help_text="Email subject template (optional, uses title if empty)"
    )
    email_html_template = models.TextField(
        blank=True,
        help_text="HTML email template (optional)"
    )
    
    # Configuration
    channel = models.CharField(
        max_length=10,
        choices=Channel.choices,
        default=Channel.BOTH
    )
    priority = models.CharField(
        max_length=10,
        choices=Priority.choices,
        default=Priority.NORMAL
    )
    
    # Behavior settings
    is_active = models.BooleanField(default=True)
    requires_user_preference = models.BooleanField(
        default=True,
        help_text="Check user preferences before sending"
    )
    
    # Template variables documentation
    available_variables = models.JSONField(
        default=dict,
        help_text="Documentation of available template variables"
    )
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'notification_templates'
        indexes = [
            models.Index(fields=['notification_type'], name='idx_notif_templates_type'),
            models.Index(fields=['is_active'], name='idx_notif_templates_active'),
        ]
    
    def __str__(self):
        return f"{self.name} ({self.notification_type})"
    
    def render_title(self, context: dict) -> str:
        """Render title template with context variables."""
        return self._render_template(self.title_template, context)
    
    def render_message(self, context: dict) -> str:
        """Render message template with context variables."""
        return self._render_template(self.message_template, context)
    
    def render_email_subject(self, context: dict) -> str:
        """Render email subject template with context variables."""
        template = self.email_subject_template or self.title_template
        return self._render_template(template, context)
    
    def _render_template(self, template: str, context: dict) -> str:
        """Simple template rendering with variable substitution."""
        try:
            return template.format(**context)
        except KeyError as e:
            # Log missing variable but don't fail
            return template.replace(f"{{{e.args[0]}}}", f"[{e.args[0]}]")


class UserNotificationPreference(models.Model):
    """
    User-specific notification preferences.
    Controls which notifications a user wants to receive and how.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    user = models.OneToOneField(
        'users.User',
        on_delete=models.CASCADE,
        related_name='notification_preferences'
    )
    
    # Global preferences
    email_notifications_enabled = models.BooleanField(default=True)
    in_app_notifications_enabled = models.BooleanField(default=True)
    
    # Specific notification type preferences
    cv_updates_email = models.BooleanField(default=True)
    cv_updates_in_app = models.BooleanField(default=True)
    
    workflow_changes_email = models.BooleanField(default=True)
    workflow_changes_in_app = models.BooleanField(default=True)
    
    system_notifications_email = models.BooleanField(default=True)
    system_notifications_in_app = models.BooleanField(default=True)
    
    security_alerts_email = models.BooleanField(default=True)
    security_alerts_in_app = models.BooleanField(default=True)
    
    # Frequency settings
    digest_frequency = models.CharField(
        max_length=20,
        choices=[
            ('immediate', 'Immediate'),
            ('hourly', 'Hourly'),
            ('daily', 'Daily'),
            ('weekly', 'Weekly'),
            ('never', 'Never'),
        ],
        default='immediate'
    )
    
    # Quiet hours
    quiet_hours_enabled = models.BooleanField(default=False)
    quiet_hours_start = models.TimeField(null=True, blank=True)
    quiet_hours_end = models.TimeField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'user_notification_preferences'
    
    def __str__(self):
        return f"Preferences for {self.user.email}"
    
    def allows_notification(self, notification_type: str, channel: str) -> bool:
        """Check if user allows this type of notification on this channel."""
        if channel == 'email' and not self.email_notifications_enabled:
            return False
        if channel == 'in_app' and not self.in_app_notifications_enabled:
            return False
        
        # Check specific type preferences
        type_mapping = {
            'cv_created': ('cv_updates_email', 'cv_updates_in_app'),
            'cv_updated': ('cv_updates_email', 'cv_updates_in_app'),
            'cv_completed': ('cv_updates_email', 'cv_updates_in_app'),
            'workflow_changed': ('workflow_changes_email', 'workflow_changes_in_app'),
            'system_maintenance': ('system_notifications_email', 'system_notifications_in_app'),
            'security_alert': ('security_alerts_email', 'security_alerts_in_app'),
        }
        
        if notification_type in type_mapping:
            email_pref, in_app_pref = type_mapping[notification_type]
            if channel == 'email':
                return getattr(self, email_pref, True)
            elif channel == 'in_app':
                return getattr(self, in_app_pref, True)
        
        return True


class Notification(models.Model):
    """
    Individual notification instance.
    Stores the actual notification sent to a user.
    """
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        SENT = 'sent', 'Sent'
        DELIVERED = 'delivered', 'Delivered'
        READ = 'read', 'Read'
        FAILED = 'failed', 'Failed'
        CANCELLED = 'cancelled', 'Cancelled'
    
    class Priority(models.TextChoices):
        LOW = 'low', 'Low'
        NORMAL = 'normal', 'Normal'
        HIGH = 'high', 'High'
        URGENT = 'urgent', 'Urgent'
    
    class Channel(models.TextChoices):
        IN_APP = 'in_app', 'In-App'
        EMAIL = 'email', 'Email'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Recipient
    user = models.ForeignKey(
        'users.User',
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    
    # Template reference
    template = models.ForeignKey(
        NotificationTemplate,
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notifications'
    )
    
    # Content
    title = models.CharField(max_length=255)
    message = models.TextField()
    
    # Configuration
    notification_type = models.CharField(max_length=30, db_index=True)
    channel = models.CharField(max_length=10, choices=Channel.choices)
    priority = models.CharField(
        max_length=10,
        choices=Priority.choices,
        default=Priority.NORMAL
    )
    
    # Status tracking
    status = models.CharField(
        max_length=15,
        choices=Status.choices,
        default=Status.PENDING,
        db_index=True
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    sent_at = models.DateTimeField(null=True, blank=True)
    delivered_at = models.DateTimeField(null=True, blank=True)
    read_at = models.DateTimeField(null=True, blank=True)
    
    # Related object (generic foreign key)
    content_type = models.ForeignKey(
        ContentType,
        on_delete=models.CASCADE,
        null=True,
        blank=True
    )
    object_id = models.CharField(max_length=255, null=True, blank=True)
    related_object = GenericForeignKey('content_type', 'object_id')
    
    # Additional data
    context_data = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text="Additional context data for the notification"
    )
    
    # Email-specific fields
    email_subject = models.CharField(max_length=255, blank=True)
    email_html_content = models.TextField(blank=True)
    email_message_id = models.CharField(max_length=255, blank=True)
    
    # Error tracking
    error_message = models.TextField(blank=True)
    retry_count = models.IntegerField(default=0)
    max_retries = models.IntegerField(default=3)
    
    class Meta:
        db_table = 'notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['user', '-created_at'], name='idx_notifications_user'),
            models.Index(fields=['status'], name='idx_notifications_status'),
            models.Index(fields=['notification_type'], name='idx_notifications_type'),
            models.Index(fields=['channel'], name='idx_notifications_channel'),
            models.Index(fields=['created_at'], name='idx_notifications_created'),
        ]
    
    def __str__(self):
        return f"{self.title} - {self.user.email} ({self.status})"
    
    def mark_as_read(self):
        """Mark notification as read."""
        if self.status != self.Status.READ:
            self.status = self.Status.READ
            self.read_at = timezone.now()
            self.save(update_fields=['status', 'read_at'])
    
    def mark_as_sent(self):
        """Mark notification as sent."""
        self.status = self.Status.SENT
        self.sent_at = timezone.now()
        self.save(update_fields=['status', 'sent_at'])
    
    def mark_as_delivered(self):
        """Mark notification as delivered."""
        self.status = self.Status.DELIVERED
        self.delivered_at = timezone.now()
        self.save(update_fields=['status', 'delivered_at'])
    
    def mark_as_failed(self, error_message: str = ''):
        """Mark notification as failed."""
        self.status = self.Status.FAILED
        self.error_message = error_message
        self.retry_count += 1
        self.save(update_fields=['status', 'error_message', 'retry_count'])
    
    @property
    def is_read(self) -> bool:
        """Check if notification is read."""
        return self.status == self.Status.READ
    
    @property
    def can_retry(self) -> bool:
        """Check if notification can be retried."""
        return (
            self.status == self.Status.FAILED and
            self.retry_count < self.max_retries
        )


class NotificationBatch(models.Model):
    """
    Batch notification processing for bulk operations.
    Tracks bulk notification jobs and their progress.
    """
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        PROCESSING = 'processing', 'Processing'
        COMPLETED = 'completed', 'Completed'
        FAILED = 'failed', 'Failed'
        CANCELLED = 'cancelled', 'Cancelled'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Batch metadata
    name = models.CharField(max_length=255)
    description = models.TextField(blank=True)
    
    # Template and configuration
    template = models.ForeignKey(
        NotificationTemplate,
        on_delete=models.CASCADE,
        related_name='batches'
    )
    
    # Target users
    target_users = models.ManyToManyField(
        'users.User',
        related_name='notification_batches'
    )
    
    # Batch context data
    context_data = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text="Context data for template rendering"
    )
    
    # Progress tracking
    status = models.CharField(
        max_length=15,
        choices=Status.choices,
        default=Status.PENDING
    )
    total_notifications = models.IntegerField(default=0)
    sent_notifications = models.IntegerField(default=0)
    failed_notifications = models.IntegerField(default=0)
    
    # Scheduling
    scheduled_at = models.DateTimeField(
        null=True,
        blank=True,
        help_text="When to send the batch (null = immediate)"
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    started_at = models.DateTimeField(null=True, blank=True)
    completed_at = models.DateTimeField(null=True, blank=True)
    
    # Created by
    created_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        related_name='created_notification_batches'
    )
    
    class Meta:
        db_table = 'notification_batches'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status'], name='idx_notif_batches_status'),
            models.Index(fields=['scheduled_at'], name='idx_notif_batches_scheduled'),
        ]
    
    def __str__(self):
        return f"Batch: {self.name} ({self.status})"
    
    @property
    def progress_percentage(self) -> float:
        """Calculate batch completion percentage."""
        if self.total_notifications == 0:
            return 0.0
        return (self.sent_notifications + self.failed_notifications) / self.total_notifications * 100


class NotificationEvent(models.Model):
    """
    Audit log for notification events.
    Tracks all notification-related actions for compliance and debugging.
    """
    
    class EventType(models.TextChoices):
        NOTIFICATION_CREATED = 'notification_created', 'Notification Created'
        NOTIFICATION_SENT = 'notification_sent', 'Notification Sent'
        NOTIFICATION_DELIVERED = 'notification_delivered', 'Notification Delivered'
        NOTIFICATION_READ = 'notification_read', 'Notification Read'
        NOTIFICATION_FAILED = 'notification_failed', 'Notification Failed'
        BATCH_CREATED = 'batch_created', 'Batch Created'
        BATCH_STARTED = 'batch_started', 'Batch Started'
        BATCH_COMPLETED = 'batch_completed', 'Batch Completed'
        PREFERENCES_UPDATED = 'preferences_updated', 'Preferences Updated'
        TEMPLATE_UPDATED = 'template_updated', 'Template Updated'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Event details
    event_type = models.CharField(max_length=30, choices=EventType.choices)
    description = models.TextField()
    
    # Related objects
    notification = models.ForeignKey(
        Notification,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='events'
    )
    batch = models.ForeignKey(
        NotificationBatch,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='events'
    )
    
    # User context
    user = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='notification_events'
    )
    
    # Technical details
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    
    # Additional data
    metadata = models.JSONField(
        default=dict,
        encoder=DjangoJSONEncoder,
        help_text="Additional event-specific data"
    )
    
    # Timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notification_events'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['event_type'], name='idx_notif_events_type'),
            models.Index(fields=['user', '-created_at'], name='idx_notif_events_user'),
            models.Index(fields=['created_at'], name='idx_notif_events_created'),
        ]
    
    def __str__(self):
        return f"{self.event_type} - {self.created_at}"


class NotificationCleanupLog(models.Model):
    """
    Tracks automatic cleanup operations for compliance and debugging.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Cleanup details
    notifications_deleted = models.IntegerField(default=0)
    batches_deleted = models.IntegerField(default=0)
    events_deleted = models.IntegerField(default=0)
    cleanup_reason = models.CharField(max_length=100)
    
    # Criteria used
    older_than_days = models.IntegerField(null=True, blank=True)
    status_filter = models.CharField(max_length=50, blank=True)
    
    # Metadata
    triggered_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'notification_cleanup_logs'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Cleanup: {self.notifications_deleted} notifications deleted"