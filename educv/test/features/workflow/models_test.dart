import 'package:flutter_test/flutter_test.dart';
import 'package:educv/features/workflow/data/models/workflow_models.dart';

void main() {
  group('WorkflowConfigurationModel', () {
    test('should create model from valid JSON', () {
      final json = {
        'id': 'config-123',
        'name': 'CV Review Workflow',
        'description': 'Standard CV review process',
        'entity_type': 'cv.profile',
        'is_active': true,
        'is_default': false,
        'configuration': {'key': 'value'},
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
        'created_by': 'user-123',
        'states': [],
        'transitions': [],
      };

      final model = WorkflowConfigurationModel.fromJson(json);

      expect(model.id, 'config-123');
      expect(model.name, 'CV Review Workflow');
      expect(model.description, 'Standard CV review process');
      expect(model.entityType, 'cv.profile');
      expect(model.isActive, true);
      expect(model.isDefault, false);
      expect(model.configuration, {'key': 'value'});
      expect(model.createdBy, 'user-123');
      expect(model.states, isEmpty);
      expect(model.transitions, isEmpty);
    });

    test('should handle null and missing fields gracefully', () {
      final json = <String, dynamic>{};

      final model = WorkflowConfigurationModel.fromJson(json);

      expect(model.id, '');
      expect(model.name, '');
      expect(model.description, '');
      expect(model.entityType, '');
      expect(model.isActive, false);
      expect(model.isDefault, false);
      expect(model.configuration, isEmpty);
      expect(model.createdBy, '');
      expect(model.states, isEmpty);
      expect(model.transitions, isEmpty);
    });

    test('should convert to JSON correctly', () {
      final model = WorkflowConfigurationModel(
        id: 'config-123',
        name: 'Test Workflow',
        description: 'Test Description',
        entityType: 'cv.profile',
        isActive: true,
        isDefault: false,
        configuration: {'test': 'value'},
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        createdBy: 'user-123',
        states: [],
        transitions: [],
      );

      final json = model.toJson();

      expect(json['id'], 'config-123');
      expect(json['name'], 'Test Workflow');
      expect(json['entity_type'], 'cv.profile');
      expect(json['is_active'], true);
      expect(json['configuration'], {'test': 'value'});
    });

    test('should create copy with updated fields', () {
      final original = WorkflowConfigurationModel(
        id: 'config-123',
        name: 'Original Name',
        description: 'Original Description',
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

      final updated = original.copyWith(
        name: 'Updated Name',
        isActive: false,
      );

      expect(updated.name, 'Updated Name');
      expect(updated.isActive, false);
      expect(updated.id, 'config-123'); // Unchanged
      expect(updated.description, 'Original Description'); // Unchanged
    });

    test('should throw FormatException for invalid JSON', () {
      expect(
        () => WorkflowConfigurationModel.fromJson({'invalid': 'data'}),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('WorkflowStateModel', () {
    test('should create model from valid JSON', () {
      final json = {
        'id': 'state-123',
        'workflow_config': 'config-123',
        'code': 'draft',
        'name': 'Draft',
        'description': 'Initial draft state',
        'state_type': 'initial',
        'is_active': true,
        'order': 1,
        'properties': {'color': 'blue'},
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
      };

      final model = WorkflowStateModel.fromJson(json);

      expect(model.id, 'state-123');
      expect(model.workflowConfigId, 'config-123');
      expect(model.code, 'draft');
      expect(model.name, 'Draft');
      expect(model.description, 'Initial draft state');
      expect(model.stateType, 'initial');
      expect(model.isActive, true);
      expect(model.order, 1);
      expect(model.properties, {'color': 'blue'});
    });

    test('should provide state type helpers', () {
      final initialState = WorkflowStateModel(
        id: 'state-1',
        workflowConfigId: 'config-1',
        code: 'initial',
        name: 'Initial',
        description: '',
        stateType: 'initial',
        isActive: true,
        order: 1,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final finalState = WorkflowStateModel(
        id: 'state-2',
        workflowConfigId: 'config-1',
        code: 'final',
        name: 'Final',
        description: '',
        stateType: 'final',
        isActive: true,
        order: 2,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(initialState.isInitial, true);
      expect(initialState.isFinal, false);
      expect(initialState.isTerminal, false);
      expect(initialState.isIntermediate, false);

      expect(finalState.isInitial, false);
      expect(finalState.isFinal, true);
    });

    test('should handle default values', () {
      final json = {
        'id': 'state-123',
      };

      final model = WorkflowStateModel.fromJson(json);

      expect(model.stateType, 'intermediate');
      expect(model.order, 0);
      expect(model.isActive, false);
      expect(model.properties, isEmpty);
    });
  });

  group('WorkflowTransitionModel', () {
    final mockFromState = WorkflowStateModel(
      id: 'from-state',
      workflowConfigId: 'config-1',
      code: 'draft',
      name: 'Draft',
      description: '',
      stateType: 'initial',
      isActive: true,
      order: 1,
      properties: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final mockToState = WorkflowStateModel(
      id: 'to-state',
      workflowConfigId: 'config-1',
      code: 'review',
      name: 'Review',
      description: '',
      stateType: 'intermediate',
      isActive: true,
      order: 2,
      properties: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should create model from valid JSON', () {
      final json = {
        'id': 'transition-123',
        'workflow_config': 'config-123',
        'name': 'Submit for Review',
        'description': 'Submit CV for review',
        'from_state': mockFromState.toJson(),
        'to_state': mockToState.toJson(),
        'allowed_roles': ['student', 'admin'],
        'validation_rules': {'min_completion': 80},
        'is_active': true,
        'requires_comment': false,
        'auto_transition': false,
        'properties': {'priority': 'high'},
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
      };

      final model = WorkflowTransitionModel.fromJson(json);

      expect(model.id, 'transition-123');
      expect(model.name, 'Submit for Review');
      expect(model.allowedRoles, ['student', 'admin']);
      expect(model.validationRules, {'min_completion': 80});
      expect(model.requiresComment, false);
      expect(model.autoTransition, false);
      expect(model.fromState.id, 'from-state');
      expect(model.toState.id, 'to-state');
    });

    test('should handle empty allowed roles', () {
      final json = {
        'id': 'transition-123',
        'from_state': mockFromState.toJson(),
        'to_state': mockToState.toJson(),
        'allowed_roles': null,
      };

      final model = WorkflowTransitionModel.fromJson(json);

      expect(model.allowedRoles, isEmpty);
    });

    test('should parse string list correctly', () {
      final json = {
        'id': 'transition-123',
        'from_state': mockFromState.toJson(),
        'to_state': mockToState.toJson(),
        'allowed_roles': ['admin', 'reviewer', 'student'],
      };

      final model = WorkflowTransitionModel.fromJson(json);

      expect(model.allowedRoles, ['admin', 'reviewer', 'student']);
    });
  });

  group('WorkflowInstanceModel', () {
    final mockConfig = WorkflowConfigurationModel(
      id: 'config-1',
      name: 'Test Config',
      description: '',
      entityType: 'cv.profile',
      isActive: true,
      isDefault: false,
      configuration: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: 'user-1',
      states: [],
      transitions: [],
    );

    final mockState = WorkflowStateModel(
      id: 'state-1',
      workflowConfigId: 'config-1',
      code: 'draft',
      name: 'Draft',
      description: '',
      stateType: 'initial',
      isActive: true,
      order: 1,
      properties: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should create model from valid JSON', () {
      final json = {
        'id': 'instance-123',
        'workflow_config': mockConfig.toJson(),
        'content_type': 'cv_profile',
        'object_id': 'cv-123',
        'current_state': mockState.toJson(),
        'started_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-02T00:00:00Z',
        'started_by': 'user-123',
        'properties': {'priority': 'high'},
        'transition_logs': [],
      };

      final model = WorkflowInstanceModel.fromJson(json);

      expect(model.id, 'instance-123');
      expect(model.contentType, 'cv_profile');
      expect(model.objectId, 'cv-123');
      expect(model.startedBy, 'user-123');
      expect(model.properties, {'priority': 'high'});
      expect(model.transitionLogs, isEmpty);
    });

    test('should calculate available transitions correctly', () {
      final transition1 = WorkflowTransitionModel(
        id: 'trans-1',
        workflowConfigId: 'config-1',
        name: 'Submit',
        description: '',
        fromState: mockState,
        toState: mockState,
        allowedRoles: [],
        validationRules: {},
        isActive: true,
        requiresComment: false,
        autoTransition: false,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final transition2 = WorkflowTransitionModel(
        id: 'trans-2',
        workflowConfigId: 'config-1',
        name: 'Reject',
        description: '',
        fromState: mockState,
        toState: mockState,
        allowedRoles: [],
        validationRules: {},
        isActive: false, // Inactive
        requiresComment: false,
        autoTransition: false,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final configWithTransitions = mockConfig.copyWith(
        transitions: [transition1, transition2],
      );

      final instance = WorkflowInstanceModel(
        id: 'instance-1',
        workflowConfig: configWithTransitions,
        contentType: 'cv_profile',
        objectId: 'cv-1',
        currentState: mockState,
        startedAt: DateTime.now(),
        updatedAt: DateTime.now(),
        startedBy: 'user-1',
        properties: {},
        transitionLogs: [],
      );

      final availableTransitions = instance.availableTransitions;

      expect(availableTransitions.length, 1);
      expect(availableTransitions.first.id, 'trans-1');
    });
  });

  group('WorkflowTransitionLogModel', () {
    final mockTransition = WorkflowTransitionModel(
      id: 'trans-1',
      workflowConfigId: 'config-1',
      name: 'Submit',
      description: '',
      fromState: WorkflowStateModel(
        id: 'from-state',
        workflowConfigId: 'config-1',
        code: 'draft',
        name: 'Draft',
        description: '',
        stateType: 'initial',
        isActive: true,
        order: 1,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      toState: WorkflowStateModel(
        id: 'to-state',
        workflowConfigId: 'config-1',
        code: 'review',
        name: 'Review',
        description: '',
        stateType: 'intermediate',
        isActive: true,
        order: 2,
        properties: {},
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      allowedRoles: [],
      validationRules: {},
      isActive: true,
      requiresComment: false,
      autoTransition: false,
      properties: {},
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    test('should create model from valid JSON', () {
      final json = {
        'id': 'log-123',
        'workflow_instance': 'instance-123',
        'transition': mockTransition.toJson(),
        'from_state': mockTransition.fromState.toJson(),
        'to_state': mockTransition.toState.toJson(),
        'performed_by': 'user-123',
        'performed_at': '2024-01-01T00:00:00Z',
        'result': 'success',
        'comment': 'Approved for review',
        'ip_address': '192.168.1.1',
        'user_agent': 'Mozilla/5.0',
        'metadata': {'source': 'web'},
      };

      final model = WorkflowTransitionLogModel.fromJson(json);

      expect(model.id, 'log-123');
      expect(model.workflowInstanceId, 'instance-123');
      expect(model.performedBy, 'user-123');
      expect(model.result, 'success');
      expect(model.comment, 'Approved for review');
      expect(model.ipAddress, '192.168.1.1');
      expect(model.userAgent, 'Mozilla/5.0');
      expect(model.metadata, {'source': 'web'});
    });

    test('should provide result helpers', () {
      final successLog = WorkflowTransitionLogModel(
        id: 'log-1',
        workflowInstanceId: 'instance-1',
        transition: mockTransition,
        fromState: mockTransition.fromState,
        toState: mockTransition.toState,
        performedBy: 'user-1',
        performedAt: DateTime.now(),
        result: 'success',
        comment: '',
        userAgent: '',
        metadata: {},
      );

      final failedLog = successLog.copyWith(result: 'failed');
      final rejectedLog = successLog.copyWith(result: 'rejected');

      expect(successLog.isSuccess, true);
      expect(successLog.isFailed, false);
      expect(successLog.isRejected, false);

      expect(failedLog.isSuccess, false);
      expect(failedLog.isFailed, true);
      expect(failedLog.isRejected, false);

      expect(rejectedLog.isSuccess, false);
      expect(rejectedLog.isFailed, false);
      expect(rejectedLog.isRejected, true);
    });

    test('should handle null IP address', () {
      final json = {
        'id': 'log-123',
        'transition': mockTransition.toJson(),
        'from_state': mockTransition.fromState.toJson(),
        'to_state': mockTransition.toState.toJson(),
        'ip_address': null,
      };

      final model = WorkflowTransitionLogModel.fromJson(json);

      expect(model.ipAddress, null);
    });
  });

  group('WorkflowTransitionRequest', () {
    test('should convert to JSON correctly', () {
      final request = WorkflowTransitionRequest(
        transitionId: 'trans-123',
        comment: 'Test comment',
        metadata: {'key': 'value'},
      );

      final json = request.toJson();

      expect(json['transition_id'], 'trans-123');
      expect(json['comment'], 'Test comment');
      expect(json['metadata'], {'key': 'value'});
    });

    test('should handle null optional fields', () {
      final request = WorkflowTransitionRequest(
        transitionId: 'trans-123',
      );

      final json = request.toJson();

      expect(json['transition_id'], 'trans-123');
      expect(json.containsKey('comment'), false);
      expect(json.containsKey('metadata'), false);
    });
  });

  group('WorkflowDashboardModel', () {
    test('should create model from valid JSON', () {
      final json = {
        'total_instances': 100,
        'active_instances': 25,
        'completed_instances': 70,
        'state_distribution': {
          'draft': 10,
          'review': 15,
          'approved': 70,
          'rejected': 5,
        },
        'recent_instances': [],
        'statistics': {'avg_completion_time': 5.5},
      };

      final model = WorkflowDashboardModel.fromJson(json);

      expect(model.totalInstances, 100);
      expect(model.activeInstances, 25);
      expect(model.completedInstances, 70);
      expect(model.stateDistribution['draft'], 10);
      expect(model.stateDistribution['review'], 15);
      expect(model.statistics['avg_completion_time'], 5.5);
    });

    test('should handle empty data', () {
      final json = <String, dynamic>{};

      final model = WorkflowDashboardModel.fromJson(json);

      expect(model.totalInstances, 0);
      expect(model.activeInstances, 0);
      expect(model.completedInstances, 0);
      expect(model.stateDistribution, isEmpty);
      expect(model.recentInstances, isEmpty);
      expect(model.statistics, isEmpty);
    });

    test('should convert to JSON correctly', () {
      final model = WorkflowDashboardModel(
        totalInstances: 50,
        activeInstances: 10,
        completedInstances: 40,
        stateDistribution: {'draft': 5, 'approved': 45},
        recentInstances: [],
        statistics: {'test': 'value'},
      );

      final json = model.toJson();

      expect(json['total_instances'], 50);
      expect(json['active_instances'], 10);
      expect(json['completed_instances'], 40);
      expect(json['state_distribution'], {'draft': 5, 'approved': 45});
      expect(json['statistics'], {'test': 'value'});
    });
  });

  group('DateTime parsing', () {
    test('should parse valid ISO 8601 strings', () {
      final json = {
        'id': 'test',
        'created_at': '2024-01-01T12:30:45Z',
        'updated_at': '2024-01-02T08:15:30.123Z',
      };

      final model = WorkflowConfigurationModel.fromJson({
        ...json,
        'name': 'Test',
        'description': '',
        'entity_type': 'test',
        'is_active': true,
        'is_default': false,
        'configuration': {},
        'created_by': 'user',
        'states': [],
        'transitions': [],
      });

      expect(model.createdAt.year, 2024);
      expect(model.createdAt.month, 1);
      expect(model.createdAt.day, 1);
      expect(model.updatedAt.year, 2024);
      expect(model.updatedAt.month, 1);
      expect(model.updatedAt.day, 2);
    });

    test('should handle invalid date strings gracefully', () {
      final json = {
        'id': 'test',
        'created_at': 'invalid-date',
        'updated_at': null,
      };

      final model = WorkflowConfigurationModel.fromJson({
        ...json,
        'name': 'Test',
        'description': '',
        'entity_type': 'test',
        'is_active': true,
        'is_default': false,
        'configuration': {},
        'created_by': 'user',
        'states': [],
        'transitions': [],
      });

      // Should use current time as fallback
      expect(model.createdAt, isA<DateTime>());
      expect(model.updatedAt, isA<DateTime>());
    });
  });
}