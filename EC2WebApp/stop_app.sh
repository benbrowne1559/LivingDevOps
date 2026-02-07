#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}Stopping Flask Web App...${NC}"

# Find and kill gunicorn processes
PIDS=$(pgrep -f "gunicorn.*app:app")

if [ -z "$PIDS" ]; then
    echo -e "${BLUE}No running gunicorn processes found${NC}"
    exit 0
fi

echo -e "${BLUE}Found gunicorn processes: $PIDS${NC}"
echo $PIDS | xargs kill -TERM

sleep 2

# Check if processes are still running
PIDS=$(pgrep -f "gunicorn.*app:app")
if [ -z "$PIDS" ]; then
    echo -e "${GREEN}Application stopped successfully${NC}"
else
    echo -e "${BLUE}Force killing remaining processes...${NC}"
    echo $PIDS | xargs kill -9
    echo -e "${GREEN}Application stopped${NC}"
fi
