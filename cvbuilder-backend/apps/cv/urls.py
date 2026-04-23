"""
CV app URL patterns.
Mounted under /api/v1/cv/ via config/api_router.py.
"""
from django.urls import path
from .views import (
    CVProfileView,
    CVCompletionView,
    EducationListView, EducationDetailView,
    ExperienceListView, ExperienceDetailView,
    SkillListView, SkillDetailView,
    LanguageListView, LanguageDetailView,
    ProjectListView, ProjectDetailView,
    CertificationListView, CertificationDetailView,
)

urlpatterns = [
    # CV Profile
    path('profile/',    CVProfileView.as_view(),    name='cv-profile'),
    path('completion/', CVCompletionView.as_view(),  name='cv-completion'),

    # Education
    path('education/',        EducationListView.as_view(),   name='education-list'),
    path('education/<uuid:pk>/', EducationDetailView.as_view(), name='education-detail'),

    # Experience
    path('experience/',           ExperienceListView.as_view(),   name='experience-list'),
    path('experience/<uuid:pk>/', ExperienceDetailView.as_view(), name='experience-detail'),

    # Skills
    path('skills/',           SkillListView.as_view(),   name='skill-list'),
    path('skills/<uuid:pk>/', SkillDetailView.as_view(), name='skill-detail'),

    # Languages
    path('languages/',           LanguageListView.as_view(),   name='language-list'),
    path('languages/<uuid:pk>/', LanguageDetailView.as_view(), name='language-detail'),

    # Projects
    path('projects/',           ProjectListView.as_view(),   name='project-list'),
    path('projects/<uuid:pk>/', ProjectDetailView.as_view(), name='project-detail'),

    # Certifications
    path('certifications/',           CertificationListView.as_view(),   name='certification-list'),
    path('certifications/<uuid:pk>/', CertificationDetailView.as_view(), name='certification-detail'),
]
