"""
Django filters for admin dashboard endpoints.
Provides search, filtering, and ordering capabilities.
"""
import django_filters
from django.db.models import Q
from apps.users.models import User, AuditLog
from apps.cv.models import GeneratedCV


class StudentFilter(django_filters.FilterSet):
    """Filter for student management endpoints"""
    
    search = django_filters.CharFilter(method='filter_search', label='Search')
    status = django_filters.ChoiceFilter(choices=User.Status.choices)
    ordering = django_filters.OrderingFilter(
        fields=(
            ('created_at', 'created_at'),
            ('full_name', 'full_name'),
            ('last_login_at', 'last_login_at'),
        ),
        field_labels={
            'created_at': 'Registration Date',
            'full_name': 'Full Name',
            'last_login_at': 'Last Login',
        }
    )
    
    class Meta:
        model = User
        fields = ['status']
    
    def filter_search(self, queryset, name, value):
        """Search across name, email, and student_id"""
        if not value:
            return queryset
        
        return queryset.filter(
            Q(full_name__icontains=value) |
            Q(email__icontains=value) |
            Q(student_id__icontains=value)
        )


class AuditLogFilter(django_filters.FilterSet):
    """Filter for audit log endpoints"""
    
    student_id = django_filters.UUIDFilter(field_name='student__id')
    action = django_filters.ChoiceFilter(choices=AuditLog.Action.choices)
    from_date = django_filters.DateFilter(field_name='timestamp', lookup_expr='gte')
    to_date = django_filters.DateFilter(field_name='timestamp', lookup_expr='lte')
    ordering = django_filters.OrderingFilter(
        fields=(
            ('timestamp', 'timestamp'),
            ('action', 'action'),
        ),
        field_labels={
            'timestamp': 'Timestamp',
            'action': 'Action',
        }
    )
    
    class Meta:
        model = AuditLog
        fields = ['action']


class GeneratedCVFilter(django_filters.FilterSet):
    """Filter for generated CV management"""
    
    template = django_filters.ChoiceFilter(choices=GeneratedCV.Template.choices)
    student_id = django_filters.UUIDFilter(field_name='cv__student__id')
    ordering = django_filters.OrderingFilter(
        fields=(
            ('generated_at', 'generated_at'),
            ('download_count', 'download_count'),
            ('template', 'template'),
        ),
        field_labels={
            'generated_at': 'Generation Date',
            'download_count': 'Downloads',
            'template': 'Template',
        }
    )
    
    class Meta:
        model = GeneratedCV
        fields = ['template']


class SecurityAuditLogFilter(django_filters.FilterSet):
    """Filter for security-specific audit logs"""
    
    SECURITY_ACTIONS = [
        AuditLog.Action.LOGIN_FAILED,
        AuditLog.Action.PASSWORD_CHANGED,
        AuditLog.Action.DELETION_REQUESTED,
        AuditLog.Action.ACCOUNT_SUSPENDED,
        AuditLog.Action.ACCOUNT_DELETED,
    ]
    
    student_id = django_filters.UUIDFilter(field_name='student__id')
    from_date = django_filters.DateFilter(field_name='timestamp', lookup_expr='gte')
    to_date = django_filters.DateFilter(field_name='timestamp', lookup_expr='lte')
    
    class Meta:
        model = AuditLog
        fields = []
    
    @property
    def qs(self):
        """Override to filter only security-relevant actions"""
        parent = super().qs
        return parent.filter(action__in=self.SECURITY_ACTIONS)