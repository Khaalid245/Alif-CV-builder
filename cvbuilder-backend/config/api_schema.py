"""
OpenAPI/Swagger configuration for EduCV API.

The drf-spectacular library auto-generates OpenAPI schema from DRF views and serializers.
This provides comprehensive API documentation accessible at:
  - /api/schema/swagger-ui/ - Swagger UI (interactive)
  - /api/schema/redoc/ - ReDoc UI (alternative)
  - /api/schema/openapi.json - Raw OpenAPI schema (for tooling)

To use:
1. Add to INSTALLED_APPS: 'drf_spectacular'
2. Update REST_FRAMEWORK settings
3. Include schema URLs in urls.py
4. Run: pip install drf-spectacular
"""

from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView, SpectacularRedocView
from drf_spectacular.openapi import AutoSchema


# Schema generation settings for settings.py
SPECTACULAR_SETTINGS = {
    'TITLE': 'EduCV API',
    'DESCRIPTION': 'Enterprise-level CV Builder API with full OpenAPI/Swagger documentation',
    'VERSION': '1.0.0',
    'SERVE_INCLUDE_SCHEMA': False,
    
    # Contact information
    'CONTACT': {
        'name': 'EduCV Support',
        'email': 'support@educv.example.com',
        'url': 'https://educv.example.com',
    },
    
    # License information
    'LICENSE': {
        'name': 'MIT',
    },
    
    # API schema endpoint
    'SCHEMA_PATH_PREFIX': '/api/',
    
    # Tagging strategy for organizing endpoints
    'TAGS_PATH_PREFIX': '/api/v1/',
    
    # Preserve request body for all methods (not just POST/PATCH/PUT)
    'PRESERVE_REQUEST_BODY_SCHEMA': True,
    
    # Deep link to operation on example endpoints
    'DEEP_LINK_PATHS': True,
    
    # Use string representation for URLs in examples
    'EXAMPLES_ENABLED': True,
    
    # Auto enum field naming
    'ENUM_FIELD_TITLE_MAPPING': {
        'Status': {
            'active': 'Active - User account is active',
            'suspended': 'Suspended - User account is suspended',
            'deactivated': 'Deactivated - User requested deactivation',
        },
        'Role': {
            'student': 'Student - Regular user account',
            'admin': 'Admin - Administrator account',
        },
    },
    
    # Determine which operations get split into separate components
    'SPLIT_VIEWS': True,
    
    # Better split of create/retrieve/update operations
    'OPERATION_ID_CASE_SENSITIVE': True,
    
    # Use view docstrings
    'USE_SESSION_AUTH_EXCLUDE': False,
    
    # Allow multiple security schemes
    'SECURITY': [
        {
            'bearerAuth': []
        }
    ],
    
    # Servers for documentation
    'SERVERS': [
        {
            'url': 'http://localhost:8000/api/v1',
            'description': 'Development server'
        },
        {
            'url': 'https://api.educv.example.com/api/v1',
            'description': 'Production server'
        },
    ],
}


# REST Framework settings to add to your settings.py
REST_FRAMEWORK_SCHEMA_SETTINGS = {
    'DEFAULT_SCHEMA_CLASS': 'drf_spectacular.openapi.AutoSchema',
}


# URL configuration - add these to your urls.py
"""
from drf_spectacular.views import (
    SpectacularAPIView,
    SpectacularSwaggerView,
    SpectacularRedocView,
)

urlpatterns = [
    # OpenAPI schema endpoint
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    
    # Swagger UI
    path('api/docs/swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
    
    # ReDoc
    path('api/docs/redoc/', SpectacularRedocView.as_view(url_name='schema'), name='redoc'),
    
    # Your API endpoints...
]
"""
