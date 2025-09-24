#!/bin/bash

# Docker health check script for containers
# This script is used by Docker containers to report health status

set -e

SERVICE_NAME="${SERVICE_NAME:-user-service}"
HEALTH_ENDPOINT="${HEALTH_ENDPOINT:-http://localhost:8080/actuator/health}"
TIMEOUT="${TIMEOUT:-5}"

# Function to check health endpoint
check_health() {
    if curl -f -s --max-time "$TIMEOUT" "$HEALTH_ENDPOINT" > /dev/null 2>&1; then
        echo "✅ $SERVICE_NAME is healthy"
        exit 0
    else
        echo "❌ $SERVICE_NAME health check failed"
        exit 1
    fi
}

# Function to check basic port connectivity
check_port() {
    local port=$1
    if nc -z localhost "$port" 2>/dev/null; then
        echo "✅ Port $port is accessible"
        exit 0
    else
        echo "❌ Port $port is not accessible"
        exit 1
    fi
}

# Main health check logic
case "$SERVICE_NAME" in
    "user-service")
        check_health
        ;;
    "frontend")
        check_port 3000
        ;;
    "redis")
        check_port 6379
        ;;
    "h2-database")
        check_port 9092
        ;;
    *)
        echo "Unknown service: $SERVICE_NAME"
        exit 1
        ;;
esac