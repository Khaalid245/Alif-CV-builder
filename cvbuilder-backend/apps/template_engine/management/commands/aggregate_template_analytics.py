"""
Management command to aggregate template analytics data.
Runs daily to calculate performance metrics and update statistics.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from datetime import datetime, timedelta
from apps.template_engine.services import TemplateAnalyticsService


class Command(BaseCommand):
    help = 'Aggregate template analytics data for specified date range'

    def add_arguments(self, parser):
        parser.add_argument(
            '--date',
            type=str,
            help='Specific date to aggregate (YYYY-MM-DD format)',
        )
        parser.add_argument(
            '--days',
            type=int,
            default=1,
            help='Number of days to aggregate (default: 1)',
        )
        parser.add_argument(
            '--backfill',
            action='store_true',
            help='Backfill missing analytics data for the last 30 days',
        )

    def handle(self, *args, **options):
        if options['backfill']:
            self._backfill_analytics()
        elif options['date']:
            date = datetime.fromisoformat(options['date']).date()
            self._aggregate_date(date)
        else:
            # Aggregate for the specified number of days
            end_date = timezone.now().date() - timedelta(days=1)  # Yesterday
            start_date = end_date - timedelta(days=options['days'] - 1)
            
            current_date = start_date
            while current_date <= end_date:
                self._aggregate_date(current_date)
                current_date += timedelta(days=1)

        self.stdout.write(
            self.style.SUCCESS('Template analytics aggregation completed!')
        )

    def _aggregate_date(self, date):
        """Aggregate analytics for a specific date."""
        try:
            self.stdout.write(f'Aggregating analytics for {date}...')
            TemplateAnalyticsService.aggregate_daily_metrics(date)
            self.stdout.write(f'  ✓ Completed aggregation for {date}')
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'  ✗ Error aggregating {date}: {e}')
            )

    def _backfill_analytics(self):
        """Backfill analytics data for the last 30 days."""
        self.stdout.write('Backfilling analytics data for the last 30 days...')
        
        end_date = timezone.now().date() - timedelta(days=1)
        start_date = end_date - timedelta(days=29)
        
        current_date = start_date
        while current_date <= end_date:
            self._aggregate_date(current_date)
            current_date += timedelta(days=1)