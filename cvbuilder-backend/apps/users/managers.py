"""
Custom managers for the User model.
Provides clean querysets that automatically exclude soft-deleted accounts.
"""
from django.utils import timezone
from django.contrib.auth.models import BaseUserManager


class StudentManager(BaseUserManager):
    """
    Custom manager for the User model.
    - create_user: creates a standard student account
    - create_superuser: creates an admin account

    IMPORTANT: get_queryset() is NOT filtered here.
    Filtering soft-deleted users in the default manager breaks JWT token
    validation — simplejwt calls User.objects.get(id=...) internally and
    would crash with DoesNotExist on soft-deleted accounts.
    Use the active_students() method for filtered queries in views.
    """

    def get_queryset(self):
        """Returns all users including soft-deleted — required for JWT internals."""
        return super().get_queryset()

    def create_user(self, email, password=None, **extra_fields):
        if not email:
            raise ValueError('Email address is required.')
        email = self.normalize_email(email)
        extra_fields.setdefault('role', 'student')
        extra_fields.setdefault('status', 'active')
        user = self.model(email=email, **extra_fields)
        user.set_password(password)
        user.save(using=self._db)
        return user

    def create_superuser(self, email, password=None, **extra_fields):
        extra_fields.setdefault('role', 'admin')
        extra_fields.setdefault('status', 'active')
        extra_fields.setdefault('is_staff', True)
        extra_fields.setdefault('is_superuser', True)
        # Superusers bypass consent requirement but timestamps are still recorded
        now = timezone.now()
        extra_fields.setdefault('terms_accepted', True)
        extra_fields.setdefault('terms_accepted_at', now)
        extra_fields.setdefault('privacy_policy_accepted', True)
        extra_fields.setdefault('privacy_policy_accepted_at', now)
        extra_fields.setdefault('data_processing_consent', True)
        extra_fields.setdefault('data_processing_consent_at', now)
        return self.create_user(email, password, **extra_fields)

    def active_students(self):
        """Returns only active, non-deleted student accounts."""
        return self.get_queryset().filter(role='student', status='active')
