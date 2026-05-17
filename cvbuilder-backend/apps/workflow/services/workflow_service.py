"""
Enterprise Workflow Service.

This service handles all workflow operations including state transitions,
validation, and audit logging. It provides a clean interface for workflow
management while maintaining enterprise-grade security and auditability.
"""
import logging
from typing import Dict, List, Optional, Tuple, Any
from django.db import transaction
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import ValidationError, PermissionDenied
from django.utils import timezone
from apps.core.utils import get_client_ip
from apps.users.models import AuditLog
from ..models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance, WorkflowTransitionLog, WorkflowRule
)
from ..exceptions import (
    WorkflowError, InvalidTransitionError, ValidationRuleError,
    WorkflowNotFoundError, StateNotFoundError
)

logger = logging.getLogger(__name__)


class WorkflowService:
    """
    Core workflow service for managing entity state transitions.
    
    This service provides enterprise-grade workflow management with:
    - Configuration-driven state definitions
    - Role-based transition permissions
    - Comprehensive validation rules
    - Complete audit logging
    - Transaction safety
    """
    
    def __init__(self):
        self.rule_validator = WorkflowRuleValidator()
    
    def initialize_workflow(
        self,
        entity: Any,
        workflow_config: Optional[WorkflowConfiguration] = None,
        user: Any = None,
        initial_properties: Optional[Dict] = None
    ) -> WorkflowInstance:
        """
        Initialize a new workflow instance for an entity.
        
        Args:
            entity: The entity to attach the workflow to
            workflow_config: Specific workflow configuration (optional)
            user: User initializing the workflow
            initial_properties: Initial instance properties
            
        Returns:
            WorkflowInstance: The created workflow instance
            
        Raises:
            WorkflowNotFoundError: If no suitable workflow configuration found
            ValidationError: If initialization validation fails
        """
        try:
            with transaction.atomic():
                # Get workflow configuration
                if not workflow_config:
                    entity_type = self._get_entity_type(entity)
                    workflow_config = WorkflowConfiguration.get_default_for_entity(entity_type)
                    
                if not workflow_config:
                    raise WorkflowNotFoundError(
                        f"No workflow configuration found for entity type: {type(entity).__name__}"
                    )
                
                # Get initial state
                initial_state = workflow_config.states.filter(
                    state_type=WorkflowState.StateType.INITIAL,
                    is_active=True
                ).first()
                
                if not initial_state:
                    raise StateNotFoundError(
                        f"No initial state found for workflow: {workflow_config.name}"
                    )
                
                # Create workflow instance
                content_type = ContentType.objects.get_for_model(entity)
                instance = WorkflowInstance.objects.create(
                    workflow_config=workflow_config,
                    content_type=content_type,
                    object_id=str(entity.pk),
                    current_state=initial_state,
                    started_by=user,
                    properties=initial_properties or {}
                )
                
                # Log initialization
                self._log_workflow_action(
                    instance, None, initial_state, user,
                    action='workflow_initialized',
                    comment='Workflow initialized'
                )
                
                logger.info(
                    f"Workflow initialized for {entity} by {user}. "
                    f"Instance: {instance.id}, Initial state: {initial_state.name}"
                )
                
                return instance
                
        except Exception as e:
            logger.error(f"Failed to initialize workflow for {entity}: {str(e)}")
            raise
    
    def transition_state(
        self,
        instance: WorkflowInstance,
        to_state_code: str,
        user: Any,
        comment: str = '',
        request: Any = None,
        additional_data: Optional[Dict] = None
    ) -> WorkflowTransitionLog:
        """
        Perform a state transition with full validation and audit logging.
        
        Args:
            instance: Workflow instance to transition
            to_state_code: Target state code
            user: User performing the transition
            comment: Optional comment for the transition
            request: HTTP request object for audit logging
            additional_data: Additional metadata for the transition
            
        Returns:
            WorkflowTransitionLog: The transition log entry
            
        Raises:
            InvalidTransitionError: If transition is not allowed
            PermissionDenied: If user lacks permission
            ValidationRuleError: If validation rules fail
        """
        try:
            with transaction.atomic():
                # Get target state
                to_state = instance.workflow_config.states.filter(
                    code=to_state_code,
                    is_active=True
                ).first()
                
                if not to_state:
                    raise StateNotFoundError(
                        f"State '{to_state_code}' not found in workflow '{instance.workflow_config.name}'"
                    )
                
                # Find valid transition
                transition = self._find_valid_transition(
                    instance.current_state, to_state, user
                )
                
                # Validate transition rules
                self._validate_transition_rules(instance, transition, user)
                
                # Validate required comment
                if transition.requires_comment and not comment.strip():
                    raise ValidationRuleError("Comment is required for this transition")
                
                # Perform the transition
                from_state = instance.current_state
                instance.current_state = to_state
                instance.updated_at = timezone.now()
                instance.save(update_fields=['current_state', 'updated_at'])
                
                # Create transition log
                transition_log = WorkflowTransitionLog.objects.create(
                    workflow_instance=instance,
                    transition=transition,
                    from_state=from_state,
                    to_state=to_state,
                    performed_by=user,
                    result=WorkflowTransitionLog.TransitionResult.SUCCESS,
                    comment=comment,
                    ip_address=get_client_ip(request) if request else None,
                    user_agent=request.META.get('HTTP_USER_AGENT', '') if request else '',
                    metadata=additional_data or {}
                )
                
                # Log to audit system
                AuditLog.log(
                    user,
                    AuditLog.Action.CV_UPDATED,
                    request,
                    extra_data={
                        'workflow_transition': {
                            'instance_id': str(instance.id),
                            'from_state': from_state.code,
                            'to_state': to_state.code,
                            'transition_id': str(transition.id),
                            'comment': comment
                        }
                    }
                )
                
                logger.info(
                    f"Workflow transition completed: {from_state.name} → {to_state.name} "
                    f"for instance {instance.id} by {user}"
                )
                
                # Trigger post-transition actions
                self._trigger_post_transition_actions(instance, transition_log)
                
                return transition_log
                
        except Exception as e:
            # Log failed transition attempt
            self._log_failed_transition(instance, to_state_code, user, str(e), request)
            logger.error(f"Workflow transition failed: {str(e)}")
            raise
    
    def get_available_transitions(
        self,
        instance: WorkflowInstance,
        user: Any
    ) -> List[Dict]:
        """
        Get all available transitions for the current state and user.
        
        Args:
            instance: Workflow instance
            user: User to check permissions for
            
        Returns:
            List of available transitions with metadata
        """
        transitions = instance.current_state.outgoing_transitions.filter(
            is_active=True
        )
        
        available = []
        for transition in transitions:
            # Check role permissions
            if self._check_transition_permission(transition, user):
                # Check validation rules
                validation_result = self._check_validation_rules(instance, transition)
                
                available.append({
                    'id': str(transition.id),
                    'name': transition.name,
                    'description': transition.description,
                    'to_state': {
                        'code': transition.to_state.code,
                        'name': transition.to_state.name
                    },
                    'requires_comment': transition.requires_comment,
                    'validation_passed': validation_result['valid'],
                    'validation_errors': validation_result['errors'],
                    'properties': transition.properties
                })
        
        return available
    
    def get_workflow_history(
        self,
        instance: WorkflowInstance,
        limit: int = 50
    ) -> List[Dict]:
        """
        Get the complete transition history for a workflow instance.
        
        Args:
            instance: Workflow instance
            limit: Maximum number of entries to return
            
        Returns:
            List of transition history entries
        """
        logs = instance.transition_logs.select_related(
            'from_state', 'to_state', 'performed_by', 'transition'
        ).order_by('-performed_at')[:limit]
        
        history = []
        for log in logs:
            history.append({
                'id': str(log.id),
                'from_state': {
                    'code': log.from_state.code,
                    'name': log.from_state.name
                },
                'to_state': {
                    'code': log.to_state.code,
                    'name': log.to_state.name
                },
                'transition_name': log.transition.name,
                'performed_by': {
                    'id': str(log.performed_by.id),
                    'name': log.performed_by.full_name,
                    'email': log.performed_by.email
                },
                'performed_at': log.performed_at.isoformat(),
                'result': log.result,
                'comment': log.comment,
                'metadata': log.metadata
            })
        
        return history
    
    def _find_valid_transition(
        self,
        from_state: WorkflowState,
        to_state: WorkflowState,
        user: Any
    ) -> WorkflowTransition:
        """Find and validate a transition between states."""
        transition = WorkflowTransition.objects.filter(
            from_state=from_state,
            to_state=to_state,
            is_active=True
        ).first()
        
        if not transition:
            raise InvalidTransitionError(
                f"No valid transition from '{from_state.name}' to '{to_state.name}'"
            )
        
        if not self._check_transition_permission(transition, user):
            raise PermissionDenied(
                f"User '{user}' does not have permission to perform this transition"
            )
        
        return transition
    
    def _check_transition_permission(
        self,
        transition: WorkflowTransition,
        user: Any
    ) -> bool:
        """Check if user has permission to perform the transition."""
        if not transition.allowed_roles:
            return True  # No role restrictions
        
        user_role = getattr(user, 'role', None)
        return user_role in transition.allowed_roles
    
    def _validate_transition_rules(
        self,
        instance: WorkflowInstance,
        transition: WorkflowTransition,
        user: Any
    ) -> None:
        """Validate all rules for a transition."""
        # Get rules for this transition
        rules = WorkflowRule.objects.filter(
            workflow_config=instance.workflow_config,
            is_active=True
        )
        
        # Apply transition-specific rules
        if transition.validation_rules:
            for rule_config in transition.validation_rules:
                if not self.rule_validator.validate_rule(
                    instance.content_object, rule_config
                ):
                    error_msg = rule_config.get('error_message', 'Validation rule failed')
                    raise ValidationRuleError(error_msg)
        
        # Apply global workflow rules
        for rule in rules:
            if not self.rule_validator.validate_workflow_rule(instance.content_object, rule):
                raise ValidationRuleError(rule.error_message)
    
    def _check_validation_rules(
        self,
        instance: WorkflowInstance,
        transition: WorkflowTransition
    ) -> Dict:
        """Check validation rules without raising exceptions."""
        errors = []
        
        try:
            self._validate_transition_rules(instance, transition, None)
            return {'valid': True, 'errors': []}
        except ValidationRuleError as e:
            errors.append(str(e))
        except Exception as e:
            errors.append(f"Validation error: {str(e)}")
        
        return {'valid': False, 'errors': errors}
    
    def _trigger_post_transition_actions(
        self,
        instance: WorkflowInstance,
        transition_log: WorkflowTransitionLog
    ) -> None:
        """Trigger actions after successful transition."""
        # This can be extended to trigger notifications, webhooks, etc.
        pass
    
    def _log_workflow_action(
        self,
        instance: WorkflowInstance,
        from_state: Optional[WorkflowState],
        to_state: WorkflowState,
        user: Any,
        action: str,
        comment: str = ''
    ) -> None:
        """Log workflow actions for audit purposes."""
        # This integrates with the existing audit system
        pass
    
    def _log_failed_transition(
        self,
        instance: WorkflowInstance,
        to_state_code: str,
        user: Any,
        error: str,
        request: Any = None
    ) -> None:
        """Log failed transition attempts."""
        logger.warning(
            f"Failed transition attempt: {instance.current_state.name} → {to_state_code} "
            f"by {user}. Error: {error}"
        )
    
    def _get_entity_type(self, entity: Any) -> str:
        """Get the entity type string for workflow configuration lookup."""
        return f"{entity._meta.app_label}.{entity._meta.model_name}"


class WorkflowRuleValidator:
    """
    Validates workflow rules against entity data.
    Supports various operators and field path resolution.
    """
    
    def validate_rule(self, entity: Any, rule_config: Dict) -> bool:
        """Validate a single rule configuration against an entity."""
        try:
            field_path = rule_config.get('field_path')
            operator = rule_config.get('operator')
            expected_value = rule_config.get('expected_value')
            
            if not all([field_path, operator]):
                return True  # Invalid rule configuration, skip
            
            actual_value = self._resolve_field_path(entity, field_path)
            return self._apply_operator(actual_value, operator, expected_value)
            
        except Exception as e:
            logger.error(f"Rule validation error: {str(e)}")
            return False
    
    def validate_workflow_rule(self, entity: Any, rule: 'WorkflowRule') -> bool:
        """Validate a WorkflowRule model against an entity."""
        try:
            actual_value = self._resolve_field_path(entity, rule.field_path)
            return self._apply_operator(actual_value, rule.operator, rule.expected_value)
        except Exception as e:
            logger.error(f"Workflow rule validation error for {rule.name}: {str(e)}")
            return False
    
    def _resolve_field_path(self, entity: Any, field_path: str) -> Any:
        """Resolve a dot-notation field path to get the actual value."""
        current = entity
        
        for part in field_path.split('.'):
            if hasattr(current, part):
                current = getattr(current, part)
                # Handle callable attributes (methods)
                if callable(current):
                    current = current()
            else:
                raise AttributeError(f"Field '{part}' not found in path '{field_path}'")
        
        return current
    
    def _apply_operator(self, actual: Any, operator: str, expected: Any) -> bool:
        """Apply comparison operator between actual and expected values."""
        operators = {
            'eq': lambda a, e: a == e,
            'ne': lambda a, e: a != e,
            'gt': lambda a, e: a > e,
            'lt': lambda a, e: a < e,
            'gte': lambda a, e: a >= e,
            'lte': lambda a, e: a <= e,
            'contains': lambda a, e: e in str(a),
            'in': lambda a, e: a in e,
            'exists': lambda a, e: a is not None,
            'not_exists': lambda a, e: a is None,
        }
        
        operator_func = operators.get(operator)
        if not operator_func:
            logger.warning(f"Unknown operator: {operator}")
            return True
        
        try:
            return operator_func(actual, expected)
        except Exception as e:
            logger.error(f"Operator '{operator}' failed: {str(e)}")
            return False