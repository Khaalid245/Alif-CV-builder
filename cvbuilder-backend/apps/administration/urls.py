"""
URL patterns for administration dashboard APIs.
All endpoints require admin authentication except health check.
"""
from django.urls import path
from apps.administration.views import (
    stats_views,
    student_views,
    cv_views,
    audit_views,
    health_views,
)

app_name = 'administration'

urlpatterns = [
    # ═══════════════════════════════════════════════════════════════════════════
    # PLATFORM STATISTICS
    # ═══════════════════════════════════════════════════════════════════════════
    path('stats/overview/', stats_views.platform_overview, name='platform_overview'),
    path('stats/templates/', stats_views.template_statistics, name='template_statistics'),
    path('stats/growth/', stats_views.growth_statistics, name='growth_statistics'),
    
    # ═══════════════════════════════════════════════════════════════════════════
    # STUDENT MANAGEMENT
    # ═══════════════════════════════════════════════════════════════════════════
    path('students/', student_views.StudentListView.as_view(), name='student_list'),
    path('students/<uuid:pk>/', student_views.StudentDetailView.as_view(), name='student_detail'),
    path('students/<uuid:pk>/cv/', student_views.student_cv_detail, name='student_cv_detail'),
    path('students/<uuid:pk>/status/', student_views.update_student_status, name='update_student_status'),
    path('students/deletion-requests/', student_views.deletion_requests_list, name='deletion_requests_list'),
    path('students/<uuid:pk>/process-deletion/', student_views.process_deletion_request, name='process_deletion_request'),
    
    # ═══════════════════════════════════════════════════════════════════════════
    # CV & PDF MANAGEMENT
    # ═══════════════════════════════════════════════════════════════════════════
    path('cvs/generated/', cv_views.GeneratedCVListView.as_view(), name='generated_cv_list'),
    path('cvs/stats/popular-sections/', cv_views.popular_sections_stats, name='popular_sections_stats'),
    
    # ═══════════════════════════════════════════════════════════════════════════
    # AUDIT LOGS
    # ═══════════════════════════════════════════════════════════════════════════
    path('audit-logs/', audit_views.AuditLogListView.as_view(), name='audit_log_list'),
    path('audit-logs/security/', audit_views.SecurityAuditLogListView.as_view(), name='security_audit_log_list'),
    
    # ═══════════════════════════════════════════════════════════════════════════
    # PLATFORM HEALTH
    # ═══════════════════════════════════════════════════════════════════════════
    path('health/', health_views.basic_health_check, name='basic_health_check'),
    path('health/detailed/', health_views.detailed_health_check, name='detailed_health_check'),
]