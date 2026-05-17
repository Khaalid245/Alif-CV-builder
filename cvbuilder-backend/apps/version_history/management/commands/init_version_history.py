"""
Management command to initialize version history system.
Creates default configuration and performs initial setup.
"""
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.version_history.models import VersionConfiguration
from apps.cv.models import CVProfile
from apps.version_history.services import version_service


class Command(BaseCommand):
    help = 'Initialize version history system with default configuration'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--max-versions',
            type=int,
            default=50,
            help='Maximum versions per CV (default: 50)'
        )
        
        parser.add_argument(
            '--no-cleanup',
            action='store_true',
            help='Disable automatic cleanup'
        )
        
        parser.add_argument(
            '--create-initial-versions',
            action='store_true',
            help='Create initial versions for existing CVs'
        )
        
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force recreate configuration if exists'
        )
    
    def handle(self, *args, **options):
        """Execute the command."""
        self.stdout.write(
            self.style.SUCCESS('Initializing Version History system...')
        )
        
        try:
            with transaction.atomic():
                # Create or update configuration
                self._setup_configuration(options)
                
                # Create initial versions if requested
                if options['create_initial_versions']:
                    self._create_initial_versions()
                
                self.stdout.write(
                    self.style.SUCCESS(
                        'Version History system initialized successfully!'
                    )
                )
                
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Failed to initialize system: {str(e)}')
            )
            raise
    
    def _setup_configuration(self, options):
        """Set up version configuration."""
        config_exists = VersionConfiguration.objects.exists()
        
        if config_exists and not options['force']:
            self.stdout.write(
                self.style.WARNING(
                    'Configuration already exists. Use --force to recreate.'
                )
            )
            return
        
        if config_exists and options['force']:
            VersionConfiguration.objects.all().delete()
            self.stdout.write('Existing configuration deleted.')
        
        config = VersionConfiguration.objects.create(
            max_versions_per_cv=options['max_versions'],
            auto_cleanup_enabled=not options['no_cleanup'],
            track_minor_changes=True,
            compression_enabled=False
        )
        
        self.stdout.write(
            f'Created configuration: max_versions={config.max_versions_per_cv}, '
            f'auto_cleanup={config.auto_cleanup_enabled}'
        )
    
    def _create_initial_versions(self):
        """Create initial versions for existing CV profiles."""
        self.stdout.write('Creating initial versions for existing CVs...')
        
        cv_profiles = CVProfile.objects.select_related('student').all()
        created_count = 0
        
        for cv_profile in cv_profiles:
            # Check if CV already has versions
            if cv_profile.versions.exists():
                self.stdout.write(
                    f'CV {cv_profile.id} already has versions, skipping.'
                )
                continue
            
            try:
                version = version_service.create_version(
                    cv_profile=cv_profile,
                    change_type='create',
                    changed_by=cv_profile.student,
                    change_summary='Initial version (system generated)',
                    fields_changed=['initial_import']
                )
                
                created_count += 1
                self.stdout.write(
                    f'Created initial version for CV {cv_profile.id} '
                    f'(student: {cv_profile.student.email})'
                )
                
            except Exception as e:
                self.stdout.write(
                    self.style.ERROR(
                        f'Failed to create version for CV {cv_profile.id}: {str(e)}'
                    )
                )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Created {created_count} initial versions.'
            )
        )
    
    def _display_statistics(self):
        """Display system statistics."""
        from apps.version_history.models import CVVersion, VersionAction
        
        total_versions = CVVersion.objects.count()
        total_cvs_with_versions = CVVersion.objects.values('cv_profile').distinct().count()
        total_actions = VersionAction.objects.count()
        
        self.stdout.write('\n' + '='*50)
        self.stdout.write('VERSION HISTORY STATISTICS')
        self.stdout.write('='*50)
        self.stdout.write(f'Total versions: {total_versions}')
        self.stdout.write(f'CVs with versions: {total_cvs_with_versions}')
        self.stdout.write(f'Total actions logged: {total_actions}')
        self.stdout.write('='*50 + '\n')