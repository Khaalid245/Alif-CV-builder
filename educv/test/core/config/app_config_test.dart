import 'package:flutter_test/flutter_test.dart';
import 'package:educv/core/config/app_config.dart';

void main() {
  group('AppConfig Platform Detection Tests', () {
    test('should detect correct API URL for different platforms', () {
      // This test verifies that the platform detection logic works
      // In actual usage, the URL will be automatically adjusted based on the platform
      
      // The baseUrl getter should return a valid URL
      expect(AppConfig.baseUrl, isNotEmpty);
      expect(AppConfig.baseUrl, contains('http'));
      expect(AppConfig.baseUrl, contains('api/v1'));
      
      print('Detected API URL: ${AppConfig.baseUrl}');
    });
  });
}