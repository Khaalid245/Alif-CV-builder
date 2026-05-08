# EduCV Enterprise Observability Guide

> Complete monitoring, alerting, and incident response system for production deployment.

---

## Overview

This observability stack provides enterprise-grade monitoring for the EduCV platform with:

- **Metrics Collection** — Prometheus + custom Django metrics
- **Visualization** — Grafana dashboards for application and infrastructure
- **Log Aggregation** — Loki + Promtail for centralized logging
- **Alerting** — Alertmanager with email/Slack notifications
- **Error Tracking** — Sentry integration for exception monitoring
- **Uptime Monitoring** — Custom health check system
- **Performance Monitoring** — Request tracing and slow query detection

---

## Quick Start

### 1. Deploy the Stack

```bash
cd observability/
chmod +x deploy.sh
./deploy.sh
```

### 2. Configure Django Backend

Add to your `.env` file:

```env
# Sentry Configuration
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
SENTRY_ENVIRONMENT=production
SENTRY_TRACES_SAMPLE_RATE=0.1

# Monitoring Settings
PROMETHEUS_METRICS_ENABLED=true
STRUCTURED_LOGGING_ENABLED=true
```

### 3. Install Dependencies

```bash
cd ../cvbuilder-backend/
pip install -r requirements.txt
```

### 4. Start Monitoring

```bash
# Start uptime monitoring
cd ../observability/
python uptime_monitor.py

# In another terminal, start the Django app
cd ../cvbuilder-backend/
python manage.py runserver
```

---

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Django App    │───▶│   Prometheus    │───▶│    Grafana      │
│  (Metrics API)  │    │  (Collection)   │    │ (Visualization) │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│     Sentry      │    │  Alertmanager   │    │   Dashboards    │
│ (Error Track)   │    │   (Alerts)      │    │   (Monitoring)  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │
         ▼                       ▼
┌─────────────────┐    ┌─────────────────┐
│      Loki       │    │ Email/Slack     │
│ (Log Storage)   │    │ (Notifications) │
└─────────────────┘    └─────────────────┘
         ▲
         │
┌─────────────────┐
│    Promtail     │
│ (Log Shipping)  │
└─────────────────┘
```

---

## Components

### Prometheus (Metrics Collection)
- **Port**: 9090
- **Purpose**: Collects metrics from Django app and system
- **Retention**: 30 days
- **Scrape Interval**: 15 seconds

**Key Metrics**:
- HTTP request rate/duration/errors
- Database connection pool usage
- PDF generation success/failure rates
- User registration/login metrics
- System resources (CPU, memory, disk)

### Grafana (Visualization)
- **Port**: 3000
- **Credentials**: admin/admin123
- **Purpose**: Dashboards and alerting visualization

**Pre-built Dashboards**:
- EduCV Application Dashboard
- Infrastructure Monitoring
- Security Events
- Business Metrics

### Loki (Log Aggregation)
- **Port**: 3100
- **Purpose**: Centralized log storage and querying
- **Integration**: Automatic log parsing and labeling

**Log Sources**:
- Django application logs
- Security audit logs
- System logs
- Container logs

### Alertmanager (Alert Management)
- **Port**: 9093
- **Purpose**: Alert routing and notification management
- **Integrations**: Email, Slack, webhooks

### Sentry (Error Tracking)
- **Purpose**: Exception monitoring and performance tracking
- **Features**: Error grouping, release tracking, performance monitoring

---

## Alert Rules

### Critical Alerts
- Application down (> 1 minute)
- High error rate (> 10% for 2 minutes)
- Database connection failures
- Disk space < 10%
- Memory usage > 90%

### Warning Alerts
- High response time (> 2s for 5 minutes)
- High CPU usage (> 80% for 5 minutes)
- PDF generation failures
- High login failure rate

### Security Alerts
- Multiple failed login attempts
- Rate limit violations
- Data deletion requests
- Suspicious activity patterns

---

## Configuration

### Environment Variables

Add to your Django `.env` file:

```env
# Sentry
SENTRY_DSN=https://your-dsn@sentry.io/project
SENTRY_ENVIRONMENT=production
SENTRY_TRACES_SAMPLE_RATE=0.1
SENTRY_SAMPLE_RATE=1.0

# Logging
LOG_LEVEL=INFO
STRUCTURED_LOGGING_ENABLED=true

# Monitoring
PROMETHEUS_METRICS_ENABLED=true
UPTIME_CHECK_INTERVAL=60
```

### Email Alerts

Update `alertmanager/alertmanager.yml`:

```yaml
global:
  smtp_smarthost: 'your-smtp-server:587'
  smtp_from: 'alerts@yourdomain.com'

receivers:
  - name: 'critical-alerts'
    email_configs:
      - to: 'devops@yourdomain.com'
        subject: '[CRITICAL] EduCV Alert'
```

### Slack Integration

1. Create a Slack webhook URL
2. Update `alertmanager/alertmanager.yml`:

```yaml
receivers:
  - name: 'slack-alerts'
    slack_configs:
      - api_url: 'YOUR_SLACK_WEBHOOK_URL'
        channel: '#alerts'
```

---

## Dashboards

### Application Dashboard
- Request rate and response times
- Error rates by endpoint
- Active user count
- PDF generation metrics
- Database performance

### Infrastructure Dashboard
- CPU, memory, disk usage
- Network I/O
- Load averages
- Container health

### Security Dashboard
- Failed login attempts
- Rate limit violations
- Security events timeline
- Geographic login distribution

### Business Dashboard
- Daily/weekly user registrations
- PDF generation trends
- Feature usage statistics
- Completion rate metrics

---

## Incident Response

### Alert Severity Levels

**Critical** (Immediate Response Required)
- Application completely down
- Database unavailable
- Security breach detected
- Data loss risk

**Warning** (Response Within 30 Minutes)
- Performance degradation
- High error rates
- Resource constraints
- Feature failures

**Info** (Monitor and Plan)
- Capacity planning alerts
- Maintenance reminders
- Usage pattern changes

### Response Procedures

1. **Acknowledge Alert**
   - Check Grafana dashboards for context
   - Review recent deployments/changes
   - Check system logs in Loki

2. **Investigate**
   - Use Sentry for error details
   - Check Prometheus metrics for trends
   - Review application logs

3. **Resolve**
   - Apply fix or rollback
   - Monitor recovery in dashboards
   - Document incident and resolution

4. **Post-Incident**
   - Update monitoring/alerts if needed
   - Conduct post-mortem for critical issues
   - Improve documentation/procedures

---

## Maintenance

### Daily Tasks
- Check dashboard for anomalies
- Review critical alerts
- Monitor disk space usage
- Verify backup completion

### Weekly Tasks
- Review performance trends
- Update alert thresholds if needed
- Check log retention policies
- Test alert notifications

### Monthly Tasks
- Review and update dashboards
- Analyze incident patterns
- Update monitoring documentation
- Capacity planning review

---

## Troubleshooting

### Common Issues

**Prometheus Not Scraping Django Metrics**
```bash
# Check if metrics endpoint is accessible
curl http://localhost:8000/metrics

# Verify Django prometheus middleware is installed
# Check INSTALLED_APPS includes 'django_prometheus'
```

**Grafana Dashboards Not Loading**
```bash
# Check datasource configuration
# Verify Prometheus URL in Grafana settings
# Check network connectivity between containers
```

**Alerts Not Firing**
```bash
# Check Prometheus rules syntax
promtool check rules prometheus/rules/*.yml

# Verify Alertmanager configuration
amtool config show --alertmanager.url=http://localhost:9093
```

**Logs Not Appearing in Loki**
```bash
# Check Promtail status
docker logs educv-promtail

# Verify log file permissions
# Check Loki connectivity from Promtail
```

### Performance Optimization

**High Memory Usage**
- Adjust Prometheus retention period
- Optimize query performance
- Reduce scrape frequency for non-critical metrics

**Slow Queries**
- Add database indexes for frequently queried metrics
- Optimize Grafana dashboard queries
- Use recording rules for complex calculations

---

## Security Considerations

### Access Control
- Change default Grafana admin password
- Restrict network access to monitoring ports
- Use HTTPS in production
- Implement proper authentication

### Data Privacy
- Configure Sentry to exclude PII
- Set appropriate log retention periods
- Encrypt sensitive configuration data
- Regular security audits

### Network Security
- Use internal networks for monitoring traffic
- Implement firewall rules
- Monitor for unauthorized access
- Regular security updates

---

## Scaling

### High Availability
- Deploy Prometheus in HA mode
- Use external storage for Grafana
- Implement Loki clustering
- Load balance Alertmanager

### Performance Scaling
- Horizontal scaling with federation
- Separate monitoring per service
- Use remote storage for long-term retention
- Optimize metric cardinality

---

## Integration with CI/CD

### Deployment Monitoring
```yaml
# Add to your deployment pipeline
- name: Wait for deployment health
  run: |
    python observability/uptime_monitor.py --once
    # Check if all services are healthy before proceeding
```

### Automated Alerting
- Alert on deployment failures
- Monitor deployment performance impact
- Automatic rollback triggers
- Release tracking in Sentry

---

## Cost Optimization

### Resource Management
- Set appropriate retention periods
- Monitor storage usage
- Optimize scrape intervals
- Use recording rules for expensive queries

### Cloud Integration
- Use managed Prometheus (if available)
- Leverage cloud monitoring services
- Implement cost alerts
- Regular usage reviews

---

## Support and Documentation

### Getting Help
- Check logs in `observability/logs/`
- Review Grafana explore for debugging
- Use Prometheus query browser
- Check component documentation

### Additional Resources
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Loki Documentation](https://grafana.com/docs/loki/)
- [Sentry Documentation](https://docs.sentry.io/)

---

## License

This observability stack is part of the EduCV project, commissioned by the university for official deployment.