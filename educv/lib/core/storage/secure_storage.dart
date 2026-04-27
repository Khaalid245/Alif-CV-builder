import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static const _knownKeys = [
    AppConstants.accessTokenKey,
    AppConstants.refreshTokenKey,
    AppConstants.userIdKey,
    AppConstants.userEmailKey,
    AppConstants.userRoleKey,
  ];

  Future<void> _write({required String key, required String value}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
      return;
    }

    await _storage.write(key: key, value: value);
  }

  Future<String?> _read({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(key);
    }

    return await _storage.read(key: key);
  }

  Future<void> _delete({required String key}) async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      return;
    }

    await _storage.delete(key: key);
  }

  // Token management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _write(key: AppConstants.accessTokenKey, value: accessToken),
      _write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _delete(key: AppConstants.accessTokenKey),
      _delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  // User data management
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      _write(key: AppConstants.userIdKey, value: userId),
      _write(key: AppConstants.userEmailKey, value: email),
      _write(key: AppConstants.userRoleKey, value: role),
    ]);
  }

  Future<String?> getUserId() async {
    return await _read(key: AppConstants.userIdKey);
  }

  Future<String?> getUserEmail() async {
    return await _read(key: AppConstants.userEmailKey);
  }

  Future<String?> getUserRole() async {
    return await _read(key: AppConstants.userRoleKey);
  }

  Future<void> clearUserData() async {
    await Future.wait([
      _delete(key: AppConstants.userIdKey),
      _delete(key: AppConstants.userEmailKey),
      _delete(key: AppConstants.userRoleKey),
    ]);
  }

  // Clear all data
  Future<void> clearAll() async {
    if (kIsWeb) {
      final prefs = await SharedPreferences.getInstance();
      await Future.wait(_knownKeys.map(prefs.remove));
      return;
    }

    await _storage.deleteAll();
  }
}
