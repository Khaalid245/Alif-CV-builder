"""
Custom Prometheus metrics for EduCV application monitoring.
Tracks business-specific metrics like PDF generations, user activity, etc.
"""
from prometheus_client import Counter, Histogram, Gauge
from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

# ─── PDF Generation Metrics ───────────────────────────────────────────────────
pdf_generations_total = Counter(
    'educv_pdf_generations_total',
    'Total number of PDF generations',
    ['template_type', 'status']
)

pdf_generation_duration = Histogram(
    'educv_pdf_generation_duration_seconds',
    'Time spent generating PDFs',
    ['template_type'],
    buckets=[0.5, 1.0, 2.0, 5.0, 10.0, 30.0, 60.0]
)

pdf_generation_failures_total = Counter(
    'educv_pdf_generation_failures_total',
    'Total number of PDF generation failures',
    ['template_type', 'error_type']
)

# ─── User Activity Metrics ────────────────────────────────────────────────────
user_registrations_total = Counter(
    'educv_user_registrations_total',
    'Total number of user registrations',
    ['status']  # success, failed
)

login_attempts_total = Counter(
    'educv_login_attempts_total',
    'Total number of login attempts',
    ['status']  # success, failed
)

login_failures_total = Counter(
    'educv_login_failures_total',
    'Total number of failed login attempts'
)

active_users_total = Gauge(
    'educv_active_users_total',
    'Number of currently active users'
)

# ─── CV Data Metrics ───────────────────────────────────────────────────────────
cv_completions_total = Counter(
    'educv_cv_completions_total',
    'Total number of CV profile completions',
    ['completion_level']  # basic, intermediate, complete
)

cv_updates_total = Counter(
    'educv_cv_updates_total',
    'Total number of CV profile updates',
    ['section']  # education, experience, skills, etc.
)

# ─── Security Metrics ──────────────────────────────────────────────────────────
security_events_total = Counter(
    'educv_security_events_total',
    'Total number of security events',
    ['event_type', 'severity']
)

rate_limit_hits_total = Counter(
    'educv_rate_limit_hits_total',
    'Total number of rate limit violations',
    ['endpoint', 'user_type']
)

# ─── Business Metrics ──────────────────────────────────────────────────────────
cv_downloads_total = Counter(
    'educv_cv_downloads_total',
    'Total number of CV downloads',
    ['template_type']
)

data_deletion_requests_total = Counter(
    'educv_data_deletion_requests_total',
    'Total number of data deletion requests'
)


def update_active_users():
    """Update the active users gauge with current count."""
    from django.utils import timezone
    from datetime import timedelta
    
    # Consider users active if they've logged in within the last 24 hours
    cutoff = timezone.now() - timedelta(hours=24)
    active_count = User.objects.filter(last_login__gte=cutoff).count()
    active_users_total.set(active_count)


def record_pdf_generation(template_type: str, duration: float, success: bool = True, error_type: str = None):
    """Record PDF generation metrics."""
    status = 'success' if success else 'failed'
    pdf_generations_total.labels(template_type=template_type, status=status).inc()
    
    if success:
        pdf_generation_duration.labels(template_type=template_type).observe(duration)
    else:
        pdf_generation_failures_total.labels(
            template_type=template_type, 
            error_type=error_type or 'unknown'
        ).inc()


def record_user_registration(success: bool = True):
    """Record user registration attempt."""
    status = 'success' if success else 'failed'
    user_registrations_total.labels(status=status).inc()


def record_login_attempt(success: bool = True):
    """Record login attempt."""
    status = 'success' if success else 'failed'
    login_attempts_total.labels(status=status).inc()
    
    if not success:
        login_failures_total.inc()


def record_cv_update(section: str):
    """Record CV section update."""
    cv_updates_total.labels(section=section).inc()


def record_cv_completion(completion_percentage: int):
    """Record CV completion level."""
    if completion_percentage < 50:
        level = 'basic'
    elif completion_percentage < 80:
        level = 'intermediate'
    else:
        level = 'complete'
    
    cv_completions_total.labels(completion_level=level).inc()


def record_security_event(event_type: str, severity: str = 'medium'):
    """Record security event."""
    security_events_total.labels(event_type=event_type, severity=severity).inc()


def record_rate_limit_hit(endpoint: str, user_type: str = 'authenticated'):
    """Record rate limit violation."""
    rate_limit_hits_total.labels(endpoint=endpoint, user_type=user_type).inc()


def record_cv_download(template_type: str):
    """Record CV download."""
    cv_downloads_total.labels(template_type=template_type).inc()


def record_deletion_request():
    """Record data deletion request."""
    data_deletion_requests_total.inc()