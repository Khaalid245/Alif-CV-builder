"""
Comprehensive tests for workflow services.
Tests business logic, validation, and state transitions.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.contrib.contenttypes.models import ContentType
from django.core.exceptions import PermissionDenied
from apps.cv.models import CVProfile
from apps.workflow.models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance, WorkflowRule
)
from apps.workflow.services.workflow_service import WorkflowService, WorkflowRuleValidator
from apps.workflow.exceptions import (
    WorkflowNotFoundError, StateNotFoundError, InvalidTransitionError,
    ValidationRuleError
)

User = get_user_model()


class WorkflowServiceTest(TestCase):
    """Test WorkflowService functionality."""
    
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
        
        self.cv = CVProfile.objects.create(
            student=self.student_user,
            completion_percentage=75
        )
        
        # Create workflow configuration
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Review Workflow',
            entity_type='cv.cvprofile',
            is_default=True,
            created_by=self.admin_user
        )
        
        # Create states
        self.draft_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL,
            order=1
        )
        
        self.review_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='under_review',
            name='Under Review',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=2
        )
        
        self.revision_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='needs_revision',
            name='Needs Revision',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=3
        )
        
        self.approved_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='approved',
            name='Approved',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=4
        )
        
        self.published_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='published',
            name='Published',
            state_type=WorkflowState.StateType.FINAL,
            order=5
        )
        
        # Create transitions
        self.submit_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state,
            allowed_roles=['student'],
            requires_comment=False
        )
        
        self.approve_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Approve',
            from_state=self.review_state,
            to_state=self.approved_state,
            allowed_roles=['admin'],
            requires_comment=False
        )
        
        self.request_revision_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Request Revision',
            from_state=self.review_state,
            to_state=self.revision_state,
            allowed_roles=['admin'],
            requires_comment=True
        )
        
        self.resubmit_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Resubmit',
            from_state=self.revision_state,
            to_state=self.review_state,
            allowed_roles=['student'],
            requires_comment=False
        )
        
        self.publish_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Publish',
            from_state=self.approved_state,
            to_state=self.published_state,
            allowed_roles=['admin'],
            requires_comment=False
        )
        
        self.workflow_service = WorkflowService()
    
    def test_initialize_workflow(self):
        """Test workflow initialization."""
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        self.assertIsNotNone(instance)
        self.assertEqual(instance.workflow_config, self.workflow_config)
        self.assertEqual(instance.current_state, self.draft_state)
        self.assertEqual(instance.started_by, self.student_user)
        self.assertEqual(instance.content_object, self.cv)
    
    def test_initialize_workflow_no_config(self):
        """Test workflow initialization when no configuration exists."""
        # Remove default configuration
        self.workflow_config.is_default = False
        self.workflow_config.save()
        
        with self.assertRaises(WorkflowNotFoundError):
            self.workflow_service.initialize_workflow(
                entity=self.cv,
                user=self.student_user
            )
    
    def test_initialize_workflow_no_initial_state(self):
        """Test workflow initialization when no initial state exists."""
        # Change draft state type
        self.draft_state.state_type = WorkflowState.StateType.INTERMEDIATE
        self.draft_state.save()
        
        with self.assertRaises(StateNotFoundError):
            self.workflow_service.initialize_workflow(
                entity=self.cv,
                user=self.student_user
            )
    
    def test_valid_state_transition(self):
        """Test valid state transition."""
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Perform transition
        transition_log = self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Submitting for review'
        )
        
        # Verify transition
        instance.refresh_from_db()
        self.assertEqual(instance.current_state, self.review_state)
        self.assertEqual(transition_log.from_state, self.draft_state)
        self.assertEqual(transition_log.to_state, self.review_state)
        self.assertEqual(transition_log.performed_by, self.student_user)
        self.assertEqual(transition_log.comment, 'Submitting for review')
    
    def test_invalid_state_transition(self):
        """Test invalid state transition."""
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Try to transition directly to approved (not allowed from draft)
        with self.assertRaises(InvalidTransitionError):
            self.workflow_service.transition_state(
                instance=instance,
                to_state_code='approved',
                user=self.student_user
            )
    
    def test_transition_permission_denied(self):
        """Test transition with insufficient permissions."""
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Transition to review state first
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user
        )
        
        # Try to approve as student (should fail)
        with self.assertRaises(PermissionDenied):
            self.workflow_service.transition_state(
                instance=instance,
                to_state_code='approved',
                user=self.student_user
            )
    
    def test_transition_requires_comment(self):
        """Test transition that requires a comment."""
        # Initialize workflow and move to review state
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user
        )
        
        # Try to request revision without comment (should fail)
        with self.assertRaises(ValidationRuleError):
            self.workflow_service.transition_state(
                instance=instance,
                to_state_code='needs_revision',
                user=self.admin_user,
                comment=''
            )
        
        # Request revision with comment (should succeed)
        transition_log = self.workflow_service.transition_state(
            instance=instance,
            to_state_code='needs_revision',
            user=self.admin_user,
            comment='Please add more details to your experience section'
        )
        
        self.assertEqual(transition_log.comment, 'Please add more details to your experience section')
    
    def test_get_available_transitions(self):
        """Test getting available transitions for current state."""
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Get available transitions for student
        transitions = self.workflow_service.get_available_transitions(
            instance, self.student_user
        )
        
        self.assertEqual(len(transitions), 1)
        self.assertEqual(transitions[0]['name'], 'Submit for Review')
        self.assertEqual(transitions[0]['to_state']['code'], 'under_review')
        
        # Move to review state
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user
        )
        
        # Get available transitions for admin
        admin_transitions = self.workflow_service.get_available_transitions(
            instance, self.admin_user
        )
        
        self.assertEqual(len(admin_transitions), 2)
        transition_names = [t['name'] for t in admin_transitions]
        self.assertIn('Approve', transition_names)
        self.assertIn('Request Revision', transition_names)
        
        # Student should have no available transitions in review state
        student_transitions = self.workflow_service.get_available_transitions(
            instance, self.student_user
        )
        self.assertEqual(len(student_transitions), 0)
    
    def test_get_workflow_history(self):
        """Test getting workflow transition history."""
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Perform several transitions
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Initial submission'
        )
        
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='needs_revision',
            user=self.admin_user,
            comment='Needs more details'
        )
        
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Resubmitting with changes'
        )
        
        # Get history
        history = self.workflow_service.get_workflow_history(instance)
        
        self.assertEqual(len(history), 3)
        
        # Check most recent transition first
        self.assertEqual(history[0]['from_state']['code'], 'needs_revision')
        self.assertEqual(history[0]['to_state']['code'], 'under_review')
        self.assertEqual(history[0]['comment'], 'Resubmitting with changes')
        
        # Check second transition
        self.assertEqual(history[1]['from_state']['code'], 'under_review')
        self.assertEqual(history[1]['to_state']['code'], 'needs_revision')
        self.assertEqual(history[1]['comment'], 'Needs more details')
        
        # Check first transition
        self.assertEqual(history[2]['from_state']['code'], 'draft')
        self.assertEqual(history[2]['to_state']['code'], 'under_review')
        self.assertEqual(history[2]['comment'], 'Initial submission')


class WorkflowRuleValidatorTest(TestCase):
    """Test WorkflowRuleValidator functionality."""
    
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
        
        self.cv = CVProfile.objects.create(
            student=self.student_user,
            completion_percentage=75,
            phone='+1234567890',
            summary='Test summary'
        )
        
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Workflow',
            entity_type='cv.cvprofile',
            created_by=self.admin_user
        )
        
        self.validator = WorkflowRuleValidator()
    
    def test_validate_rule_equals(self):
        """Test equals operator validation."""
        rule_config = {
            'field_path': 'completion_percentage',
            'operator': 'eq',
            'expected_value': 75
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertTrue(result)
        
        # Test with different value
        rule_config['expected_value'] = 80
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertFalse(result)
    
    def test_validate_rule_greater_than(self):
        """Test greater than operator validation."""
        rule_config = {
            'field_path': 'completion_percentage',
            'operator': 'gt',
            'expected_value': 70
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertTrue(result)
        
        # Test with higher threshold
        rule_config['expected_value'] = 80
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertFalse(result)
    
    def test_validate_rule_contains(self):
        """Test contains operator validation."""
        rule_config = {
            'field_path': 'summary',
            'operator': 'contains',
            'expected_value': 'Test'
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertTrue(result)
        
        # Test with non-existent substring
        rule_config['expected_value'] = 'NonExistent'
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertFalse(result)
    
    def test_validate_rule_exists(self):
        """Test exists operator validation."""
        rule_config = {
            'field_path': 'phone',
            'operator': 'exists',
            'expected_value': None
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertTrue(result)
        
        # Test with non-existent field value
        self.cv.phone = ''
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertFalse(result)
    
    def test_validate_rule_nested_field_path(self):
        """Test validation with nested field paths."""
        rule_config = {
            'field_path': 'student.role',
            'operator': 'eq',
            'expected_value': 'student'
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertTrue(result)
    
    def test_validate_rule_invalid_field_path(self):
        """Test validation with invalid field path."""
        rule_config = {
            'field_path': 'nonexistent.field',
            'operator': 'eq',
            'expected_value': 'value'
        }
        
        result = self.validator.validate_rule(self.cv, rule_config)
        self.assertFalse(result)  # Should return False for invalid paths
    
    def test_validate_workflow_rule_model(self):
        """Test validation using WorkflowRule model."""
        rule = WorkflowRule.objects.create(
            workflow_config=self.workflow_config,
            name='Completion Check',
            rule_type=WorkflowRule.RuleType.VALIDATION,
            field_path='completion_percentage',
            operator=WorkflowRule.Operator.GREATER_THAN,
            expected_value=70,
            error_message='CV must be at least 70% complete'
        )
        
        result = self.validator.validate_workflow_rule(self.cv, rule)
        self.assertTrue(result)
        
        # Test with CV that doesn't meet the rule
        self.cv.completion_percentage = 60
        result = self.validator.validate_workflow_rule(self.cv, rule)
        self.assertFalse(result)


class WorkflowIntegrationTest(TestCase):
    """Integration tests for complete workflow scenarios."""
    
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
        
        self.cv = CVProfile.objects.create(
            student=self.student_user,
            completion_percentage=80
        )
        
        # Create complete workflow configuration
        self.workflow_config = WorkflowConfiguration.objects.create(
            name='CV Review Workflow',
            entity_type='cv.cvprofile',
            is_default=True,
            created_by=self.admin_user
        )
        
        # Create states
        self.draft_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='draft',
            name='Draft',
            state_type=WorkflowState.StateType.INITIAL
        )
        
        self.review_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='under_review',
            name='Under Review',
            state_type=WorkflowState.StateType.INTERMEDIATE
        )
        
        self.approved_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='approved',
            name='Approved',
            state_type=WorkflowState.StateType.INTERMEDIATE
        )
        
        self.published_state = WorkflowState.objects.create(
            workflow_config=self.workflow_config,
            code='published',
            name='Published',
            state_type=WorkflowState.StateType.FINAL
        )
        
        # Create transitions with validation rules
        self.submit_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state,
            allowed_roles=['student'],
            validation_rules=[
                {
                    'field_path': 'completion_percentage',
                    'operator': 'gte',
                    'expected_value': 70,
                    'error_message': 'CV must be at least 70% complete to submit'
                }
            ]
        )
        
        self.approve_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Approve',
            from_state=self.review_state,
            to_state=self.approved_state,
            allowed_roles=['admin']
        )
        
        self.publish_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Publish',
            from_state=self.approved_state,
            to_state=self.published_state,
            allowed_roles=['admin']
        )
        
        self.workflow_service = WorkflowService()
    
    def test_complete_workflow_scenario(self):
        """Test a complete workflow from draft to published."""
        # 1. Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        self.assertEqual(instance.current_state.code, 'draft')
        
        # 2. Student submits for review
        transition_log = self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Ready for review'
        )
        
        instance.refresh_from_db()
        self.assertEqual(instance.current_state.code, 'under_review')
        self.assertEqual(transition_log.result, 'success')
        
        # 3. Admin approves
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='approved',
            user=self.admin_user,
            comment='CV looks good'
        )
        
        instance.refresh_from_db()
        self.assertEqual(instance.current_state.code, 'approved')
        
        # 4. Admin publishes
        self.workflow_service.transition_state(
            instance=instance,
            to_state_code='published',
            user=self.admin_user,
            comment='Publishing CV'
        )
        
        instance.refresh_from_db()
        self.assertEqual(instance.current_state.code, 'published')
        
        # 5. Verify complete history
        history = self.workflow_service.get_workflow_history(instance)
        self.assertEqual(len(history), 3)
        
        # Check final state
        self.assertEqual(instance.current_state.state_type, WorkflowState.StateType.FINAL)
    
    def test_validation_rule_enforcement(self):
        """Test that validation rules are properly enforced."""
        # Set CV completion below threshold
        self.cv.completion_percentage = 60
        self.cv.save()
        
        # Initialize workflow
        instance = self.workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        
        # Try to submit with insufficient completion (should fail)
        with self.assertRaises(ValidationRuleError) as context:
            self.workflow_service.transition_state(
                instance=instance,
                to_state_code='under_review',
                user=self.student_user
            )
        
        self.assertIn('70% complete', str(context.exception))
        
        # Increase completion and try again (should succeed)
        self.cv.completion_percentage = 80
        self.cv.save()
        
        transition_log = self.workflow_service.transition_state(
            instance=instance,
            to_state_code='under_review',
            user=self.student_user
        )
        
        self.assertEqual(transition_log.result, 'success')