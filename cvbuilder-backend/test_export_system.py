#!/usr/bin/env python
"""
Test script for CV Analysis Export functionality.
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
from pathlib import Path

User = get_user_model()

def test_export_api():
    """Test the export API endpoint."""
    print("Testing CV Analysis Export API")
    print("="*50)
    
    # Get a test user with analysis history
    user = User.objects.filter(cv_analysis_history__isnull=False).first()
    if not user:
        print("No user with analysis history found")
        return
    
    print(f"Testing with user: {user.email}")
    
    # Create JWT token
    refresh = RefreshToken.for_user(user)
    access_token = str(refresh.access_token)
    
    # Test the export endpoint
    client = Client()
    
    # Add testserver to allowed hosts temporarily
    from django.conf import settings
    original_allowed_hosts = settings.ALLOWED_HOSTS
    settings.ALLOWED_HOSTS = ['testserver'] + list(original_allowed_hosts)
    
    try:
        response = client.get(
            '/api/v1/cv/export-analysis/',
            HTTP_AUTHORIZATION=f'Bearer {access_token}',
            HTTP_HOST='testserver'
        )
        
        print(f"API Response Status: {response.status_code}")
        
        if response.status_code == 200:
            print("[SUCCESS] PDF export successful!")
            print(f"Content-Type: {response.get('Content-Type')}")
            print(f"Content-Length: {response.get('Content-Length')}")
            print(f"Filename: {response.get('Content-Disposition')}")
            print(f"Generated-At: {response.get('X-Generated-At')}")
            
            # Check if it's actually a PDF
            content = b''.join(response.streaming_content)
            if content.startswith(b'%PDF'):
                print("[SUCCESS] Valid PDF file generated")
                print(f"PDF Size: {len(content)} bytes")
            else:
                print("[ERROR] Response is not a valid PDF")
                
        else:
            print("[ERROR] Export failed")
            try:
                error_data = json.loads(response.content)
                print(f"Error: {error_data.get('message', 'Unknown error')}")
            except:
                print(f"Raw response: {response.content.decode()}")
                
    finally:
        # Restore original allowed hosts
        settings.ALLOWED_HOSTS = original_allowed_hosts

def test_export_service_directly():
    """Test the export service directly."""
    print("\nTesting Export Service Directly")
    print("="*50)
    
    from apps.cv_intelligence.export_service import CVAnalysisExportService
    
    # Get a test user
    user = User.objects.filter(cv_analysis_history__isnull=False).first()
    if not user:
        print("No user with analysis history found")
        return
    
    print(f"Testing with user: {user.email}")
    
    try:
        service = CVAnalysisExportService(user)
        report_info = service.generate_analysis_report()
        
        print("[SUCCESS] Report generated successfully!")
        print(f"Filename: {report_info['filename']}")
        print(f"File Size: {report_info['file_size']} bytes")
        print(f"File Path: {report_info['file_path']}")
        
        # Check if file exists
        file_path = Path(settings.MEDIA_ROOT) / report_info['file_path']
        if file_path.exists():
            print("[SUCCESS] PDF file exists on disk")
            
            # Check if it's a valid PDF
            with open(file_path, 'rb') as f:
                header = f.read(4)
                if header == b'%PDF':
                    print("[SUCCESS] Valid PDF file format")
                else:
                    print("[ERROR] Invalid PDF file format")
        else:
            print("[ERROR] PDF file not found on disk")
            
    except Exception as e:
        print(f"[ERROR] Export service failed: {e}")

def main():
    """Main test function."""
    test_export_service_directly()
    test_export_api()
    print("\n" + "="*50)
    print("EXPORT TESTING COMPLETE")

if __name__ == '__main__':
    main()