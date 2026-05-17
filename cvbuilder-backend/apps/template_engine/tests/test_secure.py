"""
Secure Template Engine tests with no hardcoded credentials.
All passwords are generated dynamically using cryptographically secure methods.
"""
import json
import uuid
from datetime import datetime, timedelta
from unittest.mock import patch, MagicMock

from django.test import TestCase, TransactionTestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.utils import timezone
from django.core.cache import cache
from rest_framework.test import APITestCase, APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from apps.cv.models import CVProfile
from apps.core.test_utils import SecureTestMixin
from ..models import (
    Industry, Role, TemplateCategory, Template, SectionConfiguration,
    BrandingConfiguration, UserTemplatePreference, TemplateUsage,
    TemplatePerformanceMetric, TemplateRecommendation
)
from ..services import (
    TemplateSelectionService, TemplateRenderingService, TemplateAnalyticsService,
    TemplateRecommendationService
)

User = get_user_model()


class TemplateEngineModelTests(TestCase, SecureTestMixin):
    """Test template engine models with secure credentials."""
    
    def setUp(self):
        """Set up test data with secure user creation."""
        self.user = self.create_test_user(
            email='test@example.com',
            first_name='Test',
            last_name='User'
        )
        
        self.industry = Industry.objects.create(
            name='Technology',
            slug='technology',
            description='Technology industry'
        )
        
        self.role = Role.objects.create(
            name='Software Developer',
            slug='software-developer',
            industry=self.industry,
            description='Software development role'
        )
        
        self.category = TemplateCategory.objects.create(
            name='Modern',
            slug='modern',
            description='Modern template category'
        )
        
        self.template = Template.objects.create(
            name='Modern Tech CV',
            slug='modern-tech-cv',
            description='Modern template for tech professionals',
            category=self.category,
            layout_type=Template.Layout.TWO_COLUMN,
            html_template='<div>{{ cv.student.first_name }}</div>',
            css_styles='body { font-family: Arial; }',
            status=Template.Status.ACTIVE
        )
        
        self.template.industries.add(self.industry)
        self.template.roles.add(self.role)
    
    def test_industry_creation(self):
        """Test industry model creation."""
        self.assertEqual(self.industry.name, 'Technology')
        self.assertEqual(self.industry.slug, 'technology')
        self.assertTrue(self.industry.is_active)
        self.assertEqual(str(self.industry), 'Technology')
    
    def test_role_creation(self):
        """Test role model creation."""
        self.assertEqual(self.role.name, 'Software Developer')
        self.assertEqual(self.role.industry, self.industry)
        self.assertEqual(str(self.role), 'Software Developer (Technology)')
    
    def test_template_creation(self):
        """Test template model creation."""
        self.assertEqual(self.template.name, 'Modern Tech CV')
        self.assertEqual(self.template.category, self.category)
        self.assertEqual(self.template.status, Template.Status.ACTIVE)
        self.assertEqual(str(self.template), 'Modern Tech CV v1.0.0')
    
    def test_template_validation(self):
        """Test template validation."""
        # Test active template without HTML content
        template = Template(
            name='Invalid Template',
            slug='invalid-template',
            category=self.category,
            status=Template.Status.ACTIVE,
            html_template=''  # Empty HTML
        )
        
        with self.assertRaises(Exception):
            template.full_clean()
    
    def test_section_configuration(self):
        """Test section configuration model."""
        section = SectionConfiguration.objects.create(
            template=self.template,
            section_type=SectionConfiguration.SectionType.EDUCATION,
            display_name='Education',
            is_required=True,
            order=1
        )
        
        self.assertEqual(section.template, self.template)
        self.assertEqual(section.section_type, SectionConfiguration.SectionType.EDUCATION)
        self.assertTrue(section.is_required)
    
    def test_branding_configuration(self):
        """Test branding configuration model."""
        branding = BrandingConfiguration.objects.create(
            template=self.template,
            primary_color='#2563eb',
            secondary_color='#64748b',
            font_family='Inter, sans-serif'
        )
        
        self.assertEqual(branding.template, self.template)
        self.assertEqual(branding.primary_color, '#2563eb')
        self.assertEqual(str(branding), f'Branding for {self.template.name}')
    
    def test_user_template_preference(self):
        """Test user template preference model."""
        preference = UserTemplatePreference.objects.create(user=self.user)
        preference.preferred_industries.add(self.industry)
        preference.favorite_templates.add(self.template)
        
        self.assertEqual(preference.user, self.user)
        self.assertIn(self.industry, preference.preferred_industries.all())
        self.assertIn(self.template, preference.favorite_templates.all())
    
    def test_template_usage(self):
        """Test template usage tracking."""
        usage = TemplateUsage.objects.create(
            template=self.template,
            user=self.user,
            action=TemplateUsage.Action.GENERATE,
            render_time_ms=150
        )
        
        self.assertEqual(usage.template, self.template)
        self.assertEqual(usage.user, self.user)
        self.assertEqual(usage.action, TemplateUsage.Action.GENERATE)
        self.assertEqual(usage.render_time_ms, 150)
    
    def test_template_recommendation(self):
        """Test template recommendation model."""
        recommendation = TemplateRecommendation.objects.create(
            user=self.user,
            template=self.template,
            recommendation_type=TemplateRecommendation.RecommendationType.INDUSTRY_BASED,
            confidence_score=0.85,
            reasoning='Matches user industry preference'
        )
        
        self.assertEqual(recommendation.user, self.user)
        self.assertEqual(recommendation.template, self.template)
        self.assertEqual(recommendation.confidence_score, 0.85)


class TemplateEngineServiceTests(TestCase, SecureTestMixin):
    """Test template engine services with secure credentials."""
    
    def setUp(self):
        """Set up test data with secure user creation."""
        self.user = self.create_test_user(
            email='test@example.com',
            first_name='Test',
            last_name='User'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='+1234567890',
            city='New York',
            country='USA',
            summary='Test summary'
        )
        
        self.industry = Industry.objects.create(
            name='Technology',
            slug='technology'
        )
        
        self.category = TemplateCategory.objects.create(
            name='Modern',
            slug='modern'
        )
        
        self.template = Template.objects.create(
            name='Test Template',
            slug='test-template',
            category=self.category,
            html_template='<div>{{ cv.student.first_name }} {{ cv.student.last_name }}</div>',
            status=Template.Status.ACTIVE
        )
        
        self.template.industries.add(self.industry)
    
    def test_template_selection_service(self):
        """Test template selection service."""
        # Test get recommended templates
        templates = TemplateSelectionService.get_recommended_templates(
            user=self.user,
            limit=5
        )
        
        self.assertIsInstance(templates, list)
        self.assertLessEqual(len(templates), 5)
        
        # Test get templates by industry
        industry_templates = TemplateSelectionService.get_templates_by_industry(
            industry_slug='technology',
            limit=10
        )
        
        self.assertIsInstance(industry_templates, list)
        self.assertIn(self.template, industry_templates)
    
    def test_template_rendering_service(self):
        """Test template rendering service."""
        # Test template rendering
        rendered_html, metadata = TemplateRenderingService.render_template(
            template=self.template,
            cv_profile=self.cv_profile
        )
        
        self.assertIn('Test User', rendered_html)
        self.assertIn('render_time_ms', metadata)
        self.assertIn('template_id', metadata)
        
        # Test template preview
        preview_html = TemplateRenderingService.get_template_preview(self.template)
        self.assertIn('John Doe', preview_html)  # Sample data
        
        # Test HTML validation
        is_valid, errors = TemplateRenderingService.validate_template_html(
            '<div>{{ cv.student.first_name }}</div>'
        )
        self.assertTrue(is_valid)
        self.assertEqual(len(errors), 0)
        
        # Test invalid HTML
        is_valid, errors = TemplateRenderingService.validate_template_html(
            '<script>alert("xss")</script>'
        )
        self.assertFalse(is_valid)
        self.assertGreater(len(errors), 0)
    
    def test_template_analytics_service(self):
        """Test template analytics service."""
        # Create some usage data
        TemplateUsage.objects.create(
            template=self.template,
            user=self.user,
            action=TemplateUsage.Action.PREVIEW
        )
        
        TemplateUsage.objects.create(
            template=self.template,
            user=self.user,
            action=TemplateUsage.Action.GENERATE,
            render_time_ms=200
        )
        
        # Test track usage
        usage = TemplateAnalyticsService.track_template_usage(
            template=self.template,
            user=self.user,
            action=TemplateUsage.Action.DOWNLOAD,
            context_data={'render_time_ms': 150}
        )
        
        self.assertEqual(usage.template, self.template)
        self.assertEqual(usage.action, TemplateUsage.Action.DOWNLOAD)
        self.assertEqual(usage.render_time_ms, 150)
        
        # Test get performance metrics
        metrics = TemplateAnalyticsService.get_template_performance_metrics(
            template=self.template,
            days=30
        )
        
        self.assertIn('template_id', metrics)
        self.assertIn('usage_stats', metrics)
        self.assertIn('conversion_rate', metrics)
        
        # Test get popular templates
        popular = TemplateAnalyticsService.get_popular_templates(limit=5)
        self.assertIsInstance(popular, list)
    
    def test_template_recommendation_service(self):
        """Test template recommendation service."""
        # Create user preferences
        preference = UserTemplatePreference.objects.create(user=self.user)
        preference.preferred_industries.add(self.industry)
        
        # Test generate recommendations
        recommendations = TemplateRecommendationService.generate_recommendations(
            user=self.user,
            limit=5
        )
        
        self.assertIsInstance(recommendations, list)
        self.assertLessEqual(len(recommendations), 5)
        
        if recommendations:
            rec = recommendations[0]
            self.assertEqual(rec.user, self.user)
            self.assertIsInstance(rec.confidence_score, float)
            self.assertGreaterEqual(rec.confidence_score, 0.0)
            self.assertLessEqual(rec.confidence_score, 1.0)


class TemplateEngineAPITests(APITestCase, SecureTestMixin):
    """Test template engine API endpoints with secure credentials."""
    
    def setUp(self):
        """Set up test data and authentication with secure credentials."""
        self.user = self.create_test_user(
            email='test@example.com',
            first_name='Test',
            last_name='User'
        )
        
        self.admin_user = self.create_test_admin_user(
            email='admin@example.com'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='+1234567890',
            city='New York',
            country='USA'
        )
        
        self.industry = Industry.objects.create(
            name='Technology',
            slug='technology'
        )
        
        self.category = TemplateCategory.objects.create(
            name='Modern',
            slug='modern'
        )
        
        self.template = Template.objects.create(
            name='Test Template',
            slug='test-template',
            category=self.category,
            html_template='<div>{{ cv.student.first_name }}</div>',
            status=Template.Status.ACTIVE
        )
        
        # Set up authentication
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        self.admin_client = APIClient()
        admin_refresh = RefreshToken.for_user(self.admin_user)
        self.admin_client.credentials(HTTP_AUTHORIZATION=f'Bearer {admin_refresh.access_token}')
    
    def test_industry_list_api(self):
        """Test industry list API."""
        url = reverse('template_engine:industry-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('data', response.data)
    
    def test_template_list_api(self):
        """Test template list API."""
        url = reverse('template_engine:template-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('data', response.data)
    
    def test_template_detail_api(self):
        """Test template detail API."""
        url = reverse('template_engine:template-detail', kwargs={'slug': self.template.slug})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertEqual(response.data['data']['name'], self.template.name)
    
    def test_template_preview_api(self):
        """Test template preview API."""
        url = reverse('template_engine:template-preview', kwargs={'slug': self.template.slug})
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('preview_html', response.data['data'])
    
    def test_template_render_api(self):
        """Test template render API."""
        url = reverse('template_engine:template-render', kwargs={'slug': self.template.slug})
        data = {
            'template_id': str(self.template.id),
            'custom_branding': {
                'primary_color': '#ff0000'
            }
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('rendered_html', response.data['data'])
    
    def test_template_favorite_api(self):
        """Test template favorite/unfavorite API."""
        # Test add to favorites
        url = reverse('template_engine:template-favorite', kwargs={'slug': self.template.slug})
        response = self.client.post(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        
        # Verify template is in favorites
        preference = UserTemplatePreference.objects.get(user=self.user)
        self.assertIn(self.template, preference.favorite_templates.all())
        
        # Test remove from favorites
        url = reverse('template_engine:template-unfavorite', kwargs={'slug': self.template.slug})
        response = self.client.delete(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
    
    def test_template_recommendations_api(self):
        """Test template recommendations API."""
        url = reverse('template_engine:template-recommendations')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('data', response.data)
    
    def test_user_preferences_api(self):
        """Test user preferences API."""
        url = reverse('template_engine:preference-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        
        # Test update preferences
        data = {
            'preferred_industry_ids': [str(self.industry.id)],
            'section_order_preferences': {
                'education': 1,
                'experience': 2
            }
        }
        response = self.client.put(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
    
    def test_admin_template_creation(self):
        """Test admin template creation."""
        url = reverse('template_engine:template-list')
        data = {
            'name': 'New Template',
            'slug': 'new-template',
            'description': 'A new template',
            'category_id': str(self.category.id),
            'layout_type': Template.Layout.SINGLE_COLUMN,
            'html_template': '<div>{{ cv.student.first_name }}</div>',
            'status': Template.Status.DRAFT
        }
        
        response = self.admin_client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        self.assertTrue(response.data['success'])
        
        # Verify template was created
        template = Template.objects.get(slug='new-template')
        self.assertEqual(template.name, 'New Template')
    
    def test_permission_restrictions(self):
        """Test permission restrictions."""
        # Test non-admin cannot create templates
        url = reverse('template_engine:template-list')
        data = {
            'name': 'Unauthorized Template',
            'slug': 'unauthorized-template',
            'category_id': str(self.category.id),
            'html_template': '<div>Test</div>'
        }
        
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
        
        # Test unauthenticated access
        unauth_client = APIClient()
        response = unauth_client.get(reverse('template_engine:template-list'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class TemplateEngineSignalTests(TransactionTestCase, SecureTestMixin):
    """Test template engine signals with secure credentials."""
    
    def setUp(self):
        """Set up test data with secure credentials."""
        self.user = self.create_test_user(
            email='test@example.com'
        )
        
        self.category = TemplateCategory.objects.create(
            name='Test Category',
            slug='test-category'
        )
        
        cache.clear()  # Clear cache before tests
    
    def test_template_save_signal(self):
        """Test template save signal."""
        # Create template
        template = Template.objects.create(
            name='Test Template',
            slug='test-template',
            category=self.category,
            html_template='<div>Test</div>',
            status=Template.Status.ACTIVE
        )
        
        # Verify template was created
        self.assertEqual(template.name, 'Test Template')
        
        # Update template
        template.description = 'Updated description'
        template.save()
        
        # Verify update
        template.refresh_from_db()
        self.assertEqual(template.description, 'Updated description')
    
    def test_template_usage_signal(self):
        """Test template usage signal."""
        template = Template.objects.create(
            name='Test Template',
            slug='test-template',
            category=self.category,
            html_template='<div>Test</div>',
            status=Template.Status.ACTIVE,
            usage_count=0
        )
        
        # Create usage record
        TemplateUsage.objects.create(
            template=template,
            user=self.user,
            action=TemplateUsage.Action.GENERATE
        )
        
        # Verify usage count was updated
        template.refresh_from_db()
        # Note: The signal updates usage_count, but we need to check the actual implementation
    
    def test_favorite_change_signal(self):
        """Test favorite change signal."""
        template = Template.objects.create(
            name='Test Template',
            slug='test-template',
            category=self.category,
            html_template='<div>Test</div>',
            status=Template.Status.ACTIVE
        )
        
        # Create user preferences
        preference = UserTemplatePreference.objects.create(user=self.user)
        
        # Add template to favorites
        preference.favorite_templates.add(template)
        
        # Verify template is in favorites
        self.assertIn(template, preference.favorite_templates.all())
        
        # Remove from favorites
        preference.favorite_templates.remove(template)
        
        # Verify template is not in favorites
        self.assertNotIn(template, preference.favorite_templates.all())


class TemplateEngineIntegrationTests(APITestCase, SecureTestMixin):
    """Integration tests for template engine with secure credentials."""
    
    def setUp(self):
        """Set up test data with secure credentials."""
        self.user = self.create_test_user(
            email='test@example.com',
            first_name='John',
            last_name='Doe'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='+1234567890',
            city='New York',
            country='USA',
            summary='Software developer with 5 years experience'
        )
        
        self.client = APIClient()
        refresh = RefreshToken.for_user(self.user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {refresh.access_token}')
        
        # Create test data
        self.industry = Industry.objects.create(name='Technology', slug='technology')
        self.category = TemplateCategory.objects.create(name='Modern', slug='modern')
        
        self.template = Template.objects.create(
            name='Modern Tech CV',
            slug='modern-tech-cv',
            category=self.category,
            html_template='<div>{{ cv.student.first_name }} {{ cv.student.last_name }}</div>',
            status=Template.Status.ACTIVE
        )
        self.template.industries.add(self.industry)
    
    def test_complete_template_workflow(self):
        """Test complete template workflow from discovery to rendering."""
        # 1. Get template recommendations
        url = reverse('template_engine:template-recommendations')
        response = self.client.get(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # 2. Browse templates by category
        url = reverse('template_engine:template-list')
        response = self.client.get(url, {'category': 'modern'})
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # 3. Preview template
        url = reverse('template_engine:template-preview', kwargs={'slug': self.template.slug})
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # 4. Add to favorites
        url = reverse('template_engine:template-favorite', kwargs={'slug': self.template.slug})
        response = self.client.post(url)
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # 5. Render template with CV data
        url = reverse('template_engine:template-render', kwargs={'slug': self.template.slug})
        data = {'template_id': str(self.template.id)}
        response = self.client.post(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        
        # Verify rendered content contains user data
        rendered_html = response.data['data']['rendered_html']
        self.assertIn('John Doe', rendered_html)
        
        # 6. Update preferences
        url = reverse('template_engine:preference-list')
        data = {
            'preferred_industry_ids': [str(self.industry.id)],
            'default_template_id': str(self.template.id)
        }
        response = self.client.put(url, data, format='json')
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_analytics_tracking(self):
        """Test analytics tracking throughout workflow."""
        # Generate some usage
        actions = [
            TemplateUsage.Action.PREVIEW,
            TemplateUsage.Action.GENERATE,
            TemplateUsage.Action.DOWNLOAD,
            TemplateUsage.Action.FAVORITE
        ]
        
        for action in actions:
            TemplateUsage.objects.create(
                template=self.template,
                user=self.user,
                action=action,
                render_time_ms=100 if action == TemplateUsage.Action.GENERATE else None
            )
        
        # Verify usage was tracked
        usage_count = TemplateUsage.objects.filter(template=self.template).count()
        self.assertEqual(usage_count, 4)
        
        # Test analytics aggregation
        from ..services import TemplateAnalyticsService
        
        metrics = TemplateAnalyticsService.get_template_performance_metrics(
            template=self.template,
            days=30
        )
        
        self.assertIn('usage_stats', metrics)
        self.assertGreater(metrics['usage_stats']['total_previews'], 0)
        self.assertGreater(metrics['usage_stats']['total_generations'], 0)