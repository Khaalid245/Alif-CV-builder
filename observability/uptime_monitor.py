#!/usr/bin/env python3
"""
EduCV Uptime Monitor
Performs health checks and sends alerts when services are down.
"""
import requests
import time
import json
import smtplib
from email.mime.text import MimeText
from email.mime.multipart import MimeMultipart
from datetime import datetime
from typing import Dict, List, Optional
import logging

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('uptime_monitor.log'),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger(__name__)


class UptimeMonitor:
    """Monitors EduCV services and sends alerts on failures."""
    
    def __init__(self, config_file: str = 'monitor_config.json'):
        self.config = self.load_config(config_file)
        self.services = self.config['services']
        self.alert_config = self.config['alerts']
        self.status_history = {}
    
    def load_config(self, config_file: str) -> dict:
        """Load monitoring configuration."""
        try:
            with open(config_file, 'r') as f:
                return json.load(f)
        except FileNotFoundError:
            return self.get_default_config()
    
    def get_default_config(self) -> dict:
        """Default monitoring configuration."""
        return {
            "services": [
                {
                    "name": "EduCV Backend API",
                    "url": "http://localhost:8000/api/v1/auth/profile/",
                    "method": "GET",
                    "headers": {"Authorization": "Bearer YOUR_TEST_TOKEN"},
                    "expected_status": 401,  # Unauthorized without valid token
                    "timeout": 10,
                    "critical": True
                },
                {
                    "name": "Prometheus Metrics",
                    "url": "http://localhost:8000/metrics",
                    "method": "GET",
                    "expected_status": 200,
                    "timeout": 5,
                    "critical": False
                },
                {
                    "name": "Database Health",
                    "url": "http://localhost:8000/admin/",
                    "method": "GET",
                    "expected_status": 302,  # Redirect to login
                    "timeout": 10,
                    "critical": True
                }
            ],
            "alerts": {
                "email": {
                    "enabled": True,
                    "smtp_server": "smtp.gmail.com",
                    "smtp_port": 587,
                    "username": "alerts@university.edu",
                    "password": "your_app_password",
                    "from_email": "alerts@university.edu",
                    "to_emails": ["devops@university.edu", "admin@university.edu"]
                },
                "webhook": {
                    "enabled": False,
                    "url": "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
                }
            },
            "monitoring": {
                "check_interval": 60,  # seconds
                "failure_threshold": 3,  # consecutive failures before alert
                "recovery_notification": True
            }
        }
    
    def check_service(self, service: dict) -> dict:
        """Check a single service health."""
        start_time = time.time()
        
        try:
            response = requests.request(
                method=service['method'],
                url=service['url'],
                headers=service.get('headers', {}),
                timeout=service.get('timeout', 10),
                allow_redirects=False
            )
            
            response_time = time.time() - start_time
            
            # Check if status code matches expected
            expected_status = service.get('expected_status', 200)
            is_healthy = response.status_code == expected_status
            
            return {
                'name': service['name'],
                'healthy': is_healthy,
                'status_code': response.status_code,
                'response_time': response_time,
                'error': None,
                'timestamp': datetime.now().isoformat()
            }
            
        except requests.exceptions.RequestException as e:
            response_time = time.time() - start_time
            
            return {
                'name': service['name'],
                'healthy': False,
                'status_code': None,
                'response_time': response_time,
                'error': str(e),
                'timestamp': datetime.now().isoformat()
            }
    
    def check_all_services(self) -> List[dict]:
        """Check all configured services."""
        results = []
        
        for service in self.services:
            result = self.check_service(service)
            results.append(result)
            
            # Update status history
            service_name = service['name']
            if service_name not in self.status_history:
                self.status_history[service_name] = []
            
            self.status_history[service_name].append(result)
            
            # Keep only last 10 checks
            self.status_history[service_name] = self.status_history[service_name][-10:]
            
            # Log result
            if result['healthy']:
                logger.info(f"✓ {service_name} - OK ({result['response_time']:.2f}s)")
            else:
                logger.error(f"✗ {service_name} - FAILED - {result['error'] or f'Status: {result['status_code']}'}")
        
        return results
    
    def should_send_alert(self, service_name: str, is_healthy: bool) -> bool:
        """Determine if an alert should be sent based on failure threshold."""
        if service_name not in self.status_history:
            return False
        
        history = self.status_history[service_name]
        threshold = self.config['monitoring']['failure_threshold']
        
        if not is_healthy:
            # Check if we have enough consecutive failures
            recent_failures = 0
            for check in reversed(history[-threshold:]):
                if not check['healthy']:
                    recent_failures += 1
                else:
                    break
            
            return recent_failures >= threshold
        
        else:
            # Check if this is a recovery (previous check was unhealthy)
            if len(history) >= 2 and not history[-2]['healthy']:
                return self.config['monitoring']['recovery_notification']
        
        return False
    
    def send_email_alert(self, service_name: str, is_healthy: bool, details: dict):
        """Send email alert."""
        email_config = self.alert_config['email']
        
        if not email_config['enabled']:
            return
        
        subject = f"[{'RECOVERED' if is_healthy else 'ALERT'}] EduCV Service: {service_name}"
        
        if is_healthy:
            body = f"""
Service Recovery Notification

Service: {service_name}
Status: RECOVERED
Time: {details['timestamp']}
Response Time: {details['response_time']:.2f}s

The service is now responding normally.
"""
        else:
            body = f"""
Service Alert

Service: {service_name}
Status: DOWN
Time: {details['timestamp']}
Error: {details['error'] or f'HTTP {details['status_code']}'}
Response Time: {details['response_time']:.2f}s

Please investigate immediately.
"""
        
        try:
            msg = MimeMultipart()
            msg['From'] = email_config['from_email']
            msg['To'] = ', '.join(email_config['to_emails'])
            msg['Subject'] = subject
            
            msg.attach(MimeText(body, 'plain'))
            
            server = smtplib.SMTP(email_config['smtp_server'], email_config['smtp_port'])
            server.starttls()
            server.login(email_config['username'], email_config['password'])
            
            text = msg.as_string()
            server.sendmail(email_config['from_email'], email_config['to_emails'], text)
            server.quit()
            
            logger.info(f"Alert email sent for {service_name}")
            
        except Exception as e:
            logger.error(f"Failed to send email alert: {e}")
    
    def send_webhook_alert(self, service_name: str, is_healthy: bool, details: dict):
        """Send webhook alert (e.g., to Slack)."""
        webhook_config = self.alert_config['webhook']
        
        if not webhook_config['enabled']:
            return
        
        color = "good" if is_healthy else "danger"
        status = "RECOVERED" if is_healthy else "DOWN"
        
        payload = {
            "attachments": [
                {
                    "color": color,
                    "title": f"EduCV Service {status}",
                    "fields": [
                        {"title": "Service", "value": service_name, "short": True},
                        {"title": "Status", "value": status, "short": True},
                        {"title": "Time", "value": details['timestamp'], "short": True},
                        {"title": "Response Time", "value": f"{details['response_time']:.2f}s", "short": True}
                    ]
                }
            ]
        }
        
        if not is_healthy:
            payload["attachments"][0]["fields"].append({
                "title": "Error",
                "value": details['error'] or f"HTTP {details['status_code']}",
                "short": False
            })
        
        try:
            response = requests.post(webhook_config['url'], json=payload, timeout=10)
            response.raise_for_status()
            logger.info(f"Webhook alert sent for {service_name}")
            
        except Exception as e:
            logger.error(f"Failed to send webhook alert: {e}")
    
    def process_alerts(self, results: List[dict]):
        """Process check results and send alerts if needed."""
        for result in results:
            service_name = result['name']
            is_healthy = result['healthy']
            
            if self.should_send_alert(service_name, is_healthy):
                self.send_email_alert(service_name, is_healthy, result)
                self.send_webhook_alert(service_name, is_healthy, result)
    
    def run_once(self):
        """Run a single monitoring cycle."""
        logger.info("Starting health check cycle...")
        results = self.check_all_services()
        self.process_alerts(results)
        logger.info("Health check cycle completed")
        
        return results
    
    def run_continuous(self):
        """Run continuous monitoring."""
        logger.info("Starting continuous monitoring...")
        interval = self.config['monitoring']['check_interval']
        
        try:
            while True:
                self.run_once()
                time.sleep(interval)
                
        except KeyboardInterrupt:
            logger.info("Monitoring stopped by user")
        except Exception as e:
            logger.error(f"Monitoring error: {e}")
            raise


def main():
    """Main entry point."""
    import argparse
    
    parser = argparse.ArgumentParser(description='EduCV Uptime Monitor')
    parser.add_argument('--config', default='monitor_config.json', help='Configuration file')
    parser.add_argument('--once', action='store_true', help='Run once and exit')
    
    args = parser.parse_args()
    
    monitor = UptimeMonitor(args.config)
    
    if args.once:
        results = monitor.run_once()
        print(json.dumps(results, indent=2))
    else:
        monitor.run_continuous()


if __name__ == '__main__':
    main()