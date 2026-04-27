"""
Standard API response format for EduCV.
Every endpoint must use these helpers to ensure a consistent response envelope.

Success: {success: true,  message: "...", data: {...}}
Error:   {success: false, message: "...", error: {message: "...", details: {...}}}
"""
from rest_framework.response import Response
from rest_framework import status


def success_response(message: str, data=None, status_code=status.HTTP_200_OK) -> Response:
    """Return a standardized success response."""
    return Response(
        {
            'success': True,
            'message': message,
            'data': {} if data is None else data,
        },
        status=status_code,
    )


def error_response(
    message: str,
    details=None,
    status_code=status.HTTP_400_BAD_REQUEST,
) -> Response:
    """Return a standardized error response. Never expose internal details in production."""
    return Response(
        {
            'success': False,
            'message': message,
            'error': {
                'message': message,
                'details': details or {},
            },
        },
        status=status_code,
    )
