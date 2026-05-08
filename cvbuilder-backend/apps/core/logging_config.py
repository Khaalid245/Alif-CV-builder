"""
Structured logging configuration for EduCV.
Provides consistent, machine-readable logs for better observability.
"""
import structlog
import logging
from django.conf import settings
from apps.core.metrics import (
    record_security_event,
    record_login_attempt,
    record_pdf_generation,
    record_cv_update
)


def configure_structlog():
    """Configure structured logging with consistent formatting."""
    
    timestamper = structlog.processors.TimeStamper(fmt="ISO")
    
    shared_processors = [
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        timestamper,
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
    """Centralized security event logging with metrics integration."""
    
    @staticmethod
    def log_login_attempt(user_email: str, success: bool, ip_address: str, user_agent: str):
        """Log login attempt with security context."""
        record_login_attempt(success)
        
        security_logger.info(
            "login_attempt",
            user_email=user_email,
            success=success,
            ip_address=ip_address,
            user_agent=user_agent,
            event_type="authentication"
        )
        
        if not success:
            record_security_event("failed_login", "medium")
    
    @staticmethod
    def log_registration_attempt(user_email: str, success: bool, ip_address: str, error: str = None):
        """Log registration attempt."""
        security_logger.info(
            "registration_attempt",
            user_email=user_email,
            success=success,
            ip_address=ip_address,
            error=error,
            event_type="registration"
        )
    
    @staticmethod
    def log_password_change(user_id: str, ip_address: str):
        """Log password change event."""
        security_logger.info(
            "password_change",
            user_id=user_id,
            ip_address=ip_address,
            event_type="password_change"
        )
    
    @staticmethod
    def log_data_deletion_request(user_id: str, ip_address: str):
        """Log data deletion request."""
        security_logger.warning(
            "data_deletion_request",
            user_id=user_id,
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
            user_id=user_id,
            event_type="rate_limit"
        )
        
        record_security_event("rate_limit_exceeded", "medium")


class BusinessLogger:
    """Business event logging for analytics and monitoring."""
    
    @staticmethod
    def log_pdf_generation(user_id: str, template_type: str, duration: float, success: bool, error: str = None):
        """Log PDF generation event."""
        record_pdf_generation(template_type, duration, success, error)
        
        business_logger.info(
            "pdf_generation",
            user_id=user_id,
            template_type=template_type,
            duration_seconds=duration,
            success=success,
            error=error,
            event_type="pdf_generation"
        )
    
    @staticmethod
    def log_cv_update(user_id: str, section: str, completion_percentage: int):
        """Log CV profile update."""
        record_cv_update(section)
        
        business_logger.info(
            "cv_update",
            user_id=user_id,
            section=section,
            completion_percentage=completion_percentage,
            event_type="cv_update"
        )
    
    @staticmethod
    def log_cv_download(user_id: str, template_type: str, cv_id: str):
        """Log CV download event."""
        business_logger.info(
            "cv_download",
            user_id=user_id,
            template_type=template_type,
            cv_id=cv_id,
            event_type="cv_download"
        )


class PerformanceLogger:
    """Performance monitoring and slow query logging."""
    
    @staticmethod
    def log_slow_request(path: str, method: str, duration: float, user_id: str = None):
        """Log slow HTTP requests."""
        performance_logger.warning(
            "slow_request",
            path=path,
            method=method,
            duration_seconds=duration,
            user_id=user_id,
            event_type="performance"
        )
    
    @staticmethod
    def log_database_query(query: str, duration: float, rows_affected: int = None):
        """Log slow database queries."""
        if duration > 1.0:  # Log queries taking more than 1 second
            performance_logger.warning(
                "slow_query",
                query=query[:200],  # Truncate long queries
                duration_seconds=duration,
                rows_affected=rows_affected,
                event_type="database"
            )


class ApplicationLogger:
    """General application event logging."""
    
    @staticmethod
    def log_error(error: Exception, context: dict = None):
        """Log application errors with context."""
        app_logger.error(
            "application_error",
            error_type=type(error).__name__,
            error_message=str(error),
            context=context or {},
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