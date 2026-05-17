"""
API views for Version History system.
Provides REST endpoints for version management operations.
"""
import logging
from typing import Dict, Any
from django.db.models import Count, Sum, Q
from django.utils import timezone
from django.http import Http404
from rest_framework import status, viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter

from apps.core.responses import success_response, error_response
from rest_framework.permissions import IsAuthenticated
from apps.cv.models import CVProfile
from .models import (
    CVVersion, VersionDiff, VersionAction, 
    VersionConfiguration, VersionCleanupLog
)
from .serializers import (
    CVVersionListSerializer, CVVersionDetailSerializer,
    VersionDiffSerializer, VersionComparisonSerializer,
    VersionActionSerializer, VersionConfigurationSerializer,
    VersionCleanupLogSerializer, RestoreVersionSerializer,
    CompareVersionsSerializer, VersionHistoryStatsSerializer,
    BulkVersionActionSerializer
)
from .permissions import (
    CanViewVersionHistory, CanRestoreVersion, CanCompareVersions,
    CanManageVersionConfiguration, CanViewVersionActions,
    CanDeleteVersions, IsOwnerOrAdmin
)
from .services import version_service

logger = logging.getLogger(__name__)


def get_client_ip(request):
    """Extract client IP address from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


def get_user_agent(request):
    """Extract user agent from request."""
    return request.META.get('HTTP_USER_AGENT', '')


class CVVersionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for CV version management.
    Provides list, retrieve, and custom actions for versions.
    """
    
    permission_classes = [IsAuthenticated, CanViewVersionHistory]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['change_type', 'changed_at']
    ordering_fields = ['version_number', 'changed_at']
    ordering = ['-version_number']
    search_fields = ['change_summary']
    
    def get_queryset(self):
        """Get versions for user's CV profile."""
        try:
            cv_profile = self.request.user.cv_profile
            return CVVersion.objects.filter(
                cv_profile=cv_profile
            ).select_related('changed_by', 'previous_version')
        except CVProfile.DoesNotExist:
            return CVVersion.objects.none()
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'retrieve':
            return CVVersionDetailSerializer
        return CVVersionListSerializer
    
    def list(self, request, *args, **kwargs):
        """List all versions for user's CV."""
        try:
            # Log the access
            if hasattr(request.user, 'cv_profile'):
                version_service.log_version_access(
                    action_type=VersionAction.ActionType.VIEW_HISTORY,
                    cv_profile=request.user.cv_profile,
                    user=request.user,
                    ip_address=get_client_ip(request),
                    user_agent=get_user_agent(request)
                )
            
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Version history retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list versions: {str(e)}")
            return error_response(
                message="Failed to retrieve version history.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a specific version."""
        try:
            version = self.get_object()
            
            # Log the access
            version_service.log_version_access(
                action_type=VersionAction.ActionType.VIEW_VERSION,
                cv_profile=version.cv_profile,
                user=request.user,
                version=version,
                ip_address=get_client_ip(request),
                user_agent=get_user_agent(request)
            )
            
            response = super().retrieve(request, *args, **kwargs)
            return success_response(
                message="Version retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to retrieve version: {str(e)}")
            return error_response(
                message="Failed to retrieve version.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], permission_classes=[IsAuthenticated, CanRestoreVersion])
    def restore(self, request, pk=None):
        """Restore CV to a specific version."""
        try:
            version = self.get_object()
            serializer = RestoreVersionSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid restore request.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Perform restore
            new_version = version_service.restore_version(
                cv_profile=version.cv_profile,
                version_number=version.version_number,
                user=request.user,
                ip_address=get_client_ip(request),
                user_agent=get_user_agent(request)
            )
            
            return success_response(
                message=f"CV restored to version {version.version_number} successfully.",
                data={
                    'restored_version': version.version_number,
                    'new_version': new_version.version_number,
                    'restored_at': new_version.changed_at
                }
            )
            
        except ValueError as e:
            return error_response(
                message=str(e),
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            logger.error(f"Failed to restore version: {str(e)}")
            return error_response(
                message="Failed to restore version.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['post'], permission_classes=[IsAuthenticated, CanCompareVersions])
    def compare(self, request):
        """Compare two versions."""
        try:
            serializer = CompareVersionsSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid comparison request.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            cv_profile = request.user.cv_profile
            comparison = version_service.compare_versions(
                cv_profile=cv_profile,
                from_version_number=serializer.validated_data['from_version'],
                to_version_number=serializer.validated_data['to_version'],
                user=request.user,
                ip_address=get_client_ip(request)
            )
            
            comparison_serializer = VersionComparisonSerializer(comparison)
            
            return success_response(
                message="Version comparison completed successfully.",
                data=comparison_serializer.data
            )
            
        except ValueError as e:
            return error_response(
                message=str(e),
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except CVProfile.DoesNotExist:
            return error_response(
                message="CV profile not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to compare versions: {str(e)}")
            return error_response(
                message="Failed to compare versions.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def stats(self, request):
        """Get version history statistics."""
        try:
            cv_profile = request.user.cv_profile
            versions = CVVersion.objects.filter(cv_profile=cv_profile)
            
            # Calculate statistics
            stats = versions.aggregate(
                total_versions=Count('id'),
                total_size=Sum('data_size')
            )
            
            # Get change type distribution
            change_types = versions.values('change_type').annotate(
                count=Count('id')
            ).order_by('change_type')
            
            # Get recent activity (last 10 versions)
            recent_versions = versions.order_by('-changed_at')[:10]
            recent_activity = CVVersionListSerializer(recent_versions, many=True).data
            
            stats_data = {
                'total_versions': stats['total_versions'] or 0,
                'oldest_version': versions.order_by('version_number').first().version_number if versions.exists() else 0,
                'newest_version': versions.order_by('-version_number').first().version_number if versions.exists() else 0,
                'total_size_mb': round((stats['total_size'] or 0) / (1024 * 1024), 2),
                'change_types': {ct['change_type']: ct['count'] for ct in change_types},
                'recent_activity': recent_activity
            }
            
            stats_serializer = VersionHistoryStatsSerializer(stats_data)
            
            return success_response(
                message="Version statistics retrieved successfully.",
                data=stats_serializer.data
            )
            
        except CVProfile.DoesNotExist:
            return error_response(
                message="CV profile not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to get version stats: {str(e)}")
            return error_response(
                message="Failed to retrieve version statistics.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VersionDiffViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for version differences.
    Provides access to pre-computed diffs between versions.
    """
    
    serializer_class = VersionDiffSerializer
    permission_classes = [IsAuthenticated, CanViewVersionHistory]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['diff_type', 'field_path']
    ordering = ['field_path']
    
    def get_queryset(self):
        """Get diffs for user's CV versions."""
        try:
            cv_profile = self.request.user.cv_profile
            return VersionDiff.objects.filter(
                from_version__cv_profile=cv_profile
            ).select_related('from_version', 'to_version')
        except CVProfile.DoesNotExist:
            return VersionDiff.objects.none()
    
    def list(self, request, *args, **kwargs):
        """List version diffs."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Version differences retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list version diffs: {str(e)}")
            return error_response(
                message="Failed to retrieve version differences.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VersionActionViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for version actions (audit log).
    Provides access to version-related actions for audit purposes.
    """
    
    serializer_class = VersionActionSerializer
    permission_classes = [IsAuthenticated, CanViewVersionActions]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['action_type', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Get actions for user's CV or all actions if admin."""
        if self.request.user.is_staff:
            return VersionAction.objects.all().select_related('user', 'version')
        
        try:
            cv_profile = self.request.user.cv_profile
            return VersionAction.objects.filter(
                cv_profile=cv_profile
            ).select_related('user', 'version')
        except CVProfile.DoesNotExist:
            return VersionAction.objects.none()
    
    def list(self, request, *args, **kwargs):
        """List version actions."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Version actions retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list version actions: {str(e)}")
            return error_response(
                message="Failed to retrieve version actions.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VersionConfigurationView(APIView):
    """
    API view for version configuration management.
    Only accessible by staff users.
    """
    
    permission_classes = [IsAuthenticated, CanManageVersionConfiguration]
    
    def get(self, request):
        """Get current version configuration."""
        try:
            config = version_service.config
            serializer = VersionConfigurationSerializer(config)
            
            return success_response(
                message="Version configuration retrieved successfully.",
                data=serializer.data
            )
        except Exception as e:
            logger.error(f"Failed to get version configuration: {str(e)}")
            return error_response(
                message="Failed to retrieve version configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def put(self, request):
        """Update version configuration."""
        try:
            config = version_service.config
            serializer = VersionConfigurationSerializer(config, data=request.data, partial=True)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid configuration data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            
            # Refresh service configuration
            version_service._config = serializer.instance
            
            return success_response(
                message="Version configuration updated successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to update version configuration: {str(e)}")
            return error_response(
                message="Failed to update version configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class VersionCleanupLogViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for version cleanup logs.
    Provides access to cleanup operation history.
    """
    
    serializer_class = VersionCleanupLogSerializer
    permission_classes = [IsAuthenticated, CanViewVersionActions]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['cleanup_reason', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Get cleanup logs for user's CV or all logs if admin."""
        if self.request.user.is_staff:
            return VersionCleanupLog.objects.all().select_related('cv_profile__student', 'triggered_by')
        
        try:
            cv_profile = self.request.user.cv_profile
            return VersionCleanupLog.objects.filter(
                cv_profile=cv_profile
            ).select_related('triggered_by')
        except CVProfile.DoesNotExist:
            return VersionCleanupLog.objects.none()
    
    def list(self, request, *args, **kwargs):
        """List cleanup logs."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Cleanup logs retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list cleanup logs: {str(e)}")
            return error_response(
                message="Failed to retrieve cleanup logs.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )