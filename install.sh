#!/bin/bash

# Ollama Docker Setup Script
# This script installs Docker, Docker Compose, and sets up Ollama with a web UI
# Created on: October 31, 2025

set -e  # Exit on error

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}  Ollama Docker Setup Script            ${NC}"
echo -e "${BLUE}=========================================${NC}"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo -e "${RED}Please run as root or with sudo${NC}"
  exit 1
fi

# Function to print section headers
section() {
  echo -e "\n${GREEN}>>> $1${NC}"
}

# Step 1: Update system
section "Updating system packages"
apt-get update
apt-get upgrade -y

# Step 2: Install Docker dependencies
section "Installing Docker dependencies"
apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Step 3: Add Docker's official GPG key
section "Adding Docker's GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Step 4: Set up the stable Docker repository
section "Setting up Docker repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Step 5: Install Docker Engine
section "Installing Docker Engine"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Step 6: Verify Docker installation
section "Verifying Docker installation"
docker --version
docker compose version

# Step 7: Add current user to docker group to avoid using sudo
section "Adding current user to docker group"
usermod -aG docker $SUDO_USER

# Step 8: Create directory for Ollama data
section "Creating directory for Ollama data"
OLLAMA_DIR="/home/$SUDO_USER/ollama"
mkdir -p $OLLAMA_DIR/ollama-data
chown -R $SUDO_USER:$SUDO_USER $OLLAMA_DIR

# Step 9: Create Docker Compose file
section "Creating Docker Compose configuration"
cat > $OLLAMA_DIR/docker-compose.yml << 'EOL'
version: '3'

services:
  ollama:
    container_name: ollama
    image: ollama/ollama:latest
    volumes:
      - ./ollama-data:/root/.ollama
    ports:
      - "11434:11434"
    restart: unless-stopped
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]

  webui:
    container_name: ollama-webui
    image: ghcr.io/ollama-webui/ollama-webui:main
    volumes:
      - ./webui-data:/app/backend/data
    ports:
      - "3000:8080"
    restart: unless-stopped
    environment:
      - 'OLLAMA_API_BASE_URL=http://ollama:11434/api'
    depends_on:
      - ollama
EOL

# Check if NVIDIA GPU is available and modify Docker Compose file accordingly
if ! command -v nvidia-smi &> /dev/null; then
  echo -e "${YELLOW}NVIDIA GPU not detected. Removing GPU configuration from docker-compose.yml${NC}"
  sed -i '/deploy:/,+5d' $OLLAMA_DIR/docker-compose.yml
else
  echo -e "${GREEN}NVIDIA GPU detected. Keeping GPU configuration.${NC}"
  
  # Step 9.5: Install NVIDIA Container Toolkit if GPU is available
  section "Installing NVIDIA Container Toolkit"
  curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
  curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
  apt-get update
  apt-get install -y nvidia-container-toolkit
  nvidia-ctk runtime configure --runtime=docker
  systemctl restart docker
fi

# Step 10: Create webui-data directory
section "Creating webui-data directory"
mkdir -p $OLLAMA_DIR/webui-data
chown -R $SUDO_USER:$SUDO_USER $OLLAMA_DIR/webui-data

# Step 11: Set permissions for Docker Compose file
section "Setting permissions"
chown $SUDO_USER:$SUDO_USER $OLLAMA_DIR/docker-compose.yml

# Step 12: Instructions for starting the services
section "Setup Complete!"
echo -e "${GREEN}Docker, Ollama, and Web UI have been configured successfully!${NC}"
echo -e "${YELLOW}IMPORTANT: You need to log out and log back in for the docker group changes to take effect.${NC}"
echo ""
echo -e "To start Ollama and the Web UI, run the following commands:"
echo -e "${BLUE}cd ~/ollama${NC}"
echo -e "${BLUE}docker compose up -d${NC}"
echo ""
echo -e "The services will be available at:"
echo -e "- Ollama API: http://localhost:11434"
echo -e "- Ollama Web UI: http://localhost:3000"
echo ""
echo -e "To pull a model, use:"
echo -e "${BLUE}docker exec -it ollama ollama pull llama2${NC}"
echo ""
echo -e "To stop the services:"
echo -e "${BLUE}cd ~/ollama${NC}"
echo -e "${BLUE}docker compose down${NC}"
echo ""
echo -e "${GREEN}Happy coding!${NC}"
