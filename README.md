# Ollama with Docker and Web UI Setup Guide

This guide helps you set up Ollama with Docker and a user-friendly web interface on your Linux workstation.

## What's Included

This setup provides:
- **Docker** - Container platform to run Ollama
- **Ollama** - Local large language model runner
- **Ollama Web UI** - User-friendly interface for interacting with your models

## System Requirements

- Linux workstation (Ubuntu/Debian-based distro recommended)
- At least 8GB RAM (16GB+ recommended for larger models)
- 20GB+ free disk space
- NVIDIA GPU (optional but recommended for better performance)

## Installation Instructions

1. Download the setup script:
   ```
   ollama_docker_setup.sh
   ```

2. Make the script executable:
   ```bash
   chmod +x ollama_docker_setup.sh
   ```

3. Run the script with sudo:
   ```bash
   sudo ./ollama_docker_setup.sh
   ```

4. **Important**: Log out and log back in to apply the docker group membership.

5. Start the services:
   ```bash
   cd ~/ollama
   docker compose up -d
   ```

## Accessing the Services

- **Ollama API**: http://localhost:11434
- **Ollama Web UI**: http://localhost:3000

## Managing Models

To pull a model (example: llama2):
```bash
docker exec -it ollama ollama pull llama2
```

Other available models include:
- llama3 - Meta's LLaMA 3
- mistral - Mistral AI's model
- gemma - Google's lightweight model
- phi3 - Microsoft's model
- vicuna - Berkeley's model
- ...and many more

## Stopping and Starting

To stop the services:
```bash
cd ~/ollama
docker compose down
```

To start again:
```bash
cd ~/ollama
docker compose up -d
```

## Troubleshooting

- If you see "permission denied" errors with Docker, make sure you've logged out and logged back in after installation.
- For GPU issues, check your NVIDIA drivers are properly installed with `nvidia-smi`.
- To check logs: `docker logs ollama` or `docker logs ollama-webui`.

## Advanced Configuration

The Docker Compose file is located at `~/ollama/docker-compose.yml` and can be modified for:
- Adding more memory/CPU limits
- Changing ports
- Adding custom volumes
- Modifying environment variables

After changes, restart with:
```bash
cd ~/ollama
docker compose down
docker compose up -d
```

## Updating

To update to the latest versions:
```bash
cd ~/ollama
docker compose pull
docker compose down
docker compose up -d
```

## Security Note

This setup is configured for local use. If you plan to expose this to a network, add proper authentication and encryption.
