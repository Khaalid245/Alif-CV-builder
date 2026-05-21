import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/data/models/template_model.dart';
import 'package:educv/features/data/models/template_category_model.dart';
import 'package:educv/features/data/models/industry_model.dart';
import 'package:educv/features/data/models/role_model.dart';

void main() {
  group('TemplateModel', () {
    late Map<String, dynamic> validJson;
    late TemplateCategoryModel category;
    late IndustryModel industry;
    late RoleModel role;

    setUp(() {
      category = TemplateCategoryModel(
        id: 'cat-1',
        name: 'Professional',
        slug: 'professional',
        description: 'Professional templates',
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      industry = IndustryModel(
        id: 'ind-1',
        name: 'Technology',
        slug: 'technology',
        description: 'Tech industry',
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      role = RoleModel(
        id: 'role-1',
        name: 'Software Engineer',
        slug: 'software-engineer',
        industry: industry,
        description: 'Software engineering role',
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T00:00:00Z'),
        updatedAt: DateTime.parse('2024-01-01T00:00:00Z'),
      );

      validJson = {
        'id': 'template-1',
        'name': 'Modern Professional',
        'slug': 'modern-professional',
        'description': 'A modern professional template',
        'category': category.toJson(),
        'industries': [industry.toJson()],
        'roles': [role.toJson()],
        'layout_type': 'two_column',
        'html_template': '<html>Template content</html>',
        'css_styles': 'body { font-family: Arial; }',
        'version': '1.0.0',
        'parent_template': null,
        'status': 'active',
        'is_premium': false,
        'usage_count': 150,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
        'published_at': '2024-01-01T00:00:00Z',
        'preview_image_url': 'https://example.com/preview.jpg',
      };
    });

    test('should create TemplateModel from valid JSON', () {
      final template = TemplateModel.fromJson(validJson);

      expect(template.id, 'template-1');
      expect(template.name, 'Modern Professional');
      expect(template.slug, 'modern-professional');
      expect(template.description, 'A modern professional template');
      expect(template.category.name, 'Professional');
      expect(template.industries.length, 1);
      expect(template.industries.first.name, 'Technology');
      expect(template.roles.length, 1);
      expect(template.roles.first.name, 'Software Engineer');
      expect(template.layoutType, TemplateLayout.twoColumn);
      expect(template.status, TemplateStatus.active);
      expect(template.isPremium, false);
      expect(template.usageCount, 150);
      expect(template.isActive, true);
    });

    test('should convert TemplateModel to JSON', () {
      final template = TemplateModel.fromJson(validJson);
      final json = template.toJson();

      expect(json['id'], 'template-1');
      expect(json['name'], 'Modern Professional');
      expect(json['layout_type'], 'two_column');
      expect(json['status'], 'active');
      expect(json['is_premium'], false);
    });

    test('should handle missing optional fields', () {
      final minimalJson = {
        'id': 'template-1',
        'name': 'Test Template',
        'slug': 'test-template',
        'category': category.toJson(),
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final template = TemplateModel.fromJson(minimalJson);

      expect(template.description, '');
      expect(template.industries, isEmpty);
      expect(template.roles, isEmpty);
      expect(template.layoutType, TemplateLayout.singleColumn);
      expect(template.status, TemplateStatus.draft);
      expect(template.isPremium, false);
      expect(template.usageCount, 0);
    });

    test('should parse layout types correctly', () {
      final layouts = {
        'single_column': TemplateLayout.singleColumn,
        'two_column': TemplateLayout.twoColumn,
        'three_column': TemplateLayout.threeColumn,
        'modern_grid': TemplateLayout.modernGrid,
        'timeline': TemplateLayout.timeline,
      };

      layouts.forEach((key, expectedLayout) {
        final json = Map<String, dynamic>.from(validJson);
        json['layout_type'] = key;
        final template = TemplateModel.fromJson(json);
        expect(template.layoutType, expectedLayout);
      });
    });

    test('should parse status correctly', () {
      final statuses = {
        'draft': TemplateStatus.draft,
        'active': TemplateStatus.active,
        'deprecated': TemplateStatus.deprecated,
        'archived': TemplateStatus.archived,
      };

      statuses.forEach((key, expectedStatus) {
        final json = Map<String, dynamic>.from(validJson);
        json['status'] = key;
        final template = TemplateModel.fromJson(json);
        expect(template.status, expectedStatus);
      });
    });

    test('should return correct layout display name', () {
      final displayNames = {
        TemplateLayout.singleColumn: 'Single Column',
        TemplateLayout.twoColumn: 'Two Column',
        TemplateLayout.threeColumn: 'Three Column',
        TemplateLayout.modernGrid: 'Modern Grid',
        TemplateLayout.timeline: 'Timeline',
      };

      displayNames.forEach((layout, expectedName) {
        final json = Map<String, dynamic>.from(validJson);
        json['layout_type'] = layout.toString().split('.').last;
        final template = TemplateModel.fromJson(json);
        expect(template.layoutDisplayName, expectedName);
      });
    });

    test('should implement equality correctly', () {
      final template1 = TemplateModel.fromJson(validJson);
      final template2 = TemplateModel.fromJson(validJson);
      final template3 = TemplateModel.fromJson({
        ...validJson,
        'id': 'different-id',
      });

      expect(template1, equals(template2));
      expect(template1, isNot(equals(template3)));
      expect(template1.hashCode, equals(template2.hashCode));
      expect(template1.hashCode, isNot(equals(template3.hashCode)));
    });
  });

  group('IndustryModel', () {
    test('should create IndustryModel from JSON', () {
      final json = {
        'id': 'industry-1',
        'name': 'Technology',
        'slug': 'technology',
        'description': 'Technology industry',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final industry = IndustryModel.fromJson(json);

      expect(industry.id, 'industry-1');
      expect(industry.name, 'Technology');
      expect(industry.slug, 'technology');
      expect(industry.description, 'Technology industry');
      expect(industry.isActive, true);
    });

    test('should handle missing optional fields', () {
      final json = {
        'id': 'industry-1',
        'name': 'Technology',
        'slug': 'technology',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final industry = IndustryModel.fromJson(json);

      expect(industry.description, '');
      expect(industry.isActive, true);
    });
  });

  group('TemplateCategoryModel', () {
    test('should create TemplateCategoryModel from JSON', () {
      final json = {
        'id': 'category-1',
        'name': 'Professional',
        'slug': 'professional',
        'description': 'Professional templates',
        'is_active': true,
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      };

      final category = TemplateCategoryModel.fromJson(json);

      expect(category.id, 'category-1');
      expect(category.name, 'Professional');
      expect(category.slug, 'professional');
      expect(category.description, 'Professional templates');
      expect(category.isActive, true);
    });
  });
}