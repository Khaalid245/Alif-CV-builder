import re
from typing import Any
from ..context import ResumeContext

class ClassifyStage:
    """
    Semantic Classifier Stage.
    Classifies resume text content into structured categories deterministically.
    Categories: Skill, Language, Experience, Project, Certification, Award, Publication, Reference, Unknown, Garbage.
    """
    
    LANGUAGES = {
        'english', 'spanish', 'french', 'german', 'mandarin', 'chinese', 'arabic',
        'hindi', 'bengali', 'portuguese', 'russian', 'japanese', 'punjabi', 'marathi',
        'telugu', 'turkish', 'korean', 'vietnamese', 'tamil', 'urdu', 'javanese',
        'italian', 'egyptian arabic', 'gujarati', 'persian', 'bhojpuri', 'hausa',
        'kannada', 'indonesian', 'polish', 'yoruba', 'malayalam', 'odia', 'maithili',
        'burmese', 'sundanese', 'ukrainian', 'igbo', 'uzbek', 'sindhi', 'romanian',
        'tagalog', 'dutch', 'kurdish', 'serbo-croatian', 'malagasy', 'saraiki',
        'nepali', 'sinhalese', 'chittagonian', 'zhuang', 'khmer', 'turkmen', 'assamese',
        'somali', 'cebuano', 'nyanja', 'swahili'
    }

    GARBAGE_PATTERNS = [
        r'chatgpt\.com',
        r'lorem ipsum',
        r'as an ai language model',
        r'openai',
        r'placeholder text',
        r'\[insert.*?\]',
        r'here is a draft',
        r'proposes',
        r'nfinitytech' # from earlier legacy issues
    ]

    ACTION_VERBS = {
        'developed', 'managed', 'created', 'led', 'designed', 'built', 'implemented',
        'improved', 'increased', 'decreased', 'resolved', 'analyzed', 'orchestrated',
        'coordinated', 'directed', 'executed', 'spearheaded', 'achieved', 'delivered',
        'maintained', 'optimized', 'programmed', 'tested', 'wrote', 'authored'
    }

    PROJECT_KEYWORDS = {
        'app', 'application', 'system', 'platform', 'repository', 'github.com',
        'clone', 'dashboard', 'website', 'script', 'plugin', 'module', 'framework'
    }

    CERT_KEYWORDS = {
        'certified', 'certificate', 'certification', 'coursera', 'udemy', 'aws',
        'comptia', 'cisco', 'ccna', 'az-', 'professional', 'practitioner'
    }

    AWARD_KEYWORDS = {
        'award', 'won', 'winner', 'prize', 'scholarship', 'dean', 'honor',
        'valedictorian', 'competed', 'hackathon', 'competition', 'medalist'
    }

    PUB_KEYWORDS = {
        'published', 'journal', 'doi', 'conference', 'ieee', 'acm', 'arxiv',
        'paper', 'author', 'co-author', 'proceedings'
    }

    def process(self, context: ResumeContext) -> ResumeContext:
        """
        Iterates over normalized_data and classifies ambiguous text.
        We will attach classifications to context.metadata['classifications'].
        Additionally, we detect mixed sections (e.g., an experience bullet inside skills).
        """
        if 'classifications' not in context.metadata:
            context.metadata['classifications'] = {}
            
        if 'mixed_sections' not in context.metadata:
            context.metadata['mixed_sections'] = []

        self._analyze_skills(context)
        self._analyze_experiences(context)
        
        context.add_log("ClassifyStage: Semantic classification completed")
        return context

    def classify_text(self, text: str) -> str:
        """
        Deterministically classifies a given text snippet.
        """
        if not text or not text.strip():
            return 'Unknown'
            
        lower_text = text.lower().strip()
        
        # 1. Garbage Detection
        for pattern in self.GARBAGE_PATTERNS:
            if re.search(pattern, lower_text):
                return 'Garbage'
                
        # 2. Language Detection
        # If the text is exactly a known language, or contains "native/fluent" with a language
        if lower_text in self.LANGUAGES:
            return 'Language'
            
        words = lower_text.split()
        if len(words) <= 3 and any(lang in words for lang in self.LANGUAGES):
            return 'Language'
            
        # 3. Certification Detection
        # Short phrases with certification keywords
        if len(words) <= 10 and any(kw in lower_text for kw in self.CERT_KEYWORDS):
            # Exclude if it's actually an experience bullet mentioning AWS
            if words[0] not in self.ACTION_VERBS:
                return 'Certification'

        # 4. Award Detection
        if len(words) <= 15 and any(kw in lower_text for kw in self.AWARD_KEYWORDS):
            return 'Award'

        # 5. Publication Detection
        if any(kw in lower_text for kw in self.PUB_KEYWORDS):
            # To avoid false positives, ensure it's not a generic word like 'paper' unless other context exists
            if any(k in lower_text for k in ['published', 'journal', 'doi', 'ieee', 'acm', 'arxiv', 'proceedings', 'author']):
                return 'Publication'

        # 6. Experience vs Project vs Skill
        word_count = len(words)
        
        # Skills are usually very short, nouns, no action verbs
        if word_count <= 4:
            if words[0] in self.ACTION_VERBS:
                return 'Experience'
            if any(kw in lower_text for kw in ['clone', 'github.com', 'dashboard', 'app', 'system']):
                return 'Project'
            return 'Skill'
            
        # If it's a sentence/bullet point
        if word_count > 4:
            # 7. Project Detection
            if any(kw in lower_text for kw in self.PROJECT_KEYWORDS):
                return 'Project'
                
            # Experience usually starts with an action verb
            if words[0] in self.ACTION_VERBS:
                return 'Experience'
                
            # If it has action verbs inside, likely Experience
            if any(verb in words for verb in self.ACTION_VERBS):
                return 'Experience'
                
            # Fallback for long text
            return 'Experience' # Most long resume bullets are experience

        return 'Unknown'

    def _analyze_skills(self, context: ResumeContext):
        """Analyze items listed under skills to ensure no experiences are mixed in."""
        skills = context.normalized_data.get('skills', [])
        for i, skill in enumerate(skills):
            if isinstance(skill, dict) and 'name' in skill:
                category = self.classify_text(skill['name'])
                context.metadata['classifications'][f"skill_{i}"] = category
                
                if category == 'Garbage':
                    context.add_error(f"Garbage data detected in skills: '{skill['name']}'", section="skills")
                elif category == 'Experience':
                    context.add_warning(f"Experience bullet found in skills: '{skill['name']}'", section="skills")
                    context.metadata['mixed_sections'].append('skills')

    def _analyze_experiences(self, context: ResumeContext):
        """Analyze experience descriptions to ensure they are actually experiences."""
        experiences = context.normalized_data.get('experiences', [])
        for i, exp in enumerate(experiences):
            if isinstance(exp, dict) and 'description' in exp and exp['description']:
                bullets = exp['description'].split('\n')
                for j, bullet in enumerate(bullets):
                    if not bullet.strip():
                        continue
                    category = self.classify_text(bullet)
                    context.metadata['classifications'][f"exp_{i}_bullet_{j}"] = category
                    
                    if category == 'Garbage':
                        context.add_error(f"Garbage data detected in experience: '{bullet[:30]}...'", section="experience")
                    elif category == 'Skill':
                        context.add_warning(f"Single skill found in experience bullets: '{bullet}'", section="experience")
                        context.metadata['mixed_sections'].append('experience')
