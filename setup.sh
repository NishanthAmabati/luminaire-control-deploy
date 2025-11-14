#!/usr/bin/env bash
# setup.sh - Full setup and deployment of Luminaire Control on Raspberry Pi
# Author: Yagnya Nishanth Ambati
# Date: 2025-10-12
# Revision: 2025-11-14 (Improved idempotency, fixed docker-compose, env checks)

set -euo pipefail

LOG() { echo -e "\n\033[1;32m[SETUP]\033[0m $1"; }

REPO_URL="https://github.com/nishanthamabati/luminaire-control-deploy.git"
INSTALL_DIR="$HOME/luminaire-control-deploy"

LOG "Updating system and installing prerequisites..."
sudo apt update && sudo apt upgrade -y

# Install docker and compose plugin (modern method)
LOG "Installing Docker CE and Compose plugin..."

sudo apt install -y \
    ca-certificates \
    curl \
    gnupg \
    git \
    wget

# Add Docker GPG key
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

LOG "Docker installed successfully."

# Enable docker service
LOG "Starting Docker service..."
sudo systemctl enable docker
sudo systemctl start docker

# Add user to docker group
if ! id -nG "$USER" | grep -qw "docker"; then
    LOG "Adding user '$USER' to docker group (requires logout afterward)..."
    sudo usermod -aG docker "$USER"
    ADDED_TO_DOCKER_GROUP=1
else
    ADDED_TO_DOCKER_GROUP=0
fi

# Clone or update repo
LOG "Preparing deployment directory at $INSTALL_DIR..."

if [ -d "$INSTALL_DIR" ]; then
    LOG "Repository exists. Pulling latest updates..."
    cd "$INSTALL_DIR"
    git reset --hard
    git pull --rebase
else
    LOG "Cloning repository..."
    git clone "$REPO_URL" "$INSTALL_DIR"
    cd "$INSTALL_DIR"
fi

# Make sure .env exists
if [ ! -f ".env" ]; then
    LOG "ERROR: Missing .env file! Create .env inside $INSTALL_DIR before running setup."
    exit 1
fi

LOG "Loading environment variables from .env..."
set -o allexport
source .env
set +o allexport

LOG "Deploying containers using Docker Compose..."
docker compose pull
docker compose up -d --remove-orphans

PI_IP=$(hostname -I | awk '{print $1}')

LOG "Deployment complete!"
echo -e "\nWeb App Available At:"
echo "  👉 http://$PI_IP:80"
echo "  👉 http://localhost:80"

if [ "$ADDED_TO_DOCKER_GROUP" -eq 1 ]; then
    echo -e "\n⚠️  You were added to the Docker group."
    echo "Please **log out and log back in** (or reboot) to activate permissions."
fi

echo -e "\nDone!"
