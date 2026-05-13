"""
Serializers for email verification endpoints.
"""

from rest_framework import serializers
from apps.users.models import User
from apps.users.email_verification import EmailVerificationToken
import hashlib


class ResendVerificationEmailSerializer(serializers.Serializer):
    """Serializer for requesting a new verification email."""
    email = serializers.EmailField()
    
    def validate_email(self, value):
        """Validate that user exists and email is not already verified."""
        try:
            user = User.objects.get(email=value)
        except User.DoesNotExist:
            raise serializers.ValidationError("User with this email does not exist.")
        
        if user.email_verified:
            raise serializers.ValidationError("This email is already verified.")
        
        return value
    
    def create(self, validated_data):
        """Create a new verification token and return the user."""
        email = validated_data['email']
        user = User.objects.get(email=email)
        token, token_obj = EmailVerificationToken.create_token(user)
        
        # In a real application, send the token via email here
        # send_verification_email(user.email, token)
        
        return {'user': user, 'token': token}


class VerifyEmailSerializer(serializers.Serializer):
    """Serializer for verifying an email with a token."""
    token = serializers.CharField(required=True)
    
    def validate_token(self, value):
        """Validate that the token is valid and not expired."""
        # Hash the token
        token_hash = hashlib.sha256(value.encode()).hexdigest()
        
        try:
            token_obj = EmailVerificationToken.objects.get(token_hash=token_hash)
        except EmailVerificationToken.DoesNotExist:
            raise serializers.ValidationError("Invalid verification token.")
        
        if not token_obj.is_valid():
            raise serializers.ValidationError("Verification token has expired. Please request a new one.")
        
        return value
    
    def verify(self):
        """Verify the email and return the user."""
        token = self.validated_data['token']
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        
        token_obj = EmailVerificationToken.objects.get(token_hash=token_hash)
        user = token_obj.verify_and_delete()
        
        return user


class UserRegistrationSerializer(serializers.ModelSerializer):
    """
    Serializer for user registration with email verification workflow.
    Requires email verification after registration.
    """
    password = serializers.CharField(write_only=True, min_length=8, style={'input_type': 'password'})
    confirm_password = serializers.CharField(write_only=True, min_length=8, style={'input_type': 'password'})
    terms_accepted = serializers.BooleanField(write_only=True, required=False)
    privacy_policy_accepted = serializers.BooleanField(write_only=True, required=False)
    
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'password',
            'confirm_password',
            'full_name',
            'student_id',
            'terms_consent',
            'marketing_consent',
            'data_processing_consent',
            'email_verified',
            'terms_accepted',
            'privacy_policy_accepted',
        ]
        read_only_fields = ['id', 'email_verified']
    
    def validate(self, data):
        """Validate password confirmation and map alternative field names."""
        password = data.get('password')
        confirm_password = data.get('confirm_password')
        
        if password != confirm_password:
            raise serializers.ValidationError(
                {'password': 'Passwords do not match.'}
            )
        
        # Check password strength
        if not self._is_strong_password(password):
            raise serializers.ValidationError(
                {'password': 'Password must contain uppercase, lowercase, numbers, and symbols.'}
            )
        
        # Map alternative field names for transparency
        if 'terms_accepted' in data and 'terms_consent' not in data:
            data['terms_consent'] = data.pop('terms_accepted')
        if 'privacy_policy_accepted' in data and 'marketing_consent' not in data:
            data['marketing_consent'] = data.pop('privacy_policy_accepted')
        
        return data
    
    def create(self, validated_data):
        """Create user and send verification email."""
        validated_data.pop('confirm_password', None)
        
        user = User.objects.create_user(**validated_data)
        
        # Create verification token
        token, token_obj = EmailVerificationToken.create_token(user)
        
        # In a real application, send the token via email here
        # send_verification_email(user.email, token)
        
        return user
    
    @staticmethod
    def _is_strong_password(password):
        """Check if password meets minimum strength requirements."""
        return (
            any(c.isupper() for c in password) and  # Has uppercase
            any(c.islower() for c in password) and  # Has lowercase
            any(c.isdigit() for c in password) and   # Has numbers
            any(c in '!@#$%^&*()_+-=[]{}|;:,.<>?' for c in password)  # Has symbols
        )
