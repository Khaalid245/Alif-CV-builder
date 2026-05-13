"""
Django system checks for critical configuration validation.

These checks run when Django starts to ensure the application is properly configured
for the target environment (development, staging, production).

Run manually with: python manage.py check --deploy
"""

from django.core.checks import register, Error, Warning, Critical, Info
from django.conf import settings
import logging

logger = logging.getLogger(__name__)


@register()
def check_database_configuration(app_configs, **kwargs):
    """Validate database configuration is appropriate for the environment."""
    errors = []
    warnings = []
    
    # Get current environment
    environment = getattr(settings, 'DJANGO_ENVIRONMENT', 'development').lower()
    
    # Database configuration
    databases = settings.DATABASES.get('default', {})
    
    # CRITICAL: Validate database is not SQLite in production
    if databases.get('ENGINE') == 'django.db.backends.sqlite3':
        if environment == 'production':
            errors.append(
                Critical(
                    'SQLite database detected in PRODUCTION environment. '
                    'SQLite is not suitable for production. Use MySQL/PostgreSQL.',
                    hint='Change DATABASE_ENGINE to django.db.backends.mysql '
                         'or django.db.backends.postgresql',
                    id='educv.E001',
                )
            )
        else:
            warnings.append(
                Warning(
                    'SQLite database detected. Consider using MySQL/PostgreSQL for consistency.',
                    id='educv.W001',
                )
            )
    
    # WARNING: Validate database credentials are not default
    if environment == 'production':
        db_user = databases.get('USER')
        db_password = databases.get('PASSWORD')
        
        if db_user in ['root', 'educv_user'] or db_password in ['password', 'educv_password', '']:
            errors.append(
                Critical(
                    'Database credentials appear to be default/insecure values. '
                    'Please configure strong credentials in production.',
                    hint='Use AWS Secrets Manager or environment variables for credentials.',
                    id='educv.E002',
                )
            )
    
    # INFO: Validate database connection pool settings
    conn_max_age = databases.get('CONN_MAX_AGE', 600)
    if conn_max_age > 3600 and environment == 'production':
        warnings.append(
            Warning(
                f'CONN_MAX_AGE is {conn_max_age}s. Ensure MySQL wait_timeout matches this value.',
                hint='Set MySQL: SET GLOBAL wait_timeout = 3600;',
                id='educv.W002',
            )
        )
    
    return errors + warnings


@register()
def check_security_settings(app_configs, **kwargs):
    """Validate security settings are appropriate for the environment."""
    errors = []
    warnings = []
    
    environment = getattr(settings, 'DJANGO_ENVIRONMENT', 'development').lower()
    
    # CRITICAL: DEBUG must be False in production
    if settings.DEBUG and environment == 'production':
        errors.append(
            Critical(
                'DEBUG=True in PRODUCTION environment. This exposes sensitive information.',
                hint='Set DEBUG=False in production',
                id='educv.E003',
            )
        )
    
    # CRITICAL: SECRET_KEY must be strong
    secret_key = settings.SECRET_KEY
    if len(secret_key) < 50:
        errors.append(
            Critical(
                'SECRET_KEY is too short (<50 chars). This reduces cryptographic strength.',
                hint='Generate a longer SECRET_KEY: '
                     'python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"',
                id='educv.E004',
            )
        )
    
    if secret_key.startswith('dev-') or secret_key == 'your-secret-key-here':
        if environment == 'production':
            errors.append(
                Critical(
                    'DEFAULT SECRET_KEY detected in production. Ensure a unique secret key is set.',
                    hint='Change DJANGO_SECRET_KEY in .env or environment',
                    id='educv.E005',
                )
            )
        else:
            warnings.append(
                Warning(
                    'DEFAULT SECRET_KEY detected in development. Replace it before production deployment.',
                    hint='Generate a unique DJANGO_SECRET_KEY for production.',
                    id='educv.W006',
                )
            )
    
    # CRITICAL: ALLOWED_HOSTS must be configured in production
    if environment == 'production':
        allowed_hosts = settings.ALLOWED_HOSTS
        
        if not allowed_hosts or '*' in allowed_hosts:
            errors.append(
                Critical(
                    'ALLOWED_HOSTS not properly configured in production. '
                    'Wildcard or empty value exposes the app to Host Header attacks.',
                    hint='Set ALLOWED_HOSTS to specific domain(s): '
                         'DJANGO_ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com',
                    id='educv.E006',
                )
            )
    
    # WARNING: Validate CORS configuration
    cors_allowed_origins = getattr(settings, 'CORS_ALLOWED_ORIGINS', [])
    if isinstance(cors_allowed_origins, str):
        origins_list = cors_allowed_origins.split(',')
    else:
        origins_list = cors_allowed_origins
    
    if environment == 'production':
        for origin in origins_list:
            if 'localhost' in origin or '127.0.0.1' in origin or '*' in origin:
                warnings.append(
                    Warning(
                        f'localhost/127.0.0.1 found in production CORS_ALLOWED_ORIGINS: {origin}',
                        hint='Remove development URLs from CORS configuration',
                        id='educv.W003',
                    )
                )
    
    return errors + warnings


@register()
def check_email_configuration(app_configs, **kwargs):
    """Validate email configuration is set up correctly."""
    errors = []
    warnings = []
    
    environment = getattr(settings, 'DJANGO_ENVIRONMENT', 'development').lower()
    
    if environment == 'production':
        email_host = getattr(settings, 'EMAIL_HOST', '')
        email_user = getattr(settings, 'EMAIL_HOST_USER', '')
        email_password = getattr(settings, 'EMAIL_HOST_PASSWORD', '')
        
        if not email_host or not email_user or not email_password:
            warnings.append(
                Warning(
                    'Email configuration incomplete. Email verification and password reset won\'t work.',
                    hint='Configure EMAIL_HOST, EMAIL_HOST_USER, EMAIL_HOST_PASSWORD',
                    id='educv.W004',
                )
            )
    
    return errors + warnings


@register()
def check_sentry_configuration(app_configs, **kwargs):
    """Validate Sentry error tracking is configured in production."""
    errors = []
    warnings = []
    
    environment = getattr(settings, 'DJANGO_ENVIRONMENT', 'development').lower()
    
    if environment == 'production':
        sentry_dsn = getattr(settings, 'SENTRY_DSN', '')
        
        if not sentry_dsn:
            warnings.append(
                Warning(
                    'Sentry DSN not configured. Error tracking and monitoring will be disabled.',
                    hint='Configure SENTRY_DSN in production environment',
                    id='educv.W005',
                )
            )
    
    return errors + warnings


def validate_production_readiness():
    """
    Run critical production readiness checks.
    Should be called in production __init__ settings.
    Returns True if all checks pass, False otherwise.
    """
    from django.core.management import call_command
    from io import StringIO
    
    out = StringIO()
    try:
        call_command('check', '--deploy', stdout=out, stderr=out)
        logger.info('✓ Production readiness checks passed')
        return True
    except Exception as e:
        logger.critical(f'✗ Production readiness check FAILED: {str(e)}')
        return False
