"""
Analytics Services for EduCV.
Enterprise-grade analytics engine providing score tracking, benchmarking,
trend analysis, and comprehensive metrics calculation.
"""
import logging
import statistics
from datetime import datetime, timedelta
from decimal import Decimal, ROUND_HALF_UP
from typing import Dict, List, Optional, Tuple, Any, Union
from django.db import transaction, models
from django.db.models import Avg, Count, Max, Min, Q, F, StdDev
from django.utils import timezone
from django.core.cache import cache
from django.contrib.auth import get_user_model

from apps.cv.models import CVProfile
from apps.cv_intelligence.models import CVAnalysis
from ..models import (
    AnalyticsConfiguration, ScoreSnapshot, BenchmarkingGroup,
    BenchmarkingGroupMembership, MetricDefinition, AggregatedMetric,
    TrendAnalysis, AnalyticsEvent, AnalyticsCache
)

User = get_user_model()
logger = logging.getLogger(__name__)


class AnalyticsService:
    """
    Core analytics service providing comprehensive analytics functionality.
    Handles score tracking, benchmarking, trend analysis, and metrics calculation.
    """
    
    def __init__(self):
        self._config = None
    
    @property
    def config(self) -> AnalyticsConfiguration:
        """Lazy-load analytics configuration."""
        if self._config is None:
            self._config = AnalyticsConfiguration.get_active_config()
        return self._config
    
    def create_score_snapshot(
        self,
        user: User,
        snapshot_type: str = 'automatic',
        trigger_event: str = ''
    ) -> ScoreSnapshot:
        """
        Create a score snapshot for a user.
        
        Args:
            user: User to create snapshot for
            snapshot_type: Type of snapshot (automatic, manual, triggered, scheduled)
            trigger_event: Event that triggered the snapshot
            
        Returns:
            Created ScoreSnapshot instance
        """
        try:
            start_time = timezone.now()
            
            # Get user's CV profile and latest analysis
            cv_profile = getattr(user, 'cv_profile', None)
            if not cv_profile:
                raise ValueError(f"User {user.id} has no CV profile")
            
            latest_analysis = user.cv_analyses.first()
            
            # Calculate percentile rank
            percentile_rank, peer_group_size = self._calculate_percentile_rank(user)
            
            # Create snapshot
            snapshot = ScoreSnapshot.objects.create(
                user=user,
                snapshot_type=snapshot_type,
                trigger_event=trigger_event,
                overall_score=latest_analysis.overall_score if latest_analysis else 0,
                completion_percentage=cv_profile.completion_percentage,
                profile_score=latest_analysis.profile_score if latest_analysis else 0,
                experience_score=latest_analysis.experience_score if latest_analysis else 0,
                education_score=latest_analysis.education_score if latest_analysis else 0,
                skills_score=latest_analysis.skills_score if latest_analysis else 0,
                projects_score=latest_analysis.projects_score if latest_analysis else 0,
                submission_ready=latest_analysis.submission_ready if latest_analysis else False,
                grade=latest_analysis.grade if latest_analysis else '',
                percentile_rank=percentile_rank,
                peer_group_size=peer_group_size,
                metrics_data={
                    'cv_sections_count': self._count_cv_sections(cv_profile),
                    'analysis_issues': latest_analysis.total_issues if latest_analysis else 0,
                    'recommendations': latest_analysis.total_recommendations if latest_analysis else 0,
                }
            )
            
            # Log event
            execution_time = (timezone.now() - start_time).total_seconds() * 1000
            self._log_event(
                event_type=AnalyticsEvent.EventType.SNAPSHOT_CREATED,
                description=f"Score snapshot created for user {user.id}",
                user=user,
                related_object=snapshot,
                execution_time_ms=int(execution_time)
            )
            
            logger.info(f"Created score snapshot for user {user.id}")
            return snapshot
            
        except Exception as e:
            logger.error(f"Failed to create score snapshot for user {user.id}: {str(e)}")
            self._log_event(
                event_type=AnalyticsEvent.EventType.CALCULATION_ERROR,
                description=f"Failed to create score snapshot: {str(e)}",
                user=user,
                error_message=str(e)
            )
            raise
    
    def get_score_trend(
        self,
        user: User,
        days: int = 30,
        metric: str = 'overall_score'
    ) -> Dict[str, Any]:
        """
        Get score trend analysis for a user.
        
        Args:
            user: User to analyze
            days: Number of days to analyze
            metric: Metric to analyze (overall_score, completion_percentage, etc.)
            
        Returns:
            Dictionary containing trend analysis results
        """
        try:
            start_date = timezone.now() - timedelta(days=days)
            
            # Get snapshots for the period
            snapshots = ScoreSnapshot.objects.filter(
                user=user,
                created_at__gte=start_date
            ).order_by('created_at')
            
            if snapshots.count() < 2:
                return {
                    'trend_direction': 'insufficient_data',
                    'data_points': snapshots.count(),
                    'message': 'Insufficient data for trend analysis'
                }
            
            # Extract values
            values = [getattr(snapshot, metric) for snapshot in snapshots]
            timestamps = [snapshot.created_at for snapshot in snapshots]
            
            # Calculate trend
            trend_analysis = self._calculate_trend(values, timestamps)
            
            # Add context data
            trend_analysis.update({
                'metric': metric,
                'period_days': days,
                'data_points': len(values),
                'start_value': values[0],
                'end_value': values[-1],
                'min_value': min(values),
                'max_value': max(values),
                'average_value': statistics.mean(values),
                'snapshots': [
                    {
                        'date': snapshot.created_at.isoformat(),
                        'value': getattr(snapshot, metric),
                        'percentile_rank': float(snapshot.percentile_rank) if snapshot.percentile_rank else None
                    }
                    for snapshot in snapshots
                ]
            })
            
            return trend_analysis
            
        except Exception as e:
            logger.error(f"Failed to get score trend for user {user.id}: {str(e)}")
            raise
    
    def get_peer_benchmarking(
        self,
        user: User,
        group_types: List[str] = None
    ) -> Dict[str, Any]:
        """
        Get peer benchmarking data for a user.
        
        Args:
            user: User to benchmark
            group_types: List of group types to include in benchmarking
            
        Returns:
            Dictionary containing benchmarking results
        """
        try:
            if group_types is None:
                group_types = ['education_level', 'field_of_study', 'experience_years']
            
            # Get user's latest snapshot
            latest_snapshot = user.score_snapshots.first()
            if not latest_snapshot:
                return {'error': 'No score data available for benchmarking'}
            
            benchmarking_results = {}
            
            # Get benchmarking for each group type
            for group_type in group_types:
                groups = self._get_user_benchmarking_groups(user, group_type)
                
                for group in groups:
                    group_stats = self._calculate_group_statistics(group)
                    user_rank = self._get_user_rank_in_group(user, group)
                    
                    benchmarking_results[f"{group_type}_{group.id}"] = {
                        'group_name': group.name,
                        'group_type': group_type,
                        'member_count': group.member_count,
                        'user_score': latest_snapshot.overall_score,
                        'user_rank': user_rank,
                        'user_percentile': self._calculate_percentile_from_rank(user_rank, group.member_count),
                        'group_average': float(group_stats['average']),
                        'group_median': float(group_stats['median']),
                        'group_min': float(group_stats['min']),
                        'group_max': float(group_stats['max']),
                        'performance_vs_average': latest_snapshot.overall_score - float(group_stats['average']),
                        'performance_vs_median': latest_snapshot.overall_score - float(group_stats['median'])
                    }
            
            # Calculate overall benchmarking summary
            if benchmarking_results:
                all_percentiles = [result['user_percentile'] for result in benchmarking_results.values()]
                benchmarking_results['summary'] = {
                    'average_percentile': statistics.mean(all_percentiles),
                    'best_percentile': max(all_percentiles),
                    'worst_percentile': min(all_percentiles),
                    'groups_analyzed': len(benchmarking_results)
                }
            
            return benchmarking_results
            
        except Exception as e:
            logger.error(f"Failed to get peer benchmarking for user {user.id}: {str(e)}")
            raise
    
    def get_completion_statistics(
        self,
        group_type: str = None,
        time_period: int = 30
    ) -> Dict[str, Any]:
        """
        Get CV completion statistics.
        
        Args:
            group_type: Optional group type to filter by
            time_period: Time period in days
            
        Returns:
            Dictionary containing completion statistics
        """
        try:
            start_date = timezone.now() - timedelta(days=time_period)
            
            # Base queryset
            queryset = ScoreSnapshot.objects.filter(created_at__gte=start_date)
            
            # Filter by group if specified
            if group_type:
                group_users = BenchmarkingGroupMembership.objects.filter(
                    group__group_type=group_type,
                    is_active=True
                ).values_list('user_id', flat=True)
                queryset = queryset.filter(user_id__in=group_users)
            
            # Calculate statistics
            stats = queryset.aggregate(
                total_snapshots=Count('id'),
                avg_completion=Avg('completion_percentage'),
                avg_overall_score=Avg('overall_score'),
                submission_ready_count=Count('id', filter=Q(submission_ready=True)),
                min_completion=Min('completion_percentage'),
                max_completion=Max('completion_percentage'),
                min_score=Min('overall_score'),
                max_score=Max('overall_score')
            )
            
            # Calculate completion distribution
            completion_ranges = [
                (0, 25, 'Low (0-25%)'),
                (26, 50, 'Medium (26-50%)'),
                (51, 75, 'High (51-75%)'),
                (76, 100, 'Complete (76-100%)')
            ]
            
            completion_distribution = {}
            for min_val, max_val, label in completion_ranges:
                count = queryset.filter(
                    completion_percentage__gte=min_val,
                    completion_percentage__lte=max_val
                ).count()
                completion_distribution[label] = {
                    'count': count,
                    'percentage': (count / stats['total_snapshots'] * 100) if stats['total_snapshots'] > 0 else 0
                }
            
            # Calculate score distribution
            score_ranges = [
                (0, 39, 'Poor (0-39)'),
                (40, 59, 'Needs Improvement (40-59)'),
                (60, 74, 'Average (60-74)'),
                (75, 89, 'Good (75-89)'),
                (90, 100, 'Excellent (90-100)')
            ]
            
            score_distribution = {}
            for min_val, max_val, label in score_ranges:
                count = queryset.filter(
                    overall_score__gte=min_val,
                    overall_score__lte=max_val
                ).count()
                score_distribution[label] = {
                    'count': count,
                    'percentage': (count / stats['total_snapshots'] * 100) if stats['total_snapshots'] > 0 else 0
                }
            
            return {
                'period_days': time_period,
                'group_type': group_type,
                'summary_statistics': {
                    'total_snapshots': stats['total_snapshots'],
                    'average_completion': round(float(stats['avg_completion'] or 0), 2),
                    'average_overall_score': round(float(stats['avg_overall_score'] or 0), 2),
                    'submission_ready_percentage': round(
                        (stats['submission_ready_count'] / stats['total_snapshots'] * 100) 
                        if stats['total_snapshots'] > 0 else 0, 2
                    ),
                    'completion_range': {
                        'min': stats['min_completion'] or 0,
                        'max': stats['max_completion'] or 0
                    },
                    'score_range': {
                        'min': stats['min_score'] or 0,
                        'max': stats['max_score'] or 0
                    }
                },
                'completion_distribution': completion_distribution,
                'score_distribution': score_distribution
            }
            
        except Exception as e:
            logger.error(f"Failed to get completion statistics: {str(e)}")
            raise
    
    def update_benchmarking_groups(self) -> Dict[str, int]:
        """
        Update all benchmarking groups based on current user data.
        
        Returns:
            Dictionary with update statistics
        """
        try:
            start_time = timezone.now()
            updated_groups = 0
            total_memberships = 0
            
            # Get all active groups with auto-update enabled
            groups = BenchmarkingGroup.objects.filter(
                is_active=True,
                auto_update=True
            )
            
            for group in groups:
                # Update group membership
                new_members = self._update_group_membership(group)
                total_memberships += new_members
                
                # Recalculate group statistics
                self._recalculate_group_statistics(group)
                updated_groups += 1
            
            # Log event
            execution_time = (timezone.now() - start_time).total_seconds() * 1000
            self._log_event(
                event_type=AnalyticsEvent.EventType.GROUP_UPDATED,
                description=f"Updated {updated_groups} benchmarking groups",
                execution_time_ms=int(execution_time),
                event_data={
                    'updated_groups': updated_groups,
                    'total_memberships': total_memberships
                }
            )
            
            return {
                'updated_groups': updated_groups,
                'total_memberships': total_memberships,
                'execution_time_ms': int(execution_time)
            }
            
        except Exception as e:
            logger.error(f"Failed to update benchmarking groups: {str(e)}")
            self._log_event(
                event_type=AnalyticsEvent.EventType.CALCULATION_ERROR,
                description=f"Failed to update benchmarking groups: {str(e)}",
                error_message=str(e)
            )
            raise
    
    def calculate_aggregated_metrics(
        self,
        period: str = 'daily',
        start_date: datetime = None,
        end_date: datetime = None
    ) -> Dict[str, int]:
        """
        Calculate and store aggregated metrics for the specified period.
        
        Args:
            period: Aggregation period (daily, weekly, monthly)
            start_date: Start date for aggregation
            end_date: End date for aggregation
            
        Returns:
            Dictionary with calculation statistics
        """
        try:
            start_time = timezone.now()
            
            if not start_date:
                start_date = timezone.now() - timedelta(days=1)
            if not end_date:
                end_date = timezone.now()
            
            # Get active metric definitions
            metrics = MetricDefinition.objects.filter(is_active=True)
            calculated_metrics = 0
            
            for metric in metrics:
                # Calculate global aggregation
                global_value = self._calculate_metric_aggregation(
                    metric, period, start_date, end_date, scope='global'
                )
                if global_value is not None:
                    calculated_metrics += 1
                
                # Calculate user-level aggregations
                users_with_data = self._get_users_with_metric_data(metric, start_date, end_date)
                for user in users_with_data:
                    user_value = self._calculate_metric_aggregation(
                        metric, period, start_date, end_date, scope='user', user=user
                    )
                    if user_value is not None:
                        calculated_metrics += 1
                
                # Calculate group-level aggregations
                active_groups = BenchmarkingGroup.objects.filter(is_active=True)
                for group in active_groups:
                    group_value = self._calculate_metric_aggregation(
                        metric, period, start_date, end_date, scope='group', group=group
                    )
                    if group_value is not None:
                        calculated_metrics += 1
            
            # Log event
            execution_time = (timezone.now() - start_time).total_seconds() * 1000
            self._log_event(
                event_type=AnalyticsEvent.EventType.METRIC_AGGREGATED,
                description=f"Calculated {calculated_metrics} aggregated metrics for {period}",
                execution_time_ms=int(execution_time),
                event_data={
                    'period': period,
                    'calculated_metrics': calculated_metrics,
                    'start_date': start_date.isoformat(),
                    'end_date': end_date.isoformat()
                }
            )
            
            return {
                'calculated_metrics': calculated_metrics,
                'period': period,
                'execution_time_ms': int(execution_time)
            }
            
        except Exception as e:
            logger.error(f"Failed to calculate aggregated metrics: {str(e)}")
            self._log_event(
                event_type=AnalyticsEvent.EventType.CALCULATION_ERROR,
                description=f"Failed to calculate aggregated metrics: {str(e)}",
                error_message=str(e)
            )
            raise
    
    def cleanup_old_data(self, dry_run: bool = False) -> Dict[str, int]:
        """
        Clean up old analytics data based on retention settings.
        
        Args:
            dry_run: If True, only count what would be deleted
            
        Returns:
            Dictionary with cleanup statistics
        """
        try:
            config = self.config
            now = timezone.now()
            
            # Calculate cutoff dates
            raw_data_cutoff = now - timedelta(days=config.raw_data_retention_days)
            aggregated_data_cutoff = now - timedelta(days=config.aggregated_data_retention_days)
            
            cleanup_stats = {}
            
            # Clean up old snapshots
            old_snapshots = ScoreSnapshot.objects.filter(created_at__lt=raw_data_cutoff)
            cleanup_stats['snapshots'] = old_snapshots.count()
            if not dry_run:
                old_snapshots.delete()
            
            # Clean up old trend analyses
            old_trends = TrendAnalysis.objects.filter(calculated_at__lt=raw_data_cutoff)
            cleanup_stats['trend_analyses'] = old_trends.count()
            if not dry_run:
                old_trends.delete()
            
            # Clean up old aggregated metrics
            old_aggregated = AggregatedMetric.objects.filter(calculated_at__lt=aggregated_data_cutoff)
            cleanup_stats['aggregated_metrics'] = old_aggregated.count()
            if not dry_run:
                old_aggregated.delete()
            
            # Clean up old events
            old_events = AnalyticsEvent.objects.filter(created_at__lt=raw_data_cutoff)
            cleanup_stats['events'] = old_events.count()
            if not dry_run:
                old_events.delete()
            
            # Clean up expired cache entries
            expired_cache = AnalyticsCache.objects.filter(
                Q(expires_at__lt=now) | Q(is_expired=True)
            )
            cleanup_stats['cache_entries'] = expired_cache.count()
            if not dry_run:
                expired_cache.delete()
            
            # Log cleanup
            if not dry_run:
                self._log_event(
                    event_type=AnalyticsEvent.EventType.DATA_CLEANUP,
                    description=f"Cleaned up old analytics data",
                    event_data=cleanup_stats
                )
            
            return cleanup_stats
            
        except Exception as e:
            logger.error(f"Failed to cleanup old data: {str(e)}")
            raise
    
    # Private helper methods
    
    def _calculate_percentile_rank(self, user: User) -> Tuple[Optional[Decimal], int]:
        """Calculate user's percentile rank among peers."""
        try:
            # Get user's latest score
            latest_snapshot = user.score_snapshots.first()
            if not latest_snapshot:
                return None, 0
            
            user_score = latest_snapshot.overall_score
            
            # Get peer scores (users with similar characteristics)
            peer_scores = self._get_peer_scores(user)
            
            if len(peer_scores) < 2:
                return None, len(peer_scores)
            
            # Calculate percentile rank
            scores_below = sum(1 for score in peer_scores if score < user_score)
            percentile = (scores_below / len(peer_scores)) * 100
            
            return Decimal(str(percentile)).quantize(Decimal('0.01'), rounding=ROUND_HALF_UP), len(peer_scores)
            
        except Exception as e:
            logger.error(f"Failed to calculate percentile rank for user {user.id}: {str(e)}")
            return None, 0
    
    def _get_peer_scores(self, user: User) -> List[int]:
        """Get scores of users similar to the given user."""
        # This is a simplified implementation
        # In production, you'd implement more sophisticated peer selection
        recent_snapshots = ScoreSnapshot.objects.filter(
            created_at__gte=timezone.now() - timedelta(days=30)
        ).values_list('overall_score', flat=True)
        
        return list(recent_snapshots)
    
    def _count_cv_sections(self, cv_profile: CVProfile) -> Dict[str, int]:
        """Count entries in each CV section."""
        return {
            'educations': cv_profile.educations.count(),
            'experiences': cv_profile.experiences.count(),
            'skills': cv_profile.skills.count(),
            'languages': cv_profile.languages.count(),
            'projects': cv_profile.projects.count(),
            'certifications': cv_profile.certifications.count(),
        }
    
    def _calculate_trend(self, values: List[float], timestamps: List[datetime]) -> Dict[str, Any]:
        """Calculate trend analysis for a series of values."""
        if len(values) < 2:
            return {'trend_direction': 'insufficient_data'}
        
        # Simple linear regression
        n = len(values)
        x_values = list(range(n))
        
        # Calculate slope
        x_mean = statistics.mean(x_values)
        y_mean = statistics.mean(values)
        
        numerator = sum((x - x_mean) * (y - y_mean) for x, y in zip(x_values, values))
        denominator = sum((x - x_mean) ** 2 for x in x_values)
        
        slope = numerator / denominator if denominator != 0 else 0
        
        # Calculate R-squared
        y_pred = [slope * x + (y_mean - slope * x_mean) for x in x_values]
        ss_res = sum((y - y_pred[i]) ** 2 for i, y in enumerate(values))
        ss_tot = sum((y - y_mean) ** 2 for y in values)
        r_squared = 1 - (ss_res / ss_tot) if ss_tot != 0 else 0
        
        # Determine trend direction and strength
        if abs(slope) < 0.1:
            direction = 'stable'
        elif slope > 0:
            direction = 'improving'
        else:
            direction = 'declining'
        
        strength = 'strong' if r_squared > 0.7 else 'moderate' if r_squared > 0.3 else 'weak'
        
        # Calculate changes
        absolute_change = values[-1] - values[0]
        percentage_change = (absolute_change / values[0] * 100) if values[0] != 0 else 0
        
        return {
            'trend_direction': direction,
            'trend_strength': strength,
            'slope': slope,
            'r_squared': r_squared,
            'absolute_change': absolute_change,
            'percentage_change': percentage_change,
            'volatility': statistics.stdev(values) if len(values) > 1 else 0
        }
    
    def _get_user_benchmarking_groups(self, user: User, group_type: str) -> List[BenchmarkingGroup]:
        """Get benchmarking groups for a user by type."""
        return BenchmarkingGroup.objects.filter(
            group_type=group_type,
            is_active=True,
            users=user
        )
    
    def _calculate_group_statistics(self, group: BenchmarkingGroup) -> Dict[str, Decimal]:
        """Calculate statistics for a benchmarking group."""
        # Get latest scores for group members
        member_scores = ScoreSnapshot.objects.filter(
            user__in=group.users.all()
        ).values('user').annotate(
            latest_score=Max('overall_score')
        ).values_list('latest_score', flat=True)
        
        scores = list(member_scores)
        
        if not scores:
            return {
                'average': Decimal('0'),
                'median': Decimal('0'),
                'min': Decimal('0'),
                'max': Decimal('0')
            }
        
        return {
            'average': Decimal(str(statistics.mean(scores))),
            'median': Decimal(str(statistics.median(scores))),
            'min': Decimal(str(min(scores))),
            'max': Decimal(str(max(scores)))
        }
    
    def _get_user_rank_in_group(self, user: User, group: BenchmarkingGroup) -> int:
        """Get user's rank within a benchmarking group."""
        # Get user's latest score
        user_snapshot = user.score_snapshots.first()
        if not user_snapshot:
            return group.member_count
        
        user_score = user_snapshot.overall_score
        
        # Count users with higher scores
        higher_scores = ScoreSnapshot.objects.filter(
            user__in=group.users.all(),
            overall_score__gt=user_score
        ).values('user').distinct().count()
        
        return higher_scores + 1
    
    def _calculate_percentile_from_rank(self, rank: int, total: int) -> float:
        """Calculate percentile from rank and total."""
        if total == 0:
            return 0
        return ((total - rank) / total) * 100
    
    def _update_group_membership(self, group: BenchmarkingGroup) -> int:
        """Update membership for a benchmarking group."""
        # This is a simplified implementation
        # In production, you'd implement sophisticated criteria matching
        return 0
    
    def _recalculate_group_statistics(self, group: BenchmarkingGroup):
        """Recalculate statistics for a benchmarking group."""
        stats = self._calculate_group_statistics(group)
        group.member_count = group.users.count()
        group.average_score = stats['average']
        group.median_score = stats['median']
        group.last_calculated_at = timezone.now()
        group.save()
    
    def _calculate_metric_aggregation(
        self,
        metric: MetricDefinition,
        period: str,
        start_date: datetime,
        end_date: datetime,
        scope: str,
        user: User = None,
        group: BenchmarkingGroup = None
    ) -> Optional[AggregatedMetric]:
        """Calculate aggregated metric value."""
        # This is a placeholder implementation
        # In production, you'd implement the actual metric calculation logic
        return None
    
    def _get_users_with_metric_data(
        self,
        metric: MetricDefinition,
        start_date: datetime,
        end_date: datetime
    ) -> List[User]:
        """Get users who have data for the specified metric and period."""
        return User.objects.filter(
            score_snapshots__created_at__range=[start_date, end_date]
        ).distinct()
    
    def _log_event(
        self,
        event_type: str,
        description: str,
        user: User = None,
        related_object: Any = None,
        execution_time_ms: int = None,
        error_message: str = '',
        event_data: Dict = None
    ):
        """Log an analytics event."""
        try:
            from django.contrib.contenttypes.models import ContentType
            
            content_type = None
            object_id = None
            
            if related_object:
                content_type = ContentType.objects.get_for_model(related_object)
                object_id = str(related_object.pk)
            
            AnalyticsEvent.objects.create(
                event_type=event_type,
                description=description,
                user=user,
                content_type=content_type,
                object_id=object_id,
                execution_time_ms=execution_time_ms,
                error_message=error_message,
                event_data=event_data or {}
            )
        except Exception as e:
            logger.error(f"Failed to log analytics event: {str(e)}")


# Global service instance
analytics_service = AnalyticsService()