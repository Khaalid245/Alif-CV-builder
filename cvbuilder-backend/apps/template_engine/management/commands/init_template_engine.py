"""
Management command to initialize Template Engine with sample data.
Creates industries, roles, categories, and sample templates.
"""
from django.core.management.base import BaseCommand
from django.db import transaction
from apps.template_engine.models import (
    Industry, Role, TemplateCategory, Template, SectionConfiguration,
    BrandingConfiguration
)


class Command(BaseCommand):
    help = 'Initialize Template Engine with sample data'

    def add_arguments(self, parser):
        parser.add_argument(
            '--reset',
            action='store_true',
            help='Reset all template data before initialization',
        )

    def handle(self, *args, **options):
        if options['reset']:
            self.stdout.write('Resetting template engine data...')
            self._reset_data()

        self.stdout.write('Initializing template engine...')
        
        with transaction.atomic():
            self._create_industries()
            self._create_categories()
            self._create_sample_templates()
        
        self.stdout.write(
            self.style.SUCCESS('Template engine initialized successfully!')
        )

    def _reset_data(self):
        """Reset all template engine data."""
        Template.objects.all().delete()
        TemplateCategory.objects.all().delete()
        Role.objects.all().delete()
        Industry.objects.all().delete()

    def _create_industries(self):
        """Create sample industries and roles."""
        industries_data = [
            {
                'name': 'Technology',
                'slug': 'technology',
                'description': 'Software development, IT, and tech companies',
                'roles': [
                    {'name': 'Software Developer', 'slug': 'software-developer'},
                    {'name': 'Data Scientist', 'slug': 'data-scientist'},
                    {'name': 'DevOps Engineer', 'slug': 'devops-engineer'},
                    {'name': 'Product Manager', 'slug': 'product-manager'},
                    {'name': 'UI/UX Designer', 'slug': 'ui-ux-designer'},
                ]
            },
            {
                'name': 'Finance',
                'slug': 'finance',
                'description': 'Banking, investment, and financial services',
                'roles': [
                    {'name': 'Financial Analyst', 'slug': 'financial-analyst'},
                    {'name': 'Investment Banker', 'slug': 'investment-banker'},
                    {'name': 'Accountant', 'slug': 'accountant'},
                    {'name': 'Risk Manager', 'slug': 'risk-manager'},
                ]
            },
            {
                'name': 'Healthcare',
                'slug': 'healthcare',
                'description': 'Medical, pharmaceutical, and healthcare services',
                'roles': [
                    {'name': 'Nurse', 'slug': 'nurse'},
                    {'name': 'Medical Researcher', 'slug': 'medical-researcher'},
                    {'name': 'Healthcare Administrator', 'slug': 'healthcare-administrator'},
                ]
            },
            {
                'name': 'Education',
                'slug': 'education',
                'description': 'Academic institutions and educational services',
                'roles': [
                    {'name': 'Teacher', 'slug': 'teacher'},
                    {'name': 'Research Assistant', 'slug': 'research-assistant'},
                    {'name': 'Academic Advisor', 'slug': 'academic-advisor'},
                ]
            },
            {
                'name': 'Marketing',
                'slug': 'marketing',
                'description': 'Digital marketing, advertising, and communications',
                'roles': [
                    {'name': 'Digital Marketer', 'slug': 'digital-marketer'},
                    {'name': 'Content Creator', 'slug': 'content-creator'},
                    {'name': 'Brand Manager', 'slug': 'brand-manager'},
                ]
            }
        ]

        for industry_data in industries_data:
            industry, created = Industry.objects.get_or_create(
                slug=industry_data['slug'],
                defaults={
                    'name': industry_data['name'],
                    'description': industry_data['description']
                }
            )
            
            if created:
                self.stdout.write(f'Created industry: {industry.name}')
            
            # Create roles for this industry
            for role_data in industry_data['roles']:
                role, created = Role.objects.get_or_create(
                    slug=role_data['slug'],
                    defaults={
                        'name': role_data['name'],
                        'industry': industry
                    }
                )
                
                if created:
                    self.stdout.write(f'  Created role: {role.name}')

    def _create_categories(self):
        """Create template categories."""
        categories_data = [
            {
                'name': 'Classic',
                'slug': 'classic',
                'description': 'Traditional, professional templates for corporate environments'
            },
            {
                'name': 'Modern',
                'slug': 'modern',
                'description': 'Contemporary designs for tech and creative industries'
            },
            {
                'name': 'Academic',
                'slug': 'academic',
                'description': 'Formal templates for research and academic positions'
            },
            {
                'name': 'Creative',
                'slug': 'creative',
                'description': 'Artistic and unique designs for creative professionals'
            },
            {
                'name': 'Minimalist',
                'slug': 'minimalist',
                'description': 'Clean, simple designs focusing on content'
            }
        ]

        for category_data in categories_data:
            category, created = TemplateCategory.objects.get_or_create(
                slug=category_data['slug'],
                defaults={
                    'name': category_data['name'],
                    'description': category_data['description']
                }
            )
            
            if created:
                self.stdout.write(f'Created category: {category.name}')

    def _create_sample_templates(self):
        """Create sample templates."""
        # Get categories and industries
        classic_cat = TemplateCategory.objects.get(slug='classic')
        modern_cat = TemplateCategory.objects.get(slug='modern')
        academic_cat = TemplateCategory.objects.get(slug='academic')
        
        tech_industry = Industry.objects.get(slug='technology')
        finance_industry = Industry.objects.get(slug='finance')
        
        templates_data = [
            {
                'name': 'Professional Classic',
                'slug': 'professional-classic',
                'category': classic_cat,
                'industries': [finance_industry],
                'layout_type': Template.Layout.TWO_COLUMN,
                'description': 'Traditional two-column layout perfect for corporate positions',
                'html_template': self._get_classic_template_html(),
                'css_styles': self._get_classic_template_css(),
                'branding': {
                    'primary_color': '#2c3e50',
                    'secondary_color': '#34495e',
                    'accent_color': '#3498db',
                    'font_family': 'Georgia, serif'
                }
            },
            {
                'name': 'Modern Tech',
                'slug': 'modern-tech',
                'category': modern_cat,
                'industries': [tech_industry],
                'layout_type': Template.Layout.SINGLE_COLUMN,
                'description': 'Clean, modern design optimized for tech professionals',
                'html_template': self._get_modern_template_html(),
                'css_styles': self._get_modern_template_css(),
                'branding': {
                    'primary_color': '#2563eb',
                    'secondary_color': '#64748b',
                    'accent_color': '#0ea5e9',
                    'font_family': 'Inter, sans-serif'
                }
            },
            {
                'name': 'Academic Research',
                'slug': 'academic-research',
                'category': academic_cat,
                'industries': [],
                'layout_type': Template.Layout.SINGLE_COLUMN,
                'description': 'Formal template designed for academic and research positions',
                'html_template': self._get_academic_template_html(),
                'css_styles': self._get_academic_template_css(),
                'branding': {
                    'primary_color': '#7c2d12',
                    'secondary_color': '#a3a3a3',
                    'accent_color': '#dc2626',
                    'font_family': 'Times New Roman, serif'
                }
            }
        ]

        for template_data in templates_data:
            template, created = Template.objects.get_or_create(
                slug=template_data['slug'],
                defaults={
                    'name': template_data['name'],
                    'category': template_data['category'],
                    'layout_type': template_data['layout_type'],
                    'description': template_data['description'],
                    'html_template': template_data['html_template'],
                    'css_styles': template_data['css_styles'],
                    'status': Template.Status.ACTIVE
                }
            )
            
            if created:
                self.stdout.write(f'Created template: {template.name}')
                
                # Add industries
                template.industries.set(template_data['industries'])
                
                # Create branding configuration
                BrandingConfiguration.objects.create(
                    template=template,
                    **template_data['branding']
                )
                
                # Create standard sections
                self._create_template_sections(template)

    def _create_template_sections(self, template):
        """Create standard sections for a template."""
        sections_data = [
            {'type': SectionConfiguration.SectionType.PERSONAL_INFO, 'name': 'Personal Information', 'order': 1, 'required': True},
            {'type': SectionConfiguration.SectionType.SUMMARY, 'name': 'Professional Summary', 'order': 2, 'required': False},
            {'type': SectionConfiguration.SectionType.EDUCATION, 'name': 'Education', 'order': 3, 'required': True},
            {'type': SectionConfiguration.SectionType.EXPERIENCE, 'name': 'Work Experience', 'order': 4, 'required': True},
            {'type': SectionConfiguration.SectionType.SKILLS, 'name': 'Skills', 'order': 5, 'required': True},
            {'type': SectionConfiguration.SectionType.PROJECTS, 'name': 'Projects', 'order': 6, 'required': False},
            {'type': SectionConfiguration.SectionType.CERTIFICATIONS, 'name': 'Certifications', 'order': 7, 'required': False},
            {'type': SectionConfiguration.SectionType.LANGUAGES, 'name': 'Languages', 'order': 8, 'required': False},
        ]

        for section_data in sections_data:
            SectionConfiguration.objects.create(
                template=template,
                section_type=section_data['type'],
                display_name=section_data['name'],
                order=section_data['order'],
                is_required=section_data['required'],
                is_visible=True
            )

    def _get_classic_template_html(self):
        """Get HTML for classic template."""
        return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{ cv.student.first_name }} {{ cv.student.last_name }} - CV</title>
    <style>{{ template.css_styles }}</style>
</head>
<body>
    <div class="cv-container">
        <div class="sidebar">
            <div class="personal-info">
                <h1>{{ cv.student.first_name }} {{ cv.student.last_name }}</h1>
                <div class="contact">
                    <p>{{ cv.phone }}</p>
                    <p>{{ cv.student.email }}</p>
                    <p>{{ cv.city }}, {{ cv.country }}</p>
                </div>
            </div>
            
            <div class="section">
                <h2>Skills</h2>
                {% for skill in cv.skills.all %}
                <div class="skill-item">
                    <span class="skill-name">{{ skill.name }}</span>
                    <span class="skill-level">{{ skill.level }}</span>
                </div>
                {% endfor %}
            </div>
            
            <div class="section">
                <h2>Languages</h2>
                {% for language in cv.languages.all %}
                <div class="language-item">
                    <span>{{ language.language }} - {{ language.proficiency }}</span>
                </div>
                {% endfor %}
            </div>
        </div>
        
        <div class="main-content">
            {% if cv.summary %}
            <div class="section">
                <h2>Professional Summary</h2>
                <p>{{ cv.summary }}</p>
            </div>
            {% endif %}
            
            <div class="section">
                <h2>Education</h2>
                {% for education in cv.educations.all %}
                <div class="education-item">
                    <h3>{{ education.degree }} in {{ education.field_of_study }}</h3>
                    <p class="institution">{{ education.institution }}</p>
                    <p class="dates">{{ education.start_year }} - {% if education.is_current %}Present{% else %}{{ education.end_year }}{% endif %}</p>
                    {% if education.description %}
                    <p class="description">{{ education.description }}</p>
                    {% endif %}
                </div>
                {% endfor %}
            </div>
            
            <div class="section">
                <h2>Work Experience</h2>
                {% for experience in cv.experiences.all %}
                <div class="experience-item">
                    <h3>{{ experience.job_title }}</h3>
                    <p class="company">{{ experience.company }}</p>
                    <p class="dates">{{ experience.start_date|date:"M Y" }} - {% if experience.is_current %}Present{% else %}{{ experience.end_date|date:"M Y" }}{% endif %}</p>
                    {% if experience.description %}
                    <p class="description">{{ experience.description }}</p>
                    {% endif %}
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
</body>
</html>
        '''

    def _get_classic_template_css(self):
        """Get CSS for classic template."""
        return '''
body {
    font-family: {{ branding.font_family }};
    margin: 0;
    padding: 20px;
    color: {{ branding.text_color }};
    background-color: {{ branding.background_color }};
}

.cv-container {
    display: flex;
    max-width: 210mm;
    margin: 0 auto;
    background: white;
    box-shadow: 0 0 10px rgba(0,0,0,0.1);
}

.sidebar {
    width: 35%;
    background-color: {{ branding.primary_color }};
    color: white;
    padding: 30px 20px;
}

.main-content {
    width: 65%;
    padding: 30px;
}

h1 {
    font-size: 24px;
    margin-bottom: 10px;
    font-weight: bold;
}

h2 {
    color: {{ branding.primary_color }};
    border-bottom: 2px solid {{ branding.accent_color }};
    padding-bottom: 5px;
    margin-bottom: 15px;
}

.sidebar h2 {
    color: white;
    border-bottom-color: white;
}

.section {
    margin-bottom: 25px;
}

.skill-item, .language-item {
    margin-bottom: 8px;
}

.education-item, .experience-item {
    margin-bottom: 20px;
}

.institution, .company {
    font-weight: bold;
    color: {{ branding.secondary_color }};
}

.dates {
    font-style: italic;
    color: {{ branding.secondary_color }};
    margin-bottom: 5px;
}
        '''

    def _get_modern_template_html(self):
        """Get HTML for modern template."""
        return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{ cv.student.first_name }} {{ cv.student.last_name }} - CV</title>
    <style>{{ template.css_styles }}</style>
</head>
<body>
    <div class="cv-container">
        <header class="header">
            <h1>{{ cv.student.first_name }} {{ cv.student.last_name }}</h1>
            <div class="contact-info">
                <span>{{ cv.student.email }}</span>
                <span>{{ cv.phone }}</span>
                <span>{{ cv.city }}, {{ cv.country }}</span>
            </div>
        </header>
        
        {% if cv.summary %}
        <section class="summary">
            <h2>About Me</h2>
            <p>{{ cv.summary }}</p>
        </section>
        {% endif %}
        
        <section class="experience">
            <h2>Experience</h2>
            {% for experience in cv.experiences.all %}
            <div class="experience-item">
                <div class="item-header">
                    <h3>{{ experience.job_title }}</h3>
                    <span class="dates">{{ experience.start_date|date:"M Y" }} - {% if experience.is_current %}Present{% else %}{{ experience.end_date|date:"M Y" }}{% endif %}</span>
                </div>
                <p class="company">{{ experience.company }}</p>
                {% if experience.description %}
                <p class="description">{{ experience.description }}</p>
                {% endif %}
            </div>
            {% endfor %}
        </section>
        
        <section class="education">
            <h2>Education</h2>
            {% for education in cv.educations.all %}
            <div class="education-item">
                <div class="item-header">
                    <h3>{{ education.degree }}</h3>
                    <span class="dates">{{ education.start_year }} - {% if education.is_current %}Present{% else %}{{ education.end_year }}{% endif %}</span>
                </div>
                <p class="institution">{{ education.institution }}</p>
            </div>
            {% endfor %}
        </section>
        
        <div class="skills-languages">
            <section class="skills">
                <h2>Skills</h2>
                <div class="skills-grid">
                    {% for skill in cv.skills.all %}
                    <span class="skill-tag">{{ skill.name }}</span>
                    {% endfor %}
                </div>
            </section>
            
            {% if cv.languages.all %}
            <section class="languages">
                <h2>Languages</h2>
                {% for language in cv.languages.all %}
                <div class="language-item">{{ language.language }} ({{ language.proficiency }})</div>
                {% endfor %}
            </section>
            {% endif %}
        </div>
    </div>
</body>
</html>
        '''

    def _get_modern_template_css(self):
        """Get CSS for modern template."""
        return '''
body {
    font-family: {{ branding.font_family }};
    margin: 0;
    padding: 20px;
    color: {{ branding.text_color }};
    background-color: #f8fafc;
}

.cv-container {
    max-width: 210mm;
    margin: 0 auto;
    background: white;
    border-radius: 8px;
    overflow: hidden;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
}

.header {
    background: linear-gradient(135deg, {{ branding.primary_color }}, {{ branding.accent_color }});
    color: white;
    padding: 40px 30px;
    text-align: center;
}

.header h1 {
    font-size: 32px;
    margin: 0 0 10px 0;
    font-weight: 300;
}

.contact-info {
    display: flex;
    justify-content: center;
    gap: 20px;
    flex-wrap: wrap;
}

section {
    padding: 30px;
    border-bottom: 1px solid #e2e8f0;
}

section:last-child {
    border-bottom: none;
}

h2 {
    color: {{ branding.primary_color }};
    font-size: 20px;
    margin-bottom: 20px;
    font-weight: 600;
}

.item-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-bottom: 5px;
}

.dates {
    color: {{ branding.secondary_color }};
    font-size: 14px;
}

.company, .institution {
    color: {{ branding.accent_color }};
    font-weight: 500;
    margin-bottom: 10px;
}

.skills-grid {
    display: flex;
    flex-wrap: wrap;
    gap: 8px;
}

.skill-tag {
    background: {{ branding.primary_color }};
    color: white;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 14px;
}

.skills-languages {
    display: grid;
    grid-template-columns: 1fr 1fr;
    gap: 30px;
}
        '''

    def _get_academic_template_html(self):
        """Get HTML for academic template."""
        return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>{{ cv.student.first_name }} {{ cv.student.last_name }} - Curriculum Vitae</title>
    <style>{{ template.css_styles }}</style>
</head>
<body>
    <div class="cv-container">
        <header class="header">
            <h1>{{ cv.student.first_name }} {{ cv.student.last_name }}</h1>
            <div class="contact">
                <p>{{ cv.student.email }} | {{ cv.phone }}</p>
                <p>{{ cv.address }}, {{ cv.city }}, {{ cv.country }}</p>
            </div>
        </header>
        
        {% if cv.summary %}
        <section>
            <h2>Research Interests</h2>
            <p>{{ cv.summary }}</p>
        </section>
        {% endif %}
        
        <section>
            <h2>Education</h2>
            {% for education in cv.educations.all %}
            <div class="entry">
                <div class="entry-header">
                    <strong>{{ education.degree }} in {{ education.field_of_study }}</strong>
                    <span class="year">{{ education.start_year }}{% if not education.is_current %} - {{ education.end_year }}{% endif %}</span>
                </div>
                <p class="institution">{{ education.institution }}</p>
                {% if education.gpa %}
                <p>GPA: {{ education.gpa }}</p>
                {% endif %}
                {% if education.description %}
                <p>{{ education.description }}</p>
                {% endif %}
            </div>
            {% endfor %}
        </section>
        
        <section>
            <h2>Research Experience</h2>
            {% for experience in cv.experiences.all %}
            <div class="entry">
                <div class="entry-header">
                    <strong>{{ experience.job_title }}</strong>
                    <span class="year">{{ experience.start_date|date:"Y" }}{% if not experience.is_current %} - {{ experience.end_date|date:"Y" }}{% endif %}</span>
                </div>
                <p class="institution">{{ experience.company }}</p>
                {% if experience.description %}
                <p>{{ experience.description }}</p>
                {% endif %}
            </div>
            {% endfor %}
        </section>
        
        {% if cv.projects.all %}
        <section>
            <h2>Publications & Projects</h2>
            {% for project in cv.projects.all %}
            <div class="entry">
                <strong>{{ project.title }}</strong>
                {% if project.description %}
                <p>{{ project.description }}</p>
                {% endif %}
            </div>
            {% endfor %}
        </section>
        {% endif %}
        
        <section>
            <h2>Skills & Competencies</h2>
            <div class="skills-list">
                {% for skill in cv.skills.all %}
                <span>{{ skill.name }}</span>{% if not forloop.last %}, {% endif %}
                {% endfor %}
            </div>
        </section>
    </div>
</body>
</html>
        '''

    def _get_academic_template_css(self):
        """Get CSS for academic template."""
        return '''
body {
    font-family: {{ branding.font_family }};
    margin: 0;
    padding: 40px;
    color: {{ branding.text_color }};
    line-height: 1.6;
}

.cv-container {
    max-width: 210mm;
    margin: 0 auto;
}

.header {
    text-align: center;
    border-bottom: 3px solid {{ branding.primary_color }};
    padding-bottom: 20px;
    margin-bottom: 30px;
}

.header h1 {
    font-size: 28px;
    margin: 0 0 10px 0;
    color: {{ branding.primary_color }};
}

section {
    margin-bottom: 30px;
}

h2 {
    color: {{ branding.primary_color }};
    font-size: 18px;
    margin-bottom: 15px;
    text-transform: uppercase;
    letter-spacing: 1px;
    border-bottom: 1px solid {{ branding.secondary_color }};
    padding-bottom: 5px;
}

.entry {
    margin-bottom: 20px;
}

.entry-header {
    display: flex;
    justify-content: space-between;
    align-items: baseline;
    margin-bottom: 5px;
}

.year {
    color: {{ branding.secondary_color }};
    font-weight: normal;
}

.institution {
    font-style: italic;
    color: {{ branding.secondary_color }};
    margin-bottom: 5px;
}

.skills-list {
    text-align: justify;
}
        '''