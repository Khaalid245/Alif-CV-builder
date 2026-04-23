"""
Production settings.
Extends base.py with hardened security and performance settings.
All values must come from environment variables — no hardcoded secrets.
"""
from .base import *
from decouple import config

# ─── Security ─────────────────────────────────────────────────────────────────
DEBUG = False

# Force HTTPS
SECURE_SSL_REDIRECT = True
SECURE_HSTS_SECONDS = 31536000          # 1 year
SECURE_HSTS_INCLUDE_SUBDOMAINS = True
SECURE_HSTS_PRELOAD = True
SECURE_PROXY_SSL_HEADER = ('HTTP_X_FORWARDED_PROTO', 'https')

# Cookie security
SESSION_COOKIE_SECURE = True
CSRF_COOKIE_SECURE = True
SESSION_COOKIE_HTTPONLY = True
CSRF_COOKIE_HTTPONLY = True

# Clickjacking protection
X_FRAME_OPTIONS = 'DENY'

# ─── Email (configure real SMTP in production) ────────────────────────────────
EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
EMAIL_HOST = config('EMAIL_HOST', default='smtp.gmail.com')
EMAIL_PORT = config('EMAIL_PORT', default=587, cast=int)
EMAIL_USE_TLS = True
EMAIL_HOST_USER = config('EMAIL_HOST_USER', default='')
EMAIL_HOST_PASSWORD = config('EMAIL_HOST_PASSWORD', default='')

# ─── Logging override — less verbose in production ────────────────────────────
LOGGING['loggers']['']['level'] = 'WARNING'

# ─── Database connection tuning ───────────────────────────────────────────────
# Override CONN_MAX_AGE via env var to match MySQL server's wait_timeout
DATABASES['default']['CONN_MAX_AGE'] = config('DB_CONN_MAX_AGE', default=60, cast=int)
