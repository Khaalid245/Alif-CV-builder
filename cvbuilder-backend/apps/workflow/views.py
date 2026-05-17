"""
Enterprise Workflow API Views.

Provides comprehensive REST API endpoints for workflow management with
role-based access control, validation, and audit logging.
"""
import logging
from typing import Dict, Any
from rest_framework import status, viewsets
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from django.shortcuts import get_object_or_404
from django.contrib.contenttypes.models import ContentType
from django.db.models import Count, Q
from django.utils import timezone

from apps.core.responses import success_response, error_response
from apps.cv.models import CVProfile
from .models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition,
    WorkflowInstance, WorkflowTransitionLog, WorkflowRule
)
from .serializers import (
    WorkflowConfigurationSerializer, WorkflowInstanceSerializer,
    WorkflowTransitionLogSerializer, WorkflowTransitionRequestSerializer,
    WorkflowStatusSerializer, WorkflowDashboardSerializer,
    AvailableTransitionSerializer, WorkflowHistorySerializer,
    WorkflowInitializationSerializer
)
from .permissions.workflow_permissions import (
    CanViewWorkflow, CanTransitionWorkflow, CanManageWorkflow,
    CVWorkflowPermission, get_workflow_permissions_for_user
)
from .services.workflow_service import WorkflowService
from .exceptions import (
    WorkflowError, InvalidTransitionError, ValidationRuleError,
    WorkflowNotFoundError, StateNotFoundError
)

logger = logging.getLogger(__name__)


class WorkflowInstanceViewSet(viewsets.ReadOnlyModelViewSet):
    """
    ViewSet for workflow instance operations.
    Provides read-only access to workflow instances with proper permissions.
    """
    
    serializer_class = WorkflowInstanceSerializer
    permission_classes = [IsAuthenticated, CanViewWorkflow]
    
    def get_queryset(self):
        """Get workflow instances based on user permissions."""
        user = self.request.user
        
        if user.role == user.Role.ADMIN:
            # Admins can see all workflow instances
            return WorkflowInstance.objects.select_related(
                'workflow_config', 'current_state', 'started_by'
            ).prefetch_related('workflow_config__states')
        
        elif user.role == user.Role.STUDENT:
            # Students can only see their own CV workflows
            cv_content_type = ContentType.objects.get_for_model(CVProfile)
            user_cvs = CVProfile.objects.filter(student=user).values_list('id', flat=True)
            
            return WorkflowInstance.objects.filter(
                content_type=cv_content_type,
                object_id__in=[str(cv_id) for cv_id in user_cvs]
            ).select_related(
                'workflow_config', 'current_state', 'started_by'
            ).prefetch_related('workflow_config__states')
        
        return WorkflowInstance.objects.none()
    
    @action(detail=True, methods=['get'])
    def status(self, request, pk=None):
        """Get detailed status of a workflow instance."""
        instance = self.get_object()
        workflow_service = WorkflowService()
        
        try:
            # Get available transitions
            available_transitions = workflow_service.get_available_transitions(
                instance, request.user
            )
            
            # Get user permissions
            permissions = get_workflow_permissions_for_user(request.user, instance)
            
            status_data = {
                'instance_id': str(instance.id),
                'workflow_name': instance.workflow_config.name,
                'current_state': {
                    'code': instance.current_state.code,
                    'name': instance.current_state.name,
                    'type': instance.current_state.state_type
                },
                'started_at': instance.started_at,
                'updated_at': instance.updated_at,
                'properties': instance.properties,
                'permissions': permissions,
                'available_transitions': available_transitions
            }
            
            serializer = WorkflowStatusSerializer(status_data)
            return success_response(
                'Workflow status retrieved successfully.',
                serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get workflow status for {pk}: {str(e)}")
            return error_response(
                'Failed to retrieve workflow status.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['get'])
    def history(self, request, pk=None):
        """Get transition history for a workflow instance."""
        instance = self.get_object()
        workflow_service = WorkflowService()
        
        try:
            limit = int(request.query_params.get('limit', 50))
            history = workflow_service.get_workflow_history(instance, limit)
            
            serializer = WorkflowHistorySerializer(history, many=True)
            return success_response(
                'Workflow history retrieved successfully.',
                serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get workflow history for {pk}: {str(e)}")
            return error_response(
                'Failed to retrieve workflow history.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    @action(detail=True, methods=['get'])
    def available_transitions(self, request, pk=None):
        """Get available transitions for the current state."""
        instance = self.get_object()
        workflow_service = WorkflowService()
        
        try:
            transitions = workflow_service.get_available_transitions(
                instance, request.user
            )
            
            serializer = AvailableTransitionSerializer(transitions, many=True)
            return success_response(
                'Available transitions retrieved successfully.',
                serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get available transitions for {pk}: {str(e)}")
            return error_response(
                'Failed to retrieve available transitions.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class WorkflowTransitionView(APIView):
    """
    API view for performing workflow state transitions.
    Handles transition requests with validation and audit logging.
    """
    
    permission_classes = [IsAuthenticated, CanTransitionWorkflow]
    
    def post(self, request, instance_id):
        """Perform a workflow state transition."""
        try:
            # Get workflow instance
            instance = get_object_or_404(
                WorkflowInstance.objects.select_related(
                    'workflow_config', 'current_state'
                ),
                id=instance_id
            )
            
            # Check object-level permissions
            self.check_object_permissions(request, instance)
            
            # Validate request data
            serializer = WorkflowTransitionRequestSerializer(data=request.data)
            if not serializer.is_valid():
                return error_response(
                    'Invalid transition request.',
                    serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Perform transition
            workflow_service = WorkflowService()
            transition_log = workflow_service.transition_state(
                instance=instance,
                to_state_code=serializer.validated_data['to_state'],
                user=request.user,
                comment=serializer.validated_data.get('comment', ''),
                request=request,
                additional_data=serializer.validated_data.get('additional_data')
            )
            
            # Return transition result
            log_serializer = WorkflowTransitionLogSerializer(transition_log)
            return success_response(
                f'Transition to {transition_log.to_state.name} completed successfully.',
                log_serializer.data,
                status_code=status.HTTP_200_OK
            )
            
        except WorkflowInstance.DoesNotExist:
            return error_response(
                'Workflow instance not found.',
                status_code=status.HTTP_404_NOT_FOUND
            )
        except (InvalidTransitionError, ValidationRuleError) as e:
            return error_response(
                str(e),
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except PermissionError as e:
            return error_response(
                'Permission denied for this transition.',
                status_code=status.HTTP_403_FORBIDDEN
            )
        except Exception as e:
            logger.error(f"Workflow transition failed for {instance_id}: {str(e)}")
            return error_response(
                'Workflow transition failed.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def check_object_permissions(self, request, obj):
        """Check object-level permissions for the workflow instance."""
        permission = CVWorkflowPermission()
        if not permission.has_object_permission(request, self, obj):
            raise PermissionError("Insufficient permissions for this workflow")


class CVWorkflowView(APIView):
    """
    Specialized view for CV workflow operations.
    Handles CV-specific workflow initialization and management.
    """
    
    permission_classes = [IsAuthenticated, CVWorkflowPermission]
    
    def get(self, request, cv_id):
        """Get or initialize workflow for a CV."""
        try:
            # Get CV profile
            cv = get_object_or_404(
                CVProfile.objects.select_related('student'),
                id=cv_id
            )
            
            # Check permissions
            if request.user.role == request.user.Role.STUDENT:
                if cv.student != request.user:
                    return error_response(
                        'Permission denied.',
                        status_code=status.HTTP_403_FORBIDDEN
                    )
            
            # Get or create workflow instance
            content_type = ContentType.objects.get_for_model(CVProfile)
            instance = WorkflowInstance.objects.filter(
                content_type=content_type,
                object_id=str(cv.id)
            ).select_related('workflow_config', 'current_state').first()
            
            if not instance:
                # Initialize workflow
                workflow_service = WorkflowService()
                instance = workflow_service.initialize_workflow(
                    entity=cv,
                    user=request.user
                )
            
            # Get workflow status
            workflow_service = WorkflowService()
            available_transitions = workflow_service.get_available_transitions(
                instance, request.user
            )
            permissions = get_workflow_permissions_for_user(request.user, instance)
            
            response_data = {
                'instance': WorkflowInstanceSerializer(instance).data,
                'available_transitions': available_transitions,
                'permissions': permissions
            }
            
            return success_response(
                'CV workflow retrieved successfully.',
                response_data
            )
            
        except CVProfile.DoesNotExist:
            return error_response(
                'CV not found.',
                status_code=status.HTTP_404_NOT_FOUND
            )
        except Exception as e:
            logger.error(f"Failed to get CV workflow for {cv_id}: {str(e)}")
            return error_response(
                'Failed to retrieve CV workflow.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request, cv_id):
        """Initialize or reinitialize workflow for a CV."""
        try:
            # Get CV profile
            cv = get_object_or_404(
                CVProfile.objects.select_related('student'),
                id=cv_id
            )
            
            # Check permissions
            if request.user.role == request.user.Role.STUDENT:
                if cv.student != request.user:
                    return error_response(
                        'Permission denied.',
                        status_code=status.HTTP_403_FORBIDDEN
                    )
            
            # Validate request data
            serializer = WorkflowInitializationSerializer(data=request.data)
            if not serializer.is_valid():
                return error_response(
                    'Invalid initialization request.',
                    serializer.errors,
                    status_code=status.HTTP_400_BAD_REQUEST
                )
            
            # Initialize workflow
            workflow_service = WorkflowService()
            
            workflow_config = None
            if serializer.validated_data.get('workflow_config_id'):
                workflow_config = get_object_or_404(
                    WorkflowConfiguration,
                    id=serializer.validated_data['workflow_config_id']
                )
            
            instance = workflow_service.initialize_workflow(
                entity=cv,
                workflow_config=workflow_config,
                user=request.user,
                initial_properties=serializer.validated_data.get('initial_properties')
            )
            
            return success_response(
                'CV workflow initialized successfully.',
                WorkflowInstanceSerializer(instance).data,
                status_code=status.HTTP_201_CREATED
            )
            
        except CVProfile.DoesNotExist:
            return error_response(
                'CV not found.',
                status_code=status.HTTP_404_NOT_FOUND
            )
        except WorkflowNotFoundError as e:
            return error_response(
                str(e),
                status_code=status.HTTP_400_BAD_REQUEST
            )
        except Exception as e:
            logger.error(f"Failed to initialize CV workflow for {cv_id}: {str(e)}")
            return error_response(
                'Failed to initialize CV workflow.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )


class WorkflowDashboardView(APIView):
    """
    Dashboard view providing workflow analytics and summaries.
    Role-based data access for students and administrators.
    """
    
    permission_classes = [IsAuthenticated, CanViewWorkflow]
    
    def get(self, request):
        """Get workflow dashboard data."""
        try:
            user = request.user
            dashboard_data = {}
            
            if user.role == user.Role.ADMIN:
                dashboard_data = self._get_admin_dashboard_data()
            elif user.role == user.Role.STUDENT:
                dashboard_data = self._get_student_dashboard_data(user)
            
            serializer = WorkflowDashboardSerializer(dashboard_data)
            return success_response(
                'Workflow dashboard data retrieved successfully.',
                serializer.data
            )
            
        except Exception as e:
            logger.error(f"Failed to get workflow dashboard data: {str(e)}")
            return error_response(
                'Failed to retrieve dashboard data.',
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def _get_admin_dashboard_data(self) -> Dict[str, Any]:
        """Get dashboard data for administrators."""
        # Get workflow statistics
        total_workflows = WorkflowInstance.objects.count()
        
        # Get state distribution
        state_counts = WorkflowInstance.objects.values(
            'current_state__name'
        ).annotate(count=Count('id'))
        
        workflow_states_summary = {
            item['current_state__name']: item['count']
            for item in state_counts
        }
        
        # Get recent transitions
        recent_transitions = WorkflowTransitionLog.objects.select_related(
            'from_state', 'to_state', 'performed_by'
        ).order_by('-performed_at')[:10]
        
        workflow_service = WorkflowService()
        recent_transitions_data = []
        for log in recent_transitions:
            recent_transitions_data.append({
                'id': str(log.id),
                'from_state': {'code': log.from_state.code, 'name': log.from_state.name},
                'to_state': {'code': log.to_state.code, 'name': log.to_state.name},
                'transition_name': log.transition.name,
                'performed_by': {
                    'id': str(log.performed_by.id),
                    'name': log.performed_by.full_name,
                    'email': log.performed_by.email
                },
                'performed_at': log.performed_at,
                'result': log.result,
                'comment': log.comment,
                'metadata': log.metadata
            })
        
        return {
            'total_workflows': total_workflows,
            'active_workflows': total_workflows,  # All are considered active
            'pending_reviews': workflow_states_summary.get('Under Review', 0),
            'completed_workflows': workflow_states_summary.get('Published', 0),
            'recent_transitions': recent_transitions_data,
            'workflow_states_summary': workflow_states_summary
        }
    
    def _get_student_dashboard_data(self, user) -> Dict[str, Any]:
        """Get dashboard data for students."""
        # Get student's CV workflows
        cv_content_type = ContentType.objects.get_for_model(CVProfile)
        user_cvs = CVProfile.objects.filter(student=user).values_list('id', flat=True)
        
        user_workflows = WorkflowInstance.objects.filter(
            content_type=cv_content_type,
            object_id__in=[str(cv_id) for cv_id in user_cvs]
        )
        
        total_workflows = user_workflows.count()
        
        # Get state distribution for user's workflows
        state_counts = user_workflows.values(
            'current_state__name'
        ).annotate(count=Count('id'))
        
        workflow_states_summary = {
            item['current_state__name']: item['count']
            for item in state_counts
        }
        
        # Get recent transitions for user's workflows
        recent_transitions = WorkflowTransitionLog.objects.filter(
            workflow_instance__in=user_workflows
        ).select_related(
            'from_state', 'to_state', 'performed_by'
        ).order_by('-performed_at')[:5]
        
        recent_transitions_data = []
        for log in recent_transitions:
            recent_transitions_data.append({
                'id': str(log.id),
                'from_state': {'code': log.from_state.code, 'name': log.from_state.name},
                'to_state': {'code': log.to_state.code, 'name': log.to_state.name},
                'transition_name': log.transition.name,
                'performed_by': {
                    'id': str(log.performed_by.id),
                    'name': log.performed_by.full_name,
                    'email': log.performed_by.email
                },
                'performed_at': log.performed_at,
                'result': log.result,
                'comment': log.comment,
                'metadata': log.metadata
            })
        
        return {
            'total_workflows': total_workflows,
            'active_workflows': total_workflows,
            'pending_reviews': workflow_states_summary.get('Under Review', 0),
            'completed_workflows': workflow_states_summary.get('Published', 0),
            'recent_transitions': recent_transitions_data,
            'workflow_states_summary': workflow_states_summary
        }


# Admin Views for Workflow Management

class WorkflowConfigurationViewSet(viewsets.ModelViewSet):
    """
    Admin viewset for managing workflow configurations.
    Full CRUD operations for workflow definitions.
    """
    
    serializer_class = WorkflowConfigurationSerializer
    permission_classes = [IsAuthenticated, CanManageWorkflow]
    queryset = WorkflowConfiguration.objects.prefetch_related(
        'states', 'transitions'
    ).order_by('-is_default', '-is_active', 'name')
    
    def perform_create(self, serializer):
        """Set the created_by field when creating configurations."""
        serializer.save(created_by=self.request.user)
    
    @action(detail=True, methods=['post'])
    def activate(self, request, pk=None):
        """Activate a workflow configuration."""
        config = self.get_object()
        config.is_active = True
        config.save(update_fields=['is_active', 'updated_at'])
        
        return success_response(
            f'Workflow configuration "{config.name}" activated successfully.'
        )
    
    @action(detail=True, methods=['post'])
    def deactivate(self, request, pk=None):
        """Deactivate a workflow configuration."""
        config = self.get_object()
        config.is_active = False
        config.save(update_fields=['is_active', 'updated_at'])
        
        return success_response(
            f'Workflow configuration "{config.name}" deactivated successfully.'
        )