from abc import ABC, abstractmethod
from typing import Dict, List

class AIEngineProvider(ABC):
    """
    Abstract Base Class for CV Intelligence AI engines.
    """
    
    @abstractmethod
    def analyze_bullet_point(self, text: str, context: str = None) -> Dict:
        """
        Analyze a single bullet point (e.g., from an experience section)
        and return a dictionary containing metrics such as impact, clarity,
        action verb strength, and a suggested rewrite.
        
        Returns:
            Dict containing:
                - 'score' (int): 0-100 rating of the bullet point
                - 'issues' (List[str]): List of identified issues (e.g., "missing metric")
                - 'rewrite_suggestion' (str): An improved version of the text
                - 'impact_level' (str): 'Low', 'Medium', or 'High'
        """
        pass

    @abstractmethod
    def analyze_summary(self, text: str) -> Dict:
        """
        Analyze a professional summary for conciseness, keywords, and tone.
        
        Returns:
            Dict containing:
                - 'score' (int): 0-100 rating
                - 'issues' (List[str])
                - 'rewrite_suggestion' (str)
        """
        pass

    @abstractmethod
    def extract_skills_from_text(self, text: str) -> List[str]:
        """
        Extract relevant professional skills from an arbitrary block of text.
        """
        pass
