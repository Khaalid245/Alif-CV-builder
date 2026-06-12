"""
Management command: seed_role_intelligence
Seeds RoleIntelligenceConfig entries for all roles in template_engine.
Each config carries role-specific AI scoring criteria (keywords, weak patterns,
required sections, metrics). Fully data-driven — adding new roles in the DB
does not require any code changes to the application.

Usage:
    python manage.py seed_role_intelligence
    python manage.py seed_role_intelligence --clear   # wipe and re-seed
"""
import logging
from django.core.management.base import BaseCommand
from django.db import transaction

logger = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Role intelligence definitions
# Keyed by the slug of template_engine.Role
# ---------------------------------------------------------------------------
ROLE_CONFIGS = {
    'software-engineer': {
        'required_sections': ['github', 'projects', 'skills'],
        'priority_keywords': [
            'architected', 'deployed', 'scaled', 'optimized', 'engineered',
            'implemented', 'automated', 'integrated', 'refactored', 'developed'
        ],
        'role_weak_patterns': [
            'helped the team', 'assisted developers', 'worked on code',
            'was involved in development', 'participated in coding'
        ],
        'recommended_metrics': [
            'latency', 'uptime', 'throughput', 'test coverage', 'deployment frequency',
            'code reduction', 'performance improvement', 'users', 'requests per second'
        ],
        'role_specific_summary_guidance': (
            'Emphasize your tech stack, system scale, and key engineering achievements '
            'with measurable outcomes (e.g. latency, uptime, coverage).'
        ),
        'icon': 'code-2',
    },
    'product-manager': {
        'required_sections': ['linkedin'],
        'priority_keywords': [
            'launched', 'roadmapped', 'prioritized', 'stakeholder', 'OKR', 'KPI',
            'go-to-market', 'user research', 'cross-functional', 'revenue', 'retention'
        ],
        'role_weak_patterns': [
            'helped with product', 'worked on features', 'participated in planning',
            'assisted product team', 'was involved in roadmap'
        ],
        'recommended_metrics': [
            'revenue', 'retention', 'NPS', 'DAU', 'MAU', 'conversion rate',
            'time to market', 'adoption rate', 'churn', 'ARR'
        ],
        'role_specific_summary_guidance': (
            'Highlight your ability to define product vision, prioritize roadmaps, '
            'and drive measurable business outcomes (revenue, retention, growth).'
        ),
        'icon': 'briefcase',
    },
    'data-analyst': {
        'required_sections': ['skills', 'projects'],
        'priority_keywords': [
            'analyzed', 'modeled', 'visualized', 'queried', 'forecasted',
            'dashboarded', 'segmented', 'A/B tested', 'ETL', 'pipeline'
        ],
        'role_weak_patterns': [
            'helped with reports', 'worked on data', 'participated in analysis',
            'assisted the data team', 'was involved in dashboards'
        ],
        'recommended_metrics': [
            'dataset size', 'accuracy', 'precision', 'recall', 'query performance',
            'insight adoption', 'revenue impact', 'cost savings', 'model accuracy'
        ],
        'role_specific_summary_guidance': (
            'Focus on your analytical toolkit (SQL, Python, BI tools), the scale of '
            'data you work with, and the business decisions your insights have influenced.'
        ),
        'icon': 'bar-chart-2',
    },
    'ui-ux-designer': {
        'required_sections': ['portfolio', 'projects'],
        'priority_keywords': [
            'designed', 'prototyped', 'user-tested', 'wireframed', 'iterated',
            'accessibility', 'design system', 'user research', 'Figma', 'usability'
        ],
        'role_weak_patterns': [
            'helped design', 'worked on UI', 'assisted the design team',
            'participated in design reviews', 'was involved in UX'
        ],
        'recommended_metrics': [
            'task completion rate', 'error rate reduction', 'NPS improvement',
            'engagement', 'conversion rate', 'user satisfaction', 'A/B test lift'
        ],
        'role_specific_summary_guidance': (
            'Lead with your design process, tools (Figma, Adobe XD), and the user '
            'impact of your designs — reference usability improvements and business outcomes.'
        ),
        'icon': 'palette',
    },
    'business-analyst': {
        'required_sections': ['linkedin', 'skills'],
        'priority_keywords': [
            'elicited', 'documented', 'modeled', 'gap analysis', 'requirements',
            'stakeholder management', 'process improvement', 'workflow', 'ROI', 'BRD'
        ],
        'role_weak_patterns': [
            'helped gather requirements', 'worked on documentation',
            'participated in meetings', 'assisted stakeholders',
            'was involved in analysis'
        ],
        'recommended_metrics': [
            'cost reduction', 'efficiency gain', 'process time reduction',
            'ROI', 'stakeholder satisfaction', 'defect reduction', 'delivery time'
        ],
        'role_specific_summary_guidance': (
            'Emphasize your ability to bridge business and technical teams, '
            'quantify the process improvements you drove, and list your analytical tools.'
        ),
        'icon': 'git-branch',
    },
    'marketing-specialist': {
        'required_sections': ['linkedin', 'portfolio'],
        'priority_keywords': [
            'grew', 'acquired', 'optimized', 'A/B tested', 'segmented', 'launched',
            'SEO', 'content strategy', 'lead generation', 'CPC', 'ROAS'
        ],
        'role_weak_patterns': [
            'helped with marketing', 'worked on campaigns', 'participated in marketing',
            'assisted the marketing team', 'was involved in social media'
        ],
        'recommended_metrics': [
            'traffic growth', 'conversion rate', 'CAC', 'LTV', 'ROAS',
            'email open rate', 'MQL', 'impressions', 'follower growth', 'revenue'
        ],
        'role_specific_summary_guidance': (
            'Lead with your marketing channels, measurable campaign results '
            '(traffic, conversion, ROAS), and the business growth you delivered.'
        ),
        'icon': 'megaphone',
    },
}


class Command(BaseCommand):
    help = 'Seed RoleIntelligenceConfig entries for all template_engine roles'

    # Industry + Role seed data aligned with ROLE_CONFIGS above
    INDUSTRY_ROLE_MAP = {
        'Technology': [
            ('Software Engineer', 'software-engineer'),
            ('Data Analyst', 'data-analyst'),
            ('UI/UX Designer', 'ui-ux-designer'),
        ],
        'Business': [
            ('Product Manager', 'product-manager'),
            ('Business Analyst', 'business-analyst'),
            ('Marketing Specialist', 'marketing-specialist'),
        ],
    }

    def add_arguments(self, parser):
        parser.add_argument(
            '--clear',
            action='store_true',
            help='Delete all existing configs before seeding',
        )

    def handle(self, *args, **options):
        from apps.template_engine.models import Role, Industry
        from apps.cv_intelligence.models import RoleIntelligenceConfig

        if options['clear']:
            count = RoleIntelligenceConfig.objects.all().count()
            RoleIntelligenceConfig.objects.all().delete()
            self.stdout.write(self.style.WARNING(f'Cleared {count} existing configs.'))

        # Ensure Industries and Roles exist before seeding configs
        self._ensure_roles_exist(Industry, Role)

        created_count = 0
        updated_count = 0

        with transaction.atomic():
            for role_slug, config_data in ROLE_CONFIGS.items():
                # Look up the Role by slug
                try:
                    role = Role.objects.get(slug=role_slug)
                except Role.DoesNotExist:
                    self.stdout.write(
                        self.style.WARNING(
                            f'  [SKIP] Role slug "{role_slug}" not found -- run seed_templates first.'
                        )
                    )
                    continue

                obj, created = RoleIntelligenceConfig.objects.update_or_create(
                    role=role,
                    defaults={
                        'required_sections': config_data['required_sections'],
                        'priority_keywords': config_data['priority_keywords'],
                        'role_weak_patterns': config_data['role_weak_patterns'],
                        'recommended_metrics': config_data['recommended_metrics'],
                        'role_specific_summary_guidance': config_data['role_specific_summary_guidance'],
                        'icon': config_data['icon'],
                    }
                )

                if created:
                    created_count += 1
                    self.stdout.write(self.style.SUCCESS(f'  [+] Created: {role.name}'))
                else:
                    updated_count += 1
                    self.stdout.write(f'  [~] Updated: {role.name}')

        self.stdout.write(
            self.style.SUCCESS(
                f'\nDone. Created: {created_count}, Updated: {updated_count}.'
            )
        )

    def _ensure_roles_exist(self, Industry, Role):
        """Idempotently create industries and roles so seed can run standalone."""
        from django.utils.text import slugify
        for industry_name, roles in self.INDUSTRY_ROLE_MAP.items():
            industry, _ = Industry.objects.get_or_create(
                slug=slugify(industry_name),
                defaults={'name': industry_name, 'is_active': True}
            )
            for role_name, role_slug in roles:
                Role.objects.get_or_create(
                    slug=role_slug,
                    defaults={
                        'name': role_name,
                        'industry': industry,
                        'is_active': True,
                    }
                )
