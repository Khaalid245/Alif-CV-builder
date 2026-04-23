"""
WSGI entry point for EduCV.
Used by Gunicorn in production and Django's dev server.
"""
import os
from django.core.wsgi import get_wsgi_application

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

application = get_wsgi_application()
