"""
Secure test configuration for EduCV.
Eliminates hardcoded credentials and provides secure test utilities.
"""
import os
import secrets
import string
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.conf import settings

User = get_user_model()


class SecureTestMixin:
    """Mixin providing secure test utilities without hardcoded credentials."""
    
    @staticmethod
    def generate_secure_password(length=16):
        """Generate cryptographically secure random password for tests."""
        alphabet = string.ascii_letters + string.digits + "!@#$%^&*"
        return ''.join(secrets.choice(alphabet) for _ in range(length))
    
    @staticmethod
    def generate_test_email(prefix="test"):
        """Generate unique test email address."""
        random_suffix = secrets.token_hex(8)
        return f"{prefix}_{random_suffix}@example.com"
    
    def create_test_user(self, email=None, **kwargs):
        """Create test user with secure random password."""
        if not email:
            email = self.generate_test_email()
        
        password = self.generate_secure_password()
        
        user_data = {
            'email': email,
            'password': password,
            'first_name': kwargs.get('first_name', 'Test'),
            'last_name': kwargs.get('last_name', 'User'),
            **kwargs
        }
        
        user = User.objects.create_user(**user_data)
        # Store password for test assertions if needed
        user._test_password = password
        return user
    
    def create_test_admin_user(self, email=None):
        """Create test admin user with secure credentials."""
        if not email:
            email = self.generate_test_email("admin")
        
        return self.create_test_user(
            email=email,
            is_staff=True,
            is_superuser=True,
            first_name='Admin',
            last_name='User'
        )


class SecureTestCase(TestCase, SecureTestMixin):
    """Base test case with secure credential handling."""
    
    def setUp(self):
        """Set up test environment with secure defaults."""
        super().setUp()
        # Override any insecure test settings
        if hasattr(settings, 'PASSWORD_HASHERS'):
            # Use fast hasher for tests while maintaining security
            settings.PASSWORD_HASHERS = [
                'django.contrib.auth.hashers.MD5PasswordHasher',
            ]


# Environment-based test configuration
TEST_CONFIG = {
    'USE_SECURE_PASSWORDS': os.getenv('TEST_USE_SECURE_PASSWORDS', 'true').lower() == 'true',
    'MIN_PASSWORD_LENGTH': int(os.getenv('TEST_MIN_PASSWORD_LENGTH', '12')),
    'REQUIRE_COMPLEX_PASSWORDS': os.getenv('TEST_REQUIRE_COMPLEX_PASSWORDS', 'true').lower() == 'true',
}


def get_test_password():
    """Get secure test password from environment or generate one."""
    # Check for environment variable first
    env_password = os.getenv('TEST_USER_PASSWORD')
    if env_password:
        return env_password
    
    # Generate secure password if not provided
    if TEST_CONFIG['USE_SECURE_PASSWORDS']:
        length = TEST_CONFIG['MIN_PASSWORD_LENGTH']
        alphabet = string.ascii_letters + string.digits
        
        if TEST_CONFIG['REQUIRE_COMPLEX_PASSWORDS']:
            alphabet += "!@#$%^&*"
        
        return ''.join(secrets.choice(alphabet) for _ in range(length))
    
    # Fallback for legacy tests (not recommended)
    return 'test_password_123'


def create_secure_test_user(email=None, **kwargs):
    """Create test user with secure password management."""
    if not email:
        email = f"test_{secrets.token_hex(8)}@example.com"
    
    password = get_test_password()
    
    user_data = {
        'email': email,
        'password': password,
        'first_name': kwargs.get('first_name', 'Test'),
        'last_name': kwargs.get('last_name', 'User'),
        **kwargs
    }
    
    user = User.objects.create_user(**user_data)
    # Store password for test assertions (not logged)
    user._test_password = password
    return user


def create_secure_admin_user(email=None):
    """Create admin user with secure credentials."""
    if not email:
        email = f"admin_{secrets.token_hex(8)}@example.com"
    
    return create_secure_test_user(
        email=email,
        is_staff=True,
        is_superuser=True,
        first_name='Admin',
        last_name='User'
    )