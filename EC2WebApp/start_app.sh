#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
VENV_DIR="venv"
APP_MODULE="app:app"
WORKERS=4
HOST="0.0.0.0"
PORT=8000

echo -e "${BLUE}Starting Flask Web App...${NC}"

# Check if virtual environment exists
if [ ! -d "$VENV_DIR" ]; then
    echo -e "${BLUE}Creating virtual environment...${NC}"
    python3 -m venv $VENV_DIR
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to create virtual environment${NC}"
        exit 1
    fi
    echo -e "${GREEN}Virtual environment created successfully${NC}"
fi

# Activate virtual environment
echo -e "${BLUE}Activating virtual environment...${NC}"
source $VENV_DIR/bin/activate

# Check if requirements are installed
if [ ! -f "$VENV_DIR/.requirements_installed" ]; then
    echo -e "${BLUE}Installing requirements...${NC}"
    pip install --upgrade pip
    pip install -r requirements.txt
    if [ $? -ne 0 ]; then
        echo -e "${RED}Failed to install requirements${NC}"
        exit 1
    fi
    touch $VENV_DIR/.requirements_installed
    echo -e "${GREEN}Requirements installed successfully${NC}"
else
    echo -e "${GREEN}Requirements already installed${NC}"
fi

# Start the application with gunicorn
echo -e "${GREEN}Starting application with Gunicorn...${NC}"
echo -e "${BLUE}Access the app at: http://localhost:$PORT${NC}"
echo -e "${BLUE}Press Ctrl+C to stop the server${NC}"
echo ""

gunicorn -w $WORKERS -b $HOST:$PORT $APP_MODULE
