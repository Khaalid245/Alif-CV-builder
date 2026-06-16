"""
TextProcessor — Phase 1 Resume Data Quality Engine.

Sits between CVGenerationService._fetch_student_data() and the template
renderer.  Receives the raw context dict and returns a cleaned version.

Design principles:
  - Pure Python, zero external dependencies.
  - Each transformation is a small, testable method.
  - Never modifies original DB data — only the in-memory render context.
  - Preserves existing ML layer (sentence-transformers) — no conflict.
"""
import re
import logging
from typing import Any

logger = logging.getLogger(__name__)


# ── Spell Correction Dictionary ───────────────────────────────────────────────
# Maps common student typos to correct spellings.
# Keys are lowercase. Applied before title-casing so order doesn't matter.
SPELL_FIXES = {
    # Common adjective typos
    'friendle':     'friendly',
    'freindly':     'friendly',
    'scalabe':      'scalable',
    'scaleble':     'scalable',
    'responsibe':   'responsive',
    'responisble':  'responsible',
    'managable':    'manageable',
    'flexibe':      'flexible',
    'flexiable':    'flexible',
    'realiable':    'reliable',
    'reliabe':      'reliable',
    'efficent':     'efficient',
    'effecient':    'efficient',
    'effeicient':   'efficient',
    'proficent':    'proficient',
    'developement': 'development',
    'develpment':   'development',
    'implmentation':'implementation',
    'implemantation':'implementation',
    'mantainance':  'maintenance',
    'maintenace':   'maintenance',
    'maintenence':  'maintenance',
    'intergration': 'integration',
    'integartion':  'integration',
    'colaboration': 'collaboration',
    'colaborate':   'collaborate',
    'comunication': 'communication',
    'communcation': 'communication',
    'knowlege':     'knowledge',
    'knoweldge':    'knowledge',
    'expereince':   'experience',
    'expericence':  'experience',
    # Degree typos
    'honare':       'honors',
    'honar':        'honors',
    'bachleors':    'bachelor\'s',
    'bacheors':     'bachelor\'s',
    'bacherlors':   'bachelor\'s',
    'masteres':     'master\'s',
    'mastes':       'master\'s',
    'doctorete':    'doctorate',
    'doctorat':     'doctorate',
    # Common word typos
    'univeristy':   'university',
    'univesity':    'university',
    'univercity':   'university',
    'universty':    'university',
    'institue':     'institute',
    'institiute':   'institute',
    'colege':       'college',
    'collage':      'college',
    'developr':     'developer',
    'devloper':     'developer',
    'develper':     'developer',
    'manger':       'manager',
    'managment':    'management',
    'enginere':     'engineer',
    'engieer':      'engineer',
    'analitcs':     'analytics',
    'analitics':    'analytics',
    'architecure':  'architecture',
    'architeture':  'architecture',
    'compter':      'computer',
    'scinece':      'science',
    'scince':       'science',
    'sceince':      'science',
    'buisness':     'business',
    'bussiness':    'business',
    # Tech terms (proper casing)
    'javascript':   'JavaScript',
    'typescript':   'TypeScript',
    'nodejs':       'Node.js',
    'node.js':      'Node.js',
    'reactjs':      'React.js',
    'vuejs':        'Vue.js',
    'angularjs':    'AngularJS',
    'mongodb':      'MongoDB',
    'postgresql':   'PostgreSQL',
    'mysql':        'MySQL',
    'sqlite':       'SQLite',
    'graphql':      'GraphQL',
    'restapi':      'REST API',
    'github':       'GitHub',
    'gitlab':       'GitLab',
    'bitbucket':    'Bitbucket',
    'tensorflow':   'TensorFlow',
    'pytorch':      'PyTorch',
    'scikit-learn': 'Scikit-learn',
    'scikit learn': 'Scikit-learn',
    'opencv':       'OpenCV',
    'flutter':      'Flutter',
    'django':       'Django',
    'flask':        'Flask',
    'fastapi':      'FastAPI',
    'kubernetes':   'Kubernetes',
    'docker':       'Docker',
    'aws':          'AWS',
    'gcp':          'GCP',
    'azure':        'Azure',
    'devops':       'DevOps',
    'cicd':         'CI/CD',
    'ci/cd':        'CI/CD',
    'ui/ux':        'UI/UX',
    'uiux':         'UI/UX',
    'html/css':     'HTML/CSS',
    'html':         'HTML',
    'css':          'CSS',
    'api':          'API',
    'apis':         'APIs',
    'restful':      'RESTful',
    'sql':          'SQL',
    'nosql':        'NoSQL',
    'ai':           'AI',
    'ml':           'ML',
    'oop':          'OOP',
}

# ── Location Normalization Map ────────────────────────────────────────────────
# Maps common location misspellings or shorthand to full professional locations.
LOCATION_FIXES = {
    'mogadisho': 'Mogadishu, Somalia',
    'amercan': 'American Company',
}

# ── Professional Wording Map ───────────────────────────────────────────────────
# Maps informal / weak phrases to strong professional equivalents.
# Matched case-insensitively, replaced with the professional version.
WORDING_MAP = [
    # Verb upgrades for experience descriptions
    (r'\bbuild\s+api\b',            'Developed RESTful APIs using modern backend technologies'),
    (r'\bbuild\s+apis?\b',          'Developed RESTful APIs using modern backend technologies'),
    (r'\bbuild\s+backend\b',        'Developed scalable backend services and REST APIs'),
    (r'\bbuild\s+frontend\b',       'Built responsive frontend interfaces using modern web technologies'),
    (r'\bbuild\s+(?:the\s+)?(?:website|web\s+app|web\s+application)\b',
                                    'Developed and deployed a full-stack web application'),
    (r'\bmade\s+(?:a\s+)?(?:website|web\s+app)\b',
                                    'Developed and launched a responsive web application'),
    (r'\bworked\s+on\b',            'Contributed to'),
    (r'\bhelped\s+(?:with\s+)?(?:the\s+)?development\b',
                                    'Actively contributed to the development'),
    (r'\bdid\s+(?:the\s+)?testing\b',
                                    'Conducted systematic testing and quality assurance'),
    (r'\bdid\s+(?:the\s+)?code\b',  'Designed and implemented'),
    (r'\bwrite\s+code\b',           'Engineered software solutions'),
    (r'\bwrote\s+code\b',           'Engineered software solutions'),
    (r'\bmade\s+(?:an?\s+)?(?:app|application|mobile\s+app)\b',
                                    'Designed and developed a cross-platform mobile application'),
    (r'\bused\s+(?:django|flask|fastapi)\b',
                                    'Leveraged Django/Flask REST framework'),
    (r'\bfix(?:ed)?\s+bug(?:s)?\b', 'Identified and resolved critical software defects'),
    (r'\bdeploy(?:ed)?\b',          'Deployed and maintained'),
    (r'\bmanage(?:d)?\s+(?:the\s+)?(?:team|group)\b',
                                    'Led and coordinated a cross-functional team'),
    # Partnership text that should not appear in a resume summary
    (r'\bwe\s+look\s+forward\s+to\s+establishing\b',
                                    'Experienced professional seeking'),
    (r'\blong.term\s+partnership\b','career opportunities in a dynamic organization'),
    (r'\bour\s+(?:company|organization|team)\b',
                                    'the organization'),
]

# ── Title Case Exceptions ─────────────────────────────────────────────────────
# These words stay lowercase when in the middle of a title.
_LOWERCASE_WORDS = frozenset({
    'a', 'an', 'the', 'and', 'but', 'or', 'nor', 'for', 'so', 'yet',
    'at', 'by', 'in', 'of', 'on', 'to', 'up', 'as', 'if',
    'with', 'into', 'over', 'than', 'from', 'via',
})

# ── Skill Brand Name Map ──────────────────────────────────────────────────────
# Ensures specific skill names are rendered with correct casing.
SKILL_BRANDS = {k: v for k, v in SPELL_FIXES.items()
                if any(c.isupper() for c in v)}


class TextProcessor:
    """
    Cleans and professionalizes all text in the CV render context.

    Usage:
        context = TextProcessor(raw_context).process()
    """

    def __init__(self, context: dict):
        self._ctx = dict(context)  # work on a copy — never mutate original

    # ── Public Entry Point ────────────────────────────────────────────────────

    def process(self) -> dict:
        """
        Runs the full normalization pipeline on the context dict.
        Returns the cleaned context ready for template rendering.
        """
        try:
            self._process_summary()
            self._process_experiences()
            self._process_educations()
            self._process_skills()
            self._process_projects()
            self._process_name_fields()
        except Exception as exc:
            # Never let the processor crash PDF generation.
            # Log the error and return the original context.
            logger.warning('TextProcessor failed, falling back to raw context: %s', exc)
            return self._ctx

        return self._ctx

    # ── Section Processors ────────────────────────────────────────────────────

    # ── Non-resume / garbage summary patterns ─────────────────────────────────
    # These phrases indicate the summary field contains company marketing text,
    # AI boilerplate, or template text — not a real professional summary.
    _GARBAGE_SUMMARY_PATTERNS = [
        r'\blong.term\s+partnership\b',
        r'\bwe\s+look\s+forward\s+to\b',
        r'\byour\s+company\b',
        r'\bour\s+company\b',
        r'\bpartnership\s+with\b',
        r'\bestablishing\s+a\b.*\bpartnership\b',
        r'\bproposes\b',
        r'chatgpt\.com',
        r'\bplaceholder\b',
        r'\blorem\s+ipsum\b',
    ]

    def _process_summary(self):
        """Clean the professional summary field."""
        summary = self._ctx.get('summary', '')
        if not summary:
            return

        # Step 1 — reject garbage text BEFORE any transformation
        for pattern in self._GARBAGE_SUMMARY_PATTERNS:
            if re.search(pattern, summary, re.IGNORECASE):
                self._ctx['summary'] = ''
                return

        # Step 2 — normalize
        summary = self._apply_spell_fixes(summary)
        summary = self._apply_wording_map(summary)
        summary = self._clean_sentence(summary)
        self._ctx['summary'] = summary

    def _process_experiences(self):
        """Clean job titles and experience descriptions."""
        for exp in self._ctx.get('experiences', []):
            if hasattr(exp, 'job_title') and exp.job_title:
                exp.job_title = self._smart_title_case(
                    self._apply_spell_fixes(exp.job_title)
                )
            if hasattr(exp, 'company') and exp.company:
                exp.company = self._smart_title_case(
                    self._apply_spell_fixes(exp.company)
                )
            if hasattr(exp, 'location') and exp.location:
                exp.location = self._normalize_location(exp.location)
            if hasattr(exp, 'description') and exp.description:
                exp.description = self._process_description(exp.description)

    def _process_educations(self):
        """Clean degree names and descriptions."""
        for edu in self._ctx.get('educations', []):
            if hasattr(edu, 'degree') and edu.degree:
                edu.degree = self._smart_title_case(
                    self._apply_spell_fixes(edu.degree)
                )
            if hasattr(edu, 'field_of_study') and edu.field_of_study:
                edu.field_of_study = self._smart_title_case(
                    self._apply_spell_fixes(edu.field_of_study)
                )
            if hasattr(edu, 'institution') and edu.institution:
                edu.institution = self._smart_title_case(
                    self._apply_spell_fixes(edu.institution)
                )
            if hasattr(edu, 'description') and edu.description:
                edu.description = self._process_description(edu.description)

    def _process_skills(self):
        """Normalize skill names and add formatted_skills list for templates."""
        skills = self._ctx.get('skills', [])
        for skill in skills:
            if hasattr(skill, 'name') and skill.name:
                cleaned = self._normalize_skill_name(skill.name)
                skill.name = cleaned

        # Rebuild grouped skills after cleaning
        self._ctx['technical_skills'] = [
            s for s in skills if s.category == 'technical'
        ]
        self._ctx['soft_skills'] = [
            s for s in skills if s.category == 'soft'
        ]
        self._ctx['other_skills'] = [
            s for s in skills if s.category not in ('technical', 'soft')
        ]

    def _process_projects(self):
        """Clean project titles and descriptions."""
        for proj in self._ctx.get('projects', []):
            if hasattr(proj, 'title') and proj.title:
                proj.title = self._smart_title_case(
                    self._apply_spell_fixes(proj.title)
                )
            if hasattr(proj, 'description') and proj.description:
                proj.description = self._process_description(proj.description)

    def _process_name_fields(self):
        """Capitalize name and normalize city/country."""
        if self._ctx.get('full_name'):
            self._ctx['full_name'] = self._smart_title_case(self._ctx['full_name'])
        if self._ctx.get('city'):
            self._ctx['city'] = self._normalize_location(self._ctx['city'])
        if self._ctx.get('country'):
            self._ctx['country'] = self._normalize_location(self._ctx['country'])

    # ── Text Transformation Helpers ───────────────────────────────────────────

    def _process_description(self, text: str) -> str:
        """
        Full pipeline for multi-line description fields (experience, project).
        """
        # Step 1: Reject garbage text blocks
        for pattern in self._GARBAGE_SUMMARY_PATTERNS:
            if re.search(pattern, text, re.IGNORECASE):
                return ''
                
        text = self._apply_spell_fixes(text)
        text = self._apply_wording_map(text)
        # Process line by line — capitalize each bullet
        lines = []
        for line in text.splitlines():
            line = line.strip().lstrip('•-–·* ')
            if line:
                line = self._capitalize_first(line)
                line = self._clean_sentence(line)
                lines.append(line)
        # Deduplicate while preserving order
        seen = set()
        deduped = []
        for line in lines:
            key = line.lower()
            if key not in seen:
                seen.add(key)
                deduped.append(line)
        return '\n'.join(deduped)

    def _normalize_skill_name(self, name: str) -> str:
        """
        Handles comma-separated skill lists and normalizes individual names.
        Returns the first skill if comma-separated (DB model should hold 1 skill
        per row, but handles legacy data gracefully).
        """
        # Take first item if comma-separated (e.g. "python,django,nodejs")
        primary = name.split(',')[0].strip()
        lower = primary.lower()
        # Check exact brand name match
        if lower in SPELL_FIXES:
            return SPELL_FIXES[lower]
        # Otherwise apply title case
        return self._smart_title_case(primary)

    def _normalize_location(self, location: str) -> str:
        """Applies location fixes and title cases if not fixed."""
        lower_loc = location.strip().lower()
        if lower_loc in LOCATION_FIXES:
            return LOCATION_FIXES[lower_loc]
        return self._smart_title_case(location)

    @staticmethod
    def _apply_spell_fixes(text: str) -> str:
        """
        Applies the SPELL_FIXES dictionary using whole-word regex matching.
        Preserves surrounding text and punctuation.
        """
        for wrong, correct in SPELL_FIXES.items():
            # Skip brand-name replacements that include uppercase — handled separately
            pattern = r'\b' + re.escape(wrong) + r'\b'
            text = re.sub(pattern, correct, text, flags=re.IGNORECASE)
        return text

    @staticmethod
    def _apply_wording_map(text: str) -> str:
        """
        Replaces informal phrases with professional equivalents.
        Applied sentence-by-sentence for accuracy.
        """
        for pattern, replacement in WORDING_MAP:
            text = re.sub(pattern, replacement, text, flags=re.IGNORECASE)
        return text

    @staticmethod
    def _smart_title_case(text: str) -> str:
        """
        Converts text to title case with proper handling of:
        - Exception words (a, an, the, of, in, ...)
        - Tech brand names (JavaScript, Node.js, etc.)
        - Acronyms (AWS, API, SQL, ...)
        """
        if not text:
            return text

        # Check for direct brand name match first
        lower_text = text.strip().lower()
        if lower_text in SPELL_FIXES:
            return SPELL_FIXES[lower_text]

        words = text.split()
        result = []
        for i, word in enumerate(words):
            lower_word = word.lower()
            # Check brand map
            if lower_word in SPELL_FIXES:
                result.append(SPELL_FIXES[lower_word])
            # First or last word always capitalised
            elif i == 0 or i == len(words) - 1:
                result.append(word.capitalize())
            # Exception words stay lowercase
            elif lower_word in _LOWERCASE_WORDS:
                result.append(lower_word)
            # All-uppercase words (acronyms: API, SQL, AWS) stay uppercase
            elif word.isupper() and len(word) > 1:
                result.append(word)
            else:
                result.append(word.capitalize())
        return ' '.join(result)

    @staticmethod
    def _capitalize_first(text: str) -> str:
        """Capitalizes only the first character of a string."""
        if not text:
            return text
        return text[0].upper() + text[1:]

    @staticmethod
    def _clean_sentence(text: str) -> str:
        """
        Ensures a sentence ends with a period (unless it ends with
        another terminal punctuation mark).
        Removes extra whitespace.
        """
        text = ' '.join(text.split())  # normalize internal whitespace
        if text and text[-1] not in '.!?':
            text += '.'
        return text
