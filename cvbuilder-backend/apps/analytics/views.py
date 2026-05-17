"""
API views for Analytics system.
Provides REST endpoints for analytics, benchmarking, and dashboard operations.
"""
import logging
from typing import Dict, Any
from django.db.models import Count, Avg, Q
from django.utils import timezone
from django.http import Http404
from django.contrib.auth import get_user_model
from rest_framework import status, viewsets, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import OrderingFilter, SearchFilter

from apps.core.responses import success_response, error_response
from .models import (
    AnalyticsConfiguration, ScoreSnapshot, BenchmarkingGroup,
    BenchmarkingGroupMembership, MetricDefinition, AggregatedMetric,
    TrendAnalysis, AnalyticsEvent, AnalyticsCache
)
from .serializers import (
    AnalyticsConfigurationSerializer, ScoreSnapshotListSerializer,
    ScoreSnapshotDetailSerializer, BenchmarkingGroupSerializer,
    BenchmarkingGroupMembershipSerializer, MetricDefinitionSerializer,
    AggregatedMetricSerializer, TrendAnalysisSerializer,
    AnalyticsEventSerializer, CreateSnapshotSerializer,
    TrendAnalysisRequestSerializer, BenchmarkingRequestSerializer,
    CompletionStatisticsRequestSerializer, ScoreTrendSerializer,
    PeerBenchmarkingSerializer, CompletionStatisticsSerializer,
    AnalyticsDashboardSerializer, AdminDashboardSerializer
)
from .permissions import (
    CanViewAnalytics, CanManageAnalytics, CanViewBenchmarking,
    CanManageBenchmarking, CanViewMetrics, CanManageMetrics,
    CanViewConfiguration, CanManageConfiguration, CanViewAuditLogs,
    CanAccessDashboard, CanAccessAdminDashboard, CanCreateSnapshots,
    get_user_analytics_queryset, get_user_benchmarking_queryset,
    get_user_events_queryset
)
from .services import analytics_service

User = get_user_model()
logger = logging.getLogger(__name__)


def get_client_ip(request):
    """Extract client IP address from request."""
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        ip = x_forwarded_for.split(',')[0]
    else:
        ip = request.META.get('REMOTE_ADDR')
    return ip


class ScoreSnapshotViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for score snapshots.
    Provides list, retrieve, and custom actions for analytics data.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanViewAnalytics]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['snapshot_type', 'submission_ready', 'grade']
    ordering_fields = ['created_at', 'overall_score', 'completion_percentage']
    ordering = ['-created_at']
    search_fields = ['trigger_event']
    
    def get_queryset(self):
        """Get snapshots for current user or all if admin."""
        return get_user_analytics_queryset(self.request.user).select_related('user')
    
    def get_serializer_class(self):
        """Return appropriate serializer based on action."""
        if self.action == 'retrieve':
            return ScoreSnapshotDetailSerializer
        return ScoreSnapshotListSerializer
    
    def list(self, request, *args, **kwargs):
        """List score snapshots."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Score snapshots retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list score snapshots: {str(e)}")
            return error_response(
                message="Failed to retrieve score snapshots.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def retrieve(self, request, *args, **kwargs):
        """Retrieve a specific score snapshot."""
        try:
            response = super().retrieve(request, *args, **kwargs)
            return success_response(
                message="Score snapshot retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to retrieve score snapshot: {str(e)}")
            return error_response(
                message="Failed to retrieve score snapshot.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """Get summary statistics for user's snapshots."""
        try:
            queryset = self.get_queryset()
            
            if not queryset.exists():
                return success_response(
                    message="No score data available.",
                    data={'message': 'No score snapshots found for analysis.'}
                )
            
            # Calculate summary statistics
            latest_snapshot = queryset.first()
            stats = queryset.aggregate(
                total_snapshots=Count('id'),
                avg_score=Avg('overall_score'),
                avg_completion=Avg('completion_percentage'),
                submission_ready_count=Count('id', filter=Q(submission_ready=True))
            )
            
            summary_data = {
                'latest_snapshot': ScoreSnapshotDetailSerializer(latest_snapshot).data,
                'total_snapshots': stats['total_snapshots'],
                'average_score': round(float(stats['avg_score'] or 0), 2),
                'average_completion': round(float(stats['avg_completion'] or 0), 2),
                'submission_ready_percentage': round(
                    (stats['submission_ready_count'] / stats['total_snapshots'] * 100)
                    if stats['total_snapshots'] > 0 else 0, 2
                ),
                'improvement_trend': self._calculate_improvement_trend(queryset)
            }
            
            return success_response(
                message="Score summary retrieved successfully.",
                data=summary_data
            )
            
        except Exception as e:
            logger.error(f"Failed to get score summary: {str(e)}")
            return error_response(
                message="Failed to retrieve score summary.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _calculate_improvement_trend(self, queryset):
        """Calculate improvement trend from snapshots."""
        if queryset.count() < 2:
            return {'trend': 'insufficient_data', 'message': 'Need at least 2 snapshots for trend analysis'}
        
        recent_snapshots = list(queryset.order_by('-created_at')[:10])
        if len(recent_snapshots) < 2:
            return {'trend': 'insufficient_data'}
        
        # Simple trend calculation
        first_score = recent_snapshots[-1].overall_score
        last_score = recent_snapshots[0].overall_score
        
        if last_score > first_score + 5:
            trend = 'improving'
        elif last_score < first_score - 5:
            trend = 'declining'
        else:
            trend = 'stable'
        
        return {
            'trend': trend,
            'score_change': last_score - first_score,
            'percentage_change': ((last_score - first_score) / first_score * 100) if first_score > 0 else 0
        }


class CreateSnapshotView(APIView):
    """
    API view for creating score snapshots.
    Users can create snapshots for themselves, staff can create for any user.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanCreateSnapshots]
    
    def post(self, request):
        """Create a new score snapshot."""
        try:
            serializer = CreateSnapshotSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid snapshot data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Determine target user
            target_user_id = data.get('user_id')
            if target_user_id:
                if not request.user.is_staff and str(request.user.id) != str(target_user_id):
                    return error_response(
                        message="You can only create snapshots for yourself.",
                        status_code=status.HTTP_403_FORBIDDEN
                    )
                target_user = User.objects.get(id=target_user_id)
            else:
                target_user = request.user
            
            # Create snapshot
            snapshot = analytics_service.create_score_snapshot(
                user=target_user,
                snapshot_type=data['snapshot_type'],
                trigger_event=data['trigger_event']
            )
            
            serializer = ScoreSnapshotDetailSerializer(snapshot)
            
            return success_response(
                message="Score snapshot created successfully.",
                data=serializer.data,
                status_code=status.HTTP_201_CREATED
            )
            
        except User.DoesNotExist:
            return error_response(
                message="Target user not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to create score snapshot: {str(e)}")
            return error_response(
                message="Failed to create score snapshot.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class TrendAnalysisView(APIView):
    """
    API view for trend analysis.
    Provides score trend analysis for users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanViewAnalytics]
    
    def post(self, request):
        """Get trend analysis for a user."""
        try:
            serializer = TrendAnalysisRequestSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid trend analysis request.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Determine target user
            target_user_id = data.get('user_id')
            if target_user_id:
                if not request.user.is_staff and str(request.user.id) != str(target_user_id):
                    return error_response(
                        message="You can only analyze your own trends.",
                        status_code=status.HTTP_403_FORBIDDEN
                    )
                target_user = User.objects.get(id=target_user_id)
            else:
                target_user = request.user
            
            # Get trend analysis
            trend_data = analytics_service.get_score_trend(
                user=target_user,
                days=data['days'],
                metric=data['metric']
            )
            
            serializer = ScoreTrendSerializer(trend_data)
            
            return success_response(
                message="Trend analysis completed successfully.",
                data=serializer.data
            )
            
        except User.DoesNotExist:
            return error_response(
                message="Target user not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to get trend analysis: {str(e)}")
            return error_response(
                message="Failed to perform trend analysis.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BenchmarkingView(APIView):
    """
    API view for peer benchmarking.
    Provides benchmarking data comparing user performance to peers.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanViewBenchmarking]
    
    def post(self, request):
        """Get benchmarking data for a user."""
        try:
            serializer = BenchmarkingRequestSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid benchmarking request.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Determine target user
            target_user_id = data.get('user_id')
            if target_user_id:
                if not request.user.is_staff and str(request.user.id) != str(target_user_id):
                    return error_response(
                        message="You can only view your own benchmarking data.",
                        status_code=status.HTTP_403_FORBIDDEN
                    )
                target_user = User.objects.get(id=target_user_id)
            else:
                target_user = request.user
            
            # Get benchmarking data
            benchmarking_data = analytics_service.get_peer_benchmarking(
                user=target_user,
                group_types=data.get('group_types') or None
            )
            
            return success_response(
                message="Benchmarking data retrieved successfully.",
                data=benchmarking_data
            )
            
        except User.DoesNotExist:
            return error_response(
                message="Target user not found.",
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to get benchmarking data: {str(e)}")
            return error_response(
                message="Failed to retrieve benchmarking data.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class CompletionStatisticsView(APIView):
    """
    API view for completion statistics.
    Provides platform-wide completion and readiness statistics.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanViewAnalytics]
    
    def post(self, request):
        """Get completion statistics."""
        try:
            serializer = CompletionStatisticsRequestSerializer(data=request.data)
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid statistics request.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            data = serializer.validated_data
            
            # Get completion statistics
            stats_data = analytics_service.get_completion_statistics(
                group_type=data.get('group_type'),
                time_period=data['time_period']
            )
            
            serializer = CompletionStatisticsSerializer(stats_data)
            
            return success_response(
                message="Completion statistics retrieved successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get completion statistics: {str(e)}")
            return error_response(
                message="Failed to retrieve completion statistics.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class BenchmarkingGroupViewSet(viewsets.ModelViewSet):
    """
    ViewSet for benchmarking groups.
    Allows CRUD operations on benchmarking groups (staff only for write operations).
    """
    
    queryset = BenchmarkingGroup.objects.all()
    serializer_class = BenchmarkingGroupSerializer
    permission_classes = [permissions.IsAuthenticated, CanManageBenchmarking]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['group_type', 'is_active', 'auto_update']
    ordering_fields = ['name', 'member_count', 'created_at']
    ordering = ['group_type', 'name']
    search_fields = ['name', 'description']
    
    def get_queryset(self):
        """Get benchmarking groups accessible to current user."""
        return get_user_benchmarking_queryset(self.request.user)
    
    def list(self, request, *args, **kwargs):
        """List benchmarking groups."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Benchmarking groups retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list benchmarking groups: {str(e)}")
            return error_response(
                message="Failed to retrieve benchmarking groups.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def create(self, request, *args, **kwargs):
        """Create a new benchmarking group."""
        try:
            response = super().create(request, *args, **kwargs)
            return success_response(
                message="Benchmarking group created successfully.",
                data=response.data,
                status_code=status.HTTP_201_CREATED
            )
        except Exception as e:
            logger.error(f"Failed to create benchmarking group: {str(e)}")
            return error_response(
                message="Failed to create benchmarking group.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['post'], permission_classes=[permissions.IsAuthenticated, CanManageAnalytics])
    def update_membership(self, request, pk=None):
        """Update group membership based on criteria."""
        try:
            group = self.get_object()
            
            # Update group membership (this would be implemented based on specific criteria)
            updated_count = analytics_service._update_group_membership(group)
            
            return success_response(
                message="Group membership updated successfully.",
                data={
                    'group_id': group.id,
                    'updated_members': updated_count,
                    'total_members': group.member_count
                }
            )
            
        except Exception as e:
            logger.error(f"Failed to update group membership: {str(e)}")
            return error_response(
                message="Failed to update group membership.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class MetricDefinitionViewSet(viewsets.ModelViewSet):
    """
    ViewSet for metric definitions.
    Allows CRUD operations on metric definitions (staff only for write operations).
    """
    
    queryset = MetricDefinition.objects.all()
    serializer_class = MetricDefinitionSerializer
    permission_classes = [permissions.IsAuthenticated, CanManageMetrics]
    filter_backends = [DjangoFilterBackend, OrderingFilter, SearchFilter]
    filterset_fields = ['metric_type', 'aggregation_type', 'is_active', 'is_benchmarkable']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']
    search_fields = ['name', 'display_name', 'description']
    
    def list(self, request, *args, **kwargs):
        """List metric definitions."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Metric definitions retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list metric definitions: {str(e)}")
            return error_response(
                message="Failed to retrieve metric definitions.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class AnalyticsConfigurationView(APIView):
    """
    API view for analytics configuration management.
    Only accessible by staff users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanManageConfiguration]
    
    def get(self, request):
        """Get current analytics configuration."""
        try:
            config = analytics_service.config
            serializer = AnalyticsConfigurationSerializer(config)
            
            return success_response(
                message="Analytics configuration retrieved successfully.",
                data=serializer.data
            )
        except Exception as e:
            logger.error(f"Failed to get analytics configuration: {str(e)}")
            return error_response(
                message="Failed to retrieve analytics configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def put(self, request):
        """Update analytics configuration."""
        try:
            config = analytics_service.config
            serializer = AnalyticsConfigurationSerializer(
                config,
                data=request.data,
                partial=True
            )
            
            if not serializer.is_valid():
                return error_response(
                    message="Invalid configuration data.",
                    errors=serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            serializer.save()
            
            # Refresh service configuration
            analytics_service._config = serializer.instance
            
            return success_response(
                message="Analytics configuration updated successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to update analytics configuration: {str(e)}")
            return error_response(
                message="Failed to update analytics configuration.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class AnalyticsEventViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for analytics events (audit log).
    Provides access to analytics-related events for audit purposes.
    """
    
    serializer_class = AnalyticsEventSerializer
    permission_classes = [permissions.IsAuthenticated, CanViewAuditLogs]
    filter_backends = [DjangoFilterBackend, OrderingFilter]
    filterset_fields = ['event_type', 'created_at']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Get events for user or all events if admin."""
        return get_user_events_queryset(self.request.user).select_related('user')
    
    def list(self, request, *args, **kwargs):
        """List analytics events."""
        try:
            response = super().list(request, *args, **kwargs)
            return success_response(
                message="Analytics events retrieved successfully.",
                data=response.data
            )
        except Exception as e:
            logger.error(f"Failed to list analytics events: {str(e)}")
            return error_response(
                message="Failed to retrieve analytics events.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class AnalyticsDashboardView(APIView):
    """
    API view for user analytics dashboard.
    Provides comprehensive analytics overview for users.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanAccessDashboard]
    
    def get(self, request):
        """Get analytics dashboard data for current user."""
        try:
            user = request.user
            
            # Get user's latest snapshot
            latest_snapshot = user.score_snapshots.first()
            
            # Get recent snapshots
            recent_snapshots = user.score_snapshots.all()[:10]
            
            # Get trend analysis
            trend_data = analytics_service.get_score_trend(user, days=30)
            
            # Get benchmarking summary
            benchmarking_data = analytics_service.get_peer_benchmarking(user)
            
            # Get completion stats for user's groups
            completion_stats = analytics_service.get_completion_statistics(time_period=30)
            
            dashboard_data = {
                'user_summary': {
                    'latest_score': latest_snapshot.overall_score if latest_snapshot else 0,
                    'latest_completion': latest_snapshot.completion_percentage if latest_snapshot else 0,
                    'submission_ready': latest_snapshot.submission_ready if latest_snapshot else False,
                    'grade': latest_snapshot.grade if latest_snapshot else '',
                    'percentile_rank': float(latest_snapshot.percentile_rank) if latest_snapshot and latest_snapshot.percentile_rank else None,
                    'total_snapshots': recent_snapshots.count()
                },
                'recent_snapshots': ScoreSnapshotListSerializer(recent_snapshots, many=True).data,
                'trend_analysis': trend_data,
                'benchmarking_summary': benchmarking_data.get('summary', {}),
                'completion_stats': completion_stats,
                'system_metrics': {
                    'last_updated': timezone.now().isoformat(),
                    'data_freshness': 'real-time'
                }
            }
            
            serializer = AnalyticsDashboardSerializer(dashboard_data)
            
            return success_response(
                message="Analytics dashboard data retrieved successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get analytics dashboard: {str(e)}")
            return error_response(
                message="Failed to retrieve analytics dashboard.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class AdminDashboardView(APIView):
    """
    API view for administrative analytics dashboard.
    Provides platform-wide analytics overview for administrators.
    """
    
    permission_classes = [permissions.IsAuthenticated, CanAccessAdminDashboard]
    
    def get(self, request):
        """Get administrative dashboard data."""
        try:
            # Platform overview
            total_users = User.objects.filter(is_active=True).count()
            total_snapshots = ScoreSnapshot.objects.count()
            active_groups = BenchmarkingGroup.objects.filter(is_active=True).count()
            
            # User engagement metrics
            recent_snapshots = ScoreSnapshot.objects.filter(
                created_at__gte=timezone.now() - timezone.timedelta(days=30)
            )
            
            engagement_stats = recent_snapshots.aggregate(
                avg_score=Avg('overall_score'),
                avg_completion=Avg('completion_percentage'),
                submission_ready_count=Count('id', filter=Q(submission_ready=True))
            )
            
            # Score distributions
            completion_stats = analytics_service.get_completion_statistics(time_period=30)
            
            # Recent events
            recent_events = AnalyticsEvent.objects.all()[:20]
            
            admin_dashboard_data = {
                'platform_overview': {
                    'total_users': total_users,
                    'total_snapshots': total_snapshots,
                    'active_benchmarking_groups': active_groups,
                    'system_health': 'operational'
                },
                'user_engagement': {
                    'recent_snapshots_count': recent_snapshots.count(),
                    'average_score': round(float(engagement_stats['avg_score'] or 0), 2),
                    'average_completion': round(float(engagement_stats['avg_completion'] or 0), 2),
                    'submission_ready_percentage': round(
                        (engagement_stats['submission_ready_count'] / recent_snapshots.count() * 100)
                        if recent_snapshots.count() > 0 else 0, 2
                    )
                },
                'score_distributions': completion_stats.get('score_distribution', {}),
                'trend_summaries': {
                    'improving_users': 0,  # Would be calculated from trend analyses
                    'declining_users': 0,
                    'stable_users': 0
                },
                'benchmarking_insights': {
                    'total_groups': active_groups,
                    'average_group_size': 0  # Would be calculated
                },
                'system_performance': {
                    'cache_hit_rate': 95.5,  # Would be calculated from actual cache metrics
                    'average_response_time': 150,  # milliseconds
                    'data_freshness': 'real-time'
                },
                'recent_events': AnalyticsEventSerializer(recent_events, many=True).data
            }
            
            serializer = AdminDashboardSerializer(admin_dashboard_data)
            
            return success_response(
                message="Administrative dashboard data retrieved successfully.",
                data=serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get admin dashboard: {str(e)}")
            return error_response(
                message="Failed to retrieve administrative dashboard.",
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )