import re
from typing import Dict, Any, List, Set

from .match_models import (
    CareerMatchResult, MissingSkill, ImprovementAction, JobFitCategories
)
from .review_service import ResumeReviewService

# A mock database of known technical/professional skills for deterministic extraction
KNOWN_SKILLS = {
    "python", "django", "rest api", "postgresql", "docker", "aws", "kubernetes", "ci/cd", 
    "redis", "javascript", "react", "flutter", "dart", "sql", "java", "spring boot", "c++",
    "machine learning", "data analysis", "git", "linux", "agile", "scrum", "typescript",
    "node.js", "express", "mongodb", "communication", "leadership", "project management",
    "data structures", "algorithms"
}

class CareerMatchService:
    def __init__(self):
        self.review_service = ResumeReviewService()

    def analyze(self, cv_data: Dict[str, Any], job_description: str) -> CareerMatchResult:
        """
        Deterministically compare CV data against a Job Description.
        """
        # Normalize job description to lower case
        jd_lower = job_description.lower()
        
        # 1. Extract keywords deterministically from JD
        extracted_jd_keywords = set()
        for skill in KNOWN_SKILLS:
            # handle boundary for special chars like c++
            pattern = r'(?:\b|^)' + re.escape(skill) + r'(?:\b|$|(?=\W))'
            if re.search(pattern, jd_lower):
                extracted_jd_keywords.add(skill)
                
        # 2. Extract keywords from CV
        cv_text = self._extract_cv_text(cv_data).lower()
        extracted_cv_keywords = set()
        for skill in KNOWN_SKILLS:
            pattern = r'(?:\b|^)' + re.escape(skill) + r'(?:\b|$|(?=\W))'
            if re.search(pattern, cv_text):
                extracted_cv_keywords.add(skill)
                
        # Also include explicitly listed skills
        for skill_obj in cv_data.get("skills", []):
            skill_name = skill_obj.get("name", "").lower().strip()
            if skill_name:
                extracted_cv_keywords.add(skill_name)
        
        # 3. Compare keywords
        present_keywords = extracted_cv_keywords.intersection(extracted_jd_keywords)
        missing_keywords = extracted_jd_keywords.difference(extracted_cv_keywords)
        
        # Determine status and match percentage based on present vs missing keywords
        total_jd_keywords = len(extracted_jd_keywords)
        match_percentage = 0
        if total_jd_keywords > 0:
            match_percentage = int((len(present_keywords) / total_jd_keywords) * 100)
        else:
            match_percentage = 70  # Default if no recognized keywords are in JD
            
        status = self._get_status(match_percentage)
        
        # 4. Generate Strengths (Capitalized)
        strengths = [kw.title() for kw in present_keywords]
        
        # 5. Generate Missing Skills with importance
        missing_skills_list = []
        for i, kw in enumerate(sorted(missing_keywords)):
            # Deterministic importance based on length/alphabet to simulate business rules
            importance = "High" if len(kw) > 6 else ("Medium" if len(kw) > 3 else "Low")
            improvement = 5 if importance == "High" else (3 if importance == "Medium" else 2)
            missing_skills_list.append(MissingSkill(
                name=kw.title(),
                importance=importance,
                estimated_improvement=improvement
            ))
            
        # 6. Generate Improvement Plan
        improvement_plan = self._generate_improvement_plan(cv_data, missing_skills_list)
        
        # 7. Generate Categories based on cv_data density
        categories = self._calculate_categories(cv_data, match_percentage)

        return CareerMatchResult(
            overall_match=match_percentage,
            status=status,
            strengths=strengths,
            missing_skills=missing_skills_list,
            present_keywords=[kw.title() for kw in present_keywords],
            missing_keywords=[kw.title() for kw in missing_keywords],
            recommended_keywords=[kw.title() for kw in missing_keywords][:5],  # Recommend top 5
            improvement_plan=improvement_plan,
            categories=categories
        )

    def _extract_cv_text(self, cv_data: Dict[str, Any]) -> str:
        text_parts = [cv_data.get("summary", "")]
        for exp in cv_data.get("experiences", []):
            text_parts.append(exp.get("job_title", ""))
            text_parts.append(exp.get("description", ""))
        for proj in cv_data.get("projects", []):
            text_parts.append(proj.get("title", ""))
            text_parts.append(proj.get("description", ""))
        return " ".join(text_parts)

    def _get_status(self, score: int) -> str:
        if score >= 90:
            return "Excellent Match"
        elif score >= 75:
            return "Good Match"
        elif score >= 50:
            return "Fair Match"
        else:
            return "Needs Improvement"

    def _generate_improvement_plan(self, cv_data: Dict[str, Any], missing_skills: List[MissingSkill]) -> List[ImprovementAction]:
        plan = []
        
        # Check basic CV structure rules for improvements
        if not cv_data.get("summary"):
            plan.append(ImprovementAction("Add a professional summary tailored to this role", 10))
            
        if len(cv_data.get("experiences", [])) < 2:
            plan.append(ImprovementAction("Add more measurable achievements to your experience", 7))
            
        # Add missing skills to plan
        for ms in missing_skills[:3]: # top 3 missing skills
            plan.append(ImprovementAction(f"Add {ms.name} experience to your resume", ms.estimated_improvement))
            
        # Sort by improvement descending
        plan.sort(key=lambda x: x.estimated_improvement, reverse=True)
        return plan

    def _calculate_categories(self, cv_data: Dict[str, Any], base_score: int) -> JobFitCategories:
        # Simple deterministic scoring for categories based on presence of data
        exp_score = min(100, base_score + (10 if len(cv_data.get("experiences", [])) >= 2 else 0))
        edu_score = 100 if cv_data.get("education", []) else 50
        proj_score = 100 if cv_data.get("projects", []) else 40
        tech_score = base_score
        
        return JobFitCategories(
            technical_skills=tech_score,
            communication=min(100, base_score + 5),
            leadership=min(100, base_score - 5),
            projects=proj_score,
            education=edu_score,
            experience=exp_score
        )
