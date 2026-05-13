"""
Custom DRF permissions for EduCV.

IMPORTANT: All permissions in this module are standardized across the application.
Importing from this module ensures consistency and prevents duplicate permission logic.
"""
import logging
from rest_framework.permissions import BasePermission

# Security logger for unauthorized access attempts
security_logger = logging.getLogger('security')


class IsOwner(BasePermission):
    """
    Object-level permission for models with a direct 'user' FK.
    Example: AuditLog.user, GeneratedCV.student

    DO NOT use this for CV section models (Education, Experience, Skill, etc.).
    Those link to the student via obj.cv.student, not obj.user.
    CV views enforce ownership through _get_owned_object() instead.
    """
    message = 'You do not have permission to access this resource.'

    def has_object_permission(self, request, view, obj):
        return obj.user == request.user


class IsOwnerViaCVProfile(BasePermission):
    """
    Object-level permission for CV section models.
    These link to the student through obj.cv.student, not obj.user.
    Use this if CV section views ever switch to DRF's object-level permission system.
    """
    message = 'You do not have permission to access this resource.'

    def has_object_permission(self, request, view, obj):
        return obj.cv.student == request.user


class IsAdminUser(BasePermission):
    """
    Grants access only to authenticated users with admin privileges.
    
    Checks (in order of priority):
    1. User is authenticated
    2. User has is_staff=True OR role='admin'
    
    This class is used for all admin endpoints to ensure consistency across
    the application. Security violations are logged automatically.
    
    Security Features:
    - Logs unauthorized access attempts with IP address and user agent
    - Validates both Django's is_staff flag and custom role field
    - Provides clear error message to clients
    
    Example usage in views:
        class AdminDashboardView(APIView):
            permission_classes = [IsAdminUser]
    """
    message = 'Admin access required.'

    def has_permission(self, request, view):
        # Check if user is authenticated
        if not request.user or not request.user.is_authenticated:
            self._log_unauthorized_access(request, "Unauthenticated user attempted admin access")
            return False
        
        # Check admin privileges (is_staff OR role='admin')
        is_admin = request.user.is_staff or getattr(request.user, 'role', None) == 'admin'
        
        if not is_admin:
            self._log_unauthorized_access(
                request,
                f"Non-admin user {request.user.email} (role={getattr(request.user, 'role', 'unknown')}) "
                f"attempted admin access"
            )
            return False
        
        return True
    
    @staticmethod
    def _log_unauthorized_access(request, reason):
        """Log unauthorized admin access attempts to security.log"""
        ip_address = IsAdminUser._get_client_ip(request)
        user_agent = request.META.get('HTTP_USER_AGENT', 'Unknown')
        path = request.get_full_path()
        method = request.method
        
        security_logger.warning(
            f"UNAUTHORIZED_ADMIN_ACCESS | {reason} | "
            f"Method: {method} | Path: {path} | IP: {ip_address} | User-Agent: {user_agent}"
        )
    
    @staticmethod
    def _get_client_ip(request):
        """
        Extract client IP address from request.
        Handles X-Forwarded-For headers for proxied requests.
        """
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0].strip()
        else:
            ip = request.META.get('REMOTE_ADDR', 'Unknown')
        return ip

