import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/template_engine/presentation/widgets/template_card_widget.dart';
import 'package:educv/features/template_engine/presentation/widgets/template_search_widget.dart';
import 'package:educv/features/template_engine/presentation/widgets/template_filters_widget.dart';
import 'package:educv/features/template_engine/presentation/providers/template_engine_provider.dart';
import 'package:educv/features/data/models/template_model.dart';
import 'package:educv/features/data/models/template_category_model.dart';

@GenerateMocks([TemplateEngineProvider])
import 'template_engine_widgets_test.mocks.dart';

void main() {
  group('TemplateCardWidget', () {
    late MockTemplateEngineProvider mockProvider;
    late TemplateModel mockTemplate;

    setUp(() {
      mockProvider = MockTemplateEngineProvider();
      mockTemplate = TemplateModel(
        id: 'template-1',
        name: 'Modern Professional',
        slug: 'modern-professional',
        description: 'A modern professional template',
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
        layoutType: TemplateLayout.twoColumn,
        htmlTemplate: '<html></html>',
        cssStyles: '',
        version: '1.0.0',
        status: TemplateStatus.active,
        isPremium: false,
        usageCount: 150,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockProvider.isFavorite(any)).thenReturn(false);
    });

    Widget createWidget({
      VoidCallback? onTap,
      VoidCallback? onFavorite,
      VoidCallback? onPreview,
    }) {
      return MaterialApp(
        home: ChangeNotifierProvider<TemplateEngineProvider>.value(
          value: mockProvider,
          child: Scaffold(
            body: TemplateCardWidget(
              template: mockTemplate,
              onTap: onTap,
              onFavorite: onFavorite,
              onPreview: onPreview,
            ),
          ),
        ),
      );
    }

    testWidgets('should display template information', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Modern Professional'), findsOneWidget);
      expect(find.text('Professional'), findsOneWidget);
      expect(find.text('Two Column'), findsOneWidget);
      expect(find.text('150 uses'), findsOneWidget);
    });

    testWidgets('should show premium badge for premium templates', (tester) async {
      final premiumTemplate = TemplateModel(
        id: 'template-1',
        name: 'Premium Template',
        slug: 'premium-template',
        description: 'A premium template',
        category: mockTemplate.category,
        industries: [],
        roles: [],
        layoutType: TemplateLayout.singleColumn,
        htmlTemplate: '<html></html>',
        cssStyles: '',
        version: '1.0.0',
        status: TemplateStatus.active,
        isPremium: true,
        usageCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(MaterialApp(
        home: ChangeNotifierProvider<TemplateEngineProvider>.value(
          value: mockProvider,
          child: Scaffold(
            body: TemplateCardWidget(template: premiumTemplate),
          ),
        ),
      ));

      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createWidget(
        onTap: () => tapped = true,
      ));

      await tester.tap(find.byType(InkWell));
      expect(tapped, true);
    });

    testWidgets('should call onFavorite when favorite button is tapped', (tester) async {
      bool favorited = false;
      await tester.pumpWidget(createWidget(
        onFavorite: () => favorited = true,
      ));

      await tester.tap(find.byIcon(Icons.favorite_border).first);
      expect(favorited, true);
    });

    testWidgets('should call onPreview when preview button is tapped', (tester) async {
      bool previewed = false;
      await tester.pumpWidget(createWidget(
        onPreview: () => previewed = true,
      ));

      await tester.tap(find.byIcon(Icons.visibility).first);
      expect(previewed, true);
    });

    testWidgets('should show filled heart for favorite templates', (tester) async {
      when(mockProvider.isFavorite(mockTemplate)).thenReturn(true);

      await tester.pumpWidget(createWidget());

      // The heart should be red when favorited
      final heartIcon = tester.widget<Icon>(find.byIcon(Icons.favorite).first);
      expect(heartIcon.color, Colors.red);
    });
  });

  group('TemplateSearchWidget', () {
    late MockTemplateEngineProvider mockProvider;

    setUp(() {
      mockProvider = MockTemplateEngineProvider();
      when(mockProvider.searchQuery).thenReturn('');
    });

    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TemplateEngineProvider>.value(
          value: mockProvider,
          child: const Scaffold(
            body: TemplateSearchWidget(),
          ),
        ),
      );
    }

    testWidgets('should display search field with hint text', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search templates by name, category, or description...'), findsOneWidget);
    });

    testWidgets('should call setSearchQuery when text is submitted', (tester) async {
      await tester.pumpWidget(createWidget());

      await tester.enterText(find.byType(TextField), 'modern');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      verify(mockProvider.setSearchQuery('modern')).called(1);
    });

    testWidgets('should show clear button when text is entered', (tester) async {
      when(mockProvider.searchQuery).thenReturn('test');

      await tester.pumpWidget(createWidget());

      // Simulate text entry
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('should clear search when clear button is tapped', (tester) async {
      await tester.pumpWidget(createWidget());

      // Enter text first
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump();

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));

      verify(mockProvider.setSearchQuery('')).called(1);
    });
  });

  group('TemplateFiltersWidget', () {
    late MockTemplateEngineProvider mockProvider;

    setUp(() {
      mockProvider = MockTemplateEngineProvider();
      when(mockProvider.selectedCategory).thenReturn(null);
      when(mockProvider.selectedIndustry).thenReturn(null);
      when(mockProvider.selectedRole).thenReturn(null);
      when(mockProvider.selectedLayout).thenReturn(null);
      when(mockProvider.isPremiumFilter).thenReturn(null);
      when(mockProvider.hasActiveFilters).thenReturn(false);
      when(mockProvider.categories).thenReturn([]);
      when(mockProvider.industries).thenReturn([]);
      when(mockProvider.filteredRoles).thenReturn([]);
    });

    Widget createWidget() {
      return MaterialApp(
        home: ChangeNotifierProvider<TemplateEngineProvider>.value(
          value: mockProvider,
          child: const Scaffold(
            body: TemplateFiltersWidget(),
          ),
        ),
      );
    }

    testWidgets('should display filter title', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Filters'), findsOneWidget);
    });

    testWidgets('should show clear all button when filters are active', (tester) async {
      when(mockProvider.hasActiveFilters).thenReturn(true);

      await tester.pumpWidget(createWidget());

      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('should call clearFilters when clear all is tapped', (tester) async {
      when(mockProvider.hasActiveFilters).thenReturn(true);

      await tester.pumpWidget(createWidget());

      await tester.tap(find.text('Clear All'));
      verify(mockProvider.clearFilters()).called(1);
    });

    testWidgets('should display filter dropdowns', (tester) async {
      await tester.pumpWidget(createWidget());

      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Industry'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Layout'), findsOneWidget);
      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('should call setCategory when category is changed', (tester) async {
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
      when(mockProvider.categories).thenReturn(categories);

      await tester.pumpWidget(createWidget());

      // Find and tap the category dropdown
      await tester.tap(find.text('Category').first);
      await tester.pumpAndSettle();

      // Select the professional category
      await tester.tap(find.text('Professional').last);
      await tester.pumpAndSettle();

      verify(mockProvider.setCategory('professional')).called(1);
    });
  });
}