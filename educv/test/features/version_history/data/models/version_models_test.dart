import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/version_history/data/models/version_models.dart';

void main() {
  group('CVVersionModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'test-id',
        'version_number': 5,
        'change_type': 'update',
        'change_summary': 'Updated profile',
        'cv_data': {'name': 'John Doe'},
        'changed_by': {'full_name': 'John Doe'},
        'changed_at': '2024-01-01T10:00:00Z',
        'ip_address': '192.168.1.1',
        'data_size': 1024,
        'fields_changed': ['name', 'email'],
        'previous_version': {'id': 'prev-id'},
      };

      final version = CVVersionModel.fromJson(json);

      expect(version.id, 'test-id');
      expect(version.versionNumber, 5);
      expect(version.changeType, 'update');
      expect(version.changeSummary, 'Updated profile');
      expect(version.cvData, {'name': 'John Doe'});
      expect(version.changedBy, 'John Doe');
      expect(version.ipAddress, '192.168.1.1');
      expect(version.dataSize, 1024);
      expect(version.fieldsChanged, ['name', 'email']);
      expect(version.previousVersionId, 'prev-id');
    });

    test('should handle null values in JSON', () {
      final json = {
        'id': 'test-id',
        'version_number': 1,
        'change_type': 'create',
        'change_summary': '',
        'cv_data': {},
        'changed_at': '2024-01-01T10:00:00Z',
        'data_size': 0,
        'fields_changed': [],
      };

      final version = CVVersionModel.fromJson(json);

      expect(version.changedBy, null);
      expect(version.ipAddress, null);
      expect(version.previousVersionId, null);
      expect(version.fieldsChanged, isEmpty);
    });
  });

  group('VersionDiffModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'id': 'diff-id',
        'diff_type': 'field_change',
        'field_path': 'profile.name',
        'old_value': 'Old Name',
        'new_value': 'New Name',
        'created_at': '2024-01-01T10:00:00Z',
      };

      final diff = VersionDiffModel.fromJson(json);

      expect(diff.id, 'diff-id');
      expect(diff.diffType, 'field_change');
      expect(diff.fieldPath, 'profile.name');
      expect(diff.oldValue, 'Old Name');
      expect(diff.newValue, 'New Name');
    });
  });

  group('VersionComparisonModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'from_version': {
          'id': 'v1',
          'version_number': 1,
          'change_type': 'create',
          'change_summary': '',
          'cv_data': {},
          'changed_at': '2024-01-01T10:00:00Z',
          'data_size': 0,
          'fields_changed': [],
        },
        'to_version': {
          'id': 'v2',
          'version_number': 2,
          'change_type': 'update',
          'change_summary': '',
          'cv_data': {},
          'changed_at': '2024-01-01T11:00:00Z',
          'data_size': 0,
          'fields_changed': [],
        },
        'differences': [
          {
            'id': 'diff-1',
            'diff_type': 'field_change',
            'field_path': 'name',
            'old_value': 'Old',
            'new_value': 'New',
            'created_at': '2024-01-01T10:00:00Z',
          }
        ],
        'summary': {'total_changes': 1},
      };

      final comparison = VersionComparisonModel.fromJson(json);

      expect(comparison.fromVersion.versionNumber, 1);
      expect(comparison.toVersion.versionNumber, 2);
      expect(comparison.differences.length, 1);
      expect(comparison.summary['total_changes'], 1);
    });
  });

  group('VersionStatsModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'total_versions': 10,
        'oldest_version': 1,
        'newest_version': 10,
        'total_size_mb': 5.2,
        'change_types': {'create': 1, 'update': 9},
        'recent_activity': [
          {
            'id': 'v10',
            'version_number': 10,
            'change_type': 'update',
            'change_summary': 'Latest update',
            'cv_data': {},
            'changed_at': '2024-01-01T10:00:00Z',
            'data_size': 1024,
            'fields_changed': ['name'],
          }
        ],
      };

      final stats = VersionStatsModel.fromJson(json);

      expect(stats.totalVersions, 10);
      expect(stats.oldestVersion, 1);
      expect(stats.newestVersion, 10);
      expect(stats.totalSizeMb, 5.2);
      expect(stats.changeTypes['create'], 1);
      expect(stats.changeTypes['update'], 9);
      expect(stats.recentActivity.length, 1);
      expect(stats.recentActivity.first.versionNumber, 10);
    });
  });
}