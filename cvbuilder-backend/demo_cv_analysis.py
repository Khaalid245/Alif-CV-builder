#!/usr/bin/env python
"""
CV Intelligence System Demonstration Script

This script demonstrates the enhanced CV analysis system by creating
sample CV data and running analysis to show scoring and recommendations.

Usage:
    python manage.py shell < demo_cv_analysis.py
"""

from datetime import date, timedelta
from decimal import Decimal
from django.contrib.auth import get_user_model
from apps.cv.models import CVProfile, Education, Experience, Skill, Project
from apps.cv_intelligence.validators import CVValidator
from apps.cv_intelligence.models import CVAnalysis

User = get_user_model()

def create_sample_user():
    """Create a sample user for demonstration."""
    user, created = User.objects.get_or_create(
        email='demo@university.edu',
        defaults={
            'full_name': 'Demo Student',
            'student_id': 'DEMO001',
            'password': 'demo123'
        }
    )
    return user

def create_empty_cv(user):
    """Create an empty CV profile."""
    cv, created = CVProfile.objects.get_or_create(student=user)
    # Clear existing data
    cv.educations.all().delete()
    cv.experiences.all().delete()
    cv.skills.all().delete()
    cv.projects.all().delete()
    
    cv.phone = ''
    cv.city = ''
    cv.country = ''
    cv.summary = ''
    cv.linkedin = ''
    cv.github = ''
    cv.save()
    
    return cv

def create_basic_cv(user):
    """Create a basic CV with minimal information."""
    cv = create_empty_cv(user)
    
    # Basic contact info
    cv.phone = '+1234567890'
    cv.city = 'San Francisco'
    cv.summary = 'Software developer'  # Very short
    cv.save()
    
    # Basic education
    Education.objects.create(
        cv=cv,
        degree='Bachelor',
        field_of_study='Computer Science',
        institution='University',
        start_year=2020,
        end_year=2024
    )
    
    # Basic experience with weak language
    Experience.objects.create(
        cv=cv,
        job_title='Developer',
        company='Company',
        start_date=date.today() - timedelta(days=365),
        description='Responsible for coding'  # Weak language
    )
    
    # Few skills
    Skill.objects.create(cv=cv, name='Python', level='beginner', category='technical')
    Skill.objects.create(cv=cv, name='JavaScript', level='beginner', category='technical')
    
    return cv

def create_excellent_cv(user):
    """Create an excellent CV with comprehensive information."""
    cv = create_empty_cv(user)
    
    # Complete profile
    cv.phone = '+1234567890'
    cv.city = 'San Francisco'
    cv.country = 'United States'
    cv.address = '123 Tech Street'
    cv.summary = '''
    Experienced full-stack software developer with 5+ years of expertise in modern web technologies.
    Proven track record of leading development teams and delivering scalable applications that serve
    thousands of users daily. Passionate about clean code, agile methodologies, and continuous learning.
    '''
    cv.linkedin = 'https://linkedin.com/in/demo'
    cv.github = 'https://github.com/demo'
    cv.save()
    
    # Excellent education
    Education.objects.create(
        cv=cv,
        degree='Bachelor of Science',
        field_of_study='Computer Science',
        institution='Stanford University',
        start_year=2016,
        end_year=2020,
        gpa=Decimal('3.9'),
        description='Summa Cum Laude. Relevant coursework: Advanced Algorithms, Machine Learning, Software Engineering, Database Systems'
    )
    
    # Excellent experience
    Experience.objects.create(
        cv=cv,
        job_title='Senior Software Engineer',
        company='Google',
        start_date=date.today() - timedelta(days=1095),  # 3 years
        end_date=date.today() - timedelta(days=365),     # 1 year ago
        description='''
        • Architected and developed microservices handling 10M+ requests daily using Python and Go
        • Led cross-functional team of 8 engineers to deliver critical features 2 weeks ahead of schedule
        • Improved system performance by 45% through optimization and intelligent caching strategies
        • Mentored 5 junior developers and established coding standards adopted company-wide
        • Reduced deployment time by 60% by implementing comprehensive CI/CD pipelines
        '''
    )
    
    Experience.objects.create(
        cv=cv,
        job_title='Software Engineer',
        company='Facebook',
        start_date=date.today() - timedelta(days=1460),  # 4 years ago
        end_date=date.today() - timedelta(days=1095),    # 3 years ago
        description='''
        • Developed React-based user interfaces serving 100M+ monthly active users
        • Implemented real-time messaging features using WebSocket and Redis
        • Collaborated with product managers to define technical requirements and roadmaps
        • Achieved 99.9% uptime for critical user-facing services through robust error handling
        '''
    )
    
    # Diverse, advanced skills
    skills_data = [
        ('Python', 'expert', 'technical'),
        ('JavaScript', 'expert', 'technical'),
        ('React', 'advanced', 'technical'),
        ('Node.js', 'advanced', 'technical'),
        ('PostgreSQL', 'advanced', 'technical'),
        ('AWS', 'advanced', 'technical'),
        ('Docker', 'intermediate', 'technical'),
        ('Leadership', 'expert', 'soft'),
        ('Communication', 'advanced', 'soft'),
        ('Problem Solving', 'expert', 'soft'),
    ]
    
    for name, level, category in skills_data:
        Skill.objects.create(cv=cv, name=name, level=level, category=category)
    
    # Impressive projects
    projects_data = [
        {
            'title': 'Open Source ML Library',
            'description': '''
            Created and maintain popular machine learning library with 5000+ GitHub stars and 500+ forks.
            Implemented advanced algorithms for natural language processing and computer vision using Python and TensorFlow.
            Comprehensive documentation with 95% test coverage. Used by 100+ companies worldwide including Netflix and Uber.
            Presented at 3 major conferences and featured in TechCrunch article about innovative ML tools.
            ''',
            'link': 'https://github.com/demo/ml-library'
        },
        {
            'title': 'Real-time Analytics Platform',
            'description': '''
            Built scalable real-time analytics platform processing 1M+ events per second using Apache Kafka and Elasticsearch.
            Designed intuitive dashboard with React and D3.js for data visualization and business intelligence.
            Implemented machine learning models for anomaly detection and predictive analytics.
            Reduced data processing latency by 80% and increased system throughput by 300%.
            ''',
            'link': 'https://github.com/demo/analytics-platform'
        },
        {
            'title': 'E-commerce Microservices',
            'description': '''
            Architected and developed complete e-commerce platform using microservices architecture with Docker and Kubernetes.
            Implemented user authentication, payment processing, inventory management, and order fulfillment services.
            Achieved 99.99% uptime serving 50,000+ daily active users with average response time under 100ms.
            Integrated with multiple payment gateways and third-party logistics providers for seamless user experience.
            ''',
            'link': 'https://github.com/demo/ecommerce-microservices'
        }
    ]
    
    for project_data in projects_data:
        Project.objects.create(
            cv=cv,
            title=project_data['title'],
            description=project_data['description'],
            link=project_data['link']
        )
    
    return cv

def analyze_cv(cv, title):
    """Analyze a CV and print results."""
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")
    
    validator = CVValidator()
    results = validator.validate_cv_profile(cv)
    
    # Print overall results
    print(f"\nOVERALL RESULTS:")
    print(f"  Score: {results['overall_score']}%")
    print(f"  Grade: {results['grade']}")
    print(f"  Submission Ready: {'✅ YES' if results['is_submission_ready'] else '❌ NO'}")
    
    # Print section breakdown
    print(f"\nSECTION BREAKDOWN:")
    breakdown = results['score_breakdown']
    for section, score in breakdown.items():
        status = "✅" if score >= 70 else "⚠️" if score >= 40 else "❌"
        print(f"  {section.title():12} {score:3d}% {status}")
    
    # Print recommendations
    recommendations = results['recommendations']
    
    if recommendations['critical']:
        print(f"\n🚨 CRITICAL ISSUES ({len(recommendations['critical'])}):")
        for i, rec in enumerate(recommendations['critical'][:3], 1):
            print(f"  {i}. {rec}")
    
    if recommendations['important']:
        print(f"\n⚠️  IMPORTANT IMPROVEMENTS ({len(recommendations['important'])}):")
        for i, rec in enumerate(recommendations['important'][:3], 1):
            print(f"  {i}. {rec}")
    
    if recommendations['suggestions']:
        print(f"\n💡 SUGGESTIONS ({len(recommendations['suggestions'])}):")
        for i, rec in enumerate(recommendations['suggestions'][:2], 1):
            print(f"  {i}. {rec}")
    
    if recommendations['strengths']:
        print(f"\n🌟 STRENGTHS ({len(recommendations['strengths'])}):")
        for i, strength in enumerate(recommendations['strengths'], 1):
            print(f"  {i}. {strength}")
    
    # Save to database
    analysis, created = CVAnalysis.objects.update_or_create(
        user=cv.student,
        defaults={
            'overall_score': results['overall_score'],
            'profile_score': breakdown['profile'],
            'experience_score': breakdown['experience'],
            'education_score': breakdown['education'],
            'skills_score': breakdown['skills'],
            'projects_score': breakdown['projects'],
            'submission_ready': results['is_submission_ready'],
            'analysis_data': results,
            'grade': results['grade'],
            'total_issues': len(results['issues']),
            'critical_issues': len([i for i in results['issues'] if i['severity'] == 'critical']),
            'total_recommendations': len(recommendations['critical']) + 
                                   len(recommendations['important']) + 
                                   len(recommendations['suggestions'])
        }
    )
    
    action = "Created" if created else "Updated"
    print(f"\n📊 {action} analysis record in database (ID: {analysis.id})")

def main():
    """Run the demonstration."""
    print("🎓 CV INTELLIGENCE SYSTEM DEMONSTRATION")
    print("=" * 60)
    print("This demo shows how the CV analysis system works with different")
    print("quality levels of CV content, from empty to excellent.")
    
    # Create demo user
    user = create_sample_user()
    print(f"\n👤 Using demo user: {user.email}")
    
    # Test 1: Empty CV
    empty_cv = create_empty_cv(user)
    analyze_cv(empty_cv, "TEST 1: EMPTY CV")
    
    # Test 2: Basic CV
    basic_cv = create_basic_cv(user)
    analyze_cv(basic_cv, "TEST 2: BASIC CV (Minimal Content)")
    
    # Test 3: Excellent CV
    excellent_cv = create_excellent_cv(user)
    analyze_cv(excellent_cv, "TEST 3: EXCELLENT CV (Comprehensive)")
    
    print(f"\n{'='*60}")
    print("  DEMONSTRATION COMPLETE")
    print(f"{'='*60}")
    print("\n📋 SUMMARY:")
    print("  • Empty CV: Shows critical issues and 0% score")
    print("  • Basic CV: Shows improvement areas and medium score")
    print("  • Excellent CV: Shows high score and submission readiness")
    print("\n🔗 API ENDPOINTS:")
    print("  • GET  /api/v1/cv/analyze/  - Get or create analysis")
    print("  • POST /api/v1/cv/analyze/  - Force new analysis")
    print("  • GET  /api/v1/cv/score/    - Get detailed score breakdown")
    print("  • GET  /api/v1/cv/dashboard/ - Get dashboard overview")
    print("\n✅ The CV Intelligence system is ready for production use!")

if __name__ == "__main__":
    main()