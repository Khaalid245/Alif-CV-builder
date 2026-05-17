"""
URL configuration for Notifications API.
Provides REST endpoints for notification management operations.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter

from .views import (
    NotificationViewSet, NotificationTemplateViewSet, NotificationBatchViewSet,
    NotificationEventViewSet, CreateNotificationView, CreateBulkNotificationView,
    UserNotificationPreferenceView, NotificationConfigurationView
)

app_name = 'notifications'

# Create router for viewsets
router = DefaultRouter()
router.register(r'notifications', NotificationViewSet, basename='notifications')
router.register(r'templates', NotificationTemplateViewSet, basename='templates')
router.register(r'batches', NotificationBatchViewSet, basename='batches')
router.register(r'events', NotificationEventViewSet, basename='events')

urlpatterns = [
    # ViewSet routes
    path('', include(router.urls)),
    
    # Custom API views
    path('create/', CreateNotificationView.as_view(), name='create-notification'),
    path('bulk-create/', CreateBulkNotificationView.as_view(), name='bulk-create-notification'),
    path('preferences/', UserNotificationPreferenceView.as_view(), name='user-preferences'),
    path('configuration/', NotificationConfigurationView.as_view(), name='configuration'),
]