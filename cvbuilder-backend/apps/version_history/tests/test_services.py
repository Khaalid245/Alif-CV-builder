"""
Tests for Version History services.
"""
from django.test import TestCase
from django.contrib.auth import get_user_model
from unittest.mock import patch, MagicMock

from apps.cv.models import CVProfile, Education
from apps.version_history.models import (
    CVVersion, VersionDiff, VersionAction, VersionConfiguration
)
from apps.version_history.services import VersionHistoryService, version_service

User = get_user_model()


class VersionHistoryServiceTest(TestCase):
    """Test VersionHistoryService."""
    
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123',
            first_name='Test',
            last_name='User'
        )
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            city='Test City',
            summary='Test summary'
        )
        self.service = VersionHistoryService()
    
    def test_get_configuration(self):
        """Test getting configuration."""
        config = self.service._get_configuration()
        
        self.assertIsInstance(config, VersionConfiguration)
        self.assertEqual(config.max_versions_per_cv, 50)
        self.assertTrue(config.auto_cleanup_enabled)
    
    def test_create_version(self):
        """Test creating a version."""
        version = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user,
            change_summary='Test version',
            ip_address='192.168.1.1',
            fields_changed=['phone', 'city']
        )
        
        self.assertEqual(version.version_number, 1)
        self.assertEqual(version.change_type, CVVersion.ChangeType.CREATE)
        self.assertEqual(version.change_summary, 'Test version')
        self.assertEqual(version.changed_by, self.user)
        self.assertEqual(version.ip_address, '192.168.1.1')
        self.assertEqual(version.fields_changed, ['phone', 'city'])
        self.assertIsNotNone(version.cv_data)
    
    def test_create_multiple_versions(self):
        """Test creating multiple versions."""
        # Create first version
        version1 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        # Update CV
        self.cv_profile.phone = '9876543210'
        self.cv_profile.save()
        
        # Create second version
        version2 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.UPDATE,
            changed_by=self.user
        )
        
        self.assertEqual(version1.version_number, 1)
        self.assertEqual(version2.version_number, 2)
        self.assertEqual(version2.previous_version, version1)
        
        # Check that diff was created
        diffs = VersionDiff.objects.filter(
            from_version=version1,
            to_version=version2
        )
        self.assertTrue(diffs.exists())
    
    def test_serialize_cv_data(self):
        """Test CV data serialization."""
        # Add some education data
        Education.objects.create(
            cv=self.cv_profile,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='Test University',
            start_year=2020,
            end_year=2024
        )
        
        cv_data = self.service._serialize_cv_data(self.cv_profile)
        
        self.assertIn('phone', cv_data)
        self.assertIn('city', cv_data)
        self.assertIn('summary', cv_data)
        self.assertIn('educations', cv_data)
        self.assertEqual(cv_data['phone'], '1234567890')
        self.assertEqual(cv_data['city'], 'Test City')
        self.assertEqual(len(cv_data['educations']), 1)
    
    def test_compute_differences(self):
        """Test computing differences between versions."""
        old_data = {
            'phone': '123',
            'city': 'Old City',
            'educations': [{'degree': 'Old Degree'}]
        }
        
        new_data = {
            'phone': '456',
            'city': 'New City',
            'educations': [{'degree': 'New Degree'}]
        }
        
        diffs = self.service._compute_differences(old_data, new_data)
        
        # Should detect changes in phone, city, and educations
        self.assertTrue(len(diffs) >= 2)
        
        # Check specific diffs
        phone_diff = next((d for d in diffs if d['field_path'] == 'phone'), None)
        self.assertIsNotNone(phone_diff)
        self.assertEqual(phone_diff['old_value'], '123')
        self.assertEqual(phone_diff['new_value'], '456')
    
    def test_cleanup_old_versions(self):
        """Test cleanup of old versions."""
        # Set max versions to 3
        self.service.config.max_versions_per_cv = 3
        self.service.config.save()
        
        # Create 5 versions
        versions = []
        for i in range(5):
            version = self.service.create_version(
                cv_profile=self.cv_profile,
                change_type=CVVersion.ChangeType.UPDATE,
                changed_by=self.user,
                change_summary=f'Version {i+1}'
            )
            versions.append(version)
        
        # Should only have 3 versions left
        remaining_versions = CVVersion.objects.filter(cv_profile=self.cv_profile)
        self.assertEqual(remaining_versions.count(), 3)
        
        # Should keep the latest 3 versions
        version_numbers = list(remaining_versions.values_list('version_number', flat=True))
        self.assertEqual(sorted(version_numbers), [3, 4, 5])
    
    def test_get_version_history(self):
        """Test getting version history."""
        # Create multiple versions
        for i in range(3):
            self.service.create_version(
                cv_profile=self.cv_profile,
                change_type=CVVersion.ChangeType.UPDATE,
                changed_by=self.user
            )
        
        history = self.service.get_version_history(self.cv_profile)
        
        self.assertEqual(len(history), 3)
        # Should be ordered by version number (newest first)
        self.assertEqual(history[0].version_number, 3)
        self.assertEqual(history[1].version_number, 2)
        self.assertEqual(history[2].version_number, 1)
    
    def test_get_version_by_number(self):
        """Test getting version by number."""
        version = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        retrieved = self.service.get_version_by_number(self.cv_profile, 1)
        self.assertEqual(retrieved, version)
        
        # Test non-existent version
        not_found = self.service.get_version_by_number(self.cv_profile, 999)
        self.assertIsNone(not_found)
    
    def test_compare_versions(self):
        """Test comparing versions."""
        # Create first version
        version1 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        # Update CV and create second version
        self.cv_profile.phone = '9876543210'
        self.cv_profile.save()
        
        version2 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.UPDATE,
            changed_by=self.user
        )
        
        # Compare versions
        comparison = self.service.compare_versions(
            cv_profile=self.cv_profile,
            from_version_number=1,
            to_version_number=2,
            user=self.user,
            ip_address='192.168.1.1'
        )
        
        self.assertIn('from_version', comparison)
        self.assertIn('to_version', comparison)
        self.assertIn('differences', comparison)
        self.assertIn('total_changes', comparison)
        
        self.assertEqual(comparison['from_version']['number'], 1)
        self.assertEqual(comparison['to_version']['number'], 2)
        self.assertGreater(comparison['total_changes'], 0)
        
        # Check that action was logged
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.COMPARE_VERSIONS,
            cv_profile=self.cv_profile,
            user=self.user
        ).first()
        self.assertIsNotNone(action)
    
    def test_restore_version(self):
        """Test restoring a version."""
        # Create initial version
        original_phone = self.cv_profile.phone
        version1 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        # Update CV
        self.cv_profile.phone = '9876543210'
        self.cv_profile.save()
        
        version2 = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.UPDATE,
            changed_by=self.user
        )
        
        # Restore to version 1
        restore_version = self.service.restore_version(
            cv_profile=self.cv_profile,
            version_number=1,
            user=self.user,
            ip_address='192.168.1.1'
        )
        
        # Check that restore version was created
        self.assertEqual(restore_version.change_type, CVVersion.ChangeType.RESTORE)
        self.assertEqual(restore_version.version_number, 3)
        self.assertIn('Restored to version 1', restore_version.change_summary)
        
        # Check that action was logged
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.RESTORE_VERSION,
            cv_profile=self.cv_profile,
            user=self.user
        ).first()
        self.assertIsNotNone(action)
        self.assertEqual(action.metadata['restored_to_version'], 1)
    
    def test_log_version_access(self):
        """Test logging version access."""
        version = self.service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        self.service.log_version_access(
            action_type=VersionAction.ActionType.VIEW_VERSION,
            cv_profile=self.cv_profile,
            user=self.user,
            version=version,
            ip_address='192.168.1.1',
            metadata={'test': 'data'}
        )
        
        action = VersionAction.objects.filter(
            action_type=VersionAction.ActionType.VIEW_VERSION,
            cv_profile=self.cv_profile,
            user=self.user,
            version=version
        ).first()
        
        self.assertIsNotNone(action)
        self.assertEqual(action.ip_address, '192.168.1.1')
        self.assertEqual(action.metadata, {'test': 'data'})
    
    def test_global_service_instance(self):
        """Test that global service instance works."""
        self.assertIsInstance(version_service, VersionHistoryService)
        
        # Test that it can create versions
        version = version_service.create_version(
            cv_profile=self.cv_profile,
            change_type=CVVersion.ChangeType.CREATE,
            changed_by=self.user
        )
        
        self.assertIsNotNone(version)
        self.assertEqual(version.version_number, 1)