"""
Django signals for automatic version tracking.
Automatically creates versions when CV data changes.
"""
import logging
from django.db.models.signals import post_save, post_delete
from django.dispatch import receiver
from django.contrib.auth import get_user_model

from apps.cv.models import (
    CVProfile, Education, Experience, Skill, 
    Language, Project, Certification
)
from .services import version_service
from .models import CVVersion

logger = logging.getLogger(__name__)
User = get_user_model()

# Track which models should trigger version creation
TRACKED_MODELS = [
    CVProfile, Education, Experience, Skill,
    Language, Project, Certification
]


def get_request_user():
    """
    Get current user from thread-local storage.
    This is a simplified approach - in production, you might use
    django-crum or similar middleware to track the current user.
    """
    # For now, return None - the service will handle this gracefully
    return None


def get_request_metadata():
    """
    Get request metadata (IP, user agent) from thread-local storage.
    This is a simplified approach for the implementation.
    """
    return {
        'ip_address': None,
        'user_agent': ''
    }


@receiver(post_save, sender=CVProfile)
def track_cv_profile_changes(sender, instance, created, **kwargs):
    """Track changes to CV profile."""
    try:
        user = get_request_user() or instance.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = "CV profile created" if created else "CV profile updated"
        
        version_service.create_version(
            cv_profile=instance,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['profile']
        )
        
    except Exception as e:
        logger.error(f"Failed to track CV profile changes: {str(e)}")


@receiver(post_save, sender=Education)
def track_education_changes(sender, instance, created, **kwargs):
    """Track changes to education entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Education {'added' if created else 'updated'}: {instance.degree}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['educations']
        )
        
    except Exception as e:
        logger.error(f"Failed to track education changes: {str(e)}")


@receiver(post_save, sender=Experience)
def track_experience_changes(sender, instance, created, **kwargs):
    """Track changes to experience entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Experience {'added' if created else 'updated'}: {instance.job_title}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['experiences']
        )
        
    except Exception as e:
        logger.error(f"Failed to track experience changes: {str(e)}")


@receiver(post_save, sender=Skill)
def track_skill_changes(sender, instance, created, **kwargs):
    """Track changes to skill entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Skill {'added' if created else 'updated'}: {instance.name}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['skills']
        )
        
    except Exception as e:
        logger.error(f"Failed to track skill changes: {str(e)}")


@receiver(post_save, sender=Language)
def track_language_changes(sender, instance, created, **kwargs):
    """Track changes to language entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Language {'added' if created else 'updated'}: {instance.language}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['languages']
        )
        
    except Exception as e:
        logger.error(f"Failed to track language changes: {str(e)}")


@receiver(post_save, sender=Project)
def track_project_changes(sender, instance, created, **kwargs):
    """Track changes to project entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Project {'added' if created else 'updated'}: {instance.title}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['projects']
        )
        
    except Exception as e:
        logger.error(f"Failed to track project changes: {str(e)}")


@receiver(post_save, sender=Certification)
def track_certification_changes(sender, instance, created, **kwargs):
    """Track changes to certification entries."""
    try:
        user = get_request_user() or instance.cv.student
        metadata = get_request_metadata()
        
        change_type = CVVersion.ChangeType.CREATE if created else CVVersion.ChangeType.UPDATE
        change_summary = f"Certification {'added' if created else 'updated'}: {instance.name}"
        
        version_service.create_version(
            cv_profile=instance.cv,
            change_type=change_type,
            changed_by=user,
            change_summary=change_summary,
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=['certifications']
        )
        
    except Exception as e:
        logger.error(f"Failed to track certification changes: {str(e)}")


@receiver(post_delete)
def track_deletions(sender, instance, **kwargs):
    """Track deletions of CV-related objects."""
    if sender not in TRACKED_MODELS or sender == CVProfile:
        return
    
    try:
        # Get CV profile from the deleted instance
        cv_profile = getattr(instance, 'cv', None)
        if not cv_profile:
            return
        
        user = get_request_user() or cv_profile.student
        metadata = get_request_metadata()
        
        # Determine what was deleted
        model_name = sender._meta.verbose_name
        instance_name = str(instance)
        
        version_service.create_version(
            cv_profile=cv_profile,
            change_type=CVVersion.ChangeType.DELETE,
            changed_by=user,
            change_summary=f"{model_name} deleted: {instance_name}",
            ip_address=metadata['ip_address'],
            user_agent=metadata['user_agent'],
            fields_changed=[sender._meta.model_name + 's']  # e.g., 'educations'
        )
        
    except Exception as e:
        logger.error(f"Failed to track deletion: {str(e)}")