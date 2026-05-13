# EduCV Deployment Guide

## Table of Contents
1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Database Configuration](#database-configuration)
4. [Backend Deployment](#backend-deployment)
5. [Frontend Deployment](#frontend-deployment)
6. [Monitoring & Observability](#monitoring--observability)
7. [Security Hardening](#security-hardening)
8. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

### Critical Requirements
- [ ] Django `DEBUG=False` in production
- [ ] Strong `DJANGO_SECRET_KEY` (50+ chars, randomly generated)
- [ ] Unique database credentials
- [ ] SSL/TLS certificates obtained (Let's Encrypt or similar)
- [ ] Email service credentials configured
- [ ] Sentry DSN configured for error tracking
- [ ] S3/Storage bucket for file uploads
- [ ] Redis instance for caching/sessions
- [ ] All `.env` files removed from Git

### Security Verification
```bash
python manage.py check --deploy
```

This command runs security checks. It should complete with NO errors.

---

## Environment Setup

### 1. Clone Repository
```bash
git clone https://github.com/yourorg/alif-cv-builder.git
cd alif-cv-builder
cd cvbuilder-backend
```

### 2. Create Virtual Environment
```bash
python3 -m venv venv
source venv/bin/activate  # Linux/Mac
# or
venv\Scripts\activate  # Windows
```

### 3. Install Dependencies
```bash
pip install -r requirements.txt
```

### 4. Configure Environment Variables
```bash
# Copy the example file
cp .env.example .env

# Edit .env with your production values
nano .env
```

**Required variables for production:**
```ini
DJANGO_ENVIRONMENT=production
DJANGO_DEBUG=False
DJANGO_SECRET_KEY=<generate-new-key>
DJANGO_ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com

DB_NAME=educv_production
DB_USER=<strong-username>
DB_PASSWORD=<strong-password>
DB_HOST=db.example.com
DB_PORT=3306

JWT_ACCESS_TOKEN_LIFETIME=30
JWT_REFRESH_TOKEN_LIFETIME=14

EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USE_TLS=True
EMAIL_HOST_USER=<your-email>
EMAIL_HOST_PASSWORD=<app-password>

SENTRY_DSN=<your-sentry-dsn>
SENTRY_ENVIRONMENT=production

AWS_ACCESS_KEY_ID=<your-aws-key>
AWS_SECRET_ACCESS_KEY=<your-aws-secret>
AWS_STORAGE_BUCKET_NAME=educv-uploads
```

### 5. Generate Django Secret Key
```bash
python -c "from django.core.management.utils import get_random_secret_key; print(get_random_secret_key())"
```

---

## Database Configuration

### 1. MySQL Setup
```bash
# Create database
mysql -u root -p
> CREATE DATABASE educv_production CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
> CREATE USER 'educv_user'@'localhost' IDENTIFIED BY 'strong_password_here';
> GRANT ALL PRIVILEGES ON educv_production.* TO 'educv_user'@'localhost';
> FLUSH PRIVILEGES;
```

### 2. Configure MySQL Parameters
```bash
# For optimal connection pooling
mysql -u root -p
> SET GLOBAL wait_timeout = 60;
> SET GLOBAL max_connections = 1000;
> SET GLOBAL max_allowed_packet = 16M;
```

### 3. Run Migrations
```bash
python manage.py migrate
```

### 4. Verify Database Health
```bash
python manage.py dbshell
> SELECT VERSION();
> SHOW VARIABLES LIKE 'wait_timeout';
```

---

## Backend Deployment

### 1. Collect Static Files
```bash
python manage.py collectstatic --noinput
```

### 2. Verify Configuration
```bash
# Run all security checks
python manage.py check --deploy

# Run system checks
python manage.py check

# Test email configuration
python manage.py shell
>>> from django.core.mail import send_mail
>>> send_mail('Test', 'Test', 'from@example.com', ['to@example.com'])
```

### 3. Create Admin User
```bash
python manage.py create_test_user \
  --email admin@yourdomain.com \
  --full-name "Admin User" \
  --role admin \
  --verified
```

### 4. Deploy with Gunicorn
```bash
# Create systemd service file: /etc/systemd/system/educv.service
[Unit]
Description=EduCV API Server
After=network.target

[Service]
Type=notify
User=educv
WorkingDirectory=/var/www/educv/cvbuilder-backend
Environment="PATH=/var/www/educv/cvbuilder-backend/venv/bin"
ExecStart=/var/www/educv/cvbuilder-backend/venv/bin/gunicorn \
  --workers 4 \
  --worker-class sync \
  --bind 127.0.0.1:8000 \
  --timeout 120 \
  --access-logfile /var/log/educv/access.log \
  --error-logfile /var/log/educv/error.log \
  config.wsgi:application

[Install]
WantedBy=multi-user.target

# Enable and start service
sudo systemctl enable educv
sudo systemctl start educv
sudo systemctl status educv
```

### 5. Configure Nginx Reverse Proxy
```nginx
# /etc/nginx/sites-available/educv
upstream educv_backend {
    server 127.0.0.1:8000;
}

server {
    listen 80;
    server_name api.yourdomain.com;
    
    # Redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name api.yourdomain.com;
    
    # SSL certificates
    ssl_certificate /etc/letsencrypt/live/api.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.yourdomain.com/privkey.pem;
    
    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    
    # Proxy configuration
    location / {
        proxy_pass http://educv_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 120s;
        proxy_read_timeout 120s;
    }
    
    # Static files
    location /static/ {
        alias /var/www/educv/cvbuilder-backend/staticfiles/;
        expires 365d;
    }
    
    # Media files
    location /media/ {
        alias /var/www/educv/cvbuilder-backend/media/;
        expires 7d;
    }
}
```

---

## Frontend Deployment

### 1. Build Flutter App
```bash
cd educv

# Update API URL for production
# Edit: assets/env/.env
API_BASE_URL=https://api.yourdomain.com/api/v1

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS) - requires macOS
flutter build ios --release
```

### 2. Deploy to App Stores
- **Google Play**: Upload APK using Play Console
- **App Store**: Upload IPA using Xcode or App Store Connect

---

## Monitoring & Observability

### 1. Setup Prometheus
```bash
cd observability

# Copy environment file
cp .env.observability.example .env.observability

# Update with production credentials
nano .env.observability
```

### 2. Start Monitoring Stack
```bash
# Set strong Grafana password
export GRAFANA_ADMIN_PASSWORD="strong-password-here"
export GRAFANA_ADMIN_USER="admin"

# Start all services
docker-compose up -d

# Verify services
docker-compose ps
```

### 3. Configure Grafana Dashboards
1. Access Grafana: `https://monitoring.yourdomain.com:3000`
2. Login with admin credentials
3. Add Prometheus data source: `http://prometheus:9090`
4. Import dashboards from `grafana/dashboards/`

### 4. Setup Alerts
Edit `alertmanager/alertmanager.yml`:
```yaml
global:
  resolve_timeout: 5m

route:
  receiver: 'email'
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h

receivers:
- name: 'email'
  email_configs:
  - to: 'alerts@yourdomain.com'
    from: 'alertmanager@yourdomain.com'
    smarthost: 'smtp.gmail.com:587'
    auth_username: 'your-email@gmail.com'
    auth_password: 'app-password'
```

---

## Security Hardening

### 1. SSL/TLS Certificates
```bash
# Using Let's Encrypt
sudo certbot certonly --webroot -w /var/www/educv -d api.yourdomain.com

# Auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer
```

### 2. Firewall Configuration
```bash
# UFW (Uncomplicated Firewall)
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw enable
```

### 3. Database Backup
```bash
# Daily backup script
#!/bin/bash
BACKUP_DIR="/backups/mysql"
DATE=$(date +%Y%m%d_%H%M%S)

mysqldump \
  -u educv_user \
  -p${DB_PASSWORD} \
  --single-transaction \
  educv_production > ${BACKUP_DIR}/educv_${DATE}.sql

# Compress
gzip ${BACKUP_DIR}/educv_${DATE}.sql

# Cleanup old backups (keep 30 days)
find ${BACKUP_DIR} -name "*.sql.gz" -mtime +30 -delete

# Schedule with cron
0 2 * * * /scripts/backup-db.sh
```

### 4. Environment Security
```bash
# Store secrets in AWS Secrets Manager (recommended for production)
# Or use environment variables with restricted access

# File permissions
chmod 600 .env
chmod 700 /var/www/educv/cvbuilder-backend

# Disable root login
sudo passwd -l root

# Setup SSH key-based authentication only
# Disable password login in /etc/ssh/sshd_config
PasswordAuthentication no
```

---

## Troubleshooting

### Issue: 502 Bad Gateway
**Solution:**
```bash
# Check Gunicorn service
sudo systemctl status educv
sudo systemctl restart educv

# Check logs
tail -f /var/log/educv/error.log

# Verify Nginx proxy settings
sudo nginx -t
sudo systemctl restart nginx
```

### Issue: Database Connection Refused
**Solution:**
```bash
# Verify MySQL is running
sudo systemctl status mysql

# Check credentials
mysql -u educv_user -p -h db.example.com educv_production

# Check CONN_MAX_AGE setting
mysql wait_timeout value
```

### Issue: Email Not Sending
**Solution:**
```bash
python manage.py shell
>>> from django.core.mail import send_mail
>>> send_mail('Test', 'Body', 'from@test.com', ['to@test.com'])

# If error, check SMTP credentials in .env
# Test with telnet
telnet smtp.gmail.com 587
```

### Issue: Static Files Not Loading
**Solution:**
```bash
# Collect static files
python manage.py collectstatic --noinput --clear

# Check Nginx path
ls -la /var/www/educv/cvbuilder-backend/staticfiles/

# Verify Nginx location block
sudo nginx -t
```

---

## Health Checks

### API Health Check
```bash
# Production
curl https://api.yourdomain.com/health/

# Expected response
{"status": "healthy", "database": "connected", "services": {...}}
```

### Database Health Check
```bash
python manage.py shell
>>> from django.db import connection
>>> connection.ensure_connection()
>>> # If no error, database is connected
```

### Email Service Check
```bash
python manage.py shell
>>> from django.core.mail import send_mail
>>> send_mail('Test', 'Test', 'from@test.com', ['admin@test.com'], fail_silently=False)
```

---

## Post-Deployment Verification

- [ ] API documentation available at `/api/docs/swagger/`
- [ ] Admin interface accessible at `/admin/`
- [ ] SSL certificate valid
- [ ] Email verification working
- [ ] Error tracking in Sentry working
- [ ] Monitoring dashboards loading
- [ ] Database backups running
- [ ] Application logs rotating properly
- [ ] Performance metrics within acceptable ranges

---

## Support & Escalation

For issues or questions:
1. Check `/var/log/educv/` for application logs
2. Review Sentry dashboard for errors
3. Contact DevOps team with: logs, error screenshots, reproduction steps
