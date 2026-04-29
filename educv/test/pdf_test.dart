// Simple test to verify PDF functionality
// Run: flutter test test/pdf_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/pdf/data/models/generated_cv_model.dart';

void main() {
  group('PDF Models', () {
    test('GeneratedCVModel should serialize correctly', () {
      final cv = GeneratedCVModel(
        id: 'test-id',
        template: 'classic',
        templateDisplay: 'Classic',
        downloadUrl: '/api/v1/cv/download/test-id/',
        generatedAt: DateTime(2024, 1, 15),
        downloadCount: 0,
      );

      final json = cv.toJson();
      final fromJson = GeneratedCVModel.fromJson(json);

      expect(fromJson.id, equals('test-id'));
      expect(fromJson.template, equals('classic'));
      expect(fromJson.templateDisplay, equals('Classic'));
      expect(fromJson.templateDescription, contains('Traditional layout'));
      expect(fromJson.templateBadge, equals('Professional'));
    });

    test('GenerateResponse should serialize correctly', () {
      final response = GenerateResponse(
        generatedAt: DateTime(2024, 1, 15),
        cvs: [
          GeneratedCVModel(
            id: 'classic-id',
            template: 'classic',
            templateDisplay: 'Classic',
            downloadUrl: '/api/v1/cv/download/classic-id/',
            generatedAt: DateTime(2024, 1, 15),
            downloadCount: 0,
          ),
        ],
      );

      final json = response.toJson();
      final fromJson = GenerateResponse.fromJson(json);

      expect(fromJson.cvs.length, equals(1));
      expect(fromJson.cvs.first.template, equals('classic'));
    });
  });
}