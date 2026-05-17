"""
Core version history service for EduCV.
Handles version creation, comparison, restoration, and cleanup.
"""
import json
import logging
from typing import Dict, List, Optional, Tuple, Any
from django.db import transaction
from django.core.serializers import serialize
from django.core.serializers.json import DjangoJSONEncoder
from django.utils import timezone
from django.contrib.contenttypes.models import ContentType

from apps.cv.models import CVProfile
from apps.cv.serializers import CVProfileSerializer
from ..models import (
    CVVersion, VersionDiff, VersionAction, 
    VersionConfiguration, VersionCleanupLog
)

logger = logging.getLogger(__name__)


class VersionHistoryService:
    """
    Enterprise-grade version history service.
    Handles all version tracking operations with configurable behavior.
    """
    
    def __init__(self):
        self._config = None
    
    @property
    def config(self):
        """Lazy-load configuration to avoid database access during app initialization."""
        if self._config is None:
            self._config = self._get_configuration()
        return self._config
    
    @config.setter
    def config(self, value):
        """Allow setting configuration."""
        self._config = value
    
    def _get_configuration(self) -> VersionConfiguration:
        """Get or create version configuration."""
        config, created = VersionConfiguration.objects.get_or_create(
            defaults={
                'max_versions_per_cv': 50,
                'auto_cleanup_enabled': True,
                'track_minor_changes': True,
                'compression_enabled': False,
            }
        )
        if created:
            logger.info("Created default version configuration")
        return config
    
    @transaction.atomic
    def create_version(
        self,
        cv_profile: CVProfile,
        change_type: str,
        changed_by: 'User',
        change_summary: str = '',
        ip_address: str = None,
        user_agent: str = '',
        fields_changed: List[str] = None
    ) -> CVVersion:
        """
        Create a new version snapshot of the CV.
        
        Args:
            cv_profile: The CV profile to version
            change_type: Type of change (create, update, delete, restore)
            changed_by: User who made the change
            change_summary: Brief description of changes
            ip_address: IP address of the user
            user_agent: User agent string
            fields_changed: List of field names that changed
        
        Returns:
            Created CVVersion instance
        """
        try:
            # Get next version number
            last_version = CVVersion.objects.filter(
                cv_profile=cv_profile
            ).first()
            version_number = (last_version.version_number + 1) if last_version else 1
            
            # Serialize complete CV data
            cv_data = self._serialize_cv_data(cv_profile)
            
            # Create version
            version = CVVersion.objects.create(
                cv_profile=cv_profile,
                version_number=version_number,
                change_type=change_type,
                change_summary=change_summary or f"{change_type.title()} operation",
                cv_data=cv_data,
                changed_by=changed_by,
                changed_at=timezone.now(),
                ip_address=ip_address,
                user_agent=user_agent,
                fields_changed=fields_changed or [],
                previous_version=last_version
            )
            
            # Create diff if there's a previous version
            if last_version:
                self._create_version_diff(last_version, version)
            
            # Auto-cleanup if enabled
            if self.config.auto_cleanup_enabled:
                self._cleanup_old_versions(cv_profile, changed_by)
            
            logger.info(
                f"Created version {version_number} for CV {cv_profile.id} "
                f"by user {changed_by.id}"
            )
            
            return version
            
        except Exception as e:
            logger.error(f"Failed to create version: {str(e)}")
            raise
    
    def _serialize_cv_data(self, cv_profile: CVProfile) -> Dict:
        """
        Serialize complete CV data including all related objects.
        
        Args:
            cv_profile: CV profile to serialize
            
        Returns:
            Dictionary containing complete CV data
        """
        # Use the existing serializer for consistency
        serializer = CVProfileSerializer(cv_profile)
        return serializer.data
    
    def _create_version_diff(self, from_version: CVVersion, to_version: CVVersion):
        """
        Create diff between two versions.
        
        Args:
            from_version: Previous version
            to_version: Current version
        """
        try:
            diffs = self._compute_differences(
                from_version.cv_data,
                to_version.cv_data
            )
            
            # Create VersionDiff objects
            diff_objects = []
            for diff in diffs:
                diff_objects.append(VersionDiff(
                    from_version=from_version,
                    to_version=to_version,
                    diff_type=diff['type'],
                    field_path=diff['field_path'],
                    old_value=diff.get('old_value'),
                    new_value=diff.get('new_value')
                ))
            
            if diff_objects:
                VersionDiff.objects.bulk_create(diff_objects)
                logger.debug(f"Created {len(diff_objects)} diffs between versions")
                
        except Exception as e:
            logger.error(f"Failed to create version diff: {str(e)}")
    
    def _compute_differences(self, old_data: Dict, new_data: Dict) -> List[Dict]:
        """
        Compute differences between two CV data dictionaries.
        
        Args:
            old_data: Previous version data
            new_data: Current version data
            
        Returns:
            List of difference dictionaries
        """
        diffs = []
        
        def compare_values(old_val, new_val, path):
            if old_val != new_val:
                diffs.append({
                    'type': 'field_change',
                    'field_path': path,
                    'old_value': old_val,
                    'new_value': new_val
                })
        
        def compare_dicts(old_dict, new_dict, prefix=''):
            # Compare scalar fields
            scalar_fields = ['phone', 'address', 'city', 'country', 'summary', 
                           'linkedin', 'github', 'portfolio']
            
            for field in scalar_fields:
                if field in old_dict or field in new_dict:
                    old_val = old_dict.get(field)
                    new_val = new_dict.get(field)
                    path = f"{prefix}.{field}" if prefix else field
                    compare_values(old_val, new_val, path)
            
            # Compare list fields (educations, experiences, etc.)
            list_fields = ['educations', 'experiences', 'skills', 'languages', 
                          'projects', 'certifications']
            
            for field in list_fields:
                old_list = old_dict.get(field, [])
                new_list = new_dict.get(field, [])
                path = f"{prefix}.{field}" if prefix else field
                
                # Simple comparison - could be enhanced for more granular diffs
                if len(old_list) != len(new_list):
                    diffs.append({
                        'type': 'section_modify',
                        'field_path': path,
                        'old_value': f"{len(old_list)} items",
                        'new_value': f"{len(new_list)} items"
                    })
                elif old_list != new_list:
                    diffs.append({
                        'type': 'section_modify',
                        'field_path': path,
                        'old_value': 'modified',
                        'new_value': 'modified'
                    })
        
        compare_dicts(old_data, new_data)
        return diffs
    
    def _cleanup_old_versions(self, cv_profile: CVProfile, triggered_by: 'User'):
        """
        Clean up old versions if limit exceeded.
        
        Args:
            cv_profile: CV profile to clean up
            triggered_by: User who triggered the cleanup
        """
        if self.config.max_versions_per_cv <= 0:
            return  # Unlimited versions
        
        versions = CVVersion.objects.filter(
            cv_profile=cv_profile
        ).order_by('-version_number')
        
        total_versions = versions.count()
        
        if total_versions > self.config.max_versions_per_cv:
            # Keep the most recent versions, delete the rest
            versions_to_keep = versions[:self.config.max_versions_per_cv]
            keep_ids = [v.id for v in versions_to_keep]
            
            versions_to_delete = CVVersion.objects.filter(
                cv_profile=cv_profile
            ).exclude(id__in=keep_ids)
            
            deleted_count = versions_to_delete.count()
            oldest_kept = versions_to_keep.last().version_number if versions_to_keep else None
            
            # Delete old versions
            versions_to_delete.delete()
            
            # Log cleanup
            VersionCleanupLog.objects.create(
                cv_profile=cv_profile,
                versions_deleted=deleted_count,
                oldest_version_kept=oldest_kept,
                cleanup_reason='max_versions_exceeded',
                triggered_by=triggered_by
            )
            
            logger.info(
                f"Cleaned up {deleted_count} old versions for CV {cv_profile.id}"
            )
    
    def get_version_history(self, cv_profile: CVProfile) -> List[CVVersion]:
        """
        Get version history for a CV profile.
        
        Args:
            cv_profile: CV profile to get history for
            
        Returns:
            List of CVVersion objects ordered by version number (newest first)
        """
        return CVVersion.objects.filter(
            cv_profile=cv_profile
        ).select_related('changed_by').order_by('-version_number')
    
    def get_version_by_number(
        self, 
        cv_profile: CVProfile, 
        version_number: int
    ) -> Optional[CVVersion]:
        """
        Get a specific version by number.
        
        Args:
            cv_profile: CV profile
            version_number: Version number to retrieve
            
        Returns:
            CVVersion instance or None if not found
        """
        try:
            return CVVersion.objects.get(
                cv_profile=cv_profile,
                version_number=version_number
            )
        except CVVersion.DoesNotExist:
            return None
    
    def compare_versions(
        self,
        cv_profile: CVProfile,
        from_version_number: int,
        to_version_number: int,
        user: 'User',
        ip_address: str = None
    ) -> Dict:
        """
        Compare two versions and return differences.
        
        Args:
            cv_profile: CV profile
            from_version_number: Source version number
            to_version_number: Target version number
            user: User requesting comparison
            ip_address: User's IP address
            
        Returns:
            Dictionary containing comparison results
        """
        from_version = self.get_version_by_number(cv_profile, from_version_number)
        to_version = self.get_version_by_number(cv_profile, to_version_number)
        
        if not from_version or not to_version:
            raise ValueError("One or both versions not found")
        
        # Log the action
        VersionAction.objects.create(
            action_type=VersionAction.ActionType.COMPARE_VERSIONS,
            cv_profile=cv_profile,
            user=user,
            ip_address=ip_address,
            metadata={
                'from_version': from_version_number,
                'to_version': to_version_number
            }
        )
        
        # Get or compute diffs
        diffs = VersionDiff.objects.filter(
            from_version=from_version,
            to_version=to_version
        )
        
        if not diffs.exists():
            # Compute diffs on-the-fly if not pre-computed
            diff_data = self._compute_differences(
                from_version.cv_data,
                to_version.cv_data
            )
        else:
            diff_data = [
                {
                    'type': diff.diff_type,
                    'field_path': diff.field_path,
                    'old_value': diff.old_value,
                    'new_value': diff.new_value
                }
                for diff in diffs
            ]
        
        return {
            'from_version': {
                'number': from_version.version_number,
                'changed_at': from_version.changed_at,
                'changed_by': from_version.changed_by.email if from_version.changed_by else None,
                'change_summary': from_version.change_summary
            },
            'to_version': {
                'number': to_version.version_number,
                'changed_at': to_version.changed_at,
                'changed_by': to_version.changed_by.email if to_version.changed_by else None,
                'change_summary': to_version.change_summary
            },
            'differences': diff_data,
            'total_changes': len(diff_data)
        }
    
    @transaction.atomic
    def restore_version(
        self,
        cv_profile: CVProfile,
        version_number: int,
        user: 'User',
        ip_address: str = None,
        user_agent: str = ''
    ) -> CVVersion:
        """
        Restore CV to a previous version.
        
        Args:
            cv_profile: CV profile to restore
            version_number: Version number to restore to
            user: User performing the restore
            ip_address: User's IP address
            user_agent: User agent string
            
        Returns:
            New CVVersion created for the restore operation
        """
        # Get the version to restore
        restore_version = self.get_version_by_number(cv_profile, version_number)
        if not restore_version:
            raise ValueError(f"Version {version_number} not found")
        
        # Update CV profile with restored data
        restored_data = restore_version.cv_data
        
        # Update profile fields
        profile_fields = ['phone', 'address', 'city', 'country', 'summary',
                         'linkedin', 'github', 'portfolio']
        
        for field in profile_fields:
            if field in restored_data:
                setattr(cv_profile, field, restored_data[field])
        
        cv_profile.save()
        
        # TODO: Restore related objects (educations, experiences, etc.)
        # This would require more complex logic to handle related model updates
        
        # Log the action
        VersionAction.objects.create(
            action_type=VersionAction.ActionType.RESTORE_VERSION,
            cv_profile=cv_profile,
            version=restore_version,
            user=user,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata={'restored_to_version': version_number}
        )
        
        # Create new version for the restore operation
        new_version = self.create_version(
            cv_profile=cv_profile,
            change_type=CVVersion.ChangeType.RESTORE,
            changed_by=user,
            change_summary=f"Restored to version {version_number}",
            ip_address=ip_address,
            user_agent=user_agent,
            fields_changed=['restored_from_version']
        )
        
        logger.info(
            f"Restored CV {cv_profile.id} to version {version_number} "
            f"by user {user.id}"
        )
        
        return new_version
    
    def log_version_access(
        self,
        action_type: str,
        cv_profile: CVProfile,
        user: 'User',
        version: CVVersion = None,
        ip_address: str = None,
        user_agent: str = '',
        metadata: Dict = None
    ):
        """
        Log version-related actions for audit purposes.
        
        Args:
            action_type: Type of action performed
            cv_profile: CV profile accessed
            user: User performing the action
            version: Specific version accessed (optional)
            ip_address: User's IP address
            user_agent: User agent string
            metadata: Additional action-specific data
        """
        VersionAction.objects.create(
            action_type=action_type,
            cv_profile=cv_profile,
            version=version,
            user=user,
            ip_address=ip_address,
            user_agent=user_agent,
            metadata=metadata or {}
        )


# Global service instance
version_service = VersionHistoryService()