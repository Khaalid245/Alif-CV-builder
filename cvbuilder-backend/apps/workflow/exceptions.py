"""
Workflow-specific exceptions for enterprise error handling.
"""


class WorkflowError(Exception):
    """Base exception for all workflow-related errors."""
    pass


class WorkflowNotFoundError(WorkflowError):
    """Raised when a workflow configuration is not found."""
    pass


class StateNotFoundError(WorkflowError):
    """Raised when a workflow state is not found."""
    pass


class InvalidTransitionError(WorkflowError):
    """Raised when attempting an invalid state transition."""
    pass


class ValidationRuleError(WorkflowError):
    """Raised when workflow validation rules fail."""
    pass


class PermissionDeniedError(WorkflowError):
    """Raised when user lacks permission for workflow operation."""
    pass


class WorkflowConfigurationError(WorkflowError):
    """Raised when workflow configuration is invalid."""
    pass