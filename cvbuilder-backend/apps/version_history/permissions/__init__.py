"""
Permissions for Version History system.
Implements role-based access control for version operations.
"""
from rest_framework import permissions
from django.core.exceptions import ObjectDoesNotExist

from apps.cv.models import CVProfile
from ..models import CVVersion


class VersionHistoryPermission(permissions.BasePermission):
    """
    Base permission class for version history operations.
    Ensures users can only access their own CV versions.
    """
    
    def has_permission(self, request, view):
        """Check if user has permission to access version history."""
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """Check object-level permissions."""
        if isinstance(obj, CVProfile):
            return obj.student == request.user
        elif isinstance(obj, CVVersion):
            return obj.cv_profile.student == request.user
        return False


class CanViewVersionHistory(VersionHistoryPermission):
    """
    Permission to view version history.
    Students can view their own CV version history.
    Admins can view any version history.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow GET requests for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        """Students can view their own versions, admins can view any."""
        if request.user.is_staff:
            return True
        
        return super().has_object_permission(request, view, obj)


class CanRestoreVersion(VersionHistoryPermission):
    """
    Permission to restore versions.
    Only CV owners can restore their own versions.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only allow POST for restore operations
        return request.method == 'POST'
    
    def has_object_permission(self, request, view, obj):
        """Only CV owners can restore versions."""
        # Staff users cannot restore student CVs for security
        return super().has_object_permission(request, view, obj)


class CanCompareVersions(VersionHistoryPermission):
    """
    Permission to compare versions.
    Students can compare their own versions.
    Admins can compare any versions.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        return request.method in ['GET', 'POST']
    
    def has_object_permission(self, request, view, obj):
        """Students can compare their own versions, admins can compare any."""
        if request.user.is_staff:
            return True
        
        return super().has_object_permission(request, view, obj)


class CanManageVersionConfiguration(permissions.BasePermission):
    """
    Permission to manage version configuration.
    Only staff users can modify version settings.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Only staff can manage configuration
        if request.method in permissions.SAFE_METHODS:
            return request.user.is_staff
        
        return request.user.is_staff and request.user.is_superuser


class CanViewVersionActions(VersionHistoryPermission):
    """
    Permission to view version actions (audit logs).
    Students can view their own actions.
    Admins can view all actions.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        return request.method in permissions.SAFE_METHODS
    
    def has_object_permission(self, request, view, obj):
        """Check access to version actions."""
        if request.user.is_staff:
            return True
        
        # Students can only view their own actions
        if hasattr(obj, 'cv_profile'):
            return obj.cv_profile.student == request.user
        elif hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class CanDeleteVersions(VersionHistoryPermission):
    """
    Permission to delete versions.
    Only superusers can delete versions for compliance reasons.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only superusers can delete versions
        return request.user.is_superuser and request.method == 'DELETE'
    
    def has_object_permission(self, request, view, obj):
        """Only superusers can delete any version."""
        return request.user.is_superuser


def get_user_cv_profile(user):
    """
    Helper function to get user's CV profile.
    
    Args:
        user: User instance
        
    Returns:
        CVProfile instance or None
    """
    try:
        return user.cv_profile
    except ObjectDoesNotExist:
        return None


def check_cv_ownership(user, cv_profile_id):
    """
    Check if user owns the specified CV profile.
    
    Args:
        user: User instance
        cv_profile_id: CV profile UUID
        
    Returns:
        bool: True if user owns the CV, False otherwise
    """
    try:
        cv_profile = CVProfile.objects.get(id=cv_profile_id)
        return cv_profile.student == user
    except CVProfile.DoesNotExist:
        return False


def check_version_ownership(user, version_id):
    """
    Check if user owns the CV associated with the version.
    
    Args:
        user: User instance
        version_id: CVVersion UUID
        
    Returns:
        bool: True if user owns the CV, False otherwise
    """
    try:
        version = CVVersion.objects.select_related('cv_profile__student').get(id=version_id)
        return version.cv_profile.student == user
    except CVVersion.DoesNotExist:
        return False


class IsOwnerOrAdmin(permissions.BasePermission):
    """
    Custom permission to only allow owners of an object or admins to access it.
    """
    
    def has_object_permission(self, request, view, obj):
        # Admin users have full access
        if request.user.is_staff:
            return True
        
        # Check ownership based on object type
        if isinstance(obj, CVProfile):
            return obj.student == request.user
        elif isinstance(obj, CVVersion):
            return obj.cv_profile.student == request.user
        elif hasattr(obj, 'cv_profile'):
            return obj.cv_profile.student == request.user
        elif hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class ReadOnlyOrOwner(permissions.BasePermission):
    """
    Permission that allows read-only access to everyone,
    but write access only to the owner.
    """
    
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Read permissions for any authenticated user
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions only to the owner
        return IsOwnerOrAdmin().has_object_permission(request, view, obj)