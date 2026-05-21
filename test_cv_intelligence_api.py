#!/usr/bin/env python3
"""
Test CV Intelligence API endpoints to understand response formats.
"""
import requests
import json
import sys
import os

# Add the project root to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'cvbuilder-backend'))

BASE_URL = "http://localhost:8000/api/v1"

def test_endpoint(endpoint, method="GET", data=None, headers=None):
    """Test an API endpoint and return the response."""
    url = f"{BASE_URL}{endpoint}"
    
    try:
        if method == "GET":
            response = requests.get(url, headers=headers)
        elif method == "POST":
            response = requests.post(url, json=data, headers=headers)
        
        print(f"\n{'='*60}")
        print(f"Testing: {method} {endpoint}")
        print(f"Status Code: {response.status_code}")
        print(f"Response Headers: {dict(response.headers)}")
        
        if response.status_code == 200:
            try:
                json_data = response.json()
                print(f"Response JSON:")
                print(json.dumps(json_data, indent=2))
                return json_data
            except json.JSONDecodeError:
                print(f"Response Text: {response.text}")
        else:
            print(f"Error Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"Request failed: {e}")
    
    return None

def main():
    """Test CV Intelligence endpoints."""
    print("Testing CV Intelligence API Endpoints")
    print("="*60)
    
    # Test without authentication first
    print("\n1. Testing endpoints without authentication:")
    
    # Test analyze endpoint
    test_endpoint("/cv/analyze/")
    
    # Test score endpoint  
    test_endpoint("/cv/score/")
    
    # Test history endpoint
    test_endpoint("/cv/intelligence/analysis/history/")
    test_endpoint("/cv/analysis/history/")
    
    # Test benchmarking endpoint
    test_endpoint("/cv/benchmarking/")
    
    print("\n" + "="*60)
    print("Note: Most endpoints require authentication.")
    print("Expected responses:")
    print("- 401 Unauthorized for protected endpoints")
    print("- 404 Not Found for incorrect paths")
    print("- 200 OK for accessible endpoints")

if __name__ == "__main__":
    main()