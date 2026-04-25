import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

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

  // Token management
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.accessTokenKey, value: accessToken),
      _storage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: AppConstants.accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: AppConstants.accessTokenKey),
      _storage.delete(key: AppConstants.refreshTokenKey),
    ]);
  }

  // User data management
  Future<void> saveUserData({
    required String userId,
    required String email,
    required String role,
  }) async {
    await Future.wait([
      _storage.write(key: AppConstants.userIdKey, value: userId),
      _storage.write(key: AppConstants.userEmailKey, value: email),
      _storage.write(key: AppConstants.userRoleKey, value: role),
    ]);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: AppConstants.userIdKey);
  }

  Future<String?> getUserEmail() async {
    return await _storage.read(key: AppConstants.userEmailKey);
  }

  Future<String?> getUserRole() async {
    return await _storage.read(key: AppConstants.userRoleKey);
  }

  Future<void> clearUserData() async {
    await Future.wait([
      _storage.delete(key: AppConstants.userIdKey),
      _storage.delete(key: AppConstants.userEmailKey),
      _storage.delete(key: AppConstants.userRoleKey),
    ]);
  }

  // Clear all data
  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}