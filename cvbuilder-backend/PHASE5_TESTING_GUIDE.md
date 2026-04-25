# EduCV Phase 5 - Admin Dashboard API Testing Guide

## Prerequisites

1. **Server Running**: `python manage.py runserver`
2. **Database**: MySQL with existing student data
3. **Admin Account**: Create an admin user in the database

### Create Admin User (Run in Django Shell)

```python
python manage.py shell

from apps.users.models import User
admin = User.objects.create_user(
    email='admin@university.edu',
    password='admin123',
    full_name='System Administrator',
    role='admin'
)
admin.save()
```

---

## Postman Collection Setup

### Environment Variables

Create a Postman environment with these variables:

```
BASE_URL: http://127.0.0.1:8000/api/v1
ADMIN_TOKEN: (will be set after login)
STUDENT_TOKEN: (will be set after student login)
ADMIN_ID: (will be set after login)
STUDENT_ID: (will be set after student login)
```

---

## Test Sequence

### 1. Admin Authentication

#### 1.1 Admin Login
```
POST {{BASE_URL}}/auth/login/
Content-Type: application/json

{
    "email": "admin@university.edu",
    "password": "admin123"
}
```

**Expected Response:**
```json
{
    "success": true,
    "message": "Login successful.",
    "data": {
        "access": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "refresh": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
        "user": {
            "id": "uuid-here",
            "email": "admin@university.edu",
            "full_name": "System Administrator",
            "role": "admin"
        }
    }
}
```

**Post-Response Script:**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("ADMIN_TOKEN", response.data.access);
    pm.environment.set("ADMIN_ID", response.data.user.id);
}
```

#### 1.2 Student Login (for testing unauthorized access)
```
POST {{BASE_URL}}/auth/login/
Content-Type: application/json

{
    "email": "student@university.edu",
    "password": "student123"
}
```

**Post-Response Script:**
```javascript
if (pm.response.code === 200) {
    const response = pm.response.json();
    pm.environment.set("STUDENT_TOKEN", response.data.access);
    pm.environment.set("STUDENT_ID", response.data.user.id);
}
```

---

### 2. Platform Statistics Tests

#### 2.1 Platform Overview
```
GET {{BASE_URL}}/admin/stats/overview/
Authorization: Bearer {{ADMIN_TOKEN}}
```

**Expected Response:**
```json
{
    "success": true,
    "message": "Platform overview statistics retrieved successfully.",
    "data": {
        "students": {
            "total": 1200,
            "active": 1150,
            "suspended": 30,
            "deactivated": 20,
            "new_today": 15,
            "new_this_week": 87,
            "new_this_month": 340
        },
        "cvs": {
            "total_generated": 4500,
            "generated_today": 120,
            "generated_this_week": 780,
            "generated_this_month": 2100,
            "total_downloads": 9800,
            "most_popular_template": "modern"
        },
        "platform": {
            "total_audit_logs": 25000,
            "deletion_requests_pending": 3,
            "students_with_complete_cv": 890,
            "average_completion_percentage": 72
        }
    }
}
```

#### 2.2 Template Statistics
```
GET {{BASE_URL}}/admin/stats/templates/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 2.3 Growth Statistics (Monthly)
```
GET {{BASE_URL}}/admin/stats/growth/?period=monthly
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 2.4 Growth Statistics (Weekly)
```
GET {{BASE_URL}}/admin/stats/growth/?period=weekly
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 2.5 Growth Statistics (Daily)
```
GET {{BASE_URL}}/admin/stats/growth/?period=daily
Authorization: Bearer {{ADMIN_TOKEN}}
```

---

### 3. Student Management Tests

#### 3.1 List All Students
```
GET {{BASE_URL}}/admin/students/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.2 List Students with Search
```
GET {{BASE_URL}}/admin/students/?search=john
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.3 Filter Students by Status
```
GET {{BASE_URL}}/admin/students/?status=active
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.4 Students with Ordering
```
GET {{BASE_URL}}/admin/students/?ordering=-created_at
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.5 Students Pagination
```
GET {{BASE_URL}}/admin/students/?page=2&page_size=10
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.6 Get Student Detail
```
GET {{BASE_URL}}/admin/students/{{STUDENT_ID}}/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.7 Get Student CV Data
```
GET {{BASE_URL}}/admin/students/{{STUDENT_ID}}/cv/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.8 Update Student Status
```
PATCH {{BASE_URL}}/admin/students/{{STUDENT_ID}}/status/
Authorization: Bearer {{ADMIN_TOKEN}}
Content-Type: application/json

{
    "status": "suspended",
    "reason": "Violated terms of service"
}
```

#### 3.9 List Deletion Requests
```
GET {{BASE_URL}}/admin/students/deletion-requests/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 3.10 Process Deletion Request
```
POST {{BASE_URL}}/admin/students/{{STUDENT_ID}}/process-deletion/
Authorization: Bearer {{ADMIN_TOKEN}}
```

---

### 4. CV & PDF Management Tests

#### 4.1 List All Generated CVs
```
GET {{BASE_URL}}/admin/cvs/generated/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 4.2 Filter CVs by Template
```
GET {{BASE_URL}}/admin/cvs/generated/?template=modern
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 4.3 Filter CVs by Student
```
GET {{BASE_URL}}/admin/cvs/generated/?student_id={{STUDENT_ID}}
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 4.4 Popular Sections Statistics
```
GET {{BASE_URL}}/admin/cvs/stats/popular-sections/
Authorization: Bearer {{ADMIN_TOKEN}}
```

---

### 5. Audit Log Tests

#### 5.1 List All Audit Logs
```
GET {{BASE_URL}}/admin/audit-logs/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 5.2 Filter Audit Logs by Action
```
GET {{BASE_URL}}/admin/audit-logs/?action=login
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 5.3 Filter Audit Logs by Student
```
GET {{BASE_URL}}/admin/audit-logs/?student_id={{STUDENT_ID}}
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 5.4 Filter Audit Logs by Date Range
```
GET {{BASE_URL}}/admin/audit-logs/?from_date=2024-01-01&to_date=2024-12-31
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 5.5 Security Audit Logs
```
GET {{BASE_URL}}/admin/audit-logs/security/
Authorization: Bearer {{ADMIN_TOKEN}}
```

---

### 6. Health Check Tests

#### 6.1 Basic Health Check (No Auth Required)
```
GET {{BASE_URL}}/admin/health/
```

**Expected Response:**
```json
{
    "success": true,
    "message": "System is healthy",
    "data": {
        "status": "healthy",
        "version": "1.0.0",
        "database": "connected",
        "media_storage": "accessible",
        "timestamp": "2024-01-15T10:30:00Z"
    }
}
```

#### 6.2 Detailed Health Check (Admin Only)
```
GET {{BASE_URL}}/admin/health/detailed/
Authorization: Bearer {{ADMIN_TOKEN}}
```

---

### 7. Security Tests

#### 7.1 Student Tries to Access Admin Endpoint (Should Fail)
```
GET {{BASE_URL}}/admin/stats/overview/
Authorization: Bearer {{STUDENT_TOKEN}}
```

**Expected Response:**
```json
{
    "success": false,
    "message": "You do not have permission to perform this action.",
    "error": {
        "message": "You do not have permission to perform this action.",
        "details": {}
    }
}
```

#### 7.2 Unauthenticated Access (Should Fail)
```
GET {{BASE_URL}}/admin/stats/overview/
```

**Expected Response:**
```json
{
    "success": false,
    "message": "Authentication credentials were not provided.",
    "error": {
        "message": "Authentication credentials were not provided.",
        "details": {}
    }
}
```

#### 7.3 Admin Cannot Change Own Status
```
PATCH {{BASE_URL}}/admin/students/{{ADMIN_ID}}/status/
Authorization: Bearer {{ADMIN_TOKEN}}
Content-Type: application/json

{
    "status": "suspended",
    "reason": "Testing"
}
```

**Expected Response:**
```json
{
    "success": false,
    "message": "Cannot change your own account status.",
    "error": {
        "message": "Cannot change your own account status.",
        "details": {}
    }
}
```

---

### 8. Error Handling Tests

#### 8.1 Invalid Student ID
```
GET {{BASE_URL}}/admin/students/invalid-uuid/
Authorization: Bearer {{ADMIN_TOKEN}}
```

#### 8.2 Invalid Status Transition
```
PATCH {{BASE_URL}}/admin/students/{{STUDENT_ID}}/status/
Authorization: Bearer {{ADMIN_TOKEN}}
Content-Type: application/json

{
    "status": "invalid_status"
}
```

#### 8.3 Missing Required Fields
```
PATCH {{BASE_URL}}/admin/students/{{STUDENT_ID}}/status/
Authorization: Bearer {{ADMIN_TOKEN}}
Content-Type: application/json

{}
```

---

## Test Validation Checklist

### ✅ Authentication & Authorization
- [ ] Admin can login successfully
- [ ] Student cannot access admin endpoints (403 Forbidden)
- [ ] Unauthenticated requests are rejected (401 Unauthorized)
- [ ] Admin cannot modify their own account

### ✅ Platform Statistics
- [ ] Overview statistics return correct data structure
- [ ] Template statistics show all 3 templates
- [ ] Growth statistics work for all periods (daily/weekly/monthly)
- [ ] All statistics use efficient database queries

### ✅ Student Management
- [ ] Student list with pagination works
- [ ] Search functionality works across name/email/student_id
- [ ] Status filtering works for all status types
- [ ] Student detail includes CV completion and history
- [ ] Status updates create audit log entries
- [ ] Deletion processing anonymizes data correctly

### ✅ CV & PDF Management
- [ ] Generated CV list shows all templates
- [ ] Filtering by template and student works
- [ ] Popular sections statistics are accurate
- [ ] Pagination works correctly

### ✅ Audit Logs
- [ ] All audit logs are accessible
- [ ] Filtering by action, student, and date works
- [ ] Security logs show only security-relevant actions
- [ ] Pagination handles large datasets

### ✅ Health Checks
- [ ] Basic health check works without authentication
- [ ] Detailed health check requires admin authentication
- [ ] Health status reflects actual system state

### ✅ Response Format
- [ ] All responses use standard envelope format
- [ ] Pagination metadata is included in list responses
- [ ] Error responses include proper error details
- [ ] Success messages are descriptive

### ✅ Performance
- [ ] List endpoints are paginated (never unbounded)
- [ ] Database queries use select_related/prefetch_related
- [ ] Statistics use aggregate functions, not Python loops
- [ ] Response times are acceptable (<500ms for most endpoints)

### ✅ Security Logging
- [ ] Unauthorized admin access attempts are logged to security.log
- [ ] Admin actions are logged to app.log
- [ ] IP addresses and user agents are captured
- [ ] Sensitive data is not logged

---

## Expected Log Entries

### app.log
```
[2024-01-15 10:30:00] INFO - Admin admin@university.edu accessed platform overview stats
[2024-01-15 10:31:00] INFO - Admin admin@university.edu accessed student list
[2024-01-15 10:32:00] INFO - Admin admin@university.edu changed student student@university.edu status from active to suspended. Reason: Violated terms of service
```

### security.log
```
[2024-01-15 10:33:00] WARNING - UNAUTHORIZED_ADMIN_ACCESS - Non-admin user student@university.edu attempted admin access - IP: 127.0.0.1 - Path: /api/v1/admin/stats/overview/ - User-Agent: PostmanRuntime/7.32.3
```

---

## Performance Benchmarks

| Endpoint | Expected Response Time | Max Records |
|----------|----------------------|-------------|
| Platform Overview | <200ms | N/A |
| Student List | <300ms | 20 per page |
| Generated CVs | <400ms | 20 per page |
| Audit Logs | <500ms | 50 per page |
| Health Check | <100ms | N/A |

---

This completes the comprehensive testing guide for Phase 5 Admin Dashboard APIs. All endpoints are now ready for production deployment in Phase 6.