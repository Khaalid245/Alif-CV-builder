"""
Configuration Management System for EduCV Backend.
Centralizes all configurable values with environment variable support.
"""
from decouple import config
from typing import Dict, Any


class AppConfig:
    """
    Centralized configuration management for EduCV.
    All hardcoded values should be moved here with environment variable support.
    """
    
    # ─── File Upload Configuration ────────────────────────────────────────────
    MAX_UPLOAD_SIZE = config('MAX_UPLOAD_SIZE', default=5 * 1024 * 1024, cast=int)  # 5MB
    MAX_PROFILE_PHOTO_SIZE = config('MAX_PROFILE_PHOTO_SIZE', default=2 * 1024 * 1024, cast=int)  # 2MB
    ALLOWED_IMAGE_FORMATS = config('ALLOWED_IMAGE_FORMATS', default='jpg,jpeg,png,webp', cast=lambda v: v.split(','))
    
    # ─── Pagination Configuration ─────────────────────────────────────────────
    DEFAULT_PAGE_SIZE = config('DEFAULT_PAGE_SIZE', default=20, cast=int)
    MAX_PAGE_SIZE = config('MAX_PAGE_SIZE', default=100, cast=int)
    ADMIN_PAGE_SIZE = config('ADMIN_PAGE_SIZE', default=50, cast=int)
    
    # ─── CV Intelligence Scoring Configuration ────────────────────────────────
    CV_SCORING_WEIGHTS = {
        'profile': config('CV_PROFILE_WEIGHT', default=25, cast=int),
        'experience': config('CV_EXPERIENCE_WEIGHT', default=25, cast=int),
        'education': config('CV_EDUCATION_WEIGHT', default=20, cast=int),
        'skills': config('CV_SKILLS_WEIGHT', default=15, cast=int),
        'projects': config('CV_PROJECTS_WEIGHT', default=15, cast=int),
    }
    
    # ─── CV Submission Readiness Thresholds ───────────────────────────────────
    SUBMISSION_READINESS_THRESHOLDS = {
        'overall_score': config('SUBMISSION_MIN_OVERALL_SCORE', default=70, cast=int),
        'profile_score': config('SUBMISSION_MIN_PROFILE_SCORE', default=60, cast=int),
        'experience_score': config('SUBMISSION_MIN_EXPERIENCE_SCORE', default=60, cast=int),
        'education_score': config('SUBMISSION_MIN_EDUCATION_SCORE', default=60, cast=int),
        'skills_score': config('SUBMISSION_MIN_SKILLS_SCORE', default=60, cast=int),
        'projects_score': config('SUBMISSION_MIN_PROJECTS_SCORE', default=50, cast=int),
    }
    
    # ─── CV Content Validation Thresholds ─────────────────────────────────────
    CONTENT_VALIDATION = {
        'summary_min_words': config('CV_SUMMARY_MIN_WORDS', default=15, cast=int),
        'summary_max_words': config('CV_SUMMARY_MAX_WORDS', default=80, cast=int),
        'description_min_words': config('CV_DESCRIPTION_MIN_WORDS', default=10, cast=int),
        'description_max_words': config('CV_DESCRIPTION_MAX_WORDS', default=150, cast=int),
        'project_description_min_words': config('CV_PROJECT_DESC_MIN_WORDS', default=20, cast=int),
        'min_skills_count': config('CV_MIN_SKILLS_COUNT', default=3, cast=int),
        'max_skills_count': config('CV_MAX_SKILLS_COUNT', default=15, cast=int),
        'recommended_projects_count': config('CV_RECOMMENDED_PROJECTS', default=3, cast=int),
        'good_gpa_threshold': config('CV_GOOD_GPA_THRESHOLD', default=3.5, cast=float),
    }
    
    # ─── Grade Boundaries ──────────────────────────────────────────────────────
    GRADE_BOUNDARIES = {
        'A': config('GRADE_A_THRESHOLD', default=90, cast=int),
        'B': config('GRADE_B_THRESHOLD', default=80, cast=int),
        'C': config('GRADE_C_THRESHOLD', default=70, cast=int),
        'D': config('GRADE_D_THRESHOLD', default=60, cast=int),
    }
    
    # ─── Template Configuration ────────────────────────────────────────────────
    TEMPLATE_TYPES = config('TEMPLATE_TYPES', default='classic,modern,academic', cast=lambda v: v.split(','))
    DEFAULT_TEMPLATE = config('DEFAULT_TEMPLATE', default='modern')
    
    # ─── Business Rules ────────────────────────────────────────────────────────
    MAX_EXPERIENCE_ENTRIES = config('MAX_EXPERIENCE_ENTRIES', default=10, cast=int)
    MAX_EDUCATION_ENTRIES = config('MAX_EDUCATION_ENTRIES', default=5, cast=int)
    MAX_PROJECT_ENTRIES = config('MAX_PROJECT_ENTRIES', default=10, cast=int)
    MAX_CERTIFICATION_ENTRIES = config('MAX_CERTIFICATION_ENTRIES', default=15, cast=int)
    
    # ─── Notification Configuration ────────────────────────────────────────────
    NOTIFICATION_BATCH_SIZE = config('NOTIFICATION_BATCH_SIZE', default=100, cast=int)
    NOTIFICATION_RETENTION_DAYS = config('NOTIFICATION_RETENTION_DAYS', default=90, cast=int)
    
    # ─── Analytics Configuration ───────────────────────────────────────────────
    ANALYTICS_RETENTION_DAYS = config('ANALYTICS_RETENTION_DAYS', default=365, cast=int)
    SNAPSHOT_INTERVAL_HOURS = config('SNAPSHOT_INTERVAL_HOURS', default=24, cast=int)
    
    # ─── Audit Log Configuration ───────────────────────────────────────────────
    AUDIT_LOG_RETENTION_DAYS = config('AUDIT_LOG_RETENTION_DAYS', default=2555, cast=int)  # 7 years
    SECURITY_LOG_RETENTION_DAYS = config('SECURITY_LOG_RETENTION_DAYS', default=2555, cast=int)
    
    # ─── Rate Limiting Configuration ───────────────────────────────────────────
    RATE_LIMITS = {
        'anon': config('ANON_RATE_LIMIT', default='20/hour'),
        'user': config('USER_RATE_LIMIT', default='200/hour'),
        'pdf_generation': config('PDF_GENERATION_RATE_LIMIT', default='10/hour'),
        'admin': config('ADMIN_RATE_LIMIT', default='1000/hour'),
    }
    
    # ─── Cache Configuration ───────────────────────────────────────────────────
    CACHE_TIMEOUT_SHORT = config('CACHE_TIMEOUT_SHORT', default=300, cast=int)  # 5 minutes
    CACHE_TIMEOUT_MEDIUM = config('CACHE_TIMEOUT_MEDIUM', default=1800, cast=int)  # 30 minutes
    CACHE_TIMEOUT_LONG = config('CACHE_TIMEOUT_LONG', default=3600, cast=int)  # 1 hour
    
    @classmethod
    def get_cv_scoring_config(cls) -> Dict[str, Any]:
        """Get complete CV scoring configuration."""
        return {
            'weights': cls.CV_SCORING_WEIGHTS,
            'thresholds': cls.SUBMISSION_READINESS_THRESHOLDS,
            'validation': cls.CONTENT_VALIDATION,
            'grades': cls.GRADE_BOUNDARIES,
        }
    
    @classmethod
    def validate_weights(cls) -> bool:
        """Validate that scoring weights sum to 100."""
        total = sum(cls.CV_SCORING_WEIGHTS.values())
        if total != 100:
            raise ValueError(f"CV scoring weights must sum to 100, got {total}")
        return True
    
    @classmethod
    def get_pagination_config(cls, context: str = 'default') -> Dict[str, int]:
        """Get pagination configuration for different contexts."""
        configs = {
            'default': {'page_size': cls.DEFAULT_PAGE_SIZE, 'max_page_size': cls.MAX_PAGE_SIZE},
            'admin': {'page_size': cls.ADMIN_PAGE_SIZE, 'max_page_size': cls.MAX_PAGE_SIZE},
        }
        return configs.get(context, configs['default'])


# Initialize and validate configuration on import
AppConfig.validate_weights()