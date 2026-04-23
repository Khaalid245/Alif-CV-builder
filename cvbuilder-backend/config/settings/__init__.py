"""
Settings package entry point.
Loads the correct settings module based on the DJANGO_ENVIRONMENT variable.
Defaults to development if not set.
"""
import os
from decouple import config

environment = config('DJANGO_ENVIRONMENT', default='development')

if environment == 'production':
    from .production import *
else:
    from .development import *
