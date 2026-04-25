"""
Admin-only permission classes for EduCV administration endpoints.
"""
import logging
from rest_framework.permissions import BasePermission

# Security logger for unauthorized access attempts
security_logger = logging.getLogger('security')


class IsAdminUser(BasePermission):
    """
    Permission class that allows access only to authenticated admin users.
    
    Checks:
    - User is authenticated
    - User role is 'admin'
    
    Logs unauthorized access attempts to security.log with IP and user agent.
    """
    
    def has_permission(self, request, view):
        # Check if user is authenticated
        if not request.user or not request.user.is_authenticated:
            self._log_unauthorized_access(request, "Unauthenticated user")
            return False
        
        # Check if user has admin role
        if request.user.role != 'admin':
            self._log_unauthorized_access(
                request, 
                f"Non-admin user {request.user.email} attempted admin access"
            )
            return False
        
        return True
    
    def _log_unauthorized_access(self, request, reason):
        """Log unauthorized admin access attempts to security.log"""
        ip_address = self._get_client_ip(request)
        user_agent = request.META.get('HTTP_USER_AGENT', 'Unknown')
        path = request.get_full_path()
        
        security_logger.warning(
            f"UNAUTHORIZED_ADMIN_ACCESS - {reason} - "
            f"IP: {ip_address} - Path: {path} - User-Agent: {user_agent}"
        )
    
    def _get_client_ip(self, request):
        """Extract client IP address from request"""
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            return x_forwarded_for.split(',')[0].strip()
        return request.META.get('REMOTE_ADDR', 'Unknown')