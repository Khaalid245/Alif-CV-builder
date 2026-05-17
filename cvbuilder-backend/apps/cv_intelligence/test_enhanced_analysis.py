"""
Tests for Enhanced CV Intelligence System.
"""
from datetime import date, timedelta
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status

from apps.cv.models import CVProfile, Education, Experience, Skill, Project
from apps.cv_intelligence.models import CVAnalysis
from apps.cv_intelligence.validators import CVValidator

User = get_user_model()


class EnhancedCVValidatorTest(TestCase):
    """Test the enhanced CV validator with detailed section scoring."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@university.edu',
            password='testpass123',
            full_name='Test Student',
            student_id='STU001'
        )
        self.cv = CVProfile.objects.create(student=self.user)
        self.validator = CVValidator()
    
    def test_empty_cv_analysis(self):
        """Test analysis of completely empty CV."""
        results = self.validator.validate_cv_profile(self.cv)
        
        self.assertEqual(results['score_breakdown']['profile'], 0)
        self.assertEqual(results['score_breakdown']['education'], 0)
        self.assertEqual(results['score_breakdown']['experience'], 0)
        self.assertEqual(results['score_breakdown']['skills'], 0)
        self.assertEqual(results['score_breakdown']['projects'], 0)
        self.assertEqual(results['overall_score'], 0)
        self.assertFalse(results['is_submission_ready'])
        self.assertIn('recommendations', results)
    
    def test_profile_section_scoring(self):
        """Test detailed profile section scoring."""
        # Empty profile
        results = self.validator.validate_cv_profile(self.cv)
        self.assertEqual(results['score_breakdown']['profile'], 0)
        
        # Add contact info
        self.cv.phone = '+1234567890'
        self.cv.city = 'Test City'
        self.cv.country = 'Test Country'
        self.cv.address = '123 Test St'
        
        # Add summary
        self.cv.summary = 'Experienced software developer with 5+ years of experience in full-stack development. Proven track record of delivering high-quality applications using modern technologies and agile methodologies.'
        
        # Add online presence
        self.cv.linkedin = 'https://linkedin.com/in/test'
        self.cv.github = 'https://github.com/test'
        self.cv.save()
        
        results = self.validator.validate_cv_profile(self.cv)
        profile_score = results['score_breakdown']['profile']
        
        # Should have high score with complete profile
        self.assertGreaterEqual(profile_score, 80)
    
    def test_experience_section_scoring(self):
        """Test experience section scoring algorithm."""
        # No experience
        results = self.validator.validate_cv_profile(self.cv)
        self.assertEqual(results['score_breakdown']['experience'], 0)
        
        # Add detailed experience
        Experience.objects.create(
            cv=self.cv,
            job_title='Senior Software Developer',
            company='Tech Company Inc.',
            location='San Francisco, CA',
            start_date=date.today() - timedelta(days=730),  # 2 years ago
            end_date=date.today() - timedelta(days=365),    # 1 year ago
            description='''
            • Developed and maintained 5+ web applications using React, Node.js, and PostgreSQL
            • Led a team of 3 junior developers and improved code quality by 40%
            • Implemented CI/CD pipelines that reduced deployment time by 60%
            • Collaborated with product managers to deliver features on time and within budget
            '''
        )
        
        results = self.validator.validate_cv_profile(self.cv)
        experience_score = results['score_breakdown']['experience']
        
        # Should have good score with detailed experience
        self.assertGreaterEqual(experience_score, 60)
    
    def test_education_section_scoring(self):
        """Test education section scoring."""
        # Add comprehensive education
        Education.objects.create(
            cv=self.cv,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='University of Technology',
            start_year=2018,
            end_year=2022,
            gpa=Decimal('3.8'),
            description='Relevant coursework: Data Structures, Algorithms, Software Engineering, Database Systems'
        )
        
        results = self.validator.validate_cv_profile(self.cv)
        education_score = results['score_breakdown']['education']
        
        # Should have good score with complete education
        self.assertGreaterEqual(education_score, 70)
    
    def test_skills_section_scoring(self):
        """Test skills section scoring with diversity."""
        # Add diverse skills
        skills_data = [
            ('Python', 'advanced', 'technical'),
            ('JavaScript', 'advanced', 'technical'),
            ('React', 'intermediate', 'technical'),
            ('Node.js', 'intermediate', 'technical'),
            ('PostgreSQL', 'intermediate', 'technical'),
            ('Communication', 'expert', 'soft'),
            ('Leadership', 'advanced', 'soft'),
            ('Problem Solving', 'expert', 'soft'),
        ]
        
        for name, level, category in skills_data:
            Skill.objects.create(
                cv=self.cv,
                name=name,
                level=level,
                category=category
            )
        
        results = self.validator.validate_cv_profile(self.cv)
        skills_score = results['score_breakdown']['skills']
        
        # Should have high score with diverse, advanced skills
        self.assertGreaterEqual(skills_score, 80)
    
    def test_projects_section_scoring(self):
        """Test projects section scoring."""
        # Add detailed projects
        projects_data = [
            {
                'title': 'E-commerce Platform',
                'description': '''
                Built a full-stack e-commerce platform using React, Node.js, and MongoDB.
                Implemented user authentication, payment processing, and inventory management.
                Deployed on AWS with Docker containers and achieved 99.9% uptime.
                Served 1000+ daily active users with average response time under 200ms.
                ''',
                'link': 'https://github.com/test/ecommerce'
            },
            {
                'title': 'Task Management API',
                'description': '''
                Developed RESTful API for task management using Django and PostgreSQL.
                Implemented JWT authentication, role-based permissions, and real-time notifications.
                Achieved 95% test coverage and documented all endpoints with Swagger.
                ''',
                'link': 'https://github.com/test/task-api'
            },
            {
                'title': 'Data Visualization Dashboard',
                'description': '''
                Created interactive dashboard using D3.js and Python Flask.
                Processed and visualized large datasets (100k+ records) with real-time updates.
                Implemented caching strategies that improved load times by 70%.
                ''',
                'link': 'https://github.com/test/dashboard'
            }
        ]
        
        for project_data in projects_data:
            Project.objects.create(
                cv=self.cv,
                title=project_data['title'],
                description=project_data['description'],
                link=project_data['link']
            )
        
        results = self.validator.validate_cv_profile(self.cv)
        projects_score = results['score_breakdown']['projects']
        
        # Should have high score with detailed, linked projects
        self.assertGreaterEqual(projects_score, 85)
    
    def test_submission_readiness_logic(self):
        """Test submission readiness determination."""
        # Create a well-rounded CV
        self._create_complete_cv()
        
        results = self.validator.validate_cv_profile(self.cv)
        
        # Should be submission ready with complete CV
        self.assertTrue(results['is_submission_ready'])
        self.assertGreaterEqual(results['overall_score'], 70)
    
    def test_recommendations_categorization(self):
        """Test that recommendations are properly categorized."""
        # Partially complete CV to generate various recommendation types
        self.cv.phone = '+1234567890'
        self.cv.summary = 'Short summary'  # Too short
        self.cv.save()
        
        # Add minimal experience with weak language
        Experience.objects.create(
            cv=self.cv,
            job_title='Developer',
            company='Company',
            start_date=date.today() - timedelta(days=365),
            description='Responsible for coding'  # Weak language
        )
        
        results = self.validator.validate_cv_profile(self.cv)
        recommendations = results['recommendations']
        
        # Should have all recommendation categories
        self.assertIn('critical', recommendations)
        self.assertIn('important', recommendations)
        self.assertIn('suggestions', recommendations)
        self.assertIn('strengths', recommendations)
        
        # Should have some recommendations
        total_recommendations = (
            len(recommendations['critical']) +
            len(recommendations['important']) +
            len(recommendations['suggestions'])
        )
        self.assertGreater(total_recommendations, 0)
    
    def _create_complete_cv(self):
        """Helper method to create a complete, high-quality CV."""
        # Complete profile
        self.cv.phone = '+1234567890'
        self.cv.city = 'San Francisco'
        self.cv.country = 'United States'
        self.cv.address = '123 Tech Street'
        self.cv.summary = '''
        Experienced full-stack software developer with 5+ years of expertise in modern web technologies.
        Proven track record of leading development teams and delivering scalable applications that serve
        thousands of users. Passionate about clean code, agile methodologies, and continuous learning.
        '''
        self.cv.linkedin = 'https://linkedin.com/in/test'
        self.cv.github = 'https://github.com/test'
        self.cv.save()
        
        # Education
        Education.objects.create(
            cv=self.cv,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='Stanford University',
            start_year=2016,
            end_year=2020,
            gpa=Decimal('3.9'),
            description='Summa Cum Laude. Relevant coursework: Advanced Algorithms, Machine Learning, Software Engineering'
        )
        
        # Experience
        Experience.objects.create(
            cv=self.cv,
            job_title='Senior Software Engineer',
            company='Google',
            start_date=date.today() - timedelta(days=1095),  # 3 years
            end_date=date.today() - timedelta(days=365),     # 1 year ago
            description='''
            • Architected and developed microservices handling 10M+ requests daily
            • Led cross-functional team of 8 engineers to deliver critical features ahead of schedule
            • Improved system performance by 45% through optimization and caching strategies
            • Mentored 5 junior developers and established coding standards adopted company-wide
            '''
        )
        
        # Skills
        skills = [
            ('Python', 'expert', 'technical'),
            ('JavaScript', 'expert', 'technical'),
            ('React', 'advanced', 'technical'),
            ('Node.js', 'advanced', 'technical'),
            ('AWS', 'advanced', 'technical'),
            ('Leadership', 'expert', 'soft'),
            ('Communication', 'advanced', 'soft'),
        ]
        
        for name, level, category in skills:
            Skill.objects.create(cv=self.cv, name=name, level=level, category=category)
        
        # Projects
        Project.objects.create(
            cv=self.cv,
            title='Open Source ML Library',
            description='''
            Created and maintain popular machine learning library with 5000+ GitHub stars.
            Implemented advanced algorithms for natural language processing and computer vision.
            Comprehensive documentation and 95% test coverage. Used by 100+ companies worldwide.
            ''',
            link='https://github.com/test/ml-library'
        )


class EnhancedCVAnalysisAPITest(APITestCase):
    """Test the enhanced CV analysis API endpoints."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@university.edu',
            password='testpass123',
            full_name='Test Student',
            student_id='STU001'
        )
        self.client.force_authenticate(user=self.user)
        self.cv = CVProfile.objects.create(student=self.user)
    
    def test_get_analysis_creates_if_missing(self):
        """Test GET /api/v1/cv/analyze/ creates analysis if none exists."""
        response = self.client.get('/api/v1/cv/analyze/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('data', response.data)
        
        # Check that analysis was created
        self.assertTrue(CVAnalysis.objects.filter(user=self.user).exists())
    
    def test_post_analysis_forces_refresh(self):
        """Test POST /api/v1/cv/analyze/ forces new analysis."""
        # Create existing analysis
        old_analysis = CVAnalysis.objects.create(
            user=self.user,
            overall_score=50,
            analysis_data={'old': 'data'}
        )
        
        response = self.client.post('/api/v1/cv/analyze/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        
        # Check that analysis was updated
        updated_analysis = CVAnalysis.objects.get(user=self.user)
        self.assertEqual(updated_analysis.id, old_analysis.id)  # Same object
        self.assertNotEqual(updated_analysis.analysis_data, {'old': 'data'})
    
    def test_enhanced_score_endpoint(self):
        """Test enhanced /api/v1/cv/score/ endpoint with detailed breakdown."""
        # Create analysis first
        self.client.post('/api/v1/cv/analyze/')
        
        response = self.client.get('/api/v1/cv/score/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        
        # Check enhanced response structure
        self.assertIn('score_breakdown', data)
        self.assertIn('is_submission_ready', data)
        self.assertIn('recommendations', data)
        self.assertIn('summary', data)
        
        # Check score breakdown has all sections
        breakdown = data['score_breakdown']
        required_sections = ['profile', 'experience', 'education', 'skills', 'projects']
        for section in required_sections:
            self.assertIn(section, breakdown)
            self.assertGreaterEqual(breakdown[section], 0)
            self.assertLessEqual(breakdown[section], 100)
    
    def test_analysis_with_complete_cv(self):
        """Test analysis with a comprehensive CV."""
        self._create_comprehensive_cv()
        
        response = self.client.post('/api/v1/cv/analyze/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        
        # Should have good overall score
        self.assertGreaterEqual(data['overall_score'], 70)
        
        # Should be submission ready
        self.assertTrue(data['is_submission_ready'])
        
        # Should have minimal critical issues
        self.assertLessEqual(data['critical_issues'], 2)
    
    def test_unauthorized_access(self):
        """Test that unauthenticated users cannot access analysis."""
        self.client.force_authenticate(user=None)
        
        response = self.client.get('/api/v1/cv/analyze/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        
        response = self.client.post('/api/v1/cv/analyze/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def _create_comprehensive_cv(self):
        """Helper to create a comprehensive CV for testing."""
        # Profile
        self.cv.phone = '+1234567890'
        self.cv.city = 'San Francisco'
        self.cv.country = 'United States'
        self.cv.summary = 'Experienced software developer with proven track record of delivering high-quality applications using modern technologies and best practices.'
        self.cv.linkedin = 'https://linkedin.com/in/test'
        self.cv.github = 'https://github.com/test'
        self.cv.save()
        
        # Education
        Education.objects.create(
            cv=self.cv,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='University of Technology',
            start_year=2018,
            end_year=2022,
            gpa=Decimal('3.8')
        )
        
        # Experience
        Experience.objects.create(
            cv=self.cv,
            job_title='Software Developer',
            company='Tech Company',
            start_date=date.today() - timedelta(days=730),
            end_date=date.today() - timedelta(days=365),
            description='Developed web applications using React and Node.js. Improved system performance by 30% through optimization.'
        )
        
        # Skills
        for skill_name in ['Python', 'JavaScript', 'React', 'Node.js', 'Communication']:
            Skill.objects.create(
                cv=self.cv,
                name=skill_name,
                level='advanced',
                category='technical' if skill_name != 'Communication' else 'soft'
            )
        
        # Projects
        Project.objects.create(
            cv=self.cv,
            title='Web Application',
            description='Built full-stack web application with user authentication and real-time features. Deployed on AWS with Docker.',
            link='https://github.com/test/webapp'
        )