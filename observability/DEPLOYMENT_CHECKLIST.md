# EduCV Observability Deployment Checklist

## Pre-Deployment Setup

### 1. Infrastructure Requirements
- [ ] Docker and Docker Compose installed
- [ ] Minimum 4GB RAM available for monitoring stack
- [ ] 20GB disk space for metrics and logs storage
- [ ] Network ports available: 3000, 3100, 9090, 9093, 9100

### 2. Configuration Files
- [ ] Update `alertmanager/alertmanager.yml` with real email/Slack settings
- [ ] Configure `monitor_config.json` with production URLs
- [ ] Set proper retention periods in `prometheus/prometheus.yml`
- [ ] Update `loki/loki.yml` with storage configuration

### 3. Django Application Setup
- [ ] Install monitoring dependencies: `pip install -r requirements.txt`
- [ ] Add observability environment variables to `.env`
- [ ] Configure Sentry DSN and project settings
- [ ] Enable structured logging in Django settings

## Deployment Steps

### 1. Deploy Monitoring Stack
```bash
cd observability/
chmod +x deploy.sh
./deploy.sh
```

### 2. Verify Services
- [ ] Prometheus accessible at http://localhost:9090
- [ ] Grafana accessible at http://localhost:3000 (admin/admin123)
- [ ] Alertmanager accessible at http://localhost:9093
- [ ] Loki accessible at http://localhost:3100

### 3. Configure Django Metrics
- [ ] Restart Django application with new settings
- [ ] Verify metrics endpoint: http://localhost:8000/metrics
- [ ] Check health endpoints: http://localhost:8000/api/v1/health/

### 4. Import Dashboards
- [ ] Login to Grafana (admin/admin123)
- [ ] Verify Prometheus datasource is connected
- [ ] Import EduCV Application Dashboard
- [ ] Import Infrastructure Dashboard
- [ ] Set up alert notification channels

### 5. Test Alerting
- [ ] Stop Django application to trigger alerts
- [ ] Verify email/Slack notifications are received
- [ ] Test alert recovery notifications
- [ ] Validate alert escalation rules

## Post-Deployment Verification

### 1. Metrics Collection
- [ ] Django request metrics appearing in Prometheus
- [ ] Database connection metrics being collected
- [ ] Custom business metrics (PDF generation, user activity)
- [ ] System metrics (CPU, memory, disk) from node-exporter

### 2. Log Aggregation
- [ ] Django application logs appearing in Loki
- [ ] Security logs being parsed correctly
- [ ] Log retention policies working
- [ ] Log queries working in Grafana Explore

### 3. Error Tracking
- [ ] Sentry receiving error reports
- [ ] Performance monitoring data available
- [ ] Release tracking configured
- [ ] Error grouping and notifications working

### 4. Uptime Monitoring
- [ ] Start uptime monitor: `python uptime_monitor.py`
- [ ] Verify health check endpoints responding
- [ ] Test failure detection and alerting
- [ ] Confirm recovery notifications

## Security Configuration

### 1. Access Control
- [ ] Change default Grafana admin password
- [ ] Configure Grafana user authentication (LDAP/OAuth)
- [ ] Restrict network access to monitoring ports
- [ ] Set up firewall rules for production

### 2. Data Privacy
- [ ] Configure Sentry to exclude PII data
- [ ] Set appropriate log retention periods
- [ ] Encrypt sensitive configuration files
- [ ] Review data collection policies

### 3. Network Security
- [ ] Use HTTPS for all external access
- [ ] Configure internal network for monitoring traffic
- [ ] Set up VPN access for monitoring dashboards
- [ ] Regular security updates scheduled

## Performance Optimization

### 1. Resource Allocation
- [ ] Monitor memory usage of monitoring stack
- [ ] Adjust Prometheus retention based on storage
- [ ] Optimize Grafana dashboard queries
- [ ] Configure log rotation and cleanup

### 2. Scaling Considerations
- [ ] Plan for metric cardinality growth
- [ ] Consider Prometheus federation for scaling
- [ ] Implement Loki clustering if needed
- [ ] Monitor monitoring system performance

## Maintenance Tasks

### 1. Daily
- [ ] Check critical alerts dashboard
- [ ] Review error rates and performance metrics
- [ ] Verify backup completion
- [ ] Monitor disk space usage

### 2. Weekly
- [ ] Review alert thresholds and tune if needed
- [ ] Analyze performance trends
- [ ] Update monitoring documentation
- [ ] Test alert notification channels

### 3. Monthly
- [ ] Review and update dashboards
- [ ] Analyze incident patterns and improve alerts
- [ ] Capacity planning review
- [ ] Security audit of monitoring access

## Troubleshooting Guide

### Common Issues

**Prometheus not scraping Django metrics**
- Check if `/metrics` endpoint is accessible
- Verify django-prometheus middleware is installed
- Check network connectivity between containers

**Grafana dashboards showing no data**
- Verify Prometheus datasource configuration
- Check if metrics are being collected in Prometheus
- Validate dashboard query syntax

**Alerts not firing**
- Check Prometheus alert rules syntax
- Verify Alertmanager configuration
- Test notification channels manually

**Logs not appearing in Loki**
- Check Promtail container logs
- Verify log file permissions and paths
- Test Loki connectivity from Promtail

## Support Contacts

- **DevOps Team**: devops@university.edu
- **System Administrator**: admin@university.edu
- **Emergency Contact**: +1-XXX-XXX-XXXX

## Documentation Links

- [Observability Guide](OBSERVABILITY_GUIDE.md)
- [Prometheus Documentation](https://prometheus.io/docs/)
- [Grafana Documentation](https://grafana.com/docs/)
- [Sentry Documentation](https://docs.sentry.io/)

---

**Deployment Date**: _______________
**Deployed By**: _______________
**Verified By**: _______________
**Production Ready**: [ ] Yes [ ] No