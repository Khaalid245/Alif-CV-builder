#!/usr/bin/env python3
"""
Test script for CV Intelligence Analysis History endpoints.
Tests the new history functionality we just implemented.
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

def test_endpoints():
    """Test the CV Intelligence history endpoints."""
    
    print("🧪 Testing CV Intelligence Analysis History Endpoints")
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
    
    # Step 2: Test CV Analysis (to create history)
    print("\n2. Running CV Analysis to create history...")
    analysis_response = requests.post(f"{BASE_URL}/cv/analyze/", headers=headers)
    
    if analysis_response.status_code == 200:
        print("✅ CV Analysis completed successfully")
        analysis_data = analysis_response.json()["data"]
        print(f"   Overall Score: {analysis_data.get('overall_score', 'N/A')}")
    else:
        print(f"⚠️  CV Analysis failed: {analysis_response.status_code}")
        print(f"   Response: {analysis_response.text}")
    
    # Step 3: Test Analysis History List
    print("\n3. Testing Analysis History List endpoint...")
    history_response = requests.get(f"{BASE_URL}/cv/analysis/history/", headers=headers)
    
    if history_response.status_code == 200:
        print("✅ Analysis History endpoint working")
        history_data = history_response.json()["data"]
        print(f"   Total records: {history_data.get('total', 0)}")
        print(f"   Current page: {history_data.get('current_page', 1)}")
        
        results = history_data.get('results', [])
        if results:
            print(f"   Latest analysis: {results[0].get('overall_score')}% on {results[0].get('formatted_date')}")
            
            # Step 4: Test specific history detail
            history_id = results[0].get('id')
            if history_id:
                print(f"\n4. Testing Analysis History Detail endpoint...")
                detail_response = requests.get(f"{BASE_URL}/cv/analysis/history/{history_id}/", headers=headers)
                
                if detail_response.status_code == 200:
                    print("✅ Analysis History Detail endpoint working")
                    detail_data = detail_response.json()["data"]
                    print(f"   Analysis ID: {detail_data.get('id')}")
                    print(f"   Recommendations: {detail_data.get('total_recommendations', 0)}")
                else:
                    print(f"❌ Analysis History Detail failed: {detail_response.status_code}")
        else:
            print("   No history records found")
    else:
        print(f"❌ Analysis History failed: {history_response.status_code}")
        print(f"   Response: {history_response.text}")
    
    # Step 5: Test pagination
    print("\n5. Testing pagination...")
    paginated_response = requests.get(
        f"{BASE_URL}/cv/analysis/history/", 
        headers=headers,
        params={"limit": 5, "offset": 0}
    )
    
    if paginated_response.status_code == 200:
        print("✅ Pagination working")
        paginated_data = paginated_response.json()["data"]
        print(f"   Has next: {paginated_data.get('has_next', False)}")
        print(f"   Has previous: {paginated_data.get('has_previous', False)}")
    else:
        print(f"❌ Pagination test failed: {paginated_response.status_code}")
    
    print("\n" + "=" * 60)
    print("🎉 CV Intelligence Analysis History testing completed!")
    return True

if __name__ == "__main__":
    try:
        test_endpoints()
    except Exception as e:
        print(f"❌ Test failed with error: {e}")
        sys.exit(1)