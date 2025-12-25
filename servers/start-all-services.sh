#!/bin/bash

# Smart Academy - Start All Services Script
# This script starts all microservices in separate terminal windows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Smart Academy - Service Startup${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Function to start a service in a new tab
start_service() {
    local service_name=$1
    local command=$2
    local directory=$3
    
    echo -e "${YELLOW}Starting $service_name...${NC}"
    
    gnome-terminal --tab --title="$service_name" --working-directory="$directory" -- bash -c "$command; exec bash" &
    
    sleep 2
}

echo -e "${GREEN}Step 1: Starting Databases (Docker Compose)${NC}"
docker compose up -d user-db course-db lms-db
echo -e "${GREEN}✓ Databases started${NC}"
echo ""

sleep 3

echo -e "${GREEN}Step 2: Starting Eureka Server (Service Discovery)${NC}"
start_service "Eureka Server" "mvn spring-boot:run" "$SCRIPT_DIR/Eureka-Server"
echo -e "${GREEN}✓ Waiting for Eureka to start (15 seconds)${NC}"
sleep 15

echo -e "${GREEN}Step 3: Starting User Management Service${NC}"
start_service "User Management" "mvn spring-boot:run" "$SCRIPT_DIR/User-Management"
sleep 5

echo -e "${GREEN}Step 4: Starting Course Management Service${NC}"
start_service "Course Management" "mvn spring-boot:run" "$SCRIPT_DIR/Cour-Management"
sleep 5

echo -e "${GREEN}Step 5: Starting API Gateway${NC}"
start_service "Gateway" "mvn spring-boot:run" "$SCRIPT_DIR/GateWay"
sleep 5

echo -e "${GREEN}Step 6: Starting LMS Connector (NestJS)${NC}"
start_service "LMS Connector" "npm run start:dev" "$SCRIPT_DIR/lmsconnector"
sleep 5

echo -e "${GREEN}Step 7: Starting AI Services (Python/FastAPI)${NC}"
start_service "AI Services" "export PYTHONPATH=\"$SCRIPT_DIR:\${PYTHONPATH}\" && source venv/bin/activate && uvicorn app.main:app --host 0.0.0.0 --port 8000" "$SCRIPT_DIR/AI-Services-API"
sleep 5

echo ""
echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}All Services Started!${NC}"
echo -e "${GREEN}================================${NC}"
echo ""
echo -e "${YELLOW}Service URLs:${NC}"
echo "  - Eureka Dashboard: http://localhost:8761"
echo "  - Gateway:          http://localhost:8888"
echo "  - User Management:  http://localhost:8082"
echo "  - Course Management: http://localhost:8081"
echo "  - LMS Connector:    http://localhost:3000"
echo "  - AI Services:      http://localhost:8000"
echo ""
echo -e "${YELLOW}Database Ports:${NC}"
echo "  - User DB:          localhost:5432"
echo "  - Course DB:        localhost:5433"
echo "  - LMS DB:           localhost:5434"
echo ""
echo -e "${GREEN}Check Eureka dashboard to verify all services are registered!${NC}"
echo -e "${YELLOW}Press Ctrl+C in each terminal window to stop a service${NC}"
echo ""
