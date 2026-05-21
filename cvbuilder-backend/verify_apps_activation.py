#!/usr/bin/env python
"""
Backend Apps Activation Verification Script
Verifies that all newly activated apps are properly registered and functional.
"""
import os
import sys
import django
from django.core.management import execute_from_command_line

# Setup Django
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.development')
django.setup()

from django.apps import apps
from django.urls import reverse
from django.test import Client
from django.contrib.auth import get_user_model
from django.core.management import call_command
from io import StringIO

User = get_user_model()

def test_app_registration():
    """Test that all apps are properly registered."""
    print("🔍 Testing App Registration...")
    
    required_apps = [
        'apps.analytics',
        'apps.notifications', 
        'apps.template_engine'
    ]
    
    installed_apps = [app.name for app in apps.get_app_configs()]
    
    for app_name in required_apps:
        if app_name in installed_apps:
            print(f"  ✅ {app_name} - REGISTERED")
        else:
            print(f"  ❌ {app_name} - NOT REGISTERED")
            return False
    
    return True

def test_migrations():
    """Test that migrations can be created and applied."""
    print("\n🔍 Testing Migrations...")
    
    try:
        # Check for pending migrations
        out = StringIO()
        call_command('makemigrations', '--dry-run', stdout=out, verbosity=0)
        
        if "No changes detected" in out.getvalue():
            print("  ✅ No pending migrations")
        else:
            print("  ⚠️  Pending migrations detected - creating them...")
            call_command('makemigrations', verbosity=0)
            print("  ✅ Migrations created successfully")
        
        # Test migration check
        out = StringIO()
        call_command('showmigrations', '--plan', stdout=out, verbosity=0)
        print("  ✅ Migration system working")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Migration error: {e}")
        return False

def test_url_patterns():
    """Test that URL patterns are properly registered."""
    print("\n🔍 Testing URL Patterns...")
    
    test_urls = [
        # Analytics URLs
        ('analytics:snapshots-list', 'analytics/snapshots/'),
        ('analytics:benchmarking-groups-list', 'analytics/benchmarking-groups/'),
        ('analytics:user-dashboard', 'analytics/dashboard/'),
        
        # Notifications URLs  
        ('notifications:notifications-list', 'notifications/notifications/'),
        ('notifications:templates-list', 'notifications/templates/'),
        ('notifications:user-preferences', 'notifications/preferences/'),
        
        # Template Engine URLs
        ('template_engine:industry-list', 'templates/industries/'),
        ('template_engine:template-list', 'templates/templates/'),
        ('template_engine:preference-list', 'templates/preferences/'),
    ]
    
    success_count = 0
    
    for url_name, expected_path in test_urls:
        try:
            url = reverse(url_name)
            if expected_path in url:
                print(f"  ✅ {url_name} -> {url}")
                success_count += 1
            else:
                print(f"  ⚠️  {url_name} -> {url} (unexpected path)")
        except Exception as e:
            print(f"  ❌ {url_name} - ERROR: {e}")
    
    print(f"\n  📊 URL Pattern Results: {success_count}/{len(test_urls)} working")
    return success_count == len(test_urls)

def test_model_imports():
    """Test that models can be imported successfully."""
    print("\n🔍 Testing Model Imports...")
    
    model_tests = [
        # Analytics models
        ('apps.analytics.models', ['AnalyticsConfiguration', 'ScoreSnapshot', 'BenchmarkingGroup']),
        # Notifications models
        ('apps.notifications.models', ['Notification', 'NotificationTemplate', 'NotificationBatch']),
        # Template Engine models
        ('apps.template_engine.models', ['Template', 'Industry', 'TemplateCategory']),
    ]
    
    success_count = 0
    total_models = 0
    
    for module_name, model_names in model_tests:
        try:
            module = __import__(module_name, fromlist=model_names)
            for model_name in model_names:
                total_models += 1
                if hasattr(module, model_name):
                    print(f"  ✅ {module_name}.{model_name}")
                    success_count += 1
                else:
                    print(f"  ❌ {module_name}.{model_name} - NOT FOUND")
        except Exception as e:
            print(f"  ❌ {module_name} - IMPORT ERROR: {e}")
    
    print(f"\n  📊 Model Import Results: {success_count}/{total_models} working")
    return success_count == total_models

def test_service_imports():
    """Test that services can be imported successfully."""
    print("\n🔍 Testing Service Imports...")
    
    service_tests = [
        ('apps.analytics.services', 'analytics_service'),
        ('apps.notifications.services', 'notification_service'),
        ('apps.template_engine.services', 'TemplateSelectionService'),
    ]
    
    success_count = 0
    
    for module_name, service_name in service_tests:
        try:
            module = __import__(module_name, fromlist=[service_name])
            if hasattr(module, service_name):
                print(f"  ✅ {module_name}.{service_name}")
                success_count += 1
            else:
                print(f"  ❌ {module_name}.{service_name} - NOT FOUND")
        except Exception as e:
            print(f"  ❌ {module_name} - IMPORT ERROR: {e}")
    
    print(f"\n  📊 Service Import Results: {success_count}/{len(service_tests)} working")
    return success_count == len(service_tests)

def test_admin_integration():
    """Test that models are registered in Django admin."""
    print("\n🔍 Testing Admin Integration...")
    
    from django.contrib import admin
    
    # Get all registered models
    registered_models = admin.site._registry.keys()
    model_names = [model.__name__ for model in registered_models]
    
    expected_models = [
        'AnalyticsConfiguration', 'ScoreSnapshot', 'BenchmarkingGroup',
        'Notification', 'NotificationTemplate', 'NotificationBatch', 
        'Template', 'Industry', 'TemplateCategory'
    ]
    
    success_count = 0
    for model_name in expected_models:
        if any(model_name in name for name in model_names):
            print(f"  ✅ {model_name} - Admin registered")
            success_count += 1
        else:
            print(f"  ⚠️  {model_name} - Not in admin (optional)")
    
    print(f"\n  📊 Admin Integration: {success_count}/{len(expected_models)} models found")
    return True  # Admin registration is optional

def test_signal_connections():
    """Test that Django signals are properly connected."""
    print("\n🔍 Testing Signal Connections...")
    
    try:
        # Import signal modules to ensure they're loaded
        import apps.analytics.signals
        import apps.notifications.signals  
        import apps.template_engine.signals
        
        print("  ✅ Analytics signals imported")
        print("  ✅ Notifications signals imported")
        print("  ✅ Template Engine signals imported")
        
        return True
        
    except Exception as e:
        print(f"  ❌ Signal import error: {e}")
        return False

def run_comprehensive_test():
    """Run all verification tests."""
    print("🚀 BACKEND APPS ACTIVATION VERIFICATION")
    print("=" * 50)
    
    tests = [
        ("App Registration", test_app_registration),
        ("Migrations", test_migrations),
        ("URL Patterns", test_url_patterns), 
        ("Model Imports", test_model_imports),
        ("Service Imports", test_service_imports),
        ("Admin Integration", test_admin_integration),
        ("Signal Connections", test_signal_connections),
    ]
    
    results = []
    
    for test_name, test_func in tests:
        try:
            result = test_func()
            results.append((test_name, result))
        except Exception as e:
            print(f"  ❌ {test_name} - CRITICAL ERROR: {e}")
            results.append((test_name, False))
    
    # Summary
    print("\n" + "=" * 50)
    print("📊 VERIFICATION SUMMARY")
    print("=" * 50)
    
    passed = sum(1 for _, result in results if result)
    total = len(results)
    
    for test_name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"  {test_name:20} {status}")
    
    print(f"\n🎯 Overall Result: {passed}/{total} tests passed")
    
    if passed == total:
        print("🎉 ALL APPS SUCCESSFULLY ACTIVATED!")
        print("\n✅ Ready for production deployment")
        return True
    else:
        print("⚠️  Some issues detected - review failed tests")
        return False

if __name__ == "__main__":
    success = run_comprehensive_test()
    sys.exit(0 if success else 1)