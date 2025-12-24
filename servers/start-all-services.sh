#!/bin/bash
# ============================================================================
# Smart Academy - Start All Services (Linux/Mac)
# ============================================================================

echo "========================================================================"
echo " Smart Academy - Starting All Services"
echo "========================================================================"

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running. Please start Docker first."
    exit 1
fi

echo ""
echo "[1/3] Starting Infrastructure + Core Services with Docker..."
echo "========================================================================"

# Start infrastructure and main services (excluding AI services for now)
docker-compose up -d user-management-db course-management-db lms-connector-db \
    minio-storage rabbitmq eureka-server gateway-service \
    user-management-service course-management-service \
    lms-connector-service chatbot-edu-service

echo ""
echo "Waiting for services to be ready (30 seconds)..."
sleep 30

echo ""
echo "[2/3] Checking Service Status..."
echo "========================================================================"
docker-compose ps

echo ""
echo "[3/3] Service URLs:"
echo "========================================================================"
echo " Eureka Dashboard:      http://localhost:8761"
echo " API Gateway:           http://localhost:8888"
echo " User Management:       http://localhost:8082/swagger-ui.html"
echo " Course Management:     http://localhost:8081/swagger-ui.html"
echo " LMS Connector:         http://localhost:3000"
echo " Chatbot:               http://localhost:8005/docs"
echo " MinIO Console:         http://localhost:9001 (minioadmin/minioadmin)"
echo " RabbitMQ:              http://localhost:15672 (admin/admin123)"
echo "========================================================================"

echo ""
read -p "Do you want to start AI services locally? (y/n): " START_AI

if [[ "$START_AI" == "y" || "$START_AI" == "Y" ]]; then
    echo ""
    echo "Starting AI Services locally..."
    ./run_ai_services.sh
else
    echo ""
    echo "Skipping AI services. You can start them later with: ./run_ai_services.sh"
fi

echo ""
echo "========================================================================"
echo " All services started successfully!"
echo " Open Eureka Dashboard to verify: http://localhost:8761"
echo "========================================================================"
