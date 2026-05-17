"""
Management command to initialize default notification templates.
Creates all required templates for the CV Builder platform.
"""
from django.core.management.base import BaseCommand
from django.db import transaction

from apps.notifications.models import NotificationTemplate


class Command(BaseCommand):
    help = 'Initialize default notification templates'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--update-existing',
            action='store_true',
            help='Update existing templates with new content'
        )
    
    def handle(self, *args, **options):
        """Initialize notification templates."""
        try:
            with transaction.atomic():
                created_count = 0
                updated_count = 0
                
                for template_data in self._get_template_definitions():
                    template, created = NotificationTemplate.objects.get_or_create(
                        name=template_data['name'],
                        defaults=template_data
                    )
                    
                    if created:
                        created_count += 1
                        self.stdout.write(f'Created template: {template.name}')
                    elif options['update_existing']:
                        for key, value in template_data.items():
                            if key != 'name':
                                setattr(template, key, value)
                        template.save()
                        updated_count += 1
                        self.stdout.write(f'Updated template: {template.name}')
                
                self.stdout.write(
                    self.style.SUCCESS(
                        f'\nTemplate initialization completed:\n'
                        f'  Created: {created_count}\n'
                        f'  Updated: {updated_count}'
                    )
                )
                
        except Exception as e:
            self.stdout.write(
                self.style.ERROR(f'Template initialization failed: {str(e)}')
            )
            raise
    
    def _get_template_definitions(self):
        """Get all template definitions."""
        return [
            # CV-related templates
            {
                'name': 'cv_created',
                'notification_type': 'cv_created',
                'title_template': 'Welcome to EduCV, {user_name}!',
                'message_template': 'Your CV profile has been created successfully. Start building your professional CV now.',
                'email_subject_template': 'Welcome to EduCV - Your CV Profile is Ready',
                'email_html_template': '''
                <h2>Welcome to EduCV, {user_name}!</h2>
                <p>Your CV profile has been created successfully.</p>
                <p>You can now start adding your education, experience, and skills to build a professional CV.</p>
                <p><a href="/cv/edit">Start Building Your CV</a></p>
                ''',
                'channel': 'both',
                'priority': 'high',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'cv_id': 'CV profile ID',
                    'completion_percentage': 'CV completion percentage'
                }
            },
            
            {
                'name': 'cv_updated',
                'notification_type': 'cv_updated',
                'title_template': 'CV Updated Successfully',
                'message_template': 'Your CV has been updated. Completion: {completion_percentage}%',
                'email_subject_template': 'CV Updated - {completion_percentage}% Complete',
                'email_html_template': '''
                <h2>CV Updated Successfully</h2>
                <p>Your CV has been updated and is now {completion_percentage}% complete.</p>
                <p><a href="/cv/edit">Continue Editing</a></p>
                ''',
                'channel': 'in_app',
                'priority': 'normal',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'cv_id': 'CV profile ID',
                    'completion_percentage': 'CV completion percentage'
                }
            },
            
            {
                'name': 'cv_completed',
                'notification_type': 'cv_completed',
                'title_template': 'Congratulations! Your CV is Complete',
                'message_template': 'Your CV is now 100% complete. You can generate professional PDFs now.',
                'email_subject_template': 'CV Complete - Ready to Generate PDFs',
                'email_html_template': '''
                <h2>Congratulations, {user_name}!</h2>
                <p>Your CV is now 100% complete and ready for professional use.</p>
                <p>You can now generate beautiful PDF versions of your CV.</p>
                <p><a href="/cv/generate">Generate PDF CVs</a></p>
                ''',
                'channel': 'both',
                'priority': 'high',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'cv_id': 'CV profile ID'
                }
            },
            
            # PDF generation templates
            {
                'name': 'pdf_generated',
                'notification_type': 'pdf_generated',
                'title_template': 'Your {template_name} CV is Ready!',
                'message_template': 'Your {template_name} CV has been generated successfully. Download it now.',
                'email_subject_template': 'CV PDF Ready - {template_name} Template',
                'email_html_template': '''
                <h2>Your {template_name} CV is Ready!</h2>
                <p>Your CV has been generated using the {template_name} template.</p>
                <p><a href="{download_url}">Download Your CV</a></p>
                ''',
                'channel': 'both',
                'priority': 'high',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'template_name': 'CV template name (Classic, Modern, Academic)',
                    'cv_id': 'CV profile ID',
                    'download_url': 'PDF download URL'
                }
            },
            
            # Workflow templates
            {
                'name': 'workflow_started',
                'notification_type': 'workflow_changed',
                'title_template': 'Workflow Started: {workflow_name}',
                'message_template': 'A new workflow "{workflow_name}" has been started for your CV.',
                'channel': 'in_app',
                'priority': 'normal',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'workflow_name': 'Workflow configuration name',
                    'current_state': 'Current workflow state',
                    'cv_id': 'CV profile ID'
                }
            },
            
            {
                'name': 'workflow_state_changed',
                'notification_type': 'workflow_changed',
                'title_template': 'Workflow Update: {current_state}',
                'message_template': 'Your CV workflow "{workflow_name}" has moved to: {current_state}',
                'channel': 'in_app',
                'priority': 'normal',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'workflow_name': 'Workflow configuration name',
                    'current_state': 'Current workflow state',
                    'cv_id': 'CV profile ID'
                }
            },
            
            # Version history templates
            {
                'name': 'version_restored',
                'notification_type': 'version_restored',
                'title_template': 'CV Version Restored',
                'message_template': 'Your CV has been restored to version {version_number}.',
                'channel': 'in_app',
                'priority': 'normal',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'version_number': 'Restored version number',
                    'cv_id': 'CV profile ID',
                    'change_summary': 'Version change summary'
                }
            },
            
            # Analysis templates
            {
                'name': 'analysis_completed',
                'notification_type': 'analysis_completed',
                'title_template': 'CV Analysis Complete',
                'message_template': 'Your CV analysis is ready. Score: {overall_score}/100 with {recommendations_count} recommendations.',
                'email_subject_template': 'CV Analysis Results - Score: {overall_score}/100',
                'email_html_template': '''
                <h2>Your CV Analysis is Complete</h2>
                <p>Overall Score: <strong>{overall_score}/100</strong></p>
                <p>We found {recommendations_count} recommendations to improve your CV.</p>
                <p><a href="{analysis_url}">View Full Analysis</a></p>
                ''',
                'channel': 'both',
                'priority': 'normal',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'cv_id': 'CV profile ID',
                    'overall_score': 'Analysis overall score',
                    'recommendations_count': 'Number of recommendations',
                    'analysis_url': 'Analysis results URL'
                }
            },
            
            # System templates
            {
                'name': 'welcome_user',
                'notification_type': 'account_updated',
                'title_template': 'Welcome to {platform_name}!',
                'message_template': 'Welcome to {platform_name}, {user_name}! Start building your professional CV today.',
                'email_subject_template': 'Welcome to {platform_name} - Build Your Professional CV',
                'email_html_template': '''
                <h1>Welcome to {platform_name}!</h1>
                <p>Hello {user_name},</p>
                <p>Welcome to {platform_name}, the university CV builder platform.</p>
                <p>You can now create professional CVs with our easy-to-use tools.</p>
                <p><a href="/cv/create">Start Building Your CV</a></p>
                ''',
                'channel': 'both',
                'priority': 'high',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'platform_name': 'Platform name (EduCV)'
                }
            },
            
            {
                'name': 'system_maintenance',
                'notification_type': 'system_maintenance',
                'title_template': 'Scheduled Maintenance: {scheduled_time}',
                'message_template': 'System maintenance scheduled for {scheduled_time}. Affected services: {affected_services}',
                'email_subject_template': 'Scheduled Maintenance - {platform_name}',
                'email_html_template': '''
                <h2>Scheduled System Maintenance</h2>
                <p><strong>When:</strong> {scheduled_time}</p>
                <p><strong>Message:</strong> {message}</p>
                <p><strong>Affected Services:</strong> {affected_services}</p>
                <p>We apologize for any inconvenience.</p>
                ''',
                'channel': 'both',
                'priority': 'high',
                'available_variables': {
                    'message': 'Maintenance message',
                    'scheduled_time': 'Maintenance schedule',
                    'affected_services': 'List of affected services',
                    'platform_name': 'Platform name'
                }
            },
            
            {
                'name': 'security_alert',
                'notification_type': 'security_alert',
                'title_template': 'Security Alert: {alert_type}',
                'message_template': 'Security alert for your account: {alert_type} from {ip_address} at {timestamp}',
                'email_subject_template': 'Security Alert - {alert_type}',
                'email_html_template': '''
                <h2>Security Alert</h2>
                <p><strong>Alert Type:</strong> {alert_type}</p>
                <p><strong>IP Address:</strong> {ip_address}</p>
                <p><strong>Time:</strong> {timestamp}</p>
                <p><strong>Action Taken:</strong> {action_taken}</p>
                <p>If this wasn't you, please contact support immediately.</p>
                ''',
                'channel': 'both',
                'priority': 'urgent',
                'available_variables': {
                    'user_name': 'User\'s full name or email',
                    'alert_type': 'Type of security alert',
                    'ip_address': 'Source IP address',
                    'timestamp': 'Alert timestamp',
                    'action_taken': 'Security action taken'
                }
            }
        ]