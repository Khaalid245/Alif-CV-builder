#!/bin/bash

# EduCV Observability Stack Deployment Script
# Deploys Prometheus, Grafana, Loki, and Alertmanager for comprehensive monitoring

set -e

echo "🚀 Deploying EduCV Observability Stack..."

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if docker-compose is available
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose is not installed. Please install it and try again."
    exit 1
fi

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p prometheus/rules
mkdir -p alertmanager
mkdir -p grafana/{provisioning/{datasources,dashboards},dashboards}
mkdir -p loki
mkdir -p promtail

# Set proper permissions for Grafana
echo "🔐 Setting permissions..."
sudo chown -R 472:472 grafana/ || echo "⚠️  Could not set Grafana permissions (may need to run as root)"

# Pull Docker images
echo "📦 Pulling Docker images..."
docker-compose pull

# Start the observability stack
echo "🏃 Starting observability stack..."
docker-compose up -d

# Wait for services to be ready
echo "⏳ Waiting for services to start..."
sleep 30

# Check service health
echo "🔍 Checking service health..."

services=(
    "prometheus:9090"
    "grafana:3000"
    "loki:3100"
    "alertmanager:9093"
    "node-exporter:9100"
)

for service in "${services[@]}"; do
    name=$(echo $service | cut -d: -f1)
    port=$(echo $service | cut -d: -f2)
    
    if curl -f -s "http://localhost:$port" > /dev/null; then
        echo "✅ $name is running on port $port"
    else
        echo "❌ $name is not responding on port $port"
    fi
done

echo ""
echo "🎉 Observability stack deployment complete!"
echo ""
echo "📊 Access URLs:"
echo "   Grafana:      http://localhost:3000 (admin/admin123)"
echo "   Prometheus:   http://localhost:9090"
echo "   Alertmanager: http://localhost:9093"
echo "   Loki:         http://localhost:3100"
echo ""
echo "📋 Next steps:"
echo "   1. Configure your Django app with the monitoring dependencies"
echo "   2. Update .env file with Sentry DSN and monitoring settings"
echo "   3. Set up email/Slack alerts in alertmanager.yml"
echo "   4. Import custom dashboards in Grafana"
echo "   5. Start the uptime monitor: python uptime_monitor.py"
echo ""
echo "📚 Documentation: See OBSERVABILITY_GUIDE.md for detailed setup"