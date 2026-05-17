"""
Template Engine URLs for EduCV.
URL configuration for all template-related API endpoints.
"""
from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import (
    IndustryViewSet, RoleViewSet, TemplateCategoryViewSet, TemplateViewSet,
    UserTemplatePreferenceViewSet, TemplateAnalyticsViewSet, TemplateRecommendationViewSet
)

# Create router and register viewsets
router = DefaultRouter()
router.register(r'industries', IndustryViewSet, basename='industry')
router.register(r'roles', RoleViewSet, basename='role')
router.register(r'categories', TemplateCategoryViewSet, basename='category')
router.register(r'templates', TemplateViewSet, basename='template')
router.register(r'preferences', UserTemplatePreferenceViewSet, basename='preference')
router.register(r'analytics', TemplateAnalyticsViewSet, basename='analytics')
router.register(r'recommendations', TemplateRecommendationViewSet, basename='recommendation')

app_name = 'template_engine'

urlpatterns = [
    path('', include(router.urls)),
]

# URL patterns summary:
# GET    /api/v1/templates/industries/                    - List industries
# POST   /api/v1/templates/industries/                    - Create industry (admin)
# GET    /api/v1/templates/industries/{slug}/             - Get industry details
# PUT    /api/v1/templates/industries/{slug}/             - Update industry (admin)
# DELETE /api/v1/templates/industries/{slug}/             - Delete industry (admin)

# GET    /api/v1/templates/roles/                         - List roles
# POST   /api/v1/templates/roles/                         - Create role (admin)
# GET    /api/v1/templates/roles/{slug}/                  - Get role details
# PUT    /api/v1/templates/roles/{slug}/                  - Update role (admin)
# DELETE /api/v1/templates/roles/{slug}/                  - Delete role (admin)

# GET    /api/v1/templates/categories/                    - List categories
# POST   /api/v1/templates/categories/                    - Create category (admin)
# GET    /api/v1/templates/categories/{slug}/             - Get category details
# PUT    /api/v1/templates/categories/{slug}/             - Update category (admin)
# DELETE /api/v1/templates/categories/{slug}/             - Delete category (admin)

# GET    /api/v1/templates/templates/                     - List templates
# POST   /api/v1/templates/templates/                     - Create template (admin)
# GET    /api/v1/templates/templates/{slug}/              - Get template details
# PUT    /api/v1/templates/templates/{slug}/              - Update template (admin)
# DELETE /api/v1/templates/templates/{slug}/              - Delete template (admin)
# POST   /api/v1/templates/templates/{slug}/preview/      - Generate template preview
# POST   /api/v1/templates/templates/{slug}/render/       - Render template with CV data
# POST   /api/v1/templates/templates/{slug}/favorite/     - Add to favorites
# DELETE /api/v1/templates/templates/{slug}/unfavorite/   - Remove from favorites
# GET    /api/v1/templates/templates/recommendations/     - Get personalized recommendations
# GET    /api/v1/templates/templates/popular/             - Get popular templates
# POST   /api/v1/templates/templates/bulk_action/         - Bulk template actions (admin)

# GET    /api/v1/templates/preferences/                   - Get user preferences
# PUT    /api/v1/templates/preferences/                   - Update user preferences

# GET    /api/v1/templates/analytics/overview/            - System analytics overview (admin)
# GET    /api/v1/templates/analytics/{id}/template_metrics/ - Template-specific metrics

# GET    /api/v1/templates/recommendations/               - Get user recommendations
# PATCH  /api/v1/templates/recommendations/{id}/mark_viewed/ - Mark recommendation as viewed
# PATCH  /api/v1/templates/recommendations/{id}/mark_clicked/ - Mark recommendation as clicked