"""
Sentry configuration for error tracking and performance monitoring.
"""
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.logging import LoggingIntegration
from decouple import config


def init_sentry():
    """Initialize Sentry for error tracking and performance monitoring."""
    
    # Only initialize Sentry if DSN is provided
    sentry_dsn = config('SENTRY_DSN', default='')
    if not sentry_dsn:
        return
    
    # Logging integration
    sentry_logging = LoggingIntegration(
        level=config('SENTRY_LOG_LEVEL', default='INFO'),
        event_level=config('SENTRY_EVENT_LEVEL', default='ERROR')
    )
    
    sentry_sdk.init(
        dsn=sentry_dsn,
        integrations=[
            DjangoIntegration(
                transaction_style='url',
                middleware_spans=True,
                signals_spans=True,
                cache_spans=True,
            ),
            sentry_logging,
        ],
        
        # Performance monitoring
        traces_sample_rate=config('SENTRY_TRACES_SAMPLE_RATE', default=0.1, cast=float),
        
        # Error sampling
        sample_rate=config('SENTRY_SAMPLE_RATE', default=1.0, cast=float),
        
        # Environment and release tracking
        environment=config('SENTRY_ENVIRONMENT', default='development'),
        release=config('SENTRY_RELEASE', default='unknown'),
        
        # Additional options
        send_default_pii=False,  # Don't send personally identifiable information
        attach_stacktrace=True,
        
        # Custom tags
        before_send=before_send_filter,
    )


def before_send_filter(event, hint):
    """
    Filter events before sending to Sentry.
    Remove sensitive data and filter out noise.
    """
    # Don't send events for certain exceptions
    if 'exc_info' in hint:
        exc_type, exc_value, tb = hint['exc_info']
        
        # Filter out common non-critical exceptions
        if exc_type.__name__ in [
            'DisallowedHost',
            'SuspiciousOperation',
            'PermissionDenied',
        ]:
            return None
    
    # Remove sensitive data from request
    if 'request' in event:
        request = event['request']
        
        # Remove sensitive headers
        if 'headers' in request:
            sensitive_headers = ['authorization', 'cookie', 'x-api-key']
            for header in sensitive_headers:
                request['headers'].pop(header, None)
        
        # Remove sensitive form data
        if 'data' in request:
            sensitive_fields = ['password', 'token', 'secret']
            for field in sensitive_fields:
                if field in request['data']:
                    request['data'][field] = '[Filtered]'
    
    # Add custom tags
    event.setdefault('tags', {})
    event['tags']['component'] = 'educv-backend'
    
    return event


def capture_pdf_generation_error(template_type: str, error: Exception, extra_context: dict = None):
    """Capture PDF generation specific errors with context."""
    with sentry_sdk.configure_scope() as scope:
        scope.set_tag('error_type', 'pdf_generation')
        scope.set_tag('template_type', template_type)
        scope.set_context('pdf_generation', {
            'template_type': template_type,
            **(extra_context or {})
        })
        sentry_sdk.capture_exception(error)


def capture_auth_error(event_type: str, error: Exception, user_id: str = None, ip_address: str = None):
    """Capture authentication specific errors with context."""
    with sentry_sdk.configure_scope() as scope:
        scope.set_tag('error_type', 'authentication')
        scope.set_tag('auth_event', event_type)
        scope.set_context('authentication', {
            'event_type': event_type,
            'user_id': user_id,
            'ip_address': ip_address,
        })
        sentry_sdk.capture_exception(error)


def capture_database_error(operation: str, error: Exception, model: str = None):
    """Capture database specific errors with context."""
    with sentry_sdk.configure_scope() as scope:
        scope.set_tag('error_type', 'database')
        scope.set_tag('db_operation', operation)
        scope.set_context('database', {
            'operation': operation,
            'model': model,
        })
        sentry_sdk.capture_exception(error)