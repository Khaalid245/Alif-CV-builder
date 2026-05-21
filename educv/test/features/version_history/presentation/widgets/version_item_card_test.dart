import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/version_history/data/models/version_models.dart';
import 'package:educv/features/version_history/presentation/widgets/version_item_card.dart';

void main() {
  group('VersionItemCard', () {
    late CVVersionModel testVersion;

    setUp(() {
      testVersion = CVVersionModel(
        id: 'test-id',
        versionNumber: 5,
        changeType: 'update',
        changeSummary: 'Updated profile information',
        cvData: {},
        changedBy: 'John Doe',
        changedAt: DateTime(2024, 1, 1, 10, 0),
        dataSize: 2048,
        fieldsChanged: ['name', 'email', 'phone'],
      );
    });

    testWidgets('should display version information correctly', (tester) async {
      bool tapCalled = false;
      bool restoreCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: testVersion,
              isSelected: false,
              onTap: () => tapCalled = true,
              onRestore: () => restoreCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('v5'), findsOneWidget);
      expect(find.text('Updated'), findsOneWidget);
      expect(find.text('Updated profile information'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('2.0 KB'), findsOneWidget);
      expect(find.text('Restore'), findsOneWidget);
    });

    testWidgets('should show selected state correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: testVersion,
              isSelected: true,
              onTap: () {},
              onRestore: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should call onTap when card is tapped', (tester) async {
      bool tapCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: testVersion,
              isSelected: false,
              onTap: () => tapCalled = true,
              onRestore: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byType(InkWell));
      expect(tapCalled, true);
    });

    testWidgets('should call onRestore when restore button is tapped', (tester) async {
      bool restoreCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: testVersion,
              isSelected: false,
              onTap: () {},
              onRestore: () => restoreCalled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Restore'));
      expect(restoreCalled, true);
    });

    testWidgets('should display field changes correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: testVersion,
              isSelected: false,
              onTap: () {},
              onRestore: () {},
            ),
          ),
        ),
      );

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Phone'), findsOneWidget);
    });

    testWidgets('should show "more" indicator when many fields changed', (tester) async {
      final versionWithManyChanges = CVVersionModel(
        id: 'test-id',
        versionNumber: 5,
        changeType: 'update',
        changeSummary: 'Many changes',
        cvData: {},
        changedAt: DateTime.now(),
        dataSize: 2048,
        fieldsChanged: ['field1', 'field2', 'field3', 'field4', 'field5'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VersionItemCard(
              version: versionWithManyChanges,
              isSelected: false,
              onTap: () {},
              onRestore: () {},
            ),
          ),
        ),
      );

      expect(find.textContaining('+2 more'), findsOneWidget);
    });
  });
}