"""
Development settings.
Extends base.py with dev-specific overrides.
Never use these settings in production.
"""
from .base import *
from decouple import config

# ─── Debug ────────────────────────────────────────────────────────────────────
DEBUG = True

# ─── Development-only Apps ────────────────────────────────────────────────────
INSTALLED_APPS += []  # Add dev tools here if needed (e.g. django-debug-toolbar)

# ─── CORS for local development ──────────────────────────────────────────────
# Use the origins from .env file
CORS_ALLOWED_ORIGINS = config('CORS_ALLOWED_ORIGINS', cast=Csv())
CORS_ALLOW_ALL_ORIGINS = config('CORS_ALLOW_ALL_ORIGINS', default=False, cast=bool)

# ─── Email Backend (console — no real emails in dev) ──────────────────────────
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# ─── Logging override — verbose in development ────────────────────────────────
LOGGING['loggers']['']['level'] = 'DEBUG'
