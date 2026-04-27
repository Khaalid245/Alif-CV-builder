#!/usr/bin/env python
import os
import sys
import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')
django.setup()

from apps.users.models import User
from django.utils import timezone

# Create a test user
user = User.objects.create_user(
    email='ahmed@university.edu',
    password='SecurePass123!',
    full_name='Ahmed Test User',
    terms_consent=True,
    terms_consent_date=timezone.now(),
    marketing_consent=True,
    marketing_consent_date=timezone.now(),
    data_processing_consent=True,
    data_processing_consent_date=timezone.now(),
)

print(f"Created user: {user.email}")
print("You can now login with:")
print("Email: ahmed@university.edu")
print("Password: SecurePass123!")