from dataclasses import dataclass, field
from typing import Dict, List, Any

@dataclass
class ResumeContext:
    """
    Strongly typed context object passed through the Resume Intelligence Pipeline.
    Contains strictly defined fields to prevent arbitrary dictionary manipulation.
    """
    resume_data: Dict[str, Any] = field(default_factory=dict)
    normalized_data: Dict[str, Any] = field(default_factory=dict)
    warnings: List[Dict[str, Any]] = field(default_factory=list)
    errors: List[Dict[str, Any]] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    logs: List[str] = field(default_factory=list)

    def add_log(self, message: str) -> None:
        """Appends an execution log."""
        self.logs.append(message)
        
    def add_warning(self, message: str, section: str = 'general') -> None:
        """Appends an advisory warning."""
        self.warnings.append({'section': section, 'message': message})
        
    def add_error(self, message: str, section: str = 'general') -> None:
        """Appends a critical error that may halt processing or generation."""
        self.errors.append({'section': section, 'message': message})
