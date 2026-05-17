from django.apps import AppConfig


class VersionHistoryConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.version_history'
    verbose_name = 'Version History'

    def ready(self):
        """Import signals when the app is ready."""
        import apps.version_history.signals  # noqa