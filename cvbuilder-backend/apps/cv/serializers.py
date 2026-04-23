"""
Serializers for the CV app.
CVProfileSerializer is nested — returns all sections in one response.
Each section also has its own serializer for individual CRUD operations.
"""
from rest_framework import serializers
from .models import CVProfile, Education, Experience, Skill, Language, Project, Certification


# ── Section Serializers ────────────────────────────────────────────────────────

class EducationSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Education
        fields = [
            'id', 'degree', 'field_of_study', 'institution',
            'start_year', 'end_year', 'is_current', 'gpa', 'description', 'order',
        ]
        read_only_fields = ['id']

    def validate(self, attrs):
        # On partial updates, fall back to the existing instance values
        instance   = getattr(self, 'instance', None)
        is_current = attrs.get('is_current', getattr(instance, 'is_current', False))
        end_year   = attrs.get('end_year',   getattr(instance, 'end_year', None))
        start_year = attrs.get('start_year', getattr(instance, 'start_year', None))

        if not is_current and not end_year:
            raise serializers.ValidationError(
                {'end_year': 'End year is required unless currently studying.'}
            )
        if end_year and start_year and end_year < start_year:
            raise serializers.ValidationError(
                {'end_year': 'End year cannot be before start year.'}
            )
        return attrs


class ExperienceSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Experience
        fields = [
            'id', 'job_title', 'company', 'location',
            'start_date', 'end_date', 'is_current', 'description', 'order',
        ]
        read_only_fields = ['id']

    def validate(self, attrs):
        # On partial updates, fall back to the existing instance values
        instance   = getattr(self, 'instance', None)
        is_current = attrs.get('is_current', getattr(instance, 'is_current', False))
        end_date   = attrs.get('end_date',   getattr(instance, 'end_date', None))
        start_date = attrs.get('start_date', getattr(instance, 'start_date', None))

        if not is_current and not end_date:
            raise serializers.ValidationError(
                {'end_date': 'End date is required unless this is your current position.'}
            )
        if end_date and start_date and end_date < start_date:
            raise serializers.ValidationError(
                {'end_date': 'End date cannot be before start date.'}
            )
        return attrs


class SkillSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Skill
        fields = ['id', 'name', 'level', 'category', 'order']
        read_only_fields = ['id']

    def validate_name(self, value):
        """Prevent duplicate skill names within the same CV."""
        request = self.context.get('request')
        if not request:
            return value
        instance = getattr(self, 'instance', None)
        qs = Skill.objects.filter(cv__student=request.user, name__iexact=value)
        if instance:
            qs = qs.exclude(pk=instance.pk)
        if qs.exists():
            raise serializers.ValidationError(f'You already have a skill named "{value}".')
        return value


class LanguageSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Language
        fields = ['id', 'language', 'proficiency']
        read_only_fields = ['id']

    def validate_language(self, value):
        """Prevent duplicate languages within the same CV."""
        request = self.context.get('request')
        if not request:
            return value
        instance = getattr(self, 'instance', None)
        qs = Language.objects.filter(cv__student=request.user, language__iexact=value)
        if instance:
            qs = qs.exclude(pk=instance.pk)
        if qs.exists():
            raise serializers.ValidationError(f'You already have "{value}" in your languages.')
        return value


class ProjectSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Project
        fields = ['id', 'title', 'description', 'link', 'start_date', 'end_date', 'order']
        read_only_fields = ['id']

    def validate(self, attrs):
        start_date = attrs.get('start_date')
        end_date   = attrs.get('end_date')
        if start_date and end_date and end_date < start_date:
            raise serializers.ValidationError(
                {'end_date': 'End date cannot be before start date.'}
            )
        return attrs


class CertificationSerializer(serializers.ModelSerializer):
    class Meta:
        model  = Certification
        fields = ['id', 'name', 'issuer', 'issue_date', 'expiry_date', 'credential_url']
        read_only_fields = ['id']

    def validate(self, attrs):
        issue_date  = attrs.get('issue_date')
        expiry_date = attrs.get('expiry_date')
        if issue_date and expiry_date and expiry_date < issue_date:
            raise serializers.ValidationError(
                {'expiry_date': 'Expiry date cannot be before issue date.'}
            )
        return attrs


# ── CVProfile Serializers ──────────────────────────────────────────────────────

class CVProfileSerializer(serializers.ModelSerializer):
    """
    Full nested CV serializer.
    Returns all sections in a single response for the profile endpoint.
    Student identity fields are read from the related User model.
    """
    # Student identity — read-only, pulled from the related User
    full_name  = serializers.CharField(source='student.full_name', read_only=True)
    email      = serializers.EmailField(source='student.email',     read_only=True)
    student_id = serializers.CharField(source='student.student_id', read_only=True)

    # Nested sections — all read-only in this serializer (updated via their own endpoints)
    educations     = EducationSerializer(many=True, read_only=True)
    experiences    = ExperienceSerializer(many=True, read_only=True)
    skills         = SkillSerializer(many=True, read_only=True)
    languages      = LanguageSerializer(many=True, read_only=True)
    projects       = ProjectSerializer(many=True, read_only=True)
    certifications = CertificationSerializer(many=True, read_only=True)

    class Meta:
        model  = CVProfile
        fields = [
            'id', 'full_name', 'email', 'student_id',
            'phone', 'address', 'city', 'country', 'summary',
            'linkedin', 'github', 'portfolio', 'photo',
            'completion_percentage',
            'educations', 'experiences', 'skills',
            'languages', 'projects', 'certifications',
            'created_at', 'updated_at',
        ]
        read_only_fields = ['id', 'completion_percentage', 'created_at', 'updated_at']


class CVProfileUpdateSerializer(serializers.ModelSerializer):
    """
    Used for PUT /api/v1/cv/profile/ — updates only the profile fields.
    Nested sections are not updatable through this serializer.
    """
    class Meta:
        model  = CVProfile
        fields = [
            'phone', 'address', 'city', 'country', 'summary',
            'linkedin', 'github', 'portfolio', 'photo',
        ]

    def validate_photo(self, value):
        from django.conf import settings
        max_size = getattr(settings, 'MAX_UPLOAD_SIZE', 5 * 1024 * 1024)
        if value and value.size > max_size:
            raise serializers.ValidationError(
                f'Photo file size must not exceed {max_size // (1024 * 1024)}MB.'
            )
        return value

