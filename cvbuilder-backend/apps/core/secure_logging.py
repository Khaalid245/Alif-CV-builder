"""
Secure logging configuration for EduCV.
Sanitizes sensitive information and provides secure structured logging.
"""
import structlog
import logging
import re
from django.conf import settings
from apps.core.metrics import (
    record_security_event,
    record_login_attempt,
    record_pdf_generation,
    record_cv_update
)


class SensitiveDataFilter:
    """Filter to sanitize sensitive information from logs."""
    
    # Patterns for sensitive data
    SENSITIVE_PATTERNS = {
        'email': re.compile(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b'),
        'password': re.compile(r'(?i)(password|passwd|pwd)["\']?\s*[:=]\s*["\']?([^"\'\s,}]+)', re.IGNORECASE),
        'token': re.compile(r'(?i)(token|jwt|bearer)["\']?\s*[:=]\s*["\']?([A-Za-z0-9._-]{20,})', re.IGNORECASE),
        'api_key': re.compile(r'(?i)(api[_-]?key|apikey)["\']?\s*[:=]\s*["\']?([A-Za-z0-9._-]{20,})', re.IGNORECASE),
        'phone': re.compile(r'\b\+?1?[-.\s]?\(?[0-9]{3}\)?[-.\s]?[0-9]{3}[-.\s]?[0-9]{4}\b'),
        'ssn': re.compile(r'\b\d{3}-?\d{2}-?\d{4}\b'),
        'credit_card': re.compile(r'\b(?:\d{4}[-\s]?){3}\d{4}\b'),
    }
    
    @classmethod
    def sanitize_message(cls, message):
        """Sanitize sensitive data from log message."""
        if not isinstance(message, str):
            message = str(message)
        
        # Replace sensitive patterns
        for pattern_name, pattern in cls.SENSITIVE_PATTERNS.items():
            if pattern_name == 'email':
                # Partially mask emails: user@domain.com -> u***@d***.com
                message = pattern.sub(cls._mask_email, message)
            elif pattern_name in ['password', 'token', 'api_key']:
                # Completely redact credentials
                message = pattern.sub(r'\1=***REDACTED***', message)
            else:
                # Mask other sensitive data
                message = pattern.sub('***MASKED***', message)
        
        return message
    
    @staticmethod
    def _mask_email(match):
        """Partially mask email addresses."""
        email = match.group(0)
        try:
            local, domain = email.split('@')
            if len(local) > 2:
                masked_local = local[0] + '*' * (len(local) - 2) + local[-1]
            else:
                masked_local = '*' * len(local)
            
            domain_parts = domain.split('.')
            if len(domain_parts) > 1:
                masked_domain = domain_parts[0][0] + '*' * (len(domain_parts[0]) - 1)
                masked_domain += '.' + '.'.join(domain_parts[1:])
            else:
                masked_domain = '*' * len(domain)
            
            return f"{masked_local}@{masked_domain}"
        except:
            return "***MASKED_EMAIL***"


class SecureLogProcessor:
    """Structured log processor that sanitizes sensitive data."""
    
    def __call__(self, logger, method_name, event_dict):
        """Process log event and sanitize sensitive data."""
        # Sanitize the main message
        if 'event' in event_dict:
            event_dict['event'] = SensitiveDataFilter.sanitize_message(event_dict['event'])
        
        # Sanitize all string values in the event dict
        for key, value in event_dict.items():
            if isinstance(value, str):
                event_dict[key] = SensitiveDataFilter.sanitize_message(value)
            elif isinstance(value, dict):
                event_dict[key] = self._sanitize_dict(value)
        
        return event_dict
    
    def _sanitize_dict(self, data):
        """Recursively sanitize dictionary values."""
        if not isinstance(data, dict):
            return data
        
        sanitized = {}
        for key, value in data.items():
            if isinstance(value, str):
                sanitized[key] = SensitiveDataFilter.sanitize_message(value)
            elif isinstance(value, dict):
                sanitized[key] = self._sanitize_dict(value)
            else:
                sanitized[key] = value
        
        return sanitized


def configure_structlog():
    """Configure structured logging with security sanitization."""
    
    timestamper = structlog.processors.TimeStamper(fmt="ISO")
    
    shared_processors = [
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        timestamper,
        SecureLogProcessor(),  # Add security sanitization
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
    ]
    
    if settings.DEBUG:
        # Pretty printing for development
        shared_processors.append(structlog.dev.ConsoleRenderer())
    else:
        # JSON formatting for production
        shared_processors.append(structlog.processors.JSONRenderer())
    
    structlog.configure(
        processors=shared_processors,
        context_class=dict,
        logger_factory=structlog.stdlib.LoggerFactory(),
        wrapper_class=structlog.stdlib.BoundLogger,
        cache_logger_on_first_use=True,
    )


# Initialize structured logging
configure_structlog()

# Create structured loggers
app_logger = structlog.get_logger("educv.app")
security_logger = structlog.get_logger("educv.security")
performance_logger = structlog.get_logger("educv.performance")
business_logger = structlog.get_logger("educv.business")


class SecurityLogger:
    """Centralized security event logging with sanitization."""
    
    @staticmethod
    def log_login_attempt(user_email: str, success: bool, ip_address: str, user_agent: str):
        """Log login attempt with security context (email is sanitized)."""
        record_login_attempt(success)
        
        # Sanitize user agent to remove potential sensitive data
        sanitized_user_agent = SensitiveDataFilter.sanitize_message(user_agent)
        
        security_logger.info(
            "login_attempt",
            user_email_hash=hash(user_email),  # Use hash instead of actual email
            success=success,
            ip_address=ip_address,
            user_agent=sanitized_user_agent,
            event_type="authentication"
        )
        
        if not success:
            record_security_event("failed_login", "medium")
    
    @staticmethod
    def log_registration_attempt(user_email: str, success: bool, ip_address: str, error: str = None):
        """Log registration attempt (email is sanitized)."""
        security_logger.info(
            "registration_attempt",
            user_email_hash=hash(user_email),  # Use hash instead of actual email
            success=success,
            ip_address=ip_address,
            error=SensitiveDataFilter.sanitize_message(error) if error else None,
            event_type="registration"
        )
    
    @staticmethod
    def log_password_change(user_id: str, ip_address: str):
        """Log password change event (no sensitive data)."""
        security_logger.info(
            "password_change",
            user_id_hash=hash(user_id),  # Use hash instead of actual ID
            ip_address=ip_address,
            event_type="password_change"
        )
    
    @staticmethod
    def log_data_deletion_request(user_id: str, ip_address: str):
        """Log data deletion request (no sensitive data)."""
        security_logger.warning(
            "data_deletion_request",
            user_id_hash=hash(user_id),  # Use hash instead of actual ID
            ip_address=ip_address,
            event_type="data_deletion"
        )
        
        record_security_event("data_deletion_request", "high")
    
    @staticmethod
    def log_rate_limit_exceeded(endpoint: str, ip_address: str, user_id: str = None):
        """Log rate limit violation."""
        security_logger.warning(
            "rate_limit_exceeded",
            endpoint=endpoint,
            ip_address=ip_address,
            user_id_hash=hash(user_id) if user_id else None,
            event_type="rate_limit"
        )
        
        record_security_event("rate_limit_exceeded", "medium")


class BusinessLogger:
    """Business event logging with sanitization."""
    
    @staticmethod
    def log_pdf_generation(user_id: str, template_type: str, duration: float, success: bool, error: str = None):
        """Log PDF generation event (no sensitive data)."""
        record_pdf_generation(template_type, duration, success, error)
        
        business_logger.info(
            "pdf_generation",
            user_id_hash=hash(user_id),  # Use hash instead of actual ID
            template_type=template_type,
            duration_seconds=duration,
            success=success,
            error=SensitiveDataFilter.sanitize_message(error) if error else None,
            event_type="pdf_generation"
        )
    
    @staticmethod
    def log_cv_update(user_id: str, section: str, completion_percentage: int):
        """Log CV profile update (no sensitive data)."""
        record_cv_update(section)
        
        business_logger.info(
            "cv_update",
            user_id_hash=hash(user_id),  # Use hash instead of actual ID
            section=section,
            completion_percentage=completion_percentage,
            event_type="cv_update"
        )
    
    @staticmethod
    def log_cv_download(user_id: str, template_type: str, cv_id: str):
        """Log CV download event (no sensitive data)."""
        business_logger.info(
            "cv_download",
            user_id_hash=hash(user_id),  # Use hash instead of actual ID
            template_type=template_type,
            cv_id_hash=hash(cv_id),  # Use hash instead of actual CV ID
            event_type="cv_download"
        )


class PerformanceLogger:
    """Performance monitoring with sanitized data."""
    
    @staticmethod
    def log_slow_request(path: str, method: str, duration: float, user_id: str = None):
        """Log slow HTTP requests (path is sanitized)."""
        # Sanitize path to remove potential sensitive parameters
        sanitized_path = SensitiveDataFilter.sanitize_message(path)
        
        performance_logger.warning(
            "slow_request",
            path=sanitized_path,
            method=method,
            duration_seconds=duration,
            user_id_hash=hash(user_id) if user_id else None,
            event_type="performance"
        )
    
    @staticmethod
    def log_database_query(query: str, duration: float, rows_affected: int = None):
        """Log slow database queries (query is sanitized)."""
        if duration > 1.0:  # Log queries taking more than 1 second
            # Sanitize query to remove potential sensitive data
            sanitized_query = SensitiveDataFilter.sanitize_message(query[:200])
            
            performance_logger.warning(
                "slow_query",
                query=sanitized_query,
                duration_seconds=duration,
                rows_affected=rows_affected,
                event_type="database"
            )


class ApplicationLogger:
    """General application event logging with sanitization."""
    
    @staticmethod
    def log_error(error: Exception, context: dict = None):
        """Log application errors with sanitized context."""
        sanitized_context = {}
        if context:
            for key, value in context.items():
                if isinstance(value, str):
                    sanitized_context[key] = SensitiveDataFilter.sanitize_message(value)
                else:
                    sanitized_context[key] = value
        
        app_logger.error(
            "application_error",
            error_type=type(error).__name__,
            error_message=SensitiveDataFilter.sanitize_message(str(error)),
            context=sanitized_context,
            event_type="error"
        )
    
    @staticmethod
    def log_startup():
        """Log application startup."""
        app_logger.info(
            "application_startup",
            event_type="startup"
        )
    
    @staticmethod
    def log_shutdown():
        """Log application shutdown."""
        app_logger.info(
            "application_shutdown",
            event_type="shutdown"
        )