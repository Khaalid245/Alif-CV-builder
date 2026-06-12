"""
ML Semantic Scoring Service
============================
Uses sentence-transformers (all-MiniLM-L6-v2) to compute genuine semantic
similarity between CV text and role/job descriptions.

Design principles:
  - Singleton: model loads ONCE at Django startup, reused on every request
  - Graceful fallback: if model unavailable, returns neutral 0.5 scores
  - Role embedding cache: role descriptions are embedded once and cached via Django cache
  - CPU-only: no GPU needed — runs on any standard server

Performance:
  - Model size: ~90MB RAM
  - Per-bullet inference: ~10-30ms on CPU
  - Full CV (20 bullets): ~0.3-0.6s added to analysis time
"""
import logging
from typing import Dict, List, Optional

logger = logging.getLogger(__name__)


class MLScoringService:
    """
    Singleton wrapper around sentence-transformers.

    Usage:
        service = MLScoringService.get_instance()
        score = service.compute_role_match('Led a team of 8 engineers', 'Software Engineer', [...])
    """

    # HuggingFace model — ~90MB, multilingual-capable, CPU-friendly
    MODEL_NAME = 'all-MiniLM-L6-v2'

    # Cache key prefix for pre-computed role embeddings
    ROLE_EMBED_CACHE_PREFIX = 'ml_role_embed_v1'
    ROLE_EMBED_CACHE_TTL = 86400  # 24 hours

    # Similarity → score normalization window
    # Typical good CV bullets: 0.25–0.60 cosine similarity to role description
    SIM_MIN = 0.20   # Maps to score 0
    SIM_MAX = 0.65   # Maps to score 100

    _instance: Optional['MLScoringService'] = None
    _model = None
    _model_load_attempted = False

    # ─────────────────────────────────────────────────────────────────────────
    # Singleton & lifecycle
    # ─────────────────────────────────────────────────────────────────────────

    @classmethod
    def get_instance(cls) -> 'MLScoringService':
        if cls._instance is None:
            cls._instance = cls()
        return cls._instance

    def warm_up(self):
        """
        Pre-load the model into RAM.
        Called by CvIntelligenceConfig.ready() so first request isn't slow.
        """
        self._ensure_model()

    def _ensure_model(self):
        if self._model_load_attempted:
            return
        self._model_load_attempted = True
        try:
            from sentence_transformers import SentenceTransformer
            logger.info(f'[MLScoring] Loading model: {self.MODEL_NAME}')
            self._model = SentenceTransformer(self.MODEL_NAME)
            logger.info(f'[MLScoring] Model loaded successfully ✓')
        except Exception as exc:
            logger.warning(
                f'[MLScoring] Failed to load model "{self.MODEL_NAME}": {exc}. '
                f'Falling back to keyword-based scoring.'
            )
            self._model = None

    @property
    def is_available(self) -> bool:
        """True if the model loaded successfully."""
        self._ensure_model()
        return self._model is not None

    # ─────────────────────────────────────────────────────────────────────────
    # Core ML methods
    # ─────────────────────────────────────────────────────────────────────────

    def compute_role_match(
        self,
        text: str,
        role_name: str,
        role_keywords: List[str],
        role_guidance: str = '',
    ) -> Dict:
        """
        Compute how semantically relevant `text` is to a target role.

        Args:
            text:           The CV bullet point or section text.
            role_name:      e.g. "Software Engineer"
            role_keywords:  priority_keywords from RoleIntelligenceConfig
            role_guidance:  role_specific_summary_guidance (optional)

        Returns:
            {
              'score':      int  0-100  (100 = perfect role match)
              'similarity': float       raw cosine similarity
              'confidence': str         'high' | 'medium' | 'low'
              'method':     str         'semantic' | 'fallback'
            }
        """
        self._ensure_model()
        if not self.is_available:
            return {'score': 50, 'similarity': 0.5, 'confidence': 'low', 'method': 'fallback'}

        role_context = self._build_role_context(role_name, role_keywords, role_guidance)
        role_embedding = self._get_role_embedding(role_name, role_context)
        text_embedding = self._encode(text)

        from sentence_transformers import util
        similarity = float(util.cos_sim(text_embedding, role_embedding))

        score = self._sim_to_score(similarity)
        confidence = 'high' if similarity > 0.50 else 'medium' if similarity > 0.35 else 'low'

        return {
            'score': score,
            'similarity': round(similarity, 3),
            'confidence': confidence,
            'method': 'semantic',
        }

    def compute_summary_role_fit(
        self,
        summary_text: str,
        role_name: str,
        role_keywords: List[str],
        role_guidance: str = '',
    ) -> Dict:
        """
        Same as compute_role_match but tuned for longer summary text.
        Summary sentences naturally have higher baseline similarity, so we
        adjust the normalization window slightly.
        """
        result = self.compute_role_match(
            text=summary_text,
            role_name=role_name,
            role_keywords=role_keywords,
            role_guidance=role_guidance,
        )
        # Summaries typically score higher — re-scale so the UX feels consistent
        result['score'] = min(100, int(result['score'] * 1.15))
        return result

    def extract_skills_semantic(
        self,
        text: str,
        candidate_skills: List[str],
        threshold: float = 0.45,
    ) -> List[str]:
        """
        Find skills in text using semantic similarity.
        Handles aliases: "React.js" matches "React", "ML" matches "machine learning".

        Falls back to exact string matching if model unavailable.
        """
        self._ensure_model()
        if not self.is_available:
            return self._keyword_extract_skills(text, candidate_skills)

        matched = []
        text_lower = text.lower()

        # Fast path: exact match first (avoids embedding overhead)
        exact_matched = set()
        for skill in candidate_skills:
            if skill.lower() in text_lower:
                matched.append(skill)
                exact_matched.add(skill)

        # Semantic pass for the rest
        remaining = [s for s in candidate_skills if s not in exact_matched]
        if not remaining:
            return matched

        try:
            from sentence_transformers import util
            text_emb = self._encode(text)
            for skill in remaining:
                skill_emb = self._encode(skill)
                sim = float(util.cos_sim(text_emb, skill_emb))
                if sim >= threshold:
                    matched.append(skill)
        except Exception as exc:
            logger.warning(f'[MLScoring] Skill extraction failed: {exc}')

        return matched

    def compare_texts(self, text1: str, text2: str) -> float:
        """Raw cosine similarity between two texts. Returns 0.0–1.0."""
        self._ensure_model()
        if not self.is_available:
            return 0.5
        from sentence_transformers import util
        return float(util.cos_sim(self._encode(text1), self._encode(text2)))

    # ─────────────────────────────────────────────────────────────────────────
    # Private helpers
    # ─────────────────────────────────────────────────────────────────────────

    def _encode(self, text: str):
        """Encode text to embedding tensor."""
        return self._model.encode(text, convert_to_tensor=True)

    def _build_role_context(
        self,
        role_name: str,
        role_keywords: List[str],
        role_guidance: str,
    ) -> str:
        """Build a rich role description string for embedding."""
        parts = [f'{role_name} professional.']
        if role_keywords:
            parts.append(f'Key skills: {", ".join(role_keywords[:12])}.')
        if role_guidance:
            parts.append(role_guidance)
        return ' '.join(parts)

    def _get_role_embedding(self, role_name: str, role_context: str):
        """Get cached role embedding or compute and cache it.
        Gracefully falls back to direct computation if Django cache unavailable."""
        cache_key = f'{self.ROLE_EMBED_CACHE_PREFIX}:{role_name.lower().replace(" ", "_")}'
        try:
            from django.core.cache import cache as django_cache
            cached = django_cache.get(cache_key)
            if cached is not None:
                return cached
            embedding = self._encode(role_context)
            django_cache.set(cache_key, embedding, self.ROLE_EMBED_CACHE_TTL)
            return embedding
        except Exception:
            # Cache unavailable (e.g. running outside Django context) — compute directly
            return self._encode(role_context)

    def _sim_to_score(self, similarity: float) -> int:
        """
        Normalize cosine similarity to 0-100 score.
        0.20 similarity  →  0 points
        0.65 similarity  → 100 points
        """
        normalized = (similarity - self.SIM_MIN) / (self.SIM_MAX - self.SIM_MIN)
        return max(0, min(100, int(normalized * 100)))

    @staticmethod
    def _keyword_extract_skills(text: str, candidate_skills: List[str]) -> List[str]:
        """Exact-string fallback for skill extraction."""
        text_lower = text.lower()
        return [s for s in candidate_skills if s.lower() in text_lower]
