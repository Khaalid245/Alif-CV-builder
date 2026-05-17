"""
Tests for Version History API endpoints.
"""
import json
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.cv.models import CVProfile, Education
from apps.version_history.models import (
    CVVersion, VersionAction, VersionConfiguration
)
from apps.version_history.services import version_service

User = get_user_model()


class VersionHistoryAPITest(TestCase):
    """Test Version History API endpoints."""
    
    def setUp(self):
        """Set up test data."""
        self.client = APIClient()
        
        # Create test users
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123',
            first_name='Test',
            last_name='User'
        )
        
        self.other_user = User.objects.create_user(
            email='other@example.com',
            password='testpass123'
        )
        
        self.admin_user = User.objects.create_user(
            email='admin@example.com',
            password='testpass123',
            is_staff=True,
            is_superuser=True
        )
        
        # Create CV profiles
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            city='Test City'
        )
        
        self.other_cv_profile = CVProfile.objects.create(
            student=self.other_user,
            phone='0987654321',
            city='Other City'
        )
        
        # Create some versions
        self.version1 = version_service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user,
            change_summary='Initial version'
        )
        
        # Update CV and create second version
        self.cv_profile.phone = '5555555555'
        self.cv_profile.save()
        
        self.version2 = version_service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.UPDATE,
            changed_by=self.user,
            change_summary='Updated phone'
        )
    
    def get_jwt_token(self, user):
        """Get JWT token for user."""
        refresh = RefreshToken.for_user(user)
        return str(refresh.access_token)
    
    def authenticate(self, user):
        """Authenticate client with user."""
        token = self.get_jwt_token(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    
    def test_list_versions_authenticated(self):
        """Test listing versions for authenticated user."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('data', data)
        
        results = data['data']['results']
        self.assertEqual(len(results), 2)
        
        # Check ordering (newest first)
        self.assertEqual(results[0]['version_number'], 2)
        self.assertEqual(results[1]['version_number'], 1)
    
    def test_list_versions_unauthenticated(self):
        """Test listing versions without authentication."""
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_list_versions_no_cv_profile(self):
        """Test listing versions for user without CV profile."""
        user_no_cv = User.objects.create_user(
            email='nocv@example.com',
            password='testpass123'
        )
        self.authenticate(user_no_cv)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        self.assertEqual(len(results), 0)
    
    def test_retrieve_version(self):
        """Test retrieving a specific version."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-detail', kwargs={'pk': self.version1.id})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        self.assertTrue(data['success'])
        
        version_data = data['data']
        self.assertEqual(version_data['version_number'], 1)
        self.assertEqual(version_data['change_type'], 'create')
        self.assertIn('cv_data', version_data)
        
        # Check that access was logged
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.VIEW_VERSION,
            cv_profile=self.cv_profile,
            version=self.version1,
            user=self.user
        ).first()
        self.assertIsNotNone(action)
    
    def test_retrieve_other_user_version(self):
        """Test retrieving another user's version (should fail)."""
        other_version = version_service.create_version(
            cv_profile=self.other_cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.other_user
        )
        
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-detail', kwargs={'pk': other_version.id})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_restore_version(self):
        """Test restoring a version."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-restore', kwargs={'pk': self.version1.id})
        data = {
            'version_number': 1,
            'confirm': True
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        response_data = response.json()
        self.assertTrue(response_data['success'])
        self.assertIn('restored_version', response_data['data'])
        self.assertIn('new_version', response_data['data'])
        
        # Check that new version was created
        new_version_number = response_data['data']['new_version']
        new_version = CVVersion.objects.get(
            cv_profile=self.cv_profile,
            version_number=new_version_number
        )
        self.assertEqual(new_version.change_type, CVVersion.ChangeType.RESTORE)
        
        # Check that action was logged
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.RESTORE_VERSION,
            cv_profile=self.cv_profile,
            user=self.user
        ).first()
        self.assertIsNotNone(action)
    
    def test_restore_version_without_confirmation(self):
        """Test restoring version without confirmation."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-restore', kwargs={'pk': self.version1.id})
        data = {
            'version_number': 1,
            'confirm': False
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_compare_versions(self):
        """Test comparing versions."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-compare')
        data = {
            'from_version': 1,
            'to_version': 2
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        response_data = response.json()
        self.assertTrue(response_data['success'])
        
        comparison = response_data['data']
        self.assertIn('from_version', comparison)
        self.assertIn('to_version', comparison)
        self.assertIn('differences', comparison)
        self.assertIn('total_changes', comparison)
        
        # Check that action was logged
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.COMPARE_VERSIONS,
            cv_profile=self.cv_profile,
            user=self.user
        ).first()
        self.assertIsNotNone(action)
    
    def test_compare_same_version(self):
        """Test comparing version with itself (should fail)."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-compare')
        data = {
            'from_version': 1,
            'to_version': 1
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_400_BAD_REQUEST)
    
    def test_version_stats(self):
        """Test getting version statistics."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-stats')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        self.assertTrue(data['success'])
        
        stats = data['data']
        self.assertIn('total_versions', stats)
        self.assertIn('oldest_version', stats)
        self.assertIn('newest_version', stats)
        self.assertIn('total_size_mb', stats)
        self.assertIn('change_types', stats)
        self.assertIn('recent_activity', stats)
        
        self.assertEqual(stats['total_versions'], 2)
        self.assertEqual(stats['oldest_version'], 1)
        self.assertEqual(stats['newest_version'], 2)
    
    def test_list_version_actions(self):
        """Test listing version actions."""
        self.authenticate(self.user)
        
        # Create some actions
        version_service.log_version_access(
            action_type=VersionAction.ActionType.VIEW_HISTORY,
            cv_profile=self.cv_profile,
            user=self.user
        )
        
        url = reverse('version_history:version-actions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        self.assertTrue(data['success'])
        
        results = data['data']['results']
        self.assertGreater(len(results), 0)
    
    def test_admin_can_view_all_actions(self):
        """Test that admin can view all version actions."""
        # Create action for other user
        version_service.log_version_access(
            action_type=VersionAction.ActionType.VIEW_HISTORY,
            cv_profile=self.other_cv_profile,
            user=self.other_user
        )
        
        self.authenticate(self.admin_user)
        
        url = reverse('version_history:version-actions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        
        # Admin should see actions from all users
        user_emails = [action['user']['email'] for action in results if action['user']]
        self.assertIn(self.user.email, user_emails)
        self.assertIn(self.other_user.email, user_emails)
    
    def test_version_configuration_get(self):
        """Test getting version configuration."""
        self.authenticate(self.admin_user)
        
        url = reverse('version_history:version-config')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        self.assertTrue(data['success'])
        
        config = data['data']
        self.assertIn('max_versions_per_cv', config)
        self.assertIn('auto_cleanup_enabled', config)
    
    def test_version_configuration_update(self):
        """Test updating version configuration."""
        self.authenticate(self.admin_user)
        
        url = reverse('version_history:version-config')
        data = {
            'max_versions_per_cv': 25,
            'auto_cleanup_enabled': False
        }
        response = self.client.put(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        response_data = response.json()
        self.assertTrue(response_data['success'])
        
        config = response_data['data']
        self.assertEqual(config['max_versions_per_cv'], 25)
        self.assertFalse(config['auto_cleanup_enabled'])
    
    def test_non_admin_cannot_access_config(self):
        """Test that non-admin users cannot access configuration."""
        self.authenticate(self.user)
        
        url = reverse('version_history:version-config')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_filtering_versions(self):
        """Test filtering versions by change type."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url, {'change_type': 'create'})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        
        # Should only return create versions
        for result in results:
            self.assertEqual(result['change_type'], 'create')
    
    def test_ordering_versions(self):
        """Test ordering versions."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url, {'ordering': 'version_number'})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        
        # Should be ordered by version number (ascending)
        version_numbers = [r['version_number'] for r in results]
        self.assertEqual(version_numbers, sorted(version_numbers))
    
    def test_search_versions(self):
        """Test searching versions by change summary."""
        self.authenticate(self.user)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url, {'search': 'Initial'})
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        
        # Should only return versions with 'Initial' in summary
        for result in results:
            self.assertIn('Initial', result['change_summary'])


class VersionHistoryPermissionTest(TestCase):
    """Test Version History permissions."""
    
    def setUp(self):
        """Set up test data."""
        self.client = APIClient()
        
        self.user1 = User.objects.create_user(
            email='user1@example.com',
            password='testpass123'
        )
        
        self.user2 = User.objects.create_user(
            email='user2@example.com',
            password='testpass123'
        )
        
        self.cv1 = CVProfile.objects.create(student=self.user1)
        self.cv2 = CVProfile.objects.create(student=self.user2)
        
        self.version1 = version_service.create_version(
            cv_profile=self.cv1,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user1
        )
        
        self.version2 = version_service.create_version(
            cv_profile=self.cv2,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user2
        )
    
    def authenticate(self, user):
        """Authenticate client with user."""
        refresh = RefreshToken.for_user(user)
        token = str(refresh.access_token)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    
    def test_user_can_only_see_own_versions(self):
        """Test that users can only see their own versions."""
        self.authenticate(self.user1)
        
        url = reverse('version_history:cv-versions-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        data = response.json()
        results = data['data']['results']
        
        # Should only see own version
        self.assertEqual(len(results), 1)
        self.assertEqual(results[0]['id'], str(self.version1.id))
    
    def test_user_cannot_access_other_version(self):
        """Test that user cannot access another user's version."""
        self.authenticate(self.user1)
        
        url = reverse('version_history:cv-versions-detail', kwargs={'pk': self.version2.id})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_user_cannot_restore_other_version(self):
        """Test that user cannot restore another user's version."""
        self.authenticate(self.user1)
        
        url = reverse('version_history:cv-versions-restore', kwargs={'pk': self.version2.id})
        data = {'version_number': 1, 'confirm': True}
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)