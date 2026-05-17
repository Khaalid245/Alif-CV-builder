"""
Management command to initialize the analytics system.
Sets up default configurations, metrics, and benchmarking groups.
"""
from django.core.management.base import BaseCommand
from django.db import transaction
from django.contrib.auth import get_user_model

from apps.analytics.models import (
    AnalyticsConfiguration, MetricDefinition, BenchmarkingGroup
)

User = get_user_model()


class Command(BaseCommand):
    help = 'Initialize analytics system with default configurations and metrics'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--update-existing',
            action='store_true',
            help='Update existing configurations and metrics'
        )
        
        parser.add_argument(
            '--create-sample-groups',
            action='store_true',
            help='Create sample benchmarking groups'
        )
    
    def handle(self, *args, **options):
        """Initialize the analytics system."""
        try:
            with transaction.atomic():
                created_configs = 0
                updated_configs = 0
                created_metrics = 0
                updated_metrics = 0
                created_groups = 0
                
                # Initialize configurations
                config_results = self._initialize_configurations(options['update_existing'])
                created_configs += config_results['created']
                updated_configs += config_results['updated']
                
                # Initialize metric definitions
                metrics_results = self._initialize_metrics(options['update_existing'])
                created_metrics += metrics_results['created']
                updated_metrics += metrics_results['updated']
                
                # Initialize benchmarking groups if requested
                if options['create_sample_groups']:
                    created_groups = self._initialize_benchmarking_groups()
                
                self.stdout.write(
                    self.style.SUCCESS(
                        f'\nAnalytics system initialization completed:\n'
                        f'  Configurations - Created: {created_configs}, Updated: {updated_configs}\n'
                        f'  Metrics - Created: {created_metrics}, Updated: {updated_metrics}\n'
                        f'  Benchmarking Groups - Created: {created_groups}'
                    )
                )
                
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Analytics initialization failed: {str(e)}')
            )
            raise
    
    def _initialize_configurations(self, update_existing):
        """Initialize default analytics configurations."""
        created = 0
        updated = 0
        
        config_data = {
            'name': 'Default Analytics Configuration',
            'description': 'Default configuration for EduCV analytics system',
            'version': '1.0.0',
            'score_calculation_enabled': True,
            'benchmarking_enabled': True,
            'trend_analysis_enabled': True,
            'daily_aggregation_enabled': True,
            'weekly_aggregation_enabled': True,
            'monthly_aggregation_enabled': True,
            'raw_data_retention_days': 365,
            'aggregated_data_retention_days': 1095,
            'peer_group_size': 100,
            'calculation_weights': {
                'completion_percentage': 0.3,
                'overall_score': 0.4,
                'section_scores': 0.2,
                'improvement_rate': 0.1
            },
            'benchmarking_criteria': {
                'education_level': True,
                'field_of_study': True,
                'experience_years': True,
                'location': False
            },
            'is_active': True,
            'is_default': True
        }
        
        config, config_created = AnalyticsConfiguration.objects.get_or_create(
            name=config_data['name'],
            defaults=config_data
        )
        
        if config_created:
            created += 1
            self.stdout.write(f'Created configuration: {config.name}')
        elif update_existing:
            for key, value in config_data.items():
                if key != 'name':
                    setattr(config, key, value)
            config.save()
            updated += 1
            self.stdout.write(f'Updated configuration: {config.name}')
        
        return {'created': created, 'updated': updated}
    
    def _initialize_metrics(self, update_existing):
        """Initialize default metric definitions."""
        created = 0
        updated = 0
        
        metrics_data = [
            {
                'name': 'average_overall_score',
                'display_name': 'Average Overall Score',
                'description': 'Average CV overall score across all users',
                'metric_type': 'score',
                'aggregation_type': 'average',
                'calculation_formula': 'AVG(overall_score)',
                'source_fields': ['overall_score'],
                'unit': 'points',
                'decimal_places': 2,
                'format_string': '{value:.2f}',
                'is_benchmarkable': True,
                'higher_is_better': True,
                'is_active': True,
                'is_system_metric': True
            },
            {
                'name': 'completion_rate',
                'display_name': 'CV Completion Rate',
                'description': 'Percentage of users with complete CVs',
                'metric_type': 'percentage',
                'aggregation_type': 'average',
                'calculation_formula': 'AVG(completion_percentage)',
                'source_fields': ['completion_percentage'],
                'unit': '%',
                'decimal_places': 1,
                'format_string': '{value:.1f}%',
                'is_benchmarkable': True,
                'higher_is_better': True,
                'is_active': True,
                'is_system_metric': True
            },
            {
                'name': 'submission_readiness_rate',
                'display_name': 'Submission Readiness Rate',
                'description': 'Percentage of users with submission-ready CVs',
                'metric_type': 'percentage',
                'aggregation_type': 'count',
                'calculation_formula': 'COUNT(submission_ready=True) / COUNT(*) * 100',
                'source_fields': ['submission_ready'],
                'unit': '%',
                'decimal_places': 1,
                'format_string': '{value:.1f}%',
                'is_benchmarkable': True,
                'higher_is_better': True,
                'is_active': True,
                'is_system_metric': True
            },
            {
                'name': 'score_improvement_rate',
                'display_name': 'Score Improvement Rate',
                'description': 'Rate of score improvement over time',
                'metric_type': 'ratio',
                'aggregation_type': 'average',
                'calculation_formula': 'AVG(score_change_per_day)',
                'source_fields': ['overall_score', 'created_at'],
                'unit': 'points/day',
                'decimal_places': 3,
                'format_string': '{value:.3f}',
                'is_benchmarkable': True,
                'higher_is_better': True,
                'is_active': True,
                'is_system_metric': True
            },
            {
                'name': 'user_engagement_score',
                'display_name': 'User Engagement Score',
                'description': 'Composite score measuring user engagement with the platform',
                'metric_type': 'score',
                'aggregation_type': 'average',
                'calculation_formula': 'WEIGHTED_AVG(snapshot_frequency, cv_updates, pdf_generations)',
                'source_fields': ['snapshot_type', 'trigger_event'],
                'unit': 'points',
                'decimal_places': 2,
                'format_string': '{value:.2f}',
                'is_benchmarkable': True,
                'higher_is_better': True,
                'is_active': True,
                'is_system_metric': True
            }
        ]
        
        for metric_data in metrics_data:
            metric, metric_created = MetricDefinition.objects.get_or_create(
                name=metric_data['name'],
                defaults=metric_data
            )
            
            if metric_created:
                created += 1
                self.stdout.write(f'Created metric: {metric.display_name}')
            elif update_existing:
                for key, value in metric_data.items():
                    if key != 'name':
                        setattr(metric, key, value)
                metric.save()
                updated += 1
                self.stdout.write(f'Updated metric: {metric.display_name}')
        
        return {'created': created, 'updated': updated}
    
    def _initialize_benchmarking_groups(self):
        """Initialize sample benchmarking groups."""
        created = 0
        
        groups_data = [
            {
                'name': 'Computer Science Students',
                'group_type': 'field_of_study',
                'description': 'Students studying computer science and related fields',
                'criteria': {
                    'field_keywords': ['computer science', 'software engineering', 'information technology'],
                    'degree_levels': ['bachelor', 'master', 'phd']
                },
                'is_active': True,
                'auto_update': True
            },
            {
                'name': 'Business Administration Students',
                'group_type': 'field_of_study',
                'description': 'Students studying business administration and management',
                'criteria': {
                    'field_keywords': ['business administration', 'management', 'mba'],
                    'degree_levels': ['bachelor', 'master']
                },
                'is_active': True,
                'auto_update': True
            },
            {
                'name': 'Engineering Students',
                'group_type': 'field_of_study',
                'description': 'Students studying various engineering disciplines',
                'criteria': {
                    'field_keywords': ['engineering', 'mechanical', 'electrical', 'civil'],
                    'degree_levels': ['bachelor', 'master', 'phd']
                },
                'is_active': True,
                'auto_update': True
            },
            {
                'name': 'Entry Level (0-2 years)',
                'group_type': 'experience_years',
                'description': 'Users with 0-2 years of professional experience',
                'criteria': {
                    'experience_years_min': 0,
                    'experience_years_max': 2
                },
                'is_active': True,
                'auto_update': True
            },
            {
                'name': 'Mid Level (3-5 years)',
                'group_type': 'experience_years',
                'description': 'Users with 3-5 years of professional experience',
                'criteria': {
                    'experience_years_min': 3,
                    'experience_years_max': 5
                },
                'is_active': True,
                'auto_update': True
            },
            {
                'name': 'Senior Level (6+ years)',
                'group_type': 'experience_years',
                'description': 'Users with 6 or more years of professional experience',
                'criteria': {
                    'experience_years_min': 6,
                    'experience_years_max': 999
                },
                'is_active': True,
                'auto_update': True
            }
        ]
        
        for group_data in groups_data:
            group, group_created = BenchmarkingGroup.objects.get_or_create(
                name=group_data['name'],
                group_type=group_data['group_type'],
                defaults=group_data
            )
            
            if group_created:
                created += 1
                self.stdout.write(f'Created benchmarking group: {group.name}')
        
        return created