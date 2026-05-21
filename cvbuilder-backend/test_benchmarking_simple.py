#!/usr/bin/env python
"""
Simple test for CV Benchmarking System.
Tests the core benchmarking calculations.
"""
import os
import sys
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.contrib.auth import get_user_model
from apps.cv_intelligence.models import CVAnalysisHistory
from apps.cv_intelligence.benchmarking_service import CVBenchmarkingService
from decimal import Decimal

User = get_user_model()

def test_benchmarking_calculations():
    """Test benchmarking calculations with existing data."""
    print("Testing CV Benchmarking Calculations")
    print("="*50)
    
    service = CVBenchmarkingService()
    
    # Get all users with analysis history
    users_with_analysis = User.objects.filter(cv_analysis_history__isnull=False).distinct()
    
    print(f"Found {users_with_analysis.count()} users with analysis history")
    
    if users_with_analysis.count() == 0:
        print("No users with analysis history found. Creating sample data...")
        create_sample_data()
        users_with_analysis = User.objects.filter(cv_analysis_history__isnull=False).distinct()
    
    # Test benchmarking for first few users
    for i, user in enumerate(users_with_analysis[:3]):
        print(f"\n--- User {i+1}: {user.email} ---")
        
        try:
            # Get user's latest analysis
            latest_analysis = CVAnalysisHistory.objects.filter(user=user).first()
            if latest_analysis:
                print(f"User Score: {latest_analysis.overall_score}")
                
                # Test benchmarking service
                benchmark_data = service.get_user_benchmarking_data(user)
                
                print(f"Percentile Rank: {benchmark_data['percentile_rank']}%")
                print(f"User Rank: #{benchmark_data['user_rank']} out of {benchmark_data['total_participants']}")
                print(f"Performance Level: {benchmark_data['performance_level']}")
                print(f"Average Score: {benchmark_data['average_score']}")
                print(f"Top Score: {benchmark_data['top_score']}")
                
                # Show first few insights
                insights = benchmark_data['benchmark_insights'][:2]
                for insight in insights:
                    print(f"  • {insight}")
                    
        except Exception as e:
            print(f"Error testing user {user.email}: {e}")

def create_sample_data():
    """Create minimal sample data for testing."""
    print("Creating sample analysis data...")
    
    # Get or create a test user
    user, created = User.objects.get_or_create(
        email='test_benchmark@example.com',
        defaults={
            'full_name': 'Test Benchmark User',
            'is_active': True,
            'terms_consent': True,
            'data_processing_consent': True,
        }
    )
    
    if created:
        user.set_password('testpass123')
        user.save()
    
    # Create analysis history
    CVAnalysisHistory.objects.get_or_create(
        user=user,
        defaults={
            'overall_score': Decimal('75.5'),
            'readiness_score': Decimal('70.0'),
            'readiness_grade': 'B',
            'section_scores': {
                'profile': 80,
                'experience': 75,
                'education': 85,
                'skills': 70,
                'projects': 65,
            },
            'recommendations': ['Improve skills section', 'Add more projects'],
            'strengths': ['Good education background'],
            'weaknesses': ['Limited project experience'],
            'analysis_version': '1.0',
            'total_recommendations': 2,
        }
    )
    
    print(f"Created sample data for {user.email}")

def main():
    """Main test function."""
    test_benchmarking_calculations()
    print("\n" + "="*50)
    print("BENCHMARKING TEST COMPLETE")

if __name__ == '__main__':
    main()