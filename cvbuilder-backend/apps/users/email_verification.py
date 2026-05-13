"""
Email verification token model for secure email verification.
Uses JWT-like tokens with expiration for secure email verification links.
"""

import secrets
import hashlib
from datetime import timedelta
from django.db import models
from django.utils import timezone
from django.conf import settings
from .models import User


class EmailVerificationToken(models.Model):
    """
    Stores email verification tokens with expiration.
    
    Security features:
    - One-time use tokens (deleted after verification)
    - Token expiration (24 hours by default)
    - Hashed token storage (never store plaintext tokens in DB)
    - Associated with specific user
    
    Usage:
        token = EmailVerificationToken.objects.create(user=user)
        verification_link = f"https://yourdomain.com/verify-email/{token.token}"
        # Send to user email
        
        # User clicks link, we retrieve and verify:
        try:
            token_obj = EmailVerificationToken.objects.get(token_hash=token_hash)
            token_obj.verify_and_delete()
        except EmailVerificationToken.DoesNotExist:
            raise ValidationError("Invalid or expired verification token")
    """
    
    id = models.BigAutoField(primary_key=True)
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='verification_token')
    
    # Token management
    token_hash = models.CharField(max_length=128, unique=True, db_index=True)  # Hashed token
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField(db_index=True)
    verified_at = models.DateTimeField(null=True, blank=True)  # NULL until verified
    
    class Meta:
        db_table = 'email_verification_tokens'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['expires_at'], name='idx_email_token_expires'),
            models.Index(fields=['verified_at'], name='idx_email_token_verified'),
        ]
    
    def __str__(self):
        return f"Verification token for {self.user.email}"
    
    @classmethod
    def create_token(cls, user):
        """
        Create a new verification token for a user.
        Deletes any existing tokens for that user.
        """
        # Delete any existing tokens for this user
        cls.objects.filter(user=user).delete()
        
        # Generate random token
        raw_token = secrets.token_urlsafe(32)
        token_hash = hashlib.sha256(raw_token.encode()).hexdigest()
        
        # Create token with 24-hour expiration
        token_obj = cls.objects.create(
            user=user,
            token_hash=token_hash,
            expires_at=timezone.now() + timedelta(hours=24)
        )
        
        return raw_token, token_obj
    
    def is_valid(self):
        """Check if token is valid (not expired and not already verified)."""
        return (
            self.expires_at > timezone.now() and
            self.verified_at is None
        )
    
    def verify_and_delete(self):
        """
        Mark token as verified and mark user's email as verified.
        Returns the user.
        """
        if not self.is_valid():
            raise ValueError("Token is expired or already used")
        
        user = self.user
        user.email_verified = True
        user.email_verified_at = timezone.now()
        user.save(update_fields=['email_verified', 'email_verified_at'])
        
        self.verified_at = timezone.now()
        self.save(update_fields=['verified_at'])
        
        return user
    
    @classmethod
    def cleanup_expired(cls):
        """Delete expired and already-verified tokens."""
        now = timezone.now()
        cls.objects.filter(
            models.Q(expires_at__lt=now) | models.Q(verified_at__isnull=False)
        ).delete()
