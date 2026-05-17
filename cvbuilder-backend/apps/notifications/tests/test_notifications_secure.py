"""
Comprehensive tests for Notifications system.
Tests models, services, views, and permissions.
"""
import json
from datetime import timedelta
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from unittest.mock import patch, MagicMock

from apps.cv.models import CVProfile
from ..models import (
    Notification, NotificationTemplate, NotificationBatch,
    NotificationEvent, UserNotificationPreference, NotificationConfiguration
)
from ..services import notification_service
from .test_config import TestDataMixin, create_test_user, create_test_admin_user

User = get_user_model()


class NotificationModelTest(TestCase, TestDataMixin):
    """Test notification models."""
    
    def setUp(self):
        self.user = create_test_user('test@example.com')
        self.template = self.create_test_notification_template(
            title_template='CV Created: {user_name}',
            message_template='Your CV has been created successfully.'
        )
    
    def test_notification_creation(self):
        """Test notification model creation."""
        notification = Notification.objects.create(
            user=self.user,
            template=self.template,
            title='Test Notification',
            message='Test message',
            notification_type='cv_created',
            channel='in_app'
        )
        
        self.assertEqual(notification.user, self.user)
        self.assertEqual(notification.template, self.template)
        self.assertEqual(notification.status, Notification.Status.PENDING)
        self.assertFalse(notification.is_read)
    
    def test_notification_mark_as_read(self):
        """Test marking notification as read."""
        notification = self.create_test_notification(self.user)
        
        self.assertFalse(notification.is_read)
        notification.mark_as_read()
        
        self.assertTrue(notification.is_read)
        self.assertEqual(notification.status, Notification.Status.READ)
        self.assertIsNotNone(notification.read_at)
    
    def test_template_rendering(self):
        """Test template rendering with context."""
        context = {'user_name': 'John Doe'}
        
        title = self.template.render_title(context)
        message = self.template.render_message(context)
        
        self.assertEqual(title, 'CV Created: John Doe')
        self.assertEqual(message, 'Your CV has been created successfully.')
    
    def test_user_preferences_creation(self):
        """Test user notification preferences."""
        preferences = UserNotificationPreference.objects.create(
            user=self.user,
            email_notifications_enabled=True,
            cv_updates_email=False
        )
        
        self.assertTrue(preferences.allows_notification('system_maintenance', 'email'))
        self.assertFalse(preferences.allows_notification('cv_created', 'email'))


class NotificationServiceTest(TestCase, TestDataMixin):
    """Test notification service functionality."""
    
    def setUp(self):
        self.user = create_test_user('test@example.com')
        self.template = self.create_test_notification_template(
            title_template='CV Created: {user_name}',
            message_template='Your CV has been created successfully.'
        )
    
    @patch('apps.notifications.services.send_mail')
    def test_create_notification_with_template(self, mock_send_mail):
        """Test creating notification with template."""
        notifications = notification_service.create_notification(
            user=self.user,
            notification_type='cv_created',
            template_name='test_template',
            context={'user_name': 'John Doe'},
            send_immediately=True
        )
        
        self.assertEqual(len(notifications), 2)  # in_app + email
        
        # Check in-app notification
        in_app_notif = next(n for n in notifications if n.channel == 'in_app')
        self.assertEqual(in_app_notif.title, 'CV Created: John Doe')
        self.assertEqual(in_app_notif.status, Notification.Status.SENT)
        
        # Check email notification
        email_notif = next(n for n in notifications if n.channel == 'email')
        self.assertEqual(email_notif.channel, 'email')
        mock_send_mail.assert_called_once()
    
    def test_create_notification_without_template(self):
        """Test creating notification without template."""
        notifications = notification_service.create_notification(
            user=self.user,
            notification_type='custom',
            title='Custom Title',
            message='Custom Message',
            channel='in_app',
            send_immediately=True
        )
        
        self.assertEqual(len(notifications), 1)
        notification = notifications[0]
        self.assertEqual(notification.title, 'Custom Title')
        self.assertEqual(notification.message, 'Custom Message')
    
    def test_bulk_notification_creation(self):
        """Test bulk notification creation."""
        users = [
            create_test_user(f'user{i}@example.com')
            for i in range(3)
        ]
        
        batch = notification_service.create_bulk_notification(
            users=users,
            notification_type='cv_created',
            template_name='test_template',
            context={'user_name': 'Test User'},
            name='Test Batch'
        )
        
        self.assertEqual(batch.total_notifications, 3)
        self.assertEqual(batch.status, NotificationBatch.Status.COMPLETED)
    
    def test_user_preferences_respected(self):
        """Test that user preferences are respected."""
        # Create user with email disabled
        preferences = UserNotificationPreference.objects.create(
            user=self.user,
            email_notifications_enabled=False
        )
        
        notifications = notification_service.create_notification(
            user=self.user,
            notification_type='cv_created',
            template_name='test_template',
            context={'user_name': 'John Doe'},
            send_immediately=True
        )
        
        # Should only create in-app notification
        self.assertEqual(len(notifications), 1)
        self.assertEqual(notifications[0].channel, 'in_app')


class NotificationAPITest(TestCase, TestDataMixin):
    """Test notification API endpoints."""
    
    def setUp(self):
        self.client = APIClient()
        self.user = create_test_user('test@example.com')
        self.admin_user = create_test_admin_user('admin@example.com')
        self.template = self.create_test_notification_template()
        
        # Create test notifications
        self.notification1 = self.create_test_notification(
            self.user,
            title='Test Notification 1',
            message='Test message 1',
            notification_type='cv_created'
        )
        
        self.notification2 = self.create_test_notification(
            self.user,
            title='Test Notification 2',
            message='Test message 2',
            notification_type='cv_updated',
            channel='email',
            status=Notification.Status.READ
        )
    
    def get_jwt_token(self, user):
        """Get JWT token for user."""
        refresh = RefreshToken.for_user(user)
        return str(refresh.access_token)
    
    def authenticate(self, user):
        """Authenticate client with user."""
        token = self.get_jwt_token(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    
    def test_list_notifications(self):
        """Test listing user notifications."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertEqual(len(data['data']['results']), 2)
    
    def test_list_notifications_unread_only(self):
        """Test listing only unread notifications."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-list')
        response = self.client.get(url, {'unread_only': 'true'})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(len(data['data']['results']), 1)
    
    def test_retrieve_notification(self):
        """Test retrieving specific notification."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-detail', kwargs={'pk': self.notification1.id})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['data']['title'], 'Test Notification 1')
    
    def test_mark_notification_as_read(self):
        """Test marking notification as read."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-mark-read', kwargs={'pk': self.notification1.id})
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify notification is marked as read
        self.notification1.refresh_from_db()
        self.assertTrue(self.notification1.is_read)
    
    def test_mark_multiple_notifications_as_read(self):
        """Test marking multiple notifications as read."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-mark-multiple-read')
        data = {
            'notification_ids': [str(self.notification1.id)]
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['data']['marked_count'], 1)
    
    def test_notification_stats(self):
        """Test notification statistics endpoint."""
        self.authenticate(self.user)
        
        url = reverse('notifications:notifications-stats')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertEqual(data['data']['total_notifications'], 2)
        self.assertEqual(data['data']['unread_notifications'], 1)
    
    def test_create_notification_as_admin(self):
        """Test creating notification as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('notifications:create-notification')
        data = {
            'user_id': str(self.user.id),
            'notification_type': 'cv_created',
            'template_name': 'test_template',
            'context': {'user_name': 'John Doe'},
            'channel': 'both'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        data = response.json()
        self.assertEqual(data['data']['notifications_created'], 2)
    
    def test_create_notification_as_user_forbidden(self):
        """Test that regular users cannot create notifications."""
        self.authenticate(self.user)
        
        url = reverse('notifications:create-notification')
        data = {
            'user_id': str(self.user.id),
            'notification_type': 'cv_created',
            'title': 'Test'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_user_preferences_get(self):
        """Test getting user preferences."""
        self.authenticate(self.user)
        
        url = reverse('notifications:user-preferences')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['data']['email_notifications_enabled'])
    
    def test_user_preferences_update(self):
        """Test updating user preferences."""
        self.authenticate(self.user)
        
        url = reverse('notifications:user-preferences')
        data = {
            'email_notifications_enabled': False,
            'cv_updates_email': False
        }
        response = self.client.put(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify preferences updated
        preferences = UserNotificationPreference.objects.get(user=self.user)
        self.assertFalse(preferences.email_notifications_enabled)
    
    def test_template_list_as_user(self):
        """Test listing templates as regular user."""
        self.authenticate(self.user)
        
        url = reverse('notifications:templates-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_template_create_as_admin(self):
        """Test creating template as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('notifications:templates-list')
        data = {
            'name': 'new_template',
            'notification_type': 'cv_updated',
            'title_template': 'New Template: {user_name}',
            'message_template': 'New message',
            'channel': 'in_app'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    def test_template_create_as_user_forbidden(self):
        """Test that regular users cannot create templates."""
        self.authenticate(self.user)
        
        url = reverse('notifications:templates-list')
        data = {
            'name': 'user_template',
            'notification_type': 'cv_updated',
            'title_template': 'Test',
            'message_template': 'Test'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_configuration_get_as_admin(self):
        """Test getting configuration as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('notifications:configuration')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_configuration_update_as_admin(self):
        """Test updating configuration as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('notifications:configuration')
        data = {
            'email_enabled': False,
            'email_rate_limit': 50
        }
        response = self.client.put(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_configuration_access_as_user_forbidden(self):
        """Test that regular users cannot access configuration."""
        self.authenticate(self.user)
        
        url = reverse('notifications:configuration')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_unauthenticated_access_forbidden(self):
        """Test that unauthenticated users cannot access notifications."""
        url = reverse('notifications:notifications-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class NotificationPermissionTest(TestCase, TestDataMixin):
    """Test notification permissions."""
    
    def setUp(self):
        self.user1 = create_test_user('user1@example.com')
        self.user2 = create_test_user('user2@example.com')
        self.admin_user = create_test_admin_user('admin@example.com')
        self.notification = self.create_test_notification(self.user1)
    
    def test_user_can_only_access_own_notifications(self):
        """Test that users can only access their own notifications."""
        client = APIClient()
        
        # Authenticate as user2
        refresh = RefreshToken.for_user(self.user2)
        token = str(refresh.access_token)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        
        # Try to access user1's notification
        url = reverse('notifications:notifications-detail', kwargs={'pk': self.notification.id})
        response = client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_admin_can_access_all_notifications(self):
        """Test that admin users can access all notifications."""
        client = APIClient()
        
        # Authenticate as admin
        refresh = RefreshToken.for_user(self.admin_user)
        token = str(refresh.access_token)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        
        # Access user1's notification
        url = reverse('notifications:notifications-detail', kwargs={'pk': self.notification.id})
        response = client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class NotificationSignalTest(TestCase, TestDataMixin):
    """Test notification signals."""
    
    def setUp(self):
        self.user = create_test_user('test@example.com')
        
        # Create required templates
        NotificationTemplate.objects.create(
            name='cv_created',
            notification_type='cv_created',
            title_template='CV Created',
            message_template='Your CV has been created.',
            channel='both'
        )
    
    @patch('apps.notifications.services.notification_service.create_notification')
    def test_cv_profile_creation_signal(self, mock_create_notification):
        """Test that CV profile creation triggers notification."""
        cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890'
        )
        
        # Verify notification was created
        mock_create_notification.assert_called()
        call_args = mock_create_notification.call_args
        self.assertEqual(call_args[1]['user'], self.user)
        self.assertEqual(call_args[1]['notification_type'], 'cv_created')