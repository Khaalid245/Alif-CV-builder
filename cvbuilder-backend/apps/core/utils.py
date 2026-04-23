"""
Shared utility functions for EduCV.
Import from here — never redefine these in individual apps.
"""


def get_client_ip(request) -> str:
    """
    Extract the real client IP address from a request.
    Accounts for reverse proxies (nginx, DigitalOcean load balancer)
    by checking X-Forwarded-For before falling back to REMOTE_ADDR.
    """
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        return x_forwarded_for.split(',')[0].strip()
    return request.META.get('REMOTE_ADDR', '')
