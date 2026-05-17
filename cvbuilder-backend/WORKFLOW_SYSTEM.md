# Enterprise Workflow Control System

## Overview

The Enterprise Workflow Control System is a production-ready, configuration-driven workflow management solution for the CV Builder platform. It provides comprehensive state management, role-based transitions, validation rules, and audit logging for CV lifecycle management.

## Key Features

✅ **Configuration-Driven Design**: No hardcoded business logic  
✅ **Role-Based State Transitions**: Fine-grained permission control  
✅ **Validation Rules Engine**: Configurable business rules  
✅ **Comprehensive Audit Logging**: Every action tracked with full context  
✅ **REST API Endpoints**: Complete API for workflow operations  
✅ **Dashboard Integration**: Analytics and monitoring capabilities  
✅ **Enterprise-Grade Security**: Authentication, authorization, and data protection  
✅ **Extensive Testing**: Unit, integration, and API tests  

## Architecture

### Core Components

1. **Models Layer**
   - `WorkflowConfiguration`: Workflow definitions and metadata
   - `WorkflowState`: Individual states in the workflow
   - `WorkflowTransition`: Allowed transitions between states
   - `WorkflowInstance`: Active workflow instances for entities
   - `WorkflowTransitionLog`: Immutable audit trail
   - `WorkflowRule`: Configurable validation rules
   - `WorkflowNotification`: Workflow-triggered notifications

2. **Services Layer**
   - `WorkflowService`: Core business logic and state management
   - `WorkflowRuleValidator`: Rule validation engine

3. **Permissions Layer**
   - Role-based access control
   - Object-level permissions
   - Dynamic permission checking

4. **API Layer**
   - RESTful endpoints for all operations
   - Comprehensive serializers
   - Error handling and validation

## Default CV Workflow

The system includes a pre-configured 5-state CV review workflow:

```
Draft → Under Review → Approved → Published
          ↓
    Needs Revision ↗
```

### States

| State | Type | Description | Available To |
|-------|------|-------------|--------------|
| **Draft** | Initial | CV being created/edited | Student |
| **Under Review** | Intermediate | Administrative review | Admin |
| **Needs Revision** | Intermediate | Changes required | Student |
| **Approved** | Intermediate | Ready for publication | Admin |
| **Published** | Final | Publicly available | All |

### Transitions

| Transition | From | To | Roles | Comment Required |
|------------|------|----|----|------------------|
| Submit for Review | Draft | Under Review | Student | No |
| Approve | Under Review | Approved | Admin | No |
| Request Revision | Under Review | Needs Revision | Admin | Yes |
| Resubmit | Needs Revision | Under Review | Student | No |
| Publish | Approved | Published | Admin | No |

## API Endpoints

All endpoints are under `/api/v1/workflow/`

### Core Workflow Operations

#### Get/Initialize CV Workflow
```http
GET /api/v1/workflow/cv/{cv_id}/
POST /api/v1/workflow/cv/{cv_id}/
```

**Response:**
```json
{
  "success": true,
  "message": "CV workflow retrieved successfully.",
  "data": {
    "instance": {
      "id": "uuid",
      "current_state": {
        "code": "draft",
        "name": "Draft",
        "type": "initial"
      },
      "started_at": "2024-01-15T10:30:00Z",
      "updated_at": "2024-01-15T10:30:00Z"
    },
    "available_transitions": [
      {
        "id": "uuid",
        "name": "Submit for Review",
        "to_state": {
          "code": "under_review",
          "name": "Under Review"
        },
        "requires_comment": false,
        "validation_passed": true,
        "validation_errors": []
      }
    ],
    "permissions": {
      "can_view": true,
      "can_transition": true,
      "can_manage": false,
      "is_owner": true,
      "available_actions": ["submit_for_review"]
    }
  }
}
```

#### Perform State Transition
```http
POST /api/v1/workflow/instances/{instance_id}/transition/
```

**Request:**
```json
{
  "to_state": "under_review",
  "comment": "Ready for review",
  "additional_data": {
    "completion_percentage": 85
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Transition to Under Review completed successfully.",
  "data": {
    "id": "uuid",
    "from_state": {
      "code": "draft",
      "name": "Draft"
    },
    "to_state": {
      "code": "under_review",
      "name": "Under Review"
    },
    "performed_by": "student@university.edu",
    "performed_at": "2024-01-15T10:35:00Z",
    "result": "success",
    "comment": "Ready for review"
  }
}
```

### Workflow Information

#### Get Workflow Status
```http
GET /api/v1/workflow/instances/{instance_id}/status/
```

#### Get Workflow History
```http
GET /api/v1/workflow/instances/{instance_id}/history/
```

#### Get Available Transitions
```http
GET /api/v1/workflow/instances/{instance_id}/available_transitions/
```

### Dashboard and Analytics

#### Workflow Dashboard
```http
GET /api/v1/workflow/dashboard/
```

**Response:**
```json
{
  "success": true,
  "data": {
    "total_workflows": 150,
    "active_workflows": 145,
    "pending_reviews": 23,
    "completed_workflows": 87,
    "workflow_states_summary": {
      "Draft": 45,
      "Under Review": 23,
      "Needs Revision": 12,
      "Approved": 15,
      "Published": 87
    },
    "recent_transitions": [...]
  }
}
```

### Admin Endpoints

#### Workflow Configuration Management
```http
GET /api/v1/workflow/configurations/
POST /api/v1/workflow/configurations/
PUT /api/v1/workflow/configurations/{id}/
DELETE /api/v1/workflow/configurations/{id}/
POST /api/v1/workflow/configurations/{id}/activate/
POST /api/v1/workflow/configurations/{id}/deactivate/
```

## Validation Rules

The system supports configurable validation rules that are checked before transitions:

### Rule Types
- **Validation Rules**: Must pass for transition to proceed
- **Condition Rules**: Control when transitions are available
- **Action Rules**: Trigger additional actions on transition

### Operators
- `eq` (equals), `ne` (not equals)
- `gt` (greater than), `lt` (less than)
- `gte` (greater than or equal), `lte` (less than or equal)
- `contains`, `in` (in list)
- `exists`, `not_exists`
- `custom` (custom function)

### Example Rules
```json
{
  "field_path": "completion_percentage",
  "operator": "gte",
  "expected_value": 70,
  "error_message": "CV must be at least 70% complete"
}
```

## Security Features

### Authentication & Authorization
- JWT-based authentication required for all endpoints
- Role-based access control (Student/Admin)
- Object-level permissions (students can only access their own CVs)

### Audit Logging
- Every transition logged with full context
- IP address and user agent tracking
- Immutable audit trail
- Integration with existing audit system

### Data Protection
- UUID primary keys (no sequential IDs exposed)
- Soft delete support
- Rate limiting on API endpoints
- Input validation and sanitization

## Installation & Setup

### 1. Database Migration
```bash
python manage.py migrate
```

### 2. Initialize Default Workflow
```bash
python manage.py init_cv_workflow --admin-email admin@university.edu
```

### 3. Verify Installation
```bash
python manage.py check
```

## Configuration

### Environment Variables
```env
# Workflow-specific settings (optional)
WORKFLOW_RATE_LIMIT=10/hour
WORKFLOW_NOTIFICATION_ENABLED=true
WORKFLOW_AUDIT_RETENTION_DAYS=365
```

### Django Settings
The workflow system is automatically configured when added to `INSTALLED_APPS`:

```python
LOCAL_APPS = [
    # ... other apps
    'apps.workflow',
]
```

## Usage Examples

### Initialize Workflow for CV
```python
from apps.workflow.services.workflow_service import WorkflowService
from apps.cv.models import CVProfile

workflow_service = WorkflowService()
cv = CVProfile.objects.get(id=cv_id)

# Initialize workflow
instance = workflow_service.initialize_workflow(
    entity=cv,
    user=request.user
)
```

### Perform State Transition
```python
# Submit CV for review
transition_log = workflow_service.transition_state(
    instance=instance,
    to_state_code='under_review',
    user=request.user,
    comment='Ready for review',
    request=request
)
```

### Check Available Transitions
```python
# Get available transitions for current user
transitions = workflow_service.get_available_transitions(
    instance, request.user
)
```

## Testing

### Run All Tests
```bash
python manage.py test apps.workflow
```

### Run Specific Test Categories
```bash
# Model tests
python manage.py test apps.workflow.tests.test_models

# Service tests
python manage.py test apps.workflow.tests.test_services

# API tests
python manage.py test apps.workflow.tests.test_api
```

### Test Coverage
- **Models**: 100% coverage of all model functionality
- **Services**: Complete business logic testing
- **API**: Full endpoint testing with authentication
- **Permissions**: Role-based access control validation
- **Integration**: End-to-end workflow scenarios

## Monitoring & Maintenance

### Health Checks
The workflow system integrates with the existing health check system:
- Database connectivity
- Configuration validation
- Service availability

### Logging
Comprehensive logging at multiple levels:
- **INFO**: Normal operations and transitions
- **WARNING**: Validation failures and permission denials
- **ERROR**: System errors and exceptions
- **SECURITY**: Authentication and authorization events

### Metrics
Key metrics tracked:
- Transition success/failure rates
- Average time in each state
- User activity patterns
- System performance metrics

## Troubleshooting

### Common Issues

#### 1. Migration Errors
```bash
# Reset migrations if needed
python manage.py migrate workflow zero
python manage.py migrate workflow
```

#### 2. Permission Denied Errors
- Verify user roles are correctly assigned
- Check workflow configuration permissions
- Ensure object-level permissions are working

#### 3. Validation Rule Failures
- Check rule configuration syntax
- Verify field paths are correct
- Test rules with sample data

### Debug Mode
Enable debug logging for troubleshooting:
```python
LOGGING = {
    'loggers': {
        'apps.workflow': {
            'level': 'DEBUG',
            'handlers': ['console', 'file'],
        }
    }
}
```

## Performance Considerations

### Database Optimization
- Proper indexing on all foreign keys
- Efficient queries with select_related/prefetch_related
- Connection pooling for high-traffic scenarios

### Caching
- Workflow configurations cached for performance
- Available transitions cached per user session
- Dashboard data cached with appropriate TTL

### Scalability
- Stateless design for horizontal scaling
- Async notification processing
- Bulk operations for large datasets

## Roadmap

### Planned Features
- [ ] Workflow templates and cloning
- [ ] Advanced notification channels (SMS, Slack, etc.)
- [ ] Workflow analytics and reporting
- [ ] Integration with external systems
- [ ] Workflow versioning and rollback
- [ ] Advanced rule engine with scripting support

### Version History
- **v1.0**: Initial release with core functionality
- **v1.1**: Enhanced validation rules and notifications
- **v1.2**: Dashboard improvements and analytics

## Support

For technical support and questions:
- Check the troubleshooting section above
- Review test cases for usage examples
- Consult the API documentation for endpoint details
- Check logs for detailed error information

## License

This workflow system is part of the EduCV platform, commissioned by the university for official deployment.