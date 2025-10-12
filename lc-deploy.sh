#!/usr/bin/env bash
# setup.sh - Full setup and deployment of Luminaire Control on Raspberry Pi
# Author: Yagnya Nishanth Ambati
# Date: 2025-10-12

set -e  # Exit immediately if a command fails
set -u  # Treat unset variables as errors

# Update system & install prerequisites
echo "Updating system, installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget docker.io docker-compose

# Enable and start Docker
sudo systemctl enable docker
sudo systemctl start docker


# Clone repository
REPO_URL="https://github.com/nishanthamabati/luminaire-control-deploy.git"
INSTALL_DIR="$HOME/luminaire-control-deploy"

if [ -d "$INSTALL_DIR" ]; then
    echo "Directory exists, pulling latest changes..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Deploy all services
echo "Starting services..."
docker compose up -d

# Auto-start on reboot
CRON_CMD="@reboot cd $INSTALL_DIR && /usr/bin/docker compose up -d"
(crontab -l 2>/dev/null | grep -Fv "$INSTALL_DIR"; echo "$CRON_CMD") | crontab -

# Success message
PI_IP=$(hostname -I | awk '{print $1}')
echo
echo "Deployment complete!"
echo "Access the web app at: http://$PI_IP:8080 or http://localhost:8080"
echo "Use 'docker compose logs -f' to view logs"