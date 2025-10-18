#!/usr/bin/env bash
# setup.sh - Full setup and deployment of Luminaire Control on Raspberry Pi
# Author: Yagnya Nishanth Ambati
# Date: 2025-10-12
# Revision: 2025-10-18 (Fixing Docker permissions)

set -e # Exit immediately if a command fails
set -u # Treat unset variables as errors

# variables
REPO_URL="https://github.com/nishanthamabati/luminaire-control-deploy.git"
INSTALL_DIR="$HOME/luminaire-control-deploy"

# system update & pre requisites
echo "Updating system, installing prerequisites (git, curl, wget, docker)..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y git curl wget docker.io docker-compose

# docker setup
echo "Setting up Docker permissions and service..."

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Add current user to the 'docker' group to run commands without sudo
if ! getent group docker | grep -q "\b$USER\b"; then
    echo "Adding user '$USER' to the 'docker' group. This requires a re-login to take effect."
    sudo usermod -aG docker "$USER"
fi

# clone repo
echo "Cloning/pulling repository..."
if [ -d "$INSTALL_DIR" ]; then
    echo "Directory exists: $INSTALL_DIR. Pulling latest changes..."
    cd "$INSTALL_DIR"
    git pull
else
    echo "Cloning repository to $INSTALL_DIR..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# deploy services
echo "Deploying services with Docker Compose..."
sudo docker-compose up -d

# --- 5. AUTO-START ON REBOOT (Cron job, commented out for optional use) ---
# echo "--- 5. Setting up auto-start on reboot (using Cron)..."
# CRON_CMD="@reboot cd $INSTALL_DIR && $DOCKER_COMPOSE_CMD up -d"
# (crontab -l 2>/dev/null | grep -Fv "$INSTALL_DIR"; echo "$CRON_CMD") | crontab -
# echo "Cron job added."

# success message
PI_IP=$(hostname -I | awk '{print $1}')
echo
echo "Deployment complete!"
echo "IMPORTANT: Please **log out and log back in** for the new Docker permissions to take effect."
echo "For future commands (like 'docker ps'), please **log out and log back in** for the new Docker permissions to take full effect."
echo "If you don't re-login, you might see 'permission denied' errors.
echo "Access the web app at: http://$PI_IP:8080 or http://localhost:8080"
echo "Use '$DOCKER_COMPOSE_CMD logs -f' to view logs"
