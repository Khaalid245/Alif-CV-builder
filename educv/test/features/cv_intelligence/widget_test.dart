import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'package:educv/features/cv_intelligence/data/models/cv_intelligence_models.dart';
import 'package:educv/features/cv_intelligence/presentation/widgets/score_display_widget.dart';
import 'package:educv/features/cv_intelligence/presentation/widgets/recommendation_card.dart';
import 'package:educv/features/cv_intelligence/presentation/widgets/submission_readiness_widget.dart';
import 'package:educv/features/cv_intelligence/presentation/widgets/cv_intelligence_summary_widget.dart';

void main() {
  group('CV Intelligence Widget Tests', () {
    group('ScoreDisplayWidget', () {
      testWidgets('should display score information correctly', (tester) async {
        // Arrange
        const score = 85.0;
        const maxScore = 100.0;
        const title = 'Overall Score';
        const subtitle = 'Based on comprehensive analysis';

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplayWidget(
                score: score,
                maxScore: maxScore,
                title: title,
                subtitle: subtitle,
                showPercentage: true,
                animated: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text(title), findsOneWidget);
        expect(find.text(subtitle), findsOneWidget);
        expect(find.text('85%'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should show raw score when showPercentage is false', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplayWidget(
                score: 85.0,
                maxScore: 100.0,
                title: 'Test Score',
                showPercentage: false,
                animated: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('85.0/100'), findsOneWidget);
      });

      testWidgets('should handle tap when onTap is provided', (tester) async {
        // Arrange
        bool tapped = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplayWidget(
                score: 75.0,
                maxScore: 100.0,
                title: 'Tappable Score',
                animated: false,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(ScoreDisplayWidget));

        // Assert
        expect(tapped, isTrue);
      });

      testWidgets('should display correct score colors', (tester) async {
        // Test excellent score (90+)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplayWidget(
                score: 95.0,
                maxScore: 100.0,
                title: 'Excellent Score',
                animated: false,
              ),
            ),
          ),
        );

        expect(find.text('Excellent'), findsOneWidget);

        // Test poor score (<50)
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ScoreDisplayWidget(
                score: 30.0,
                maxScore: 100.0,
                title: 'Poor Score',
                animated: false,
              ),
            ),
          ),
        );

        expect(find.text('Needs Work'), findsOneWidget);
      });
    });

    group('SectionScoreCard', () {
      testWidgets('should display section score information', (tester) async {
        // Arrange
        final sectionScore = SectionScoreModel(
          score: 80.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'good',
          strengths: ['Strong content'],
          weaknesses: ['Formatting issues'],
          suggestions: ['Improve layout', 'Add more details'],
          details: {},
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionScoreCard(
                sectionName: 'education_section',
                sectionScore: sectionScore,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Education Section'), findsOneWidget);
        expect(find.text('80%'), findsOneWidget);
        expect(find.text('Improve layout'), findsOneWidget);
        expect(find.byType(LinearProgressIndicator), findsOneWidget);
      });

      testWidgets('should handle tap when onTap is provided', (tester) async {
        // Arrange
        final sectionScore = SectionScoreModel(
          score: 70.0,
          maxScore: 100.0,
          weight: 1.0,
          status: 'good',
          strengths: [],
          weaknesses: [],
          suggestions: [],
          details: {},
        );
        bool tapped = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SectionScoreCard(
                sectionName: 'skills',
                sectionScore: sectionScore,
                onTap: () => tapped = true,
              ),
            ),
          ),
        );

        await tester.tap(find.byType(InkWell));

        // Assert
        expect(tapped, isTrue);
      });
    });

    group('RecommendationCard', () {
      testWidgets('should display recommendation information', (tester) async {
        // Arrange
        final recommendation = RecommendationModel(
          id: 'rec-1',
          category: 'skills',
          priority: 'high',
          title: 'Add Technical Skills',
          description: 'Consider adding more technical skills to your CV',
          actionText: 'Add Skills',
          actionUrl: 'https://example.com',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(
                recommendation: recommendation,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Add Technical Skills'), findsOneWidget);
        expect(find.text('Consider adding more technical skills to your CV'), findsOneWidget);
        expect(find.text('Skills'), findsOneWidget);
        expect(find.byIcon(LucideIcons.alertTriangle), findsOneWidget); // High priority icon
        expect(find.text('Add Skills'), findsOneWidget);
        expect(find.text('Mark as Done'), findsOneWidget);
      });

      testWidgets('should show implemented badge when recommendation is implemented', (tester) async {
        // Arrange
        final recommendation = RecommendationModel(
          id: 'rec-1',
          category: 'education',
          priority: 'medium',
          title: 'Add Certification',
          description: 'Add relevant certifications',
          actionText: 'Add',
          metadata: {},
          isImplemented: true,
          createdAt: DateTime.now(),
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(
                recommendation: recommendation,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Implemented'), findsOneWidget);
        expect(find.byIcon(LucideIcons.check), findsOneWidget);
        expect(find.text('Mark as Done'), findsNothing); // Should not show actions
      });

      testWidgets('should handle action button taps', (tester) async {
        // Arrange
        final recommendation = RecommendationModel(
          id: 'rec-1',
          category: 'skills',
          priority: 'low',
          title: 'Test Recommendation',
          description: 'Test description',
          actionText: 'Take Action',
          actionUrl: 'https://example.com',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        bool implementedCalled = false;
        bool actionCalled = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(
                recommendation: recommendation,
                onImplemented: () => implementedCalled = true,
                onAction: () => actionCalled = true,
              ),
            ),
          ),
        );

        await tester.tap(find.text('Mark as Done'));
        await tester.tap(find.text('Take Action'));

        // Assert
        expect(implementedCalled, isTrue);
        expect(actionCalled, isTrue);
      });

      testWidgets('should display correct priority icons and colors', (tester) async {
        // Test high priority
        final highPriorityRec = RecommendationModel(
          id: 'rec-high',
          category: 'skills',
          priority: 'high',
          title: 'High Priority',
          description: 'High priority recommendation',
          actionText: 'Action',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(recommendation: highPriorityRec),
            ),
          ),
        );

        expect(find.byIcon(LucideIcons.alertTriangle), findsOneWidget);

        // Test medium priority
        final mediumPriorityRec = RecommendationModel(
          id: 'rec-medium',
          category: 'education',
          priority: 'medium',
          title: 'Medium Priority',
          description: 'Medium priority recommendation',
          actionText: 'Action',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(recommendation: mediumPriorityRec),
            ),
          ),
        );

        expect(find.byIcon(LucideIcons.alertCircle), findsOneWidget);

        // Test low priority
        final lowPriorityRec = RecommendationModel(
          id: 'rec-low',
          category: 'formatting',
          priority: 'low',
          title: 'Low Priority',
          description: 'Low priority recommendation',
          actionText: 'Action',
          metadata: {},
          isImplemented: false,
          createdAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationCard(recommendation: lowPriorityRec),
            ),
          ),
        );

        expect(find.byIcon(LucideIcons.info), findsOneWidget);
      });
    });

    group('RecommendationsList', () {
      testWidgets('should display list of recommendations', (tester) async {
        // Arrange
        final recommendations = [
          RecommendationModel(
            id: 'rec-1',
            category: 'skills',
            priority: 'high',
            title: 'Add Skills',
            description: 'Add more skills',
            actionText: 'Add',
            metadata: {},
            isImplemented: false,
            createdAt: DateTime.now(),
          ),
          RecommendationModel(
            id: 'rec-2',
            category: 'education',
            priority: 'medium',
            title: 'Add Education',
            description: 'Add education details',
            actionText: 'Add',
            metadata: {},
            isImplemented: false,
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationsList(
                recommendations: recommendations,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Add Skills'), findsOneWidget);
        expect(find.text('Add Education'), findsOneWidget);
        expect(find.byType(RecommendationCard), findsNWidgets(2));
      });

      testWidgets('should show empty state when no recommendations', (tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationsList(
                recommendations: [],
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('All Caught Up!'), findsOneWidget);
        expect(find.text('You\'ve implemented all recommendations. Great job!'), findsOneWidget);
        expect(find.byIcon(LucideIcons.checkCircle), findsOneWidget);
      });

      testWidgets('should show filters when enabled', (tester) async {
        // Arrange
        final recommendations = [
          RecommendationModel(
            id: 'rec-1',
            category: 'skills',
            priority: 'high',
            title: 'Test Rec',
            description: 'Test',
            actionText: 'Test',
            metadata: {},
            isImplemented: false,
            createdAt: DateTime.now(),
          ),
        ];

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: RecommendationsList(
                recommendations: recommendations,
                showFilters: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Category'), findsOneWidget);
        expect(find.text('Priority'), findsOneWidget);
        expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
      });
    });

    group('SubmissionReadinessWidget', () {
      testWidgets('should display readiness information', (tester) async {
        // Arrange
        final readiness = SubmissionReadinessModel(
          isReady: true,
          readinessScore: 85.0,
          readyAspects: ['Complete profile', 'Good formatting'],
          missingAspects: [],
          improvementAreas: ['Add more skills'],
          overallAssessment: 'Your CV is ready for submission!',
          details: {},
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SubmissionReadinessWidget(
                readiness: readiness,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Submission Readiness'), findsOneWidget);
        expect(find.text('Your CV is ready for submission!'), findsOneWidget);
        expect(find.text('85%'), findsOneWidget);
        expect(find.text('Good'), findsOneWidget);
        expect(find.text('Ready Aspects'), findsOneWidget);
        expect(find.text('Complete profile'), findsOneWidget);
        expect(find.text('Improvement Areas'), findsOneWidget);
        expect(find.text('Add more skills'), findsOneWidget);
      });

      testWidgets('should show improve button when not ready', (tester) async {
        // Arrange
        final readiness = SubmissionReadinessModel(
          isReady: false,
          readinessScore: 60.0,
          readyAspects: [],
          missingAspects: ['Skills section', 'Experience details'],
          improvementAreas: ['Complete all sections'],
          overallAssessment: 'Several improvements needed',
          details: {},
        );

        bool improveCalled = false;

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SubmissionReadinessWidget(
                readiness: readiness,
                onImprove: () => improveCalled = true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Improve CV'), findsOneWidget);
        expect(find.text('Missing Aspects'), findsOneWidget);
        expect(find.text('Skills section'), findsOneWidget);

        await tester.tap(find.text('Improve CV'));
        expect(improveCalled, isTrue);
      });

      testWidgets('should display correct readiness icons', (tester) async {
        // Test ready state
        final readyReadiness = SubmissionReadinessModel(
          isReady: true,
          readinessScore: 95.0,
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: 'Ready!',
          details: {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SubmissionReadinessWidget(readiness: readyReadiness),
            ),
          ),
        );

        expect(find.byIcon(LucideIcons.checkCircle), findsOneWidget);

        // Test not ready state
        final notReadyReadiness = SubmissionReadinessModel(
          isReady: false,
          readinessScore: 40.0,
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: 'Needs work',
          details: {},
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SubmissionReadinessWidget(readiness: notReadyReadiness),
            ),
          ),
        );

        expect(find.byIcon(LucideIcons.alertTriangle), findsOneWidget);
      });
    });

    group('ReadinessStatusBadge', () {
      testWidgets('should display compact readiness badge', (tester) async {
        // Arrange
        final readiness = SubmissionReadinessModel(
          isReady: true,
          readinessScore: 90.0,
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: '',
          details: {},
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReadinessStatusBadge(
                readiness: readiness,
                compact: true,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Ready'), findsOneWidget);
        expect(find.byIcon(LucideIcons.checkCircle), findsOneWidget);
      });

      testWidgets('should display full readiness badge', (tester) async {
        // Arrange
        final readiness = SubmissionReadinessModel(
          isReady: false,
          readinessScore: 75.0,
          readyAspects: [],
          missingAspects: [],
          improvementAreas: [],
          overallAssessment: '',
          details: {},
        );

        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ReadinessStatusBadge(
                readiness: readiness,
                compact: false,
              ),
            ),
          ),
        );

        // Assert
        expect(find.text('Good'), findsOneWidget);
        expect(find.byIcon(LucideIcons.clock), findsOneWidget);
      });
    });
  });
}