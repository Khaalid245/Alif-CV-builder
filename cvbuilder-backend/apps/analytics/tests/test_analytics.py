"""
Comprehensive tests for Analytics system.
Tests models, services, views, and permissions.
"""
import json
from datetime import datetime, timedelta
from decimal import Decimal
from django.test import TestCase
from django.urls import reverse
from django.contrib.auth import get_user_model
from django.utils import timezone
from rest_framework.test import APIClient
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken
from unittest.mock import patch, MagicMock

from apps.cv.models import CVProfile
from apps.cv_intelligence.models import CVAnalysis
from ..models import (
    AnalyticsConfiguration, ScoreSnapshot, BenchmarkingGroup,
    BenchmarkingGroupMembership, MetricDefinition, AggregatedMetric,
    TrendAnalysis, AnalyticsEvent, AnalyticsCache
)
from ..services import analytics_service

User = get_user_model()


class AnalyticsModelTest(TestCase):
    """Test analytics models."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@example.com',
            password='secure_test_password_123'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            completion_percentage=75
        )
        
        self.config = AnalyticsConfiguration.objects.create(
            name='Test Configuration',
            description='Test configuration',
            is_active=True,
            is_default=True
        )
    
    def test_analytics_configuration_creation(self):
        """Test analytics configuration model creation."""
        self.assertEqual(self.config.name, 'Test Configuration')
        self.assertTrue(self.config.is_active)
        self.assertTrue(self.config.is_default)
    
    def test_score_snapshot_creation(self):
        """Test score snapshot model creation."""
        snapshot = ScoreSnapshot.objects.create(
            user=self.user,
            snapshot_type='manual',
            overall_score=85,
            completion_percentage=75,
            percentile_rank=Decimal('78.50')
        )
        
        self.assertEqual(snapshot.user, self.user)
        self.assertEqual(snapshot.overall_score, 85)
        self.assertEqual(snapshot.completion_percentage, 75)
        self.assertEqual(snapshot.percentile_rank, Decimal('78.50'))
    
    def test_benchmarking_group_creation(self):
        """Test benchmarking group model creation."""
        group = BenchmarkingGroup.objects.create(
            name='Computer Science Students',
            group_type='field_of_study',
            description='Students studying computer science',
            criteria={'field': 'computer_science'}
        )
        
        self.assertEqual(group.name, 'Computer Science Students')
        self.assertEqual(group.group_type, 'field_of_study')
        self.assertTrue(group.is_active)
    
    def test_metric_definition_creation(self):
        """Test metric definition model creation."""
        metric = MetricDefinition.objects.create(
            name='average_score',
            display_name='Average Score',
            description='Average CV score across all sections',
            metric_type='score',
            aggregation_type='average',
            calculation_formula='AVG(overall_score)'
        )
        
        self.assertEqual(metric.name, 'average_score')
        self.assertEqual(metric.metric_type, 'score')
        self.assertTrue(metric.is_active)
    
    def test_analytics_event_creation(self):
        """Test analytics event model creation."""
        event = AnalyticsEvent.objects.create(
            event_type='snapshot_created',
            description='Score snapshot created for user',
            user=self.user,
            execution_time_ms=150
        )
        
        self.assertEqual(event.event_type, 'snapshot_created')
        self.assertEqual(event.user, self.user)
        self.assertEqual(event.execution_time_ms, 150)


class AnalyticsServiceTest(TestCase):
    """Test analytics service functionality."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@example.com',
            password='secure_test_password_123'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            completion_percentage=75
        )
        
        self.analysis = CVAnalysis.objects.create(
            user=self.user,
            overall_score=85,
            profile_score=80,
            experience_score=90,
            education_score=85,
            skills_score=80,
            projects_score=75,
            grade='good',
            submission_ready=True
        )
        
        # Create configuration
        AnalyticsConfiguration.objects.create(
            name='Test Configuration',
            description='Test configuration',
            is_active=True,
            is_default=True
        )
    
    def test_create_score_snapshot(self):
        """Test creating a score snapshot."""
        snapshot = analytics_service.create_score_snapshot(
            user=self.user,
            snapshot_type='manual',
            trigger_event='test_creation'
        )
        
        self.assertIsInstance(snapshot, ScoreSnapshot)
        self.assertEqual(snapshot.user, self.user)
        self.assertEqual(snapshot.snapshot_type, 'manual')
        self.assertEqual(snapshot.trigger_event, 'test_creation')
        self.assertEqual(snapshot.overall_score, 85)
        self.assertEqual(snapshot.completion_percentage, 75)
    
    def test_get_score_trend_insufficient_data(self):
        """Test score trend with insufficient data."""
        trend_data = analytics_service.get_score_trend(
            user=self.user,
            days=30,
            metric='overall_score'
        )
        
        self.assertEqual(trend_data['trend_direction'], 'insufficient_data')
        self.assertIn('message', trend_data)
    
    def test_get_score_trend_with_data(self):
        """Test score trend with sufficient data."""
        # Create multiple snapshots
        base_time = timezone.now()
        for i in range(5):
            ScoreSnapshot.objects.create(
                user=self.user,
                snapshot_type='automatic',
                overall_score=70 + i * 5,  # Improving trend
                completion_percentage=60 + i * 5,
                created_at=base_time - timedelta(days=i * 7)
            )
        
        trend_data = analytics_service.get_score_trend(
            user=self.user,
            days=30,
            metric='overall_score'
        )
        
        self.assertIn('trend_direction', trend_data)
        self.assertIn('data_points', trend_data)
        self.assertEqual(trend_data['data_points'], 5)
        self.assertIn('snapshots', trend_data)
    
    def test_get_peer_benchmarking_no_data(self):
        """Test peer benchmarking with no score data."""
        # Create user without snapshots
        user_no_data = User.objects.create_user(
            email='nodata@example.com',
            password='secure_test_password_123'
        )
        
        benchmarking_data = analytics_service.get_peer_benchmarking(user_no_data)
        
        self.assertIn('error', benchmarking_data)
    
    def test_get_completion_statistics(self):
        """Test completion statistics calculation."""
        # Create some test snapshots
        for i in range(10):
            user = User.objects.create_user(
                email=f'user{i}@example.com',
                password='secure_test_password_123'
            )
            ScoreSnapshot.objects.create(
                user=user,
                snapshot_type='automatic',
                overall_score=60 + i * 4,
                completion_percentage=50 + i * 5,
                submission_ready=i % 2 == 0
            )
        
        stats = analytics_service.get_completion_statistics(time_period=30)
        
        self.assertIn('summary_statistics', stats)
        self.assertIn('completion_distribution', stats)
        self.assertIn('score_distribution', stats)
        self.assertEqual(stats['period_days'], 30)
    
    def test_update_benchmarking_groups(self):
        """Test benchmarking groups update."""
        # Create a test group
        group = BenchmarkingGroup.objects.create(
            name='Test Group',
            group_type='education_level',
            is_active=True,
            auto_update=True
        )
        
        result = analytics_service.update_benchmarking_groups()
        
        self.assertIn('updated_groups', result)
        self.assertIn('execution_time_ms', result)
    
    def test_cleanup_old_data_dry_run(self):
        """Test data cleanup in dry run mode."""
        # Create old snapshot
        old_snapshot = ScoreSnapshot.objects.create(
            user=self.user,
            snapshot_type='automatic',
            overall_score=70,
            completion_percentage=60,
            created_at=timezone.now() - timedelta(days=400)
        )
        
        cleanup_stats = analytics_service.cleanup_old_data(dry_run=True)
        
        self.assertIn('snapshots', cleanup_stats)
        # Snapshot should still exist in dry run
        self.assertTrue(ScoreSnapshot.objects.filter(id=old_snapshot.id).exists())


class AnalyticsAPITest(TestCase):
    """Test analytics API endpoints."""
    
    def setUp(self):
        self.client = APIClient()
        
        self.user = User.objects.create_user(
            email='test@example.com',
            password='secure_test_password_123'
        )
        
        self.admin_user = User.objects.create_user(
            email='admin@example.com',
            password='secure_test_password_123',
            is_staff=True,
            is_superuser=True
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            completion_percentage=75
        )
        
        self.analysis = CVAnalysis.objects.create(
            user=self.user,
            overall_score=85,
            grade='good',
            submission_ready=True
        )
        
        # Create test snapshots
        self.snapshot1 = ScoreSnapshot.objects.create(
            user=self.user,
            snapshot_type='automatic',
            overall_score=85,
            completion_percentage=75,
            submission_ready=True
        )
        
        self.snapshot2 = ScoreSnapshot.objects.create(
            user=self.user,
            snapshot_type='manual',
            overall_score=80,
            completion_percentage=70,
            submission_ready=False
        )
        
        # Create configuration
        AnalyticsConfiguration.objects.create(
            name='Test Configuration',
            description='Test configuration',
            is_active=True,
            is_default=True
        )
    
    def get_jwt_token(self, user):
        """Get JWT token for user."""
        refresh = RefreshToken.for_user(user)
        return str(refresh.access_token)
    
    def authenticate(self, user):
        """Authenticate client with user."""
        token = self.get_jwt_token(user)
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
    
    def test_list_snapshots(self):
        """Test listing score snapshots."""
        self.authenticate(self.user)
        
        url = reverse('analytics:snapshots-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertEqual(len(data['data']['results']), 2)
    
    def test_retrieve_snapshot(self):
        """Test retrieving specific snapshot."""
        self.authenticate(self.user)
        
        url = reverse('analytics:snapshots-detail', kwargs={'pk': self.snapshot1.id})
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertEqual(data['data']['overall_score'], 85)
    
    def test_snapshot_summary(self):
        """Test snapshot summary endpoint."""
        self.authenticate(self.user)
        
        url = reverse('analytics:snapshots-summary')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('latest_snapshot', data['data'])
        self.assertIn('total_snapshots', data['data'])
    
    def test_create_snapshot(self):
        """Test creating a new snapshot."""
        self.authenticate(self.user)
        
        url = reverse('analytics:create-snapshot')
        data = {
            'snapshot_type': 'manual',
            'trigger_event': 'api_test'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        response_data = response.json()
        self.assertTrue(response_data['success'])
        self.assertEqual(response_data['data']['snapshot_type'], 'manual')
    
    def test_create_snapshot_for_other_user_as_admin(self):
        """Test admin creating snapshot for another user."""
        self.authenticate(self.admin_user)
        
        url = reverse('analytics:create-snapshot')
        data = {
            'user_id': str(self.user.id),
            'snapshot_type': 'manual',
            'trigger_event': 'admin_created'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
    
    def test_create_snapshot_for_other_user_as_user_forbidden(self):
        """Test user cannot create snapshot for another user."""
        other_user = User.objects.create_user(
            email='other@example.com',
            password='secure_test_password_123'
        )
        
        self.authenticate(self.user)
        
        url = reverse('analytics:create-snapshot')
        data = {
            'user_id': str(other_user.id),
            'snapshot_type': 'manual'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_trend_analysis(self):
        """Test trend analysis endpoint."""
        self.authenticate(self.user)
        
        url = reverse('analytics:trend-analysis')
        data = {
            'days': 30,
            'metric': 'overall_score'
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        response_data = response.json()
        self.assertTrue(response_data['success'])
        self.assertIn('trend_direction', response_data['data'])
    
    def test_benchmarking(self):
        """Test benchmarking endpoint."""
        self.authenticate(self.user)
        
        url = reverse('analytics:peer-benchmarking')
        data = {
            'group_types': ['education_level']
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        response_data = response.json()
        self.assertTrue(response_data['success'])
    
    def test_completion_statistics(self):
        """Test completion statistics endpoint."""
        self.authenticate(self.user)
        
        url = reverse('analytics:completion-statistics')
        data = {
            'time_period': 30
        }
        response = self.client.post(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        response_data = response.json()
        self.assertTrue(response_data['success'])
        self.assertIn('summary_statistics', response_data['data'])
    
    def test_user_dashboard(self):
        """Test user analytics dashboard."""
        self.authenticate(self.user)
        
        url = reverse('analytics:user-dashboard')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('user_summary', data['data'])
        self.assertIn('recent_snapshots', data['data'])
    
    def test_admin_dashboard(self):
        """Test admin analytics dashboard."""
        self.authenticate(self.admin_user)
        
        url = reverse('analytics:admin-dashboard')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
        self.assertIn('platform_overview', data['data'])
        self.assertIn('user_engagement', data['data'])
    
    def test_admin_dashboard_forbidden_for_user(self):
        """Test that regular users cannot access admin dashboard."""
        self.authenticate(self.user)
        
        url = reverse('analytics:admin-dashboard')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_configuration_get_as_admin(self):
        """Test getting configuration as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('analytics:configuration')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.json()
        self.assertTrue(data['success'])
    
    def test_configuration_update_as_admin(self):
        """Test updating configuration as admin."""
        self.authenticate(self.admin_user)
        
        url = reverse('analytics:configuration')
        data = {
            'score_calculation_enabled': False,
            'peer_group_size': 150
        }
        response = self.client.put(url, data, format='json')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
    
    def test_configuration_access_as_user_forbidden(self):
        """Test that regular users cannot access configuration."""
        self.authenticate(self.user)
        
        url = reverse('analytics:configuration')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_403_FORBIDDEN)
    
    def test_unauthenticated_access_forbidden(self):
        """Test that unauthenticated users cannot access analytics."""
        url = reverse('analytics:snapshots-list')
        response = self.client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)


class AnalyticsPermissionTest(TestCase):
    """Test analytics permissions."""
    
    def setUp(self):
        self.user1 = User.objects.create_user(
            email='user1@example.com',
            password='secure_test_password_123'
        )
        
        self.user2 = User.objects.create_user(
            email='user2@example.com',
            password='secure_test_password_123'
        )
        
        self.admin_user = User.objects.create_user(
            email='admin@example.com',
            password='secure_test_password_123',
            is_staff=True
        )
        
        self.snapshot = ScoreSnapshot.objects.create(
            user=self.user1,
            snapshot_type='automatic',
            overall_score=85,
            completion_percentage=75
        )
    
    def test_user_can_only_access_own_snapshots(self):
        """Test that users can only access their own snapshots."""
        client = APIClient()
        
        # Authenticate as user2
        refresh = RefreshToken.for_user(self.user2)
        token = str(refresh.access_token)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        
        # Try to access user1's snapshot
        url = reverse('analytics:snapshots-detail', kwargs={'pk': self.snapshot.id})
        response = client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_404_NOT_FOUND)
    
    def test_admin_can_access_all_snapshots(self):
        """Test that admin users can access all snapshots."""
        client = APIClient()
        
        # Authenticate as admin
        refresh = RefreshToken.for_user(self.admin_user)
        token = str(refresh.access_token)
        client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        
        # Access user1's snapshot
        url = reverse('analytics:snapshots-detail', kwargs={'pk': self.snapshot.id})
        response = client.get(url)
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)


class AnalyticsSignalTest(TestCase):
    """Test analytics signals."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@example.com',
            password='secure_test_password_123'
        )
        
        self.cv_profile = CVProfile.objects.create(
            student=self.user,
            phone='1234567890',
            completion_percentage=75
        )
        
        # Create configuration
        AnalyticsConfiguration.objects.create(
            name='Test Configuration',
            description='Test configuration',
            is_active=True,
            is_default=True
        )
    
    @patch('apps.analytics.services.analytics_service.create_score_snapshot')
    def test_cv_analysis_signal(self, mock_create_snapshot):
        """Test that CV analysis creation triggers snapshot."""
        analysis = CVAnalysis.objects.create(
            user=self.user,
            overall_score=85,
            grade='good',
            submission_ready=True
        )
        
        # Verify snapshot creation was called
        mock_create_snapshot.assert_called_once()
        call_args = mock_create_snapshot.call_args
        self.assertEqual(call_args[1]['user'], self.user)
        self.assertEqual(call_args[1]['trigger_event'], 'cv_analysis_completed')