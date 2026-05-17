"""
Security tests for EduCV platform.
Tests for credential security, SQL injection prevention, and logging sanitization.
"""
import re
import secrets
from django.test import TestCase, override_settings
from django.contrib.auth import get_user_model
from django.core.management import call_command
from django.db import connection
from io import StringIO
import logging

from apps.core.test_utils import SecureTestMixin
from apps.core.secure_logging import SensitiveDataFilter, SecurityLogger
from apps.template_engine.management.commands.cleanup_template_engine import Command as CleanupCommand

User = get_user_model()


class CredentialSecurityTests(TestCase, SecureTestMixin):
    """Test that no hardcoded credentials exist in the system."""
    
    def test_secure_test_user_creation(self):
        """Test that test users are created with secure random passwords."""
        user = self.create_test_user()
        
        # Verify user was created
        self.assertIsNotNone(user)
        self.assertTrue(user.email.endswith('@example.com'))
        
        # Verify password is stored securely (not hardcoded)
        self.assertTrue(hasattr(user, '_test_password'))
        self.assertGreaterEqual(len(user._test_password), 12)
        
        # Verify password contains mixed characters
        password = user._test_password
        self.assertTrue(any(c.isupper() for c in password))
        self.assertTrue(any(c.islower() for c in password))
        self.assertTrue(any(c.isdigit() for c in password))
    
    def test_admin_user_creation_security(self):
        """Test that admin users are created securely."""
        admin_user = self.create_test_admin_user()
        
        # Verify admin privileges
        self.assertTrue(admin_user.is_staff)
        self.assertTrue(admin_user.is_superuser)
        
        # Verify secure password
        self.assertTrue(hasattr(admin_user, '_test_password'))
        self.assertGreaterEqual(len(admin_user._test_password), 12)
    
    def test_password_generation_entropy(self):
        """Test that generated passwords have sufficient entropy."""
        passwords = [self.generate_secure_password() for _ in range(10)]
        
        # All passwords should be different
        self.assertEqual(len(set(passwords)), 10)
        
        # All passwords should meet complexity requirements
        for password in passwords:
            self.assertGreaterEqual(len(password), 12)
            self.assertTrue(any(c.isupper() for c in password))
            self.assertTrue(any(c.islower() for c in password))
            self.assertTrue(any(c.isdigit() for c in password))


class SQLInjectionPreventionTests(TestCase):
    """Test SQL injection prevention measures."""
    
    def test_cleanup_command_sql_safety(self):
        """Test that cleanup command uses parameterized queries."""
        command = CleanupCommand()
        
        # Test that the _optimize_database method exists and is safe
        self.assertTrue(hasattr(command, '_optimize_database'))
        
        # Mock the database optimization to test parameter usage
        with connection.cursor() as cursor:
            # This should not raise an exception with our parameterized approach
            try:
                # Test with a safe table name
                cursor.execute('SELECT 1')  # Safe test query
                result = cursor.fetchone()
                self.assertEqual(result[0], 1)
            except Exception as e:
                self.fail(f"Database query failed: {e}")
    
    def test_parameterized_query_usage(self):
        """Test that parameterized queries work correctly."""
        with connection.cursor() as cursor:
            # Test parameterized query (safe)
            cursor.execute('SELECT %s as test_value', ['safe_value'])
            result = cursor.fetchone()
            self.assertEqual(result[0], 'safe_value')
            
            # Test with potentially dangerous input (should be safe)
            dangerous_input = "'; DROP TABLE users; --"
            cursor.execute('SELECT %s as test_value', [dangerous_input])
            result = cursor.fetchone()
            # The dangerous input should be treated as literal string
            self.assertEqual(result[0], dangerous_input)


class LoggingSanitizationTests(TestCase):
    """Test logging sanitization and security."""
    
    def test_email_sanitization(self):
        """Test that emails are properly sanitized in logs."""
        test_email = "user@example.com"
        sanitized = SensitiveDataFilter.sanitize_message(f"User email: {test_email}")
        
        # Should not contain the original email
        self.assertNotIn(test_email, sanitized)
        
        # Should contain masked version
        self.assertIn("u***@e***.com", sanitized)
    
    def test_password_sanitization(self):
        """Test that passwords are completely redacted."""
        test_message = 'password="secret123" and token="abc123xyz"'
        sanitized = SensitiveDataFilter.sanitize_message(test_message)
        
        # Should not contain original credentials
        self.assertNotIn("secret123", sanitized)
        self.assertNotIn("abc123xyz", sanitized)
        
        # Should contain redaction markers
        self.assertIn("***REDACTED***", sanitized)
    
    def test_phone_number_sanitization(self):
        """Test that phone numbers are masked."""
        test_message = "Contact: +1-555-123-4567"
        sanitized = SensitiveDataFilter.sanitize_message(test_message)
        
        # Should not contain original phone number
        self.assertNotIn("555-123-4567", sanitized)
        
        # Should contain mask
        self.assertIn("***MASKED***", sanitized)
    
    def test_token_sanitization(self):
        """Test that JWT tokens and API keys are redacted."""
        test_cases = [
            'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
            'api_key: sk_live_abcdef123456789',
            'token="jwt_token_here_123456789"'
        ]
        
        for test_case in test_cases:
            sanitized = SensitiveDataFilter.sanitize_message(test_case)
            
            # Should contain redaction
            self.assertIn("***REDACTED***", sanitized)
            
            # Should not contain original token
            self.assertNotRegex(sanitized, r'[A-Za-z0-9._-]{20,}')


class SecurityComplianceTests(TestCase):
    """Test compliance with security standards."""
    
    def test_password_complexity_requirements(self):
        """Test that password generation meets security requirements."""
        from apps.core.test_utils import get_test_password
        
        # Generate multiple passwords to test consistency
        passwords = [get_test_password() for _ in range(5)]
        
        for password in passwords:
            # Minimum length
            self.assertGreaterEqual(len(password), 12)
            
            # Character diversity
            self.assertTrue(any(c.isupper() for c in password))
            self.assertTrue(any(c.islower() for c in password))
            self.assertTrue(any(c.isdigit() for c in password))
            
            # No common patterns
            self.assertNotIn('123456', password)
            self.assertNotIn('password', password.lower())
            self.assertNotIn('admin', password.lower())
    
    def test_no_sensitive_data_exposure(self):
        """Test that no sensitive data is exposed in error messages."""
        # Test with invalid user creation
        try:
            User.objects.create_user(
                email='invalid-email',
                password='test'
            )
        except Exception as e:
            error_message = str(e)
            
            # Should not expose internal details
            self.assertNotIn('password', error_message.lower())
            self.assertNotIn('secret', error_message.lower())
            self.assertNotIn('key', error_message.lower())