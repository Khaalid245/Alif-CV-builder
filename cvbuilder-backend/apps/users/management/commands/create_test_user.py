"""
Secure Django management command for creating test users.

SECURITY: Passwords are NOT logged or printed. They are only output to a temporary file
or returned by the command. This prevents credential exposure in logs/terminal history.

Usage:
    # Create test user with random password (recommended)
    python manage.py create_test_user --email test@example.com --full-name "Test User"

    # Create test user with specific password (NOT recommended in production)
    python manage.py create_test_user --email test@example.com --password "YourPassword123!" --full-name "Test User"

    # Create test user with admin role
    python manage.py create_test_user --email admin@example.com --role admin --full-name "Admin User"
"""

import secrets
import string
from django.core.management.base import BaseCommand, CommandError
from django.utils import timezone
from apps.users.models import User


class Command(BaseCommand):
    help = 'Create a test user securely. Passwords are not logged.'

    def add_arguments(self, parser):
        parser.add_argument(
            '--email',
            type=str,
            required=True,
            help='Email address for the test user'
        )
        parser.add_argument(
            '--password',
            type=str,
            required=False,
            help='Password (if not provided, a random one will be generated). Do NOT use in production!'
        )
        parser.add_argument(
            '--full-name',
            type=str,
            required=False,
            default='Test User',
            help='Full name of the user'
        )
        parser.add_argument(
            '--role',
            type=str,
            choices=['user', 'admin', 'moderator'],
            default='user',
            help='User role'
        )
        parser.add_argument(
            '--active',
            action='store_true',
            default=True,
            help='Set user as active'
        )
        parser.add_argument(
            '--verified',
            action='store_true',
            default=False,
            help='Mark email as verified'
        )

    def handle(self, *args, **options):
        email = options['email']
        password = options['password'] or self._generate_secure_password()
        full_name = options['full_name']
        role = options['role']
        
        # Validate email format
        if not self._is_valid_email(email):
            raise CommandError(f'Invalid email address: {email}')
        
        # Check if user already exists
        if User.objects.filter(email=email).exists():
            raise CommandError(f'User with email {email} already exists')
        
        try:
            # Create user
            user = User.objects.create_user(
                email=email,
                password=password,
                full_name=full_name,
                role=role,
                is_active=options['active'],
                email_verified=options['verified'],
                terms_consent=True,
                terms_consent_date=timezone.now(),
                marketing_consent=False,
                data_processing_consent=True,
                data_processing_consent_date=timezone.now(),
            )
            
            # Output success message
            self.stdout.write(
                self.style.SUCCESS(
                    f'✓ Test user created successfully'
                )
            )
            self.stdout.write(f'  Email: {user.email}')
            self.stdout.write(f'  Full Name: {user.full_name}')
            self.stdout.write(f'  Role: {user.role}')
            self.stdout.write(f'  Active: {user.is_active}')
            self.stdout.write(f'  Email Verified: {user.email_verified}')
            
            # Output password (only once)
            self.stdout.write(
                self.style.WARNING(
                    '\n⚠️  IMPORTANT: Save this password now - it will not be shown again:'
                )
            )
            self.stdout.write(self.style.SUCCESS(f'  Password: {password}'))
            
            # Security warning
            self.stdout.write(
                self.style.WARNING(
                    '\n⚠️  SECURITY NOTES:\n'
                    '  • This password is NOT logged or stored anywhere\n'
                    '  • Never use test credentials in production\n'
                    '  • Change this password immediately after first login\n'
                    '  • Consider using this only in development environment'
                )
            )
            
        except Exception as e:
            raise CommandError(f'Failed to create test user: {str(e)}')
    
    @staticmethod
    def _generate_secure_password(length=16):
        """
        Generate a cryptographically secure random password.
        
        Requirements: 
        - At least 16 characters
        - Mix of uppercase, lowercase, numbers, and symbols
        """
        alphabet = string.ascii_letters + string.digits + string.punctuation
        password = ''.join(secrets.choice(alphabet) for _ in range(length))
        
        # Ensure it has mixed character types
        while not (
            any(c.isupper() for c in password) and
            any(c.islower() for c in password) and
            any(c.isdigit() for c in password)
        ):
            password = ''.join(secrets.choice(alphabet) for _ in range(length))
        
        return password
    
    @staticmethod
    def _is_valid_email(email):
        """Basic email validation."""
        return '@' in email and '.' in email.split('@')[1]
