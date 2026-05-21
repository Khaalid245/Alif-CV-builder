import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:educv/features/version_history/data/models/version_models.dart';
import 'package:educv/features/version_history/presentation/providers/version_history_provider.dart';
import 'package:educv/features/version_history/presentation/screens/version_history_screen.dart';

import '../providers/version_history_provider_test.mocks.dart';

void main() {
  group('VersionHistoryScreen Integration Tests', () {
    late MockVersionHistoryRepository mockRepository;
    late VersionHistoryProvider provider;

    setUp(() {
      mockRepository = MockVersionHistoryRepository();
      provider = VersionHistoryProvider(mockRepository);
    });

    testWidgets('should display loading state initially', (tester) async {
      when(mockRepository.getVersionHistory()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return [];
      });

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display empty state when no versions', (tester) async {
      when(mockRepository.getVersionHistory()).thenAnswer((_) async => []);
      when(mockRepository.getVersionStats()).thenAnswer((_) async => VersionStatsModel(
        totalVersions: 0,
        oldestVersion: 0,
        newestVersion: 0,
        totalSizeMb: 0.0,
        changeTypes: {},
        recentActivity: [],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No Version History'), findsOneWidget);
      expect(find.text('No versions found for your CV.'), findsOneWidget);
    });

    testWidgets('should display version list when data is loaded', (tester) async {
      final mockVersions = [
        CVVersionModel(
          id: '1',
          versionNumber: 2,
          changeType: 'update',
          changeSummary: 'Updated profile',
          cvData: {},
          changedBy: 'John Doe',
          changedAt: DateTime(2024, 1, 1, 10, 0),
          dataSize: 1024,
          fieldsChanged: ['name'],
        ),
        CVVersionModel(
          id: '2',
          versionNumber: 1,
          changeType: 'create',
          changeSummary: 'Initial version',
          cvData: {},
          changedBy: 'John Doe',
          changedAt: DateTime(2024, 1, 1, 9, 0),
          dataSize: 512,
          fieldsChanged: [],
        ),
      ];

      final mockStats = VersionStatsModel(
        totalVersions: 2,
        oldestVersion: 1,
        newestVersion: 2,
        totalSizeMb: 1.5,
        changeTypes: {'create': 1, 'update': 1},
        recentActivity: mockVersions,
      );

      when(mockRepository.getVersionHistory()).thenAnswer((_) async => mockVersions);
      when(mockRepository.getVersionStats()).thenAnswer((_) async => mockStats);

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('v2'), findsOneWidget);
      expect(find.text('v1'), findsOneWidget);
      expect(find.text('Updated profile'), findsOneWidget);
      expect(find.text('Initial version'), findsOneWidget);
      expect(find.text('Version Statistics'), findsOneWidget);
    });

    testWidgets('should handle version selection for comparison', (tester) async {
      final mockVersions = [
        CVVersionModel(
          id: '1',
          versionNumber: 2,
          changeType: 'update',
          changeSummary: 'Updated profile',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 1024,
          fieldsChanged: [],
        ),
        CVVersionModel(
          id: '2',
          versionNumber: 1,
          changeType: 'create',
          changeSummary: 'Initial version',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 512,
          fieldsChanged: [],
        ),
      ];

      when(mockRepository.getVersionHistory()).thenAnswer((_) async => mockVersions);
      when(mockRepository.getVersionStats()).thenAnswer((_) async => VersionStatsModel(
        totalVersions: 2,
        oldestVersion: 1,
        newestVersion: 2,
        totalSizeMb: 1.5,
        changeTypes: {},
        recentActivity: [],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap first version
      await tester.tap(find.text('v2'));
      await tester.pump();

      expect(find.text('1 version(s) selected'), findsOneWidget);

      // Tap second version
      await tester.tap(find.text('v1'));
      await tester.pump();

      expect(find.text('2 version(s) selected'), findsOneWidget);
      expect(find.text('Compare'), findsOneWidget);
    });

    testWidgets('should show error state when loading fails', (tester) async {
      when(mockRepository.getVersionHistory()).thenThrow(Exception('Network error'));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Failed to load version history'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('should refresh data when pull to refresh', (tester) async {
      final mockVersions = [
        CVVersionModel(
          id: '1',
          versionNumber: 1,
          changeType: 'create',
          changeSummary: 'Initial version',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 512,
          fieldsChanged: [],
        ),
      ];

      when(mockRepository.getVersionHistory()).thenAnswer((_) async => mockVersions);
      when(mockRepository.getVersionStats()).thenAnswer((_) async => VersionStatsModel(
        totalVersions: 1,
        oldestVersion: 1,
        newestVersion: 1,
        totalSizeMb: 0.5,
        changeTypes: {},
        recentActivity: [],
      ));

      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider.value(
            value: provider,
            child: const VersionHistoryScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Perform pull to refresh
      await tester.fling(find.byType(RefreshIndicator), const Offset(0, 300), 1000);
      await tester.pump();

      verify(mockRepository.getVersionHistory()).called(2); // Initial + refresh
    });
  });
}