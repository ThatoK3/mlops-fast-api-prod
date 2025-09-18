#!/usr/bin/env bash
set -e

echo "🚀 Starting MLOps FastAPI Platform Deployment..."
echo "=============================================="

# Stop any existing containers
echo "🛑 Stopping any existing containers..."
docker compose down
sleep 5s

# Start the containers
echo "🐳 Starting containers with Docker Compose..."
source .env
docker compose --env-file .env up -d --build

echo "⏳ Waiting for services to initialize..."
sleep 60s

# Initialize the database
echo "🗄️ Initializing database..."
bash upload_db_data.sh

# Wait for services to be ready
echo "⏳ Waiting for services to be ready..."
sleep 30s

# Register MySQL source connector
echo "🔌 Registering MySQL source connector..."
bash dbz-register-mysql-source.sh

# Check connector status
echo "📊 Checking MySQL source connector status..."
sleep 30s
curl -s http://localhost:8083/connectors/stroke-predictions-connector/status | jq

# Register MSSQL sink connector
echo "🔌 Registering MSSQL sink connector..."
sleep 30s
bash dbz-register-mssql-sink.sh

# Check connector status
echo "📊 Checking MSSQL sink connector status..."
sleep 30s
curl -s http://localhost:8083/connectors/mssql-sink-predictions/status | jq

# Register S3 sink connector
echo "🔌 Registering S3 sink connector..."
sleep 30s
bash dbz-register-s3-sink.sh

# Check connector status
echo "📊 Checking S3 sink connector status..."
sleep 30s
curl -s http://localhost:8083/connectors/s3-sink-stroke-predictions/status | jq

# Configure Prometheus for monitoring
echo "📈 Configuring Prometheus for monitoring..."
sleep 30s

# Create backup of current Prometheus config
docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-prometheus") cp /etc/prometheus/prometheus.yml /etc/prometheus/prometheus.yml.backup.$(date +%Y%m%d_%H%M%S)

# Update Prometheus configuration for Kafka Connect monitoring
cat > /tmp/prometheus_new.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    static_configs:
      - targets: ['localhost:9100']

  # Kafka Connect CDC Metrics (Debezium) - PORT 9400
  - job_name: 'kafka-connect-cdc'
    scrape_interval: 15s
    static_configs:
      - targets: ['connect:9400']
        labels:
          environment: 'production'
          service: 'debezium-cdc'
          host: 'cdc-server'
EOF

# Copy new configuration to Prometheus container
docker cp /tmp/prometheus_new.yml $(docker ps -q -f name="mlops-fast-api-prod-prometheus"):/etc/prometheus/prometheus.yml

# Validate configuration
docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-prometheus") promtool check config /etc/prometheus/prometheus.yml

# Reload Prometheus
echo "🔄 Reloading Prometheus configuration..."
docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-prometheus") kill -HUP 1

# Wait for reload to complete
sleep 10s

# Verify Prometheus targets
echo "✅ Verifying Prometheus targets..."
docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-prometheus") curl -s http://localhost:9090/api/v1/targets | jq '.data.activeTargets[] | .scrapeUrl, .health'

# Verify Kafka Connect metrics endpoint
echo "✅ Verifying Kafka Connect metrics..."
docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-connect") curl -s http://localhost:9400/metrics | head -10

# Final health check
echo "🏥 Performing final health checks..."
echo "✅ MySQL Health: $(docker exec -it $(docker ps -q -f name="mlops-fast-api-prod-mysql") mysqladmin ping -h localhost -u root -p${MYSQL_ROOT_PASSWORD} 2>/dev/null && echo 'OK' || echo 'FAILED')"
echo "✅ FastAPI Health: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/)"
echo "✅ Kafka Connect Health: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:8083/)"
echo "✅ Prometheus Health: $(curl -s -o /dev/null -w "%{http_code}" http://localhost:9090/)"

echo "=============================================="
echo "🎉 Deployment completed successfully!"
echo ""
echo "📊 Monitoring URLs:"
echo "   - Prometheus: http://localhost:9090"
echo "   - Kafka Connect Metrics: http://localhost:9400/metrics"
echo "   - FastAPI: http://localhost:8000"
echo "   - API Documentation: http://localhost:8000/docs"
echo "   - Spark UI: http://localhost:8080"
echo "   - Jupyter: http://localhost:9999"
echo ""
echo "Next steps:"
echo "1. Import Kafka Connect dashboard in Grafana (ID: 12664)"
echo "2. Set up alerts for connector status and replication lag"
echo "=============================================="
