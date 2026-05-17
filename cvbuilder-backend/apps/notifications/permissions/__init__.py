"""
Permissions for Notifications system.
Implements role-based access control for notification operations.
"""
from rest_framework import permissions
from django.core.exceptions import ObjectDoesNotExist
from django.db import models

from ..models import Notification, NotificationBatch, NotificationTemplate


class NotificationPermission(permissions.BasePermission):
    """
    Base permission class for notification operations.
    Ensures users can only access their own notifications.
    """
    
    def has_permission(self, request, view):
        """Check if user has permission to access notifications."""
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """Check object-level permissions."""
        if isinstance(obj, Notification):
            return obj.user == request.user
        elif isinstance(obj, NotificationBatch):
            # Users can view batches they created or are targeted by
            return (
                obj.created_by == request.user or
                obj.target_users.filter(id=request.user.id).exists()
            )
        return False


class CanViewNotifications(NotificationPermission):
    """
    Permission to view notifications.
    Users can view their own notifications.
    Admins can view any notifications.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow GET requests for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        """Users can view their own notifications, admins can view any."""
        if request.user.is_staff:
            return True
        
        return super().has_object_permission(request, view, obj)


class CanManageNotifications(NotificationPermission):
    """
    Permission to manage notifications (mark as read, delete).
    Only notification owners can manage their notifications.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow POST, PUT, PATCH, DELETE for authenticated users
        return request.method in ['GET', 'POST', 'PUT', 'PATCH', 'DELETE']
    
    def has_object_permission(self, request, view, obj):
        """Only notification owners can manage notifications."""
        # Staff users cannot manage user notifications for privacy
        return super().has_object_permission(request, view, obj)


class CanCreateNotifications(permissions.BasePermission):
    """
    Permission to create notifications.
    Only staff users can create notifications for other users.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Only staff can create notifications
        return request.user.is_staff


class CanManageTemplates(permissions.BasePermission):
    """
    Permission to manage notification templates.
    Only staff users can manage templates.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Read access for all authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write access only for staff
        return request.user.is_staff


class CanManageConfiguration(permissions.BasePermission):
    """
    Permission to manage notification configuration.
    Only superusers can modify notification settings.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Only staff can view configuration
        if request.method in permissions.SAFE_METHODS:
            return request.user.is_staff
        
        # Only superusers can modify configuration
        return request.user.is_staff and request.user.is_superuser


class CanViewAuditLogs(permissions.BasePermission):
    """
    Permission to view notification audit logs.
    Users can view their own logs.
    Admins can view all logs.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        return request.method in permissions.SAFE_METHODS
    
    def has_object_permission(self, request, view, obj):
        """Check access to notification events."""
        if request.user.is_staff:
            return True
        
        # Users can only view their own events
        if hasattr(obj, 'user'):
            return obj.user == request.user
        elif hasattr(obj, 'notification') and obj.notification:
            return obj.notification.user == request.user
        
        return False


class CanManageBulkNotifications(permissions.BasePermission):
    """
    Permission to manage bulk notifications.
    Only staff users can create and manage bulk notifications.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Read access for staff and users (to see batches they're part of)
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write access only for staff
        return request.user.is_staff
    
    def has_object_permission(self, request, view, obj):
        """Check access to notification batches."""
        if request.user.is_staff:
            return True
        
        # Users can view batches they created or are targeted by
        if isinstance(obj, NotificationBatch):
            return (
                obj.created_by == request.user or
                obj.target_users.filter(id=request.user.id).exists()
            )
        
        return False


class CanManagePreferences(NotificationPermission):
    """
    Permission to manage notification preferences.
    Users can only manage their own preferences.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        return True
    
    def has_object_permission(self, request, view, obj):
        """Users can only manage their own preferences."""
        return obj.user == request.user


def get_user_notifications_queryset(user):
    """
    Helper function to get notifications queryset for a user.
    
    Args:
        user: User instance
        
    Returns:
        QuerySet of notifications the user can access
    """
    if user.is_staff:
        return Notification.objects.all()
    else:
        return Notification.objects.filter(user=user)


def get_user_batches_queryset(user):
    """
    Helper function to get notification batches queryset for a user.
    
    Args:
        user: User instance
        
    Returns:
        QuerySet of batches the user can access
    """
    if user.is_staff:
        return NotificationBatch.objects.all()
    else:
        # Users can see batches they created or are targeted by
        return NotificationBatch.objects.filter(
            models.Q(created_by=user) | models.Q(target_users=user)
        ).distinct()


def check_notification_ownership(user, notification_id):
    """
    Check if user owns the specified notification.
    
    Args:
        user: User instance
        notification_id: Notification UUID
        
    Returns:
        bool: True if user owns the notification, False otherwise
    """
    try:
        notification = Notification.objects.get(id=notification_id)
        return notification.user == user
    except Notification.DoesNotExist:
        return False


def check_batch_access(user, batch_id):
    """
    Check if user has access to the specified batch.
    
    Args:
        user: User instance
        batch_id: NotificationBatch UUID
        
    Returns:
        bool: True if user has access, False otherwise
    """
    try:
        batch = NotificationBatch.objects.get(id=batch_id)
        return (
            user.is_staff or
            batch.created_by == user or
            batch.target_users.filter(id=user.id).exists()
        )
    except NotificationBatch.DoesNotExist:
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
        if isinstance(obj, Notification):
            return obj.user == request.user
        elif isinstance(obj, NotificationBatch):
            return (
                obj.created_by == request.user or
                obj.target_users.filter(id=request.user.id).exists()
            )
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