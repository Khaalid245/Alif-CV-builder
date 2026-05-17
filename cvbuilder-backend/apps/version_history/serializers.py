"""
Serializers for Version History API.
Handles serialization of version data, diffs, and history.
"""
from rest_framework import serializers
from django.contrib.auth import get_user_model

from .models import (
    CVVersion, VersionDiff, VersionAction, 
    VersionConfiguration, VersionCleanupLog
)

User = get_user_model()


class UserBasicSerializer(serializers.ModelSerializer):
    """Basic user info for version history."""
    
    class Meta:
        model = User
        fields = ['id', 'email', 'first_name', 'last_name']
        read_only_fields = fields


class VersionConfigurationSerializer(serializers.ModelSerializer):
    """Serializer for version configuration."""
    
    class Meta:
        model = VersionConfiguration
        fields = [
            'id', 'max_versions_per_cv', 'auto_cleanup_enabled',
            'track_minor_changes', 'compression_enabled',
            'created_at', 'updated_at'
        ]
        read_only_fields = ['id', 'created_at', 'updated_at']


class CVVersionListSerializer(serializers.ModelSerializer):
    """Serializer for version list view (without full CV data)."""
    
    changed_by = UserBasicSerializer(read_only=True)
    data_size_mb = serializers.SerializerMethodField()
    
    class Meta:
        model = CVVersion
        fields = [
            'id', 'version_number', 'change_type', 'change_summary',
            'changed_by', 'changed_at', 'data_size', 'data_size_mb',
            'fields_changed'
        ]
        read_only_fields = fields
    
    def get_data_size_mb(self, obj):
        """Convert data size to MB for display."""
        return round(obj.data_size / (1024 * 1024), 2) if obj.data_size else 0


class CVVersionDetailSerializer(serializers.ModelSerializer):
    """Serializer for detailed version view (with full CV data)."""
    
    changed_by = UserBasicSerializer(read_only=True)
    data_size_mb = serializers.SerializerMethodField()
    previous_version_number = serializers.SerializerMethodField()
    
    class Meta:
        model = CVVersion
        fields = [
            'id', 'version_number', 'change_type', 'change_summary',
            'cv_data', 'changed_by', 'changed_at', 'ip_address',
            'data_size', 'data_size_mb', 'fields_changed',
            'previous_version_number'
        ]
        read_only_fields = fields
    
    def get_data_size_mb(self, obj):
        """Convert data size to MB for display."""
        return round(obj.data_size / (1024 * 1024), 2) if obj.data_size else 0
    
    def get_previous_version_number(self, obj):
        """Get previous version number."""
        return obj.previous_version.version_number if obj.previous_version else None


class VersionDiffSerializer(serializers.ModelSerializer):
    """Serializer for version differences."""
    
    from_version_number = serializers.SerializerMethodField()
    to_version_number = serializers.SerializerMethodField()
    
    class Meta:
        model = VersionDiff
        fields = [
            'id', 'diff_type', 'field_path', 'old_value', 'new_value',
            'from_version_number', 'to_version_number', 'created_at'
        ]
        read_only_fields = fields
    
    def get_from_version_number(self, obj):
        return obj.from_version.version_number
    
    def get_to_version_number(self, obj):
        return obj.to_version.version_number


class VersionComparisonSerializer(serializers.Serializer):
    """Serializer for version comparison results."""
    
    from_version = serializers.DictField(read_only=True)
    to_version = serializers.DictField(read_only=True)
    differences = serializers.ListField(read_only=True)
    total_changes = serializers.IntegerField(read_only=True)


class VersionActionSerializer(serializers.ModelSerializer):
    """Serializer for version actions (audit log)."""
    
    user = UserBasicSerializer(read_only=True)
    version_number = serializers.SerializerMethodField()
    
    class Meta:
        model = VersionAction
        fields = [
            'id', 'action_type', 'user', 'version_number',
            'ip_address', 'metadata', 'created_at'
        ]
        read_only_fields = fields
    
    def get_version_number(self, obj):
        return obj.version.version_number if obj.version else None


class VersionCleanupLogSerializer(serializers.ModelSerializer):
    """Serializer for cleanup logs."""
    
    triggered_by = UserBasicSerializer(read_only=True)
    cv_student_email = serializers.SerializerMethodField()
    
    class Meta:
        model = VersionCleanupLog
        fields = [
            'id', 'cv_student_email', 'versions_deleted',
            'oldest_version_kept', 'cleanup_reason',
            'triggered_by', 'created_at'
        ]
        read_only_fields = fields
    
    def get_cv_student_email(self, obj):
        return obj.cv_profile.student.email


class RestoreVersionSerializer(serializers.Serializer):
    """Serializer for version restore requests."""
    
    version_number = serializers.IntegerField(min_value=1)
    confirm = serializers.BooleanField(default=False)
    
    def validate_confirm(self, value):
        """Ensure user confirms the restore operation."""
        if not value:
            raise serializers.ValidationError(
                "You must confirm the restore operation by setting 'confirm' to true."
            )
        return value


class CompareVersionsSerializer(serializers.Serializer):
    """Serializer for version comparison requests."""
    
    from_version = serializers.IntegerField(min_value=1)
    to_version = serializers.IntegerField(min_value=1)
    
    def validate(self, data):
        """Ensure versions are different."""
        if data['from_version'] == data['to_version']:
            raise serializers.ValidationError(
                "Cannot compare a version with itself."
            )
        return data


class VersionHistoryStatsSerializer(serializers.Serializer):
    """Serializer for version history statistics."""
    
    total_versions = serializers.IntegerField(read_only=True)
    oldest_version = serializers.IntegerField(read_only=True)
    newest_version = serializers.IntegerField(read_only=True)
    total_size_mb = serializers.FloatField(read_only=True)
    change_types = serializers.DictField(read_only=True)
    recent_activity = serializers.ListField(read_only=True)


class BulkVersionActionSerializer(serializers.Serializer):
    """Serializer for bulk version operations."""
    
    version_numbers = serializers.ListField(
        child=serializers.IntegerField(min_value=1),
        min_length=1,
        max_length=10  # Limit bulk operations
    )
    action = serializers.ChoiceField(choices=['delete', 'export'])
    confirm = serializers.BooleanField(default=False)
    
    def validate_confirm(self, value):
        """Ensure user confirms bulk operations."""
        if not value:
            raise serializers.ValidationError(
                "You must confirm bulk operations by setting 'confirm' to true."
            )
        return value