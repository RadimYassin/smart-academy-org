#!/bin/bash

# ==================================================
# Smart Academy - Health Check Script (Linux/Mac)
# ==================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║     Smart Academy Platform Health Check        ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}\n"

up_count=0
down_count=0

check_service() {
    local name=$1
    local url=$2
    
    echo -n "Checking $name... "
    
    if curl -s -o /dev/null -w "%{http_code}" --max-time 3 "$url" | grep -q "200\|302"; then
        echo -e "${GREEN}✓ UP${NC}"
        ((up_count++))
    else
        echo -e "${RED}✗ DOWN${NC}"
        ((down_count++))
    fi
}

# Check all services
check_service "Eureka Server" "http://localhost:8761"
check_service "API Gateway" "http://localhost:8888"
check_service "User Management" "http://localhost:8082/actuator/health"
check_service "Course Management" "http://localhost:8081/actuator/health"
check_service "LMS Connector" "http://localhost:3000"
check_service "Chatbot-edu" "http://localhost:8005/health"
check_service "MinIO Console" "http://localhost:9001"
check_service "RabbitMQ Management" "http://localhost:15672"

echo -e "\n${CYAN}═══════════════════════════════════════════════════${NC}"
echo -e "Summary: ${GREEN}$up_count UP${NC} | ${RED}$down_count DOWN${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════${NC}\n"

# Check Docker containers
echo -e "${CYAN}Checking Docker Containers...${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" 2>/dev/null || echo -e "${YELLOW}Docker not running or not installed${NC}"

echo -e "\n${GREEN}✓ Health check complete!${NC}\n"
