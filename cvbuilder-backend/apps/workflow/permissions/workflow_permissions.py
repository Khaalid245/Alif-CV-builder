"""
Enterprise-grade permissions for workflow operations.
Implements role-based access control with fine-grained permissions.
"""
from rest_framework.permissions import BasePermission
from django.contrib.auth import get_user_model
from ..models import WorkflowInstance, WorkflowConfiguration

User = get_user_model()


class WorkflowPermission(BasePermission):
    """
    Base permission class for workflow operations.
    Implements role-based access control for workflow management.
    """
    
    def has_permission(self, request, view):
        """Check if user has basic workflow access."""
        if not request.user or not request.user.is_authenticated:
            return False
        
        # Check if user account is active
        if not request.user.is_account_active():
            return False
        
        return True
    
    def has_object_permission(self, request, view, obj):
        """Check object-level permissions for workflow operations."""
        if not self.has_permission(request, view):
            return False
        
        # Workflow instance permissions
        if isinstance(obj, WorkflowInstance):
            return self._check_workflow_instance_permission(request, obj)
        
        # Workflow configuration permissions
        if isinstance(obj, WorkflowConfiguration):
            return self._check_workflow_config_permission(request, obj)
        
        return False
    
    def _check_workflow_instance_permission(self, request, instance):
        """Check permissions for workflow instance operations."""
        user = request.user
        
        # Students can only access their own CV workflows
        if user.role == User.Role.STUDENT:
            # Check if this is the user's own CV
            if hasattr(instance.content_object, 'student'):
                return instance.content_object.student == user
            return False
        
        # Admins have full access
        if user.role == User.Role.ADMIN:
            return True
        
        return False
    
    def _check_workflow_config_permission(self, request, config):
        """Check permissions for workflow configuration operations."""
        user = request.user
        
        # Only admins can manage workflow configurations
        return user.role == User.Role.ADMIN


class CanViewWorkflow(WorkflowPermission):
    """Permission to view workflow instances and history."""
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Both students and admins can view workflows
        return request.user.role in [User.Role.STUDENT, User.Role.ADMIN]


class CanTransitionWorkflow(WorkflowPermission):
    """Permission to perform workflow state transitions."""
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Both students and admins can perform transitions
        # Specific transition permissions are checked at the transition level
        return request.user.role in [User.Role.STUDENT, User.Role.ADMIN]
    
    def has_object_permission(self, request, view, obj):
        if not super().has_object_permission(request, view, obj):
            return False
        
        # Additional checks for transition permissions
        if isinstance(obj, WorkflowInstance):
            return self._check_transition_permission(request, obj)
        
        return True
    
    def _check_transition_permission(self, request, instance):
        """Check if user can perform transitions on this instance."""
        user = request.user
        
        # Students can only transition their own CVs
        if user.role == User.Role.STUDENT:
            if hasattr(instance.content_object, 'student'):
                return instance.content_object.student == user
            return False
        
        # Admins can transition any workflow
        if user.role == User.Role.ADMIN:
            return True
        
        return False


class CanManageWorkflow(WorkflowPermission):
    """Permission to manage workflow configurations and rules."""
    
    def has_permission(self, request, view):
        if not super().has_permission(request, view):
            return False
        
        # Only admins can manage workflow configurations
        return request.user.role == User.Role.ADMIN


class IsWorkflowOwner(WorkflowPermission):
    """Permission for workflow owners (students for their own CVs)."""
    
    def has_object_permission(self, request, view, obj):
        if not super().has_object_permission(request, view, obj):
            return False
        
        user = request.user
        
        # Check ownership based on object type
        if isinstance(obj, WorkflowInstance):
            if hasattr(obj.content_object, 'student'):
                return obj.content_object.student == user
        
        return False


class WorkflowTransitionPermission(BasePermission):
    """
    Dynamic permission checking for specific workflow transitions.
    Checks role-based permissions defined in transition configuration.
    """
    
    def has_permission(self, request, view):
        """Basic authentication and account status check."""
        if not request.user or not request.user.is_authenticated:
            return False
        
        return request.user.is_account_active()
    
    def check_transition_permission(self, user, transition):
        """
        Check if user has permission to perform a specific transition.
        
        Args:
            user: User attempting the transition
            transition: WorkflowTransition instance
            
        Returns:
            bool: True if user has permission
        """
        # Check if transition has role restrictions
        if not transition.allowed_roles:
            return True  # No role restrictions
        
        # Check if user's role is in allowed roles
        user_role = getattr(user, 'role', None)
        return user_role in transition.allowed_roles


class CVWorkflowPermission(WorkflowPermission):
    """
    Specialized permission class for CV workflow operations.
    Implements CV-specific business rules and access control.
    """
    
    def has_object_permission(self, request, view, obj):
        if not super().has_object_permission(request, view, obj):
            return False
        
        user = request.user
        
        # CV-specific permission logic
        if isinstance(obj, WorkflowInstance):
            return self._check_cv_workflow_permission(request, obj)
        
        return True
    
    def _check_cv_workflow_permission(self, request, instance):
        """Check CV-specific workflow permissions."""
        user = request.user
        cv = instance.content_object
        
        # Students can only access their own CVs
        if user.role == User.Role.STUDENT:
            return hasattr(cv, 'student') and cv.student == user
        
        # Admins have full access for review and management
        if user.role == User.Role.ADMIN:
            return True
        
        return False


def get_workflow_permissions_for_user(user, workflow_instance):
    """
    Get a summary of workflow permissions for a user.
    
    Args:
        user: User to check permissions for
        workflow_instance: WorkflowInstance to check
        
    Returns:
        dict: Permission summary
    """
    permissions = {
        'can_view': False,
        'can_transition': False,
        'can_manage': False,
        'is_owner': False,
        'available_actions': []
    }
    
    if not user or not user.is_authenticated:
        return permissions
    
    # Check basic permissions
    base_permission = WorkflowPermission()
    can_view_permission = CanViewWorkflow()
    can_transition_permission = CanTransitionWorkflow()
    can_manage_permission = CanManageWorkflow()
    is_owner_permission = IsWorkflowOwner()
    
    # Mock request object for permission checking
    class MockRequest:
        def __init__(self, user):
            self.user = user
    
    mock_request = MockRequest(user)
    
    # Check permissions
    permissions['can_view'] = can_view_permission.has_object_permission(
        mock_request, None, workflow_instance
    )
    permissions['can_transition'] = can_transition_permission.has_object_permission(
        mock_request, None, workflow_instance
    )
    permissions['can_manage'] = can_manage_permission.has_permission(
        mock_request, None
    )
    permissions['is_owner'] = is_owner_permission.has_object_permission(
        mock_request, None, workflow_instance
    )
    
    # Determine available actions based on permissions
    if permissions['can_view']:
        permissions['available_actions'].append('view_history')
        permissions['available_actions'].append('view_status')
    
    if permissions['can_transition']:
        permissions['available_actions'].append('submit_for_review')
        permissions['available_actions'].append('request_changes')
    
    if permissions['can_manage']:
        permissions['available_actions'].extend([
            'approve', 'reject', 'publish', 'manage_configuration'
        ])
    
    return permissions