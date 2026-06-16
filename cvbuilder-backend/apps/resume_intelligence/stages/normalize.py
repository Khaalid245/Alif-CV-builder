import re
import copy
from typing import Any
from ..context import ResumeContext

class NormalizeStage:
    """
    Stage responsible for deterministic text normalization:
    - whitespace cleanup
    - capitalization
    - degree normalization
    - issuer normalization
    - location normalization
    - typo correction
    """
    
    TYPO_MAP = {
        'sceince': 'Science',
        'scinece': 'Science',
        'scince': 'Science',
        'buisness': 'Business',
        'teh': 'the',
        'amercan': 'American',
        'mogadisho': 'Mogadishu'
    }

    LOCATION_MAP = {
        'mogadisho': 'Mogadishu, Somalia',
        'mogadishu': 'Mogadishu, Somalia',
        'new york': 'New York, NY',
        'sf': 'San Francisco, CA'
    }

    DEGREE_MAP = {
        'bsc': 'B.Sc.',
        'b.s.': 'B.Sc.',
        'bs': 'B.Sc.',
        'bachelor of science': 'B.Sc.',
        'ba': 'B.A.',
        'b.a.': 'B.A.',
        'bachelor of arts': 'B.A.',
        'msc': 'M.Sc.',
        'master of science': 'M.Sc.',
        'ms': 'M.Sc.',
        'phd': 'Ph.D.',
        'ph.d': 'Ph.D.',
        'ph.d.': 'Ph.D.'
    }

    def process(self, context: ResumeContext) -> ResumeContext:
        """
        Deep copies resume_data to normalized_data and normalizes strings deterministically.
        """
        # Start fresh from raw data
        context.normalized_data = copy.deepcopy(context.resume_data)
        
        # Traverse and normalize recursively
        self._normalize_dict(context.normalized_data)
        
        context.add_log("NormalizationStage: Normalization completed")
        return context

    def _normalize_dict(self, data: dict) -> None:
        """Recursively normalizes strings within a dictionary."""
        for k, v in data.items():
            if isinstance(v, str):
                data[k] = self._normalize_string(v, field_type=k)
            elif isinstance(v, dict):
                self._normalize_dict(v)
            elif isinstance(v, list):
                self._normalize_list(v, field_type=k)

    def _normalize_list(self, items: list, field_type: str = '') -> None:
        """Recursively normalizes strings within a list."""
        for i, item in enumerate(items):
            if isinstance(item, str):
                items[i] = self._normalize_string(item, field_type)
            elif isinstance(item, dict):
                self._normalize_dict(item)
            elif isinstance(item, list):
                self._normalize_list(item, field_type)

    def _normalize_string(self, text: str, field_type: str = '') -> str:
        """Applies normalization rules to a single string based on its field context."""
        if not text:
            return text
            
        # 1. Whitespace cleanup (remove multiple spaces, newlines are preserved by not using re.sub for all whitespace)
        # Actually, standardizing all whitespace to single spaces is usually desired for simple fields,
        # but for description fields, we might want to preserve newlines.
        if field_type not in ('description', 'summary'):
            text = re.sub(r'\s+', ' ', text).strip()
        else:
            # For multiline, clean trailing/leading spaces per line
            lines = [line.strip() for line in text.split('\n')]
            text = '\n'.join(line for line in lines if line)
        
        # 2. Typo correction
        if field_type not in ('description', 'summary'):
            words = text.split()
            for i, w in enumerate(words):
                clean_w = w.strip('.,()[]{}')
                if not clean_w:
                    continue
                lower_w = clean_w.lower()
                if lower_w in self.TYPO_MAP:
                    words[i] = w.replace(clean_w, self.TYPO_MAP[lower_w])
            text = ' '.join(words)
        else:
            # Typo correction preserving newlines
            lines = []
            for line in text.split('\n'):
                line_words = line.split()
                for i, w in enumerate(line_words):
                    clean_w = w.strip('.,()[]{}')
                    if clean_w.lower() in self.TYPO_MAP:
                        line_words[i] = w.replace(clean_w, self.TYPO_MAP[clean_w.lower()])
                # Also normalize internal whitespace on this line
                lines.append(' '.join(line_words))
            text = '\n'.join(lines)
            
        lower_text = text.lower()
        
        # 3. Location normalization
        if field_type in ['location', 'city']:
            if lower_text in self.LOCATION_MAP:
                return self.LOCATION_MAP[lower_text]
                
        # 4. Degree normalization
        if field_type == 'degree':
            if lower_text in self.DEGREE_MAP:
                return self.DEGREE_MAP[lower_text]
                
        # 5. Capitalization (title case for specific fields)
        title_case_fields = {
            'degree', 'field_of_study', 'institution', 'company', 
            'location', 'issuer', 'job_title', 'city', 'country',
            'name'
        }
        
        if field_type in title_case_fields:
            exceptions = {'and', 'in', 'of', 'for', 'a', 'an', 'the', 'at', 'by', 'to'}
            words = text.split()
            capitalized_words = []
            for i, word in enumerate(words):
                if '-' in word:
                    parts = word.split('-')
                    word = '-'.join(p.capitalize() for p in parts)
                    capitalized_words.append(word)
                    continue
                    
                if i == 0 or word.lower() not in exceptions:
                    if word.islower():
                        capitalized_words.append(word.capitalize())
                    else:
                        capitalized_words.append(word[0].upper() + word[1:])
                else:
                    capitalized_words.append(word.lower())
            text = ' '.join(capitalized_words)
            
        return text
