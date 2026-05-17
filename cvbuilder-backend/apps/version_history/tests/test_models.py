"""
Tests for Version History models.
"""
import json
from django.test import TestCase
from django.contrib.auth import get_user_model
from django.core.exceptions import ValidationError
from django.db import IntegrityError

from apps.cv.models import CVProfile, Education
from apps.version_history.models import (
    CVVersion, VersionDiff, VersionAction, 
    VersionConfiguration, VersionCleanupLog
)

User = get_user_model()


class VersionConfigurationModelTest(TestCase):
    """Test VersionConfiguration model."""
    
    def test_create_configuration(self):
        """Test creating version configuration."""
        config = VersionConfiguration.objects.create(
            max_versions_per_cv=25,
            auto_cleanup_enabled=False,
            track_minor_changes=True
        )
        
        self.assertEqual(config.max_versions_per_cv, 25)
        self.assertFalse(config.auto_cleanup_enabled)
        self.assertTrue(config.track_minor_changes)
        self.assertIsNotNone(config.created_at)
        self.assertIsNotNone(config.updated_at)
    
    def test_configuration_str(self):
        """Test string representation."""
        config = VersionConfiguration.objects.create(max_versions_per_cv=30)
        self.assertEqual(str(config), "Version Config (max: 30)")


class CVVersionModelTest(TestCase):
    """Test CVVersion model."""
    
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
            city='Test City'
        )
    
    def test_create_version(self):
        """Test creating a CV version."""
        cv_data = {
            'phone': '1234567890',
            'city': 'Test City',
            'educations': []
        }
        
        version = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            change_summary='Initial version',
            cv_data=cv_data,
            changed_by=self.user,
            fields_changed=['phone', 'city']
        )
        
        self.assertEqual(version.version_number, 1)
        self.assertEqual(version.change_type, CVVersion.ChangeType.CREATE)
        self.assertEqual(version.cv_data, cv_data)
        self.assertEqual(version.changed_by, self.user)
        self.assertEqual(version.fields_changed, ['phone', 'city'])
        self.assertIsNotNone(version.changed_at)
    
    def test_version_str(self):
        """Test string representation."""
        version = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data={},
            changed_by=self.user
        )
        
        expected = f"CV v1 - {self.user.email}"
        self.assertEqual(str(version), expected)
    
    def test_get_data_size(self):
        """Test data size calculation."""
        cv_data = {'test': 'data', 'number': 123}
        version = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data=cv_data,
            changed_by=self.user
        )
        
        expected_size = len(json.dumps(cv_data).encode('utf-8'))
        self.assertEqual(version.get_data_size(), expected_size)
        self.assertEqual(version.data_size, expected_size)
    
    def test_unique_version_per_cv(self):
        """Test unique constraint on version number per CV."""
        CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data={},
            changed_by=self.user
        )
        
        # Should raise IntegrityError for duplicate version number
        with self.assertRaises(IntegrityError):
            CVVersion.objects.create(
                cv_profile=self.cv_profile,
                version_number=1,
                change_type=CVVersion.ChangeType.UPDATE,
                cv_data={},
                changed_by=self.user
            )
    
    def test_version_ordering(self):
        """Test version ordering."""
        version1 = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data={},
            changed_by=self.user
        )
        
        version2 = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=2,
            change_type=CVVersion.ChangeType.UPDATE,
            cv_data={},
            changed_by=self.user
        )
        
        versions = list(CVVersion.objects.all())
        self.assertEqual(versions[0], version2)  # Higher version first
        self.assertEqual(versions[1], version1)


class VersionDiffModelTest(TestCase):
    """Test VersionDiff model."""
    
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        self.cv_profile = CVProfile.objects.create(student=self.user)
        
        self.version1 = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data={'phone': '123'},
            changed_by=self.user
        )
        
        self.version2 = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=2,
            change_type=CVVersion.ChangeType.UPDATE,
            cv_data={'phone': '456'},
            changed_by=self.user
        )
    
    def test_create_diff(self):
        """Test creating version diff."""
        diff = VersionDiff.objects.create(
            from_version=self.version1,
            to_version=self.version2,
            diff_type=VersionDiff.DiffType.FIELD_CHANGE,
            field_path='phone',
            old_value='123',
            new_value='456'
        )
        
        self.assertEqual(diff.from_version, self.version1)
        self.assertEqual(diff.to_version, self.version2)
        self.assertEqual(diff.diff_type, VersionDiff.DiffType.FIELD_CHANGE)
        self.assertEqual(diff.field_path, 'phone')
        self.assertEqual(diff.old_value, '123')
        self.assertEqual(diff.new_value, '456')
    
    def test_diff_str(self):
        """Test string representation."""
        diff = VersionDiff.objects.create(
            from_version=self.version1,
            to_version=self.version2,
            diff_type=VersionDiff.DiffType.FIELD_CHANGE,
            field_path='phone',
            old_value='123',
            new_value='456'
        )
        
        expected = "Diff: phone (1 → 2)"
        self.assertEqual(str(diff), expected)


class VersionActionModelTest(TestCase):
    """Test VersionAction model."""
    
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        self.cv_profile = CVProfile.objects.create(student=self.user)
        self.version = CVVersion.objects.create(
            cv_profile=self.cv_profile,
            version_number=1,
            change_type=CVVersion.ChangeType.CREATE,
            cv_data={},
            changed_by=self.user
        )
    
    def test_create_action(self):
        """Test creating version action."""
        action = VersionAction.objects.create(
            action_type=VersionAction.ActionType.VIEW_VERSION,
            cv_profile=self.cv_profile,
            version=self.version,
            user=self.user,
            ip_address='192.168.1.1',
            metadata={'test': 'data'}
        )
        
        self.assertEqual(action.action_type, VersionAction.ActionType.VIEW_VERSION)
        self.assertEqual(action.cv_profile, self.cv_profile)
        self.assertEqual(action.version, self.version)
        self.assertEqual(action.user, self.user)
        self.assertEqual(action.ip_address, '192.168.1.1')
        self.assertEqual(action.metadata, {'test': 'data'})
    
    def test_action_str(self):
        """Test string representation."""
        action = VersionAction.objects.create(
            action_type=VersionAction.ActionType.VIEW_VERSION,
            cv_profile=self.cv_profile,
            user=self.user
        )
        
        expected = f"view_version - {self.user.email} at {action.created_at}"
        self.assertEqual(str(action), expected)


class VersionCleanupLogModelTest(TestCase):
    """Test VersionCleanupLog model."""
    
    def setUp(self):
        """Set up test data."""
        self.user = User.objects.create_user(
            email='test@example.com',
            password='testpass123'
        )
        self.cv_profile = CVProfile.objects.create(student=self.user)
    
    def test_create_cleanup_log(self):
        """Test creating cleanup log."""
        log = VersionCleanupLog.objects.create(
            cv_profile=self.cv_profile,
            versions_deleted=5,
            oldest_version_kept=10,
            cleanup_reason='max_versions_exceeded',
            triggered_by=self.user
        )
        
        self.assertEqual(log.cv_profile, self.cv_profile)
        self.assertEqual(log.versions_deleted, 5)
        self.assertEqual(log.oldest_version_kept, 10)
        self.assertEqual(log.cleanup_reason, 'max_versions_exceeded')
        self.assertEqual(log.triggered_by, self.user)
    
    def test_cleanup_log_str(self):
        """Test string representation."""
        log = VersionCleanupLog.objects.create(
            cv_profile=self.cv_profile,
            versions_deleted=3,
            triggered_by=self.user
        )
        
        expected = f"Cleanup: 3 versions deleted for {self.user.email}"
        self.assertEqual(str(log), expected)