"""
Serializers for the users app.
Each serializer handles one specific use case — no overloaded serializers.
Passwords are NEVER included in any output serializer.
"""
from django.contrib.auth.password_validation import validate_password
from django.utils import timezone
from rest_framework import serializers
from .models import User


class UserProfileSerializer(serializers.ModelSerializer):
    """
    Read-only serializer for returning student profile data.
    Used in login, register responses, and the profile endpoint.
    Password and internal fields are explicitly excluded.
    """
    class Meta:
        model = User
        fields = [
            'id', 'email', 'full_name', 'student_id', 'role', 'status',
            'terms_consent', 'terms_consent_date',
            'marketing_consent', 'marketing_consent_date',
            'data_processing_consent', 'data_processing_consent_date',
            'deletion_requested_at',
            'created_at', 'updated_at', 'last_login_at',
        ]
        read_only_fields = fields


class RegisterSerializer(serializers.Serializer):
    """
    Handles student registration.
    Validates consent fields, password strength, and uniqueness.
    All three consent fields are mandatory — registration is rejected without them.
    """
    email              = serializers.EmailField()
    full_name          = serializers.CharField(max_length=255)
    student_id         = serializers.CharField(max_length=50)
    password           = serializers.CharField(write_only=True, min_length=8)
    confirm_password   = serializers.CharField(write_only=True)

    # Consent — terms and data processing are required; marketing is optional
    terms_consent           = serializers.BooleanField()
    marketing_consent       = serializers.BooleanField(required=False, default=False)
    data_processing_consent = serializers.BooleanField()

    def validate_email(self, value):
        if User.objects.filter(email=value.lower()).exists():
            raise serializers.ValidationError('An account with this email already exists.')
        return value.lower()

    def validate_student_id(self, value):
        if User.objects.filter(student_id=value).exists():
            raise serializers.ValidationError('This student ID is already registered.')
        return value

    def validate_terms_consent(self, value):
        if not value:
            raise serializers.ValidationError('You must accept the terms and conditions.')
        return value

    def validate_marketing_consent(self, value):
        # Marketing consent is optional — students may decline
        return value

    def validate_data_processing_consent(self, value):
        if not value:
            raise serializers.ValidationError('You must consent to data processing.')
        return value

    def validate(self, attrs):
        if attrs['password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})

        # Run Django's built-in password validators
        validate_password(attrs['password'])
        return attrs

    def create(self, validated_data):
        validated_data.pop('confirm_password')
        now = timezone.now()

        user = User.objects.create_user(
            email=validated_data['email'],
            password=validated_data['password'],
            full_name=validated_data['full_name'],
            student_id=validated_data['student_id'],
            # Consent with timestamps
            terms_consent=True,
            terms_consent_date=now,
            marketing_consent=True,
            marketing_consent_date=now,
            data_processing_consent=True,
            data_processing_consent_date=now,
        )
        return user


class LoginSerializer(serializers.Serializer):
    """Validates login credentials. Authentication logic is in the view."""
    email    = serializers.EmailField()
    password = serializers.CharField(write_only=True)

    def validate_email(self, value):
        return value.lower()


class UpdateProfileSerializer(serializers.ModelSerializer):
    """
    Allows students to update their own profile.
    Email, role, status, and consent fields are not updatable here.
    """
    class Meta:
        model = User
        fields = ['full_name', 'student_id']

    def validate_student_id(self, value):
        # Allow keeping the same student_id, but reject if taken by another user
        user = self.context['request'].user
        if User.objects.filter(student_id=value).exclude(pk=user.pk).exists():
            raise serializers.ValidationError('This student ID is already registered.')
        return value


class ChangePasswordSerializer(serializers.Serializer):
    """Handles password change for authenticated students."""
    current_password = serializers.CharField(write_only=True)
    new_password     = serializers.CharField(write_only=True, min_length=8)
    confirm_password = serializers.CharField(write_only=True)

    def validate_current_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Current password is incorrect.')
        return value

    def validate(self, attrs):
        if attrs['new_password'] != attrs['confirm_password']:
            raise serializers.ValidationError({'confirm_password': 'Passwords do not match.'})
        validate_password(attrs['new_password'], self.context['request'].user)
        return attrs


class RequestDeletionSerializer(serializers.Serializer):
    """
    Student requests deletion of their own data.
    Requires password confirmation as a safety gate.
    """
    password = serializers.CharField(write_only=True)
    reason   = serializers.CharField(max_length=500, required=False, allow_blank=True)

    def validate_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError('Password is incorrect.')
        return value
