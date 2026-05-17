"""
Serializers for Notifications API.
Handles serialization of notification data, templates, and preferences.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from django.utils import timezone

from .models import (
    Notification, NotificationTemplate, NotificationBatch,
    NotificationEvent, UserNotificationPreference, 
    NotificationConfiguration, NotificationCleanupLog
)

User = get_user_model()


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user info for notifications."""
    
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name']
        read_only_fields = fields


class NotificationConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for notification configuration."""
    
    class Meta:
        model = NotificationConfiguration
        fields = [
            'id', 'email_enabled', 'email_rate_limit', 'in_app_enabled',
            'max_notifications_per_user', 'auto_cleanup_enabled',
            'cleanup_after_days', 'batch_size', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class NotificationTemplateSerializer(serializers.ModelSerializer):
    """Serializer for notification templates."""
    
    class Meta:
        model = NotificationTemplate
        fields = [
            'id', 'name', 'notification_type', 'title_template',
            'message_template', 'email_subject_template', 'email_html_template',
            'channel', 'priority', 'is_active', 'requires_user_preference',
            'available_variables', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_name(self, value):
        """Ensure template name is unique."""
        if self.instance and self.instance.name == value:
            return value
        
        if NotificationTemplate.objects.filter(name=value).exists():
            raise serializers.ValidationError("Template with this name already exists.")
        
        return value


class UserNotificationPreferenceSerializer(serializers.ModelSerializer):
    """Serializer for user notification preferences."""
    
    class Meta:
        model = UserNotificationPreference
        fields = [
            'id', 'email_notifications_enabled', 'in_app_notifications_enabled',
            'cv_updates_email', 'cv_updates_in_app', 'workflow_changes_email',
            'workflow_changes_in_app', 'system_notifications_email',
            'system_notifications_in_app', 'security_alerts_email',
            'security_alerts_in_app', 'digest_frequency', 'quiet_hours_enabled',
            'quiet_hours_start', 'quiet_hours_end', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate(self, data):
        """Validate quiet hours configuration."""
        if data.get('quiet_hours_enabled'):
            if not data.get('quiet_hours_start') or not data.get('quiet_hours_end'):
                raise serializers.ValidationError(
                    "Quiet hours start and end times are required when quiet hours are enabled."
                )
        
        return data


class NotificationListSerializer(serializers.ModelSerializer):
    """Serializer for notification list view."""
    
    template_name = serializers.SerializerMethodField()
    is_read = serializers.SerializerMethodField()
    time_ago = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'notification_type', 'channel',
            'priority', 'status', 'template_name', 'is_read', 'time_ago',
            'created_at', 'read_at'
        ]
        read_only_fields = fields
    
    def get_template_name(self, obj):
        return obj.template.name if obj.template else None
    
    def get_is_read(self, obj):
        return obj.is_read
    
    def get_time_ago(self, obj):
        """Calculate human-readable time ago."""
        from django.utils.html import escape
        
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


class NotificationDetailSerializer(serializers.ModelSerializer):
    """Serializer for detailed notification view."""
    
    template = NotificationTemplateSerializer(read_only=True)
    template_name = serializers.SerializerMethodField()
    is_read = serializers.SerializerMethodField()
    related_object_info = serializers.SerializerMethodField()
    
    class Meta:
        model = Notification
        fields = [
            'id', 'title', 'message', 'notification_type', 'channel',
            'priority', 'status', 'template', 'template_name', 'is_read',
            'context_data', 'email_subject', 'error_message', 'retry_count',
            'related_object_info', 'created_at', 'sent_at', 'delivered_at',
            'read_at'
        ]
        read_only_fields = fields
    
    def get_template_name(self, obj):
        return obj.template.name if obj.template else None
    
    def get_is_read(self, obj):
        return obj.is_read
    
    def get_related_object_info(self, obj):
        """Get basic info about related object."""
        from django.utils.html import escape
        
        if obj.related_object:
            return {
                'type': escape(obj.content_type.model),
                'id': escape(str(obj.object_id)),
                'name': escape(str(obj.related_object))
            }
        return None


class NotificationBatchListSerializer(serializers.ModelSerializer):
    """Serializer for notification batch list view."""
    
    template_name = serializers.SerializerMethodField()
    created_by_email = serializers.SerializerMethodField()
    progress_percentage = serializers.SerializerMethodField()
    
    class Meta:
        model = NotificationBatch
        fields = [
            'id', 'name', 'description', 'template_name', 'status',
            'total_notifications', 'sent_notifications', 'failed_notifications',
            'progress_percentage', 'scheduled_at', 'created_by_email',
            'created_at', 'started_at', 'completed_at'
        ]
        read_only_fields = fields
    
    def get_template_name(self, obj):
        return obj.template.name
    
    def get_created_by_email(self, obj):
        return obj.created_by.email if obj.created_by else None
    
    def get_progress_percentage(self, obj):
        return obj.progress_percentage


class NotificationBatchDetailSerializer(serializers.ModelSerializer):
    """Serializer for detailed notification batch view."""
    
    template = NotificationTemplateSerializer(read_only=True)
    created_by = UserBasicSerializer(read_only=True)
    target_users = UserBasicSerializer(many=True, read_only=True)
    progress_percentage = serializers.SerializerMethodField()
    
    class Meta:
        model = NotificationBatch
        fields = [
            'id', 'name', 'description', 'template', 'target_users',
            'context_data', 'status', 'total_notifications',
            'sent_notifications', 'failed_notifications', 'progress_percentage',
            'scheduled_at', 'created_by', 'created_at', 'started_at',
            'completed_at'
        ]
        read_only_fields = fields
    
    def get_progress_percentage(self, obj):
        return obj.progress_percentage


class CreateNotificationSerializer(serializers.Serializer):
    """Serializer for creating individual notifications."""
    
    user_id = serializers.UUIDField()
    notification_type = serializers.CharField(max_length=30)
    title = serializers.CharField(max_length=255, required=False)
    message = serializers.CharField(required=False)
    template_name = serializers.CharField(max_length=100, required=False)
    context = serializers.JSONField(required=False, default=dict)
    channel = serializers.ChoiceField(
        choices=['in_app', 'email', 'both'],
        default='both'
    )
    priority = serializers.ChoiceField(
        choices=['low', 'normal', 'high', 'urgent'],
        default='normal'
    )
    send_immediately = serializers.BooleanField(default=True)
    
    def validate(self, data):
        """Validate notification creation data."""
        if not data.get('title') and not data.get('template_name'):
            raise serializers.ValidationError(
                "Either title or template_name must be provided."
            )
        
        if not data.get('message') and not data.get('template_name'):
            raise serializers.ValidationError(
                "Either message or template_name must be provided."
            )
        
        # Validate user exists
        try:
            User.objects.get(id=data['user_id'])
        except User.DoesNotExist:
            raise serializers.ValidationError("User not found.")
        
        # Validate template exists if provided
        if data.get('template_name'):
            try:
                NotificationTemplate.objects.get(
                    name=data['template_name'],
                    is_active=True
                )
            except NotificationTemplate.DoesNotExist:
                raise serializers.ValidationError("Template not found or inactive.")
        
        return data


class CreateBulkNotificationSerializer(serializers.Serializer):
    """Serializer for creating bulk notifications."""
    
    user_ids = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1,
        max_length=1000  # Limit bulk operations
    )
    notification_type = serializers.CharField(max_length=30)
    template_name = serializers.CharField(max_length=100)
    context = serializers.JSONField(required=False, default=dict)
    name = serializers.CharField(max_length=255, required=False)
    description = serializers.CharField(required=False, default='')
    scheduled_at = serializers.DateTimeField(required=False)
    
    def validate_user_ids(self, value):
        """Validate that all user IDs exist."""
        existing_users = User.objects.filter(id__in=value).count()
        if existing_users != len(value):
            raise serializers.ValidationError(
                "One or more user IDs are invalid."
            )
        return value
    
    def validate_template_name(self, value):
        """Validate template exists and is active."""
        try:
            NotificationTemplate.objects.get(name=value, is_active=True)
        except NotificationTemplate.DoesNotExist:
            raise serializers.ValidationError("Template not found or inactive.")
        return value


class NotificationEventSerializer(serializers.ModelSerializer):
    """Serializer for notification events (audit log)."""
    
    user = UserBasicSerializer(read_only=True)
    notification_title = serializers.SerializerMethodField()
    batch_name = serializers.SerializerMethodField()
    
    class Meta:
        model = NotificationEvent
        fields = [
            'id', 'event_type', 'description', 'user', 'notification_title',
            'batch_name', 'ip_address', 'metadata', 'created_at'
        ]
        read_only_fields = fields
    
    def get_notification_title(self, obj):
        return obj.notification.title if obj.notification else None
    
    def get_batch_name(self, obj):
        return obj.batch.name if obj.batch else None


class NotificationStatsSerializer(serializers.Serializer):
    """Serializer for notification statistics."""
    
    total_notifications = serializers.IntegerField(read_only=True)
    unread_notifications = serializers.IntegerField(read_only=True)
    notifications_by_type = serializers.DictField(read_only=True)
    notifications_by_channel = serializers.DictField(read_only=True)
    notifications_by_status = serializers.DictField(read_only=True)
    recent_notifications = NotificationListSerializer(many=True, read_only=True)


class MarkAsReadSerializer(serializers.Serializer):
    """Serializer for marking notifications as read."""
    
    notification_ids = serializers.ListField(
        child=serializers.UUIDField(),
        min_length=1,
        max_length=100
    )
    
    def validate_notification_ids(self, value):
        """Validate that all notification IDs exist and belong to the user."""
        user = self.context['request'].user
        existing_notifications = Notification.objects.filter(
            id__in=value,
            user=user
        ).count()
        
        if existing_notifications != len(value):
            raise serializers.ValidationError(
                "One or more notification IDs are invalid or don't belong to you."
            )
        
        return value


class NotificationCleanupLogSerializer(serializers.ModelSerializer):
    """Serializer for cleanup logs."""
    
    triggered_by = UserBasicSerializer(read_only=True)
    
    class Meta:
        model = NotificationCleanupLog
        fields = [
            'id', 'notifications_deleted', 'batches_deleted', 'events_deleted',
            'cleanup_reason', 'older_than_days', 'status_filter',
            'triggered_by', 'created_at'
        ]
        read_only_fields = fields