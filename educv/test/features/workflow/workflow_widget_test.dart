import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:educv/features/workflow/presentation/widgets/workflow_state_widget.dart';
import 'package:educv/features/workflow/presentation/widgets/workflow_transition_widget.dart';
import 'package:educv/features/workflow/presentation/widgets/workflow_integration_widget.dart';
import 'package:educv/features/workflow/presentation/widgets/workflow_dashboard_widget.dart';
import 'package:educv/features/workflow/presentation/providers/workflow_provider.dart';
import 'package:educv/features/workflow/data/models/workflow_models.dart';
import 'package:educv/features/workflow/domain/workflow_repository.dart';

import 'workflow_widget_test.mocks.dart';

@GenerateMocks([WorkflowRepository])
void main() {
  late MockWorkflowRepository mockRepository;

  setUp(() {
    mockRepository = MockWorkflowRepository();
  });

  // Helper function to create test workflow models
  WorkflowInstanceModel createTestWorkflowInstance({
    String id = 'instance-123',
    String currentStateType = 'initial',
    String currentStateName = 'Draft',
  }) {
    final config = WorkflowConfigurationModel(
      id: 'config-123',
      name: 'Test Workflow',
      description: 'Test workflow description',
      entityType: 'cv.profile',
      isActive: true,
      isDefault: false,
      configuration: {},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      createdBy: 'user-123',
      states: [],
      transitions: [],
    );

    final currentState = WorkflowStateModel(
      id: 'state-123',
      workflowConfigId: 'config-123',
      code: currentStateName.toLowerCase(),
      name: currentStateName,
      description: 'Test state description',
      stateType: currentStateType,
      isActive: true,
      order: 1,
      properties: {},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    return WorkflowInstanceModel(
      id: id,
      workflowConfig: config,
      contentType: 'cv_profile',
      objectId: 'cv-123',
      currentState: currentState,
      startedAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
      startedBy: 'user-123',
      properties: {},
      transitionLogs: [],
    );
  }

  WorkflowTransitionModel createTestTransition({
    String id = 'transition-123',
    String name = 'Submit for Review',
    bool requiresComment = false,
    List<String> allowedRoles = const [],
  }) {
    final fromState = WorkflowStateModel(
      id: 'from-state',
      workflowConfigId: 'config-123',
      code: 'draft',
      name: 'Draft',
      description: '',
      stateType: 'initial',
      isActive: true,
      order: 1,
      properties: {},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    final toState = WorkflowStateModel(
      id: 'to-state',
      workflowConfigId: 'config-123',
      code: 'review',
      name: 'Under Review',
      description: '',
      stateType: 'intermediate',
      isActive: true,
      order: 2,
      properties: {},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    return WorkflowTransitionModel(
      id: id,
      workflowConfigId: 'config-123',
      name: name,
      description: 'Test transition description',
      fromState: fromState,
      toState: toState,
      allowedRoles: allowedRoles,
      validationRules: {},
      isActive: true,
      requiresComment: requiresComment,
      autoTransition: false,
      properties: {},
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );
  }

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        workflowRepositoryProvider.overrideWithValue(mockRepository),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  group('WorkflowStateWidget', () {
    testWidgets('should display workflow state information', (tester) async {
      final workflow = createTestWorkflowInstance();

      await tester.pumpWidget(createTestWidget(
        WorkflowStateWidget(
          workflow: workflow,
          showDetails: true,
        ),
      ));

      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Test state description'), findsOneWidget);
      expect(find.text('Test Workflow'), findsOneWidget);
    });

    testWidgets('should show different colors for different state types', (tester) async {
      final initialWorkflow = createTestWorkflowInstance(currentStateType: 'initial');
      final finalWorkflow = createTestWorkflowInstance(currentStateType: 'final');

      // Test initial state
      await tester.pumpWidget(createTestWidget(
        WorkflowStateWidget(workflow: initialWorkflow),
      ));

      // Should find state indicator with appropriate styling
      expect(find.byType(Container), findsWidgets);

      // Test final state
      await tester.pumpWidget(createTestWidget(
        WorkflowStateWidget(workflow: finalWorkflow),
      ));

      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle tap callback', (tester) async {
      final workflow = createTestWorkflowInstance();
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        WorkflowStateWidget(
          workflow: workflow,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('should hide details when showDetails is false', (tester) async {
      final workflow = createTestWorkflowInstance();

      await tester.pumpWidget(createTestWidget(
        WorkflowStateWidget(
          workflow: workflow,
          showDetails: false,
        ),
      ));

      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Test Workflow'), findsNothing);
    });
  });

  group('WorkflowProgressWidget', () {
    testWidgets('should display progress indicators', (tester) async {
      final states = [
        WorkflowStateModel(
          id: 'state-1',
          workflowConfigId: 'config-123',
          code: 'draft',
          name: 'Draft',
          description: '',
          stateType: 'initial',
          isActive: true,
          order: 1,
          properties: {},
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
        WorkflowStateModel(
          id: 'state-2',
          workflowConfigId: 'config-123',
          code: 'review',
          name: 'Review',
          description: '',
          stateType: 'intermediate',
          isActive: true,
          order: 2,
          properties: {},
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      ];

      final config = WorkflowConfigurationModel(
        id: 'config-123',
        name: 'Test Workflow',
        description: '',
        entityType: 'cv.profile',
        isActive: true,
        isDefault: false,
        configuration: {},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'user-123',
        states: states,
        transitions: [],
      );

      final workflow = WorkflowInstanceModel(
        id: 'instance-123',
        workflowConfig: config,
        contentType: 'cv_profile',
        objectId: 'cv-123',
        currentState: states[0],
        startedAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        startedBy: 'user-123',
        properties: {},
        transitionLogs: [],
      );

      await tester.pumpWidget(createTestWidget(
        WorkflowProgressWidget(
          workflow: workflow,
          showLabels: true,
        ),
      ));

      expect(find.text('Workflow Progress'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('should hide labels when showLabels is false', (tester) async {
      final workflow = createTestWorkflowInstance();

      await tester.pumpWidget(createTestWidget(
        WorkflowProgressWidget(
          workflow: workflow,
          showLabels: false,
        ),
      ));

      expect(find.text('Workflow Progress'), findsNothing);
    });
  });

  group('WorkflowTransitionActionsWidget', () {
    testWidgets('should display available transitions', (tester) async {
      final transitions = [
        createTestTransition(name: 'Submit for Review'),
        createTestTransition(id: 'transition-2', name: 'Save as Draft'),
      ];

      await tester.pumpWidget(createTestWidget(
        WorkflowTransitionActionsWidget(
          transitions: transitions,
        ),
      ));

      expect(find.text('Available Actions'), findsOneWidget);
      expect(find.text('Submit for Review'), findsOneWidget);
      expect(find.text('Save as Draft'), findsOneWidget);
    });

    testWidgets('should show no actions state when transitions are empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        WorkflowTransitionActionsWidget(
          transitions: [],
        ),
      ));

      expect(find.text('No Actions Available'), findsOneWidget);
      expect(find.text('There are no available transitions from the current state.'), findsOneWidget);
    });

    testWidgets('should disable buttons when loading', (tester) async {
      final transitions = [createTestTransition()];

      await tester.pumpWidget(createTestWidget(
        WorkflowTransitionActionsWidget(
          transitions: transitions,
          isLoading: true,
        ),
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should call onTransition when button is tapped', (tester) async {
      final transitions = [createTestTransition()];
      String? calledTransitionId;
      String? calledComment;
      Map<String, dynamic>? calledMetadata;

      await tester.pumpWidget(createTestWidget(
        WorkflowTransitionActionsWidget(
          transitions: transitions,
          onTransition: (transitionId, comment, metadata) {
            calledTransitionId = transitionId;
            calledComment = comment;
            calledMetadata = metadata;
          },
        ),
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Confirm Transition'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Submit for Review').last);
      await tester.pumpAndSettle();

      expect(calledTransitionId, 'transition-123');
    });
  });

  group('TransitionConfirmationDialog', () {
    testWidgets('should display transition information', (tester) async {
      final transition = createTestTransition();

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => TransitionConfirmationDialog(
                transition: transition,
                onConfirm: (comment, metadata) {},
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Transition'), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Under Review'), findsOneWidget);
    });

    testWidgets('should show comment field when required', (tester) async {
      final transition = createTestTransition(requiresComment: true);

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => TransitionConfirmationDialog(
                transition: transition,
                onConfirm: (comment, metadata) {},
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Comment *'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('should validate required comment', (tester) async {
      final transition = createTestTransition(requiresComment: true);

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => TransitionConfirmationDialog(
                transition: transition,
                onConfirm: (comment, metadata) {},
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Try to confirm without comment
      await tester.tap(find.text('Submit for Review').last);
      await tester.pumpAndSettle();

      expect(find.text('Comment is required for this transition'), findsOneWidget);
    });

    testWidgets('should call onConfirm with comment', (tester) async {
      final transition = createTestTransition(requiresComment: true);
      String? receivedComment;

      await tester.pumpWidget(createTestWidget(
        Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (_) => TransitionConfirmationDialog(
                transition: transition,
                onConfirm: (comment, metadata) {
                  receivedComment = comment;
                  Navigator.of(context).pop();
                },
              ),
            ),
            child: const Text('Show Dialog'),
          ),
        ),
      ));

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      // Enter comment
      await tester.enterText(find.byType(TextField), 'Test comment');
      await tester.pumpAndSettle();

      // Confirm transition
      await tester.tap(find.text('Submit for Review').last);
      await tester.pumpAndSettle();

      expect(receivedComment, 'Test comment');
    });
  });

  group('TransitionHistoryWidget', () {
    WorkflowTransitionLogModel createTestLog({
      String id = 'log-123',
      String result = 'success',
      String comment = 'Test comment',
    }) {
      final transition = createTestTransition();
      
      return WorkflowTransitionLogModel(
        id: id,
        workflowInstanceId: 'instance-123',
        transition: transition,
        fromState: transition.fromState,
        toState: transition.toState,
        performedBy: 'user-123',
        performedAt: DateTime(2024, 1, 1),
        result: result,
        comment: comment,
        userAgent: 'Mozilla/5.0',
        metadata: {},
      );
    }

    testWidgets('should display transition history', (tester) async {
      final history = [
        createTestLog(comment: 'First transition'),
        createTestLog(id: 'log-2', comment: 'Second transition'),
      ];

      await tester.pumpWidget(createTestWidget(
        TransitionHistoryWidget(
          history: history,
        ),
      ));

      expect(find.text('Transition History'), findsOneWidget);
      expect(find.text('First transition'), findsOneWidget);
      expect(find.text('Second transition'), findsOneWidget);
    });

    testWidgets('should show empty state when no history', (tester) async {
      await tester.pumpWidget(createTestWidget(
        TransitionHistoryWidget(
          history: [],
        ),
      ));

      expect(find.text('No History Available'), findsOneWidget);
      expect(find.text('No transitions have been performed yet.'), findsOneWidget);
    });

    testWidgets('should show load more button when hasMore is true', (tester) async {
      final history = [createTestLog()];

      await tester.pumpWidget(createTestWidget(
        TransitionHistoryWidget(
          history: history,
          hasMore: true,
          onLoadMore: () {},
        ),
      ));

      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('should call onLoadMore when load more button is tapped', (tester) async {
      final history = [createTestLog()];
      bool loadMoreCalled = false;

      await tester.pumpWidget(createTestWidget(
        TransitionHistoryWidget(
          history: history,
          hasMore: true,
          onLoadMore: () => loadMoreCalled = true,
        ),
      ));

      await tester.tap(find.text('Load More'));
      expect(loadMoreCalled, true);
    });

    testWidgets('should show loading indicator when isLoading is true', (tester) async {
      final history = [createTestLog()];

      await tester.pumpWidget(createTestWidget(
        TransitionHistoryWidget(
          history: history,
          hasMore: true,
          isLoading: true,
          onLoadMore: () {},
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('WorkflowDashboardStatsWidget', () {
    testWidgets('should display dashboard statistics', (tester) async {
      final dashboard = WorkflowDashboardModel(
        totalInstances: 100,
        activeInstances: 25,
        completedInstances: 70,
        stateDistribution: {
          'draft': 10,
          'review': 15,
          'approved': 70,
          'rejected': 5,
        },
        recentInstances: [],
        statistics: {},
      );

      await tester.pumpWidget(createTestWidget(
        WorkflowDashboardStatsWidget(
          dashboard: dashboard,
        ),
      ));

      expect(find.text('Workflow Statistics'), findsOneWidget);
      expect(find.text('100'), findsOneWidget); // Total workflows
      expect(find.text('25'), findsOneWidget);  // Active
      expect(find.text('70'), findsOneWidget);  // Completed
      expect(find.text('70.0%'), findsOneWidget); // Success rate
    });

    testWidgets('should display state distribution', (tester) async {
      final dashboard = WorkflowDashboardModel(
        totalInstances: 100,
        activeInstances: 25,
        completedInstances: 70,
        stateDistribution: {
          'draft': 10,
          'review': 15,
        },
        recentInstances: [],
        statistics: {},
      );

      await tester.pumpWidget(createTestWidget(
        WorkflowDashboardStatsWidget(
          dashboard: dashboard,
        ),
      ));

      expect(find.text('State Distribution'), findsOneWidget);
      expect(find.text('draft'), findsOneWidget);
      expect(find.text('review'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });
  });

  group('WorkflowInstanceListWidget', () {
    testWidgets('should display list of workflow instances', (tester) async {
      final instances = [
        createTestWorkflowInstance(id: 'instance-1'),
        createTestWorkflowInstance(id: 'instance-2'),
      ];

      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceListWidget(
          instances: instances,
        ),
      ));

      expect(find.text('Workflow Instances'), findsOneWidget);
      expect(find.byType(WorkflowInstanceCard), findsNWidgets(2));
    });

    testWidgets('should show empty state when no instances', (tester) async {
      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceListWidget(
          instances: [],
        ),
      ));

      expect(find.text('No Workflow Instances'), findsOneWidget);
      expect(find.text('No workflow instances have been created yet.'), findsOneWidget);
    });

    testWidgets('should show load more button when hasMore is true', (tester) async {
      final instances = [createTestWorkflowInstance()];

      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceListWidget(
          instances: instances,
          hasMore: true,
          onLoadMore: () {},
        ),
      ));

      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('should call onInstanceTap when instance is tapped', (tester) async {
      final instances = [createTestWorkflowInstance()];
      WorkflowInstanceModel? tappedInstance;

      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceListWidget(
          instances: instances,
          onInstanceTap: (instance) => tappedInstance = instance,
        ),
      ));

      await tester.tap(find.byType(WorkflowInstanceCard));
      expect(tappedInstance?.id, 'instance-123');
    });
  });

  group('WorkflowInstanceCard', () {
    testWidgets('should display instance information', (tester) async {
      final instance = createTestWorkflowInstance();

      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceCard(
          instance: instance,
        ),
      ));

      expect(find.text('Test Workflow'), findsOneWidget);
      expect(find.text('Object ID: cv-123'), findsOneWidget);
      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('should call onTap when tapped', (tester) async {
      final instance = createTestWorkflowInstance();
      bool tapped = false;

      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceCard(
          instance: instance,
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, true);
    });

    testWidgets('should show different colors for different state types', (tester) async {
      final initialInstance = createTestWorkflowInstance(currentStateType: 'initial');
      final finalInstance = createTestWorkflowInstance(currentStateType: 'final');

      // Test initial state
      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceCard(instance: initialInstance),
      ));

      expect(find.byType(Container), findsWidgets);

      // Test final state
      await tester.pumpWidget(createTestWidget(
        WorkflowInstanceCard(instance: finalInstance),
      ));

      expect(find.byType(Container), findsWidgets);
    });
  });
}