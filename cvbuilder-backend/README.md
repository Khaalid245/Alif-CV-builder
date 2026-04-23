# EduCV — University CV Builder Platform

> A backend platform built for a university, proposed by the dean, to solve a real problem students face every day.

---

## The Problem

University students know their own information — their education, skills, experience, projects. But most of them have no idea how to present it professionally. They struggle with formatting, layout, and design. They submit CVs that look unprofessional, miss opportunities, and don't reflect their actual potential.

This platform was built to fix that.

---

## What It Does

A student fills in their information once. The platform automatically generates **3 professionally designed CVs** as ready-to-download PDFs — formatted, structured, and print-ready. No design skills needed. No Word templates. No guessing.

```
Student fills in their info
         ↓
Platform generates 3 PDF templates simultaneously
         ↓
Student downloads and submits to employers
```

---

## The 3 CV Templates

| Template | Style | Best For |
|----------|-------|----------|
| **Classic** | Two-column, navy sidebar | Corporate, government, formal institutions |
| **Modern** | Clean single-column, teal header | Tech companies, startups |
| **Academic** | Structured formal layout, burgundy accents | Research, scholarships, postgraduate |

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Backend | Django 4.2 + Django REST Framework |
| Database | MySQL with utf8mb4 |
| Authentication | JWT via djangorestframework-simplejwt |
| PDF Generation | WeasyPrint (HTML/CSS → PDF) |
| Environment | python-decouple (.env management) |
| Audit Logging | django-auditlog |
| Frontend (planned) | Flutter (web + mobile) |
| Deployment | DigitalOcean (Ubuntu, Docker) |

---

## Project Structure

```
cvbuilder-backend/
├── config/
│   ├── settings/
│   │   ├── base.py          # Shared settings
│   │   ├── development.py   # Dev overrides
│   │   └── production.py    # Production hardening
│   ├── urls.py
│   └── api_router.py        # All versioned routes
│
├── apps/
│   ├── core/                # Shared utilities
│   │   ├── exceptions.py    # Custom exception handler
│   │   ├── responses.py     # Standard response envelope
│   │   ├── permissions.py   # IsOwner, IsAdminUser
│   │   └── utils.py         # get_client_ip
│   │
│   ├── users/               # Authentication & user management
│   ├── cv/                  # CV data models & APIs
│   ├── pdf_generator/       # PDF generation service & templates
│   └── administration/      # Admin dashboard (Phase 5)
│
├── logs/
│   ├── app.log              # General application log
│   └── security.log         # Auth failures, suspicious activity
│
├── media/
│   └── generated_cvs/       # Student PDFs stored here
│
├── .env.example
├── requirements.txt
└── manage.py
```

---

## API Overview

All endpoints are versioned under `/api/v1/`

### Authentication — `/api/v1/auth/`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register/` | Register with mandatory consent |
| POST | `/login/` | Login, returns JWT tokens |
| POST | `/token/refresh/` | Refresh access token |
| POST | `/logout/` | Blacklist refresh token |
| GET | `/profile/` | Get own profile |
| PUT | `/profile/update/` | Update own profile |
| POST | `/change-password/` | Change password + invalidate all sessions |
| POST | `/request-deletion/` | Request data deletion |

### CV Data — `/api/v1/cv/`

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET/PUT | `/profile/` | Full nested CV with all sections |
| GET | `/completion/` | Completion percentage + checklist |
| GET/POST | `/education/` | List or add education |
| PUT/DELETE | `/education/<id>/` | Update or delete entry |
| GET/POST | `/experience/` | List or add experience |
| PUT/DELETE | `/experience/<id>/` | Update or delete entry |
| GET/POST | `/skills/` | List or add skills |
| PUT/DELETE | `/skills/<id>/` | Update or delete entry |
| GET/POST | `/languages/` | List or add languages |
| PUT/DELETE | `/languages/<id>/` | Update or delete entry |
| GET/POST | `/projects/` | List or add projects |
| PUT/DELETE | `/projects/<id>/` | Update or delete entry |
| GET/POST | `/certifications/` | List or add certifications |
| PUT/DELETE | `/certifications/<id>/` | Update or delete entry |

### PDF Generation — `/api/v1/cv/`

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/generate/` | Generate all 3 PDFs |
| GET | `/download/<id>/` | Download a specific PDF |
| GET | `/history/` | View past generated CVs |

---

## Standard Response Format

Every endpoint returns the same envelope — no exceptions.

```json
// Success
{
    "success": true,
    "message": "CV profile retrieved successfully.",
    "data": { ... }
}

// Error
{
    "success": false,
    "message": "Validation failed.",
    "error": {
        "message": "Validation failed.",
        "details": { ... }
    }
}
```

---

## Security

- UUID primary keys on every model — no sequential IDs exposed
- JWT authentication on all protected routes
- Students can only access their own data — enforced on every view
- Failed login attempts logged to `security.log` with IP address
- Refresh tokens blacklisted on logout and password change
- Soft delete only — student data is never hard deleted
- Consent timestamps stored as legal proof of agreement
- Rate limiting: anonymous 20/hour, authenticated 200/hour, PDF generation 10/hour
- Profile photo upload capped at 5MB
- CORS restricted to Flutter app origins only

---

## Ethical Standards

This platform handles student data. These are not optional features — they are requirements.

- **Consent is mandatory** — registration is rejected without accepting all three consent fields
- **Consent timestamps** are stored as legal proof
- **Data deletion requests** — students can request full deletion of their data
- **Soft delete only** — no data is permanently removed immediately
- **Audit logs** — every important action is recorded with timestamp, IP, and user agent
- **Data minimalism** — only what is needed for a CV is collected

---

## Getting Started

### Prerequisites

- Python 3.11+
- MySQL 8.0+
- GTK3 Runtime (Windows only, required for WeasyPrint)

### Setup

```bash
# Clone the repository
git clone <repo-url>
cd cvbuilder-backend

# Create virtual environment
python -m venv venv
venv\Scripts\Activate.ps1  # Windows

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your database credentials and secret key

# Create MySQL database
mysql -u root -p
CREATE DATABASE educv_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'educv_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON educv_db.* TO 'educv_user'@'localhost';
FLUSH PRIVILEGES;

# Run migrations
python manage.py makemigrations users
python manage.py migrate

# Start server
python manage.py runserver
```

### Windows — WeasyPrint Setup

WeasyPrint requires GTK3 on Windows.

1. Download from: https://github.com/tschoonj/GTK-for-Windows-Runtime-Environment-Installer/releases
2. Install with "Add to PATH" checked
3. Open a new PowerShell window
4. Add to PATH manually if needed:
```powershell
$env:PATH = "C:\Program Files\GTK3-Runtime Win64\bin;" + $env:PATH
```

---

## Environment Variables

```env
DJANGO_SECRET_KEY=your-secret-key
DJANGO_DEBUG=True
DJANGO_ENVIRONMENT=development
DJANGO_ALLOWED_HOSTS=localhost,127.0.0.1

DB_NAME=educv_db
DB_USER=educv_user
DB_PASSWORD=your-password
DB_HOST=127.0.0.1
DB_PORT=3306

JWT_ACCESS_TOKEN_LIFETIME=1440
JWT_REFRESH_TOKEN_LIFETIME=7

CORS_ALLOWED_ORIGINS=http://localhost:3000,http://localhost:8080

ANON_RATE_LIMIT=20/hour
USER_RATE_LIMIT=200/hour
PDF_GENERATION_RATE_LIMIT=10/hour
```

---

## What Has Been Built

### Phase 1 — Enterprise Project Setup
Full Django project structure with split settings, environment-based configuration, versioned API, custom exception handler, standard response envelope, rotating log files, rate limiting, and CORS.

### Phase 2 — Authentication System
Custom User model with UUID primary key, email-based login, role and status management, consent tracking with timestamps, soft delete, data deletion requests, full JWT authentication with token blacklisting, and security audit logging.

### Phase 3 — CV Data Layer
Eight models covering every section of a professional CV. Full CRUD on all sections with ownership enforcement, completion percentage tracking, and duplicate prevention at both database and serializer level.

### Phase 4 — PDF Generation
Service layer that fetches student data, renders it into three HTML/CSS templates, converts to PDF using WeasyPrint, saves to media storage, and returns download URLs. Includes photo-to-base64 conversion, atomic database writes, file handle safety, and generation rate limiting.

---

## What Is Coming

### Phase 5 — Admin Dashboard
University admin APIs to manage students, view platform statistics, process data deletion requests, and monitor CV generation activity.

### Phase 6 — Testing and Deployment
Full test suite, Docker configuration, and DigitalOcean deployment with Gunicorn and nginx.

### Phase 7–11 — Flutter Application
Mobile and web frontend covering authentication, multi-step CV form, PDF preview and download, and admin dashboard UI.

---

## Phases Roadmap

```
✅ Phase 1  — Enterprise project setup
✅ Phase 2  — JWT authentication
✅ Phase 3  — CV data models & APIs
✅ Phase 4  — PDF generation (3 templates)
⬜ Phase 5  — Admin dashboard APIs
⬜ Phase 6  — Testing & deployment
⬜ Phase 7  — Flutter setup & API layer
⬜ Phase 8  — Authentication screens
⬜ Phase 9  — CV form (multi-step)
⬜ Phase 10 — PDF preview & download
⬜ Phase 11 — Admin dashboard UI
```

---

## License

This project was proposed and commissioned by a university dean for official university use.
