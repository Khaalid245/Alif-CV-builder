"""
Management command for analytics data aggregation.
Calculates and stores aggregated metrics for performance optimization.
"""
from django.core.management.base import BaseCommand
from django.utils import timezone
from django.db import transaction
from datetime import datetime, timedelta

from apps.analytics.services import analytics_service
from apps.analytics.models import AnalyticsConfiguration


class Command(BaseCommand):
    help = 'Calculate and store aggregated analytics metrics'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--period',
            type=str,
            choices=['daily', 'weekly', 'monthly', 'all'],
            default='daily',
            help='Aggregation period to calculate'
        )
        
        parser.add_argument(
            '--start-date',
            type=str,
            help='Start date for aggregation (YYYY-MM-DD format)'
        )
        
        parser.add_argument(
            '--end-date',
            type=str,
            help='End date for aggregation (YYYY-MM-DD format)'
        )
        
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force aggregation even if disabled in configuration'
        )
        
        parser.add_argument(
            '--dry-run',
            action='store_true',
            help='Show what would be calculated without actually calculating'
        )
    
    def handle(self, *args, **options):
        """Execute the aggregation command."""
        try:
            # Get configuration
            config = AnalyticsConfiguration.get_active_config()
            
            # Check if aggregation is enabled
            period = options['period']
            if not self._is_aggregation_enabled(config, period) and not options['force']:
                self.stdout.write(
                    self.style.WARNING(
                        f'{period.title()} aggregation is disabled. Use --force to override.'
                    )
                )
                return
            
            # Parse dates
            start_date = self._parse_date(options.get('start_date'))
            end_date = self._parse_date(options.get('end_date'))
            
            if not start_date:
                start_date = timezone.now() - timedelta(days=1)
            if not end_date:
                end_date = timezone.now()
            
            self.stdout.write(f'Starting {period} aggregation from {start_date} to {end_date}...')
            
            if options['dry_run']:
                self.stdout.write(
                    self.style.WARNING('DRY RUN MODE - No data will be calculated')
                )
                return
            
            # Perform aggregation
            if period == 'all':
                results = self._aggregate_all_periods(start_date, end_date)
            else:
                results = analytics_service.calculate_aggregated_metrics(
                    period=period,
                    start_date=start_date,
                    end_date=end_date
                )
            
            # Display results
            self._display_results(results, period)
            
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Aggregation failed: {str(e)}')
            )
            raise
    
    def _is_aggregation_enabled(self, config, period):
        """Check if aggregation is enabled for the given period."""
        if period == 'daily':
            return config.daily_aggregation_enabled
        elif period == 'weekly':
            return config.weekly_aggregation_enabled
        elif period == 'monthly':
            return config.monthly_aggregation_enabled
        elif period == 'all':
            return (config.daily_aggregation_enabled or 
                   config.weekly_aggregation_enabled or 
                   config.monthly_aggregation_enabled)
        return False
    
    def _parse_date(self, date_string):
        """Parse date string to datetime object."""
        if not date_string:
            return None
        
        try:
            return datetime.strptime(date_string, '%Y-%m-%d').replace(tzinfo=timezone.utc)
        except ValueError:
            raise ValueError(f"Invalid date format: {date_string}. Use YYYY-MM-DD format.")
    
    def _aggregate_all_periods(self, start_date, end_date):
        """Aggregate all enabled periods."""
        config = AnalyticsConfiguration.get_active_config()
        results = {}
        
        if config.daily_aggregation_enabled:
            self.stdout.write('Calculating daily aggregations...')
            results['daily'] = analytics_service.calculate_aggregated_metrics(
                period='daily',
                start_date=start_date,
                end_date=end_date
            )
        
        if config.weekly_aggregation_enabled:
            self.stdout.write('Calculating weekly aggregations...')
            results['weekly'] = analytics_service.calculate_aggregated_metrics(
                period='weekly',
                start_date=start_date,
                end_date=end_date
            )
        
        if config.monthly_aggregation_enabled:
            self.stdout.write('Calculating monthly aggregations...')
            results['monthly'] = analytics_service.calculate_aggregated_metrics(
                period='monthly',
                start_date=start_date,
                end_date=end_date
            )
        
        return results
    
    def _display_results(self, results, period):
        """Display aggregation results."""
        self.stdout.write(
            self.style.SUCCESS(f'\n{period.title()} aggregation completed:')
        )
        
        if isinstance(results, dict) and 'calculated_metrics' in results:
            # Single period result
            self.stdout.write(f'  Calculated metrics: {results["calculated_metrics"]}')
            self.stdout.write(f'  Execution time: {results["execution_time_ms"]}ms')
        elif isinstance(results, dict):
            # Multiple periods result
            total_metrics = 0
            total_time = 0
            
            for period_name, period_result in results.items():
                if isinstance(period_result, dict):
                    metrics = period_result.get('calculated_metrics', 0)
                    time_ms = period_result.get('execution_time_ms', 0)
                    
                    self.stdout.write(f'  {period_name.title()}: {metrics} metrics ({time_ms}ms)')
                    total_metrics += metrics
                    total_time += time_ms
            
            self.stdout.write(f'\nTotal: {total_metrics} metrics calculated in {total_time}ms')
        else:
            self.stdout.write(f'  Result: {results}')