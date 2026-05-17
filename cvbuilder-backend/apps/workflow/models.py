"""
Enterprise Workflow Control System Models.

This module implements a configuration-driven workflow system that manages
CV lifecycle states with role-based transitions and comprehensive audit logging.
"""
import uuid
from django.db import models
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.utils import timezone
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey

User = get_user_model()


class WorkflowConfiguration(models.Model):
    """
    Configuration-driven workflow definitions.
    Allows dynamic workflow creation without code changes.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    name = models.CharField(max_length=100, unique=True)
    description = models.TextField()
    
    # Workflow metadata
    entity_type = models.CharField(
        max_length=50,
        help_text='Type of entity this workflow applies to (e.g., cv_profile)'
    )
    is_active = models.BooleanField(default=True)
    is_default = models.BooleanField(default=False)
    
    # Configuration data
    configuration = models.JSONField(
        default=dict,
        help_text='Workflow configuration including states, transitions, and rules'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    created_by = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name='created_workflows'
    )
    
    class Meta:
        db_table = 'workflow_configurations'
        ordering = ['-is_default', '-is_active', 'name']
        indexes = [
            models.Index(fields=['entity_type', 'is_active']),
            models.Index(fields=['is_default', 'is_active']),
        ]
    
    def __str__(self):
        return f'{self.name} ({self.entity_type})'
    
    def save(self, *args, **kwargs):
        # Ensure only one default configuration per entity type
        if self.is_default:
            WorkflowConfiguration.objects.filter(
                entity_type=self.entity_type,
                is_default=True
            ).exclude(pk=self.pk).update(is_default=False)
        super().save(*args, **kwargs)
    
    @classmethod
    def get_default_for_entity(cls, entity_type: str):
        """Get the default workflow configuration for an entity type."""
        return cls.objects.filter(
            entity_type=entity_type,
            is_active=True,
            is_default=True
        ).first()


class WorkflowState(models.Model):
    """
    Defines available states in a workflow.
    States are configuration-driven and can be modified without code changes.
    """
    
    class StateType(models.TextChoices):
        INITIAL = 'initial', 'Initial'
        INTERMEDIATE = 'intermediate', 'Intermediate'
        FINAL = 'final', 'Final'
        TERMINAL = 'terminal', 'Terminal'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_config = models.ForeignKey(
        WorkflowConfiguration,
        on_delete=models.CASCADE,
        related_name='states'
    )
    
    # State definition
    code = models.CharField(max_length=50)
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    state_type = models.CharField(max_length=15, choices=StateType.choices)
    
    # State properties
    is_active = models.BooleanField(default=True)
    order = models.IntegerField(default=0)
    
    # State configuration
    properties = models.JSONField(
        default=dict,
        help_text='State-specific properties and metadata'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'workflow_states'
        ordering = ['workflow_config', 'order', 'name']
        unique_together = [['workflow_config', 'code']]
        indexes = [
            models.Index(fields=['workflow_config', 'is_active']),
            models.Index(fields=['state_type']),
        ]
    
    def __str__(self):
        return f'{self.workflow_config.name}: {self.name}'


class WorkflowTransition(models.Model):
    """
    Defines allowed transitions between workflow states.
    Includes role-based permissions and validation rules.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_config = models.ForeignKey(
        WorkflowConfiguration,
        on_delete=models.CASCADE,
        related_name='transitions'
    )
    
    # Transition definition
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    from_state = models.ForeignKey(
        WorkflowState,
        on_delete=models.CASCADE,
        related_name='outgoing_transitions'
    )
    to_state = models.ForeignKey(
        WorkflowState,
        on_delete=models.CASCADE,
        related_name='incoming_transitions'
    )
    
    # Permission and validation
    allowed_roles = models.JSONField(
        default=list,
        help_text='List of user roles allowed to perform this transition'
    )
    validation_rules = models.JSONField(
        default=dict,
        help_text='Validation rules that must pass for transition to be allowed'
    )
    
    # Transition properties
    is_active = models.BooleanField(default=True)
    requires_comment = models.BooleanField(default=False)
    auto_transition = models.BooleanField(default=False)
    
    # Configuration
    properties = models.JSONField(
        default=dict,
        help_text='Transition-specific properties and metadata'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'workflow_transitions'
        ordering = ['workflow_config', 'from_state', 'to_state']
        unique_together = [['workflow_config', 'from_state', 'to_state']]
        indexes = [
            models.Index(fields=['workflow_config', 'is_active']),
            models.Index(fields=['from_state']),
            models.Index(fields=['to_state']),
        ]
    
    def __str__(self):
        return f'{self.from_state.name} → {self.to_state.name}'
    
    def clean(self):
        """Validate transition configuration."""
        if self.from_state.workflow_config != self.workflow_config:
            raise ValidationError('From state must belong to the same workflow')
        if self.to_state.workflow_config != self.workflow_config:
            raise ValidationError('To state must belong to the same workflow')
        if self.from_state == self.to_state:
            raise ValidationError('From state and to state cannot be the same')


class WorkflowInstance(models.Model):
    """
    Represents a workflow instance for a specific entity.
    Tracks the current state and workflow history.
    """
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_config = models.ForeignKey(
        WorkflowConfiguration,
        on_delete=models.PROTECT,
        related_name='instances'
    )
    
    # Generic foreign key to any model
    content_type = models.ForeignKey(ContentType, on_delete=models.CASCADE)
    object_id = models.CharField(max_length=255)
    content_object = GenericForeignKey('content_type', 'object_id')
    
    # Current state
    current_state = models.ForeignKey(
        WorkflowState,
        on_delete=models.PROTECT,
        related_name='current_instances'
    )
    
    # Workflow metadata
    started_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    started_by = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name='started_workflows'
    )
    
    # Instance properties
    properties = models.JSONField(
        default=dict,
        help_text='Instance-specific properties and metadata'
    )
    
    class Meta:
        db_table = 'workflow_instances'
        ordering = ['-updated_at']
        unique_together = [['content_type', 'object_id']]
        indexes = [
            models.Index(fields=['workflow_config', 'current_state']),
            models.Index(fields=['content_type', 'object_id']),
            models.Index(fields=['started_by']),
            models.Index(fields=['updated_at']),
        ]
    
    def __str__(self):
        return f'{self.workflow_config.name} for {self.content_object}'


class WorkflowTransitionLog(models.Model):
    """
    Immutable audit log of all workflow transitions.
    Records who performed the transition, when, and why.
    """
    
    class TransitionResult(models.TextChoices):
        SUCCESS = 'success', 'Success'
        FAILED = 'failed', 'Failed'
        REJECTED = 'rejected', 'Rejected'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_instance = models.ForeignKey(
        WorkflowInstance,
        on_delete=models.CASCADE,
        related_name='transition_logs'
    )
    transition = models.ForeignKey(
        WorkflowTransition,
        on_delete=models.PROTECT,
        related_name='logs'
    )
    
    # Transition details
    from_state = models.ForeignKey(
        WorkflowState,
        on_delete=models.PROTECT,
        related_name='transition_logs_from'
    )
    to_state = models.ForeignKey(
        WorkflowState,
        on_delete=models.PROTECT,
        related_name='transition_logs_to'
    )
    
    # Audit information
    performed_by = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name='performed_transitions'
    )
    performed_at = models.DateTimeField(auto_now_add=True)
    
    # Transition context
    result = models.CharField(max_length=10, choices=TransitionResult.choices)
    comment = models.TextField(blank=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True)
    
    # Additional data
    metadata = models.JSONField(
        default=dict,
        help_text='Additional transition metadata and context'
    )
    
    class Meta:
        db_table = 'workflow_transition_logs'
        ordering = ['-performed_at']
        indexes = [
            models.Index(fields=['workflow_instance', '-performed_at']),
            models.Index(fields=['performed_by', '-performed_at']),
            models.Index(fields=['result']),
            models.Index(fields=['performed_at']),
        ]
    
    def __str__(self):
        return f'{self.from_state.name} → {self.to_state.name} by {self.performed_by}'


class WorkflowRule(models.Model):
    """
    Configurable business rules for workflow validation.
    Allows dynamic rule definition without code changes.
    """
    
    class RuleType(models.TextChoices):
        VALIDATION = 'validation', 'Validation Rule'
        CONDITION = 'condition', 'Condition Rule'
        ACTION = 'action', 'Action Rule'
    
    class Operator(models.TextChoices):
        EQUALS = 'eq', 'Equals'
        NOT_EQUALS = 'ne', 'Not Equals'
        GREATER_THAN = 'gt', 'Greater Than'
        LESS_THAN = 'lt', 'Less Than'
        CONTAINS = 'contains', 'Contains'
        IN = 'in', 'In List'
        EXISTS = 'exists', 'Exists'
        CUSTOM = 'custom', 'Custom Function'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_config = models.ForeignKey(
        WorkflowConfiguration,
        on_delete=models.CASCADE,
        related_name='rules'
    )
    
    # Rule definition
    name = models.CharField(max_length=100)
    description = models.TextField(blank=True)
    rule_type = models.CharField(max_length=15, choices=RuleType.choices)
    
    # Rule logic
    field_path = models.CharField(
        max_length=200,
        help_text='Dot-notation path to the field to validate (e.g., cv.completion_percentage)'
    )
    operator = models.CharField(max_length=15, choices=Operator.choices)
    expected_value = models.JSONField(
        help_text='Expected value for comparison'
    )
    
    # Rule configuration
    is_active = models.BooleanField(default=True)
    error_message = models.CharField(
        max_length=255,
        help_text='Error message to display when rule fails'
    )
    
    # Rule metadata
    properties = models.JSONField(
        default=dict,
        help_text='Additional rule properties and configuration'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'workflow_rules'
        ordering = ['workflow_config', 'rule_type', 'name']
        indexes = [
            models.Index(fields=['workflow_config', 'is_active']),
            models.Index(fields=['rule_type']),
        ]
    
    def __str__(self):
        return f'{self.workflow_config.name}: {self.name}'


class WorkflowNotification(models.Model):
    """
    Workflow-triggered notifications for state changes.
    Supports multiple notification channels and templates.
    """
    
    class NotificationType(models.TextChoices):
        EMAIL = 'email', 'Email'
        SMS = 'sms', 'SMS'
        PUSH = 'push', 'Push Notification'
        WEBHOOK = 'webhook', 'Webhook'
        INTERNAL = 'internal', 'Internal Notification'
    
    class Status(models.TextChoices):
        PENDING = 'pending', 'Pending'
        SENT = 'sent', 'Sent'
        FAILED = 'failed', 'Failed'
        CANCELLED = 'cancelled', 'Cancelled'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    workflow_instance = models.ForeignKey(
        WorkflowInstance,
        on_delete=models.CASCADE,
        related_name='notifications'
    )
    transition_log = models.ForeignKey(
        WorkflowTransitionLog,
        on_delete=models.CASCADE,
        related_name='notifications',
        null=True,
        blank=True
    )
    
    # Notification details
    notification_type = models.CharField(max_length=15, choices=NotificationType.choices)
    recipient = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='workflow_notifications'
    )
    
    # Content
    subject = models.CharField(max_length=255)
    message = models.TextField()
    
    # Status and delivery
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.PENDING)
    sent_at = models.DateTimeField(null=True, blank=True)
    delivery_attempts = models.IntegerField(default=0)
    
    # Metadata
    metadata = models.JSONField(
        default=dict,
        help_text='Additional notification metadata'
    )
    
    # Timestamps
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'workflow_notifications'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['workflow_instance', '-created_at']),
            models.Index(fields=['recipient', 'status']),
            models.Index(fields=['status', 'created_at']),
        ]
    
    def __str__(self):
        return f'{self.notification_type} to {self.recipient}: {self.subject}'