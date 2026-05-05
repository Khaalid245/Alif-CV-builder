"""
Shared utility functions for EduCV.
Import from here — never redefine these in individual apps.
"""


def get_client_ip(request) -> str:
    """
    Extract the real client IP address from a request.

    In production behind nginx/DigitalOcean, X-Forwarded-For is set by the
    proxy and looks like: "client_ip, proxy1_ip, proxy2_ip".
    We take the LAST entry added by our own trusted proxy, not the first
    (which is client-controlled and can be spoofed).

    In development with no proxy, falls back to REMOTE_ADDR.
    """
    x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
    if x_forwarded_for:
        # Last IP is appended by our trusted proxy — cannot be spoofed
        return x_forwarded_for.split(',')[-1].strip()
    return request.META.get('REMOTE_ADDR', '')
