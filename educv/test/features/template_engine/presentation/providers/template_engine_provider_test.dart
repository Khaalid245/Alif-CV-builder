import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/template_engine/presentation/providers/template_engine_provider.dart';
import 'package:educv/features/template_engine/domain/repositories/template_engine_repository.dart';
import 'package:educv/features/data/models/template_model.dart';
import 'package:educv/features/data/models/industry_model.dart';
import 'package:educv/features/data/models/template_category_model.dart';
import 'package:educv/core/network/api_client.dart';

@GenerateMocks([TemplateEngineRepository, ApiClient])
import 'template_engine_provider_test.mocks.dart';

void main() {
  group('TemplateEngineProvider', () {
    late TemplateEngineProvider provider;
    late MockTemplateEngineRepository mockRepository;
    late MockApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockApiClient();
      mockRepository = MockTemplateEngineRepository();
      provider = TemplateEngineProvider(mockApiClient);
      // Replace the repository with our mock
      provider.repository = mockRepository;
    });

    group('initialization', () {
      test('should initialize with default values', () {
        expect(provider.isLoading, false);
        expect(provider.error, null);
        expect(provider.templates, isEmpty);
        expect(provider.industries, isEmpty);
        expect(provider.categories, isEmpty);
        expect(provider.hasActiveFilters, false);
      });

      test('should load initial data on initialize', () async {
        final industries = [
          IndustryModel(
            id: '1',
            name: 'Technology',
            slug: 'technology',
            description: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final categories = [
          TemplateCategoryModel(
            id: '1',
            name: 'Professional',
            slug: 'professional',
            description: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        when(mockRepository.getIndustries()).thenAnswer((_) async => industries);
        when(mockRepository.getCategories()).thenAnswer((_) async => categories);
        when(mockRepository.getRoles()).thenAnswer((_) async => []);
        when(mockRepository.getUserPreferences()).thenThrow(Exception('Not found'));
        when(mockRepository.getTemplates()).thenAnswer((_) async => []);

        await provider.initialize();

        expect(provider.industries, industries);
        expect(provider.categories, categories);
        verify(mockRepository.getIndustries()).called(1);
        verify(mockRepository.getCategories()).called(1);
      });
    });

    group('filtering', () {
      test('should update category filter and reload templates', () async {
        when(mockRepository.getTemplates(category: 'professional'))
            .thenAnswer((_) async => []);

        provider.setCategory('professional');

        expect(provider.selectedCategory, 'professional');
        expect(provider.hasActiveFilters, true);
        verify(mockRepository.getTemplates(category: 'professional')).called(1);
      });

      test('should update industry filter and reload roles and templates', () async {
        when(mockRepository.getRoles(industrySlug: 'technology'))
            .thenAnswer((_) async => []);
        when(mockRepository.getTemplates(industry: 'technology'))
            .thenAnswer((_) async => []);

        provider.setIndustry('technology');

        expect(provider.selectedIndustry, 'technology');
        expect(provider.selectedRole, null); // Should reset role
        expect(provider.hasActiveFilters, true);
        verify(mockRepository.getRoles(industrySlug: 'technology')).called(1);
        verify(mockRepository.getTemplates(industry: 'technology')).called(1);
      });

      test('should update search query and reload templates', () async {
        when(mockRepository.getTemplates(search: 'modern'))
            .thenAnswer((_) async => []);

        provider.setSearchQuery('modern');

        expect(provider.searchQuery, 'modern');
        expect(provider.hasActiveFilters, true);
        verify(mockRepository.getTemplates(search: 'modern')).called(1);
      });

      test('should clear all filters', () async {
        // Set some filters first
        when(mockRepository.getTemplates(category: 'professional'))
            .thenAnswer((_) async => []);
        when(mockRepository.getTemplates()).thenAnswer((_) async => []);

        provider.setCategory('professional');
        expect(provider.hasActiveFilters, true);

        provider.clearFilters();

        expect(provider.selectedCategory, null);
        expect(provider.selectedIndustry, null);
        expect(provider.selectedRole, null);
        expect(provider.searchQuery, '');
        expect(provider.hasActiveFilters, false);
        verify(mockRepository.getTemplates()).called(1);
      });
    });

    group('template operations', () {
      late TemplateModel mockTemplate;

      setUp(() {
        mockTemplate = TemplateModel(
          id: 'template-1',
          name: 'Test Template',
          slug: 'test-template',
          description: 'Test description',
          category: TemplateCategoryModel(
            id: '1',
            name: 'Professional',
            slug: 'professional',
            description: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          industries: [],
          roles: [],
          layoutType: TemplateLayout.singleColumn,
          htmlTemplate: '<html></html>',
          cssStyles: '',
          version: '1.0.0',
          status: TemplateStatus.active,
          isPremium: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      test('should select template successfully', () async {
        when(mockRepository.getTemplate('test-template'))
            .thenAnswer((_) async => mockTemplate);

        await provider.selectTemplate('test-template');

        expect(provider.selectedTemplate, mockTemplate);
        expect(provider.error, null);
        verify(mockRepository.getTemplate('test-template')).called(1);
      });

      test('should handle template selection error', () async {
        when(mockRepository.getTemplate('test-template'))
            .thenThrow(Exception('Template not found'));

        await provider.selectTemplate('test-template');

        expect(provider.selectedTemplate, null);
        expect(provider.error, contains('Template not found'));
      });

      test('should generate template preview', () async {
        const previewHtml = '<html>Preview content</html>';
        when(mockRepository.previewTemplate('test-template'))
            .thenAnswer((_) async => previewHtml);

        await provider.previewTemplate('test-template');

        expect(provider.templatePreview, previewHtml);
        expect(provider.error, null);
        verify(mockRepository.previewTemplate('test-template')).called(1);
      });

      test('should render template with custom branding', () async {
        final renderResult = {
          'rendered_html': '<html>Rendered content</html>',
          'metadata': {'render_time_ms': 150},
        };
        final customBranding = {'primary_color': '#ff0000'};

        when(mockRepository.renderTemplate('test-template', customBranding: customBranding))
            .thenAnswer((_) async => renderResult);

        final result = await provider.renderTemplate('test-template', customBranding: customBranding);

        expect(result, renderResult);
        expect(provider.error, null);
        verify(mockRepository.renderTemplate('test-template', customBranding: customBranding)).called(1);
      });
    });

    group('favorites', () {
      late TemplateModel mockTemplate;

      setUp(() {
        mockTemplate = TemplateModel(
          id: 'template-1',
          name: 'Test Template',
          slug: 'test-template',
          description: 'Test description',
          category: TemplateCategoryModel(
            id: '1',
            name: 'Professional',
            slug: 'professional',
            description: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          industries: [],
          roles: [],
          layoutType: TemplateLayout.singleColumn,
          htmlTemplate: '<html></html>',
          cssStyles: '',
          version: '1.0.0',
          status: TemplateStatus.active,
          isPremium: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      test('should add template to favorites', () async {
        when(mockRepository.favoriteTemplate('test-template'))
            .thenAnswer((_) async => {});

        await provider.toggleFavorite(mockTemplate);

        verify(mockRepository.favoriteTemplate('test-template')).called(1);
      });

      test('should remove template from favorites', () async {
        // Set up user preferences with the template as favorite
        provider.userPreferences?.favoriteTemplates.add(mockTemplate);
        
        when(mockRepository.unfavoriteTemplate('test-template'))
            .thenAnswer((_) async => {});

        await provider.toggleFavorite(mockTemplate);

        verify(mockRepository.unfavoriteTemplate('test-template')).called(1);
      });

      test('should check if template is favorite', () {
        expect(provider.isFavorite(mockTemplate), false);

        // Add to favorites
        provider.userPreferences?.favoriteTemplates.add(mockTemplate);
        expect(provider.isFavorite(mockTemplate), true);
      });
    });

    group('recent templates', () {
      late TemplateModel mockTemplate;

      setUp(() {
        mockTemplate = TemplateModel(
          id: 'template-1',
          name: 'Test Template',
          slug: 'test-template',
          description: 'Test description',
          category: TemplateCategoryModel(
            id: '1',
            name: 'Professional',
            slug: 'professional',
            description: '',
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          industries: [],
          roles: [],
          layoutType: TemplateLayout.singleColumn,
          htmlTemplate: '<html></html>',
          cssStyles: '',
          version: '1.0.0',
          status: TemplateStatus.active,
          isPremium: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
      });

      test('should add template to recent list', () {
        provider.addToRecent(mockTemplate);

        expect(provider.recentTemplates, contains(mockTemplate));
        expect(provider.recentTemplates.first, mockTemplate);
      });

      test('should move existing template to top of recent list', () {
        final template2 = TemplateModel(
          id: 'template-2',
          name: 'Test Template 2',
          slug: 'test-template-2',
          description: 'Test description 2',
          category: mockTemplate.category,
          industries: [],
          roles: [],
          layoutType: TemplateLayout.singleColumn,
          htmlTemplate: '<html></html>',
          cssStyles: '',
          version: '1.0.0',
          status: TemplateStatus.active,
          isPremium: false,
          usageCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        provider.addToRecent(mockTemplate);
        provider.addToRecent(template2);
        provider.addToRecent(mockTemplate); // Add again

        expect(provider.recentTemplates.first, mockTemplate);
        expect(provider.recentTemplates.length, 2);
      });

      test('should limit recent templates to 10', () {
        // Add 15 templates
        for (int i = 0; i < 15; i++) {
          final template = TemplateModel(
            id: 'template-$i',
            name: 'Template $i',
            slug: 'template-$i',
            description: 'Description $i',
            category: mockTemplate.category,
            industries: [],
            roles: [],
            layoutType: TemplateLayout.singleColumn,
            htmlTemplate: '<html></html>',
            cssStyles: '',
            version: '1.0.0',
            status: TemplateStatus.active,
            isPremium: false,
            usageCount: 0,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
          provider.addToRecent(template);
        }

        expect(provider.recentTemplates.length, 10);
      });
    });

    group('error handling', () {
      test('should handle network errors gracefully', () async {
        when(mockRepository.getTemplates())
            .thenThrow(Exception('Network error'));

        await provider.loadTemplates();

        expect(provider.error, contains('Network error'));
        expect(provider.isLoading, false);
      });

      test('should clear error when operation succeeds', () async {
        // First, cause an error
        when(mockRepository.getTemplates())
            .thenThrow(Exception('Network error'));
        await provider.loadTemplates();
        expect(provider.error, isNotNull);

        // Then, succeed
        when(mockRepository.getTemplates())
            .thenAnswer((_) async => []);
        await provider.loadTemplates();

        expect(provider.error, null);
      });

      test('should allow manual error clearing', () {
        provider.setError('Test error');
        expect(provider.error, 'Test error');

        provider.clearError();
        expect(provider.error, null);
      });
    });

    group('loading states', () {
      test('should set loading state during template operations', () async {
        when(mockRepository.getTemplates())
            .thenAnswer((_) async {
          // Simulate delay
          await Future.delayed(const Duration(milliseconds: 100));
          return [];
        });

        final future = provider.loadTemplates();
        expect(provider.isLoading, true);

        await future;
        expect(provider.isLoading, false);
      });
    });
  });
}