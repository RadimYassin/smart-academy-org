#!/bin/bash

# Smart Academy - Service Status Checker

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}================================${NC}"
echo -e "${GREEN}Smart Academy - Service Status${NC}"
echo -e "${GREEN}================================${NC}"
echo ""

# Function to check if port is in use
check_port() {
    local port=$1
    local service=$2
    
    if lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1 ; then
        echo -e "${GREEN}✓${NC} $service (Port $port) - ${GREEN}RUNNING${NC}"
        return 0
    else
        echo -e "${RED}✗${NC} $service (Port $port) - ${RED}STOPPED${NC}"
        return 1
    fi
}

echo -e "${YELLOW}Microservices:${NC}"
check_port 8761 "Eureka Server      "
check_port 8888 "API Gateway        "
check_port 8082 "User Management    "
check_port 8081 "Course Management  "
check_port 3000 "LMS Connector      "
check_port 8000 "AI Services        "

echo ""
echo -e "${YELLOW}Databases:${NC}"
check_port 5432 "User DB            "
check_port 5433 "Course DB          "
check_port 5434 "LMS DB             "

echo ""
echo -e "${YELLOW}Docker Containers:${NC}"
docker ps --format "table {{.Names}}\t{{.Status}}" | grep -E "user-db|course-db|lms-db|NAMES" || echo "  No database containers running"

echo ""
echo -e "${YELLOW}Quick Links:${NC}"
echo "  Eureka Dashboard: http://localhost:8761"
echo "  Gateway Health:   http://localhost:8888/actuator/health"
echo "  API Docs (AI):    http://localhost:8000/docs"
echo ""
