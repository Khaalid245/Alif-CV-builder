from .provider import AIEngineProvider
from .enterprise_heuristics import EnterpriseHeuristicsProvider
from .openai_provider import OpenAIProvider

def get_ai_engine() -> AIEngineProvider:
    """Factory method to return the active AI engine."""
    # For now, default to the EnterpriseHeuristicsProvider.
    # In the future, this can check settings.py to return OpenAIProvider if an API key exists.
    return EnterpriseHeuristicsProvider()
