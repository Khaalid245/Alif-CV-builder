"""
render_cv_preview.py
Renders all 3 CV templates (classic, modern, academic) with sample data
for macalin@gmail.com — no Django server required.

Run: python render_cv_preview.py
Output: classic_preview.html, modern_preview.html, academic_preview.html
"""

import os
import sys
import django
from pathlib import Path
from datetime import date

# ── Point Django at the backend ───────────────────────────────────────────────
BACKEND_DIR = Path(__file__).parent / 'cvbuilder-backend'
sys.path.insert(0, str(BACKEND_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')

# Minimal standalone settings — no DB, no secret, just template engine
from django.conf import settings

if not settings.configured:
    settings.configure(
        TEMPLATES=[{
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': [
                BACKEND_DIR / 'templates',
            ],
            'APP_DIRS': False,
            'OPTIONS': {
                'context_processors': [],
            },
        }],
        INSTALLED_APPS=[],
    )

django.setup()

from django.template.loader import render_to_string

# ── Sample Data for macalin@gmail.com ────────────────────────────────────────

class Obj:
    """Converts a dict to an object with attribute access + get_*_display support."""
    def __init__(self, **kwargs):
        for k, v in kwargs.items():
            setattr(self, k, v)

    def __repr__(self):
        return f"Obj({self.__dict__})"


def make_date(year, month, day):
    return date(year, month, day)


# Level display mapping
LEVEL_DISPLAY = {
    'beginner':     'Beginner',
    'intermediate': 'Intermediate',
    'advanced':     'Advanced',
    'expert':       'Expert',
}

PROFICIENCY_DISPLAY = {
    'elementary':  'Elementary',
    'conversational': 'Conversational',
    'professional': 'Professional',
    'native':      'Native / Bilingual',
}


class Skill(Obj):
    def get_level_display(self):
        return LEVEL_DISPLAY.get(self.level, self.level.title())


class Language(Obj):
    def get_proficiency_display(self):
        return PROFICIENCY_DISPLAY.get(self.proficiency, self.proficiency.title())


# Education entries
educations = [
    Obj(
        degree='Bachelor of Science',
        field_of_study='Computer Science',
        institution='University of Edinburgh',
        start_year=2018,
        end_year=2022,
        is_current=False,
        gpa=3.8,
        description=(
            'Dissertation: Machine Learning Approaches to Natural Language Understanding\n'
            'Dean\'s List — all 4 years\n'
            'President, Computer Science Society'
        ),
    ),
    Obj(
        degree='Higher National Diploma',
        field_of_study='Information Technology',
        institution='Scottish Qualifications Authority',
        start_year=2016,
        end_year=2018,
        is_current=False,
        gpa=None,
        description='',
    ),
]

# Work experience
experiences = [
    Obj(
        job_title='Senior Software Engineer',
        company='Cloudwave Technologies',
        location='Edinburgh, UK',
        start_date=make_date(2022, 8, 1),
        end_date=None,
        is_current=True,
        description=(
            'Led migration of monolithic API to microservices architecture, reducing latency by 42%\n'
            'Designed and deployed CI/CD pipelines for 6 product squads using GitHub Actions and Docker\n'
            'Mentored 3 junior engineers through biweekly 1-on-1 sessions and code reviews\n'
            'Implemented real-time data streaming pipeline processing 2M events/day with Apache Kafka'
        ),
    ),
    Obj(
        job_title='Software Engineer',
        company='FinTrack Analytics Ltd',
        location='Glasgow, UK',
        start_date=make_date(2020, 6, 1),
        end_date=make_date(2022, 7, 31),
        is_current=False,
        description=(
            'Built customer-facing financial dashboard serving 40,000 monthly active users\n'
            'Reduced database query time by 60% through query optimisation and Redis caching\n'
            'Delivered REST API integrations with 5 third-party financial data providers'
        ),
    ),
    Obj(
        job_title='Junior Developer',
        company='BrightPath Digital Agency',
        location='Edinburgh, UK',
        start_date=make_date(2018, 9, 1),
        end_date=make_date(2020, 5, 31),
        is_current=False,
        description=(
            'Developed and maintained 12 client websites using React and Node.js\n'
            'Collaborated with UX designers to implement responsive, accessible interfaces'
        ),
    ),
]

# Technical skills
technical_skills = [
    Skill(name='Python', level='expert', category='technical'),
    Skill(name='Django / Django REST Framework', level='expert', category='technical'),
    Skill(name='TypeScript / React', level='advanced', category='technical'),
    Skill(name='PostgreSQL / MySQL', level='advanced', category='technical'),
    Skill(name='Docker & Kubernetes', level='advanced', category='technical'),
    Skill(name='Apache Kafka', level='intermediate', category='technical'),
    Skill(name='AWS (EC2, S3, Lambda)', level='intermediate', category='technical'),
    Skill(name='Redis / Celery', level='advanced', category='technical'),
    Skill(name='GraphQL', level='intermediate', category='technical'),
    Skill(name='Git / GitHub Actions', level='expert', category='technical'),
    Skill(name='Machine Learning (scikit-learn, PyTorch)', level='intermediate', category='technical'),
    Skill(name='Linux / Bash scripting', level='advanced', category='technical'),
]

# Soft skills
soft_skills = [
    Skill(name='Technical Leadership', level='intermediate', category='soft'),
    Skill(name='Cross-functional Collaboration', level='intermediate', category='soft'),
    Skill(name='Agile / Scrum Methodology', level='intermediate', category='soft'),
]

# Projects
projects = [
    Obj(
        title='EduMatch — AI-Powered Job Matching Platform',
        start_date=make_date(2023, 1, 1),
        end_date=make_date(2023, 8, 31),
        description=(
            'Engineered NLP pipeline using BERT embeddings to match CVs to job descriptions with 91% accuracy\n'
            'Built FastAPI backend serving 500 concurrent requests with sub-100ms response time\n'
            'Deployed on AWS ECS with auto-scaling; handled 10K daily active users at launch'
        ),
        link='github.com/macalin/edumatch',
    ),
    Obj(
        title='OpenBudget — Personal Finance Tracker',
        start_date=make_date(2021, 3, 1),
        end_date=make_date(2021, 9, 30),
        description=(
            'Full-stack web app with React frontend and Django backend\n'
            'Integrated Open Banking API for automatic transaction categorisation\n'
            'Published on Product Hunt — 1,200 upvotes, featured in "Finance" category'
        ),
        link='openbudget.dev',
    ),
]

# Certifications
certifications = [
    Obj(
        name='AWS Certified Solutions Architect — Associate',
        issuer='Amazon Web Services',
        issue_date=make_date(2023, 4, 15),
    ),
    Obj(
        name='Professional Scrum Master I (PSM I)',
        issuer='Scrum.org',
        issue_date=make_date(2022, 11, 1),
    ),
    Obj(
        name='Google Professional Data Engineer',
        issuer='Google Cloud',
        issue_date=make_date(2024, 1, 20),
    ),
]

# Languages
languages = [
    Language(language='English', proficiency='native'),
    Language(language='French', proficiency='professional'),
    Language(language='Arabic', proficiency='conversational'),
    Language(language='Spanish', proficiency='elementary'),
]

# ── Build template context ────────────────────────────────────────────────────
context = {
    'full_name':   'Macalin Hassan',
    'email':       'macalin@gmail.com',
    'phone':       '+44 7700 900 142',
    'city':        'Edinburgh',
    'country':     'United Kingdom',
    'linkedin':    'linkedin.com/in/macalinhassan',
    'github':      'github.com/macalin',
    'portfolio':   'macalinhassan.dev',
    'summary': (
        'Senior Software Engineer with 6+ years of experience building scalable distributed systems '
        'and data-intensive applications. Proven track record of leading engineering teams and delivering '
        'high-impact products in fintech and SaaS environments. Passionate about clean architecture, '
        'developer experience, and mentoring the next generation of engineers.'
    ),
    'educations':       educations,
    'experiences':      experiences,
    'technical_skills': technical_skills,
    'soft_skills':      soft_skills,
    'other_skills':     [],
    'skills':           technical_skills + soft_skills,
    'projects':         projects,
    'certifications':   certifications,
    'languages':        languages,
    'photo_base64':     None,
    'initials':         'MH',
}

# ── Render each template ──────────────────────────────────────────────────────
OUTPUT_DIR = Path(__file__).parent / 'cv_previews'
OUTPUT_DIR.mkdir(exist_ok=True)

templates = ['classic', 'modern', 'academic']

for template_name in templates:
    try:
        html = render_to_string(f'cv_templates/{template_name}.html', context)
        out_path = OUTPUT_DIR / f'{template_name}_preview.html'
        out_path.write_text(html, encoding='utf-8')
        print(f'[OK]  {template_name.upper()} -> {out_path}')
    except Exception as e:
        print(f'[FAIL] {template_name.upper()} failed: {e}')
        import traceback
        traceback.print_exc()

print()
print(f'Preview files saved to: {OUTPUT_DIR}')
print('Opening previews in browser...')
