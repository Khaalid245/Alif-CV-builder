"""
Tests for CV Analysis Engine.
"""
from datetime import date, timedelta
from decimal import Decimal
from django.test import TestCase
from django.contrib.auth import get_user_model
from rest_framework.test import APITestCase
from rest_framework import status
from apps.cv.models import CVProfile, Education, Experience, Skill, Project, CVAnalysis
from apps.cv.services import CVAnalysisService

User = get_user_model()


class CVAnalysisServiceTest(TestCase):
    """Test the core analysis service logic."""
    
    def setUp(self):
        self.user = User.objects.create_user(
            email='test@university.edu',
            password='testpass123',
            full_name='Test Student',
            student_id='STU001'
        )
        self.cv = CVProfile.objects.create(student=self.user)
        self.service = CVAnalysisService(self.cv)
    
    def test_empty_cv_analysis(self):
        """Test analysis of completely empty CV."""
        analysis = self.service.analyze()
        
        self.assertEqual(analysis.profile_score, 0)
        self.assertEqual(analysis.education_score, 0)
        self.assertEqual(analysis.experience_score, 0)
        self.assertEqual(analysis.skills_score, 0)
        self.assertEqual(analysis.projects_score, 0)
        self.assertEqual(analysis.overall_score, 0)
        self.assertFalse(analysis.is_submission_ready)
        self.assertIn('critical', analysis.recommendations)
    
    def test_profile_scoring(self):
        """Test profile section scoring algorithm."""
        # Empty profile
        self.assertEqual(self.service._analyze_profile(), 0)
        
        # Add contact info (40 points)
        self.cv.phone = '+1234567890'
        self.cv.city = 'Test City'
        self.cv.country = 'Test Country'
        self.cv.address = '123 Test St'
        self.assertEqual(self.service._analyze_profile(), 40)
        
        # Add summary (30 points for 100+ chars)
        self.cv.summary = 'A' * 100
        self.assertEqual(self.service._analyze_profile(), 70)
        
        # Add online presence (20 points)
        self.cv.linkedin = 'https://linkedin.com/in/test'
        self.cv.github = 'https://github.com/test'
        self.assertEqual(self.service._analyze_profile(), 90)
        
        # Add photo (10 points)
        # Note: In real test, you'd mock the ImageField
        # For now, we'll test the logic path
    
    def test_education_scoring(self):
        """Test education section scoring algorithm."""
        # No education
        self.assertEqual(self.service._analyze_education(), 0)
        
        # Add basic education (40 points)
        Education.objects.create(
            cv=self.cv,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='Test University',
            start_year=2020,
            end_year=2024
        )
        self.service._load_sections()  # Reload counts
        self.assertEqual(self.service._analyze_education(), 40)
        
        # Add second education (20 points bonus)
        Education.objects.create(
            cv=self.cv,
            degree='High School Diploma',
            field_of_study='General Studies',
            institution='Test High School',
            start_year=2016,
            end_year=2020
        )
        self.service._load_sections()
        score = self.service._analyze_education()
        self.assertGreaterEqual(score, 60)  # 40 + 20
    
    def test_experience_scoring(self):
        """Test experience section scoring algorithm."""
        # No experience
        self.assertEqual(self.service._analyze_experience(), 0)
        
        # Add basic experience (30 points)
        Experience.objects.create(
            cv=self.cv,
            job_title='Software Intern',
            company='Test Company',
            start_date=date.today() - timedelta(days=365),
            end_date=date.today() - timedelta(days=180),
            description='A' * 100  # Detailed description
        )
        self.service._load_sections()
        score = self.service._analyze_experience()
        self.assertGreaterEqual(score, 30)
    
    def test_skills_scoring(self):
        """Test skills section scoring algorithm."""
        # No skills
        self.assertEqual(self.service._analyze_skills(), 0)
        
        # Add basic skills
        skills_data = [
            ('Python', 'advanced', 'technical'),
            ('JavaScript', 'intermediate', 'technical'),
            ('Communication', 'expert', 'soft'),
            ('Leadership', 'advanced', 'soft'),
        ]
        
        for name, level, category in skills_data:
            Skill.objects.create(
                cv=self.cv,
                name=name,
                level=level,
                category=category
            )
        
        self.service._load_sections()
        score = self.service._analyze_skills()
        self.assertGreaterEqual(score, 30)  # Basic presence
    
    def test_projects_scoring(self):
        """Test projects section scoring algorithm."""
        # No projects
        self.assertEqual(self.service._analyze_projects(), 0)
        
        # Add basic project (40 points)
        Project.objects.create(
            cv=self.cv,
            title='Test Project',
            description='A' * 100,  # Detailed description
            link='https://github.com/test/project'
        )
        self.service._load_sections()
        score = self.service._analyze_projects()
        self.assertGreaterEqual(score, 40)
    
    def test_overall_scoring_calculation(self):
        """Test overall score calculation with weights."""
        # Mock section scores
        self.service._analyze_profile = lambda: 80
        self.service._analyze_education = lambda: 70
        self.service._analyze_experience = lambda: 90
        self.service._analyze_skills = lambda: 85
        self.service._analyze_projects = lambda: 75
        
        analysis = self.service.analyze()
        
        # Calculate expected score: 80*0.25 + 70*0.20 + 90*0.25 + 85*0.15 + 75*0.15
        expected = int(80*0.25 + 70*0.20 + 90*0.25 + 85*0.15 + 75*0.15)
        self.assertEqual(analysis.overall_score, expected)
    
    def test_submission_readiness(self):
        """Test submission readiness logic."""
        # Mock high scores
        self.service._analyze_profile = lambda: 80
        self.service._analyze_education = lambda: 75
        self.service._analyze_experience = lambda: 85
        self.service._analyze_skills = lambda: 70
        self.service._analyze_projects = lambda: 80
        
        analysis = self.service.analyze()
        self.assertTrue(analysis.is_submission_ready)
        
        # Mock low overall score
        self.service._analyze_profile = lambda: 50
        analysis = self.service.analyze()
        self.assertFalse(analysis.is_submission_ready)
    
    def test_recommendations_generation(self):
        """Test recommendation generation logic."""
        scores = {
            'profile': 30,      # Critical
            'education': 60,    # Important
            'experience': 80,   # Suggestion
            'skills': 95,       # Strength
            'projects': 40,     # Important
            'overall': 65
        }
        
        recommendations = self.service._generate_recommendations(scores)
        
        self.assertIn('critical', recommendations)
        self.assertIn('important', recommendations)
        self.assertIn('suggestions', recommendations)
        self.assertIn('strengths', recommendations)
        
        # Check that we have recommendations for each category
        self.assertTrue(len(recommendations['critical']) > 0)
        self.assertTrue(len(recommendations['important']) > 0)
        self.assertTrue(len(recommendations['suggestions']) > 0)
        self.assertTrue(len(recommendations['strengths']) > 0)


class CVAnalysisAPITest(APITestCase):
    """Test the analysis API endpoints."""
    
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
        """Test GET /api/v1/cv/analysis/ creates analysis if none exists."""
        response = self.client.get('/api/v1/cv/analysis/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        self.assertIn('data', response.data)
        
        # Check that analysis was created
        self.assertTrue(CVAnalysis.objects.filter(cv=self.cv).exists())
    
    def test_get_existing_analysis(self):
        """Test GET returns existing analysis without recreating."""
        # Create analysis manually
        analysis = CVAnalysis.objects.create(
            cv=self.cv,
            profile_score=50,
            education_score=60,
            experience_score=70,
            skills_score=80,
            projects_score=90,
            overall_score=65,
            is_submission_ready=False,
            recommendations={'test': 'data'}
        )
        
        response = self.client.get('/api/v1/cv/analysis/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertEqual(response.data['data']['overall_score'], 65)
        self.assertEqual(response.data['data']['id'], str(analysis.id))
    
    def test_post_analysis_forces_refresh(self):
        """Test POST /api/v1/cv/analysis/ forces new analysis."""
        # Create existing analysis
        old_analysis = CVAnalysis.objects.create(
            cv=self.cv,
            overall_score=50,
            recommendations={'old': 'data'}
        )
        
        response = self.client.post('/api/v1/cv/analysis/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        self.assertTrue(response.data['success'])
        
        # Check that analysis was updated
        updated_analysis = CVAnalysis.objects.get(cv=self.cv)
        self.assertEqual(updated_analysis.id, old_analysis.id)  # Same object
        self.assertNotEqual(updated_analysis.recommendations, {'old': 'data'})
    
    def test_analysis_with_complete_cv(self):
        """Test analysis with a well-filled CV."""
        # Fill CV with good data
        self.cv.phone = '+1234567890'
        self.cv.city = 'Test City'
        self.cv.country = 'Test Country'
        self.cv.summary = 'A comprehensive professional summary that exceeds the minimum character requirement for good scoring.'
        self.cv.linkedin = 'https://linkedin.com/in/test'
        self.cv.save()
        
        # Add education
        Education.objects.create(
            cv=self.cv,
            degree='Bachelor of Science',
            field_of_study='Computer Science',
            institution='Test University',
            start_year=2020,
            end_year=2024,
            gpa=Decimal('3.8'),
            description='Relevant coursework and achievements in computer science.'
        )
        
        # Add experience
        Experience.objects.create(
            cv=self.cv,
            job_title='Software Developer Intern',
            company='Tech Company',
            start_date=date.today() - timedelta(days=365),
            end_date=date.today() - timedelta(days=90),
            description='Developed web applications using modern frameworks and contributed to team projects with measurable impact.'
        )
        
        # Add skills
        for skill_name in ['Python', 'JavaScript', 'React', 'Django', 'Communication', 'Problem Solving']:
            Skill.objects.create(
                cv=self.cv,
                name=skill_name,
                level='advanced' if skill_name in ['Python', 'Communication'] else 'intermediate',
                category='technical' if skill_name not in ['Communication', 'Problem Solving'] else 'soft'
            )
        
        # Add projects
        for i in range(3):
            Project.objects.create(
                cv=self.cv,
                title=f'Project {i+1}',
                description='A detailed project description that showcases technical skills and problem-solving abilities with clear outcomes.',
                link=f'https://github.com/test/project{i+1}'
            )
        
        response = self.client.post('/api/v1/cv/analysis/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        
        # Should have decent scores
        self.assertGreater(data['overall_score'], 70)
        self.assertGreater(data['profile_score'], 60)
        self.assertGreater(data['education_score'], 40)
        self.assertGreater(data['experience_score'], 30)
        self.assertGreater(data['skills_score'], 50)
        self.assertGreater(data['projects_score'], 60)
    
    def test_unauthorized_access(self):
        """Test that unauthenticated users cannot access analysis."""
        self.client.force_authenticate(user=None)
        
        response = self.client.get('/api/v1/cv/analysis/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
        
        response = self.client.post('/api/v1/cv/analysis/')
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)
    
    def test_analysis_response_structure(self):
        """Test that analysis response has correct structure."""
        response = self.client.get('/api/v1/cv/analysis/')
        
        self.assertEqual(response.status_code, status.HTTP_200_OK)
        data = response.data['data']
        
        # Check required fields
        required_fields = [
            'id', 'profile_score', 'education_score', 'experience_score',
            'skills_score', 'projects_score', 'overall_score',
            'is_submission_ready', 'recommendations', 'analyzed_at'
        ]
        
        for field in required_fields:
            self.assertIn(field, data)
        
        # Check score ranges
        score_fields = [
            'profile_score', 'education_score', 'experience_score',
            'skills_score', 'projects_score', 'overall_score'
        ]
        
        for field in score_fields:
            self.assertGreaterEqual(data[field], 0)
            self.assertLessEqual(data[field], 100)
        
        # Check recommendations structure
        self.assertIsInstance(data['recommendations'], dict)
        self.assertIn('critical', data['recommendations'])
        self.assertIn('important', data['recommendations'])
        self.assertIn('suggestions', data['recommendations'])
        self.assertIn('strengths', data['recommendations'])