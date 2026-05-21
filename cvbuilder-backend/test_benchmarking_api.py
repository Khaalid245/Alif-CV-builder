#!/usr/bin/env python
"""
Test the benchmarking API endpoint directly.
"""
import os
import sys
import django
from django.conf import settings

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

import json
from django.test import Client
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken

User = get_user_model()

def test_benchmarking_api():
    """Test the benchmarking API endpoint."""
    print("Testing Benchmarking API Endpoint")
    print("="*50)
    
    # Get a test user
    user = User.objects.filter(cv_analysis_history__isnull=False).first()
    if not user:
        print("No user with analysis history found")
        return
    
    print(f"Testing with user: {user.email}")
    
    # Create JWT token
    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    
    # Test the API endpoint
    client = Client()
    
    # Add testserver to allowed hosts temporarily
    from django.conf import settings
    original_allowed_hosts = settings.ALLOWED_HOSTS
    settings.ALLOWED_HOSTS = ['testserver'] + list(original_allowed_hosts)
    
    try:
        response = client.get(
            '/api/v1/cv/benchmarking/',
            HTTP_AUTHORIZATION=f'Bearer {access_token}',
            HTTP_HOST='testserver'
        )
        
        print(f"API Response Status: {response.status_code}")
        
        if response.status_code == 200:
            data = json.loads(response.content)
            print("[SUCCESS] API Response Success:", data.get('success'))
            print("[SUCCESS] API Response Message:", data.get('message'))
            
            if data.get('data'):
                benchmark_data = data['data']
                print(f"[SUCCESS] Current Score: {benchmark_data.get('current_score')}")
                print(f"[SUCCESS] Percentile Rank: {benchmark_data.get('percentile_rank')}%")
                print(f"[SUCCESS] User Rank: #{benchmark_data.get('user_rank')} out of {benchmark_data.get('total_participants')}")
                print(f"[SUCCESS] Performance Level: {benchmark_data.get('performance_level')}")
                print(f"[SUCCESS] Average Score: {benchmark_data.get('average_score')}")
                print(f"[SUCCESS] Top Score: {benchmark_data.get('top_score')}")
                
                insights = benchmark_data.get('benchmark_insights', [])
                print(f"[SUCCESS] Insights ({len(insights)} total):")
                for insight in insights[:3]:  # Show first 3
                    print(f"    - {insight}")
                    
                print("[SUCCESS] API endpoint is working correctly!")
        else:
            print("[ERROR] API Error Response:")
            print(response.content.decode())
            
    finally:
        # Restore original allowed hosts
        settings.ALLOWED_HOSTS = original_allowed_hosts

def main():
    """Main test function."""
    test_benchmarking_api()
    print("\n" + "="*50)
    print("API TEST COMPLETE")

if __name__ == '__main__':
    main()