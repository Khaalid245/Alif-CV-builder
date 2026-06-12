"""
CV Intelligence App Config
Pre-warms the ML scoring model at Django startup so the first analysis
request is not penalised with model loading time.
"""
import logging
from django.apps import AppConfig

logger = logging.getLogger(__name__)


class CvIntelligenceConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'apps.cv_intelligence'
    verbose_name = 'CV Intelligence'

    def ready(self):
        """
        Called once after Django has fully initialised.
        Pre-loads the sentence-transformers model into RAM so all subsequent
        analysis requests are fast (no cold-start latency).
        """
        try:
            from .ai.ml_scoring_service import MLScoringService
            MLScoringService.get_instance().warm_up()
        except Exception as exc:
            # Never crash Django startup — model loading is best-effort
            logger.warning(f'[CVIntelligence] ML model pre-warm skipped: {exc}')