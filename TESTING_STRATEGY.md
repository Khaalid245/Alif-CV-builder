# Testing Strategy & Implementation Guide

## Overview
This guide provides a comprehensive testing framework to achieve **80%+ code coverage** across the EduCV project. Current coverage is near 0% - this document outlines how to systematically build a production-ready test suite.

---

## Testing Pyramid

```
        /\
       /  \        E2E Tests (5-10%)
      /____\       - User journeys
     /      \      - Production scenarios
    /        \
   /          \    Integration Tests (15-20%)
  /            \   - API endpoints
 /              \  - Database interactions
/________________\ - External services

Unit Tests (70-80%) - Fast, isolated, deterministic
```

---

## Backend Testing Setup

### 1. Install Testing Dependencies
Add to `requirements.txt`:
```txt
pytest==7.4.0
pytest-django==4.5.2
pytest-cov==4.1.0
factory-boy==3.3.0
faker==19.0.0
pytest-xdist==3.3.1  # Parallel test execution
freezegun==1.2.2      # Time mocking
```

### 2. Pytest Configuration

Create `cvbuilder-backend/pytest.ini`:
```ini
[pytest]
DJANGO_SETTINGS_MODULE = config.settings
python_files = test_*.py
python_classes = Test*
python_functions = test_*
testpaths = apps
addopts = 
    --cov=apps
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
    -v
    -n auto
```

### 3. Test Database Configuration

Update `config/settings/test.py`:
```python
# Use in-memory SQLite for tests (faster)
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': ':memory:',
    }
}

# Disable password hashing for faster tests
PASSWORD_HASHERS = [
    'django.contrib.auth.hashers.MD5PasswordHasher',
]

# Disable migrations for tests (use schema)
class DisableMigrations:
    def __contains__(self, item):
        return True
    def __getitem__(self, item):
        return None

MIGRATION_MODULES = DisableMigrations()
```

---

## Unit Test Examples

### 1. User Model Tests

Create `apps/users/tests/test_models.py`:
```python
import pytest
from django.utils import timezone
from apps.users.models import User
from apps.users.email_verification import EmailVerificationToken

@pytest.mark.django_db
class TestUserModel:
    """User model tests."""
    
    def test_create_user(self):
        """Test creating a new user."""
        user = User.objects.create_user(
            email='test@example.com',
            password='TestPass123',
            full_name='Test User',
        )
        assert user.email == 'test@example.com'
        assert user.check_password('TestPass123')
        assert user.role == 'student'
    
    def test_user_soft_delete(self):
        """Test soft delete functionality."""
        user = User.objects.create_user(
            email='test@example.com',
            password='TestPass123',
            full_name='Test User',
        )
        
        user.soft_delete()
        
        assert user.is_deleted is True
        assert user.deleted_at is not None
        assert user.is_active is False
    
    def test_email_verification_workflow(self):
        """Test email verification token generation and verification."""
        user = User.objects.create_user(
            email='test@example.com',
            password='TestPass123',
            full_name='Test User',
        )
        
        # Create verification token
        raw_token, token_obj = EmailVerificationToken.create_token(user)
        
        assert token_obj.is_valid()
        assert user.email_verified is False
        
        # Verify email
        verified_user = token_obj.verify_and_delete()
        
        assert verified_user.email_verified is True
        assert verified_user.email_verified_at is not None
        assert not EmailVerificationToken.objects.filter(user=user).exists()
    
    def test_duplicate_verification_tokens_cleanup(self):
        """Test that creating new token deletes old ones."""
        user = User.objects.create_user(
            email='test@example.com',
            password='TestPass123',
            full_name='Test User',
        )
        
        token1, _ = EmailVerificationToken.create_token(user)
        assert EmailVerificationToken.objects.count() == 1
        
        token2, _ = EmailVerificationToken.create_token(user)
        assert EmailVerificationToken.objects.count() == 1  # Old token deleted

@pytest.mark.django_db
class TestUserPermissions:
    """User permission and authorization tests."""
    
    def test_admin_user_identification(self):
        """Test admin user is correctly identified."""
        admin = User.objects.create_user(
            email='admin@example.com',
            password='AdminPass123',
            full_name='Admin User',
            role='admin',
            is_staff=True,
        )
        
        student = User.objects.create_user(
            email='student@example.com',
            password='StudentPass123',
            full_name='Student User',
            role='student',
        )
        
        assert admin.role == 'admin'
        assert admin.is_staff is True
        assert student.role == 'student'
        assert student.is_staff is False
```

### 2. Permission Tests

Create `apps/core/tests/test_permissions.py`:
```python
import pytest
from rest_framework.test import APIRequestFactory
from rest_framework.permissions import IsAuthenticated
from apps.core.permissions import IsAdminUser
from apps.users.models import User

@pytest.mark.django_db
class TestIsAdminUserPermission:
    """Test IsAdminUser permission class."""
    
    def setup_method(self):
        self.factory = APIRequestFactory()
        self.admin_user = User.objects.create_user(
            email='admin@example.com',
            password='AdminPass123',
            full_name='Admin User',
            is_staff=True,
            role='admin',
        )
        self.student_user = User.objects.create_user(
            email='student@example.com',
            password='StudentPass123',
            full_name='Student User',
        )
    
    def test_admin_user_has_permission(self):
        """Test admin user has permission."""
        request = self.factory.get('/')
        request.user = self.admin_user
        
        permission = IsAdminUser()
        assert permission.has_permission(request, None) is True
    
    def test_student_user_denied(self):
        """Test non-admin user is denied."""
        request = self.factory.get('/')
        request.user = self.student_user
        
        permission = IsAdminUser()
        assert permission.has_permission(request, None) is False
    
    def test_unauthenticated_denied(self):
        """Test unauthenticated user is denied."""
        request = self.factory.get('/')
        request.user = None
        
        permission = IsAdminUser()
        assert permission.has_permission(request, None) is False
```

### 3. Serializer Tests

Create `apps/users/tests/test_serializers.py`:
```python
import pytest
from apps.users.serializers.email_verification import UserRegistrationSerializer

@pytest.mark.django_db
class TestUserRegistrationSerializer:
    """Test user registration serializer."""
    
    def test_valid_registration(self):
        """Test valid user registration."""
        data = {
            'email': 'newuser@example.com',
            'password': 'StrongPass123',
            'password_confirm': 'StrongPass123',
            'full_name': 'New User',
            'terms_consent': True,
            'data_processing_consent': True,
            'marketing_consent': False,
        }
        
        serializer = UserRegistrationSerializer(data=data)
        assert serializer.is_valid()
        
        user = serializer.save()
        assert user.email == 'newuser@example.com'
        assert user.email_verified is False
        assert user.full_name == 'New User'
    
    def test_weak_password_rejected(self):
        """Test weak password is rejected."""
        data = {
            'email': 'user@example.com',
            'password': 'weak',  # No numbers/symbols/uppercase
            'password_confirm': 'weak',
            'full_name': 'User',
            'terms_consent': True,
            'data_processing_consent': True,
        }
        
        serializer = UserRegistrationSerializer(data=data)
        assert not serializer.is_valid()
        assert 'password' in serializer.errors
    
    def test_password_mismatch_rejected(self):
        """Test mismatched passwords are rejected."""
        data = {
            'email': 'user@example.com',
            'password': 'StrongPass123',
            'password_confirm': 'DifferentPass123',
            'full_name': 'User',
            'terms_consent': True,
            'data_processing_consent': True,
        }
        
        serializer = UserRegistrationSerializer(data=data)
        assert not serializer.is_valid()
        assert 'password' in serializer.errors
```

---

## API Integration Tests

### 1. Authentication Endpoints

Create `apps/users/tests/test_auth_views.py`:
```python
import pytest
from rest_framework.test import APIClient
from rest_framework import status
from apps.users.models import User

@pytest.mark.django_db
class TestAuthenticationViews:
    """Test authentication API endpoints."""
    
    def setup_method(self):
        self.client = APIClient()
        self.user = User.objects.create_user(
            email='test@example.com',
            password='TestPass123',
            full_name='Test User',
            email_verified=True,
        )
    
    def test_login_success(self):
        """Test successful login."""
        response = self.client.post('/api/v1/auth/login/', {
            'email': 'test@example.com',
            'password': 'TestPass123',
        })
        
        assert response.status_code == status.HTTP_200_OK
        assert 'access' in response.data
        assert 'refresh' in response.data
    
    def test_login_invalid_credentials(self):
        """Test login with invalid credentials."""
        response = self.client.post('/api/v1/auth/login/', {
            'email': 'test@example.com',
            'password': 'WrongPassword',
        })
        
        assert response.status_code == status.HTTP_401_UNAUTHORIZED
    
    def test_register_new_user(self):
        """Test user registration."""
        response = self.client.post('/api/v1/auth/register/', {
            'email': 'newuser@example.com',
            'password': 'NewPass123',
            'password_confirm': 'NewPass123',
            'full_name': 'New User',
            'terms_consent': True,
            'data_processing_consent': True,
        })
        
        assert response.status_code == status.HTTP_201_CREATED
        assert User.objects.filter(email='newuser@example.com').exists()
```

---

## Frontend Testing (Flutter)

### 1. Widget Tests

Create `educv/test/api_client_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:educv/core/constants/api_constants.dart';

void main() {
  group('ApiConstants', () {
    test('baseUrl returns configured URL', () {
      // Set environment (mocked)
      final url = ApiConstants.baseUrl;
      expect(url, contains('/api/v1'));
      expect(url.isEmpty, false);
    });

    test('baseUrl throws exception if not configured', () {
      // Test error handling
      expect(
        () => ApiConstants.baseUrl,
        throwsA(isA<Exception>()),
      );
    });
  });
}
```

---

## Running Tests

```bash
# Run all tests with coverage
pytest --cov=apps --cov-report=html

# Run specific test file
pytest apps/users/tests/test_models.py

# Run tests matching pattern
pytest -k "test_email_verification"

# Run tests in parallel
pytest -n auto

# Run with detailed output
pytest -vv

# Generate coverage report
coverage run -m pytest
coverage report
coverage html  # Opens htmlcov/index.html
```

---

## Test Coverage Goals

```
Phase 1 (Week 1-2): 30% coverage
- Core models
- Core permissions
- Serializers

Phase 2 (Week 3-4): 60% coverage
- All API endpoints
- Error handling
- Edge cases

Phase 3 (Week 5-6): 80%+ coverage
- Integration tests
- Performance tests
- Security tests
```

---

## CI/CD Integration

Create `.github/workflows/tests.yml`:
```yaml
name: Run Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    services:
      mysql:
        image: mysql:8.0
        env:
          MYSQL_DATABASE: test_educv
          MYSQL_USER: educv_user
          MYSQL_PASSWORD: test_password
          MYSQL_ROOT_PASSWORD: root
        options: >-
          --health-cmd="mysqladmin ping"
          --health-interval=10s
          --health-timeout=5s
          --health-retries=3
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: '3.11'
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
    
    - name: Run tests with coverage
      run: |
        pytest --cov=apps --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        files: ./coverage.xml
```

---

## Next Steps

1. **Week 1**: Install testing framework, write unit tests (30% coverage)
2. **Week 2**: Write integration tests (60% coverage)
3. **Week 3**: Add E2E tests, performance tests (80%+ coverage)
4. **Week 4**: Integrate with CI/CD pipeline

---

**Target:** 80%+ code coverage before production deployment
