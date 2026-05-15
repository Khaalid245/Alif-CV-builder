"""
CV Intelligence Configuration System.
Centralizes all scoring parameters and thresholds for easy adjustment.
"""
from django.conf import settings
from typing import Dict, List


class CVIntelligenceConfig:
    """
    Centralized configuration for CV intelligence features.
    All thresholds and parameters can be adjusted without code changes.
    """
    
    # Scoring weights (must sum to 1.0)
    SCORING_WEIGHTS = {
        'summary': 0.15,        # 15%
        'experience': 0.40,     # 40% 
        'education': 0.15,      # 15%
        'skills': 0.15,         # 15%
        'completeness': 0.15    # 15%
    }
    
    # Content length thresholds
    CONTENT_THRESHOLDS = {
        'summary': {
            'min_words': 15,
            'max_words': 80,
            'optimal_min': 20,
            'optimal_max': 50
        },
        'experience_description': {
            'min_words': 10,
            'max_words': 150,
            'optimal_min': 20,
            'optimal_max': 100
        }
    }
    
    # Skills validation
    SKILLS_THRESHOLDS = {
        'min_count': 3,
        'max_count': 15,
        'optimal_min': 5,
        'optimal_max': 10
    }
    
    # Education validation
    EDUCATION_THRESHOLDS = {
        'good_gpa_threshold': 3.5,
        'base_score': 60,
        'complete_info_bonus': 20,
        'good_gpa_bonus': 10,
        'description_bonus': 10
    }
    
    # Grade boundaries
    GRADE_BOUNDARIES = {
        'A': 90,
        'B': 80,
        'C': 70,
        'D': 60,
        'F': 0
    }
    
    # Scoring points allocation
    SCORING_POINTS = {
        'summary': {
            'length_points': 20,
            'content_quality_points': 40,
            'structure_points': 40
        },
        'experience': {
            'basic_info_points': 30,
            'description_points': 70,
            'multiple_experience_bonus': 10
        },
        'skills': {
            'base_points': 80,
            'diversity_bonus': 20
        },
        'completeness': {
            'summary_points': 20,
            'experience_points': 30,
            'education_points': 25,
            'skills_points': 15,
            'projects_bonus': 5,
            'certifications_bonus': 5
        }
    }
    
    @classmethod
    def get_scoring_weight(cls, section: str) -> float:
        """Get scoring weight for a section."""
        return cls.SCORING_WEIGHTS.get(section, 0.0)
    
    @classmethod
    def get_content_threshold(cls, content_type: str, threshold_type: str) -> int:
        """Get content threshold value."""
        return cls.CONTENT_THRESHOLDS.get(content_type, {}).get(threshold_type, 0)
    
    @classmethod
    def get_skills_threshold(cls, threshold_type: str) -> int:
        """Get skills threshold value."""
        return cls.SKILLS_THRESHOLDS.get(threshold_type, 0)
    
    @classmethod
    def get_education_threshold(cls, threshold_type: str) -> int:
        """Get education threshold value."""
        return cls.EDUCATION_THRESHOLDS.get(threshold_type, 0)
    
    @classmethod
    def get_grade_for_score(cls, score: float) -> str:
        """Convert numerical score to letter grade."""
        for grade, min_score in cls.GRADE_BOUNDARIES.items():
            if score >= min_score:
                return grade
        return 'F'
    
    @classmethod
    def get_scoring_points(cls, section: str, point_type: str) -> int:
        """Get scoring points for a section and point type."""
        return cls.SCORING_POINTS.get(section, {}).get(point_type, 0)
    
    @classmethod
    def validate_configuration(cls) -> bool:
        """Validate that configuration is consistent."""
        # Check that scoring weights sum to 1.0
        total_weight = sum(cls.SCORING_WEIGHTS.values())
        if abs(total_weight - 1.0) > 0.001:
            raise ValueError(f"Scoring weights must sum to 1.0, got {total_weight}")
        
        # Check that grade boundaries are in descending order
        grades = list(cls.GRADE_BOUNDARIES.items())
        for i in range(len(grades) - 1):
            if grades[i][1] <= grades[i + 1][1]:
                raise ValueError(f"Grade boundaries must be in descending order")
        
        return True


# Industry-specific configurations
class IndustryConfig:
    """
    Industry-specific validation rules and keywords.
    Allows customization based on target industry.
    """
    
    INDUSTRY_KEYWORDS = {
        'software_engineering': {
            'required': ['programming', 'development', 'software', 'code'],
            'preferred': ['agile', 'git', 'testing', 'debugging', 'algorithms'],
            'action_verbs': ['developed', 'implemented', 'architected', 'optimized']
        },
        'data_science': {
            'required': ['data', 'analysis', 'statistics', 'python', 'sql'],
            'preferred': ['machine learning', 'visualization', 'modeling', 'research'],
            'action_verbs': ['analyzed', 'modeled', 'researched', 'predicted']
        },
        'business_analysis': {
            'required': ['analysis', 'business', 'requirements', 'stakeholder'],
            'preferred': ['process improvement', 'documentation', 'communication'],
            'action_verbs': ['analyzed', 'facilitated', 'documented', 'improved']
        },
        'project_management': {
            'required': ['project', 'management', 'planning', 'coordination'],
            'preferred': ['agile', 'scrum', 'budget', 'timeline', 'stakeholder'],
            'action_verbs': ['managed', 'coordinated', 'planned', 'delivered']
        }
    }
    
    @classmethod
    def get_industry_keywords(cls, industry: str) -> Dict:
        """Get keywords for a specific industry."""
        return cls.INDUSTRY_KEYWORDS.get(industry, {
            'required': [],
            'preferred': [],
            'action_verbs': []
        })
    
    @classmethod
    def get_available_industries(cls) -> List[str]:
        """Get list of available industries."""
        return list(cls.INDUSTRY_KEYWORDS.keys())


# Initialize and validate configuration on import
CVIntelligenceConfig.validate_configuration()