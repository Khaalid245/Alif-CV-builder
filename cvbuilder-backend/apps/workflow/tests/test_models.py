"""
Comprehensive unit tests for workflow models.
Tests all model functionality, validation, and business logic.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import ValidationError
from django.db import IntegrityError
from apps.cv.models import CVProfile
from apps.workflow.models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance, WorkflowTransitionLog, WorkflowRule
)

User = get_user_model()


class WorkflowConfigurationModelTest(TestCase):
    """Test WorkflowConfiguration model functionality."""
    
    def setUp(self):
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
    
    def test_create_workflow_configuration(self):
        """Test creating a workflow configuration."""
        config = WorkflowConfiguration.objects.create(
            name='CV Review Workflow',
            description='Standard CV review process',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        self.assertEqual(config.name, 'CV Review Workflow')
        self.assertEqual(config.entity_type, 'cv.cvprofile')
        self.assertTrue(config.is_active)
        self.assertFalse(config.is_default)
        self.assertEqual(config.created_by, self.admin_user)
    
    def test_unique_name_constraint(self):
        """Test that workflow configuration names must be unique."""
        WorkflowConfiguration.objects.create(
            name='CV Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        with self.assertRaises(IntegrityError):
            WorkflowConfiguration.objects.create(
                name='CV Workflow',
                entity_type='cv.cvprofile',
                created_by=self.admin_user
            )
    
    def test_default_configuration_enforcement(self):
        """Test that only one default configuration per entity type is allowed."""
        config1 = WorkflowConfiguration.objects.create(
            name='CV Workflow 1',
            entity_type='cv.cvprofile',
            is_default=True,
            created_by=self.admin_user
        )
        
        config2 = WorkflowConfiguration.objects.create(
            name='CV Workflow 2',
            entity_type='cv.cvprofile',
            is_default=True,
            created_by=self.admin_user
        )
        
        # Refresh from database
        config1.refresh_from_db()
        config2.refresh_from_db()
        
        # Only the second one should be default
        self.assertFalse(config1.is_default)
        self.assertTrue(config2.is_default)
    
    def test_get_default_for_entity(self):
        """Test getting default workflow configuration for entity type."""
        config = WorkflowConfiguration.objects.create(
            name='Default CV Workflow',
            entity_type='cv.cvprofile',
            is_default=True,
            is_active=True,
            created_by=self.admin_user
        )
        
        default_config = WorkflowConfiguration.get_default_for_entity('cv.cvprofile')
        self.assertEqual(default_config, config)
        
        # Test with non-existent entity type
        no_config = WorkflowConfiguration.get_default_for_entity('nonexistent.model')
        self.assertIsNone(no_config)


class WorkflowStateModelTest(TestCase):
    """Test WorkflowState model functionality."""
    
    def setUp(self):
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='Test Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
    
    def test_create_workflow_state(self):
        """Test creating a workflow state."""
        state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            description='Initial draft state',
            state_type=WorkflowState.StateType.INITIAL,
            order=1
        )
        
        self.assertEqual(state.code, 'draft')
        self.assertEqual(state.name, 'Draft')
        self.assertEqual(state.state_type, WorkflowState.StateType.INITIAL)
        self.assertTrue(state.is_active)
        self.assertEqual(state.workflow_config, self.workflow_config)
    
    def test_unique_code_per_workflow(self):
        """Test that state codes must be unique within a workflow."""
        WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL
        )
        
        with self.assertRaises(IntegrityError):
            WorkflowState.objects.create(
                workflow_config=self.workflow_config,
                code='draft',
                name='Another Draft',
                state_type=WorkflowState.StateType.INTERMEDIATE
            )
    
    def test_state_ordering(self):
        """Test state ordering functionality."""
        state1 = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL,
            order=2
        )
        
        state2 = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='review',
            name='Under Review',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=1
        )
        
        states = list(WorkflowState.objects.filter(workflow_config=self.workflow_config))
        self.assertEqual(states[0], state2)  # Lower order comes first
        self.assertEqual(states[1], state1)


class WorkflowTransitionModelTest(TestCase):
    """Test WorkflowTransition model functionality."""
    
    def setUp(self):
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='Test Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        self.draft_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL
        )
        
        self.review_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='review',
            name='Under Review',
            state_type=WorkflowState.StateType.INTERMEDIATE
        )
    
    def test_create_workflow_transition(self):
        """Test creating a workflow transition."""
        transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state,
            allowed_roles=['student'],
            requires_comment=False
        )
        
        self.assertEqual(transition.name, 'Submit for Review')
        self.assertEqual(transition.from_state, self.draft_state)
        self.assertEqual(transition.to_state, self.review_state)
        self.assertEqual(transition.allowed_roles, ['student'])
        self.assertTrue(transition.is_active)
    
    def test_transition_validation(self):
        """Test transition model validation."""
        # Create transition with states from different workflows
        other_workflow = WorkflowConfiguration.objects.create(
            name='Other Workflow',
            entity_type='other.model',
            created_by=self.admin_user
        )
        
        other_state = WorkflowState.objects.create(
            workflow_config=other_workflow,
            code='other',
            name='Other State',
            state_type=WorkflowState.StateType.INITIAL
        )
        
        transition = WorkflowTransition(
            workflow_config=self.workflow_config,
            name='Invalid Transition',
            from_state=self.draft_state,
            to_state=other_state  # Different workflow
        )
        
        with self.assertRaises(ValidationError):
            transition.clean()
    
    def test_self_transition_validation(self):
        """Test that self-transitions are not allowed."""
        transition = WorkflowTransition(
            workflow_config=self.workflow_config,
            name='Self Transition',
            from_state=self.draft_state,
            to_state=self.draft_state  # Same state
        )
        
        with self.assertRaises(ValidationError):
            transition.clean()
    
    def test_unique_transition_constraint(self):
        """Test that transitions between same states must be unique."""
        WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state
        )
        
        with self.assertRaises(IntegrityError):
            WorkflowTransition.objects.create(
                workflow_config=self.workflow_config,
                name='Another Submit',
                from_state=self.draft_state,
                to_state=self.review_state
            )


class WorkflowInstanceModelTest(TestCase):
    """Test WorkflowInstance model functionality."""
    
    def setUp(self):
        self.student_user = User.objects.create_user(
            email='student@university.edu',
            password='student123',
            full_name='Student User',
            student_id='STU001',
            role=User.Role.STUDENT
        )
        
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
        
        self.cv = CVProfile.objects.create(student=self.student_user)
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        self.draft_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL
        )
    
    def test_create_workflow_instance(self):
        """Test creating a workflow instance."""
        content_type = ContentType.objects.get_for_model(CVProfile)
        
        instance = WorkflowInstance.objects.create(
            workflow_config=self.workflow_config,
            content_type=content_type,
            object_id=str(self.cv.id),
            current_state=self.draft_state,
            started_by=self.student_user
        )
        
        self.assertEqual(instance.workflow_config, self.workflow_config)
        self.assertEqual(instance.content_object, self.cv)
        self.assertEqual(instance.current_state, self.draft_state)
        self.assertEqual(instance.started_by, self.student_user)
    
    def test_unique_instance_per_entity(self):
        """Test that only one workflow instance per entity is allowed."""
        content_type = ContentType.objects.get_for_model(CVProfile)
        
        WorkflowInstance.objects.create(
            workflow_config=self.workflow_config,
            content_type=content_type,
            object_id=str(self.cv.id),
            current_state=self.draft_state,
            started_by=self.student_user
        )
        
        with self.assertRaises(IntegrityError):
            WorkflowInstance.objects.create(
                workflow_config=self.workflow_config,
                content_type=content_type,
                object_id=str(self.cv.id),
                current_state=self.draft_state,
                started_by=self.student_user
            )


class WorkflowTransitionLogModelTest(TestCase):
    """Test WorkflowTransitionLog model functionality."""
    
    def setUp(self):
        self.student_user = User.objects.create_user(
            email='student@university.edu',
            password='student123',
            full_name='Student User',
            student_id='STU001',
            role=User.Role.STUDENT
        )
        
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
        
        self.cv = CVProfile.objects.create(student=self.student_user)
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        self.draft_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL
        )
        
        self.review_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='review',
            name='Under Review',
            state_type=WorkflowState.StateType.INTERMEDIATE
        )
        
        self.transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state
        )
        
        content_type = ContentType.objects.get_for_model(CVProfile)
        self.instance = WorkflowInstance.objects.create(
            workflow_config=self.workflow_config,
            content_type=content_type,
            object_id=str(self.cv.id),
            current_state=self.draft_state,
            started_by=self.student_user
        )
    
    def test_create_transition_log(self):
        """Test creating a transition log entry."""
        log = WorkflowTransitionLog.objects.create(
            workflow_instance=self.instance,
            transition=self.transition,
            from_state=self.draft_state,
            to_state=self.review_state,
            performed_by=self.student_user,
            result=WorkflowTransitionLog.TransitionResult.SUCCESS,
            comment='Submitting CV for review'
        )
        
        self.assertEqual(log.workflow_instance, self.instance)
        self.assertEqual(log.transition, self.transition)
        self.assertEqual(log.from_state, self.draft_state)
        self.assertEqual(log.to_state, self.review_state)
        self.assertEqual(log.performed_by, self.student_user)
        self.assertEqual(log.result, WorkflowTransitionLog.TransitionResult.SUCCESS)
        self.assertEqual(log.comment, 'Submitting CV for review')


class WorkflowRuleModelTest(TestCase):
    """Test WorkflowRule model functionality."""
    
    def setUp(self):
        self.admin_user = User.objects.create_user(
            email='admin@university.edu',
            password='admin123',
            full_name='Admin User',
            role=User.Role.ADMIN
        )
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
    
    def test_create_workflow_rule(self):
        """Test creating a workflow rule."""
        rule = WorkflowRule.objects.create(
            workflow_config=self.workflow_config,
            name='CV Completion Check',
            description='Ensure CV is at least 70% complete',
            rule_type=WorkflowRule.RuleType.VALIDATION,
            field_path='completion_percentage',
            operator=WorkflowRule.Operator.GREATER_THAN,
            expected_value=70,
            error_message='CV must be at least 70% complete'
        )
        
        self.assertEqual(rule.name, 'CV Completion Check')
        self.assertEqual(rule.rule_type, WorkflowRule.RuleType.VALIDATION)
        self.assertEqual(rule.field_path, 'completion_percentage')
        self.assertEqual(rule.operator, WorkflowRule.Operator.GREATER_THAN)
        self.assertEqual(rule.expected_value, 70)
        self.assertTrue(rule.is_active)