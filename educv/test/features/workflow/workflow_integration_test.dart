import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:educv/features/workflow/presentation/screens/workflow_control_screen.dart';
import 'package:educv/features/workflow/presentation/widgets/workflow_integration_widget.dart';
import 'package:educv/features/workflow/presentation/providers/workflow_provider.dart';
import 'package:educv/features/workflow/data/models/workflow_models.dart';
import 'package:educv/features/workflow/domain/workflow_repository.dart';
import 'package:educv/features/auth/presentation/providers/auth_provider.dart';
import 'package:educv/features/cv/presentation/providers/cv_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Workflow Integration Tests', () {
    late MockWorkflowRepository mockRepository;
    late MockAuthRepository mockAuthRepository;
    late MockCVRepository mockCVRepository;

    setUp(() {
      mockRepository = MockWorkflowRepository();
      mockAuthRepository = MockAuthRepository();
      mockCVRepository = MockCVRepository();
    });

    // Helper function to create test app with providers
    Widget createTestApp(Widget child) {
      return ProviderScope(
        overrides: [
          workflowRepositoryProvider.overrideWithValue(mockRepository),
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
          cvRepositoryProvider.overrideWithValue(mockCVRepository),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    // Helper function to create test workflow data
    WorkflowInstanceModel createTestWorkflow({
      String id = 'workflow-123',
      String currentStateType = 'initial',
      String currentStateName = 'Draft',
    }) {
      final config = WorkflowConfigurationModel(
        id: 'config-123',
        name: 'CV Review Workflow',
        description: 'Standard CV review process',
        entityType: 'cv.profile',
        isActive: true,
        isDefault: true,
        configuration: {},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
        createdBy: 'admin-123',
        states: [
          WorkflowStateModel(
            id: 'state-1',
            workflowConfigId: 'config-123',
            code: 'draft',
            name: 'Draft',
            description: 'Initial draft state',
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
            name: 'Under Review',
            description: 'CV is being reviewed',
            stateType: 'intermediate',
            isActive: true,
            order: 2,
            properties: {},
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
          WorkflowStateModel(
            id: 'state-3',
            workflowConfigId: 'config-123',
            code: 'approved',
            name: 'Approved',
            description: 'CV has been approved',
            stateType: 'final',
            isActive: true,
            order: 3,
            properties: {},
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
        transitions: [
          WorkflowTransitionModel(
            id: 'transition-1',
            workflowConfigId: 'config-123',
            name: 'Submit for Review',
            description: 'Submit CV for review',
            fromState: WorkflowStateModel(
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
            toState: WorkflowStateModel(
              id: 'state-2',
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
            ),
            allowedRoles: ['student'],
            validationRules: {},
            isActive: true,
            requiresComment: false,
            autoTransition: false,
            properties: {},
            createdAt: DateTime(2024, 1, 1),
            updatedAt: DateTime(2024, 1, 1),
          ),
        ],
      );

      final currentState = config.states.firstWhere(
        (state) => state.name == currentStateName,
        orElse: () => config.states.first,
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

    testWidgets('Complete workflow lifecycle - from draft to approved', (tester) async {
      // Setup initial workflow in draft state
      final draftWorkflow = createTestWorkflow();
      
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => draftWorkflow);
      
      when(mockRepository.getAvailableTransitions(draftWorkflow.id))
          .thenAnswer((_) async => draftWorkflow.workflowConfig.transitions);

      // Setup CV profile
      when(mockCVRepository.getCVProfile())
          .thenAnswer((_) async => CVProfileModel(id: 'cv-123', /* other fields */));

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Verify initial state is displayed
      expect(find.text('Draft'), findsOneWidget);
      expect(find.text('Submit for Review'), findsOneWidget);

      // Simulate transition to review state
      final reviewWorkflow = createTestWorkflow(
        currentStateType: 'intermediate',
        currentStateName: 'Under Review',
      );

      when(mockRepository.performTransition(
        draftWorkflow.id,
        any,
      )).thenAnswer((_) async => reviewWorkflow);

      when(mockRepository.getAvailableTransitions(reviewWorkflow.id))
          .thenAnswer((_) async => []);

      // Tap submit for review button
      await tester.tap(find.text('Submit for Review'));
      await tester.pumpAndSettle();

      // Verify transition dialog appears
      expect(find.text('Confirm Transition'), findsOneWidget);
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);

      // Confirm the transition
      await tester.tap(find.text('Submit for Review').last);
      await tester.pumpAndSettle();

      // Verify success message
      expect(find.text('Workflow updated successfully!'), findsOneWidget);

      // Verify new state is displayed
      expect(find.text('Under Review'), findsOneWidget);
    });

    testWidgets('Workflow with required comment', (tester) async {
      final workflow = createTestWorkflow();
      
      // Create transition that requires comment
      final transitionWithComment = WorkflowTransitionModel(
        id: 'transition-comment',
        workflowConfigId: 'config-123',
        name: 'Reject with Reason',
        description: 'Reject CV with reason',
        fromState: workflow.currentState,
        toState: workflow.currentState,
        allowedRoles: ['reviewer'],
        validationRules: {},
        isActive: true,
        requiresComment: true,
        autoTransition: false,
        properties: {},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => [transitionWithComment]);

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Tap transition button
      await tester.tap(find.text('Reject with Reason'));
      await tester.pumpAndSettle();

      // Verify comment field is shown
      expect(find.text('Comment *'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);

      // Try to confirm without comment
      await tester.tap(find.text('Reject with Reason').last);
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Comment is required for this transition'), findsOneWidget);

      // Enter comment
      await tester.enterText(find.byType(TextField), 'CV needs more details');
      await tester.pumpAndSettle();

      // Mock successful transition
      when(mockRepository.performTransition(
        workflow.id,
        argThat(predicate<WorkflowTransitionRequest>((req) => 
          req.comment == 'CV needs more details'
        )),
      )).thenAnswer((_) async => workflow);

      // Confirm with comment
      await tester.tap(find.text('Reject with Reason').last);
      await tester.pumpAndSettle();

      // Verify transition was called with comment
      verify(mockRepository.performTransition(
        workflow.id,
        argThat(predicate<WorkflowTransitionRequest>((req) => 
          req.comment == 'CV needs more details'
        )),
      )).called(1);
    });

    testWidgets('Workflow history display and pagination', (tester) async {
      final workflow = createTestWorkflow();
      
      // Create test transition logs
      final transitionLogs = List.generate(5, (index) => 
        WorkflowTransitionLogModel(
          id: 'log-$index',
          workflowInstanceId: workflow.id,
          transition: workflow.workflowConfig.transitions.first,
          fromState: workflow.workflowConfig.states[0],
          toState: workflow.workflowConfig.states[1],
          performedBy: 'user-$index',
          performedAt: DateTime(2024, 1, 1).add(Duration(hours: index)),
          result: 'success',
          comment: 'Transition $index comment',
          userAgent: 'Mozilla/5.0',
          metadata: {},
        ),
      );

      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => []);

      when(mockRepository.getTransitionHistory(
        workflow.id,
        page: 1,
        pageSize: 50,
      )).thenAnswer((_) async => transitionLogs);

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(
          cvId: 'cv-123',
          showFullHistory: true,
        ),
      ));

      await tester.pumpAndSettle();

      // Verify history section is displayed
      expect(find.text('Recent Activity'), findsOneWidget);
      
      // Should show first 3 items
      expect(find.text('Transition 0 comment'), findsOneWidget);
      expect(find.text('Transition 1 comment'), findsOneWidget);
      expect(find.text('Transition 2 comment'), findsOneWidget);

      // Tap "View All" to see full history
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      // Verify full history dialog
      expect(find.text('Workflow History'), findsOneWidget);
      expect(find.text('Transition History'), findsOneWidget);

      // Should show all transition logs
      for (int i = 0; i < 5; i++) {
        expect(find.text('Transition $i comment'), findsOneWidget);
      }
    });

    testWidgets('Error handling - network failure', (tester) async {
      // Mock network failure
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Verify error state is displayed
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      // Test retry functionality
      final workflow = createTestWorkflow();
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => []);

      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      // Verify workflow is loaded after retry
      expect(find.text('Draft'), findsOneWidget);
    });

    testWidgets('No workflow state - create workflow flow', (tester) async {
      // Mock no workflow found
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => null);

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Verify no workflow state
      expect(find.text('No Active Workflow'), findsOneWidget);
      expect(find.text('This CV is not currently part of any workflow process.'), findsOneWidget);
      expect(find.text('Start Workflow'), findsOneWidget);

      // Tap start workflow
      await tester.tap(find.text('Start Workflow'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog
      expect(find.text('Start Workflow'), findsNWidgets(2)); // Title and button
      expect(find.text('Would you like to start a workflow process for this CV?'), findsOneWidget);

      // Confirm workflow creation
      await tester.tap(find.text('Start').last);
      await tester.pumpAndSettle();

      // Verify placeholder message (since creation is not implemented)
      expect(find.text('Workflow creation feature coming soon!'), findsOneWidget);
    });

    testWidgets('Role-based permissions - restricted actions', (tester) async {
      final workflow = createTestWorkflow();
      
      // Create transition with role restrictions
      final restrictedTransition = WorkflowTransitionModel(
        id: 'restricted-transition',
        workflowConfigId: 'config-123',
        name: 'Admin Only Action',
        description: 'Only admins can perform this action',
        fromState: workflow.currentState,
        toState: workflow.currentState,
        allowedRoles: ['admin'], // Only admin can perform
        validationRules: {},
        isActive: true,
        requiresComment: false,
        autoTransition: false,
        properties: {},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      );

      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => [restrictedTransition]);

      // Mock student user
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => UserModel(
            id: 'user-123',
            email: 'student@example.com',
            role: 'student',
            /* other fields */
          ));

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Verify restricted action is not shown for student
      expect(find.text('Admin Only Action'), findsNothing);
      expect(find.text('No Actions Available'), findsOneWidget);
    });

    testWidgets('Workflow refresh functionality', (tester) async {
      final workflow = createTestWorkflow();
      
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Verify initial state
      expect(find.text('Draft'), findsOneWidget);

      // Update workflow state
      final updatedWorkflow = createTestWorkflow(
        currentStateType: 'intermediate',
        currentStateName: 'Under Review',
      );

      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => updatedWorkflow);

      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      // Verify updated state is displayed
      expect(find.text('Under Review'), findsOneWidget);
      expect(find.text('Draft'), findsNothing);
    });

    testWidgets('Multiple transitions - show all actions dialog', (tester) async {
      final workflow = createTestWorkflow();
      
      // Create multiple transitions
      final transitions = List.generate(5, (index) => 
        WorkflowTransitionModel(
          id: 'transition-$index',
          workflowConfigId: 'config-123',
          name: 'Action $index',
          description: 'Test action $index',
          fromState: workflow.currentState,
          toState: workflow.currentState,
          allowedRoles: [],
          validationRules: {},
          isActive: true,
          requiresComment: false,
          autoTransition: false,
          properties: {},
          createdAt: DateTime(2024, 1, 1),
          updatedAt: DateTime(2024, 1, 1),
        ),
      );

      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async => workflow);
      
      when(mockRepository.getAvailableTransitions(workflow.id))
          .thenAnswer((_) async => transitions);

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      await tester.pumpAndSettle();

      // Should show first 3 actions as chips
      expect(find.text('Action 0'), findsOneWidget);
      expect(find.text('Action 1'), findsOneWidget);
      expect(find.text('Action 2'), findsOneWidget);

      // Should show "View All" link
      expect(find.text('View All'), findsOneWidget);

      // Tap "View All"
      await tester.tap(find.text('View All'));
      await tester.pumpAndSettle();

      // Verify all actions dialog
      expect(find.text('All Available Actions'), findsOneWidget);
      
      // Should show all 5 actions
      for (int i = 0; i < 5; i++) {
        expect(find.text('Action $i'), findsOneWidget);
      }
    });

    testWidgets('Loading states and transitions', (tester) async {
      // Mock delayed response to test loading state
      when(mockRepository.getCVWorkflow('cv-123'))
          .thenAnswer((_) async {
            await Future.delayed(Duration(milliseconds: 100));
            return createTestWorkflow();
          });

      await tester.pumpWidget(createTestApp(
        WorkflowIntegrationWidget(cvId: 'cv-123'),
      ));

      // Verify loading state is shown initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify content is loaded
      expect(find.text('Draft'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}