import re
from typing import Tuple, List, Dict, Optional, Any
from apps.resume_intelligence.context import ResumeContext
from .review_models import ReviewCategories, TopAction

class ResumeReviewRules:
    """
    Evaluates ResumeContext to generate deterministic scores, warnings, and recommendations.
    Provides the Resume Action Center payload.
    """
    
    def evaluate(self, context: ResumeContext) -> Tuple[ReviewCategories, List[str], List[Dict[str, Any]], Optional[TopAction]]:
        warnings = []
        recommendations_map = {} # action -> improvement
        categories = ReviewCategories()
        
        # We start with perfect scores and deduct based on rules.
        categories.professional_writing = 100
        categories.ats_compatibility = 100
        categories.skills = 100
        categories.projects = 100
        categories.career_story = 100
        
        data = context.normalized_data
        classifications = context.metadata.get('classifications', {})
        mixed_sections = context.metadata.get('mixed_sections', [])
        pipeline_errors = context.errors

        # 1. Career Story (Summary & Structure)
        if not data.get('summary'):
            warnings.append("Missing professional summary.")
            recommendations_map["Add a professional summary to introduce your profile."] = 10
            categories.career_story -= 30

        if not data.get('experiences') and not data.get('projects'):
            warnings.append("Missing experience and projects sections.")
            recommendations_map["Add at least one work experience or project to demonstrate your skills."] = 15
            categories.career_story -= 40
            categories.projects -= 50

        if not data.get('skills'):
            warnings.append("Missing skills section.")
            recommendations_map["Add a skills section listing your technical proficiencies."] = 10
            categories.career_story -= 20
            categories.skills -= 100
            
        if not data.get('educations'):
            warnings.append("Missing education section.")
            recommendations_map["Add your educational background."] = 5
            categories.career_story -= 10

        # Links (ATS Compatibility)
        github = data.get('github')
        linkedin = data.get('linkedin')
        portfolio = data.get('portfolio')
        if not github:
            warnings.append("Missing GitHub link.")
            recommendations_map["Add your GitHub profile URL to showcase your code."] = 6
            categories.ats_compatibility -= 10
        if not linkedin:
            warnings.append("Missing LinkedIn link.")
            recommendations_map["Add your LinkedIn profile URL for professional networking."] = 5
            categories.ats_compatibility -= 10
        if not portfolio and not github:
            warnings.append("Missing portfolio link.")
            recommendations_map["Add a portfolio link or GitHub to stand out."] = 4
            categories.ats_compatibility -= 5

        # 2. Summary Checks (Career Story & Professional Writing)
        summary = data.get('summary', '')
        if summary:
            if len(summary.split()) < 15:
                warnings.append("Weak Summary.")
                recommendations_map["Expand your summary to at least 15 words. Highlight your top achievements."] = 7
                categories.career_story -= 20
                categories.professional_writing -= 15
            elif "I am" in summary and "looking for" in summary:
                warnings.append("Generic Summary format.")
                recommendations_map["Replace generic 'I am looking for' phrases with strong value propositions."] = 5
                categories.professional_writing -= 20
                
        # 3. Skills Checks
        skills = data.get('skills', [])
        skill_names = []
        has_docker = False
        has_devops_exp = False
        
        for i, skill in enumerate(skills):
            if isinstance(skill, dict) and 'name' in skill:
                name = skill['name']
                if name.lower() in skill_names:
                    warnings.append(f"Duplicate skill: {name}")
                    recommendations_map[f"Remove the duplicate skill entry for '{name}'."] = 2
                    categories.skills -= 10
                else:
                    skill_names.append(name.lower())
                if name.lower() == 'docker':
                    has_docker = True
                    
        # 4. Project Checks
        projects = data.get('projects', [])
        project_titles = []
        for i, proj in enumerate(projects):
            if isinstance(proj, dict):
                title = proj.get('title', '')
                desc = proj.get('description', '')
                if title.lower() in project_titles:
                    warnings.append(f"Duplicate project: {title}")
                    recommendations_map[f"Remove the duplicate project entry for '{title}'."] = 3
                    categories.projects -= 15
                else:
                    project_titles.append(title.lower())
                    
                if not desc or len(desc.strip()) < 10:
                    warnings.append(f"Weak Project Description for {title}.")
                    recommendations_map[f"Add a detailed description for project '{title}' including technologies used."] = 8
                    categories.projects -= 25

        # 5. Experience Checks
        experiences = data.get('experiences', [])
        for i, exp in enumerate(experiences):
            if isinstance(exp, dict):
                desc = exp.get('description', '')
                title = exp.get('job_title', '').lower()
                if 'devops' in title or 'devops' in desc.lower():
                    has_devops_exp = True
                if desc:
                    if not re.search(r'\d+%|\$\d+|\d+x|\d+\+', desc):
                        warnings.append("Experience without measurable achievements.")
                        recommendations_map[f"Add measurable metrics (e.g., %, $, multipliers) to your {exp.get('company', 'recent')} experience."] = 12
                        categories.projects -= 10 
                        categories.professional_writing -= 15
                        categories.ats_compatibility -= 10
                        break

        # Conditional Recommendations
        if has_devops_exp and not has_docker:
            warnings.append("Missing ATS key technology (Docker).")
            recommendations_map["Add Docker keyword because your experience mentions DevOps."] = 6
            categories.skills -= 10

        # 6. Pipeline Context Checks (Semantic Engine results)
        if 'skills' in mixed_sections:
            warnings.append("Mixed content in skills section.")
            recommendations_map["Move experience descriptions out of the skills section."] = 8
            categories.career_story -= 20
            categories.ats_compatibility -= 15

        if 'experience' in mixed_sections:
            warnings.append("Mixed content in experience section.")
            recommendations_map["Clean up the experience section to separate skills."] = 8
            categories.career_story -= 20
            categories.ats_compatibility -= 15

        for err in pipeline_errors:
            if "Garbage data" in err['message']:
                warnings.append("Garbage or placeholder text detected.")
                recommendations_map["Remove placeholder links or template text from your resume."] = 20
                categories.professional_writing -= 50
                categories.ats_compatibility -= 50

        # Ensure no negative scores
        categories.professional_writing = max(0, categories.professional_writing)
        categories.ats_compatibility = max(0, categories.ats_compatibility)
        categories.skills = max(0, categories.skills)
        categories.projects = max(0, categories.projects)
        categories.career_story = max(0, categories.career_story)
        
        # Format outputs
        warnings = list(dict.fromkeys(warnings))
        
        # Sort recommendations by estimated improvement descending
        sorted_recs = sorted(recommendations_map.items(), key=lambda item: item[1], reverse=True)
        recommendations_list = [item[0] for item in sorted_recs]
        
        top_action = None
        if sorted_recs:
            top_action = TopAction(action=sorted_recs[0][0], estimated_improvement=sorted_recs[0][1])

        return categories, warnings, recommendations_list, top_action

    def calculate_overall_score(self, categories: ReviewCategories) -> int:
        """
        Calculates the overall score.
        Writing (20), ATS (20), Skills (20), Projects (20), Career Story (20) = 100
        """
        score = 0
        score += (categories.professional_writing * 0.20)
        score += (categories.ats_compatibility * 0.20)
        score += (categories.skills * 0.20)
        score += (categories.projects * 0.20)
        score += (categories.career_story * 0.20)
        return int(round(score))

    def get_status(self, score: int) -> str:
        if score >= 90: return "Excellent"
        if score >= 75: return "Good"
        if score >= 60: return "Needs Improvement"
        return "Critical"
