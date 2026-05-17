"""
Comprehensive API tests for workflow endpoints.
Tests all REST API functionality with proper authentication and permissions.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.contrib.contenttypes.models import ContentType
from rest_framework.test import APITestCase
from rest_framework import status
from apps.cv.models import CVProfile
from apps.workflow.models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance
)
from apps.workflow.services.workflow_service import WorkflowService

User = get_user_model()


class WorkflowAPITestCase(APITestCase):
    """Base test case for workflow API tests."""
    
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
        
        self.other_student = User.objects.create_user(
            email='other@university.edu',
            password='other123',
            full_name='Other Student',
            student_id='STU002',
            role=User.Role.STUDENT
        )
        
        self.cv = CVProfile.objects.create(
            student=self.student_user,
            completion_percentage=80
        )
        
        self.other_cv = CVProfile.objects.create(
            student=self.other_student,
            completion_percentage=70
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
        
        # Create transitions
        self.submit_transition = WorkflowTransition.objects.create(
            workflow_config=self.workflow_config,
            name='Submit for Review',
            from_state=self.draft_state,
            to_state=self.review_state,
            allowed_roles=['student']
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


class CVWorkflowAPITest(WorkflowAPITestCase):
    """Test CV workflow API endpoints."""
    
    def test_get_cv_workflow_unauthenticated(self):
        """Test accessing CV workflow without authentication."""
        response = self.client.get(f'/api/v1/workflow/cv/{self.cv.id}/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_get_cv_workflow_as_owner(self):
        """Test getting CV workflow as the owner."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get(f'/api/v1/workflow/cv/{self.cv.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertIn('instance', data)
        self.assertIn('available_transitions', data)
        self.assertIn('permissions', data)
        
        # Check that workflow was initialized
        instance_data = data['instance']
        self.assertEqual(instance_data['current_state']['code'], 'draft')
    
    def test_get_cv_workflow_as_other_student(self):
        """Test accessing another student's CV workflow."""
        self.client.force_authenticate(user=self.other_student)
        
        response = self.client.get(f'/api/v1/workflow/cv/{self.cv.id}/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_get_cv_workflow_as_admin(self):
        """Test getting CV workflow as admin."""
        self.client.force_authenticate(user=self.admin_user)
        
        response = self.client.get(f'/api/v1/workflow/cv/{self.cv.id}/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertIn('instance', data)
        self.assertIn('available_transitions', data)
        self.assertIn('permissions', data)
    
    def test_get_nonexistent_cv_workflow(self):
        """Test getting workflow for non-existent CV."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get('/api/v1/workflow/cv/00000000-0000-0000-0000-000000000000/')
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_initialize_cv_workflow(self):
        """Test initializing CV workflow via POST."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.post(f'/api/v1/workflow/cv/{self.cv.id}/', {})
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        data = response.data['data']
        self.assertEqual(data['current_state']['code'], 'draft')
        self.assertEqual(data['started_by'], str(self.student_user))


class WorkflowTransitionAPITest(WorkflowAPITestCase):
    """Test workflow transition API endpoints."""
    
    def setUp(self):
        super().setUp()
        # Initialize workflow instance
        workflow_service = WorkflowService()
        self.instance = workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
    
    def test_transition_unauthenticated(self):
        """Test performing transition without authentication."""
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'under_review'}
        )
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_valid_transition_as_owner(self):
        """Test valid transition as CV owner."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {
                'to_state': 'under_review',
                'comment': 'Submitting for review'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(data['from_state']['code'], 'draft')
        self.assertEqual(data['to_state']['code'], 'under_review')
        self.assertEqual(data['comment'], 'Submitting for review')
        
        # Verify instance state changed
        self.instance.refresh_from_db()
        self.assertEqual(self.instance.current_state.code, 'under_review')
    
    def test_invalid_transition(self):
        """Test invalid transition attempt."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'approved'}  # Can't go directly from draft to approved
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        self.assertIn('No valid transition', response.data['message'])
    
    def test_transition_permission_denied(self):
        """Test transition with insufficient permissions."""
        # First, move to review state as student
        self.client.force_authenticate(user=self.student_user)
        self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'under_review'}
        )
        
        # Try to approve as student (should fail)
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'approved'}
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_transition_as_admin(self):
        """Test admin performing transitions."""
        # Move to review state first
        self.client.force_authenticate(user=self.student_user)
        self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'under_review'}
        )
        
        # Admin approves
        self.client.force_authenticate(user=self.admin_user)
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {
                'to_state': 'approved',
                'comment': 'CV approved'
            }
        )
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(data['to_state']['code'], 'approved')
        self.assertEqual(data['performed_by'], str(self.admin_user))
    
    def test_transition_other_student_cv(self):
        """Test student trying to transition another student's CV."""
        self.client.force_authenticate(user=self.other_student)
        
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': 'under_review'}
        )
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_transition_invalid_request_data(self):
        """Test transition with invalid request data."""
        self.client.force_authenticate(user=self.student_user)
        
        # Missing to_state
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'comment': 'Test comment'}
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
        
        # Empty to_state
        response = self.client.post(
            f'/api/v1/workflow/instances/{self.instance.id}/transition/',
            {'to_state': ''}
        )
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_transition_nonexistent_instance(self):
        """Test transition on non-existent workflow instance."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.post(
            '/api/v1/workflow/instances/00000000-0000-0000-0000-000000000000/transition/',
            {'to_state': 'under_review'}
        )
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)


class WorkflowInstanceAPITest(WorkflowAPITestCase):
    """Test workflow instance API endpoints."""
    
    def setUp(self):
        super().setUp()
        # Initialize workflow instances
        workflow_service = WorkflowService()
        self.instance = workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        self.other_instance = workflow_service.initialize_workflow(
            entity=self.other_cv,
            user=self.other_student
        )
    
    def test_list_workflow_instances_as_student(self):
        """Test listing workflow instances as student."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get('/api/v1/workflow/instances/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['results']
        self.assertEqual(len(data), 1)  # Should only see own CV workflow
        self.assertEqual(data[0]['id'], str(self.instance.id))
    
    def test_list_workflow_instances_as_admin(self):
        """Test listing workflow instances as admin."""
        self.client.force_authenticate(user=self.admin_user)
        
        response = self.client.get('/api/v1/workflow/instances/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['results']
        self.assertEqual(len(data), 2)  # Should see all workflow instances
    
    def test_get_workflow_instance_status(self):
        """Test getting detailed workflow instance status."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get(f'/api/v1/workflow/instances/{self.instance.id}/status/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(data['instance_id'], str(self.instance.id))
        self.assertEqual(data['current_state']['code'], 'draft')
        self.assertIn('available_transitions', data)
        self.assertIn('permissions', data)
        
        # Check available transitions
        transitions = data['available_transitions']
        self.assertEqual(len(transitions), 1)
        self.assertEqual(transitions[0]['name'], 'Submit for Review')
    
    def test_get_workflow_instance_history(self):
        """Test getting workflow instance history."""
        self.client.force_authenticate(user=self.student_user)
        
        # Perform a transition first
        workflow_service = WorkflowService()
        workflow_service.transition_state(
            instance=self.instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Initial submission'
        )
        
        response = self.client.get(f'/api/v1/workflow/instances/{self.instance.id}/history/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(len(data), 1)
        
        history_entry = data[0]
        self.assertEqual(history_entry['from_state']['code'], 'draft')
        self.assertEqual(history_entry['to_state']['code'], 'under_review')
        self.assertEqual(history_entry['comment'], 'Initial submission')
        self.assertEqual(history_entry['performed_by']['email'], self.student_user.email)
    
    def test_get_available_transitions(self):
        """Test getting available transitions for current state."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get(f'/api/v1/workflow/instances/{self.instance.id}/available_transitions/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(len(data), 1)
        
        transition = data[0]
        self.assertEqual(transition['name'], 'Submit for Review')
        self.assertEqual(transition['to_state']['code'], 'under_review')
        self.assertFalse(transition['requires_comment'])
        self.assertTrue(transition['validation_passed'])


class WorkflowDashboardAPITest(WorkflowAPITestCase):
    """Test workflow dashboard API endpoints."""
    
    def setUp(self):
        super().setUp()
        # Initialize workflow instances
        workflow_service = WorkflowService()
        self.instance = workflow_service.initialize_workflow(
            entity=self.cv,
            user=self.student_user
        )
        self.other_instance = workflow_service.initialize_workflow(
            entity=self.other_cv,
            user=self.other_student
        )
        
        # Perform some transitions for history
        workflow_service.transition_state(
            instance=self.instance,
            to_state_code='under_review',
            user=self.student_user,
            comment='Student submission'
        )
        
        workflow_service.transition_state(
            instance=self.instance,
            to_state_code='approved',
            user=self.admin_user,
            comment='Admin approval'
        )
    
    def test_dashboard_as_student(self):
        """Test dashboard data for student user."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get('/api/v1/workflow/dashboard/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(data['total_workflows'], 1)  # Only own CV
        self.assertEqual(data['active_workflows'], 1)
        self.assertIn('recent_transitions', data)
        self.assertIn('workflow_states_summary', data)
        
        # Check recent transitions
        recent_transitions = data['recent_transitions']
        self.assertGreaterEqual(len(recent_transitions), 1)
        
        # Check state summary
        state_summary = data['workflow_states_summary']
        self.assertIn('Approved', state_summary)
    
    def test_dashboard_as_admin(self):
        """Test dashboard data for admin user."""
        self.client.force_authenticate(user=self.admin_user)
        
        response = self.client.get('/api/v1/workflow/dashboard/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['data']
        self.assertEqual(data['total_workflows'], 2)  # All workflows
        self.assertEqual(data['active_workflows'], 2)
        self.assertIn('recent_transitions', data)
        self.assertIn('workflow_states_summary', data)
        
        # Admin should see more transitions
        recent_transitions = data['recent_transitions']
        self.assertGreaterEqual(len(recent_transitions), 2)
    
    def test_dashboard_unauthenticated(self):
        """Test dashboard access without authentication."""
        response = self.client.get('/api/v1/workflow/dashboard/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class WorkflowConfigurationAPITest(WorkflowAPITestCase):
    """Test workflow configuration management API endpoints."""
    
    def test_list_configurations_as_admin(self):
        """Test listing workflow configurations as admin."""
        self.client.force_authenticate(user=self.admin_user)
        
        response = self.client.get('/api/v1/workflow/configurations/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.data['results']
        self.assertEqual(len(data), 1)
        self.assertEqual(data[0]['name'], 'CV Review Workflow')
    
    def test_list_configurations_as_student(self):
        """Test that students cannot access configuration endpoints."""
        self.client.force_authenticate(user=self.student_user)
        
        response = self.client.get('/api/v1/workflow/configurations/')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_create_configuration_as_admin(self):
        """Test creating workflow configuration as admin."""
        self.client.force_authenticate(user=self.admin_user)
        
        config_data = {
            'name': 'New Workflow',
            'description': 'A new workflow configuration',
            'entity_type': 'test.model',
            'is_active': True,
            'is_default': False,
            'configuration': {}
        }
        
        response = self.client.post('/api/v1/workflow/configurations/', config_data)
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        
        data = response.data
        self.assertEqual(data['name'], 'New Workflow')
        self.assertEqual(data['created_by'], str(self.admin_user))
    
    def test_activate_configuration(self):
        """Test activating workflow configuration."""
        self.client.force_authenticate(user=self.admin_user)
        
        # Deactivate first
        self.workflow_config.is_active = False
        self.workflow_config.save()
        
        response = self.client.post(f'/api/v1/workflow/configurations/{self.workflow_config.id}/activate/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify activation
        self.workflow_config.refresh_from_db()
        self.assertTrue(self.workflow_config.is_active)
    
    def test_deactivate_configuration(self):
        """Test deactivating workflow configuration."""
        self.client.force_authenticate(user=self.admin_user)
        
        response = self.client.post(f'/api/v1/workflow/configurations/{self.workflow_config.id}/deactivate/')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify deactivation
        self.workflow_config.refresh_from_db()
        self.assertFalse(self.workflow_config.is_active)