"""
API views for Notifications system.
Provides REST endpoints for notification management operations.
"""
import logging
from typing import Dict, Any
from django.db.models import Count, Q
from django.utils import timezone
from django.http import Http404
from rest_framework import status, viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter

from apps.core.responses import success_response, error_response
from .models import (
    Notification, NotificationTemplate, NotificationBatch,
    NotificationEvent, UserNotificationPreference, 
    NotificationConfiguration, NotificationCleanupLog
)
from .serializers import (
    NotificationListSerializer, NotificationDetailSerializer,
    NotificationTemplateSerializer, NotificationBatchListSerializer,
    NotificationBatchDetailSerializer, NotificationEventSerializer,
    UserNotificationPreferenceSerializer, NotificationConfigurationSerializer,
    NotificationCleanupLogSerializer, CreateNotificationSerializer,
    CreateBulkNotificationSerializer, NotificationStatsSerializer,
    MarkAsReadSerializer
)
from .permissions import (
    CanViewNotifications, CanManageNotifications, CanCreateNotifications,
    CanManageTemplates, CanManageConfiguration, CanViewAuditLogs,
    CanManageBulkNotifications, CanManagePreferences, IsOwnerOrAdmin,
    get_user_notifications_queryset, get_user_batches_queryset
)
from .services import notification_service

logger = logging.getLogger(__name__)


def get_client_ip(request):
    """Extract client IP address from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def get_user_agent(request):
    """Extract user agent from request."""
    return request.META.get('HTTP_USER_AGENT', '')


class NotificationViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for user notifications.
    Provides list, retrieve, and custom actions for notifications.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanViewNotifications]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['notification_type', 'channel', 'status', 'priority']
    ordering_fields = ['created_at', 'priority']
    ordering = ['-created_at']
    search_fields = ['title', 'message']
    
    def get_queryset(self):
        """Get notifications for current user."""
        return get_user_notifications_queryset(self.request.user).select_related(
            'template', 'user'
        )
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'retrieve':
            return NotificationDetailSerializer
        return NotificationListSerializer
    
    def list(self, request, *args, **kwargs):
        """List notifications for user."""
        try:
            # Add unread filter if requested
            if request.query_params.get('unread_only') == 'true':
                self.queryset = self.get_queryset().exclude(
                    status=Notification.Status.READ
                )
            
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Notifications retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list notifications: {str(e)}")
            return error_response(
                message="Failed to retrieve notifications.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a specific notification."""
        try:
            response = super().retrieve(request, *args, **kwargs)
            return success_response(
                message="Notification retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to retrieve notification: {str(e)}")
            return error_response(
                message="Failed to retrieve notification.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated, CanManageNotifications])
    def mark_read(self, request, pk=None):
        """Mark a notification as read."""
        try:
            notification = self.get_object()
            
            success = notification_service.mark_notification_as_read(
                notification=notification,
                user=request.user,
                ip_address=get_client_ip(request)
            )
            
            if success:
                return success_response(
                    message="Notification marked as read successfully.",
                    data={'id': notification.id, 'status': notification.status}
                )
            else:
                return error_response(
                    message="Failed to mark notification as read.",
                    status_code=status.HTTP_400_BAD_REQUEST
                )
                
        except Exception as e:
            logger.error(f"Failed to mark notification as read: {str(e)}")
            return error_response(
                message="Failed to mark notification as read.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['post'], permission_classes=[permissions.IsAuthenticated, CanManageNotifications])
    def mark_multiple_read(self, request):
        """Mark multiple notifications as read."""
        try:
            serializer = MarkAsReadSerializer(data=request.data, context={'request': request})
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid request data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            notification_ids = serializer.validated_data['notification_ids']
            notifications = Notification.objects.filter(
                id__in=notification_ids,
                user=request.user
            )
            
            marked_count = 0
            for notification in notifications:
                success = notification_service.mark_notification_as_read(
                    notification=notification,
                    user=request.user,
                    ip_address=get_client_ip(request)
                )
                if success:
                    marked_count += 1
            
            return success_response(
                message=f"Marked {marked_count} notifications as read.",
                data={'marked_count': marked_count, 'total_requested': len(notification_ids)}
            )
            
        except Exception as e:
            logger.error(f"Failed to mark multiple notifications as read: {str(e)}")
            return error_response(
                message="Failed to mark notifications as read.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get notification statistics for user."""
        try:
            user_notifications = self.get_queryset()
            
            # Calculate statistics
            stats = user_notifications.aggregate(
                total=Count('id'),
                unread=Count('id', filter=Q(status__ne=Notification.Status.READ))
            )
            
            # Get counts by type
            by_type = user_notifications.values('notification_type').annotate(
                count=Count('id')
            ).order_by('notification_type')
            
            # Get counts by channel
            by_channel = user_notifications.values('channel').annotate(
                count=Count('id')
            ).order_by('channel')
            
            # Get counts by status
            by_status = user_notifications.values('status').annotate(
                count=Count('id')
            ).order_by('status')
            
            # Get recent notifications
            recent = user_notifications.order_by('-created_at')[:10]
            recent_serializer = NotificationListSerializer(recent, many=True)
            
            stats_data = {
                'total_notifications': stats['total'] or 0,
                'unread_notifications': stats['unread'] or 0,
                'notifications_by_type': {item['notification_type']: item['count'] for item in by_type},
                'notifications_by_channel': {item['channel']: item['count'] for item in by_channel},
                'notifications_by_status': {item['status']: item['count'] for item in by_status},
                'recent_notifications': recent_serializer.data
            }
            
            stats_serializer = NotificationStatsSerializer(stats_data)
            
            return success_response(
                message="Notification statistics retrieved successfully.",
                data=stats_serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get notification stats: {str(e)}")
            return error_response(
                message="Failed to retrieve notification statistics.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class NotificationTemplateViewSet(viewsets.ModelViewSet):
    """
    ViewSet for notification templates.
    Allows CRUD operations on templates (staff only for write operations).
    """
    
    queryset = NotificationTemplate.objects.all()
    serializer_class = NotificationTemplateSerializer
    permission_classes = [permissions.IsAuthenticated, CanManageTemplates]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['notification_type', 'channel', 'is_active']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']
    search_fields = ['name', 'title_template']
    
    def list(self, request, *args, **kwargs):
        """List notification templates."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Notification templates retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list templates: {str(e)}")
            return error_response(
                message="Failed to retrieve templates.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def create(self, request, *args, **kwargs):
        """Create a new notification template."""
        try:
            response = super().create(request, *args, **kwargs)
            return success_response(
                message="Notification template created successfully.",
                data=response.data,
                status_code=status.HTTP_201_CREATED
            )
        except Exception as e:
            logger.error(f"Failed to create template: {str(e)}")
            return error_response(
                message="Failed to create template.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class NotificationBatchViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for notification batches.
    Provides access to bulk notification operations.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanManageBulkNotifications]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['status', 'template__notification_type']
    ordering_fields = ['created_at', 'scheduled_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Get batches accessible to current user."""
        return get_user_batches_queryset(self.request.user).select_related(
            'template', 'created_by'
        ).prefetch_related('target_users')
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'retrieve':
            return NotificationBatchDetailSerializer
        return NotificationBatchListSerializer
    
    def list(self, request, *args, **kwargs):
        """List notification batches."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Notification batches retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list batches: {str(e)}")
            return error_response(
                message="Failed to retrieve batches.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CreateNotificationView(APIView):
    """
    API view for creating individual notifications.
    Only accessible by staff users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanCreateNotifications]
    
    def post(self, request):
        """Create a new notification."""
        try:
            serializer = CreateNotificationSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid notification data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Get target user
            from django.contrib.auth import get_user_model
            User = get_user_model()
            user = User.objects.get(id=data['user_id'])
            
            # Create notification
            notifications = notification_service.create_notification(
                user=user,
                notification_type=data['notification_type'],
                title=data.get('title'),
                message=data.get('message'),
                template_name=data.get('template_name'),
                context=data.get('context', {}),
                channel=data['channel'],
                priority=data['priority'],
                send_immediately=data['send_immediately']
            )
            
            return success_response(
                message="Notification created successfully.",
                data={
                    'notifications_created': len(notifications),
                    'notification_ids': [str(n.id) for n in notifications]
                },
                status_code=status.HTTP_201_CREATED
            )
            
        except Exception as e:
            logger.error(f"Failed to create notification: {str(e)}")
            return error_response(
                message="Failed to create notification.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CreateBulkNotificationView(APIView):
    """
    API view for creating bulk notifications.
    Only accessible by staff users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanManageBulkNotifications]
    
    def post(self, request):
        """Create a bulk notification batch."""
        try:
            serializer = CreateBulkNotificationSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid bulk notification data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Get target users
            from django.contrib.auth import get_user_model
            User = get_user_model()
            users = User.objects.filter(id__in=data['user_ids'])
            
            # Create batch
            batch = notification_service.create_bulk_notification(
                users=list(users),
                notification_type=data['notification_type'],
                template_name=data['template_name'],
                context=data.get('context', {}),
                name=data.get('name'),
                description=data.get('description', ''),
                created_by=request.user,
                scheduled_at=data.get('scheduled_at')
            )
            
            batch_serializer = NotificationBatchDetailSerializer(batch)
            
            return success_response(
                message="Bulk notification batch created successfully.",
                data=batch_serializer.data,
                status_code=status.HTTP_201_CREATED
            )
            
        except Exception as e:
            logger.error(f"Failed to create bulk notification: {str(e)}")
            return error_response(
                message="Failed to create bulk notification.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class UserNotificationPreferenceView(APIView):
    """
    API view for user notification preferences.
    Users can view and update their own preferences.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanManagePreferences]
    
    def get(self, request):
        """Get user's notification preferences."""
        try:
            preferences = notification_service._get_user_preferences(request.user)
            serializer = UserNotificationPreferenceSerializer(preferences)
            
            return success_response(
                message="Notification preferences retrieved successfully.",
                data=serializer.data
            )
        except Exception as e:
            logger.error(f"Failed to get preferences: {str(e)}")
            return error_response(
                message="Failed to retrieve preferences.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def put(self, request):
        """Update user's notification preferences."""
        try:
            preferences = notification_service._get_user_preferences(request.user)
            serializer = UserNotificationPreferenceSerializer(
                preferences, 
                data=request.data, 
                partial=True
            )
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid preference data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            
            return success_response(
                message="Notification preferences updated successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to update preferences: {str(e)}")
            return error_response(
                message="Failed to update preferences.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class NotificationConfigurationView(APIView):
    """
    API view for notification configuration management.
    Only accessible by staff users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanManageConfiguration]
    
    def get(self, request):
        """Get current notification configuration."""
        try:
            config = notification_service.config
            serializer = NotificationConfigurationSerializer(config)
            
            return success_response(
                message="Notification configuration retrieved successfully.",
                data=serializer.data
            )
        except Exception as e:
            logger.error(f"Failed to get configuration: {str(e)}")
            return error_response(
                message="Failed to retrieve configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def put(self, request):
        """Update notification configuration."""
        try:
            config = notification_service.config
            serializer = NotificationConfigurationSerializer(
                config, 
                data=request.data, 
                partial=True
            )
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid configuration data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            
            # Refresh service configuration
            notification_service._config = serializer.instance
            
            return success_response(
                message="Notification configuration updated successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to update configuration: {str(e)}")
            return error_response(
                message="Failed to update configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class NotificationEventViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for notification events (audit log).
    Provides access to notification-related events for audit purposes.
    """
    
    serializer_class = NotificationEventSerializer
    permission_classes = [permissions.IsAuthenticated, CanViewAuditLogs]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['event_type', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Get events for user or all events if admin."""
        if self.request.user.is_staff:
            return NotificationEvent.objects.all().select_related('user', 'notification')
        
        return NotificationEvent.objects.filter(
            user=self.request.user
        ).select_related('user', 'notification')
    
    def list(self, request, *args, **kwargs):
        """List notification events."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Notification events retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list events: {str(e)}")
            return error_response(
                message="Failed to retrieve events.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )