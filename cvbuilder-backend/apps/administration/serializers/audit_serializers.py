"""
Audit log serializers for admin dashboard.
"""
from rest_framework import serializers
from apps.users.models import AuditLog


class AuditLogSerializer(serializers.ModelSerializer):
    """Serializer for audit log entries"""
    
    student_name = serializers.CharField(source='student.full_name', read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)
    student_uuid = serializers.UUIDField(source='student.id', read_only=True)
    action_display = serializers.CharField(source='get_action_display', read_only=True)
    
    class Meta:
        model = AuditLog
        fields = [
            'id', 'student_name', 'student_id', 'student_uuid',
            'action', 'action_display', 'ip_address', 'user_agent',
            'timestamp', 'extra_data'
        ]