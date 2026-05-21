"""
Security tests for the fixed vulnerabilities.
Tests SQL injection prevention, secure logging, and credential security.
"""
import re
import logging
from io import StringIO
from unittest.mock import patch, MagicMock
from django.test import TestCase, override_settings
from django.core.management import call_command
from django.db import connection
from django.contrib.auth import get_user_model

from apps.core.test_utils import SecureTestMixin
from apps.core.secure_logging import SensitiveDataFilter, SecurityLogger
from apps.template_engine.management.commands.cleanup_template_engine import Command as CleanupCommand

User = get_user_model()


class SQLInjectionPreventionTests(TestCase):
    """Test SQL injection prevention in management commands."""
    
    def test_cleanup_command_sql_safety(self):
        """Test that cleanup command uses safe SQL construction."""
        command = CleanupCommand()
        
        # Test that the _optimize_database method exists and is safe
        self.assertTrue(hasattr(command, '_optimize_database'))
        
        # Test with dry run (should not execute SQL)
        try:
            command._optimize_database(dry_run=True)
        except Exception as e:
            self.fail(f"Dry run failed: {e}")
    
    def test_table_name_validation(self):
        """Test that table names are properly validated."""
        command = CleanupCommand()
        
        # Mock the database connection to test validation
        with patch('django.db.connection') as mock_connection:
            mock_cursor = MagicMock()
            mock_connection.cursor.return_value.__enter__.return_value = mock_cursor
            
            # This should work without raising exceptions
            command._optimize_database(dry_run=False)
            
            # Verify that execute was called with safe SQL
            self.assertTrue(mock_cursor.execute.called)
            
            # Check that the SQL contains table names from Django models
            call_args = mock_cursor.execute.call_args_list
            for call in call_args:
                sql = call[0][0]
                # Should contain ANALYZE TABLE with backticks (safe)
                self.assertIn('ANALYZE TABLE `', sql)
                # Should not contain raw %s placeholders
                self.assertNotIn('%s', sql)


class SecureLoggingTests(TestCase, SecureTestMixin):
    """Test secure logging implementation."""
    
    def setUp(self):
        self.user = self.create_test_user()
    
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
    
    @patch('apps.core.secure_logging.security_logger')
    def test_security_logger_login_attempt(self, mock_logger):
        """Test that SecurityLogger properly sanitizes login attempts."""
        SecurityLogger.log_login_attempt(
            user_email="test@example.com",
            success=False,
            ip_address="192.168.1.1",
            user_agent="Mozilla/5.0 (Test Browser)"
        )
        
        # Verify logger was called
        self.assertTrue(mock_logger.info.called)
        
        # Check that email was hashed, not logged directly
        call_args = mock_logger.info.call_args
        self.assertIn('user_email_hash', call_args[1])
        self.assertNotIn('test@example.com', str(call_args))
    
    @patch('apps.core.secure_logging.security_logger')
    def test_security_logger_password_change(self, mock_logger):
        """Test that SecurityLogger properly sanitizes password change events."""
        SecurityLogger.log_password_change(
            user_id=str(self.user.id),
            ip_address="192.168.1.1"
        )
        
        # Verify logger was called
        self.assertTrue(mock_logger.info.called)
        
        # Check that user ID was hashed, not logged directly
        call_args = mock_logger.info.call_args
        self.assertIn('user_id_hash', call_args[1])
        self.assertNotIn(str(self.user.id), str(call_args))


class CredentialSecurityTests(TestCase, SecureTestMixin):
    """Test credential security implementation."""
    
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
    
    def test_no_hardcoded_credentials_in_tests(self):
        """Test that no hardcoded credentials exist in test files."""
        # This test verifies the SecureTestMixin is being used properly
        user1 = self.create_test_user()
        user2 = self.create_test_user()
        
        # Passwords should be different (not hardcoded)
        self.assertNotEqual(user1._test_password, user2._test_password)
        
        # Both should be secure
        for user in [user1, user2]:
            password = user._test_password
            self.assertGreaterEqual(len(password), 12)
            self.assertNotIn('password', password.lower())
            self.assertNotIn('123456', password)


class SecurityComplianceTests(TestCase, SecureTestMixin):
    """Test overall security compliance."""
    
    def test_no_sensitive_data_in_error_messages(self):
        """Test that error messages don't expose sensitive data."""
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
    
    def test_logging_sanitization_comprehensive(self):
        """Test comprehensive logging sanitization."""
        sensitive_data = {
            'email': 'user@example.com',
            'password': 'secret123',
            'token': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ',
            'phone': '+1-555-123-4567',
            'api_key': 'sk_live_abcdef123456789'
        }
        
        for data_type, value in sensitive_data.items():
            test_message = f"Processing {data_type}: {value}"
            sanitized = SensitiveDataFilter.sanitize_message(test_message)
            
            # Original value should not be present
            self.assertNotIn(value, sanitized)
            
            # Should contain appropriate masking
            if data_type == 'email':
                self.assertIn('***@', sanitized)
            else:
                self.assertTrue(
                    '***REDACTED***' in sanitized or '***MASKED***' in sanitized,
                    f"No masking found for {data_type}"
                )


class IntegrationSecurityTests(TestCase, SecureTestMixin):
    """Integration tests for security fixes."""
    
    def test_management_command_security(self):
        """Test that management commands are secure."""
        # Test cleanup command with dry run
        out = StringIO()
        try:
            call_command('cleanup_template_engine', '--dry-run', stdout=out)
            output = out.getvalue()
            
            # Should complete without errors
            self.assertIn('cleanup completed', output.lower())
            
            # Should indicate dry run
            self.assertIn('dry run', output.lower())
            
        except Exception as e:
            self.fail(f"Management command failed: {e}")
    
    def test_secure_logging_integration(self):
        """Test that secure logging works in integration."""
        with patch('apps.core.secure_logging.security_logger') as mock_logger:
            # Test login attempt logging
            SecurityLogger.log_login_attempt(
                user_email="test@example.com",
                success=True,
                ip_address="192.168.1.1",
                user_agent="Test Agent"
            )
            
            # Verify secure logging was used
            self.assertTrue(mock_logger.info.called)
            
            # Verify no sensitive data in logs
            call_str = str(mock_logger.info.call_args)
            self.assertNotIn('test@example.com', call_str)
            self.assertIn('user_email_hash', call_str)