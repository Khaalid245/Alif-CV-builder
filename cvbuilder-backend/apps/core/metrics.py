"""
Simple metrics tracking for EduCV application monitoring.
Tracks business-specific metrics without external dependencies.
"""
from django.contrib.auth import get_user_model
import logging

User = get_user_model()
logger = logging.getLogger(__name__)


def update_active_users():
    """Update the active users count - simplified version."""
    from django.utils import timezone
    from datetime import timedelta
    
    try:
        # Consider users active if they've logged in within the last 24 hours
        cutoff = timezone.now() - timedelta(hours=24)
        active_count = User.objects.filter(last_login_at__gte=cutoff).count()
        logger.info(f"Active users in last 24h: {active_count}")
        return active_count
    except Exception as e:
        logger.warning(f"Failed to update active users count: {e}")
        return 0


def record_pdf_generation(template_type: str, duration: float, success: bool = True, error_type: str = None):
    """Record PDF generation metrics - simplified logging."""
    status = 'success' if success else 'failed'
    logger.info(f"PDF generation: {template_type} - {status} - {duration:.2f}s")
    if not success and error_type:
        logger.error(f"PDF generation failed: {template_type} - {error_type}")


def record_user_registration(success: bool = True):
    """Record user registration attempt - simplified logging."""
    status = 'success' if success else 'failed'
    logger.info(f"User registration: {status}")


def record_login_attempt(success: bool = True):
    """Record login attempt - simplified logging."""
    status = 'success' if success else 'failed'
    logger.info(f"Login attempt: {status}")


def record_cv_update(section: str):
    """Record CV section update - simplified logging."""
    logger.info(f"CV update: {section}")


def record_cv_completion(completion_percentage: int):
    """Record CV completion level - simplified logging."""
    if completion_percentage < 50:
        level = 'basic'
    elif completion_percentage < 80:
        level = 'intermediate'
    else:
        level = 'complete'
    
    logger.info(f"CV completion: {level} ({completion_percentage}%)")


def record_security_event(event_type: str, severity: str = 'medium'):
    """Record security event - simplified logging."""
    logger.warning(f"Security event: {event_type} - {severity}")


def record_rate_limit_hit(endpoint: str, user_type: str = 'authenticated'):
    """Record rate limit violation - simplified logging."""
    logger.warning(f"Rate limit hit: {endpoint} - {user_type}")


def record_cv_download(template_type: str):
    """Record CV download - simplified logging."""
    logger.info(f"CV download: {template_type}")


def record_deletion_request():
    """Record data deletion request - simplified logging."""
    logger.info("Data deletion request submitted")