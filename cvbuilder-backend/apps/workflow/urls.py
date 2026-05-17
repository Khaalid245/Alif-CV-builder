"""
URL patterns for Workflow Control System API endpoints.
Provides comprehensive routing for workflow operations.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    WorkflowInstanceViewSet, WorkflowTransitionView, CVWorkflowView,
    WorkflowDashboardView, WorkflowConfigurationViewSet
)

app_name = 'workflow'

# Create router for viewsets
router = DefaultRouter()
router.register(r'instances', WorkflowInstanceViewSet, basename='workflow-instance')
router.register(r'configurations', WorkflowConfigurationViewSet, basename='workflow-configuration')

urlpatterns = [
    # Include router URLs
    path('', include(router.urls)),
    
    # Workflow operations
    path('instances/<uuid:instance_id>/transition/', 
         WorkflowTransitionView.as_view(), 
         name='workflow-transition'),
    
    # CV-specific workflow endpoints
    path('cv/<uuid:cv_id>/', 
         CVWorkflowView.as_view(), 
         name='cv-workflow'),
    
    # Dashboard and analytics
    path('dashboard/', 
         WorkflowDashboardView.as_view(), 
         name='workflow-dashboard'),
]