"""
Management command to initialize default CV workflow configuration.
Creates the standard CV review workflow with all states and transitions.
"""
from django.core.management.base import BaseCommand
from django.contrib.auth import get_user_model
from apps.workflow.models import (
    WorkflowConfiguration, WorkflowState, WorkflowTransition, WorkflowRule
)

User = get_user_model()


class Command(BaseCommand):
    help = 'Initialize default CV workflow configuration'
    
    def add_arguments(self, parser):
        parser.add_argument(
            '--admin-email',
            type=str,
            default='admin@university.edu',
            help='Email of admin user to create workflow (default: admin@university.edu)'
        )
        
        parser.add_argument(
            '--force',
            action='store_true',
            help='Force recreation of workflow if it already exists'
        )
    
    def handle(self, *args, **options):
        admin_email = options['admin_email']
        force = options['force']
        
        # Get or create admin user
        try:
            admin_user = User.objects.get(email=admin_email, role=User.Role.ADMIN)
        except User.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'Admin user with email {admin_email} not found')
            )
            return
        
        # Check if workflow already exists
        existing_workflow = WorkflowConfiguration.objects.filter(
            name='CV Review Workflow',
            entity_type='cv.cvprofile'
        ).first()
        
        if existing_workflow and not force:
            self.stdout.write(
                self.style.WARNING('CV Review Workflow already exists. Use --force to recreate.')
            )
            return
        
        if existing_workflow and force:
            self.stdout.write('Deleting existing workflow configuration...')
            existing_workflow.delete()
        
        # Create workflow configuration
        self.stdout.write('Creating CV Review Workflow configuration...')
        
        workflow_config = WorkflowConfiguration.objects.create(
            name='CV Review Workflow',
            description='Standard CV review and approval process for university students',
            entity_type='cv.cvprofile',
            is_active=True,
            is_default=True,
            created_by=admin_user,
            configuration={
                'description': 'Standard 5-state CV workflow',
                'version': '1.0',
                'features': ['role_based_transitions', 'validation_rules', 'audit_logging']
            }
        )
        
        # Create workflow states
        self.stdout.write('Creating workflow states...')
        
        draft_state = WorkflowState.objects.create(
            workflow_config=workflow_config,
            code='draft',
            name='Draft',
            description='Initial state when CV is being created or edited',
            state_type=WorkflowState.StateType.INITIAL,
            order=1,
            properties={
                'color': '#6c757d',
                'icon': 'edit',
                'student_actions': ['edit', 'submit'],
                'admin_actions': []
            }
        )
        
        review_state = WorkflowState.objects.create(
            workflow_config=workflow_config,
            code='under_review',
            name='Under Review',
            description='CV is being reviewed by administrators',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=2,
            properties={
                'color': '#ffc107',
                'icon': 'clock',
                'student_actions': [],
                'admin_actions': ['approve', 'request_revision']
            }
        )
        
        revision_state = WorkflowState.objects.create(
            workflow_config=workflow_config,
            code='needs_revision',
            name='Needs Revision',
            description='CV requires changes before approval',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=3,
            properties={
                'color': '#dc3545',
                'icon': 'exclamation-triangle',
                'student_actions': ['edit', 'resubmit'],
                'admin_actions': []
            }
        )
        
        approved_state = WorkflowState.objects.create(
            workflow_config=workflow_config,
            code='approved',
            name='Approved',
            description='CV has been approved and is ready for publication',
            state_type=WorkflowState.StateType.INTERMEDIATE,
            order=4,
            properties={
                'color': '#28a745',
                'icon': 'check-circle',
                'student_actions': [],
                'admin_actions': ['publish']
            }
        )
        
        published_state = WorkflowState.objects.create(
            workflow_config=workflow_config,
            code='published',
            name='Published',
            description='CV is published and available for employers',
            state_type=WorkflowState.StateType.FINAL,
            order=5,
            properties={
                'color': '#007bff',
                'icon': 'globe',
                'student_actions': ['download'],
                'admin_actions': []
            }
        )
        
        # Create workflow transitions
        self.stdout.write('Creating workflow transitions...')
        
        # Student transitions
        submit_transition = WorkflowTransition.objects.create(
            workflow_config=workflow_config,
            name='Submit for Review',
            description='Submit CV for administrative review',
            from_state=draft_state,
            to_state=review_state,
            allowed_roles=['student'],
            requires_comment=False,
            validation_rules=[
                {
                    'field_path': 'completion_percentage',
                    'operator': 'gte',
                    'expected_value': 70,
                    'error_message': 'CV must be at least 70% complete to submit for review'
                }
            ],
            properties={
                'button_text': 'Submit for Review',
                'button_class': 'btn-primary',
                'confirmation_required': True,
                'confirmation_message': 'Are you sure you want to submit your CV for review?'
            }
        )
        
        resubmit_transition = WorkflowTransition.objects.create(
            workflow_config=workflow_config,
            name='Resubmit',
            description='Resubmit CV after making requested revisions',
            from_state=revision_state,
            to_state=review_state,
            allowed_roles=['student'],
            requires_comment=False,
            validation_rules=[
                {
                    'field_path': 'completion_percentage',
                    'operator': 'gte',
                    'expected_value': 70,
                    'error_message': 'CV must be at least 70% complete to resubmit'
                }
            ],
            properties={
                'button_text': 'Resubmit',
                'button_class': 'btn-success',
                'confirmation_required': True,
                'confirmation_message': 'Have you addressed all the requested revisions?'
            }
        )
        
        # Admin transitions
        approve_transition = WorkflowTransition.objects.create(
            workflow_config=workflow_config,
            name='Approve',
            description='Approve CV for publication',
            from_state=review_state,
            to_state=approved_state,
            allowed_roles=['admin'],
            requires_comment=False,
            properties={
                'button_text': 'Approve',
                'button_class': 'btn-success',
                'confirmation_required': False
            }
        )
        
        request_revision_transition = WorkflowTransition.objects.create(
            workflow_config=workflow_config,
            name='Request Revision',
            description='Request changes to the CV before approval',
            from_state=review_state,
            to_state=revision_state,
            allowed_roles=['admin'],
            requires_comment=True,
            properties={
                'button_text': 'Request Revision',
                'button_class': 'btn-warning',
                'confirmation_required': True,
                'confirmation_message': 'Please provide specific feedback for the student.',
                'comment_placeholder': 'Please specify what changes are needed...'
            }
        )
        
        publish_transition = WorkflowTransition.objects.create(
            workflow_config=workflow_config,
            name='Publish',
            description='Publish approved CV',
            from_state=approved_state,
            to_state=published_state,
            allowed_roles=['admin'],
            requires_comment=False,
            properties={
                'button_text': 'Publish',
                'button_class': 'btn-primary',
                'confirmation_required': True,
                'confirmation_message': 'This will make the CV publicly available.'
            }
        )
        
        # Create workflow rules
        self.stdout.write('Creating workflow validation rules...')
        
        completion_rule = WorkflowRule.objects.create(
            workflow_config=workflow_config,
            name='CV Completion Requirement',
            description='Ensure CV is sufficiently complete before submission',
            rule_type=WorkflowRule.RuleType.VALIDATION,
            field_path='completion_percentage',
            operator=WorkflowRule.Operator.GREATER_THAN,
            expected_value=70,
            error_message='CV must be at least 70% complete',
            properties={
                'applies_to_transitions': ['submit', 'resubmit'],
                'severity': 'error'
            }
        )
        
        contact_info_rule = WorkflowRule.objects.create(
            workflow_config=workflow_config,
            name='Contact Information Requirement',
            description='Ensure essential contact information is provided',
            rule_type=WorkflowRule.RuleType.VALIDATION,
            field_path='phone',
            operator=WorkflowRule.Operator.EXISTS,
            expected_value=None,
            error_message='Phone number is required',
            properties={
                'applies_to_transitions': ['submit', 'resubmit'],
                'severity': 'error'
            }
        )
        
        summary_rule = WorkflowRule.objects.create(
            workflow_config=workflow_config,
            name='Professional Summary Requirement',
            description='Ensure professional summary is provided',
            rule_type=WorkflowRule.RuleType.VALIDATION,
            field_path='summary',
            operator=WorkflowRule.Operator.EXISTS,
            expected_value=None,
            error_message='Professional summary is required',
            properties={
                'applies_to_transitions': ['submit', 'resubmit'],
                'severity': 'warning'
            }
        )
        
        self.stdout.write(
            self.style.SUCCESS(
                f'Successfully created CV Review Workflow with:\n'
                f'  - 5 states: {[s.name for s in workflow_config.states.all()]}\n'
                f'  - 5 transitions: {[t.name for t in workflow_config.transitions.all()]}\n'
                f'  - 3 validation rules\n'
                f'  - Configuration ID: {workflow_config.id}'
            )
        )
        
        # Display workflow summary
        self.stdout.write('\n' + '='*60)
        self.stdout.write('WORKFLOW SUMMARY')
        self.stdout.write('='*60)
        
        self.stdout.write(f'Name: {workflow_config.name}')
        self.stdout.write(f'Entity Type: {workflow_config.entity_type}')
        self.stdout.write(f'Default: {workflow_config.is_default}')
        self.stdout.write(f'Active: {workflow_config.is_active}')
        
        self.stdout.write('\nStates:')
        for state in workflow_config.states.all():
            self.stdout.write(f'  {state.order}. {state.name} ({state.code}) - {state.state_type}')
        
        self.stdout.write('\nTransitions:')
        for transition in workflow_config.transitions.all():
            roles = ', '.join(transition.allowed_roles) if transition.allowed_roles else 'Any'
            comment_req = ' [Comment Required]' if transition.requires_comment else ''
            self.stdout.write(
                f'  {transition.from_state.name} → {transition.to_state.name} '
                f'(Roles: {roles}){comment_req}'
            )
        
        self.stdout.write('\nValidation Rules:')
        for rule in workflow_config.rules.all():
            self.stdout.write(f'  {rule.name}: {rule.field_path} {rule.operator} {rule.expected_value}')
        
        self.stdout.write('\n' + '='*60)
        self.stdout.write('Workflow initialization completed successfully!')
        self.stdout.write('='*60)