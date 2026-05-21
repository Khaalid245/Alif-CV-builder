import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/version_history/data/models/version_models.dart';
import 'package:educv/features/version_history/domain/version_history_repository.dart';
import 'package:educv/features/version_history/presentation/providers/version_history_provider.dart';

import 'version_history_provider_test.mocks.dart';

@GenerateMocks([VersionHistoryRepository])
void main() {
  late MockVersionHistoryRepository mockRepository;
  late VersionHistoryProvider provider;

  setUp(() {
    mockRepository = MockVersionHistoryRepository();
    provider = VersionHistoryProvider(mockRepository);
  });

  group('VersionHistoryProvider', () {
    test('initial state should be correct', () {
      expect(provider.state, VersionHistoryState.initial);
      expect(provider.versions, isEmpty);
      expect(provider.stats, null);
      expect(provider.comparison, null);
      expect(provider.errorMessage, null);
    });

    test('loadVersionHistory should update state correctly on success', () async {
      final mockVersions = [
        CVVersionModel(
          id: '1',
          versionNumber: 1,
          changeType: 'create',
          changeSummary: 'Initial version',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 1024,
          fieldsChanged: [],
        ),
      ];

      when(mockRepository.getVersionHistory()).thenAnswer((_) async => mockVersions);

      await provider.loadVersionHistory();

      expect(provider.state, VersionHistoryState.loaded);
      expect(provider.versions, mockVersions);
      expect(provider.errorMessage, null);
    });

    test('loadVersionHistory should handle errors correctly', () async {
      when(mockRepository.getVersionHistory()).thenThrow(Exception('Network error'));

      await provider.loadVersionHistory();

      expect(provider.state, VersionHistoryState.error);
      expect(provider.versions, isEmpty);
      expect(provider.errorMessage, 'Exception: Network error');
    });

    test('compareVersions should update comparison on success', () async {
      final mockComparison = VersionComparisonModel(
        fromVersion: CVVersionModel(
          id: '1',
          versionNumber: 1,
          changeType: 'create',
          changeSummary: '',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 1024,
          fieldsChanged: [],
        ),
        toVersion: CVVersionModel(
          id: '2',
          versionNumber: 2,
          changeType: 'update',
          changeSummary: '',
          cvData: {},
          changedAt: DateTime.now(),
          dataSize: 1024,
          fieldsChanged: [],
        ),
        differences: [],
        summary: {},
      );

      when(mockRepository.compareVersions(1, 2)).thenAnswer((_) async => mockComparison);

      await provider.compareVersions(1, 2);

      expect(provider.state, VersionHistoryState.loaded);
      expect(provider.comparison, mockComparison);
      expect(provider.errorMessage, null);
    });

    test('restoreVersion should return true on success', () async {
      final mockVersion = CVVersionModel(
        id: '1',
        versionNumber: 1,
        changeType: 'restore',
        changeSummary: 'Restored version',
        cvData: {},
        changedAt: DateTime.now(),
        dataSize: 1024,
        fieldsChanged: [],
      );

      when(mockRepository.restoreVersion(1)).thenAnswer((_) async => mockVersion);
      when(mockRepository.getVersionHistory()).thenAnswer((_) async => [mockVersion]);

      final result = await provider.restoreVersion(1);

      expect(result, true);
      verify(mockRepository.restoreVersion(1)).called(1);
      verify(mockRepository.getVersionHistory()).called(1);
    });

    test('restoreVersion should return false on error', () async {
      when(mockRepository.restoreVersion(1)).thenThrow(Exception('Restore failed'));

      final result = await provider.restoreVersion(1);

      expect(result, false);
      expect(provider.errorMessage, 'Exception: Restore failed');
    });

    test('clearComparison should clear comparison data', () {
      provider.clearComparison();
      expect(provider.comparison, null);
    });

    test('clearError should clear error message', () {
      provider.clearError();
      expect(provider.errorMessage, null);
    });
  });
}