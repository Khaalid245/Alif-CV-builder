"""
Custom DRF permissions for EduCV.
"""
from rest_framework.permissions import BasePermission


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
    Grants access only to users with is_staff=True.
    Used to protect the administration dashboard endpoints.
    """
    message = 'Admin access required.'

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.is_staff)
