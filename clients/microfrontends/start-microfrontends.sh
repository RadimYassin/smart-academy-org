#!/bin/bash

# Smart Academy - Start All Microfrontends Script
# This script starts all frontend microservices in separate terminal tabs

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}Smart Academy - Frontend Startup${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# Check file watcher limit
WATCHER_LIMIT=$(cat /proc/sys/fs/inotify/max_user_watches)
if [ "$WATCHER_LIMIT" -lt 524288 ]; then
    echo -e "${RED}ERROR: System file watcher limit is too low ($WATCHER_LIMIT).${NC}"
    echo -e "${YELLOW}You need to increase it to run multiple microfrontends.${NC}"
    echo -e "${YELLOW}Run this command to fix it:${NC}"
    echo ""
    echo -e "${GREEN}echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p${NC}"
    echo ""
    echo -e "${RED}Stopping startup to prevent crashes.${NC}"
    exit 1
fi

# Function to start a service in a new tab
start_service() {
    local service_name=$1
    local command=$2
    local directory=$3
    
    echo -e "${YELLOW}Starting $service_name...${NC}"
    
    gnome-terminal --tab --title="$service_name" --working-directory="$directory" -- bash -c "$command; exec bash" &
    
    sleep 2
}

echo -e "${GREEN}Starting Microfrontends...${NC}"

# Start Shell (Container)
start_service "Shell (Host)" "npm run dev" "$SCRIPT_DIR/shell"

# Start Microfrontends
start_service "Auth MFE" "npm run dev" "$SCRIPT_DIR/auth"
start_service "Dashboard MFE" "npm run dev" "$SCRIPT_DIR/dashboard"
start_service "Courses MFE" "npm run dev" "$SCRIPT_DIR/courses"

echo ""
echo -e "${GREEN}====================================${NC}"
echo -e "${GREEN}All Microfrontends Started!${NC}"
echo -e "${GREEN}====================================${NC}"
echo ""
echo -e "${YELLOW}Application URLs:${NC}"
echo "  - Shell (Main App): http://localhost:5001"
echo "  - Auth MFE:         http://localhost:5002"
echo "  - Dashboard MFE:    http://localhost:5003"
echo "  - Courses MFE:      http://localhost:5004"
echo ""
echo -e "${YELLOW}Note:${NC} If you see 'ENOSPC' errors, run:"
echo "echo fs.inotify.max_user_watches=524288 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"
echo ""
