"""
Management command for analytics data cleanup.
Removes old analytics data based on retention policies.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from datetime import timedelta

from apps.analytics.services import analytics_service
from apps.analytics.models import AnalyticsConfiguration


class Command(BaseCommand):
    help = 'Clean up old analytics data based on retention policies'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be deleted without actually deleting'
        )
        
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force cleanup even if auto-cleanup is disabled'
        )
        
        parser.add_argument(
            '--raw-data-days',
            type=int,
            help='Override raw data retention days from configuration'
        )
        
        parser.add_argument(
            '--aggregated-data-days',
            type=int,
            help='Override aggregated data retention days from configuration'
        )
        
        parser.add_argument(
            '--cleanup-cache',
            action='store_true',
            help='Also cleanup expired cache entries'
        )
    
    def handle(self, *args, **options):
        """Execute the cleanup command."""
        try:
            # Get configuration
            config = AnalyticsConfiguration.get_active_config()
            
            # Check if cleanup is enabled
            if not config.auto_cleanup_enabled and not options['force']:
                self.stdout.write(
                    self.style.WARNING(
                        'Auto-cleanup is disabled. Use --force to override.'
                    )
                )
                return
            
            # Override retention settings if provided
            if options['raw_data_days']:
                config.raw_data_retention_days = options['raw_data_days']
            if options['aggregated_data_days']:
                config.aggregated_data_retention_days = options['aggregated_data_days']
            
            self.stdout.write(f'Starting analytics data cleanup...')
            self.stdout.write(f'Raw data retention: {config.raw_data_retention_days} days')
            self.stdout.write(f'Aggregated data retention: {config.aggregated_data_retention_days} days')
            
            if options['dry_run']:
                self.stdout.write(
                    self.style.WARNING('DRY RUN MODE - No data will be deleted')
                )
            
            # Perform cleanup
            cleanup_stats = analytics_service.cleanup_old_data(
                dry_run=options['dry_run']
            )
            
            # Display results
            self._display_results(cleanup_stats, options['dry_run'])
            
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Cleanup failed: {str(e)}')
            )
            raise
    
    def _display_results(self, cleanup_stats, dry_run):
        """Display cleanup results."""
        action = 'Would delete' if dry_run else 'Deleted'
        
        self.stdout.write(
            self.style.SUCCESS(f'\nCleanup completed:')
        )
        
        total_deleted = 0
        
        for data_type, count in cleanup_stats.items():
            if count > 0:
                self.stdout.write(f'  {action} {count} {data_type.replace("_", " ")}')
                total_deleted += count
        
        if total_deleted == 0:
            self.stdout.write('  No old data found for cleanup')
        else:
            self.stdout.write(f'\nTotal items {action.lower()}: {total_deleted}')
        
        if dry_run:
            self.stdout.write(
                self.style.WARNING('\nThis was a dry run. No data was actually deleted.')
            )