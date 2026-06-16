"""
Phase 2.1 — Pipeline Audit Test
Tests the full TextProcessor pipeline with intentionally bad input.
Prints RAW → PROCESSED data at every stage.
Run: python pipeline_audit.py
"""
import os, sys, django
from pathlib import Path

BACKEND_DIR = Path(__file__).parent / 'cvbuilder-backend'
sys.path.insert(0, str(BACKEND_DIR))

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.base')

from django.conf import settings
if not settings.configured:
    settings.configure(
        TEMPLATES=[{
            'BACKEND': 'django.template.backends.django.DjangoTemplates',
            'DIRS': [BACKEND_DIR / 'templates'],
            'APP_DIRS': False,
            'OPTIONS': {'context_processors': []},
        }],
        INSTALLED_APPS=[],
        LOGGING={'version': 1, 'disable_existing_loggers': False},
    )
django.setup()

sys.path.insert(0, str(BACKEND_DIR / 'apps' / 'pdf_generator'))
from text_processor import TextProcessor
from django.template.loader import render_to_string
from datetime import date

DIVIDER = "=" * 70

# ── Intentionally bad input (as specified in Phase 2.1 mission) ──────────────
class Obj:
    def __init__(self, **kw):
        for k, v in kw.items():
            setattr(self, k, v)

LEVEL_MAP = {'intermediate': 'Intermediate', 'advanced': 'Advanced', 'expert': 'Expert'}
PROFICIENCY_MAP = {'native': 'Native / Bilingual', 'professional': 'Professional'}

class Skill(Obj):
    def get_level_display(self): return LEVEL_MAP.get(self.level, self.level)
class Language(Obj):
    def get_proficiency_display(self): return PROFICIENCY_MAP.get(self.proficiency, self.proficiency)

bad_experience = Obj(
    job_title='frontend developr',
    company='tech startup',
    location='Edinbrugh',
    start_date=date(2022, 1, 1),
    end_date=None,
    is_current=True,
    description='building friendle user interface\nbuilding scalabe backend',
)
bad_education = Obj(
    degree='Honare degree',
    field_of_study='compter scince',
    institution='Kiit univeristy',
    start_year=2018,
    end_year=2022,
    is_current=False,
    gpa=3.7,
    description='',
)
bad_skill = Skill(name='javascript', level='advanced', category='technical')
bad_skill2 = Skill(name='python', level='expert', category='technical')

raw_context = {
    'full_name': 'macalin hassan',
    'email': 'macalin@gmail.com',
    'phone': '+44 7700 900 142',
    'city': 'edinburgh',
    'country': 'united kingdom',
    'summary': 'We look forward to establishing a long-term partnership with your esteemed institution.',
    'linkedin': 'linkedin.com/in/macalinhassan',
    'github': 'github.com/macalin',
    'portfolio': None,
    'photo_base64': None,
    'initials': 'MH',
    'educations': [bad_education],
    'experiences': [bad_experience],
    'skills': [bad_skill, bad_skill2],
    'technical_skills': [bad_skill, bad_skill2],
    'soft_skills': [],
    'other_skills': [],
    'languages': [Language(language='English', proficiency='native')],
    'projects': [],
    'certifications': [],
}

# ── STAGE 1: Print RAW DATA ───────────────────────────────────────────────────
print(DIVIDER)
print("STAGE 1: RAW DATA (what comes from DB)")
print(DIVIDER)
print(f"  full_name   : {raw_context['full_name']}")
print(f"  summary     : {raw_context['summary']}")
print(f"  exp[0].title: {bad_experience.job_title}")
print(f"  exp[0].desc : {bad_experience.description!r}")
print(f"  edu[0].degree     : {bad_education.degree}")
print(f"  edu[0].institution: {bad_education.institution}")
print(f"  skill[0].name     : {bad_skill.name}")
print()

# ── STAGE 2: Run TextProcessor ────────────────────────────────────────────────
print(DIVIDER)
print("STAGE 2: RUNNING TextProcessor.process()")
print(DIVIDER)
processed_context = TextProcessor(raw_context).process()
print()

# ── STAGE 3: Print PROCESSED DATA ─────────────────────────────────────────────
print(DIVIDER)
print("STAGE 3: PROCESSED DATA (after TextProcessor)")
print(DIVIDER)
proc_exp = processed_context['experiences'][0]
proc_edu = processed_context['educations'][0]
proc_skill = processed_context['technical_skills'][0]

print(f"  full_name   : {processed_context['full_name']}")
print(f"  summary     : '{processed_context['summary']}'")
print(f"  exp[0].title: {proc_exp.job_title}")
print(f"  exp[0].desc : {proc_exp.description!r}")
print(f"  edu[0].degree     : {proc_edu.degree}")
print(f"  edu[0].institution: {proc_edu.institution}")
print(f"  skill[0].name     : {proc_skill.name}")
print()

# ── STAGE 4: Verify context passed to templates ───────────────────────────────
print(DIVIDER)
print("STAGE 4: TEMPLATE DATA VERIFICATION")
print(DIVIDER)
TEMPLATES = ['classic', 'modern', 'academic']
for tpl_name in TEMPLATES:
    try:
        html = render_to_string(f'cv_templates/{tpl_name}.html', processed_context)

        # Check that RAW garbage is NOT in the HTML
        raw_fails = []
        for bad_str in ['friendle', 'scalabe', 'Honare', 'Kiit univeristy', 'long-term partnership']:
            if bad_str.lower() in html.lower():
                raw_fails.append(bad_str)

        # Check that PROCESSED good values ARE in the HTML
        proc_pass = []
        for good_str in ['Macalin Hassan', 'JavaScript']:
            if good_str in html:
                proc_pass.append(good_str)

        status_txt = "PASS" if not raw_fails else "FAIL"
        print(f"  {tpl_name.upper()}: {status_txt}")
        if raw_fails:
            print(f"    [FAIL] Raw garbage found in HTML: {raw_fails}")
        else:
            print(f"    [OK]   No raw garbage found")
        if proc_pass:
            print(f"    [OK]   Processed values confirmed: {proc_pass}")

        # Summary specific check
        if 'We look forward' in html:
            print(f"    [FAIL] Summary garbage text leaked into HTML!")
        else:
            print(f"    [OK]   Garbage summary correctly suppressed")

        # Save for manual inspection
        out = Path(__file__).parent / 'cv_previews' / f'{tpl_name}_audit.html'
        out.write_text(html, encoding='utf-8')
        print(f"    [SAVED] {out}")

    except Exception as e:
        print(f"  {tpl_name.upper()}: ERROR - {e}")
    print()

# ── STAGE 5: Final diff report ─────────────────────────────────────────────────
print(DIVIDER)
print("STAGE 5: BEFORE vs AFTER COMPARISON")
print(DIVIDER)

fields = [
    ("summary",            raw_context['summary'][:60], processed_context['summary'] or '[EMPTY - garbage suppressed]'),
    ("full_name",          raw_context['full_name'], processed_context['full_name']),
    ("experience.title",   bad_experience.job_title,  proc_exp.job_title),
    ("experience.desc[0]", raw_context['experiences'][0].description.split('\n')[0],
                           processed_context['experiences'][0].description.split('\n')[0] if processed_context['experiences'][0].description else ''),
    ("education.degree",   raw_context['educations'][0].degree, processed_context['educations'][0].degree),
    ("education.inst",     raw_context['educations'][0].institution, processed_context['educations'][0].institution),
    ("skill[0]",           'javascript', processed_context['technical_skills'][0].name),
]

for label, before, after in fields:
    changed = "[CHANGED]" if before.lower() != after.lower() else "[SAME]"
    print(f"  {label}:")
    print(f"    BEFORE: {before}")
    print(f"    AFTER : {after}  {changed}")
    print()

print(DIVIDER)
print("PIPELINE AUDIT COMPLETE")
print(DIVIDER)
