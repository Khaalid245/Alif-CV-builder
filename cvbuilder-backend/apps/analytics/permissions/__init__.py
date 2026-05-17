"""
Permissions for Analytics system.
Implements role-based access control for analytics operations.
"""
from rest_framework import permissions
from django.core.exceptions import ObjectDoesNotExist

from ..models import ScoreSnapshot, BenchmarkingGroup, AnalyticsEvent


class AnalyticsPermission(permissions.BasePermission):
    """
    Base permission class for analytics operations.
    Ensures users can only access their own analytics data.
    """
    
    def has_permission(self, request, view):
        """Check if user has permission to access analytics."""
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        """Check object-level permissions."""
        if isinstance(obj, ScoreSnapshot):
            return obj.user == request.user or request.user.is_staff
        elif isinstance(obj, BenchmarkingGroup):
            # Users can view groups they belong to, staff can view all
            return (
                request.user.is_staff or
                obj.users.filter(id=request.user.id).exists()
            )
        elif isinstance(obj, AnalyticsEvent):
            # Users can view their own events, staff can view all
            return obj.user == request.user or request.user.is_staff
        return False


class CanViewAnalytics(AnalyticsPermission):
    """
    Permission to view analytics data.
    Users can view their own analytics.
    Admins can view any analytics.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow GET requests for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        """Users can view their own analytics, admins can view any."""
        if request.user.is_staff:
            return True
        
        return super().has_object_permission(request, view, obj)


class CanManageAnalytics(AnalyticsPermission):
    """
    Permission to manage analytics (create snapshots, update configurations).
    Only staff users can manage analytics operations.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only staff can manage analytics
        return request.user.is_staff
    
    def has_object_permission(self, request, view, obj):
        """Only staff can manage analytics objects."""
        return request.user.is_staff


class CanViewBenchmarking(AnalyticsPermission):
    """
    Permission to view benchmarking data.
    Users can view benchmarking for groups they belong to.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow GET requests for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return False
    
    def has_object_permission(self, request, view, obj):
        """Check benchmarking access permissions."""
        if request.user.is_staff:
            return True
        
        if isinstance(obj, BenchmarkingGroup):
            return obj.users.filter(id=request.user.id).exists()
        
        return super().has_object_permission(request, view, obj)


class CanManageBenchmarking(AnalyticsPermission):
    """
    Permission to manage benchmarking groups and configurations.
    Only staff users can manage benchmarking.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Read access for all authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write access only for staff
        return request.user.is_staff
    
    def has_object_permission(self, request, view, obj):
        """Only staff can manage benchmarking objects."""
        if request.method in permissions.SAFE_METHODS:
            return super().has_object_permission(request, view, obj)
        
        return request.user.is_staff


class CanViewMetrics(AnalyticsPermission):
    """
    Permission to view metrics and aggregated data.
    Users can view metrics relevant to them.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow GET requests for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return False


class CanManageMetrics(AnalyticsPermission):
    """
    Permission to manage metric definitions and calculations.
    Only staff users can manage metrics.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Read access for all authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write access only for staff
        return request.user.is_staff


class CanViewConfiguration(AnalyticsPermission):
    """
    Permission to view analytics configuration.
    Only staff users can view configuration.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only staff can view configuration
        return request.user.is_staff


class CanManageConfiguration(AnalyticsPermission):
    """
    Permission to manage analytics configuration.
    Only superusers can modify analytics settings.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only staff can view configuration
        if request.method in permissions.SAFE_METHODS:
            return request.user.is_staff
        
        # Only superusers can modify configuration
        return request.user.is_staff and request.user.is_superuser


class CanViewAuditLogs(AnalyticsPermission):
    """
    Permission to view analytics audit logs.
    Users can view their own logs.
    Admins can view all logs.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        return request.method in permissions.SAFE_METHODS
    
    def has_object_permission(self, request, view, obj):
        """Check access to analytics events."""
        if request.user.is_staff:
            return True
        
        # Users can only view their own events
        if isinstance(obj, AnalyticsEvent):
            return obj.user == request.user
        
        return False


class CanAccessDashboard(AnalyticsPermission):
    """
    Permission to access analytics dashboards.
    Users can access their own dashboard.
    Staff can access administrative dashboards.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        return request.method in permissions.SAFE_METHODS


class CanAccessAdminDashboard(AnalyticsPermission):
    """
    Permission to access administrative analytics dashboards.
    Only staff users can access admin dashboards.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only staff can access admin dashboards
        return request.user.is_staff and request.method in permissions.SAFE_METHODS


def get_user_analytics_queryset(user):
    """
    Helper function to get analytics queryset for a user.
    
    Args:
        user: User instance
        
    Returns:
        QuerySet of analytics data the user can access
    """
    if user.is_staff:
        return ScoreSnapshot.objects.all()
    else:
        return ScoreSnapshot.objects.filter(user=user)


def get_user_benchmarking_queryset(user):
    """
    Helper function to get benchmarking queryset for a user.
    
    Args:
        user: User instance
        
    Returns:
        QuerySet of benchmarking groups the user can access
    """
    if user.is_staff:
        return BenchmarkingGroup.objects.all()
    else:
        return BenchmarkingGroup.objects.filter(
            users=user,
            is_active=True
        )


def get_user_events_queryset(user):
    """
    Helper function to get analytics events queryset for a user.
    
    Args:
        user: User instance
        
    Returns:
        QuerySet of analytics events the user can access
    """
    if user.is_staff:
        return AnalyticsEvent.objects.all()
    else:
        return AnalyticsEvent.objects.filter(user=user)


def check_analytics_ownership(user, snapshot_id):
    """
    Check if user owns the specified analytics snapshot.
    
    Args:
        user: User instance
        snapshot_id: ScoreSnapshot UUID
        
    Returns:
        bool: True if user owns the snapshot, False otherwise
    """
    try:
        snapshot = ScoreSnapshot.objects.get(id=snapshot_id)
        return snapshot.user == user or user.is_staff
    except ScoreSnapshot.DoesNotExist:
        return False


def check_benchmarking_access(user, group_id):
    """
    Check if user has access to the specified benchmarking group.
    
    Args:
        user: User instance
        group_id: BenchmarkingGroup UUID
        
    Returns:
        bool: True if user has access, False otherwise
    """
    try:
        group = BenchmarkingGroup.objects.get(id=group_id)
        return (
            user.is_staff or
            group.users.filter(id=user.id).exists()
        )
    except BenchmarkingGroup.DoesNotExist:
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
        if isinstance(obj, ScoreSnapshot):
            return obj.user == request.user
        elif isinstance(obj, AnalyticsEvent):
            return obj.user == request.user
        elif isinstance(obj, BenchmarkingGroup):
            return obj.users.filter(id=request.user.id).exists()
        elif hasattr(obj, 'user'):
            return obj.user == request.user
        
        return False


class ReadOnlyOrStaff(permissions.BasePermission):
    """
    Permission that allows read-only access to everyone,
    but write access only to staff users.
    """
    
    def has_permission(self, request, view):
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Read permissions for any authenticated user
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions only to staff users
        return request.user.is_staff


class CanCreateSnapshots(AnalyticsPermission):
    """
    Permission to create score snapshots.
    Users can create snapshots for themselves.
    Staff can create snapshots for any user.
    """
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Allow POST requests for authenticated users
        return request.method == 'POST'
    
    def validate_snapshot_creation(self, request_data, user):
        """
        Validate snapshot creation permissions.
        
        Args:
            request_data: Request data containing user_id
            user: Current user making the request
            
        Returns:
            bool: True if user can create snapshot for target user
        """
        target_user_id = request_data.get('user_id')
        
        # If no user_id specified, user is creating for themselves
        if not target_user_id:
            return True
        
        # Staff can create snapshots for any user
        if user.is_staff:
            return True
        
        # Users can only create snapshots for themselves
        return str(user.id) == str(target_user_id)