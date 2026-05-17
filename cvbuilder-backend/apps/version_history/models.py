"""
Version History models for EduCV.
Automatically tracks all changes to CV data with complete snapshots.
"""
import uuid
import json
from django.db import models
from django.contrib.contenttypes.models import ContentType
from django.contrib.contenttypes.fields import GenericForeignKey
from django.core.serializers.json import DjangoJSONEncoder
from django.utils import timezone


class VersionConfiguration(models.Model):
    """
    Configuration for version tracking behavior.
    Allows runtime configuration without code changes.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Configuration settings
    max_versions_per_cv = models.IntegerField(
        default=50,
        help_text="Maximum number of versions to keep per CV (0 = unlimited)"
    )
    auto_cleanup_enabled = models.BooleanField(
        default=True,
        help_text="Automatically cleanup old versions when limit exceeded"
    )
    track_minor_changes = models.BooleanField(
        default=True,
        help_text="Track minor changes like formatting updates"
    )
    compression_enabled = models.BooleanField(
        default=False,
        help_text="Enable compression for version data (future feature)"
    )
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    class Meta:
        db_table = 'version_configurations'
    
    def __str__(self):
        return f"Version Config (max: {self.max_versions_per_cv})"


class CVVersion(models.Model):
    """
    Complete snapshot of CV data at a specific point in time.
    Stores serialized CV profile and all related data.
    """
    
    class ChangeType(models.TextChoices):
        CREATE = 'create', 'Create'
        UPDATE = 'update', 'Update'
        DELETE = 'delete', 'Delete'
        RESTORE = 'restore', 'Restore'
        BULK_UPDATE = 'bulk_update', 'Bulk Update'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # CV reference
    cv_profile = models.ForeignKey(
        'cv.CVProfile',
        on_delete=models.CASCADE,
        related_name='versions'
    )
    
    # Version metadata
    version_number = models.IntegerField(help_text="Sequential version number")
    change_type = models.CharField(max_length=15, choices=ChangeType.choices)
    change_summary = models.CharField(
        max_length=255,
        blank=True,
        help_text="Brief description of what changed"
    )
    
    # Complete CV data snapshot (JSON)
    cv_data = models.JSONField(
        encoder=DjangoJSONEncoder,
        help_text="Complete serialized CV data at this version"
    )
    
    # Change tracking
    changed_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        related_name='cv_versions_created'
    )
    changed_at = models.DateTimeField(default=timezone.now)
    
    # Technical metadata
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True, default='')
    data_size = models.IntegerField(
        default=0,
        help_text="Size of cv_data in bytes"
    )
    
    # Comparison metadata
    fields_changed = models.JSONField(
        default=list,
        help_text="List of field names that changed in this version"
    )
    previous_version = models.ForeignKey(
        'self',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='next_versions'
    )
    
    class Meta:
        db_table = 'cv_versions'
        ordering = ['-version_number']
        indexes = [
            models.Index(fields=['cv_profile', '-version_number'], name='idx_cv_versions_profile'),
            models.Index(fields=['changed_at'], name='idx_cv_versions_changed_at'),
            models.Index(fields=['change_type'], name='idx_cv_versions_change_type'),
        ]
        constraints = [
            models.UniqueConstraint(
                fields=['cv_profile', 'version_number'],
                name='unique_version_per_cv'
            )
        ]
    
    def __str__(self):
        return f"CV v{self.version_number} - {self.cv_profile.student.email}"
    
    def get_data_size(self):
        """Calculate and return the size of cv_data in bytes."""
        if self.cv_data:
            return len(json.dumps(self.cv_data, cls=DjangoJSONEncoder).encode('utf-8'))
        return 0
    
    def save(self, *args, **kwargs):
        """Auto-calculate data size before saving."""
        self.data_size = self.get_data_size()
        super().save(*args, **kwargs)


class VersionDiff(models.Model):
    """
    Stores computed differences between two versions for performance.
    Pre-computed diffs avoid expensive runtime comparisons.
    """
    
    class DiffType(models.TextChoices):
        FIELD_CHANGE = 'field_change', 'Field Change'
        SECTION_ADD = 'section_add', 'Section Added'
        SECTION_REMOVE = 'section_remove', 'Section Removed'
        SECTION_MODIFY = 'section_modify', 'Section Modified'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Version references
    from_version = models.ForeignKey(
        CVVersion,
        on_delete=models.CASCADE,
        related_name='diffs_from'
    )
    to_version = models.ForeignKey(
        CVVersion,
        on_delete=models.CASCADE,
        related_name='diffs_to'
    )
    
    # Diff data
    diff_type = models.CharField(max_length=15, choices=DiffType.choices)
    field_path = models.CharField(
        max_length=255,
        help_text="Dot-notation path to changed field (e.g., 'profile.summary')"
    )
    old_value = models.JSONField(null=True, blank=True)
    new_value = models.JSONField(null=True, blank=True)
    
    # Metadata
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'version_diffs'
        ordering = ['field_path']
        indexes = [
            models.Index(fields=['from_version', 'to_version'], name='idx_version_diffs_versions'),
            models.Index(fields=['diff_type'], name='idx_version_diffs_type'),
        ]
    
    def __str__(self):
        return f"Diff: {self.field_path} ({self.from_version.version_number} → {self.to_version.version_number})"


class VersionAction(models.Model):
    """
    Audit log for version-related actions (view, restore, compare).
    Tracks who accessed version history and when.
    """
    
    class ActionType(models.TextChoices):
        VIEW_VERSION = 'view_version', 'View Version'
        VIEW_HISTORY = 'view_history', 'View History'
        RESTORE_VERSION = 'restore_version', 'Restore Version'
        COMPARE_VERSIONS = 'compare_versions', 'Compare Versions'
        DELETE_VERSION = 'delete_version', 'Delete Version'
    
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    # Action details
    action_type = models.CharField(max_length=20, choices=ActionType.choices)
    cv_profile = models.ForeignKey(
        'cv.CVProfile',
        on_delete=models.CASCADE,
        related_name='version_actions'
    )
    version = models.ForeignKey(
        CVVersion,
        on_delete=models.CASCADE,
        null=True,
        blank=True,
        related_name='actions'
    )
    
    # User and context
    user = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        related_name='version_actions'
    )
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True, default='')
    
    # Additional context
    metadata = models.JSONField(
        default=dict,
        help_text="Additional action-specific data"
    )
    
    # Timestamp
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'version_actions'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['cv_profile', '-created_at'], name='idx_version_actions_cv'),
            models.Index(fields=['action_type'], name='idx_version_actions_type'),
            models.Index(fields=['user', '-created_at'], name='idx_version_actions_user'),
        ]
    
    def __str__(self):
        return f"{self.action_type} - {self.cv_profile.student.email} at {self.created_at}"


class VersionCleanupLog(models.Model):
    """
    Tracks automatic cleanup operations for compliance and debugging.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    
    cv_profile = models.ForeignKey(
        'cv.CVProfile',
        on_delete=models.CASCADE,
        related_name='cleanup_logs'
    )
    
    # Cleanup details
    versions_deleted = models.IntegerField(default=0)
    oldest_version_kept = models.IntegerField(null=True, blank=True)
    cleanup_reason = models.CharField(
        max_length=100,
        default='max_versions_exceeded'
    )
    
    # Metadata
    triggered_by = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True
    )
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'version_cleanup_logs'
        ordering = ['-created_at']
    
    def __str__(self):
        return f"Cleanup: {self.versions_deleted} versions deleted for {self.cv_profile.student.email}"