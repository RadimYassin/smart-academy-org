#!/bin/bash

# Smart Academy - Stop All Services Script

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}Stopping All Smart Academy Services...${NC}"
echo ""

# Stop Docker containers
echo -e "${GREEN}Stopping databases...${NC}"
cd "$(dirname "$0")"
docker compose down
echo -e "${GREEN}✓ Databases stopped${NC}"

# Kill Spring Boot services
echo -e "${GREEN}Stopping Spring Boot services...${NC}"
pkill -f "spring-boot:run" || true
echo -e "${GREEN}✓ Spring Boot services stopped${NC}"

# Kill Node.js services
echo -e "${GREEN}Stopping Node.js services...${NC}"
pkill -f "nest start" || true
pkill -f "npm.*start" || true
echo -e "${GREEN}✓ Node.js services stopped${NC}"

# Kill Python services
echo -e "${GREEN}Stopping Python services...${NC}"
pkill -f "uvicorn.*app.main:app" || true
echo -e "${GREEN}✓ Python services stopped${NC}"

echo ""
echo -e "${GREEN}All services stopped!${NC}"
