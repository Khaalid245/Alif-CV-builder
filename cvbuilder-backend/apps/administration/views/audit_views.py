"""
Audit log views for admin dashboard.
Provides access to all audit logs and security-specific logs.
"""
import logging
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.generics import ListAPIView
from rest_framework.pagination import PageNumberPagination

from apps.core.responses import success_response
from apps.administration.permissions import IsAdminUser
from apps.administration.filters import AuditLogFilter, SecurityAuditLogFilter
from apps.administration.serializers.audit_serializers import AuditLogSerializer
from apps.users.models import AuditLog

# Application logger
app_logger = logging.getLogger('app')


class AuditLogPagination(PageNumberPagination):
    """Custom pagination for audit log lists"""
    page_size = 50
    page_size_query_param = 'page_size'
    max_page_size = 200


class AuditLogListView(ListAPIView):
    """
    GET /api/v1/admin/audit-logs/
    List all audit logs with filtering and search capabilities.
    """
    serializer_class = AuditLogSerializer
    permission_classes = [IsAdminUser]
    pagination_class = AuditLogPagination
    filter_backends = [DjangoFilterBackend]
    filterset_class = AuditLogFilter
    
    def get_queryset(self):
        """Optimized queryset with student data"""
        return AuditLog.objects.select_related('student').order_by('-timestamp')
    
    def list(self, request, *args, **kwargs):
        """Override to log admin access and format response"""
        app_logger.info(f"Admin {request.user.email} accessed audit logs")
        
        response = super().list(request, *args, **kwargs)
        
        # Format response with pagination metadata
        return success_response(
            message="Audit logs retrieved successfully.",
            data={
                'count': response.data['count'],
                'total_pages': (response.data['count'] + self.pagination_class.page_size - 1) // self.pagination_class.page_size,
                'current_page': int(request.GET.get('page', 1)),
                'next': response.data['next'],
                'previous': response.data['previous'],
                'results': response.data['results'],
            }
        )


class SecurityAuditLogListView(ListAPIView):
    """
    GET /api/v1/admin/audit-logs/security/
    List only security-relevant audit logs.
    """
    serializer_class = AuditLogSerializer
    permission_classes = [IsAdminUser]
    pagination_class = AuditLogPagination
    filter_backends = [DjangoFilterBackend]
    filterset_class = SecurityAuditLogFilter
    
    def get_queryset(self):
        """Security-specific audit logs"""
        security_actions = [
            AuditLog.Action.LOGIN_FAILED,
            AuditLog.Action.PASSWORD_CHANGED,
            AuditLog.Action.DELETION_REQUESTED,
            AuditLog.Action.ACCOUNT_SUSPENDED,
            AuditLog.Action.ACCOUNT_REACTIVATED,
            AuditLog.Action.ACCOUNT_DELETED,
        ]
        
        return AuditLog.objects.select_related('student').filter(
            action__in=security_actions
        ).order_by('-timestamp')
    
    def list(self, request, *args, **kwargs):
        """Override to log admin access and format response"""
        app_logger.info(f"Admin {request.user.email} accessed security audit logs")
        
        response = super().list(request, *args, **kwargs)
        
        # Format response with pagination metadata
        return success_response(
            message="Security audit logs retrieved successfully.",
            data={
                'count': response.data['count'],
                'total_pages': (response.data['count'] + self.pagination_class.page_size - 1) // self.pagination_class.page_size,
                'current_page': int(request.GET.get('page', 1)),
                'next': response.data['next'],
                'previous': response.data['previous'],
                'results': response.data['results'],
            }
        )