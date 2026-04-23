# EduCV — University CV Builder Platform

> Built for a university, proposed by the dean, to solve a real problem students face every day.

---

## The Problem

University students know their own information — their education, skills, experience, and projects. But most of them have no idea how to present it professionally. They struggle with formatting, layout, and design. They submit CVs that look unprofessional, miss opportunities, and don't reflect their actual potential.

This platform was built to fix that.

---

## What It Does

A student fills in their information once. The platform automatically generates **3 professionally designed CVs** as ready-to-download PDFs — formatted, structured, and print-ready. No design skills needed. No Word templates. No guessing.

```
Student fills in their info once
              ↓
Platform generates 3 PDF templates simultaneously
              ↓
Student downloads and submits to employers
```

---

## The 3 CV Templates

| Template | Style | Best For |
|----------|-------|----------|
| **Classic** | Two-column layout, navy blue sidebar | Corporate, government, formal institutions |
| **Modern** | Clean single-column, teal header | Tech companies, startups, creative roles |
| **Academic** | Structured formal layout, burgundy accents | Research positions, scholarships, postgraduate |

---

## Who Uses It

| User | What They Do |
|------|-------------|
| **Students** | Fill in their CV data, generate and download 3 professional PDFs |
| **Admin** | Manage the platform, view statistics, process deletion requests |

---

## Project Structure

```
Alif-CV-builder/
├── cvbuilder-backend/       ← Django REST API (Phases 1–6)
│   ├── apps/
│   │   ├── core/            ← Shared utilities, responses, permissions
│   │   ├── users/           ← Authentication, consent, audit logs
│   │   ├── cv/              ← CV data models and APIs
│   │   ├── pdf_generator/   ← PDF generation service and templates
│   │   └── administration/  ← Admin dashboard (Phase 5)
│   ├── config/
│   │   └── settings/        ← base / development / production
│   ├── logs/                ← app.log + security.log (rotating)
│   └── media/               ← Generated student PDFs
│
└── cvbuilder-flutter/       ← Flutter app (Phases 7–11) [coming soon]
```

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| Backend | Django 4.2 + DRF | Mature, secure, production-proven |
| Database | MySQL 8.0 | Reliable relational storage with utf8mb4 |
| Authentication | JWT (simplejwt) | Stateless, scalable, mobile-friendly |
| PDF Generation | WeasyPrint | HTML/CSS templates → print-quality PDFs |
| Environment | python-decouple | Clean .env management, no hardcoded secrets |
| Audit Logging | django-auditlog | Every action tracked with IP and timestamp |
| Frontend | Flutter | Single codebase for web and mobile |
| Deployment | DigitalOcean + Docker | Scalable, containerized production server |

---

## API Endpoints

All endpoints live under `/api/v1/`

### Authentication

```
POST   /api/v1/auth/register/          Register with mandatory consent
POST   /api/v1/auth/login/             Login, receive JWT tokens
POST   /api/v1/auth/token/refresh/     Refresh access token
POST   /api/v1/auth/logout/            Blacklist refresh token
GET    /api/v1/auth/profile/           Get own profile
PUT    /api/v1/auth/profile/update/    Update own profile
POST   /api/v1/auth/change-password/   Change password
POST   /api/v1/auth/request-deletion/  Request data deletion
```

### CV Data

```
GET/PUT    /api/v1/cv/profile/                  Full nested CV
GET        /api/v1/cv/completion/               Completion percentage
GET/POST   /api/v1/cv/education/                List or add education
PUT/DELETE /api/v1/cv/education/<id>/           Update or delete
GET/POST   /api/v1/cv/experience/               List or add experience
PUT/DELETE /api/v1/cv/experience/<id>/          Update or delete
GET/POST   /api/v1/cv/skills/                   List or add skills
PUT/DELETE /api/v1/cv/skills/<id>/              Update or delete
GET/POST   /api/v1/cv/languages/                List or add languages
PUT/DELETE /api/v1/cv/languages/<id>/           Update or delete
GET/POST   /api/v1/cv/projects/                 List or add projects
PUT/DELETE /api/v1/cv/projects/<id>/            Update or delete
GET/POST   /api/v1/cv/certifications/           List or add certifications
PUT/DELETE /api/v1/cv/certifications/<id>/      Update or delete
```

### PDF Generation

```
POST   /api/v1/cv/generate/            Generate all 3 PDFs
GET    /api/v1/cv/download/<id>/       Download a specific PDF
GET    /api/v1/cv/history/             View past generated CVs
```

---

## Response Format

Every single endpoint returns the same structure — no exceptions.

```json
{
    "success": true,
    "message": "CV profile retrieved successfully.",
    "data": { }
}
```

```json
{
    "success": false,
    "message": "Validation failed.",
    "error": {
        "message": "Validation failed.",
        "details": { }
    }
}
```

---

## Security Standards

- UUID primary keys — no sequential IDs ever exposed
- JWT authentication on all protected routes
- Students can only access their own data — enforced on every single view
- Failed login attempts logged to `security.log` with IP address
- All refresh tokens blacklisted on logout and password change
- Soft delete only — student data is never permanently removed
- Rate limiting: anonymous 20/hour, authenticated 200/hour, PDF generation 10/hour
- Profile photo upload capped at 5MB to prevent memory exhaustion
- CORS restricted to Flutter app origins only

---

## Ethical Standards

This platform handles real student data. These are not optional features.

- Consent is mandatory — registration rejected without all three consent fields
- Consent timestamps stored as legal proof of agreement
- Students can request full deletion of their data at any time
- Every important action recorded in audit logs with timestamp, IP, and user agent
- Only data necessary for a CV is collected

---

## Getting Started

### Requirements

- Python 3.11+
- MySQL 8.0+
- GTK3 Runtime (Windows only — required for WeasyPrint)

### Setup

```bash
# 1. Clone
git clone <repo-url>
cd Alif-CV-builder/cvbuilder-backend

# 2. Virtual environment
python -m venv venv
venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install -r requirements.txt

# 4. Configure environment
cp .env.example .env
# Fill in your DB credentials and secret key

# 5. Create MySQL database
mysql -u root -p
CREATE DATABASE educv_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'educv_user'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON educv_db.* TO 'educv_user'@'localhost';
FLUSH PRIVILEGES;
exit

# 6. Run migrations
python manage.py makemigrations users
python manage.py migrate

# 7. Start server
python manage.py runserver
```

### WeasyPrint on Windows

```powershell
# Download GTK3 from:
# https://github.com/tschoonj/GTK-for-Windows-Runtime-Environment-Installer/releases
# Install with "Add to PATH" checked, then restart PowerShell

# If PATH not picked up automatically:
$env:PATH = "C:\Program Files\GTK3-Runtime Win64\bin;" + $env:PATH

# Verify
python -c "import weasyprint; print('WeasyPrint OK:', weasyprint.__version__)"
```

---

## Build Progress

```
✅ Phase 1  — Enterprise project setup & configuration
✅ Phase 2  — JWT authentication, consent, audit logs
✅ Phase 3  — CV data models & 22 APIs
✅ Phase 4  — PDF generation (3 templates via WeasyPrint)
⬜ Phase 5  — Admin dashboard APIs
⬜ Phase 6  — Testing & DigitalOcean deployment
⬜ Phase 7  — Flutter project setup & API service layer
⬜ Phase 8  — Authentication screens
⬜ Phase 9  — Multi-step CV form
⬜ Phase 10 — PDF preview & download
⬜ Phase 11 — Admin dashboard UI
```

---

## License

Commissioned by a university dean for official university deployment.
