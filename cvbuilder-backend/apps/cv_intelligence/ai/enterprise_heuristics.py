"""
Enterprise Heuristics Provider - Role-Aware AI Analysis Engine.

v2: Now powered by real semantic ML (sentence-transformers).

Scoring architecture — 3 layers working together:
  1. Rule layer   — universal checks (metrics, weak phrases) ← unchanged
  2. ML layer     — semantic role match via all-MiniLM-L6-v2 ← NEW
  3. Role layer   — role-specific boosts/penalties from DB    ← upgraded

Backward compatible: all role_config arguments default to None,
which triggers generic analysis behavior (ML still active, role context
is just "professional CV").
"""
import re
from typing import Dict, List, Optional
from .provider import AIEngineProvider
from .ml_scoring_service import MLScoringService


class EnterpriseHeuristicsProvider(AIEngineProvider):
    """
    Advanced CV analysis engine combining rule-based heuristics and
    semantic ML scoring.

    When a RoleIntelligenceConfig is provided:
      - Rule checks use role-specific weak patterns and keywords
      - ML scoring embeds the bullet against the full role description
      - Skill extraction uses semantic similarity (not just exact match)

    When no role_config is provided:
      - Falls back to generic professional CV scoring
      - ML still active — compares against "professional CV" context
    """

    # ── Generic fallback constants ─────────────────────────────────────────────

    GENERIC_WEAK_PHRASES = [
        'responsible for', 'worked on', 'helped with', 'assisted with',
        'was involved in', 'participated in', 'contributed to', 'dealt with',
        'handled', 'did', 'performed', 'executed', 'tasked with', 'in charge of'
    ]

    GENERIC_ACTION_VERBS = [
        'spearheaded', 'orchestrated', 'architected', 'engineered',
        'maximized', 'optimized', 'transformed', 'pioneered',
        'conceptualized', 'directed', 'formulated', 'delivered'
    ]

    METRIC_INDICATORS = [
        r'\d+%', r'\$\d+', r'\d+x', r'million', r'billion', r'thousand',
        r'reduced by', r'increased by', r'improved', r'saved',
        r'\d+ms', r'\d+s response', r'\d+ users', r'\d+k',
    ]

    # Broad skill vocabulary (extended with ML for semantic matching)
    KNOWN_SKILLS = [
        'Python', 'Java', 'JavaScript', 'TypeScript', 'Dart', 'Go', 'Rust', 'C++',
        'Django', 'React', 'Flutter', 'Node.js', 'FastAPI', 'Spring Boot',
        'AWS', 'Azure', 'GCP', 'Docker', 'Kubernetes', 'Terraform',
        'PostgreSQL', 'MySQL', 'MongoDB', 'Redis', 'Kafka', 'Spark',
        'Machine Learning', 'Deep Learning', 'NLP', 'Computer Vision',
        'Agile', 'Scrum', 'CI/CD', 'DevOps', 'Figma', 'Product Management',
        'SQL', 'Git', 'Linux', 'REST API', 'GraphQL', 'Microservices',
    ]

    # ML/Rule blend — ML carries the semantic intelligence for ANY major:
    #   60% ML  = semantic role match (works for any field, no seeds needed)
    #   40% Rule = universal checks (metrics, weak phrases — valid everywhere)
    # Increasing ML weight from 30% → 60% allows the system to serve Civil
    # Engineers, Nurses, Marketing students, etc. with zero configuration.
    ML_WEIGHT   = 0.60
    RULE_WEIGHT = 0.40

    # ── Core interface ─────────────────────────────────────────────────────────

    def analyze_bullet_point(
        self,
        text: str,
        context: str = None,
        role_config=None,           # Optional[RoleIntelligenceConfig]
        custom_role_name: str = '', # Free-text major e.g. "Civil Engineering"
    ) -> Dict:
        """
        Analyze a single bullet point with hybrid rule + ML scoring.

        Scoring breakdown:
          Rule score (40%) — universal, works for every profession:
            - Missing metrics:      -30 pts
            - Weak phrase found:    -20 pts
          ML score (60%) — semantic, understands any major/field:
            - Semantic role match:   0-100 pts

        Final score = rule_score * 0.40 + ml_score * 0.60
        """
        text_lower = text.lower()
        issues = []
        rule_score = 100
        impact_level = 'High'

        # ── 1. Metric check (universal, unchanged) ────────────────────────
        has_metrics = any(re.search(p, text_lower) for p in self.METRIC_INDICATORS)
        if not has_metrics:
            issues.append('Missing quantifiable metrics (e.g. %, $, timelines)')
            rule_score -= 30
            impact_level = 'Low'

        # ── 2. Weak phrase check (role-aware, unchanged) ──────────────────
        weak_phrases = (
            (role_config.role_weak_patterns + self.GENERIC_WEAK_PHRASES)
            if role_config and role_config.role_weak_patterns
            else self.GENERIC_WEAK_PHRASES
        )
        for phrase in weak_phrases:
            if phrase.lower() in text_lower:
                issues.append(f"Uses passive/weak phrase: '{phrase}'")
                rule_score -= 20
                impact_level = 'Medium' if impact_level == 'High' else 'Low'
                break

        # ── 3. ML semantic role match (NEW — replaces keyword counting) ───
        ml_result = self._compute_ml_score(text, role_config, custom_role_name)
        ml_score = ml_result['score']

        # Low semantic match is a soft issue (only flag if rule score is already weak)
        if ml_result['method'] == 'semantic' and ml_score < 35 and rule_score < 80:
            role_name = (
                role_config.role.name if role_config
                else (custom_role_name or 'your target role')
            )
            issues.append(
                f"Bullet point has low semantic relevance to {role_name}. "
                f"Try aligning language more closely with the role's core skills."
            )

        # ── 4. Hybrid final score ─────────────────────────────────────────
        final_score = int(rule_score * self.RULE_WEIGHT + ml_score * self.ML_WEIGHT)
        final_score = max(0, min(100, final_score))

        # Rewrite suggestion
        rewrite = None
        if final_score < 100:
            rewrite = self._generate_bullet_rewrite(text, role_config)

        return {
            'score': final_score,
            'issues': issues,
            'rewrite_suggestion': rewrite,
            'impact_level': impact_level,
            'role_aware': role_config is not None,
            # ML diagnostics (transparent to the caller)
            'ml_score': ml_score,
            'ml_similarity': ml_result.get('similarity'),
            'ml_confidence': ml_result.get('confidence'),
            'ml_method': ml_result.get('method'),
        }

    def analyze_summary(
        self,
        text: str,
        role_config=None,           # Optional[RoleIntelligenceConfig]
        custom_role_name: str = '', # Free-text major e.g. "Nursing"
    ) -> Dict:
        """
        Analyze the professional summary.
        Combines length/quality rules with ML semantic role alignment check.
        """
        word_count = len(text.split())
        issues = []
        rule_score = 100

        # Length checks
        if word_count < 30:
            issues.append('Summary is too brief. Aim for 3-5 lines (50-100 words).')
            rule_score -= 30
        elif word_count > 100:
            issues.append('Summary is too verbose. Keep it concise (under 100 words).')
            rule_score -= 20

        # ── ML semantic fit for summary ───────────────────────────────────
        ml_service = MLScoringService.get_instance()
        effective_role_name = (
            role_config.role.name if role_config
            else (custom_role_name.strip() or '')
        )
        if ml_service.is_available and effective_role_name:
            keywords = role_config.priority_keywords if role_config else self.GENERIC_ACTION_VERBS
            guidance = role_config.role_specific_summary_guidance if role_config else ''
            ml_result = ml_service.compute_summary_role_fit(
                summary_text=text,
                role_name=effective_role_name,
                role_keywords=keywords,
                role_guidance=guidance,
            )
            ml_score = ml_result['score']

            if ml_score < 40:
                issues.append(
                    f"Your summary has low semantic alignment with a "
                    f"{effective_role_name} role (ML score: {ml_score}/100). "
                    f"Try highlighting key skills relevant to {effective_role_name}."
                )
                rule_score -= 15
        else:
            ml_score = 50  # Neutral when role not set

        # Determine rewrite suggestion
        rewrite = None
        if rule_score < 100:
            if role_config and role_config.role_specific_summary_guidance:
                rewrite = role_config.role_specific_summary_guidance
            else:
                rewrite = (
                    'A seasoned professional with a proven track record of driving '
                    'impact and delivering enterprise-grade solutions.'
                )

        final_score = max(0, min(100, int(rule_score * 0.70 + ml_score * 0.30)))

        return {
            'score': final_score,
            'issues': issues,
            'rewrite_suggestion': rewrite,
            'role_aware': role_config is not None,
            'ml_score': ml_score,
        }

    def extract_skills_from_text(self, text: str) -> List[str]:
        """
        Extract professional skills using semantic ML similarity.
        Catches 'React.js' for 'React', 'ML' for 'Machine Learning', etc.
        Falls back to exact matching if ML unavailable.
        """
        ml_service = MLScoringService.get_instance()
        return ml_service.extract_skills_semantic(
            text=text,
            candidate_skills=self.KNOWN_SKILLS,
            threshold=0.45,
        )

    # ── Private helpers ───────────────────────────────────────────────────────

    def _compute_ml_score(
        self, text: str, role_config, custom_role_name: str = ''
    ) -> Dict:
        """
        Compute ML semantic score for a bullet point.

        Priority order:
          1. role_config (seeded DB role — most precise)
          2. custom_role_name (free-text e.g. "Civil Engineering" — any major)
          3. Generic professional fallback
        """
        ml_service = MLScoringService.get_instance()

        if role_config:
            # Seeded role — use full DB config for maximum accuracy
            return ml_service.compute_role_match(
                text=text,
                role_name=role_config.role.name,
                role_keywords=role_config.priority_keywords,
                role_guidance=role_config.role_specific_summary_guidance,
            )
        elif custom_role_name and custom_role_name.strip():
            # Free-text major — ML uses the name as semantic context
            # Works for Civil Engineering, Nursing, Architecture, Marketing, etc.
            return ml_service.compute_role_match(
                text=text,
                role_name=custom_role_name.strip(),
                role_keywords=[],   # No seeds needed — ML understands the name
                role_guidance=f'Professional work in the field of {custom_role_name.strip()}.',
            )
        else:
            # No role context at all — generic professional scoring
            return ml_service.compute_role_match(
                text=text,
                role_name='Professional',
                role_keywords=self.GENERIC_ACTION_VERBS,
                role_guidance='Delivering measurable impact in a professional role.',
            )

    def _generate_bullet_rewrite(self, text: str, role_config=None) -> str:
        """
        Generate a deterministic rewrite suggestion.

        Fully DB-driven: reads role name, recommended_metrics, and
        role_specific_summary_guidance from RoleIntelligenceConfig.
        Works automatically for ANY role — no hardcoded slug checks.
        """
        text_lower = text.lower()

        if role_config:
            metrics = role_config.recommended_metrics
            metric_example = metrics[0] if metrics else 'measurable outcome'
            role_name = role_config.role.name

            # Detect weak-phrase patterns and choose action verb from role config
            action_verb = (
                role_config.priority_keywords[0].capitalize()
                if role_config.priority_keywords
                else 'Delivered'
            )

            if 'worked on' in text_lower or 'responsible for' in text_lower:
                return (
                    f'{action_verb} key {role_name} deliverables, achieving '
                    f'measurable {metric_example} improvements of 25-35%.'
                )
            elif 'helped with' in text_lower or 'assisted with' in text_lower:
                return (
                    f'Collaborated as a core {role_name} contributor, driving '
                    f'{metric_example} outcomes through cross-functional alignment.'
                )

            # Generic role-aware fallback for any role
            return (
                f'{action_verb} high-impact {role_name} initiatives '
                f'resulting in measurable {metric_example} improvements.'
            )

        # Generic fallback (no role configured)
        if 'responsible for' in text_lower and 'sales' in text_lower:
            return 'Spearheaded B2B sales initiatives, resulting in 20% YoY revenue growth.'
        elif 'helped with' in text_lower or 'assisted with' in text_lower:
            return 'Collaborated cross-functionally to accelerate project delivery by 15%.'
        elif 'worked on' in text_lower and ('code' in text_lower or 'software' in text_lower):
            return 'Architected and deployed scalable software solutions, improving performance by 30%.'

        words = text.split()
        last_word = words[-1] if words else 'initiatives'
        return (
            f'Orchestrated key initiatives related to {last_word} '
            f'to drive measurable business outcomes.'
        )
