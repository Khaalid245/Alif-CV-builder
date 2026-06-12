from django.core.management.base import BaseCommand
from apps.template_engine.models import Template, TemplateCategory

class Command(BaseCommand):
    help = 'Seeds initial templates for the application'

    def handle(self, *args, **kwargs):
        # Create categories
        professional_cat, _ = TemplateCategory.objects.get_or_create(
            slug='professional',
            defaults={'name': 'Professional', 'description': 'Standard professional templates'}
        )
        creative_cat, _ = TemplateCategory.objects.get_or_create(
            slug='creative',
            defaults={'name': 'Creative', 'description': 'Creative and modern templates'}
        )
        academic_cat, _ = TemplateCategory.objects.get_or_create(
            slug='academic',
            defaults={'name': 'Academic', 'description': 'Templates for academia'}
        )

        templates = [
            {
                'name': 'Modern',
                'slug': 'modern',
                'description': 'A sleek, two-column layout perfect for tech roles and creative industries.',
                'category': creative_cat,
                'layout_type': Template.Layout.TWO_COLUMN,
                'status': Template.Status.ACTIVE,
                'html_template': '<!-- modern HTML -->',
            },
            {
                'name': 'Classic',
                'slug': 'classic',
                'description': 'The traditional single-column format trusted by corporate recruiters.',
                'category': professional_cat,
                'layout_type': Template.Layout.SINGLE_COLUMN,
                'status': Template.Status.ACTIVE,
                'html_template': '<!-- classic HTML -->',
            },
            {
                'name': 'Academic',
                'slug': 'academic',
                'description': 'Comprehensive layout with extended sections for publications, research, and grants.',
                'category': academic_cat,
                'layout_type': Template.Layout.SINGLE_COLUMN,
                'status': Template.Status.ACTIVE,
                'html_template': '<!-- academic HTML -->',
            }
        ]

        for template_data in templates:
            Template.objects.get_or_create(
                slug=template_data['slug'],
                defaults=template_data
            )
        
        self.stdout.write(self.style.SUCCESS(f'Successfully seeded {len(templates)} templates'))
