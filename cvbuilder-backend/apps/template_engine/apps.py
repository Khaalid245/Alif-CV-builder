"""Template Engine app configuration."""
from django.apps import AppConfig


class TemplateEngineConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.template_engine'
    verbose_name = 'Template Engine'

    def ready(self):
        """Import signals when Django starts."""
        import apps.template_engine.signals  # noqa