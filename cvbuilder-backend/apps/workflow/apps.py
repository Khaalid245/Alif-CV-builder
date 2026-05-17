"""
Workflow app configuration.
"""
from django.apps import AppConfig


class WorkflowConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.workflow'
    verbose_name = 'Workflow Control System'
    
    def ready(self):
        """Import signals when the app is ready."""
        try:
            import apps.workflow.signals  # noqa F401
        except ImportError:
            pass