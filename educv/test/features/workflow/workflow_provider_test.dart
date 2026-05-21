import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:educv/features/workflow/domain/workflow_repository.dart';
import 'package:educv/features/workflow/data/models/workflow_models.dart';
import 'package:educv/features/workflow/presentation/providers/workflow_provider.dart';
import 'package:educv/core/exceptions/app_exception.dart';

import '../workflow_integration_test.mocks.dart';

@GenerateMocks([WorkflowRepository])
void main() {
  group('Workflow Provider Tests', () {
    late MockWorkflowRepository mockRepository;
    late ProviderContainer container;

    setUp(() {
      mockRepository = MockWorkflowRepository();
      container = ProviderContainer(
        overrides: [
          workflowRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    group('CVWorkflowNotifier', () {
      test('should load workflow successfully', () async {
        // Arrange
        final mockWorkflow = _createMockWorkflow();
        final mockTransitions = [_createMockTransition()];
        
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenAnswer((_) async => mockWorkflow);
        when(mockRepository.getAvailableTransitions(mockWorkflow.id))
            .thenAnswer((_) async => mockTransitions);

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(cvWorkflowProvider('test-cv-id'));
        expect(state.workflow, equals(mockWorkflow));
        expect(state.availableTransitions, equals(mockTransitions));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should handle workflow not found', () async {
        // Arrange
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenAnswer((_) async => null);

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(cvWorkflowProvider('test-cv-id'));
        expect(state.workflow, isNull);
        expect(state.availableTransitions, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should handle loading error', () async {
        // Arrange
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenThrow(AppException(message: 'Network error', statusCode: 500));

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(cvWorkflowProvider('test-cv-id'));
        expect(state.workflow, isNull);
        expect(state.isLoading, isFalse);
        expect(state.error, equals('Network error'));
      });

      test('should perform transition successfully', () async {
        // Arrange
        final mockWorkflow = _createMockWorkflow();
        final mockTransitions = [_createMockTransition()];
        final updatedWorkflow = mockWorkflow.copyWith(
          currentState: _createMockState('review', 'Under Review', 'intermediate', 1),
        );
        
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenAnswer((_) async => mockWorkflow);
        when(mockRepository.getAvailableTransitions(mockWorkflow.id))
            .thenAnswer((_) async => mockTransitions);
        when(mockRepository.performTransition(any, any))
            .thenAnswer((_) async => updatedWorkflow);
        when(mockRepository.getAvailableTransitions(updatedWorkflow.id))
            .thenAnswer((_) async => []);

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);
        
        await notifier.performTransition('transition-1', comment: 'Test comment');

        // Assert
        final state = container.read(cvWorkflowProvider('test-cv-id'));
        expect(state.workflow?.currentState.name, equals('Under Review'));
        expect(state.isTransitioning, isFalse);
        expect(state.error, isNull);
      });

      test('should handle transition error', () async {
        // Arrange
        final mockWorkflow = _createMockWorkflow();
        final mockTransitions = [_createMockTransition()];
        
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenAnswer((_) async => mockWorkflow);
        when(mockRepository.getAvailableTransitions(mockWorkflow.id))
            .thenAnswer((_) async => mockTransitions);
        when(mockRepository.performTransition(any, any))
            .thenThrow(AppException(message: 'Transition failed', statusCode: 400));

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);
        
        try {
          await notifier.performTransition('transition-1');
        } catch (e) {
          // Expected to throw
        }

        // Assert
        final state = container.read(cvWorkflowProvider('test-cv-id'));
        expect(state.isTransitioning, isFalse);
        expect(state.error, equals('Transition failed'));
      });

      test('should refresh workflow', () async {
        // Arrange
        final mockWorkflow = _createMockWorkflow();
        final mockTransitions = [_createMockTransition()];
        
        when(mockRepository.getCVWorkflow('test-cv-id'))
            .thenAnswer((_) async => mockWorkflow);
        when(mockRepository.getAvailableTransitions(mockWorkflow.id))
            .thenAnswer((_) async => mockTransitions);

        // Act
        final notifier = container.read(cvWorkflowProvider('test-cv-id').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);
        
        await notifier.refreshWorkflow();

        // Assert
        verify(mockRepository.getCVWorkflow('test-cv-id')).called(2);
        verify(mockRepository.getAvailableTransitions(mockWorkflow.id)).called(2);
      });
    });

    group('WorkflowInstancesNotifier', () {
      test('should load instances successfully', () async {
        // Arrange
        final mockInstances = [_createMockWorkflow()];
        when(mockRepository.getWorkflowInstances(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
          status: anyNamed('status'),
          workflowConfigId: anyNamed('workflowConfigId'),
        )).thenAnswer((_) async => mockInstances);

        // Act
        final notifier = container.read(workflowInstancesProvider.notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(workflowInstancesProvider);
        expect(state.instances, equals(mockInstances));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should handle loading error', () async {
        // Arrange
        when(mockRepository.getWorkflowInstances(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
          status: anyNamed('status'),
          workflowConfigId: anyNamed('workflowConfigId'),
        )).thenThrow(AppException(message: 'Failed to load', statusCode: 500));

        // Act
        final notifier = container.read(workflowInstancesProvider.notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(workflowInstancesProvider);
        expect(state.instances, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, equals('Failed to load'));
      });

      test('should load more instances', () async {
        // Arrange
        final firstBatch = [_createMockWorkflow()];
        final secondBatch = [_createMockWorkflow()];
        
        when(mockRepository.getWorkflowInstances(
          page: 1,
          pageSize: anyNamed('pageSize'),
          status: anyNamed('status'),
          workflowConfigId: anyNamed('workflowConfigId'),
        )).thenAnswer((_) async => firstBatch);
        
        when(mockRepository.getWorkflowInstances(
          page: 2,
          pageSize: anyNamed('pageSize'),
          status: anyNamed('status'),
          workflowConfigId: anyNamed('workflowConfigId'),
        )).thenAnswer((_) async => secondBatch);

        // Act
        final notifier = container.read(workflowInstancesProvider.notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);
        
        await notifier.loadMoreInstances();

        // Assert
        final state = container.read(workflowInstancesProvider);
        expect(state.instances.length, equals(2));
        expect(state.currentPage, equals(2));
        expect(state.isLoadingMore, isFalse);
      });

      test('should apply filters', () async {
        // Arrange
        final filteredInstances = [_createMockWorkflow()];
        when(mockRepository.getWorkflowInstances(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
          status: 'active',
          workflowConfigId: 'config-1',
        )).thenAnswer((_) async => filteredInstances);

        // Act
        final notifier = container.read(workflowInstancesProvider.notifier);
        notifier.setFilters(status: 'active', config: 'config-1');
        
        // Wait for load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(workflowInstancesProvider);
        expect(state.statusFilter, equals('active'));
        expect(state.configFilter, equals('config-1'));
        verify(mockRepository.getWorkflowInstances(
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
          status: 'active',
          workflowConfigId: 'config-1',
        )).called(1);
      });
    });

    group('TransitionHistoryNotifier', () {
      test('should load history successfully', () async {
        // Arrange
        final mockHistory = [_createMockTransitionLog()];
        when(mockRepository.getTransitionHistory(
          'instance-1',
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        )).thenAnswer((_) async => mockHistory);

        // Act
        final notifier = container.read(transitionHistoryProvider('instance-1').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(transitionHistoryProvider('instance-1'));
        expect(state.history, equals(mockHistory));
        expect(state.isLoading, isFalse);
        expect(state.error, isNull);
      });

      test('should handle history loading error', () async {
        // Arrange
        when(mockRepository.getTransitionHistory(
          'instance-1',
          page: anyNamed('page'),
          pageSize: anyNamed('pageSize'),
        )).thenThrow(AppException(message: 'History load failed', statusCode: 500));

        // Act
        final notifier = container.read(transitionHistoryProvider('instance-1').notifier);
        
        // Wait for initial load
        await Future.delayed(Duration.zero);

        // Assert
        final state = container.read(transitionHistoryProvider('instance-1'));
        expect(state.history, isEmpty);
        expect(state.isLoading, isFalse);
        expect(state.error, equals('History load failed'));
      });
    });
  });
}

// Helper functions (reuse from integration test)
WorkflowInstanceModel _createMockWorkflow() {
  final states = [
    _createMockState('draft', 'Draft', 'initial', 0),
    _createMockState('review', 'Under Review', 'intermediate', 1),
    _createMockState('published', 'Published', 'final', 2),
  ];

  final transitions = [
    _createMockTransition(),
  ];

  final config = WorkflowConfigurationModel(
    id: 'config-1',
    name: 'CV Approval Workflow',
    description: 'Standard CV approval process',
    entityType: 'cv_profile',
    isActive: true,
    isDefault: true,
    configuration: {},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    createdBy: 'admin',
    states: states,
    transitions: transitions,
  );

  return WorkflowInstanceModel(
    id: 'instance-1',
    workflowConfig: config,
    contentType: 'cv.cvprofile',
    objectId: 'cv-1',
    currentState: states[0],
    startedAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now(),
    startedBy: 'student-1',
    properties: {},
    transitionLogs: [],
  );
}

WorkflowStateModel _createMockState(String code, String name, String type, int order) {
  return WorkflowStateModel(
    id: 'state-$code',
    workflowConfigId: 'config-1',
    code: code,
    name: name,
    description: 'State description for $name',
    stateType: type,
    isActive: true,
    order: order,
    properties: {},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

WorkflowTransitionModel _createMockTransition({bool requiresComment = false}) {
  final fromState = _createMockState('draft', 'Draft', 'initial', 0);
  final toState = _createMockState('review', 'Under Review', 'intermediate', 1);

  return WorkflowTransitionModel(
    id: 'transition-1',
    workflowConfigId: 'config-1',
    name: 'Submit for Review',
    description: 'Submit CV for review process',
    fromState: fromState,
    toState: toState,
    allowedRoles: ['student'],
    validationRules: {},
    isActive: true,
    requiresComment: requiresComment,
    autoTransition: false,
    properties: {},
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

WorkflowTransitionLogModel _createMockTransitionLog() {
  final transition = _createMockTransition();
  
  return WorkflowTransitionLogModel(
    id: 'log-1',
    workflowInstanceId: 'instance-1',
    transition: transition,
    fromState: transition.fromState,
    toState: transition.toState,
    performedBy: 'student-1',
    performedAt: DateTime.now().subtract(const Duration(hours: 2)),
    result: 'success',
    comment: 'CV submitted for review',
    userAgent: 'Flutter App',
    metadata: {},
  );
}