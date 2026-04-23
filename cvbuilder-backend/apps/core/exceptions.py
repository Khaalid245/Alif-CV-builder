"""
Custom exception handler for EduCV.
Intercepts ALL exceptions and returns the standard response envelope.
Raw Django/Python errors are NEVER exposed to the client.
Internal errors are logged server-side for debugging.
"""
import logging
from rest_framework.views import exception_handler
from rest_framework.exceptions import (
    AuthenticationFailed,
    NotAuthenticated,
    PermissionDenied,
    ValidationError,
    Throttled,
)
from rest_framework import status
from django.core.exceptions import ObjectDoesNotExist
from django.http import Http404

logger = logging.getLogger(__name__)
security_logger = logging.getLogger('security')


def custom_exception_handler(exc, context):
    """
    Global exception handler.
    1. Calls DRF's default handler first to get the response.
    2. Wraps it in our standard envelope.
    3. Handles cases DRF doesn't cover (e.g. Django's ObjectDoesNotExist).
    """
    # Let DRF handle what it knows first
    response = exception_handler(exc, context)

    # ── Cases DRF doesn't handle natively ─────────────────────────────────────
    if response is None:
        if isinstance(exc, (ObjectDoesNotExist, Http404)):
            return _build_error('Resource not found.', {}, status.HTTP_404_NOT_FOUND)

        # Unhandled server error — log it, return generic message
        logger.exception('Unhandled server error: %s', exc, extra={'context': str(context)})
        return _build_error(
            'An unexpected error occurred. Please try again later.',
            {},
            status.HTTP_500_INTERNAL_SERVER_ERROR,
        )

    # ── Wrap DRF responses in our envelope ────────────────────────────────────
    if isinstance(exc, NotAuthenticated):
        message = 'Authentication credentials were not provided.'
        security_logger.warning('Unauthenticated request: %s', _get_path(context))
    elif isinstance(exc, AuthenticationFailed):
        message = 'Invalid authentication credentials.'
        security_logger.warning('Authentication failed: %s', _get_path(context))
    elif isinstance(exc, PermissionDenied):
        message = 'You do not have permission to perform this action.'
    elif isinstance(exc, Throttled):
        wait = exc.wait
        message = f'Too many requests. Please wait {int(wait)} seconds.' if wait else 'Too many requests.'
    elif isinstance(exc, ValidationError):
        message = 'Validation failed.'
    else:
        message = 'An error occurred.'

    response.data = {
        'success': False,
        'message': message,
        'error': {
            'message': message,
            'details': _normalize_details(response.data),
        },
    }

    return response


def _build_error(message: str, details: dict, status_code: int):
    """Build a Response object with the standard error envelope."""
    from rest_framework.response import Response
    return Response(
        {
            'success': False,
            'message': message,
            'error': {'message': message, 'details': details},
        },
        status=status_code,
    )


def _normalize_details(data) -> dict:
    """
    Normalize DRF's error data (which can be a dict, list, or string)
    into a consistent dict for the 'details' field.
    """
    if isinstance(data, dict):
        return {k: v if isinstance(v, list) else [v] for k, v in data.items()}
    if isinstance(data, list):
        return {'non_field_errors': data}
    return {'detail': [str(data)]}


def _get_path(context) -> str:
    """Safely extract the request path from the exception context."""
    try:
        return context['request'].path
    except (KeyError, AttributeError):
        return 'unknown'
