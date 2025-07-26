#!/bin/bash

# Fleet Smart Health Monitor
# This script checks the health of the Fleet Smart application

set -e

# Configuration
CONTAINER_PREFIX="fleet-smart-app"
ODOO_PORT="8069"
LOG_FILE="/var/log/fleet-smart-health.log"
MAX_RETRIES=3
RETRY_DELAY=10

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Logging function
log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Function to send notification
send_notification() {
    local message="$1"
    local status="$2"
    
    # Log the message
    log_message "$message"
    
    # Send Telegram notification if configured
    if [ -f "./notify_telegram.sh" ] && [ -n "$TELEGRAM_BOT_TOKEN" ] && [ -n "$TELEGRAM_CHAT_ID" ]; then
        ./notify_telegram.sh "$message"
    fi
    
    # Send to system log
    logger "Fleet Smart Monitor: $message"
}

# Function to check container health
check_container_health() {
    local container_name="$1"
    
    if ! docker ps --format "table {{.Names}}" | grep -q "$container_name"; then
        return 1
    fi
    
    local health_status=$(docker inspect --format='{{.State.Health.Status}}' "$container_name" 2>/dev/null || echo "no-health-check")
    
    if [ "$health_status" = "healthy" ] || [ "$health_status" = "no-health-check" ]; then
        return 0
    else
        return 1
    fi
}

# Function to check HTTP response
check_http_response() {
    local url="$1"
    local expected_codes="200 303 302"
    
    local http_code=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 10 --max-time 30 "$url" 2>/dev/null || echo "000")
    
    for code in $expected_codes; do
        if [ "$http_code" = "$code" ]; then
            return 0
        fi
    done
    
    return 1
}

# Function to restart containers
restart_containers() {
    log_message "🔄 Attempting to restart Fleet Smart containers..."
    
    cd /home/ubuntu/fleet-smart-app 2>/dev/null || cd /opt/fleet-smart-app || {
        send_notification "❌ Fleet Smart directory not found!" "error"
        return 1
    }
    
    # Stop containers
    sudo docker-compose down --timeout 30
    
    # Wait a moment
    sleep 5
    
    # Start containers
    sudo docker-compose up -d
    
    # Wait for startup
    sleep 30
    
    log_message "✅ Container restart completed"
}

# Main health check function
perform_health_check() {
    local issues_found=0
    local restart_needed=false
    
    log_message "🏥 Starting Fleet Smart health check..."
    
    # Check if Docker is running
    if ! systemctl is-active --quiet docker; then
        send_notification "❌ Docker service is not running!" "critical"
        sudo systemctl start docker
        sleep 10
        issues_found=$((issues_found + 1))
    fi
    
    # Find container names
    local odoo_container=$(docker ps --format "{{.Names}}" | grep -E "(odoo|fleet)" | head -1)
    local db_container=$(docker ps --format "{{.Names}}" | grep -E "(db|postgres)" | head -1)
    
    if [ -z "$odoo_container" ]; then
        send_notification "❌ Odoo container not found or not running!" "critical"
        restart_needed=true
        issues_found=$((issues_found + 1))
    else
        # Check Odoo container health
        if ! check_container_health "$odoo_container"; then
            send_notification "❌ Odoo container is unhealthy: $odoo_container" "warning"
            restart_needed=true
            issues_found=$((issues_found + 1))
        fi
    fi
    
    if [ -z "$db_container" ]; then
        send_notification "❌ Database container not found or not running!" "critical"
        restart_needed=true
        issues_found=$((issues_found + 1))
    else
        # Check database container health
        if ! check_container_health "$db_container"; then
            send_notification "❌ Database container is unhealthy: $db_container" "warning"
            restart_needed=true
            issues_found=$((issues_found + 1))
        fi
    fi
    
    # Check HTTP response
    if ! check_http_response "http://localhost:$ODOO_PORT"; then
        send_notification "❌ Fleet Smart web interface is not responding on port $ODOO_PORT" "warning"
        restart_needed=true
        issues_found=$((issues_found + 1))
    fi
    
    # Check disk space
    local disk_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 85 ]; then
        send_notification "⚠️ Disk usage is high: ${disk_usage}%" "warning"
        issues_found=$((issues_found + 1))
    fi
    
    # Check memory usage
    local mem_usage=$(free | awk 'NR==2{printf "%.0f", $3*100/$2}')
    if [ "$mem_usage" -gt 90 ]; then
        send_notification "⚠️ Memory usage is high: ${mem_usage}%" "warning"
        issues_found=$((issues_found + 1))
    fi
    
    # Restart if needed
    if [ "$restart_needed" = true ]; then
        restart_containers
        
        # Wait and recheck
        sleep 60
        if check_http_response "http://localhost:$ODOO_PORT"; then
            send_notification "✅ Fleet Smart recovered after restart" "info"
        else
            send_notification "❌ Fleet Smart still not responding after restart" "critical"
        fi
    fi
    
    if [ "$issues_found" -eq 0 ]; then
        log_message "✅ All health checks passed"
    else
        log_message "⚠️ Health check completed with $issues_found issues"
    fi
    
    return $issues_found
}

# Main execution
main() {
    # Create log file if it doesn't exist
    sudo touch "$LOG_FILE"
    sudo chmod 666 "$LOG_FILE"
    
    # Perform health check
    perform_health_check
    
    local exit_code=$?
    
    # Clean up old log entries (keep last 1000 lines)
    if [ -f "$LOG_FILE" ]; then
        tail -n 1000 "$LOG_FILE" > "${LOG_FILE}.tmp" && mv "${LOG_FILE}.tmp" "$LOG_FILE"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"
