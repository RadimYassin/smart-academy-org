#!/bin/bash

# ==================================================
# Smart Academy - Quick Start Script (Linux/Mac)
# ==================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "\n${CYAN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║      Smart Academy Quick Start Script          ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}\n"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

missing=()

check_prerequisite() {
    if command -v $1 &> /dev/null; then
        echo -e "  ${GREEN}✓ $2 installed${NC}"
    else
        echo -e "  ${RED}✗ $2 NOT found${NC}"
        missing+=("$2")
    fi
}

check_prerequisite "docker" "Docker"
check_prerequisite "java" "Java"
check_prerequisite "mvn" "Maven"
check_prerequisite "node" "Node.js"
check_prerequisite "python3" "Python"

if [ ${#missing[@]} -gt 0 ]; then
    echo -e "\n${RED}⚠ Missing prerequisites: ${missing[*]}${NC}"
    echo -e "${YELLOW}Please install missing tools before continuing.${NC}\n"
    exit 1
fi

echo -e "\n${GREEN}✓ All prerequisites met!${NC}\n"

# Ask user for deployment mode
echo -e "${CYAN}Choose deployment mode:${NC}"
echo -e "  ${NC}1. Infrastructure Only (Development)${NC}"
echo -e "  ${NC}2. Full Docker Compose${NC}"
read -p $'\nEnter choice (1-2): ' mode

case $mode in
    1)
        echo -e "\n${CYAN}🚀 Starting infrastructure only...${NC}"
        docker-compose -f docker-compose.infrastructure.yml up -d
        
        echo -e "\n${YELLOW}⏳ Waiting 30 seconds for databases to start...${NC}"
        sleep 30
        
        echo -e "\n${GREEN}✓ Infrastructure started!${NC}"
        echo -e "${YELLOW}Services will run locally. Start them manually.${NC}\n"
        ;;
    2)
        echo -e "\n${CYAN}🚀 Starting full Docker Compose...${NC}"
        docker-compose up -d
        
        echo -e "\n${YELLOW}⏳ Waiting for services to start...${NC}"
        sleep 60
        
        echo -e "\n${GREEN}✓ All services started!${NC}\n"
        ;;
    *)
        echo -e "\n${RED}✗ Invalid choice. Exiting.${NC}\n"
        exit 1
        ;;
esac

# Run health check
echo -e "${CYAN}Running health check...${NC}\n"
bash ./health-check.sh

echo -e "\n${CYAN}📊 Access services:${NC}"
echo -e "  - Eureka: http://localhost:8761"
echo -e "  - Gateway: http://localhost:8888"
echo -e "  - MinIO Console: http://localhost:9001 (minioadmin/minioadmin)"
echo -e "  - RabbitMQ: http://localhost:15672 (admin/admin123)\n"

echo -e "${GREEN}✓ Smart Academy is ready!${NC}\n"
