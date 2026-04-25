"""
Statistics views for admin dashboard.
Provides platform overview, template statistics, and growth metrics.
"""
import logging
from datetime import datetime, timedelta
from django.db.models import Count, Avg, Q
from django.utils import timezone
from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response

from apps.core.responses import success_response
from apps.administration.permissions import IsAdminUser
from apps.users.models import User, AuditLog
from apps.cv.models import CVProfile, GeneratedCV

# Application logger
app_logger = logging.getLogger('app')


@api_view(['GET'])
@permission_classes([IsAdminUser])
def platform_overview(request):
    """
    GET /api/v1/admin/stats/overview/
    Returns main dashboard statistics.
    """
    app_logger.info(f"Admin {request.user.email} accessed platform overview stats")
    
    # Calculate date ranges
    today = timezone.now().date()
    week_ago = today - timedelta(days=7)
    month_ago = today - timedelta(days=30)
    
    # Student statistics with single query using annotations
    student_stats = User.objects.aggregate(
        total=Count('id'),
        active=Count('id', filter=Q(status=User.Status.ACTIVE)),
        suspended=Count('id', filter=Q(status=User.Status.SUSPENDED)),
        deactivated=Count('id', filter=Q(status=User.Status.DEACTIVATED)),
        new_today=Count('id', filter=Q(created_at__date=today)),
        new_this_week=Count('id', filter=Q(created_at__date__gte=week_ago)),
        new_this_month=Count('id', filter=Q(created_at__date__gte=month_ago)),
    )
    
    # CV statistics
    cv_stats = GeneratedCV.objects.aggregate(
        total_generated=Count('id'),
        generated_today=Count('id', filter=Q(generated_at__date=today)),
        generated_this_week=Count('id', filter=Q(generated_at__date__gte=week_ago)),
        generated_this_month=Count('id', filter=Q(generated_at__date__gte=month_ago)),
        total_downloads=Count('id', filter=Q(download_count__gt=0)),
    )
    
    # Most popular template
    popular_template = GeneratedCV.objects.values('template').annotate(
        count=Count('id')
    ).order_by('-count').first()
    
    most_popular_template = popular_template['template'] if popular_template else None
    
    # Platform statistics
    platform_stats = {
        'total_audit_logs': AuditLog.objects.count(),
        'deletion_requests_pending': User.objects.filter(
            deletion_requested_at__isnull=False,
            is_deleted=False
        ).count(),
        'students_with_complete_cv': CVProfile.objects.filter(
            completion_percentage=100
        ).count(),
        'average_completion_percentage': CVProfile.objects.aggregate(
            avg=Avg('completion_percentage')
        )['avg'] or 0,
    }
    
    data = {
        'students': student_stats,
        'cvs': {
            **cv_stats,
            'most_popular_template': most_popular_template,
        },
        'platform': platform_stats,
    }
    
    return success_response(
        message="Platform overview statistics retrieved successfully.",
        data=data
    )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def template_statistics(request):
    """
    GET /api/v1/admin/stats/templates/
    Returns breakdown per CV template.
    """
    app_logger.info(f"Admin {request.user.email} accessed template statistics")
    
    # Get template statistics
    template_stats = GeneratedCV.objects.values('template').annotate(
        total_generated=Count('id'),
        total_downloads=Count('id', filter=Q(download_count__gt=0))
    ).order_by('-total_generated')
    
    # Calculate total for percentages
    total_generated = GeneratedCV.objects.count()
    
    # Format response data
    data = []
    for stat in template_stats:
        percentage = (stat['total_generated'] / total_generated * 100) if total_generated > 0 else 0
        
        data.append({
            'template': stat['template'],
            'template_display': dict(GeneratedCV.Template.choices)[stat['template']],
            'total_generated': stat['total_generated'],
            'total_downloads': stat['total_downloads'],
            'percentage_of_total': round(percentage, 1),
        })
    
    return success_response(
        message="Template statistics retrieved successfully.",
        data=data
    )


@api_view(['GET'])
@permission_classes([IsAdminUser])
def growth_statistics(request):
    """
    GET /api/v1/admin/stats/growth/
    Returns student registration and CV generation growth over time.
    Query param: ?period=daily|weekly|monthly (default: monthly)
    """
    app_logger.info(f"Admin {request.user.email} accessed growth statistics")
    
    period = request.GET.get('period', 'monthly')
    
    if period == 'daily':
        # Last 12 days
        date_format = '%Y-%m-%d'
        periods = [(timezone.now().date() - timedelta(days=i)) for i in range(11, -1, -1)]
        labels = [p.strftime('%m-%d') for p in periods]
        
    elif period == 'weekly':
        # Last 12 weeks
        date_format = '%Y-%W'
        periods = []
        labels = []
        for i in range(11, -1, -1):
            week_start = timezone.now().date() - timedelta(weeks=i)
            periods.append(week_start)
            labels.append(f"Week {week_start.strftime('%W')}")
        
    else:  # monthly
        # Last 12 months
        date_format = '%Y-%m'
        periods = []
        labels = []
        for i in range(11, -1, -1):
            month_date = timezone.now().date().replace(day=1) - timedelta(days=32*i)
            month_date = month_date.replace(day=1)
            periods.append(month_date)
            labels.append(month_date.strftime('%b'))
    
    # Get registration data
    registrations = []
    cvs_generated = []
    
    for i, period_date in enumerate(periods):
        if period == 'daily':
            reg_count = User.objects.filter(created_at__date=period_date).count()
            cv_count = GeneratedCV.objects.filter(generated_at__date=period_date).count()
        elif period == 'weekly':
            week_end = period_date + timedelta(days=6)
            reg_count = User.objects.filter(
                created_at__date__gte=period_date,
                created_at__date__lte=week_end
            ).count()
            cv_count = GeneratedCV.objects.filter(
                generated_at__date__gte=period_date,
                generated_at__date__lte=week_end
            ).count()
        else:  # monthly
            if i < len(periods) - 1:
                next_month = periods[i + 1]
            else:
                next_month = timezone.now().date().replace(day=1)
            
            reg_count = User.objects.filter(
                created_at__date__gte=period_date,
                created_at__date__lt=next_month
            ).count()
            cv_count = GeneratedCV.objects.filter(
                generated_at__date__gte=period_date,
                generated_at__date__lt=next_month
            ).count()
        
        registrations.append(reg_count)
        cvs_generated.append(cv_count)
    
    data = {
        'period': period,
        'labels': labels,
        'registrations': registrations,
        'cvs_generated': cvs_generated,
    }
    
    return success_response(
        message=f"Growth statistics ({period}) retrieved successfully.",
        data=data
    )