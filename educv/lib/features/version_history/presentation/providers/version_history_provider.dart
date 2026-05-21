import 'package:flutter/foundation.dart';
import '../../data/models/version_models.dart';
import '../../domain/version_history_repository.dart';

enum VersionHistoryState { initial, loading, loaded, error }

class VersionHistoryProvider extends ChangeNotifier {
  final VersionHistoryRepository _repository;

  VersionHistoryProvider(this._repository);

  VersionHistoryState _state = VersionHistoryState.initial;
  List<CVVersionModel> _versions = [];
  VersionStatsModel? _stats;
  VersionComparisonModel? _comparison;
  String? _errorMessage;

  VersionHistoryState get state => _state;
  List<CVVersionModel> get versions => _versions;
  VersionStatsModel? get stats => _stats;
  VersionComparisonModel? get comparison => _comparison;
  String? get errorMessage => _errorMessage;

  Future<void> loadVersionHistory() async {
    _setState(VersionHistoryState.loading);
    
    try {
      _versions = await _repository.getVersionHistory();
      _setState(VersionHistoryState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VersionHistoryState.error);
    }
  }

  Future<void> loadVersionStats() async {
    try {
      _stats = await _repository.getVersionStats();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VersionHistoryState.error);
    }
  }

  Future<void> compareVersions(int fromVersion, int toVersion) async {
    _setState(VersionHistoryState.loading);
    
    try {
      _comparison = await _repository.compareVersions(fromVersion, toVersion);
      _setState(VersionHistoryState.loaded);
    } catch (e) {
      _errorMessage = e.toString();
      _setState(VersionHistoryState.error);
    }
  }

  Future<bool> restoreVersion(int versionNumber) async {
    try {
      await _repository.restoreVersion(versionNumber);
      await loadVersionHistory(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    }
  }

  void clearComparison() {
    _comparison = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void _setState(VersionHistoryState newState) {
    _state = newState;
    notifyListeners();
  }
}