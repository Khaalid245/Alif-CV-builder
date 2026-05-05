"""
CV views for EduCV.
Every view enforces that students can only access their own CV data.
Ownership is checked by filtering through cv__student=request.user.
CVProfile is auto-created on first access if it doesn't exist.
"""
import logging
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from rest_framework.views import APIView

from apps.core.responses import success_response, error_response
from apps.users.models import AuditLog
from .models import CVProfile, Education, Experience, Skill, Language, Project, Certification
from .serializers import (
    CVProfileSerializer,
    CVProfileUpdateSerializer,
    EducationSerializer,
    ExperienceSerializer,
    SkillSerializer,
    LanguageSerializer,
    ProjectSerializer,
    CertificationSerializer,
)

logger = logging.getLogger(__name__)


def _get_or_create_cv(user) -> CVProfile:
    """
    Returns the student's CVProfile, creating it automatically if it doesn't exist.
    Prefetches all related sections to avoid N+1 queries on the nested serializer.
    """
    cv, created = CVProfile.objects.prefetch_related(
        'educations', 'experiences', 'skills',
        'languages', 'projects', 'certifications',
    ).get_or_create(student=user)
    return cv


def _get_owned_object(model, pk, user):
    """
    Fetches a CV section object and verifies it belongs to the requesting student.
    Returns the object or None if not found / not owned.
    All section models link to CVProfile which links to the student.
    """
    return model.objects.filter(pk=pk, cv__student=user).first()


# ── CV Profile ─────────────────────────────────────────────────────────────────

class CVProfileView(APIView):
    """
    GET  /api/v1/cv/profile/ → Returns full nested CV with all sections
    PUT  /api/v1/cv/profile/ → Updates profile fields only
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cv = _get_or_create_cv(request.user)
        serializer = CVProfileSerializer(cv, context={'request': request})
        return success_response('CV profile retrieved successfully.', serializer.data)

    def put(self, request):
        cv = _get_or_create_cv(request.user)
        serializer = CVProfileUpdateSerializer(cv, data=request.data, partial=True)
        if not serializer.is_valid():
            return error_response('Profile update failed.', serializer.errors)

        serializer.save()
        cv.update_completion()

        # Return the full nested profile after update
        return success_response(
            'CV profile updated successfully.',
            CVProfileSerializer(cv, context={'request': request}).data,
        )


# ── CV Completion ──────────────────────────────────────────────────────────────

class CVCompletionView(APIView):
    """
    GET /api/v1/cv/completion/
    Returns completion percentage and a detailed checklist of what is missing.
    """
    permission_classes = [IsAuthenticated]

    def get(self, request):
        cv = _get_or_create_cv(request.user)

        # Single query for all counts
        from django.db.models import Count
        counts = CVProfile.objects.filter(pk=cv.pk).aggregate(
            edu_count=Count('educations',     distinct=True),
            exp_count=Count('experiences',    distinct=True),
            ski_count=Count('skills',         distinct=True),
            lan_count=Count('languages',      distinct=True),
            pro_count=Count('projects',       distinct=True),
            cer_count=Count('certifications', distinct=True),
        )

        checks = [
            (bool(cv.phone),              'Phone number'),
            (bool(cv.city),               'City'),
            (bool(cv.country),            'Country'),
            (bool(cv.summary),            'Professional summary'),
            (counts['edu_count'] >= 1,    'Education (at least 1 entry)'),
            (counts['exp_count'] >= 1,    'Experience (at least 1 entry)'),
            (counts['ski_count'] >= 2,    'Skills (at least 2 entries)'),
            (counts['lan_count'] >= 1,    'Languages (at least 1 entry)'),
            (counts['pro_count'] >= 1,    'Projects (at least 1 entry)'),
            (counts['cer_count'] >= 1,    'Certifications (at least 1 entry)'),
        ]

        missing   = [label for done, label in checks if not done]
        completed = [label for done, label in checks if done]

        # update_completion already called by mutations — no need to call here
        return success_response('CV completion status retrieved.', {
            'completion_percentage': cv.completion_percentage,
            'completed': completed,
            'missing':   missing,
        })


# ── Base Section View ──────────────────────────────────────────────────────────

class BaseSectionListView(APIView):
    """
    Base class for CV section list/create endpoints.
    Subclasses define: model, serializer_class, section_name.
    """
    permission_classes = [IsAuthenticated]
    model             = None
    serializer_class  = None
    section_name      = ''

    def get(self, request):
        # Do not auto-create CVProfile on section reads — just return empty list
        cv = CVProfile.objects.filter(student=request.user).first()
        if not cv:
            return success_response(f'{self.section_name} retrieved successfully.', [])
        objects = self.model.objects.filter(cv=cv)
        data    = self.serializer_class(objects, many=True).data
        return success_response(f'{self.section_name} retrieved successfully.', data)

    def post(self, request):
        cv = _get_or_create_cv(request.user)
        serializer = self.serializer_class(data=request.data, context={'request': request})
        if not serializer.is_valid():
            return error_response(f'Failed to add {self.section_name}.', serializer.errors)

        serializer.save(cv=cv)
        cv.update_completion()
        logger.info('%s added for student: %s', self.section_name, request.user.email)

        AuditLog.log(request.user, AuditLog.Action.CV_UPDATED, request,
                     extra_data={'section': self.section_name, 'action': 'created'})

        return success_response(
            f'{self.section_name} added successfully.',
            serializer.data,
            status.HTTP_201_CREATED,
        )


class BaseSectionDetailView(APIView):
    """
    Base class for CV section update/delete endpoints.
    Subclasses define: model, serializer_class, section_name.
    """
    permission_classes = [IsAuthenticated]
    model            = None
    serializer_class = None
    section_name     = ''

    def patch(self, request, pk):
        obj = _get_owned_object(self.model, pk, request.user)
        if not obj:
            return error_response(
                f'{self.section_name} not found.',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        serializer = self.serializer_class(obj, data=request.data, partial=True, context={'request': request})
        if not serializer.is_valid():
            return error_response(f'Failed to update {self.section_name}.', serializer.errors)

        serializer.save()
        obj.cv.update_completion()

        AuditLog.log(request.user, AuditLog.Action.CV_UPDATED, request,
                     extra_data={'section': self.section_name, 'action': 'updated', 'id': str(pk)})

        return success_response(f'{self.section_name} updated successfully.', serializer.data)

    def delete(self, request, pk):
        obj = _get_owned_object(self.model, pk, request.user)
        if not obj:
            return error_response(
                f'{self.section_name} not found.',
                status_code=status.HTTP_404_NOT_FOUND,
            )

        cv = obj.cv
        obj.delete()
        cv.update_completion()

        AuditLog.log(request.user, AuditLog.Action.CV_UPDATED, request,
                     extra_data={'section': self.section_name, 'action': 'deleted', 'id': str(pk)})

        return success_response(f'{self.section_name} deleted successfully.')


# ── Education ──────────────────────────────────────────────────────────────────

class EducationListView(BaseSectionListView):
    model            = Education
    serializer_class = EducationSerializer
    section_name     = 'Education'


class EducationDetailView(BaseSectionDetailView):
    model            = Education
    serializer_class = EducationSerializer
    section_name     = 'Education'


# ── Experience ─────────────────────────────────────────────────────────────────

class ExperienceListView(BaseSectionListView):
    model            = Experience
    serializer_class = ExperienceSerializer
    section_name     = 'Experience'


class ExperienceDetailView(BaseSectionDetailView):
    model            = Experience
    serializer_class = ExperienceSerializer
    section_name     = 'Experience'


# ── Skills ─────────────────────────────────────────────────────────────────────

class SkillListView(BaseSectionListView):
    model            = Skill
    serializer_class = SkillSerializer
    section_name     = 'Skill'


class SkillDetailView(BaseSectionDetailView):
    model            = Skill
    serializer_class = SkillSerializer
    section_name     = 'Skill'


# ── Languages ──────────────────────────────────────────────────────────────────

class LanguageListView(BaseSectionListView):
    model            = Language
    serializer_class = LanguageSerializer
    section_name     = 'Language'


class LanguageDetailView(BaseSectionDetailView):
    model            = Language
    serializer_class = LanguageSerializer
    section_name     = 'Language'


# ── Projects ───────────────────────────────────────────────────────────────────

class ProjectListView(BaseSectionListView):
    model            = Project
    serializer_class = ProjectSerializer
    section_name     = 'Project'


class ProjectDetailView(BaseSectionDetailView):
    model            = Project
    serializer_class = ProjectSerializer
    section_name     = 'Project'


# ── Certifications ─────────────────────────────────────────────────────────────

class CertificationListView(BaseSectionListView):
    model            = Certification
    serializer_class = CertificationSerializer
    section_name     = 'Certification'


class CertificationDetailView(BaseSectionDetailView):
    model            = Certification
    serializer_class = CertificationSerializer
    section_name     = 'Certification'
