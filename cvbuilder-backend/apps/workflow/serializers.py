"""
Enterprise-grade serializers for workflow API endpoints.
Provides comprehensive data serialization with validation and security.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model
from .models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance, WorkflowTransitionLog, WorkflowRule,
    WorkflowNotification
)

User = get_user_model()


class WorkflowStateSerializer(serializers.ModelSerializer):
    """Serializer for workflow states."""
    
    class Meta:
        model = WorkflowState
        fields = [
            'id', 'code', 'name', 'description', 'state_type',
            'is_active', 'order', 'properties', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class WorkflowTransitionSerializer(serializers.ModelSerializer):
    """Serializer for workflow transitions."""
    
    from_state = WorkflowStateSerializer(read_only=True)
    to_state = WorkflowStateSerializer(read_only=True)
    
    class Meta:
        model = WorkflowTransition
        fields = [
            'id', 'name', 'description', 'from_state', 'to_state',
            'allowed_roles', 'validation_rules', 'is_active',
            'requires_comment', 'auto_transition', 'properties',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class WorkflowConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for workflow configurations."""
    
    states = WorkflowStateSerializer(many=True, read_only=True)
    transitions = WorkflowTransitionSerializer(many=True, read_only=True)
    created_by = serializers.StringRelatedField(read_only=True)
    
    class Meta:
        model = WorkflowConfiguration
        fields = [
            'id', 'name', 'description', 'entity_type', 'is_active',
            'is_default', 'configuration', 'states', 'transitions',
            'created_by', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_by', 'created_at', 'updated_at']
    
    def validate(self, attrs):
        """Validate workflow configuration."""
        # Ensure entity_type is valid
        entity_type = attrs.get('entity_type')
        if entity_type and not self._is_valid_entity_type(entity_type):
            raise serializers.ValidationError({
                'entity_type': 'Invalid entity type format. Use app_label.model_name'
            })
        
        return attrs
    
    def _is_valid_entity_type(self, entity_type):
        """Validate entity type format."""
        parts = entity_type.split('.')
        return len(parts) == 2 and all(part.isidentifier() for part in parts)


class WorkflowInstanceSerializer(serializers.ModelSerializer):
    """Serializer for workflow instances."""
    
    workflow_config = WorkflowConfigurationSerializer(read_only=True)
    current_state = WorkflowStateSerializer(read_only=True)
    started_by = serializers.StringRelatedField(read_only=True)
    content_object_type = serializers.CharField(source='content_type.model', read_only=True)
    
    class Meta:
        model = WorkflowInstance
        fields = [
            'id', 'workflow_config', 'current_state', 'content_object_type',
            'object_id', 'started_by', 'started_at', 'updated_at', 'properties'
        ]
        read_only_fields = [
            'id', 'workflow_config', 'current_state', 'content_object_type',
            'object_id', 'started_by', 'started_at', 'updated_at'
        ]


class WorkflowTransitionLogSerializer(serializers.ModelSerializer):
    """Serializer for workflow transition logs."""
    
    from_state = WorkflowStateSerializer(read_only=True)
    to_state = WorkflowStateSerializer(read_only=True)
    transition = WorkflowTransitionSerializer(read_only=True)
    performed_by = serializers.StringRelatedField(read_only=True)
    
    class Meta:
        model = WorkflowTransitionLog
        fields = [
            'id', 'from_state', 'to_state', 'transition', 'performed_by',
            'performed_at', 'result', 'comment', 'metadata'
        ]
        read_only_fields = ['id', 'performed_at']


class WorkflowRuleSerializer(serializers.ModelSerializer):
    """Serializer for workflow rules."""
    
    class Meta:
        model = WorkflowRule
        fields = [
            'id', 'name', 'description', 'rule_type', 'field_path',
            'operator', 'expected_value', 'is_active', 'error_message',
            'properties', 'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']
    
    def validate_field_path(self, value):
        """Validate field path format."""
        if not value or not isinstance(value, str):
            raise serializers.ValidationError("Field path must be a non-empty string")
        
        # Basic validation for dot notation
        parts = value.split('.')
        if not all(part.isidentifier() for part in parts):
            raise serializers.ValidationError(
                "Field path must use valid dot notation (e.g., 'cv.completion_percentage')"
            )
        
        return value


class WorkflowNotificationSerializer(serializers.ModelSerializer):
    """Serializer for workflow notifications."""
    
    recipient = serializers.StringRelatedField(read_only=True)
    
    class Meta:
        model = WorkflowNotification
        fields = [
            'id', 'notification_type', 'recipient', 'subject', 'message',
            'status', 'sent_at', 'delivery_attempts', 'metadata',
            'created_at', 'updated_at'
        ]
        read_only_fields = [
            'id', 'recipient', 'status', 'sent_at', 'delivery_attempts',
            'created_at', 'updated_at'
        ]


# Action Serializers for API Operations

class WorkflowTransitionRequestSerializer(serializers.Serializer):
    """Serializer for workflow transition requests."""
    
    to_state = serializers.CharField(
        max_length=50,
        help_text='Target state code'
    )
    comment = serializers.CharField(
        required=False,
        allow_blank=True,
        max_length=1000,
        help_text='Optional comment for the transition'
    )
    additional_data = serializers.JSONField(
        required=False,
        help_text='Additional metadata for the transition'
    )
    
    def validate_to_state(self, value):
        """Validate target state code."""
        if not value or not value.strip():
            raise serializers.ValidationError("Target state code is required")
        return value.strip()


class WorkflowInitializationSerializer(serializers.Serializer):
    """Serializer for workflow initialization requests."""
    
    workflow_config_id = serializers.UUIDField(
        required=False,
        help_text='Optional specific workflow configuration ID'
    )
    initial_properties = serializers.JSONField(
        required=False,
        help_text='Initial properties for the workflow instance'
    )


class AvailableTransitionSerializer(serializers.Serializer):
    """Serializer for available transitions response."""
    
    id = serializers.UUIDField(read_only=True)
    name = serializers.CharField(read_only=True)
    description = serializers.CharField(read_only=True)
    to_state = serializers.DictField(read_only=True)
    requires_comment = serializers.BooleanField(read_only=True)
    validation_passed = serializers.BooleanField(read_only=True)
    validation_errors = serializers.ListField(read_only=True)
    properties = serializers.JSONField(read_only=True)


class WorkflowHistorySerializer(serializers.Serializer):
    """Serializer for workflow history response."""
    
    id = serializers.UUIDField(read_only=True)
    from_state = serializers.DictField(read_only=True)
    to_state = serializers.DictField(read_only=True)
    transition_name = serializers.CharField(read_only=True)
    performed_by = serializers.DictField(read_only=True)
    performed_at = serializers.DateTimeField(read_only=True)
    result = serializers.CharField(read_only=True)
    comment = serializers.CharField(read_only=True)
    metadata = serializers.JSONField(read_only=True)


class WorkflowStatusSerializer(serializers.Serializer):
    """Serializer for workflow status response."""
    
    instance_id = serializers.UUIDField(read_only=True)
    workflow_name = serializers.CharField(read_only=True)
    current_state = serializers.DictField(read_only=True)
    started_at = serializers.DateTimeField(read_only=True)
    updated_at = serializers.DateTimeField(read_only=True)
    properties = serializers.JSONField(read_only=True)
    permissions = serializers.DictField(read_only=True)
    available_transitions = AvailableTransitionSerializer(many=True, read_only=True)


class WorkflowDashboardSerializer(serializers.Serializer):
    """Serializer for workflow dashboard data."""
    
    total_workflows = serializers.IntegerField(read_only=True)
    active_workflows = serializers.IntegerField(read_only=True)
    pending_reviews = serializers.IntegerField(read_only=True)
    completed_workflows = serializers.IntegerField(read_only=True)
    recent_transitions = WorkflowHistorySerializer(many=True, read_only=True)
    workflow_states_summary = serializers.DictField(read_only=True)


# Admin Serializers

class WorkflowConfigurationCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating workflow configurations."""
    
    class Meta:
        model = WorkflowConfiguration
        fields = [
            'name', 'description', 'entity_type', 'is_active',
            'is_default', 'configuration'
        ]
    
    def create(self, validated_data):
        """Create workflow configuration with current user."""
        validated_data['created_by'] = self.context['request'].user
        return super().create(validated_data)


class WorkflowStateCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating workflow states."""
    
    class Meta:
        model = WorkflowState
        fields = [
            'workflow_config', 'code', 'name', 'description',
            'state_type', 'is_active', 'order', 'properties'
        ]
    
    def validate(self, attrs):
        """Validate state creation."""
        workflow_config = attrs.get('workflow_config')
        code = attrs.get('code')
        
        # Check for duplicate state codes within the same workflow
        if WorkflowState.objects.filter(
            workflow_config=workflow_config,
            code=code
        ).exists():
            raise serializers.ValidationError({
                'code': f"State with code '{code}' already exists in this workflow"
            })
        
        return attrs


class WorkflowTransitionCreateSerializer(serializers.ModelSerializer):
    """Serializer for creating workflow transitions."""
    
    class Meta:
        model = WorkflowTransition
        fields = [
            'workflow_config', 'name', 'description', 'from_state',
            'to_state', 'allowed_roles', 'validation_rules',
            'is_active', 'requires_comment', 'auto_transition', 'properties'
        ]
    
    def validate(self, attrs):
        """Validate transition creation."""
        workflow_config = attrs.get('workflow_config')
        from_state = attrs.get('from_state')
        to_state = attrs.get('to_state')
        
        # Validate states belong to the same workflow
        if from_state.workflow_config != workflow_config:
            raise serializers.ValidationError({
                'from_state': 'From state must belong to the specified workflow'
            })
        
        if to_state.workflow_config != workflow_config:
            raise serializers.ValidationError({
                'to_state': 'To state must belong to the specified workflow'
            })
        
        # Check for duplicate transitions
        if WorkflowTransition.objects.filter(
            workflow_config=workflow_config,
            from_state=from_state,
            to_state=to_state
        ).exists():
            raise serializers.ValidationError(
                "Transition between these states already exists"
            )
        
        return attrs