"""
Phase 2 Verification Tests - Fixed
Uses types.SimpleNamespace instead of MagicMock so Django template
variable resolution uses attribute lookup (not __getitem__).
Run: python -X utf8 test_phase2.py
"""
import os
import sys
from types import SimpleNamespace
from datetime import date

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings')

import django
django.setup()

from django.template.loader import render_to_string
from django.utils import timezone

PASS = '[PASS]'
FAIL = '[FAIL]'
results = []

# ── Fixture Helpers ───────────────────────────────────────────────────────────

def make_skill(name, level='intermediate', category='technical'):
    return SimpleNamespace(
        name=name, level=level, category=category,
        get_level_display=lambda: level.capitalize()
    )

def make_exp(title, company, location='', desc='', is_current=False):
    return SimpleNamespace(
        job_title=title, company=company, location=location,
        description=desc,
        start_date=date(2022, 1, 1),
        end_date=date(2023, 6, 1) if not is_current else None,
        is_current=is_current,
    )

def make_edu(degree, field, institution, start=2018, end=2022, gpa=None, desc=''):
    return SimpleNamespace(
        degree=degree, field_of_study=field, institution=institution,
        start_year=start, end_year=end, is_current=False,
        gpa=gpa, description=desc,
    )

def make_lang(language, proficiency='professional'):
    return SimpleNamespace(
        language=language, proficiency=proficiency,
        get_proficiency_display=lambda: proficiency.capitalize()
    )

def make_cert(name, issuer, year=2023):
    return SimpleNamespace(
        name=name, issuer=issuer,
        issue_date=date(year, 6, 1),
    )

def make_proj(title, desc='', link=''):
    return SimpleNamespace(
        title=title, description=desc, link=link,
        start_date=date(2023, 1, 1),
        end_date=date(2023, 12, 1),
    )

def render(tpl, ctx):
    return render_to_string(f'cv_templates/{tpl}.html', ctx)

TEMPLATES = ['classic', 'modern', 'academic']

# ──────────────────────────────────────────────────────────────────────────────
# TEST 1 — Dense content
# ──────────────────────────────────────────────────────────────────────────────
print('\n-- Test 1: Dense content (5 exp / 3 edu / 15 skills / 4 langs) ----------')
technical = [make_skill(f'Python Framework {i}', 'advanced') for i in range(10)]
soft      = [make_skill(f'Leadership Skill {i}', 'intermediate', 'soft') for i in range(5)]

ctx1 = {
    'full_name': 'Ahmed Al-Rashid',
    'email': 'ahmed@example.com',
    'phone': '+971 50 123 4567',
    'city': 'Dubai', 'country': 'UAE',
    'linkedin': 'linkedin.com/in/ahmed',
    'github': 'github.com/ahmed',
    'portfolio': '',
    'summary': 'Experienced software engineer with 5 years in full-stack development.',
    'photo_base64': None, 'initials': 'AA',
    'educations': [
        make_edu('Bachelor of Science', 'Computer Science', 'King Abdulaziz University', 2015, 2019, 3.8),
        make_edu('Master of Science', 'Artificial Intelligence', 'American University of Sharjah', 2019, 2021),
        make_edu('Diploma', 'Data Analytics', 'Dubai Institute of Technology', 2021, 2022),
    ],
    'experiences': [
        make_exp('Senior Software Engineer', 'Microsoft Gulf', 'Dubai, UAE',
                 'Led a team of 8 engineers\nDelivered 3 major features\nReduced latency by 40%', True),
        make_exp('Software Engineer', 'Amazon Web Services', 'Riyadh, KSA',
                 'Built microservices architecture\nDeveloped RESTful APIs'),
        make_exp('Junior Developer', 'Noon.com', 'Dubai, UAE', 'Maintained frontend components'),
        make_exp('Intern', 'Careem', 'Dubai, UAE', 'Supported backend team'),
        make_exp('Freelance Developer', 'Self-employed', 'Remote', 'Delivered 12 web projects'),
    ],
    'skills': technical + soft,
    'technical_skills': technical,
    'soft_skills': soft,
    'other_skills': [],
    'languages': [
        make_lang('Arabic', 'native'), make_lang('English', 'professional'),
        make_lang('French', 'conversational'), make_lang('German', 'basic'),
    ],
    'projects': [make_proj('EduCV Platform', 'Full-stack resume builder\nBuilt with Django and Flutter')],
    'certifications': [make_cert('AWS Solutions Architect', 'Amazon', 2023)],
    'generated_at': timezone.now(),
}

for tpl in TEMPLATES:
    try:
        html = render(tpl, ctx1)
        # Verify key content is actually rendered (not mock repr)
        assert 'Ahmed Al-Rashid' in html, 'Full name not rendered'
        assert 'King Abdulaziz University' in html, 'Institution not rendered'
        assert 'Microsoft Gulf' in html, 'Company not rendered'
        assert len(html) > 3000, f'HTML suspiciously short: {len(html)} chars'
        print(f'  {PASS}  {tpl}.html rendered correctly ({len(html):,} chars)')
        results.append(True)
    except Exception as e:
        print(f'  {FAIL}  {tpl}.html: {e}')
        results.append(False)

# ──────────────────────────────────────────────────────────────────────────────
# TEST 2 — Long text (overflow test)
# ──────────────────────────────────────────────────────────────────────────────
print('\n-- Test 2: Long text -- no overflow -------------------------------------')
ctx2 = dict(ctx1)
ctx2['full_name'] = 'Muhammad Ibn Abdullah Al-Mahmoud Al-Rashidi Al-Farouqi'
ctx2['educations'] = [
    make_edu(
        'Doctor of Philosophy',
        'Advanced Distributed Systems and Cloud Computing Architecture',
        'Massachusetts Institute of Technology School of Engineering',
        2015, 2021, 3.95,
        'Dissertation on distributed consensus algorithms.'
    )
]
ctx2['experiences'] = [
    make_exp(
        'Principal Software Architect and Engineering Lead',
        'International Business Machines Corporation',
        'San Francisco Bay Area California United States of America',
        'Architected large-scale distributed systems\nLed global engineering teams across 12 countries'
    )
]

for tpl in TEMPLATES:
    try:
        html = render(tpl, ctx2)
        assert 'Massachusetts Institute of Technology' in html, 'Long institution name missing from HTML'
        assert 'International Business Machines Corporation' in html, 'Long company name missing from HTML'
        print(f'  {PASS}  {tpl}.html -- long text present and not clipped')
        results.append(True)
    except AssertionError as e:
        print(f'  {FAIL}  {tpl}.html: {e}')
        results.append(False)
    except Exception as e:
        print(f'  {FAIL}  {tpl}.html exception: {e}')
        results.append(False)

# ──────────────────────────────────────────────────────────────────────────────
# TEST 3 — Sparse content (no exp / no projects / no certs)
# ──────────────────────────────────────────────────────────────────────────────
print('\n-- Test 3: Sparse content -- no empty sections --------------------------')
ctx3 = {
    'full_name': 'Sara Ahmed',
    'email': 'sara@example.com',
    'phone': '', 'city': 'Cairo', 'country': 'Egypt',
    'linkedin': '', 'github': '', 'portfolio': '',
    'summary': '',
    'photo_base64': None, 'initials': 'SA',
    'educations': [make_edu('Bachelor of Arts', 'English Literature', 'Cairo University', 2019, 2023)],
    'experiences': [],
    'skills': [], 'technical_skills': [], 'soft_skills': [], 'other_skills': [],
    'languages': [make_lang('Arabic', 'native')],
    'projects': [],
    'certifications': [],
    'generated_at': timezone.now(),
}

GHOST_SECTIONS = [
    ('Work Experience',        'Work Experience section should be hidden'),
    ('section-title">Projects','Projects section should be hidden'),
    ('Certifications',         'Certifications section should be hidden'),
    ('Personal Profile',       'Empty summary section should be hidden'),
    ('Professional Summary',   'Empty summary section should be hidden'),
    ('Key Skills',             'Empty skills section should be hidden'),
    ('Technical Skills',       'Empty skills section should be hidden'),
]

for tpl in TEMPLATES:
    try:
        html = render(tpl, ctx3)
        # Confirm the student's name IS there
        assert 'Sara Ahmed' in html, 'Name missing -- template may have failed silently'
        # Confirm empty sections are NOT there
        ghosts = [(label, msg) for label, msg in GHOST_SECTIONS if label in html]
        if ghosts:
            print(f'  {FAIL}  {tpl}.html -- ghost sections: {[g[1] for g in ghosts]}')
            results.append(False)
        else:
            print(f'  {PASS}  {tpl}.html -- no empty sections visible')
            results.append(True)
    except Exception as e:
        print(f'  {FAIL}  {tpl}.html: {e}')
        results.append(False)

# ──────────────────────────────────────────────────────────────────────────────
# TEST 4 — Design token + template inheritance verification
# ──────────────────────────────────────────────────────────────────────────────
print('\n-- Test 4: Design system & template inheritance -------------------------')

# These strings exist ONLY in base_cv.html — if they appear in rendered
# child templates, it proves {% extends %} is working correctly.
BASE_MARKERS = [
    '<!DOCTYPE html>',   # base structure
    '--sp-1',            # spacing token
    '--fs-name',         # typography token
    '--color-primary',   # color token
    'word-break: break-word',  # PDF-safe rule
    'page-break-inside: avoid',  # PDF-safe rule
    'entry-header',      # shared CSS class
]

for tpl in TEMPLATES:
    try:
        html = render(tpl, ctx1)
        missing = [m for m in BASE_MARKERS if m not in html]
        if missing:
            print(f'  {FAIL}  {tpl}.html -- base markers missing: {missing}')
            # Debug: show a slice of the HTML
            print(f'         HTML snippet (first 300 chars): {html[:300]!r}')
            results.append(False)
        else:
            print(f'  {PASS}  {tpl}.html -- design system inherited correctly')
            results.append(True)
    except Exception as e:
        print(f'  {FAIL}  {tpl}.html exception: {e}')
        results.append(False)

# ──────────────────────────────────────────────────────────────────────────────
# SUMMARY
# ──────────────────────────────────────────────────────────────────────────────
total  = len(results)
passed = sum(results)
failed = total - passed
print(f'\n{"=" * 56}')
print(f'  Results: {passed}/{total} passed  |  {failed} failed')
print(f'{"=" * 56}')
sys.exit(0 if failed == 0 else 1)
