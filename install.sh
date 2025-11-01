#!/bin/bash

# Open WebUI Installation Script
# Modified by Claude, based on kylanj7's Docker-Ollama-WebUI-Install
# This script automates the installation of Docker, Ollama, and Open WebUI

# Text colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${BLUE}                Open WebUI with Ollama Setup Script                  ${NC}"
echo -e "${BLUE}=====================================================================${NC}"

# Check for root/sudo privileges
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}This script must be run with sudo or as root.${NC}"
   exit 1
fi

# Function to check if a command exists
command_exists() {
  command -v "$1" >/dev/null 2>&1
}

# Install Docker if it's not already installed
install_docker() {
    echo -e "${YELLOW}Installing Docker...${NC}"
    
    # Update package lists
    apt-get update
    
    # Install packages to allow apt to use a repository over HTTPS
    apt-get install -y \
        apt-transport-https \
        ca-certificates \
        curl \
        gnupg \
        lsb-release
    
    # Add Docker's official GPG key
    mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    
    # Set up the Docker repository
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Update package lists again
    apt-get update
    
    # Install Docker Engine, containerd, and Docker Compose
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Enable and start Docker service
    systemctl enable docker
    systemctl start docker
    
    echo -e "${GREEN}Docker installed successfully.${NC}"
}

# Install Ollama if it's not already installed
install_ollama() {
    echo -e "${YELLOW}Installing Ollama...${NC}"
    
    # Download and run the Ollama install script
    curl -fsSL https://ollama.com/install.sh | sh
    
    echo -e "${GREEN}Ollama installed successfully.${NC}"
}

# Configure Ollama service to listen on all interfaces and set models path
configure_ollama() {
    echo -e "${YELLOW}Configuring Ollama service...${NC}"
    
    # Create systemd override directory if it doesn't exist
    mkdir -p /etc/systemd/system/ollama.service.d
    
    # Create override.conf file
    cat > /etc/systemd/system/ollama.service.d/override.conf << EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_MODELS=/usr/share/ollama/.ollama/models"
EOF
    
    # Reload systemd daemon and restart Ollama service
    systemctl daemon-reload
    systemctl enable ollama
    systemctl restart ollama
    
    echo -e "${GREEN}Ollama configured to listen on all interfaces.${NC}"
}

# Set up Open WebUI with Docker
setup_open_webui() {
    echo -e "${YELLOW}Setting up Open WebUI with Docker...${NC}"
    
    # Create directory for Open WebUI
    mkdir -p ~/open-webui/data
    
    # Create docker-compose.yml file
    cat > ~/open-webui/docker-compose.yml << EOF
version: '3'
services:
  open-webui:
    container_name: open-webui
    image: ghcr.io/open-webui/open-webui:main
    volumes:
      - ./data:/app/backend/data
    ports:
      - "3001:8080"
    restart: unless-stopped
    extra_hosts:
      - "host.docker.internal:host-gateway"
    environment:
      - OLLAMA_API_BASE_URL=http://host.docker.internal:11434/api
      - OPENAI_API_KEY=open-webui-not-needed
EOF
    
    # Start Open WebUI container
    cd ~/open-webui
    docker compose down -v 2>/dev/null || true  # Clean up any previous installation
    docker compose up -d
    
    echo -e "${GREEN}Open WebUI setup completed.${NC}"
}

# Main installation flow
main() {
    echo -e "${YELLOW}Starting installation...${NC}"
    
    # Install Docker if not installed
    if ! command_exists docker; then
        install_docker
    else
        echo -e "${GREEN}Docker is already installed.${NC}"
    fi
    
    # Install Ollama if not installed
    if ! command_exists ollama; then
        install_ollama
    else
        echo -e "${GREEN}Ollama is already installed.${NC}"
    fi
    
    # Configure Ollama
    configure_ollama
    
    # Set up Open WebUI
    setup_open_webui
    
    # Final information
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${GREEN}                  Setup completed successfully!                      ${NC}"
    echo -e "${GREEN}=====================================================================${NC}"
    echo -e "${YELLOW}Open WebUI is now available at: ${BLUE}http://localhost:3001${NC}"
    echo -e "${YELLOW}If you don't see your models in Open WebUI, try these steps:${NC}"
    echo -e "  ${BLUE}1. Check if Ollama is running: ${NC}systemctl status ollama"
    echo -e "  ${BLUE}2. List your Ollama models: ${NC}ollama list"
    echo -e "  ${BLUE}3. Restart Open WebUI: ${NC}cd ~/open-webui && docker compose restart"
    echo -e "  ${BLUE}4. Check Open WebUI logs: ${NC}docker logs open-webui"
    echo -e "${YELLOW}To stop Open WebUI: ${NC}cd ~/open-webui && docker compose down"
    echo -e "${YELLOW}To start Open WebUI: ${NC}cd ~/open-webui && docker compose up -d"
    echo -e "${GREEN}=====================================================================${NC}"
}

# Run the main installation
main
