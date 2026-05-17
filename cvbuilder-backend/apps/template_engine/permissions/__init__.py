"""
Template Engine permissions for EduCV.
Role-based access control for template management and usage.
"""
from rest_framework import permissions
from django.contrib.auth import get_user_model
from .models import Template, UserTemplatePreference

User = get_user_model()


class IsAdminOrReadOnly(permissions.BasePermission):
    """
    Admin users can perform any action.
    Authenticated users can read only.
    Anonymous users are denied.
    """
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return request.user.is_staff or request.user.is_superuser


class IsTemplateOwnerOrAdmin(permissions.BasePermission):
    """
    Template creators and admins can modify templates.
    Others can read only.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Read permissions for authenticated users
        if request.method in permissions.SAFE_METHODS:
            return True
        
        # Write permissions for admins
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # For now, only admins can create/modify templates
        # In future versions, you might allow template creators
        return False


class CanUseTemplate(permissions.BasePermission):
    """
    Permission to use/render templates.
    Students can use active templates.
    Admins can use any template.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Admins can use any template
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # Students can only use active templates
        if isinstance(obj, Template):
            return obj.status == Template.Status.ACTIVE
        
        return True


class CanManageOwnPreferences(permissions.BasePermission):
    """
    Users can only manage their own template preferences.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Users can only access their own preferences
        if isinstance(obj, UserTemplatePreference):
            return obj.user == request.user
        
        return True


class CanViewTemplateAnalytics(permissions.BasePermission):
    """
    Permission to view template analytics.
    Admins can view all analytics.
    Users can view limited analytics for templates they've used.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Admins can view all analytics
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # Users can view analytics for templates they've used
        # This would be implemented in the view logic
        return True


class CanManageTemplateCategories(permissions.BasePermission):
    """
    Only admins can manage template categories and industries.
    """
    
    def has_permission(self, request, view):
        if not request.user.is_authenticated:
            return False
        
        if request.method in permissions.SAFE_METHODS:
            return True
        
        return request.user.is_staff or request.user.is_superuser


class CanAccessPremiumTemplates(permissions.BasePermission):
    """
    Permission to access premium templates.
    For future implementation of premium features.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # For now, all authenticated users can access premium templates
        # In future, this could check subscription status
        if isinstance(obj, Template) and obj.is_premium:
            # Check if user has premium access
            # For now, return True for all authenticated users
            return True
        
        return True


class CanBulkManageTemplates(permissions.BasePermission):
    """
    Only admins can perform bulk operations on templates.
    """
    
    def has_permission(self, request, view):
        return (request.user.is_authenticated and 
                (request.user.is_staff or request.user.is_superuser))


class CanViewSystemAnalytics(permissions.BasePermission):
    """
    Only admins can view system-wide analytics and metrics.
    """
    
    def has_permission(self, request, view):
        return (request.user.is_authenticated and 
                (request.user.is_staff or request.user.is_superuser))


class CanManageTemplateRecommendations(permissions.BasePermission):
    """
    Permission to manage template recommendations.
    Users can view their own recommendations.
    Admins can manage all recommendations.
    """
    
    def has_permission(self, request, view):
        return request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        # Admins can manage all recommendations
        if request.user.is_staff or request.user.is_superuser:
            return True
        
        # Users can only view/update their own recommendations
        from .models import TemplateRecommendation
        if isinstance(obj, TemplateRecommendation):
            if request.method in permissions.SAFE_METHODS:
                return obj.user == request.user
            # Only allow updating interaction fields
            return obj.user == request.user and request.method in ['PATCH', 'PUT']
        
        return True


class StudentOnlyPermission(permissions.BasePermission):
    """
    Permission for student-only endpoints.
    """
    
    def has_permission(self, request, view):
        return (request.user.is_authenticated and 
                not request.user.is_staff and 
                not request.user.is_superuser)


class AdminOnlyPermission(permissions.BasePermission):
    """
    Permission for admin-only endpoints.
    """
    
    def has_permission(self, request, view):
        return (request.user.is_authenticated and 
                (request.user.is_staff or request.user.is_superuser))


class TemplateEnginePermissionMixin:
    """
    Mixin to provide common permission methods for template engine views.
    """
    
    def get_permissions(self):
        """
        Return appropriate permissions based on action.
        """
        if self.action in ['list', 'retrieve']:
            permission_classes = [permissions.IsAuthenticated]
        elif self.action in ['create', 'update', 'partial_update', 'destroy']:
            permission_classes = [IsAdminOrReadOnly]
        elif self.action in ['render', 'preview', 'download']:
            permission_classes = [CanUseTemplate]
        elif self.action in ['analytics', 'metrics']:
            permission_classes = [CanViewTemplateAnalytics]
        elif self.action in ['bulk_action']:
            permission_classes = [CanBulkManageTemplates]
        else:
            permission_classes = [permissions.IsAuthenticated]
        
        return [permission() for permission in permission_classes]


# Permission mapping for different user roles
TEMPLATE_PERMISSIONS = {
    'student': {
        'can_view_templates': True,
        'can_use_templates': True,
        'can_favorite_templates': True,
        'can_manage_preferences': True,
        'can_view_own_analytics': True,
        'can_create_templates': False,
        'can_modify_templates': False,
        'can_delete_templates': False,
        'can_view_all_analytics': False,
        'can_manage_categories': False,
        'can_bulk_operations': False,
    },
    'admin': {
        'can_view_templates': True,
        'can_use_templates': True,
        'can_favorite_templates': True,
        'can_manage_preferences': True,
        'can_view_own_analytics': True,
        'can_create_templates': True,
        'can_modify_templates': True,
        'can_delete_templates': True,
        'can_view_all_analytics': True,
        'can_manage_categories': True,
        'can_bulk_operations': True,
    }
}


def get_user_template_permissions(user):
    """
    Get template permissions for a user based on their role.
    """
    if user.is_staff or user.is_superuser:
        return TEMPLATE_PERMISSIONS['admin']
    else:
        return TEMPLATE_PERMISSIONS['student']


def check_template_permission(user, permission_name):
    """
    Check if user has a specific template permission.
    """
    permissions = get_user_template_permissions(user)
    return permissions.get(permission_name, False)