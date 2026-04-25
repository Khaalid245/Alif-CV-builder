"""
User and AuditLog models for EduCV.

User    — Custom student/admin account with UUID PK, consent tracking,
          soft delete, and data deletion request support.
AuditLog — Immutable record of every important action in the system.
"""
import uuid
from django.db import models
from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.utils import timezone
from .managers import StudentManager
from apps.core.utils import get_client_ip


class User(AbstractBaseUser, PermissionsMixin):
    """
    Central user model for EduCV.
    Used for both students and admins — differentiated by the 'role' field.
    UUID primary key ensures IDs are never guessable or sequential.
    """

    # ── Role & Status Choices ─────────────────────────────────────────────────
    class Role(models.TextChoices):
        STUDENT = 'student', 'Student'
        ADMIN   = 'admin',   'Admin'

    class Status(models.TextChoices):
        ACTIVE      = 'active',      'Active'
        SUSPENDED   = 'suspended',   'Suspended'
        DEACTIVATED = 'deactivated', 'Deactivated'

    # ── Core Identity ─────────────────────────────────────────────────────────
    id         = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email      = models.EmailField(unique=True, db_index=True)
    full_name  = models.CharField(max_length=255)
    student_id = models.CharField(max_length=50, unique=True, null=True, blank=True)

    # ── Role & Status ─────────────────────────────────────────────────────────
    role   = models.CharField(max_length=10, choices=Role.choices, default=Role.STUDENT)
    status = models.CharField(max_length=15, choices=Status.choices, default=Status.ACTIVE)

    # ── Django Required Fields ────────────────────────────────────────────────
    is_active   = models.BooleanField(default=True)
    is_staff    = models.BooleanField(default=False)

    # ── Consent Tracking (legally required) ───────────────────────────────────
    terms_consent            = models.BooleanField(default=False)
    terms_consent_date       = models.DateTimeField(null=True, blank=True)
    marketing_consent        = models.BooleanField(default=False)
    marketing_consent_date   = models.DateTimeField(null=True, blank=True)
    data_processing_consent  = models.BooleanField(default=False)
    data_processing_consent_date = models.DateTimeField(null=True, blank=True)

    # ── Data Deletion Request (GDPR-style ethical requirement) ────────────────
    deletion_requested_at = models.DateTimeField(null=True, blank=True)

    # ── Soft Delete (never hard delete student data) ──────────────────────────
    is_deleted = models.BooleanField(default=False, db_index=True)
    deleted_at = models.DateTimeField(null=True, blank=True)

    # ── Timestamps ────────────────────────────────────────────────────────────
    created_at    = models.DateTimeField(auto_now_add=True)
    updated_at    = models.DateTimeField(auto_now=True)
    last_login_at = models.DateTimeField(null=True, blank=True)

    objects = StudentManager()

    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['full_name']

    class Meta:
        db_table     = 'users'
        verbose_name = 'User'
        verbose_name_plural = 'Users'
        ordering = ['-created_at']
        indexes = [
            models.Index(fields=['status'],     name='idx_user_status'),
            models.Index(fields=['created_at'], name='idx_user_created_at'),
            models.Index(fields=['role'],       name='idx_user_role'),
        ]

    def __str__(self):
        return f'{self.email} ({self.get_role_display()})'

    # ── Business Logic Helpers ────────────────────────────────────────────────

    def is_account_active(self) -> bool:
        """Returns True only if the account is active and not soft-deleted."""
        return self.status == self.Status.ACTIVE and not self.is_deleted

    def soft_delete(self):
        """Marks the account as deleted without removing the database record."""
        self.is_deleted        = True
        self.deleted_at        = timezone.now()
        self.is_active         = False
        # Clear the pending deletion request — it has been processed
        self.deletion_requested_at = None
        self.save(update_fields=[
            'is_deleted', 'deleted_at', 'is_active',
            'deletion_requested_at', 'updated_at',
        ])

    def record_login(self):
        """Updates last_login_at timestamp on successful authentication."""
        self.last_login_at = timezone.now()
        self.save(update_fields=['last_login_at'])


class AuditLog(models.Model):
    """
    Immutable audit trail for all important actions in EduCV.
    Records who did what, when, and from where.
    Never update or delete audit log entries — append only.
    """

    class Action(models.TextChoices):
        LOGIN               = 'login',               'Login'
        LOGIN_FAILED        = 'login_failed',        'Login Failed'
        LOGOUT              = 'logout',              'Logout'
        REGISTER            = 'register',            'Register'
        CV_CREATED          = 'cv_created',          'CV Created'
        CV_UPDATED          = 'cv_updated',          'CV Updated'
        PDF_GENERATED       = 'pdf_generated',       'PDF Generated'
        PDF_DOWNLOADED      = 'pdf_downloaded',      'PDF Downloaded'
        ACCOUNT_DELETED     = 'account_deleted',     'Account Deleted'
        ACCOUNT_SUSPENDED   = 'account_suspended',   'Account Suspended'
        ACCOUNT_REACTIVATED = 'account_reactivated', 'Account Reactivated'
        PASSWORD_CHANGED    = 'password_changed',    'Password Changed'
        DELETION_REQUESTED  = 'deletion_requested',  'Deletion Requested'

    id      = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    # SET_NULL so audit logs survive even if the user is soft-deleted
    student = models.ForeignKey(
        'users.User',
        on_delete=models.SET_NULL,
        null=True,
        blank=True,
        related_name='audit_logs',
    )
    action     = models.CharField(max_length=30, choices=Action.choices, db_index=True)
    ip_address = models.GenericIPAddressField(null=True, blank=True)
    user_agent = models.TextField(blank=True, default='')
    extra_data = models.JSONField(default=dict, blank=True)
    timestamp  = models.DateTimeField(auto_now_add=True, db_index=True)

    class Meta:
        db_table     = 'audit_logs'
        verbose_name = 'Audit Log'
        verbose_name_plural = 'Audit Logs'
        ordering = ['-timestamp']
        indexes = [
            models.Index(fields=['action'],    name='idx_auditlog_action'),
            models.Index(fields=['timestamp'], name='idx_auditlog_timestamp'),
        ]

    def __str__(self):
        return f'[{self.timestamp}] {self.action} — {self.student}'

    @classmethod
    def log(cls, student, action, request=None, extra_data=None):
        """
        Convenience class method to create an audit log entry.
        Usage: AuditLog.log(student, AuditLog.Action.LOGIN, request)
        """
        ip_address = None
        user_agent = ''

        if request:
            ip_address = get_client_ip(request)
            user_agent = request.META.get('HTTP_USER_AGENT', '')

        return cls.objects.create(
            student=student,
            action=action,
            ip_address=ip_address,
            user_agent=user_agent,
            extra_data=extra_data or {},
        )

