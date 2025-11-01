# Open WebUI with Ollama Installation Script

This repository contains an automated installation script for setting up [Open WebUI](https://github.com/open-webui/open-webui) (formerly Ollama Web UI) with [Ollama](https://ollama.com/) on Linux systems.

## What This Script Does

This script automates the installation and configuration of:

1. **Docker and Docker Compose** - For running Open WebUI in a container
2. **Ollama** - The backend service that runs large language models locally
3. **Open WebUI** - The web interface for interacting with Ollama models
4. **System Service Configuration** - Sets up Ollama to properly expose its API and find models

## Requirements

- A Linux system (Ubuntu/Debian-based systems recommended)
- Sudo/root access
- Internet connection
- At least 32GB RAM and modern CPU recommended for running larger models (Nvidia GPU perferred)
- Sufficient disk space for Docker images and LLM models

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/open-webui-install.git
   cd open-webui-install
   ```

2. Make the script executable:
   ```bash
   chmod +x install.sh
   ```

3. Run the script with sudo:
   ```bash
   sudo ./install.sh
   ```

4. After installation completes, access Open WebUI at http://localhost:3001

## Features

- **Automated Installation** - Installs all necessary components with minimal user interaction
- **Proper API Configuration** - Correctly configures Ollama to listen on all interfaces
- **Model Path Configuration** - Sets up Ollama to find models in the standard location
- **Docker Compose Setup** - Uses Docker Compose for easier management of the Open WebUI container
- **System Service Integration** - Configures Ollama as a system service that starts on boot

## Post-Installation

After installation:

1. Open your browser and navigate to http://localhost:3001
2. Create an account or log in
3. Select one of your installed Ollama models from the dropdown
4. Start chatting with your local LLM!

## Managing Models

To manage your models:

- **List models**: `ollama list`
- **Pull new models**: `ollama pull modelname`
- **Remove models**: `ollama rm modelname`

Any changes to your Ollama models will be reflected in Open WebUI.

## Maintenance Commands

- **Start Open WebUI**: `cd ~/open-webui && docker compose up -d`
- **Stop Open WebUI**: `cd ~/open-webui && docker compose down`
- **Update Open WebUI**: `cd ~/open-webui && docker compose pull && docker compose up -d`
- **View logs**: `docker logs open-webui`
- **Restart Ollama**: `sudo systemctl restart ollama`

## Troubleshooting

If you don't see your models in Open WebUI:

1. Check if Ollama is running: `systemctl status ollama`
2. Verify your models are installed: `ollama list`
3. Check Open WebUI logs: `docker logs open-webui`
4. Ensure Ollama is listening on all interfaces: `sudo netstat -tulpn | grep 11434`
5. Restart both services:
   ```bash
   sudo systemctl restart ollama
   cd ~/open-webui && docker compose restart
   ```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Based on the work by [kylanj7](https://github.com/kylanj7/Docker-Ollama-WebUI-Install)
- Thanks to the [Open WebUI](https://github.com/open-webui/open-webui) and [Ollama](https://github.com/ollama/ollama) projects
