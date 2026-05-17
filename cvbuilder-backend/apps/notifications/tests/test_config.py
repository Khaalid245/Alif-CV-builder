"""
Secure test configuration for notifications tests.
Centralizes test credentials and security settings.
"""
import os
from django.conf import settings

# Test user credentials - NOT for production use
TEST_USER_PASSWORD = os.getenv('TEST_USER_PASSWORD', 'secure_test_password_2024!')

# Test email settings
TEST_EMAIL_BACKEND = 'django.core.mail.backends.locmem.EmailBackend'

# Security settings for tests
TEST_SECURITY_SETTINGS = {
    'RATE_LIMIT_ENABLED': False,
    'EMAIL_VERIFICATION_REQUIRED': False,
    'AUDIT_LOGGING_ENABLED': True,
}

def get_test_user_password():
    """Get secure test password from environment or default."""
    return TEST_USER_PASSWORD

def create_test_user(email, **kwargs):
    """Create test user with secure password."""
    from django.contrib.auth import get_user_model
    User = get_user_model()
    
    defaults = {
        'password': get_test_user_password(),
        'is_active': True,
    }
    defaults.update(kwargs)
    
    return User.objects.create_user(email=email, **defaults)

def create_test_admin_user(email, **kwargs):
    """Create test admin user with secure password."""
    kwargs.update({
        'is_staff': True,
        'is_superuser': True,
    })
    return create_test_user(email, **kwargs)

class TestDataMixin:
    """Mixin for test classes to provide common test data."""
    
    @classmethod
    def setUpTestData(cls):
        """Set up test data once for the entire test class."""
        cls.test_password = get_test_user_password()
    
    def create_test_notification_template(self, **kwargs):
        """Create test notification template."""
        from ..models import NotificationTemplate
        
        defaults = {
            'name': 'test_template',
            'notification_type': 'cv_created',
            'title_template': 'Test: {user_name}',
            'message_template': 'Test message',
            'channel': 'both',
            'is_active': True,
        }
        defaults.update(kwargs)
        
        return NotificationTemplate.objects.create(**defaults)
    
    def create_test_notification(self, user, **kwargs):
        """Create test notification."""
        from ..models import Notification
        
        defaults = {
            'title': 'Test Notification',
            'message': 'Test message',
            'notification_type': 'test',
            'channel': 'in_app',
        }
        defaults.update(kwargs)
        
        return Notification.objects.create(user=user, **defaults)