"""
Django app configuration for the core application.
Registers system checks for configuration validation.
"""

from django.apps import AppConfig


class CoreConfig(AppConfig):
    """Core application configuration."""
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.core'
    verbose_name = 'EduCV Core'
    
    def ready(self):
        """
        Django signals and checks are registered when the app is ready.
        """
        # Import system checks
        from . import checks  # noqa
