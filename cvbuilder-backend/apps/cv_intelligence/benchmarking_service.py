"""
CV Benchmarking Service - Production-ready peer comparison and ranking system.
Calculates percentile rankings, performance levels, and generates insights.
"""
import logging
from typing import Dict, List, Optional, Tuple
from django.db.models import Avg, Max, Min, Count, Q, OuterRef
from django.db import models
from django.core.cache import cache
from django.utils import timezone
from datetime import timedelta

from apps.users.models import User
from .models import CVAnalysisHistory

logger = logging.getLogger(__name__)


class CVBenchmarkingService:
    """
    Service for calculating CV benchmarking data and peer comparisons.
    Provides percentile rankings, performance insights, and comparative analytics.
    """
    
    # Cache timeout for benchmark calculations (1 hour)
    CACHE_TIMEOUT = 3600
    
    # Performance level thresholds
    PERFORMANCE_LEVELS = {
        'excellent': (90, 100),
        'strong': (75, 89),
        'average': (60, 74),
        'needs_improvement': (40, 59),
        'poor': (0, 39),
    }
    
    def __init__(self):
        self.cache_prefix = 'cv_benchmark'
    
    def get_user_benchmarking_data(
        self, 
        user: User, 
        comparison_group: Optional[str] = None
    ) -> Dict:
        """
        Get comprehensive benchmarking data for a user.
        
        Args:
            user: User to benchmark
            comparison_group: Optional group filter ('faculty', 'major', 'year', 'experience')
        
        Returns:
            Dictionary containing all benchmarking metrics
        """
        try:
            # Get user's latest analysis
            user_analysis = self._get_latest_user_analysis(user)
            if not user_analysis:
                return self._get_empty_benchmark_data()
            
            # Generate cache key
            cache_key = self._generate_cache_key(user.id, comparison_group)
            
            # Try to get from cache first
            cached_data = cache.get(cache_key)
            if cached_data:
                # SECURITY: Don't log user email, use user ID instead
                logger.info(f'Returning cached benchmark data for user {user.id}')
                return cached_data
            
            # Calculate benchmark data
            benchmark_data = self._calculate_benchmark_data(user, user_analysis, comparison_group)
            
            # Cache the results
            cache.set(cache_key, benchmark_data, self.CACHE_TIMEOUT)
            
            # SECURITY: Don't log user email, use user ID instead
            logger.info(f'Calculated benchmark data for user {user.id} - Rank: {benchmark_data["user_rank"]}/{benchmark_data["total_participants"]}')
            
            return benchmark_data
            
        except Exception as e:
            # SECURITY: Don't log user email, use user ID instead
            logger.error(f'Failed to calculate benchmark data for user {user.id}: {str(e)}')
            return self._get_empty_benchmark_data()
    
    def _get_latest_user_analysis(self, user: User) -> Optional[CVAnalysisHistory]:
        """Get the user's most recent CV analysis."""
        return CVAnalysisHistory.objects.filter(user=user).first()
    
    def _calculate_benchmark_data(
        self, 
        user: User, 
        user_analysis: CVAnalysisHistory, 
        comparison_group: Optional[str]
    ) -> Dict:
        """Calculate all benchmarking metrics for a user."""
        
        # Get comparison dataset
        comparison_queryset = self._get_comparison_queryset(user, comparison_group)
        
        # Calculate basic statistics
        stats = self._calculate_basic_statistics(comparison_queryset)
        
        # Calculate user's rank and percentile
        user_score = float(user_analysis.overall_score)
        rank_data = self._calculate_user_rank(user_score, comparison_queryset)
        
        # Calculate performance level
        performance_level = self._get_performance_level(user_score)
        
        # Generate insights
        insights = self._generate_benchmark_insights(
            user_score, stats, rank_data, performance_level
        )
        
        # Calculate section percentiles
        section_percentiles = self._calculate_section_percentiles(
            user_analysis, comparison_queryset
        )
        
        return {
            'user_id': str(user.id),
            'current_score': user_score,
            'percentile_rank': rank_data['percentile_rank'],
            'user_rank': rank_data['user_rank'],
            'total_participants': stats['total_participants'],
            'average_score': stats['average_score'],
            'top_score': stats['top_score'],
            'bottom_score': stats['bottom_score'],
            'score_gap_to_average': user_score - stats['average_score'],
            'score_gap_to_top': stats['top_score'] - user_score,
            'performance_level': performance_level,
            'benchmark_insights': insights,
            'section_percentiles': section_percentiles,
            'comparison_group': comparison_group or 'all_students',
            'last_updated': timezone.now().isoformat(),
            'statistics': {
                'median_score': stats['median_score'],
                'std_deviation': stats['std_deviation'],
                'score_distribution': stats['score_distribution'],
            }
        }
    
    def _get_comparison_queryset(self, user: User, comparison_group: Optional[str]):
        """Get the queryset for comparison based on grouping criteria."""
        
        # Get the latest analysis per user using a more MySQL-compatible approach
        from django.db.models import Max
        
        # First, get the latest created_at timestamp for each user
        latest_analyses = CVAnalysisHistory.objects.values('user').annotate(
            latest_created=Max('created_at')
        )
        
        # Build a list of (user_id, latest_created) tuples
        latest_conditions = []
        for item in latest_analyses:
            latest_conditions.append(
                Q(user=item['user']) & Q(created_at=item['latest_created'])
            )
        
        if not latest_conditions:
            return CVAnalysisHistory.objects.none()
        
        # Combine all conditions with OR
        combined_condition = latest_conditions[0]
        for condition in latest_conditions[1:]:
            combined_condition |= condition
        
        # Base queryset with latest analysis per user
        base_queryset = CVAnalysisHistory.objects.select_related('user').filter(
            combined_condition
        )
        
        # Apply grouping filters if specified and data is available
        if comparison_group and hasattr(user, 'profile'):
            profile = user.profile
            
            if comparison_group == 'faculty' and hasattr(profile, 'faculty'):
                base_queryset = base_queryset.filter(user__profile__faculty=profile.faculty)
            elif comparison_group == 'major' and hasattr(profile, 'major'):
                base_queryset = base_queryset.filter(user__profile__major=profile.major)
            elif comparison_group == 'year' and hasattr(profile, 'graduation_year'):
                base_queryset = base_queryset.filter(user__profile__graduation_year=profile.graduation_year)
            elif comparison_group == 'experience' and hasattr(profile, 'experience_level'):
                base_queryset = base_queryset.filter(user__profile__experience_level=profile.experience_level)
        
        return base_queryset
    
    def _calculate_basic_statistics(self, queryset) -> Dict:
        """Calculate basic statistical measures for the comparison group."""
        
        scores = list(queryset.values_list('overall_score', flat=True))
        
        if not scores:
            return {
                'total_participants': 0,
                'average_score': 0.0,
                'top_score': 0.0,
                'bottom_score': 0.0,
                'median_score': 0.0,
                'std_deviation': 0.0,
                'score_distribution': {},
            }
        
        # Convert to float for calculations
        scores = [float(score) for score in scores]
        scores.sort()
        
        # Basic statistics
        total_participants = len(scores)
        average_score = sum(scores) / total_participants
        top_score = max(scores)
        bottom_score = min(scores)
        
        # Median calculation
        n = len(scores)
        if n % 2 == 0:
            median_score = (scores[n//2 - 1] + scores[n//2]) / 2
        else:
            median_score = scores[n//2]
        
        # Standard deviation
        variance = sum((x - average_score) ** 2 for x in scores) / total_participants
        std_deviation = variance ** 0.5
        
        # Score distribution (by performance levels)
        score_distribution = self._calculate_score_distribution(scores)
        
        return {
            'total_participants': total_participants,
            'average_score': round(average_score, 2),
            'top_score': round(top_score, 2),
            'bottom_score': round(bottom_score, 2),
            'median_score': round(median_score, 2),
            'std_deviation': round(std_deviation, 2),
            'score_distribution': score_distribution,
        }
    
    def _calculate_user_rank(self, user_score: float, queryset) -> Dict:
        """Calculate user's rank and percentile within the comparison group."""
        
        # Count users with scores higher than the user
        higher_scores_count = queryset.filter(overall_score__gt=user_score).count()
        
        # Count users with the same score
        same_score_count = queryset.filter(overall_score=user_score).count()
        
        # Total participants
        total_participants = queryset.count()
        
        if total_participants == 0:
            return {'user_rank': 1, 'percentile_rank': 100.0}
        
        # Calculate rank (1-based, where 1 is the highest)
        user_rank = higher_scores_count + 1
        
        # Calculate percentile rank
        # Users with same score get the average percentile of their range
        users_below = total_participants - higher_scores_count - same_score_count
        percentile_rank = ((users_below + (same_score_count / 2)) / total_participants) * 100
        
        return {
            'user_rank': user_rank,
            'percentile_rank': round(percentile_rank, 1)
        }
    
    def _get_performance_level(self, score: float) -> str:
        """Determine performance level based on score."""
        for level, (min_score, max_score) in self.PERFORMANCE_LEVELS.items():
            if min_score <= score <= max_score:
                return level
        return 'poor'  # Default fallback
    
    def _generate_benchmark_insights(
        self, 
        user_score: float, 
        stats: Dict, 
        rank_data: Dict, 
        performance_level: str
    ) -> List[str]:
        """Generate human-readable insights about the user's performance."""
        
        insights = []
        
        # SECURITY: Sanitize numeric values to prevent XSS
        percentile = max(0, min(100, rank_data.get('percentile_rank', 0)))
        gap_to_average = stats.get('average_score', 0) - user_score
        gap_to_top = stats.get('top_score', 0) - user_score
        total = max(1, stats.get('total_participants', 1))
        rank = max(1, rank_data.get('user_rank', 1))
        
        # Percentile insight
        if percentile >= 90:
            insights.append(f"You rank in the top {100 - percentile:.0f}% of students.")
        elif percentile >= 75:
            insights.append(f"You rank in the top {100 - percentile:.0f}% of students.")
        elif percentile >= 50:
            insights.append(f"You rank above {percentile:.0f}% of students.")
        else:
            insights.append(f"You rank above {percentile:.0f}% of students.")
        
        # Score comparison to average
        if gap_to_average < 0:  # User score is above average
            insights.append(f"Your score is {abs(gap_to_average):.1f} points above average.")
        elif gap_to_average > 0:  # User score is below average
            insights.append(f"Your score is {gap_to_average:.1f} points below average.")
        else:
            insights.append("Your score matches the average.")
        
        # Gap to top score
        if gap_to_top > 0:
            insights.append(f"You are {gap_to_top:.1f} points away from the top score.")
        else:
            insights.append("You have achieved the top score!")
        
        # Performance level insight - use predefined safe messages
        performance_messages = {
            'excellent': "Your CV demonstrates excellent quality and completeness.",
            'strong': "Your CV shows strong performance with room for minor improvements.",
            'average': "Your CV meets basic standards but has significant improvement potential.",
            'needs_improvement': "Your CV needs substantial improvements to meet competitive standards.",
            'poor': "Your CV requires major improvements across multiple areas."
        }
        # SECURITY: Only use predefined performance levels to prevent XSS
        safe_performance_level = performance_level if performance_level in performance_messages else 'average'
        insights.append(performance_messages[safe_performance_level])
        
        # Ranking insight
        if rank == 1:
            insights.append("Congratulations! You have the highest CV score.")
        elif rank <= total * 0.1:
            insights.append(f"You rank #{rank} out of {total} students.")
        elif rank <= total * 0.25:
            insights.append(f"You're in the top quarter, ranking #{rank} out of {total}.")
        
        return insights
    
    def _calculate_section_percentiles(
        self, 
        user_analysis: CVAnalysisHistory, 
        queryset
    ) -> Dict[str, float]:
        """Calculate percentiles for each CV section."""
        
        section_percentiles = {}
        user_sections = user_analysis.section_scores or {}
        
        for section_name, user_section_score in user_sections.items():
            if isinstance(user_section_score, (int, float)):
                user_score = float(user_section_score)
            else:
                continue  # Skip non-numeric scores
            
            # Get all section scores for this section
            section_scores = []
            for analysis in queryset:
                if analysis.section_scores and section_name in analysis.section_scores:
                    score = analysis.section_scores[section_name]
                    if isinstance(score, (int, float)):
                        section_scores.append(float(score))
            
            if section_scores:
                # Calculate percentile
                below_count = sum(1 for score in section_scores if score < user_score)
                same_count = sum(1 for score in section_scores if score == user_score)
                total_count = len(section_scores)
                
                percentile = ((below_count + (same_count / 2)) / total_count) * 100
                section_percentiles[section_name] = round(percentile, 1)
        
        return section_percentiles
    
    def _calculate_score_distribution(self, scores: List[float]) -> Dict[str, int]:
        """Calculate distribution of scores across performance levels."""
        
        distribution = {level: 0 for level in self.PERFORMANCE_LEVELS.keys()}
        
        for score in scores:
            level = self._get_performance_level(score)
            distribution[level] += 1
        
        return distribution
    
    def _generate_cache_key(self, user_id: int, comparison_group: Optional[str]) -> str:
        """Generate cache key for benchmark data."""
        group_suffix = f"_{comparison_group}" if comparison_group else "_all"
        return f"{self.cache_prefix}_user_{user_id}{group_suffix}"
    
    def _get_empty_benchmark_data(self) -> Dict:
        """Return empty benchmark data structure."""
        return {
            'user_id': '',
            'current_score': 0.0,
            'percentile_rank': 0.0,
            'user_rank': 0,
            'total_participants': 0,
            'average_score': 0.0,
            'top_score': 0.0,
            'bottom_score': 0.0,
            'score_gap_to_average': 0.0,
            'score_gap_to_top': 0.0,
            'performance_level': 'poor',
            'benchmark_insights': ['No analysis data available for benchmarking.'],
            'section_percentiles': {},
            'comparison_group': 'all_students',
            'last_updated': timezone.now().isoformat(),
            'statistics': {
                'median_score': 0.0,
                'std_deviation': 0.0,
                'score_distribution': {},
            }
        }
    
    def invalidate_cache(self, user_id: Optional[int] = None):
        """Invalidate benchmark cache for a user or all users."""
        if user_id:
            # Invalidate specific user's cache
            for group in [None, 'faculty', 'major', 'year', 'experience']:
                cache_key = self._generate_cache_key(user_id, group)
                cache.delete(cache_key)
        else:
            # Invalidate all benchmark cache (expensive operation)
            cache.delete_pattern(f"{self.cache_prefix}_*")
        
        logger.info(f'Invalidated benchmark cache for user {user_id or "all"}')