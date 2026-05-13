"""
Email verification views for user registration and email verification.

Endpoints:
  POST /auth/register/ - Register user and initiate email verification
  POST /auth/verify-email/ - Verify email with token
  POST /auth/resend-verification/ - Resend verification email
"""

from rest_framework import status
from rest_framework.decorators import api_view, permission_classes, throttle_classes
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework_simplejwt.tokens import RefreshToken

from apps.core.responses import success_response, error_response
from apps.users.serializers.email_verification import (
    UserRegistrationSerializer,
    VerifyEmailSerializer,
    ResendVerificationEmailSerializer,
)


@api_view(['POST'])
@permission_classes([AllowAny])
@throttle_classes([])
def register_user(request):
    """
    Register a new user and initiate email verification workflow.
    
    Request body:
    {
        "email": "user@example.com",
        "password": "SecurePassword123!",
        "password_confirm": "SecurePassword123!",
        "full_name": "John Doe",
        "terms_consent": true,
        "marketing_consent": false,
        "data_processing_consent": true
    }
    
    Response:
    {
        "id": "uuid",
        "email": "user@example.com",
        "full_name": "John Doe",
        "email_verified": false,
        "message": "Registration successful. Please check your email to verify your account."
    }
    """
    if request.method == 'POST':
        serializer = UserRegistrationSerializer(data=request.data)
        
        if serializer.is_valid():
            user = serializer.save()
            return success_response(
                message='Registration successful. Please check your email to verify your account.',
                data={
                    'id': str(user.id),
                    'email': user.email,
                    'full_name': user.full_name,
                    'email_verified': user.email_verified,
                },
                status_code=status.HTTP_201_CREATED
            )
        
        return error_response(
            message='Registration failed. Please check your input.',
            details=serializer.errors,
            status_code=status.HTTP_400_BAD_REQUEST
        )


@api_view(['POST'])
@permission_classes([AllowAny])
def verify_email(request):
    """
    Verify user email with verification token.
    
    Request body:
    {
        "token": "email-verification-token"
    }
    
    Response:
    {
        "email": "user@example.com",
        "email_verified": true,
        "message": "Email verified successfully. You can now log in.",
        "access": "jwt-token",
        "refresh": "jwt-refresh-token"
    }
    """
    if request.method == 'POST':
        serializer = VerifyEmailSerializer(data=request.data)
        
        if serializer.is_valid():
            try:
                user = serializer.verify()
                
                # Generate JWT tokens
                refresh = RefreshToken.for_user(user)
                
                return Response(
                    {
                        'email': user.email,
                        'email_verified': user.email_verified,
                        'message': 'Email verified successfully. You can now log in.',
                        'access': str(refresh.access_token),
                        'refresh': str(refresh),
                    },
                    status=status.HTTP_200_OK
                )
            except Exception as e:
                return Response(
                    {'error': str(e)},
                    status=status.HTTP_400_BAD_REQUEST
                )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


@api_view(['POST'])
@permission_classes([AllowAny])
def resend_verification_email(request):
    """
    Resend verification email to user.
    
    Request body:
    {
        "email": "user@example.com"
    }
    
    Response:
    {
        "message": "Verification email sent. Please check your inbox."
    }
    """
    if request.method == 'POST':
        serializer = ResendVerificationEmailSerializer(data=request.data)
        
        if serializer.is_valid():
            result = serializer.save()
            user = result['user']
            token = result['token']
            
            # In a real application, send the token via email here
            # send_verification_email(user.email, token)
            
            return Response(
                {'message': 'Verification email sent. Please check your inbox.'},
                status=status.HTTP_200_OK
            )
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
