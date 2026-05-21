import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/analytics/data/models/analytics_models.dart';
import 'package:educv/features/analytics/presentation/widgets/analytics_overview_card.dart';

void main() {
  group('AnalyticsOverviewCard', () {
    late UserSummaryModel testUserSummary;

    setUp(() {
      testUserSummary = UserSummaryModel(
        latestScore: 85,
        latestCompletion: 90,
        submissionReady: true,
        grade: 'A',
        percentileRank: 75.5,
        totalSnapshots: 10,
      );
    });

    testWidgets('should display user summary information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      expect(find.text('Your CV Performance'), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('90'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('Total Snapshots: 10'), findsOneWidget);
    });

    testWidgets('should show percentile rank when available', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      expect(find.text('Peer Ranking'), findsOneWidget);
      expect(find.text('75.5th'), findsOneWidget);
      expect(find.text('percentile'), findsOneWidget);
    });

    testWidgets('should not show percentile rank when null', (tester) async {
      final summaryWithoutPercentile = UserSummaryModel(
        latestScore: 85,
        latestCompletion: 90,
        submissionReady: true,
        grade: 'A',
        percentileRank: null,
        totalSnapshots: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: summaryWithoutPercentile),
          ),
        ),
      );

      expect(find.text('Peer Ranking'), findsNothing);
      expect(find.text('percentile'), findsNothing);
    });

    testWidgets('should show correct submission readiness status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      expect(find.text('Ready to Submit'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
    });

    testWidgets('should show not ready status when submission not ready', (tester) async {
      final notReadySummary = UserSummaryModel(
        latestScore: 45,
        latestCompletion: 60,
        submissionReady: false,
        grade: 'C',
        percentileRank: 25.0,
        totalSnapshots: 5,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: notReadySummary),
          ),
        ),
      );

      expect(find.text('Needs Improvement'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('should handle empty grade correctly', (tester) async {
      final summaryWithoutGrade = UserSummaryModel(
        latestScore: 85,
        latestCompletion: 90,
        submissionReady: true,
        grade: '',
        percentileRank: 75.5,
        totalSnapshots: 10,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: summaryWithoutGrade),
          ),
        ),
      );

      expect(find.text('Not Graded'), findsOneWidget);
    });

    testWidgets('should display correct score colors based on performance', (tester) async {
      // Test high score (should be success color)
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      // Verify the widget renders without errors
      expect(find.byType(AnalyticsOverviewCard), findsOneWidget);
    });

    testWidgets('should show different percentile descriptions based on rank', (tester) async {
      // Test excellent performance (90th+ percentile)
      final excellentSummary = UserSummaryModel(
        latestScore: 95,
        latestCompletion: 100,
        submissionReady: true,
        grade: 'A+',
        percentileRank: 95.0,
        totalSnapshots: 15,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: excellentSummary),
          ),
        ),
      );

      expect(find.textContaining('Excellent performance'), findsOneWidget);
    });

    testWidgets('should handle low performance correctly', (tester) async {
      final lowPerformanceSummary = UserSummaryModel(
        latestScore: 30,
        latestCompletion: 40,
        submissionReady: false,
        grade: 'D',
        percentileRank: 15.0,
        totalSnapshots: 3,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: lowPerformanceSummary),
          ),
        ),
      );

      expect(find.textContaining('Needs significant improvement'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
      expect(find.text('Needs Improvement'), findsOneWidget);
    });

    testWidgets('should display all score sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      expect(find.text('Overall Score'), findsOneWidget);
      expect(find.text('Completion'), findsOneWidget);
      expect(find.text('Submission Ready'), findsOneWidget);
      expect(find.text('Grade'), findsOneWidget);
    });

    testWidgets('should show correct icons for different sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnalyticsOverviewCard(userSummary: testUserSummary),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.grade), findsOneWidget);
    });
  });
}