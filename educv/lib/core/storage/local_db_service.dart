import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final localDbServiceProvider = Provider<LocalDbService>((ref) {
  return LocalDbService();
});

class LocalDbService {
  static const String _cvBoxName = 'cv_cache_box';
  static const String _cvProfileKey = 'cv_profile_data';

  Future<void> init() async {
    await Hive.openBox<String>(_cvBoxName);
  }

  Future<void> saveCvProfile(Map<String, dynamic> data) async {
    final box = await Hive.openBox<String>(_cvBoxName);
    await box.put(_cvProfileKey, jsonEncode(data));
  }

  Future<Map<String, dynamic>?> getCvProfile() async {
    final box = await Hive.openBox<String>(_cvBoxName);
    final dataString = box.get(_cvProfileKey);
    if (dataString != null) {
      return jsonDecode(dataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearCache() async {
    final box = await Hive.openBox<String>(_cvBoxName);
    await box.clear();
  }
}
