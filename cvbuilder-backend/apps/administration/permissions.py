"""
Admin-only permission classes for EduCV administration endpoints.

NOTE: This module now delegates to core.permissions for consistency.
All permission classes are defined in core/permissions.py
"""
import logging

# DEPRECATED: Use core.permissions instead
# This import is maintained for backward compatibility
from apps.core.permissions import IsAdminUser

# Security logger for unauthorized access attempts
security_logger = logging.getLogger('security')


def log_unauthorized_access(request, reason):
    """Log unauthorized admin access attempts to security.log"""
    ip_address = _get_client_ip(request)
    user_agent = request.META.get('HTTP_USER_AGENT', 'Unknown')
    path = request.get_full_path()
    
    security_logger.warning(
        f"UNAUTHORIZED_ADMIN_ACCESS - {reason} - "
        f"IP: {ip_address} - Path: {path} - User-Agent: {user_agent}"
    )


def _get_client_ip(request):
    """Extract client IP address from request"""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


__all__ = ['IsAdminUser', 'log_unauthorized_access']
