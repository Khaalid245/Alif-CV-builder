#!/usr/bin/env python
"""
Test script for CV Benchmarking System.
Creates test users with different scores and verifies benchmarking calculations.
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
import random

User = get_user_model()

def create_test_users_with_scores():
    """Create test users with varying CV scores for benchmarking."""
    print("Creating test users with different CV scores...")
    
    # Define test users with different score ranges
    test_users = [
        ('excellent1@test.com', 'Test', 'Excellent1', random.uniform(90, 100)),
        ('excellent2@test.com', 'Test', 'Excellent2', random.uniform(90, 100)),
        ('strong1@test.com', 'Test', 'Strong1', random.uniform(75, 89)),
        ('strong2@test.com', 'Test', 'Strong2', random.uniform(75, 89)),
        ('strong3@test.com', 'Test', 'Strong3', random.uniform(75, 89)),
        ('average1@test.com', 'Test', 'Average1', random.uniform(60, 74)),
        ('average2@test.com', 'Test', 'Average2', random.uniform(60, 74)),
        ('average3@test.com', 'Test', 'Average3', random.uniform(60, 74)),
        ('average4@test.com', 'Test', 'Average4', random.uniform(60, 74)),
        ('needs_improvement1@test.com', 'Test', 'NeedsImprovement1', random.uniform(40, 59)),
        ('needs_improvement2@test.com', 'Test', 'NeedsImprovement2', random.uniform(40, 59)),
        ('poor1@test.com', 'Test', 'Poor1', random.uniform(0, 39)),
        ('poor2@test.com', 'Test', 'Poor2', random.uniform(0, 39)),
    ]
    
    created_users = []
    
    for email, first_name, last_name, score in test_users:
        # Create or get user
        user, created = User.objects.get_or_create(
            email=email,
            defaults={
                'full_name': f'{first_name} {last_name}',
                'is_active': True,
                'terms_consent': True,
                'marketing_consent': True,
                'data_processing_consent': True,
            }
        )
        
        if created:
            user.set_password('testpass123')
            user.save()
            print(f"Created user: {email}")
        
        # Create analysis history with the score
        analysis_history, created = CVAnalysisHistory.objects.get_or_create(
            user=user,
            defaults={
                'overall_score': Decimal(str(round(score, 2))),
                'readiness_score': Decimal(str(round(score * 0.9, 2))),
                'readiness_grade': get_grade_from_score(score),
                'section_scores': {
                    'profile': round(score + random.uniform(-10, 10), 2),
                    'experience': round(score + random.uniform(-10, 10), 2),
                    'education': round(score + random.uniform(-10, 10), 2),
                    'skills': round(score + random.uniform(-10, 10), 2),
                    'projects': round(score + random.uniform(-10, 10), 2),
                },
                'recommendations': [
                    f'Improve your CV score from {score:.1f}',
                    'Add more relevant experience',
                    'Enhance your skills section'
                ],
                'strengths': ['Good overall structure'],
                'weaknesses': ['Could use more detail'],
                'analysis_version': '1.0',
                'total_recommendations': 3,
            }
        )
        
        if created:
            print(f"Created analysis history for {email} with score {score:.2f}")
        
        created_users.append((user, score))
    
    return created_users

def get_grade_from_score(score):
    """Convert numeric score to letter grade."""
    if score >= 90:
        return 'A'
    elif score >= 80:
        return 'B'
    elif score >= 70:
        return 'C'
    elif score >= 60:
        return 'D'
    else:
        return 'F'

def test_benchmarking_service():
    """Test the benchmarking service with created users."""
    print("\n" + "="*50)
    print("TESTING BENCHMARKING SERVICE")
    print("="*50)
    
    service = CVBenchmarkingService()
    
    # Get all test users
    test_users = User.objects.filter(email__contains='@test.com')
    
    if not test_users.exists():
        print("No test users found. Creating them first...")
        create_test_users_with_scores()
        test_users = User.objects.filter(email__contains='@test.com')
    
    print(f"Found {test_users.count()} test users")
    
    # Test benchmarking for a few users
    for user in test_users[:5]:  # Test first 5 users
        print(f"\n--- Benchmarking for {user.email} ---")
        
        try:
            benchmark_data = service.get_user_benchmarking_data(user)
            
            print(f"Current Score: {benchmark_data['current_score']}")
            print(f"Percentile Rank: {benchmark_data['percentile_rank']}%")
            print(f"User Rank: #{benchmark_data['user_rank']} out of {benchmark_data['total_participants']}")
            print(f"Average Score: {benchmark_data['average_score']}")
            print(f"Top Score: {benchmark_data['top_score']}")
            print(f"Performance Level: {benchmark_data['performance_level']}")
            print(f"Gap to Average: {benchmark_data['score_gap_to_average']:+.1f}")
            print(f"Gap to Top: {benchmark_data['score_gap_to_top']:+.1f}")
            
            print("Insights:")
            for insight in benchmark_data['benchmark_insights']:
                print(f"  • {insight}")
            
            print("Section Percentiles:")
            for section, percentile in benchmark_data['section_percentiles'].items():
                print(f"  {section}: {percentile}%")
                
        except Exception as e:
            print(f"Error getting benchmark data for {user.email}: {e}")

def test_api_endpoint():
    """Test the API endpoint directly."""
    print("\n" + "="*50)
    print("TESTING API ENDPOINT")
    print("="*50)
    
    from django.test import Client
    from django.contrib.auth import authenticate
    from rest_framework_simplejwt.tokens import RefreshToken
    
    # Get a test user
    user = User.objects.filter(email__contains='@test.com').first()
    if not user:
        print("No test user found for API testing")
        return
    
    # Create JWT token
    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    
    # Test the API endpoint
    client = Client()
    response = client.get(
        '/api/v1/cv/benchmarking/',
        HTTP_AUTHORIZATION=f'Bearer {access_token}'
    )
    
    print(f"API Response Status: {response.status_code}")
    if response.status_code == 200:
        import json
        data = json.loads(response.content)
        print("API Response Success:", data.get('success'))
        print("API Response Message:", data.get('message'))
        if data.get('data'):
            benchmark_data = data['data']
            print(f"Percentile Rank: {benchmark_data.get('percentile_rank')}%")
            print(f"Performance Level: {benchmark_data.get('performance_level')}")
    else:
        print("API Response Content:", response.content.decode())

def main():
    """Main test function."""
    print("CV Benchmarking System Test")
    print("="*50)
    
    # Create test users if they don't exist
    users = create_test_users_with_scores()
    print(f"Total test users: {len(users)}")
    
    # Test the benchmarking service
    test_benchmarking_service()
    
    # Test the API endpoint
    test_api_endpoint()
    
    print("\n" + "="*50)
    print("BENCHMARKING SYSTEM TEST COMPLETE")
    print("="*50)

if __name__ == '__main__':
    main()