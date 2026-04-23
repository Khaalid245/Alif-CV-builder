"""
Authentication views for EduCV.
All views use the standard response envelope from apps.core.responses.
All protected views enforce that students can only access their own data.
Failed auth attempts are logged to security.log with IP address.
"""
import logging
from django.contrib.auth import authenticate
from django.utils import timezone
from rest_framework import status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken
from rest_framework_simplejwt.exceptions import TokenError
from rest_framework_simplejwt.token_blacklist.models import OutstandingToken, BlacklistedToken
from rest_framework_simplejwt.views import TokenRefreshView as BaseTokenRefreshView

from apps.core.responses import success_response, error_response
from apps.core.utils import get_client_ip
from .models import User, AuditLog
from .serializers import (
    RegisterSerializer,
    LoginSerializer,
    UserProfileSerializer,
    UpdateProfileSerializer,
    ChangePasswordSerializer,
    RequestDeletionSerializer,
)

logger          = logging.getLogger(__name__)
security_logger = logging.getLogger('security')


def _get_tokens(user) -> dict:
    """Generate a fresh JWT access + refresh token pair for a user."""
    refresh = RefreshToken.for_user(user)
    return {
        'access':  str(refresh.access_token),
        'refresh': str(refresh),
    }


class RegisterView(APIView):
    """
    POST /api/v1/auth/register/
    Public endpoint — no authentication required.
    Creates a new student account with mandatory consent tracking.
    Returns student profile + JWT tokens on success.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if not serializer.is_valid():
            return error_response(
                'Registration failed. Please correct the errors below.',
                serializer.errors,
                status.HTTP_400_BAD_REQUEST,
            )

        user = serializer.save()

        # Record registration in audit log
        AuditLog.log(user, AuditLog.Action.REGISTER, request)

        logger.info('New student registered: %s', user.email)

        return success_response(
            'Registration successful. Welcome to EduCV!',
            {
                'user':   UserProfileSerializer(user).data,
                'tokens': _get_tokens(user),
            },
            status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    """
    POST /api/v1/auth/login/
    Public endpoint — no authentication required.
    Authenticates student, checks account status, returns JWT tokens.
    All failed attempts are logged to security.log with IP address.
    """
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if not serializer.is_valid():
            return error_response(
                'Invalid input.',
                serializer.errors,
                status.HTTP_400_BAD_REQUEST,
            )

        email    = serializer.validated_data['email']
        password = serializer.validated_data['password']
        ip       = get_client_ip(request)

        # Authenticate against the database
        user = authenticate(request, username=email, password=password)

        if user is None:
            # Log failed attempt with IP — critical for security monitoring
            security_logger.warning(
                'Failed login attempt | email=%s | ip=%s | ua=%s',
                email, ip, request.META.get('HTTP_USER_AGENT', ''),
            )
            return error_response(
                'Invalid email or password.',
                status_code=status.HTTP_401_UNAUTHORIZED,
            )

        # Check account status before issuing tokens
        if user.is_deleted:
            return error_response(
                'This account has been deactivated.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        if user.status == User.Status.SUSPENDED:
            security_logger.warning('Suspended account login attempt | email=%s | ip=%s', email, ip)
            return error_response(
                'Your account has been suspended. Please contact support.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        if user.status == User.Status.DEACTIVATED:
            return error_response(
                'This account has been deactivated.',
                status_code=status.HTTP_403_FORBIDDEN,
            )

        # Successful login
        user.record_login()
        AuditLog.log(user, AuditLog.Action.LOGIN, request)
        logger.info('Student logged in: %s | ip=%s', user.email, ip)

        return success_response(
            'Login successful.',
            {
                'user':   UserProfileSerializer(user).data,
                'tokens': _get_tokens(user),
            },
        )


class LogoutView(APIView):
    """
    POST /api/v1/auth/logout/
    Blacklists the provided refresh token, invalidating the session.
    The access token will expire naturally (short lifetime).
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        refresh_token = request.data.get('refresh')
        if not refresh_token:
            return error_response('Refresh token is required.', status_code=status.HTTP_400_BAD_REQUEST)

        try:
            token = RefreshToken(refresh_token)
            token.blacklist()
        except TokenError:
            return error_response('Invalid or expired token.', status_code=status.HTTP_400_BAD_REQUEST)

        AuditLog.log(request.user, AuditLog.Action.LOGOUT, request)
        logger.info('Student logged out: %s', request.user.email)

        return success_response('Logged out successfully.')


class TokenRefreshWrappedView(BaseTokenRefreshView):
    """
    POST /api/v1/auth/token/refresh/
    Wraps simplejwt's TokenRefreshView to return our standard response envelope.
    Without this, the refresh endpoint returns {access: '...'} which breaks
    the consistent {success, message, data} contract expected by Flutter.
    """
    def post(self, request, *args, **kwargs):
        response = super().post(request, *args, **kwargs)
        if response.status_code == 200:
            return success_response('Token refreshed successfully.', response.data)
        return response


class ProfileView(APIView):
    """
    GET /api/v1/auth/profile/
    Returns the authenticated student's own profile.
    Students can only see their own data — enforced by using request.user.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = UserProfileSerializer(request.user)
        return success_response('Profile retrieved successfully.', serializer.data)


class UpdateProfileView(APIView):
    """
    PUT /api/v1/auth/profile/update/
    Allows students to update their own profile fields.
    Sensitive fields (email, role, status) cannot be changed here.
    """
    permission_classes = [IsAuthenticated]

    def put(self, request):
        serializer = UpdateProfileSerializer(
            request.user,
            data=request.data,
            partial=True,
            context={'request': request},
        )
        if not serializer.is_valid():
            return error_response(
                'Profile update failed.',
                serializer.errors,
                status.HTTP_400_BAD_REQUEST,
            )

        serializer.save()
        logger.info('Profile updated: %s', request.user.email)

        return success_response(
            'Profile updated successfully.',
            UserProfileSerializer(request.user).data,
        )


class ChangePasswordView(APIView):
    """
    POST /api/v1/auth/change-password/
    Requires current password verification before setting a new one.
    Invalidates all existing tokens after password change for security.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={'request': request},
        )
        if not serializer.is_valid():
            return error_response(
                'Password change failed.',
                serializer.errors,
                status.HTTP_400_BAD_REQUEST,
            )

        request.user.set_password(serializer.validated_data['new_password'])
        request.user.save(update_fields=['password', 'updated_at'])

        # Blacklist ALL outstanding refresh tokens for this user
        # so every existing session is invalidated after a password change
        outstanding_tokens = OutstandingToken.objects.filter(user=request.user)
        for token in outstanding_tokens:
            BlacklistedToken.objects.get_or_create(token=token)

        AuditLog.log(request.user, AuditLog.Action.PASSWORD_CHANGED, request)
        security_logger.info('Password changed — all sessions invalidated: %s', request.user.email)

        return success_response(
            'Password changed successfully. Please log in again with your new password.',
        )


class RequestDeletionView(APIView):
    """
    POST /api/v1/auth/request-deletion/
    Student requests deletion of their own account and data.
    This is a soft flag — actual deletion is handled by admin after review.
    Password confirmation is required as a safety gate.
    Stores timestamp as legal proof of the request.
    """
    permission_classes = [IsAuthenticated]

    def post(self, request):
        # Prevent duplicate deletion requests
        if request.user.deletion_requested:
            return error_response(
                'A deletion request has already been submitted for this account.',
                status_code=status.HTTP_400_BAD_REQUEST,
            )

        serializer = RequestDeletionSerializer(
            data=request.data,
            context={'request': request},
        )
        if not serializer.is_valid():
            return error_response(
                'Deletion request failed.',
                serializer.errors,
                status.HTTP_400_BAD_REQUEST,
            )

        reason = serializer.validated_data.get('reason', '')

        # Flag the account — admin will process the actual deletion
        request.user.deletion_requested    = True
        request.user.deletion_requested_at = timezone.now()
        request.user.save(update_fields=['deletion_requested', 'deletion_requested_at', 'updated_at'])

        AuditLog.log(
            request.user,
            AuditLog.Action.DELETION_REQUESTED,
            request,
            extra_data={'reason': reason},
        )
        security_logger.info('Data deletion requested: %s', request.user.email)

        return success_response(
            'Your data deletion request has been submitted. '
            'Our team will process it within 30 days as required by law.',
        )

