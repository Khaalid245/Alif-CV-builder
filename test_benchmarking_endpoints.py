#!/usr/bin/env python3
"""
Test script for CV Intelligence Benchmarking Infrastructure.
Tests the new benchmarking system we just implemented.
"""

import requests
import json
import sys
from datetime import datetime

# Configuration
BASE_URL = "http://127.0.0.1:8000/api/v1"
TEST_USER = {
    "email": "test@example.com",
    "password": "testpass123"
}

def test_benchmarking_endpoints():
    """Test the CV Intelligence benchmarking endpoints."""
    
    print("🏆 Testing CV Intelligence Benchmarking Infrastructure")
    print("=" * 60)
    
    # Step 1: Login to get authentication token
    print("1. Authenticating user...")
    login_response = requests.post(f"{BASE_URL}/auth/login/", json=TEST_USER)
    
    if login_response.status_code != 200:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"Response: {login_response.text}")
        return False
    
    token = login_response.json()["data"]["access"]
    headers = {"Authorization": f"Bearer {token}"}
    print("✅ Authentication successful")
    
    # Step 2: Create some analysis data first
    print("\n2. Creating analysis data for benchmarking...")
    analysis_response = requests.post(f"{BASE_URL}/cv/analyze/", headers=headers)
    
    if analysis_response.status_code == 200:
        print("✅ CV Analysis completed successfully")
        analysis_data = analysis_response.json()["data"]
        print(f"   Overall Score: {analysis_data.get('overall_score', 'N/A')}")
    else:
        print(f"⚠️  CV Analysis failed: {analysis_response.status_code}")
        print(f"   Response: {analysis_response.text}")
    
    # Step 3: Test Benchmarking endpoint (all students)
    print("\n3. Testing Benchmarking endpoint (all students)...")
    benchmark_response = requests.get(f"{BASE_URL}/cv/benchmarking/", headers=headers)
    
    if benchmark_response.status_code == 200:
        print("✅ Benchmarking endpoint working")
        benchmark_data = benchmark_response.json()["data"]
        
        print(f"   Current Score: {benchmark_data.get('current_score', 'N/A')}")
        print(f"   Percentile Rank: {benchmark_data.get('percentile_rank', 'N/A')}th")
        print(f"   User Rank: #{benchmark_data.get('user_rank', 'N/A')} out of {benchmark_data.get('total_participants', 'N/A')}")
        print(f"   Performance Level: {benchmark_data.get('performance_level', 'N/A')}")
        print(f"   Average Score: {benchmark_data.get('average_score', 'N/A')}")
        print(f"   Top Score: {benchmark_data.get('top_score', 'N/A')}")
        
        # Display insights
        insights = benchmark_data.get('benchmark_insights', [])
        if insights:
            print(f"   Insights:")
            for i, insight in enumerate(insights[:3], 1):
                print(f"     {i}. {insight}")
        
        # Display section percentiles
        section_percentiles = benchmark_data.get('section_percentiles', {})
        if section_percentiles:
            print(f"   Section Percentiles:")
            for section, percentile in section_percentiles.items():
                print(f"     {section}: {percentile}th percentile")
                
    else:
        print(f"❌ Benchmarking failed: {benchmark_response.status_code}")
        print(f"   Response: {benchmark_response.text}")
    
    # Step 4: Test Benchmarking with group filter
    print("\n4. Testing Benchmarking with group filter...")
    grouped_response = requests.get(
        f"{BASE_URL}/cv/benchmarking/", 
        headers=headers,
        params={"group": "faculty"}
    )
    
    if grouped_response.status_code == 200:
        print("✅ Group filtering working")
        grouped_data = grouped_response.json()["data"]
        print(f"   Comparison Group: {grouped_data.get('comparison_group', 'N/A')}")
        print(f"   Total Participants: {grouped_data.get('total_participants', 'N/A')}")
    else:
        print(f"❌ Group filtering test failed: {grouped_response.status_code}")
    
    # Step 5: Test invalid group parameter
    print("\n5. Testing invalid group parameter...")
    invalid_response = requests.get(
        f"{BASE_URL}/cv/benchmarking/", 
        headers=headers,
        params={"group": "invalid_group"}
    )
    
    if invalid_response.status_code == 400:
        print("✅ Invalid group parameter properly rejected")
    else:
        print(f"⚠️  Expected 400 error for invalid group, got: {invalid_response.status_code}")
    
    # Step 6: Test performance levels calculation
    print("\n6. Testing performance levels...")
    if benchmark_response.status_code == 200:
        performance_level = benchmark_data.get('performance_level', '')
        current_score = benchmark_data.get('current_score', 0)
        
        expected_levels = {
            (90, 100): 'excellent',
            (75, 89): 'strong', 
            (60, 74): 'average',
            (40, 59): 'needs_improvement',
            (0, 39): 'poor'
        }
        
        expected_level = None
        for (min_score, max_score), level in expected_levels.items():
            if min_score <= current_score <= max_score:
                expected_level = level
                break
        
        if performance_level == expected_level:
            print(f"✅ Performance level calculation correct: {performance_level}")
        else:
            print(f"⚠️  Performance level mismatch. Expected: {expected_level}, Got: {performance_level}")
    
    print("\n" + "=" * 60)
    print("🎉 CV Intelligence Benchmarking testing completed!")
    return True

if __name__ == "__main__":
    try:
        test_benchmarking_endpoints()
    except Exception as e:
        print(f"❌ Test failed with error: {e}")
        sys.exit(1)