"""
Secure test fixtures for CV Intelligence tests.
Provides reusable test data without hardcoded credentials.
"""
import os
from django.conf import settings
from django.contrib.auth import get_user_model

User = get_user_model()


class SecureTestFixtures:
    """Provides secure test data for CV Intelligence tests."""
    
    @staticmethod
    def get_test_credentials():
        """Get test credentials from environment or use secure defaults."""
        return {
            'email': os.getenv('TEST_USER_EMAIL', 'test@university.edu'),
            'password': os.getenv('TEST_USER_PASSWORD', 'SecureTestPass123!'),
            'full_name': 'Test Student',
            'student_id': 'STU001'
        }
    
    @staticmethod
    def create_test_user():
        """Create a test user with secure credentials."""
        credentials = SecureTestFixtures.get_test_credentials()
        return User.objects.create_user(**credentials)
    
    @staticmethod
    def get_api_test_credentials():
        """Get API test credentials for authentication tests."""
        return {
            'email': os.getenv('API_TEST_EMAIL', 'api.test@university.edu'),
            'password': os.getenv('API_TEST_PASSWORD', 'ApiTestPass456!'),
            'full_name': 'API Test User',
            'student_id': 'API001'
        }
    
    @staticmethod
    def create_api_test_user():
        """Create an API test user with secure credentials."""
        credentials = SecureTestFixtures.get_api_test_credentials()
        return User.objects.create_user(**credentials)
    
    @staticmethod
    def get_sample_cv_data():
        """Get sample CV data for testing."""
        return {
            'profile': {
                'phone': '+1234567890',
                'city': 'Test City',
                'country': 'Test Country',
                'address': '123 Test Street',
                'summary': 'Experienced software developer with proven track record.',
                'linkedin': 'https://linkedin.com/in/testuser',
                'github': 'https://github.com/testuser'
            },
            'education': {
                'degree': 'Bachelor of Science',
                'field_of_study': 'Computer Science',
                'institution': 'Test University',
                'start_year': 2018,
                'end_year': 2022,
                'gpa': '3.8'
            },
            'experience': {
                'job_title': 'Software Developer',
                'company': 'Test Company Inc.',
                'location': 'Test City, TC',
                'description': 'Developed web applications using modern technologies.'
            },
            'skills': [
                {'name': 'Python', 'level': 'advanced', 'category': 'technical'},
                {'name': 'JavaScript', 'level': 'advanced', 'category': 'technical'},
                {'name': 'Communication', 'level': 'expert', 'category': 'soft'}
            ],
            'projects': {
                'title': 'Test Web Application',
                'description': 'Built full-stack application with modern frameworks.',
                'link': 'https://github.com/testuser/webapp'
            }
        }