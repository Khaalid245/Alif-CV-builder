import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/analytics/data/models/analytics_models.dart';
import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';

void main() {
  group('ScoreSnapshotModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'snapshot_type': 'manual',
        'trigger_event': 'User requested',
        'overall_score': 85,
        'completion_percentage': 90,
        'profile_score': 80,
        'experience_score': 85,
        'education_score': 90,
        'skills_score': 88,
        'projects_score': 82,
        'submission_ready': true,
        'grade': 'A',
        'percentile_rank': '75.5',
        'peer_group_size': 150,
        'metrics_data': {'additional': 'data'},
        'created_at': '2024-01-01T10:00:00Z',
      };

      final snapshot = ScoreSnapshotModel.fromJson(json);

      expect(snapshot.id, 'test-id');
      expect(snapshot.snapshotType, 'manual');
      expect(snapshot.triggerEvent, 'User requested');
      expect(snapshot.overallScore, 85);
      expect(snapshot.completionPercentage, 90);
      expect(snapshot.profileScore, 80);
      expect(snapshot.experienceScore, 85);
      expect(snapshot.educationScore, 90);
      expect(snapshot.skillsScore, 88);
      expect(snapshot.projectsScore, 82);
      expect(snapshot.submissionReady, true);
      expect(snapshot.grade, 'A');
      expect(snapshot.percentileRank, 75.5);
      expect(snapshot.peerGroupSize, 150);
      expect(snapshot.metricsData, {'additional': 'data'});
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 'test-id',
        'snapshot_type': 'automatic',
        'trigger_event': '',
        'overall_score': 0,
        'completion_percentage': 0,
        'profile_score': 0,
        'experience_score': 0,
        'education_score': 0,
        'skills_score': 0,
        'projects_score': 0,
        'submission_ready': false,
        'grade': '',
        'peer_group_size': 0,
        'metrics_data': {},
        'created_at': '2024-01-01T10:00:00Z',
      };

      final snapshot = ScoreSnapshotModel.fromJson(json);

      expect(snapshot.percentileRank, null);
      expect(snapshot.grade, '');
      expect(snapshot.submissionReady, false);
    });
  });

  group('TrendAnalysisModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'trend_direction': 'improving',
        'trend_strength': 'strong',
        'slope': 2.5,
        'r_squared': 0.85,
        'absolute_change': 15.0,
        'percentage_change': 20.5,
        'volatility_score': 3.2,
        'predicted_next_value': 88.5,
        'confidence_interval': {'lower': 85.0, 'upper': 92.0},
        'data_points': [
          {
            'date': '2024-01-01T10:00:00Z',
            'value': 70.0,
            'label': 'Initial'
          },
          {
            'date': '2024-01-15T10:00:00Z',
            'value': 85.0,
            'label': 'Improved'
          }
        ],
        'analysis_start': '2024-01-01T00:00:00Z',
        'analysis_end': '2024-01-31T23:59:59Z',
        'data_points_count': 2,
      };

      final trend = TrendAnalysisModel.fromJson(json);

      expect(trend.trendDirection, 'improving');
      expect(trend.trendStrength, 'strong');
      expect(trend.slope, 2.5);
      expect(trend.rSquared, 0.85);
      expect(trend.absoluteChange, 15.0);
      expect(trend.percentageChange, 20.5);
      expect(trend.volatilityScore, 3.2);
      expect(trend.predictedNextValue, 88.5);
      expect(trend.confidenceInterval, {'lower': 85.0, 'upper': 92.0});
      expect(trend.dataPoints.length, 2);
      expect(trend.dataPointsCount, 2);
    });

    test('should handle data points correctly', () {
      final json = {
        'trend_direction': 'stable',
        'trend_strength': 'weak',
        'slope': 0.1,
        'r_squared': 0.15,
        'absolute_change': 1.0,
        'percentage_change': 1.5,
        'volatility_score': 1.0,
        'confidence_interval': {},
        'data_points': [
          {
            'date': '2024-01-01T10:00:00Z',
            'value': 75.0,
          }
        ],
        'analysis_start': '2024-01-01T00:00:00Z',
        'analysis_end': '2024-01-31T23:59:59Z',
        'data_points_count': 1,
      };

      final trend = TrendAnalysisModel.fromJson(json);

      expect(trend.dataPoints.length, 1);
      expect(trend.dataPoints.first.value, 75.0);
      expect(trend.dataPoints.first.label, null);
      expect(trend.predictedNextValue, null);
    });
  });

  group('BenchmarkingDataModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'user_id': 'user-123',
        'current_score': 85.5,
        'percentile_rank': 75.0,
        'total_peers': 200,
        'groups': [
          {
            'id': 'group-1',
            'name': 'Computer Science Students',
            'group_type': 'field_of_study',
            'description': 'Students in CS field',
            'member_count': 50,
            'average_score': 80.0,
            'median_score': 82.0,
            'user_rank': 10.0,
            'user_percentile': 80.0,
          }
        ],
        'summary': {'overall_performance': 'above_average'},
        'peer_comparisons': [
          {
            'metric': 'overall_score',
            'user_value': 85.5,
            'peer_average': 80.0,
            'peer_median': 82.0,
            'percentile_rank': 75.0,
            'performance': 'above_average',
          }
        ],
      };

      final benchmarking = BenchmarkingDataModel.fromJson(json);

      expect(benchmarking.userId, 'user-123');
      expect(benchmarking.currentScore, 85.5);
      expect(benchmarking.percentileRank, 75.0);
      expect(benchmarking.totalPeers, 200);
      expect(benchmarking.groups.length, 1);
      expect(benchmarking.groups.first.name, 'Computer Science Students');
      expect(benchmarking.summary['overall_performance'], 'above_average');
      expect(benchmarking.peerComparisons.length, 1);
      expect(benchmarking.peerComparisons.first.metric, 'overall_score');
    });
  });

  group('CompletionStatisticsModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'time_period': '30',
        'total_users': 1000,
        'average_completion': 75.5,
        'average_score': 82.3,
        'submission_ready_count': 650,
        'submission_ready_percentage': 65.0,
        'score_distribution': {
          '0-20': 50,
          '21-40': 100,
          '41-60': 200,
          '61-80': 400,
          '81-100': 250,
        },
        'completion_distribution': {
          '0-25': 100,
          '26-50': 150,
          '51-75': 300,
          '76-100': 450,
        },
        'section_averages': {
          'profile_score': 85.0,
          'experience_score': 78.5,
          'education_score': 88.2,
        },
        'trends': [
          {
            'date': '2024-01-01T00:00:00Z',
            'average_score': 80.0,
            'average_completion': 70.0,
            'user_count': 950,
          }
        ],
      };

      final stats = CompletionStatisticsModel.fromJson(json);

      expect(stats.timePeriod, '30');
      expect(stats.totalUsers, 1000);
      expect(stats.averageCompletion, 75.5);
      expect(stats.averageScore, 82.3);
      expect(stats.submissionReadyCount, 650);
      expect(stats.submissionReadyPercentage, 65.0);
      expect(stats.scoreDistribution['61-80'], 400);
      expect(stats.completionDistribution['76-100'], 450);
      expect(stats.sectionAverages['profile_score'], 85.0);
      expect(stats.trends.length, 1);
      expect(stats.trends.first.averageScore, 80.0);
    });
  });

  group('AnalyticsDashboardModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'user_summary': {
          'latest_score': 85,
          'latest_completion': 90,
          'submission_ready': true,
          'grade': 'A',
          'percentile_rank': '75.5',
          'total_snapshots': 10,
        },
        'recent_snapshots': [
          {
            'id': 'snap-1',
            'snapshot_type': 'manual',
            'trigger_event': 'Test',
            'overall_score': 85,
            'completion_percentage': 90,
            'profile_score': 80,
            'experience_score': 85,
            'education_score': 90,
            'skills_score': 88,
            'projects_score': 82,
            'submission_ready': true,
            'grade': 'A',
            'peer_group_size': 100,
            'metrics_data': {},
            'created_at': '2024-01-01T10:00:00Z',
          }
        ],
        'trend_analysis': {
          'trend_direction': 'improving',
          'trend_strength': 'moderate',
          'slope': 1.5,
          'r_squared': 0.75,
          'absolute_change': 10.0,
          'percentage_change': 15.0,
          'volatility_score': 2.0,
          'confidence_interval': {},
          'data_points': [],
          'analysis_start': '2024-01-01T00:00:00Z',
          'analysis_end': '2024-01-31T23:59:59Z',
          'data_points_count': 0,
        },
        'benchmarking_summary': {'performance': 'good'},
        'completion_stats': {
          'time_period': '30',
          'total_users': 500,
          'average_completion': 70.0,
          'average_score': 75.0,
          'submission_ready_count': 300,
          'submission_ready_percentage': 60.0,
          'score_distribution': {},
          'completion_distribution': {},
          'section_averages': {},
          'trends': [],
        },
        'system_metrics': {'last_updated': '2024-01-01T10:00:00Z'},
      };

      final dashboard = AnalyticsDashboardModel.fromJson(json);

      expect(dashboard.userSummary.latestScore, 85);
      expect(dashboard.userSummary.submissionReady, true);
      expect(dashboard.recentSnapshots.length, 1);
      expect(dashboard.trendAnalysis?.trendDirection, 'improving');
      expect(dashboard.benchmarkingSummary['performance'], 'good');
      expect(dashboard.completionStats?.totalUsers, 500);
      expect(dashboard.systemMetrics['last_updated'], '2024-01-01T10:00:00Z');
    });
  });
}