"""
Refactored base settings with configurable hardcoded values.
All previously hardcoded values are now configurable via environment variables.
"""
from pathlib import Path
from datetime import timedelta
from decouple import config, Csv
from apps.core.config import AppConfig

# ─── Paths ────────────────────────────────────────────────────────────────────
BASE_DIR = Path(__file__).resolve().parent.parent.parent

# ─── Security ─────────────────────────────────────────────────────────────────
SECRET_KEY = config('DJANGO_SECRET_KEY')
ALLOWED_HOSTS = config('DJANGO_ALLOWED_HOSTS', cast=Csv())

# ─── Application Definition ───────────────────────────────────────────────────
DJANGO_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
]

THIRD_PARTY_APPS = [
    'rest_framework',
    'rest_framework_simplejwt',
    'rest_framework_simplejwt.token_blacklist',
    'corsheaders',
    'auditlog',
    'django_filters',
]

LOCAL_APPS = [
    'apps.core',
    'apps.users',
    'apps.cv',
    'apps.pdf_generator',
    'apps.administration',
    'apps.cv_intelligence',
    'apps.workflow',
    'apps.version_history',
    'apps.analytics',
    'apps.notifications',
    'apps.template_engine',
]

INSTALLED_APPS = DJANGO_APPS + THIRD_PARTY_APPS + LOCAL_APPS

# ─── Middleware ───────────────────────────────────────────────────────────────
MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'auditlog.middleware.AuditlogMiddleware',
]

ROOT_URLCONF = 'config.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [
            BASE_DIR / 'templates',
            BASE_DIR / 'apps' / 'pdf_generator' / 'templates',
        ],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'config.wsgi.application'

# ─── Database (MySQL with utf8mb4) ────────────────────────────────────────────
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.mysql',
        'NAME': config('DB_NAME'),
        'USER': config('DB_USER'),
        'PASSWORD': config('DB_PASSWORD'),
        'HOST': config('DB_HOST', default='127.0.0.1'),
        'PORT': config('DB_PORT', default='3306'),
        'OPTIONS': {
            'charset': 'utf8mb4',
            'init_command': "SET sql_mode='STRICT_TRANS_TABLES'",
        },
        'CONN_MAX_AGE': config('DB_CONN_MAX_AGE', default=60, cast=int),
    }
}

# ─── Custom User Model ────────────────────────────────────────────────────────
AUTH_USER_MODEL = 'users.User'

# ─── Password Validation ──────────────────────────────────────────────────────
AUTH_PASSWORD_VALIDATORS = [
    {'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator'},
    {'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
     'OPTIONS': {'min_length': config('PASSWORD_MIN_LENGTH', default=8, cast=int)}},
    {'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator'},
    {'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator'},
]

# ─── Internationalization ─────────────────────────────────────────────────────
LANGUAGE_CODE = config('LANGUAGE_CODE', default='en-us')
TIME_ZONE = config('TIME_ZONE', default='UTC')
USE_I18N = config('USE_I18N', default=True, cast=bool)
USE_TZ = config('USE_TZ', default=True, cast=bool)

# ─── Static & Media Files ─────────────────────────────────────────────────────
STATIC_URL = config('STATIC_URL', default='/static/')
STATIC_ROOT = BASE_DIR / config('STATIC_ROOT', default='staticfiles')

MEDIA_URL = config('MEDIA_URL', default='/media/')
MEDIA_ROOT = BASE_DIR / config('MEDIA_ROOT', default='media')
FRONTEND_URL = config('FRONTEND_URL', default='http://localhost:3000')

# ─── File Upload Limits (Now Configurable) ───────────────────────────────────
MAX_UPLOAD_SIZE = AppConfig.MAX_UPLOAD_SIZE
MAX_PROFILE_PHOTO_SIZE = AppConfig.MAX_PROFILE_PHOTO_SIZE
ALLOWED_IMAGE_FORMATS = AppConfig.ALLOWED_IMAGE_FORMATS

# ─── Default Primary Key ──────────────────────────────────────────────────────
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'

# ─── Django REST Framework (Now Configurable) ─────────────────────────────────
REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework_simplejwt.authentication.JWTAuthentication',
    ),
    'DEFAULT_PERMISSION_CLASSES': (
        'rest_framework.permissions.IsAuthenticated',
    ),
    'DEFAULT_FILTER_BACKENDS': (
        'django_filters.rest_framework.DjangoFilterBackend',
        'rest_framework.filters.SearchFilter',
        'rest_framework.filters.OrderingFilter',
    ),
    'DEFAULT_THROTTLE_CLASSES': [
        'rest_framework.throttling.AnonRateThrottle',
        'rest_framework.throttling.UserRateThrottle',
    ],
    'DEFAULT_THROTTLE_RATES': AppConfig.RATE_LIMITS,
    'DEFAULT_PAGINATION_CLASS': 'rest_framework.pagination.PageNumberPagination',
    'PAGE_SIZE': AppConfig.DEFAULT_PAGE_SIZE,
}

# ─── JWT Configuration ────────────────────────────────────────────────────────
SIMPLE_JWT = {
    'ACCESS_TOKEN_LIFETIME': timedelta(
        minutes=config('JWT_ACCESS_TOKEN_LIFETIME', default=60, cast=int)
    ),
    'REFRESH_TOKEN_LIFETIME': timedelta(
        days=config('JWT_REFRESH_TOKEN_LIFETIME', default=7, cast=int)
    ),
    'ROTATE_REFRESH_TOKENS': config('JWT_ROTATE_REFRESH_TOKENS', default=True, cast=bool),
    'BLACKLIST_AFTER_ROTATION': config('JWT_BLACKLIST_AFTER_ROTATION', default=True, cast=bool),
    'UPDATE_LAST_LOGIN': config('JWT_UPDATE_LAST_LOGIN', default=True, cast=bool),
    'ALGORITHM': config('JWT_ALGORITHM', default='HS256'),
    'AUTH_HEADER_TYPES': (config('JWT_AUTH_HEADER_TYPE', default='Bearer'),),
    'USER_ID_FIELD': 'id',
    'USER_ID_CLAIM': 'user_id',
}

# ─── CORS Configuration ───────────────────────────────────────────────────────
CORS_ALLOW_CREDENTIALS = config('CORS_ALLOW_CREDENTIALS', default=True, cast=bool)
CORS_ALLOW_HEADERS = config(
    'CORS_ALLOW_HEADERS',
    default='accept,accept-encoding,authorization,content-type,dnt,origin,user-agent,x-csrftoken,x-requested-with',
    cast=lambda v: v.split(',')
)

# ─── Logging Configuration (Now Configurable) ─────────────────────────────────
LOGS_DIR = BASE_DIR / config('LOGS_DIR', default='logs')
LOGS_DIR.mkdir(exist_ok=True)

LOG_FILE_MAX_BYTES = config('LOG_FILE_MAX_BYTES', default=1024 * 1024 * 10, cast=int)  # 10 MB
LOG_BACKUP_COUNT = config('LOG_BACKUP_COUNT', default=5, cast=int)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,

    'formatters': {
        'verbose': {
            'format': config(
                'LOG_FORMAT_VERBOSE',
                default='[{asctime}] {levelname} {name} {process:d} {thread:d} {message}'
            ),
            'style': '{',
        },
        'simple': {
            'format': config(
                'LOG_FORMAT_SIMPLE',
                default='[{asctime}] {levelname} {message}'
            ),
            'style': '{',
        },
    },

    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
            'formatter': 'simple',
        },
        'app_file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': LOGS_DIR / 'app.log',
            'maxBytes': LOG_FILE_MAX_BYTES,
            'backupCount': LOG_BACKUP_COUNT,
            'formatter': 'verbose',
            'encoding': 'utf-8',
        },
        'security_file': {
            'class': 'logging.handlers.RotatingFileHandler',
            'filename': LOGS_DIR / 'security.log',
            'maxBytes': LOG_FILE_MAX_BYTES,
            'backupCount': LOG_BACKUP_COUNT,
            'formatter': 'verbose',
            'encoding': 'utf-8',
        },
    },

    'loggers': {
        '': {
            'handlers': ['console', 'app_file'],
            'level': config('LOG_LEVEL', default='INFO'),
            'propagate': False,
        },
        'security': {
            'handlers': ['security_file', 'console'],
            'level': config('SECURITY_LOG_LEVEL', default='WARNING'),
            'propagate': False,
        },
        'django': {
            'handlers': ['console', 'app_file'],
            'level': config('DJANGO_LOG_LEVEL', default='WARNING'),
            'propagate': False,
        },
    },
}

# ─── Cache Configuration (Now Configurable) ───────────────────────────────────
CACHES = {
    'default': {
        'BACKEND': config('CACHE_BACKEND', default='django.core.cache.backends.locmem.LocMemCache'),
        'LOCATION': config('CACHE_LOCATION', default='unique-snowflake'),
        'TIMEOUT': AppConfig.CACHE_TIMEOUT_MEDIUM,
        'OPTIONS': {
            'MAX_ENTRIES': config('CACHE_MAX_ENTRIES', default=1000, cast=int),
        }
    }
}

# ─── Application-Specific Configuration ───────────────────────────────────────
# CV Intelligence Configuration
CV_INTELLIGENCE_CONFIG = AppConfig.get_cv_scoring_config()

# Template Configuration
TEMPLATE_TYPES = AppConfig.TEMPLATE_TYPES
DEFAULT_TEMPLATE = AppConfig.DEFAULT_TEMPLATE

# Business Rules Configuration
MAX_EXPERIENCE_ENTRIES = AppConfig.MAX_EXPERIENCE_ENTRIES
MAX_EDUCATION_ENTRIES = AppConfig.MAX_EDUCATION_ENTRIES
MAX_PROJECT_ENTRIES = AppConfig.MAX_PROJECT_ENTRIES
MAX_CERTIFICATION_ENTRIES = AppConfig.MAX_CERTIFICATION_ENTRIES

# Notification Configuration
NOTIFICATION_BATCH_SIZE = AppConfig.NOTIFICATION_BATCH_SIZE
NOTIFICATION_RETENTION_DAYS = AppConfig.NOTIFICATION_RETENTION_DAYS

# Analytics Configuration
ANALYTICS_RETENTION_DAYS = AppConfig.ANALYTICS_RETENTION_DAYS
SNAPSHOT_INTERVAL_HOURS = AppConfig.SNAPSHOT_INTERVAL_HOURS

# Audit Log Configuration
AUDIT_LOG_RETENTION_DAYS = AppConfig.AUDIT_LOG_RETENTION_DAYS
SECURITY_LOG_RETENTION_DAYS = AppConfig.SECURITY_LOG_RETENTION_DAYS