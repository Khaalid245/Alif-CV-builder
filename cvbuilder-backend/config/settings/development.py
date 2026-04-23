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

# ─── Relaxed CORS for local development ───────────────────────────────────────
CORS_ALLOW_ALL_ORIGINS = False  # Still explicit even in dev

# ─── Email Backend (console — no real emails in dev) ──────────────────────────
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# ─── Logging override — verbose in development ────────────────────────────────
LOGGING['loggers']['']['level'] = 'DEBUG'
