# Workflow Control System - Frontend Integration

## Overview

The Workflow Control System provides comprehensive frontend integration for managing CV lifecycle states, transitions, and approval processes. This system enables role-based workflow management with real-time state tracking, audit logging, and user-friendly interfaces.

## Architecture

### Clean Architecture Implementation

```
lib/features/workflow/
├── data/
│   ├── models/           # Data models with JSON serialization
│   └── repositories/     # Repository implementations
├── domain/              # Business logic and interfaces
│   └── workflow_repository.dart
└── presentation/        # UI layer
    ├── providers/       # State management (Riverpod)
    ├── screens/         # Full-screen workflows
    └── widgets/         # Reusable UI components
```

### Key Components

#### 1. Data Models (`data/models/workflow_models.dart`)

**WorkflowConfigurationModel**
- Defines workflow structure and rules
- Contains states, transitions, and validation rules
- Supports dynamic configuration without code changes

**WorkflowInstanceModel**
- Represents active workflow for specific CV
- Tracks current state and history
- Provides available transitions based on current state

**WorkflowTransitionModel**
- Defines allowed state transitions
- Includes role-based permissions
- Supports validation rules and comment requirements

**WorkflowTransitionLogModel**
- Immutable audit trail of all transitions
- Records who, when, why, and result of each transition
- Includes IP address and user agent for security

#### 2. Repository Layer (`data/repositories/workflow_repository_impl.dart`)

Implements `WorkflowRepository` interface with:
- RESTful API integration using Dio HTTP client
- Comprehensive error handling with `AppException`
- Automatic retry logic for network failures
- Response caching for improved performance

#### 3. State Management (`presentation/providers/workflow_provider.dart`)

**CVWorkflowNotifier**
- Manages workflow state for specific CV
- Handles transition execution with optimistic updates
- Provides real-time error handling and loading states

**WorkflowInstancesNotifier**
- Manages list of workflow instances with pagination
- Supports filtering by status and configuration
- Implements infinite scrolling for large datasets

**TransitionHistoryNotifier**
- Manages transition history with pagination
- Provides chronological audit trail
- Supports real-time updates

#### 4. UI Components

**WorkflowStateWidget**
- Displays current workflow state with visual indicators
- Shows state type (initial, intermediate, final, terminal)
- Provides detailed workflow information

**WorkflowTransitionActionsWidget**
- Lists available transitions based on user permissions
- Handles transition confirmation with comments
- Provides role-based action filtering

**WorkflowIntegrationWidget**
- Embeddable component for CV detail screens
- Shows workflow status, quick actions, and recent history
- Supports both compact and expanded views

**WorkflowDashboardStatsWidget**
- Displays workflow statistics and metrics
- Shows state distribution and success rates
- Provides visual progress indicators

## Usage Examples

### 1. Basic Workflow Integration

```dart
// Embed workflow status in CV detail screen
WorkflowIntegrationWidget(
  cvId: 'cv-123',
  showActions: true,
  showFullHistory: false,
)
```

### 2. Full Workflow Management Screen

```dart
// Navigate to complete workflow management
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => WorkflowControlScreen(),
  ),
)
```

### 3. Role-Based Action Filtering

```dart
// Show actions based on user permissions
ConditionalWorkflowActions(
  transitions: availableTransitions,
  onTransition: (transitionId, comment, metadata) async {
    await performTransition(transitionId, comment, metadata);
  },
)
```

### 4. Workflow Dashboard

```dart
// Display workflow statistics
Consumer(
  builder: (context, ref, child) {
    final dashboardAsync = ref.watch(workflowDashboardProvider(null));
    
    return dashboardAsync.when(
      data: (dashboard) => WorkflowDashboardStatsWidget(
        dashboard: dashboard,
      ),
      loading: () => AppLoader(),
      error: (error, stack) => AppErrorState(
        message: error.toString(),
        onRetry: () => ref.refresh(workflowDashboardProvider(null)),
      ),
    );
  },
)
```

## API Integration

### Endpoints Used

| Endpoint | Method | Purpose |
|----------|--------|---------|
| `/workflow/cv/{cvId}/` | GET | Get workflow for specific CV |
| `/workflow/instances/` | GET | List workflow instances |
| `/workflow/instances/{id}/` | GET | Get specific workflow instance |
| `/workflow/instances/{id}/transition/` | POST | Perform state transition |
| `/workflow/instances/{id}/available-transitions/` | GET | Get available transitions |
| `/workflow/instances/{id}/history/` | GET | Get transition history |
| `/workflow/configurations/` | GET | List workflow configurations |
| `/workflow/dashboard/` | GET | Get dashboard statistics |

### Request/Response Format

All API responses follow the standard format:

```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": { /* response data */ }
}
```

Error responses:

```json
{
  "success": false,
  "message": "Operation failed",
  "error": {
    "message": "Detailed error message",
    "details": { /* error details */ }
  }
}
```

### Transition Request Format

```json
{
  "transition_id": "uuid-of-transition",
  "comment": "Optional comment for audit trail",
  "metadata": {
    "source": "web",
    "additional_data": "value"
  }
}
```

## State Management Patterns

### 1. Loading States

```dart
class CVWorkflowState {
  final bool isLoading;          // Initial data loading
  final bool isTransitioning;    // Transition in progress
  final bool isRefreshing;       // Manual refresh
  
  bool get canTransition => !isTransitioning && hasWorkflow;
}
```

### 2. Error Handling

```dart
// Automatic error recovery
if (state.error != null) {
  return AppErrorState(
    message: state.error!,
    onRetry: () => ref.read(provider.notifier).retry(),
  );
}
```

### 3. Optimistic Updates

```dart
// Update UI immediately, rollback on error
Future<void> performTransition(String transitionId) async {
  // Optimistic update
  state = state.copyWith(isTransitioning: true);
  
  try {
    final result = await repository.performTransition(instanceId, request);
    state = state.copyWith(
      workflow: result,
      isTransitioning: false,
    );
  } catch (e) {
    // Rollback on error
    state = state.copyWith(
      isTransitioning: false,
      error: e.toString(),
    );
    rethrow;
  }
}
```

## Role-Based Permissions

### Permission Checking

```dart
// Check if user can perform transition
bool canPerformTransition(WorkflowTransitionModel transition, String userRole) {
  return transition.allowedRoles.isEmpty || 
         transition.allowedRoles.contains(userRole) ||
         userRole == 'admin';
}
```

### Conditional UI Rendering

```dart
// Show actions based on permissions
WorkflowPermissionChecker(
  transition: transition,
  builder: (hasPermission) => hasPermission
    ? TransitionButton(transition: transition)
    : PermissionDeniedWidget(),
)
```

### Role Hierarchy

1. **Admin** - Full access to all workflows and transitions
2. **Reviewer** - Can review and approve/reject CVs
3. **Supervisor** - Can oversee workflow progress
4. **Student** - Can submit CVs and view their own workflow status

## Testing Strategy

### 1. Unit Tests (`test/features/workflow/models_test.dart`)

- Data model serialization/deserialization
- Business logic validation
- Edge case handling
- Error scenarios

```bash
# Run unit tests
flutter test test/features/workflow/models_test.dart --coverage
```

### 2. Repository Tests (`test/features/workflow/workflow_repository_test.dart`)

- API integration testing with mocked HTTP client
- Error handling and retry logic
- Response parsing and validation
- Network failure scenarios

### 3. Widget Tests (`test/features/workflow/workflow_widget_test.dart`)

- UI component rendering
- User interaction handling
- State change verification
- Accessibility compliance

### 4. Integration Tests (`test/features/workflow/workflow_integration_test.dart`)

- End-to-end user flows
- State management integration
- API communication
- Error recovery

### Test Execution

```bash
# Unix/Linux/macOS
./test/features/workflow/run_tests.sh

# Windows
./test/features/workflow/run_tests.ps1
```

### Coverage Requirements

- **Minimum Coverage**: 90%
- **Critical Paths**: 100% (transitions, permissions, error handling)
- **UI Components**: 85%
- **Integration Flows**: 95%

## Performance Considerations

### 1. Lazy Loading

```dart
// Load workflow data only when needed
final workflowProvider = FutureProvider.family<WorkflowInstanceModel?, String>(
  (ref, cvId) async {
    if (cvId.isEmpty) return null;
    return ref.watch(workflowRepositoryProvider).getCVWorkflow(cvId);
  },
);
```

### 2. Pagination

```dart
// Implement infinite scrolling for large datasets
Future<void> loadMoreInstances() async {
  if (state.isLoadingMore || !state.hasMore) return;
  
  final nextPage = state.currentPage + 1;
  final newInstances = await repository.getWorkflowInstances(page: nextPage);
  
  state = state.copyWith(
    instances: [...state.instances, ...newInstances],
    currentPage: nextPage,
    hasMore: newInstances.length >= pageSize,
  );
}
```

### 3. Caching Strategy

- **Workflow Configurations**: Cache for 1 hour
- **Instance Data**: Cache for 5 minutes
- **Transition History**: Cache for 10 minutes
- **Dashboard Stats**: Cache for 2 minutes

### 4. Memory Management

```dart
// Dispose controllers and listeners
@override
void dispose() {
  _commentController.dispose();
  _scrollController.dispose();
  super.dispose();
}
```

## Security Considerations

### 1. Input Validation

```dart
// Validate transition requests
class WorkflowTransitionRequest {
  final String transitionId;
  final String? comment;
  
  WorkflowTransitionRequest({
    required this.transitionId,
    this.comment,
  }) {
    if (transitionId.isEmpty) {
      throw ArgumentError('Transition ID cannot be empty');
    }
    if (comment != null && comment!.length > 1000) {
      throw ArgumentError('Comment too long');
    }
  }
}
```

### 2. Permission Enforcement

```dart
// Always verify permissions on client side
// Note: Server-side validation is the authoritative source
bool hasPermission = transition.allowedRoles.isEmpty || 
                    transition.allowedRoles.contains(currentUserRole);

if (!hasPermission) {
  throw UnauthorizedException('Insufficient permissions');
}
```

### 3. Audit Trail

All user actions are automatically logged:
- Transition attempts (successful and failed)
- Permission violations
- Data access patterns
- Error occurrences

## Deployment Guidelines

### 1. Environment Configuration

```dart
// Configure API endpoints per environment
class ApiConstants {
  static String get baseUrl {
    const environment = String.fromEnvironment('ENVIRONMENT');
    switch (environment) {
      case 'production':
        return 'https://api.educv.com/api/v1';
      case 'staging':
        return 'https://staging-api.educv.com/api/v1';
      default:
        return 'http://localhost:8000/api/v1';
    }
  }
}
```

### 2. Build Configuration

```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/env/.env
    - assets/env/.env.production
```

### 3. CI/CD Integration

```yaml
# .github/workflows/workflow-tests.yml
name: Workflow Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: ./test/features/workflow/run_tests.sh
      - uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## Troubleshooting

### Common Issues

1. **Network Timeouts**
   ```dart
   // Increase timeout for slow networks
   final dio = Dio(BaseOptions(
     connectTimeout: Duration(seconds: 30),
     receiveTimeout: Duration(seconds: 30),
   ));
   ```

2. **State Synchronization**
   ```dart
   // Force refresh when data seems stale
   ref.invalidate(cvWorkflowProvider(cvId));
   ```

3. **Permission Errors**
   ```dart
   // Check user authentication status
   final authState = ref.watch(authProvider);
   if (!authState.isAuthenticated) {
     // Redirect to login
   }
   ```

### Debug Mode

```dart
// Enable debug logging
class WorkflowRepositoryImpl {
  static const bool _debugMode = kDebugMode;
  
  void _log(String message) {
    if (_debugMode) {
      print('[Workflow] $message');
    }
  }
}
```

## Future Enhancements

### Planned Features

1. **Real-time Updates**
   - WebSocket integration for live workflow updates
   - Push notifications for state changes

2. **Advanced Analytics**
   - Workflow performance metrics
   - Bottleneck identification
   - User behavior analysis

3. **Workflow Designer**
   - Visual workflow configuration
   - Drag-and-drop state management
   - Custom validation rules

4. **Mobile Optimization**
   - Offline workflow support
   - Mobile-specific UI patterns
   - Push notification integration

### API Evolution

- GraphQL integration for efficient data fetching
- Batch operations for multiple transitions
- Webhook support for external integrations
- Advanced filtering and search capabilities

## Support and Maintenance

### Code Quality Standards

- **Linting**: Follow `analysis_options.yaml` rules
- **Formatting**: Use `dart format` consistently
- **Documentation**: Maintain comprehensive inline documentation
- **Testing**: Achieve 90%+ test coverage

### Performance Monitoring

- Monitor API response times
- Track memory usage patterns
- Analyze user interaction metrics
- Monitor error rates and types

### Version Compatibility

- Maintain backward compatibility for 2 major versions
- Provide migration guides for breaking changes
- Support gradual rollout of new features
- Maintain comprehensive changelog

---

For additional support or questions, please refer to the main project documentation or contact the development team.