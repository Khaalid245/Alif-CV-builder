"""
Management command for template engine cleanup and maintenance.
Removes old analytics data, unused templates, and optimizes performance.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from datetime import timedelta
from apps.template_engine.models import (
    Template, TemplateUsage, TemplatePerformanceMetric, 
    TemplateRecommendation
)


class Command(BaseCommand):
    help = 'Clean up template engine data and perform maintenance tasks'

    def add_arguments(self, parser):
        parser.add_argument(
            '--cleanup-usage',
            action='store_true',
            help='Clean up old template usage records (older than 1 year)',
        )
        parser.add_argument(
            '--cleanup-metrics',
            action='store_true',
            help='Clean up old performance metrics (older than 6 months)',
        )
        parser.add_argument(
            '--cleanup-recommendations',
            action='store_true',
            help='Clean up old recommendations (older than 30 days)',
        )
        parser.add_argument(
            '--archive-unused',
            action='store_true',
            help='Archive templates that haven\'t been used in 6 months',
        )
        parser.add_argument(
            '--all',
            action='store_true',
            help='Run all cleanup tasks',
        )
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be cleaned up without actually doing it',
        )

    def handle(self, *args, **options):
        dry_run = options['dry_run']
        
        if dry_run:
            self.stdout.write(
                self.style.WARNING('DRY RUN MODE - No data will be deleted')
            )

        if options['all']:
            self._cleanup_usage_records(dry_run)
            self._cleanup_performance_metrics(dry_run)
            self._cleanup_recommendations(dry_run)
            self._archive_unused_templates(dry_run)
        else:
            if options['cleanup_usage']:
                self._cleanup_usage_records(dry_run)
            
            if options['cleanup_metrics']:
                self._cleanup_performance_metrics(dry_run)
            
            if options['cleanup_recommendations']:
                self._cleanup_recommendations(dry_run)
            
            if options['archive_unused']:
                self._archive_unused_templates(dry_run)

        self.stdout.write(
            self.style.SUCCESS('Template engine cleanup completed!')
        )

    def _cleanup_usage_records(self, dry_run=False):
        """Clean up old template usage records."""
        cutoff_date = timezone.now() - timedelta(days=365)  # 1 year ago
        
        old_usage = TemplateUsage.objects.filter(created_at__lt=cutoff_date)
        count = old_usage.count()
        
        if count > 0:
            self.stdout.write(f'Found {count} old usage records to clean up')
            
            if not dry_run:
                with transaction.atomic():
                    deleted_count = old_usage.delete()[0]
                    self.stdout.write(f'  ✓ Deleted {deleted_count} old usage records')
            else:
                self.stdout.write(f'  → Would delete {count} old usage records')
        else:
            self.stdout.write('No old usage records found')

    def _cleanup_performance_metrics(self, dry_run=False):
        """Clean up old performance metrics."""
        cutoff_date = timezone.now().date() - timedelta(days=180)  # 6 months ago
        
        old_metrics = TemplatePerformanceMetric.objects.filter(date__lt=cutoff_date)
        count = old_metrics.count()
        
        if count > 0:
            self.stdout.write(f'Found {count} old performance metrics to clean up')
            
            if not dry_run:
                with transaction.atomic():
                    deleted_count = old_metrics.delete()[0]
                    self.stdout.write(f'  ✓ Deleted {deleted_count} old performance metrics')
            else:
                self.stdout.write(f'  → Would delete {count} old performance metrics')
        else:
            self.stdout.write('No old performance metrics found')

    def _cleanup_recommendations(self, dry_run=False):
        """Clean up old recommendations."""
        cutoff_date = timezone.now() - timedelta(days=30)  # 30 days ago
        
        old_recommendations = TemplateRecommendation.objects.filter(
            created_at__lt=cutoff_date,
            is_viewed=False,
            is_clicked=False
        )
        count = old_recommendations.count()
        
        if count > 0:
            self.stdout.write(f'Found {count} old unviewed recommendations to clean up')
            
            if not dry_run:
                with transaction.atomic():
                    deleted_count = old_recommendations.delete()[0]
                    self.stdout.write(f'  ✓ Deleted {deleted_count} old recommendations')
            else:
                self.stdout.write(f'  → Would delete {count} old recommendations')
        else:
            self.stdout.write('No old recommendations found')

    def _archive_unused_templates(self, dry_run=False):
        """Archive templates that haven't been used recently."""
        cutoff_date = timezone.now() - timedelta(days=180)  # 6 months ago
        
        # Find templates that haven't been used in 6 months
        unused_templates = Template.objects.filter(
            status=Template.Status.ACTIVE
        ).exclude(
            usage_logs__created_at__gte=cutoff_date
        ).exclude(
            usage_logs__action=TemplateUsage.Action.GENERATE
        )
        
        count = unused_templates.count()
        
        if count > 0:
            self.stdout.write(f'Found {count} unused templates to archive')
            
            if not dry_run:
                with transaction.atomic():
                    updated_count = unused_templates.update(
                        status=Template.Status.ARCHIVED
                    )
                    self.stdout.write(f'  ✓ Archived {updated_count} unused templates')
                    
                    # Log which templates were archived
                    for template in unused_templates:
                        self.stdout.write(f'    - {template.name} ({template.slug})')
            else:
                self.stdout.write(f'  → Would archive {count} unused templates:')
                for template in unused_templates:
                    self.stdout.write(f'    - {template.name} ({template.slug})')
        else:
            self.stdout.write('No unused templates found')

    def _optimize_database(self, dry_run=False):
        """Optimize database tables using safe SQL construction."""
        if dry_run:
            self.stdout.write('  → Would optimize database tables')
            return
        
        try:
            from django.db import connection
            from django.db.models import get_models
            from apps.template_engine.models import (
                Template, TemplateUsage, TemplatePerformanceMetric, 
                TemplateRecommendation
            )
            
            # Get actual table names from Django models (safe)
            models_to_optimize = [
                Template,
                TemplateUsage, 
                TemplatePerformanceMetric,
                TemplateRecommendation
            ]
            
            with connection.cursor() as cursor:
                for model in models_to_optimize:
                    # Use Django's _meta to get the actual table name (safe)
                    table_name = model._meta.db_table
                    
                    # Validate table name contains only safe characters
                    if not table_name.replace('_', '').replace('-', '').isalnum():
                        self.stdout.write(
                            self.style.WARNING(f'Skipping unsafe table name: {table_name}')
                        )
                        continue
                    
                    # Use Django's connection.ops.quote_name for safe table name quoting
                    quoted_table = connection.ops.quote_name(table_name)
                    
                    # Use connection-specific SQL for table analysis
                    if connection.vendor == 'mysql':
                        sql = f'ANALYZE TABLE {quoted_table}'
                    elif connection.vendor == 'postgresql':
                        sql = f'ANALYZE {quoted_table}'
                    else:
                        # Skip unsupported databases
                        self.stdout.write(
                            self.style.WARNING(f'Skipping optimization for {connection.vendor} database')
                        )
                        continue
                    
                    cursor.execute(sql)
                    self.stdout.write(f'  ✓ Optimized table: {table_name}')
                    
        except Exception as e:
            self.stdout.write(
                self.style.WARNING(f'Database optimization failed: {e}')
            )