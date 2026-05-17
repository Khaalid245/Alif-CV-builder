"""
Management command for notification cleanup operations.
Handles automatic cleanup of old notifications and maintenance tasks.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from datetime import timedelta

from apps.notifications.models import (
    Notification, NotificationEvent, NotificationBatch,
    NotificationCleanupLog, NotificationConfiguration
)


class Command(BaseCommand):
    help = 'Clean up old notifications and related data'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--days',
            type=int,
            default=None,
            help='Delete notifications older than N days (overrides config)'
        )
        
        parser.add_argument(
            '--status',
            type=str,
            choices=['read', 'sent', 'delivered', 'failed'],
            default='read',
            help='Only delete notifications with this status'
        )
        
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
            '--cleanup-events',
            action='store_true',
            help='Also cleanup old notification events'
        )
        
        parser.add_argument(
            '--cleanup-batches',
            action='store_true',
            help='Also cleanup old notification batches'
        )
    
    def handle(self, *args, **options):
        """Execute the cleanup command."""
        try:
            # Get configuration
            config = self._get_configuration()
            
            # Check if cleanup is enabled
            if not config.auto_cleanup_enabled and not options['force']:
                self.stdout.write(
                    self.style.WARNING(
                        'Auto-cleanup is disabled. Use --force to override.'
                    )
                )
                return
            
            # Determine cleanup criteria
            days = options['days'] or config.cleanup_after_days
            status_filter = options['status']
            
            self.stdout.write(f'Starting cleanup for notifications older than {days} days...')
            
            # Calculate cutoff date
            cutoff_date = timezone.now() - timedelta(days=days)
            
            # Perform cleanup
            with transaction.atomic():
                cleanup_stats = self._cleanup_notifications(
                    cutoff_date=cutoff_date,
                    status_filter=status_filter,
                    dry_run=options['dry_run']
                )
                
                if options['cleanup_events']:
                    cleanup_stats.update(
                        self._cleanup_events(cutoff_date, options['dry_run'])
                    )
                
                if options['cleanup_batches']:
                    cleanup_stats.update(
                        self._cleanup_batches(cutoff_date, options['dry_run'])
                    )
                
                # Log cleanup operation
                if not options['dry_run']:
                    self._log_cleanup(cleanup_stats, days, status_filter)
            
            # Display results
            self._display_results(cleanup_stats, options['dry_run'])
            
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Cleanup failed: {str(e)}')
            )
            raise
    
    def _get_configuration(self):
        """Get or create notification configuration."""
        config, created = NotificationConfiguration.objects.get_or_create(
            defaults={
                'auto_cleanup_enabled': True,
                'cleanup_after_days': 90
            }
        )
        return config
    
    def _cleanup_notifications(self, cutoff_date, status_filter, dry_run=False):
        """Clean up old notifications."""
        queryset = Notification.objects.filter(
            created_at__lt=cutoff_date,
            status=status_filter
        )
        
        count = queryset.count()
        
        if not dry_run and count > 0:
            queryset.delete()
        
        return {'notifications_deleted': count}
    
    def _cleanup_events(self, cutoff_date, dry_run=False):
        """Clean up old notification events."""
        queryset = NotificationEvent.objects.filter(
            created_at__lt=cutoff_date
        )
        
        count = queryset.count()
        
        if not dry_run and count > 0:
            queryset.delete()
        
        return {'events_deleted': count}
    
    def _cleanup_batches(self, cutoff_date, dry_run=False):
        """Clean up old notification batches."""
        queryset = NotificationBatch.objects.filter(
            created_at__lt=cutoff_date,
            status__in=['completed', 'failed', 'cancelled']
        )
        
        count = queryset.count()
        
        if not dry_run and count > 0:
            queryset.delete()
        
        return {'batches_deleted': count}
    
    def _log_cleanup(self, stats, days, status_filter):
        """Log cleanup operation."""
        NotificationCleanupLog.objects.create(
            notifications_deleted=stats.get('notifications_deleted', 0),
            batches_deleted=stats.get('batches_deleted', 0),
            events_deleted=stats.get('events_deleted', 0),
            cleanup_reason='Scheduled cleanup',
            older_than_days=days,
            status_filter=status_filter
        )
    
    def _display_results(self, stats, dry_run):
        """Display cleanup results."""
        action = 'Would delete' if dry_run else 'Deleted'
        
        self.stdout.write(
            self.style.SUCCESS(f'\nCleanup completed:')
        )
        
        if 'notifications_deleted' in stats:
            self.stdout.write(f'  {action} {stats["notifications_deleted"]} notifications')
        
        if 'events_deleted' in stats:
            self.stdout.write(f'  {action} {stats["events_deleted"]} events')
        
        if 'batches_deleted' in stats:
            self.stdout.write(f'  {action} {stats["batches_deleted"]} batches')
        
        if dry_run:
            self.stdout.write(
                self.style.WARNING('\nThis was a dry run. No data was actually deleted.')
            )