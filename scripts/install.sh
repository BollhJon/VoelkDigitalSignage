#!/usr/bin/env bash
set -euo pipefail

INSTALL_DIR="${SIGNAGE_DIR:-$HOME/VoelkDigitalSignage}"
SERVICE_USER="${SUDO_USER:-$USER}"

echo "Update local repository"
git -C "$INSTALL_DIR" pull

sh "$INSTALL_DIR/scripts/configure_envoirment.sh"

echo "System install/update git, python and chromium-browser"
sudo apt-get update
sudo apt-get install -y git python3 python3-venv chromium-browser

echo "Setup Virtual Enviroment and install/update pyhton packages"
python3 -m venv "$INSTALL_DIR/.venv"
"$INSTALL_DIR/.venv/bin/pip" install --upgrade pip
"$INSTALL_DIR/.venv/bin/pip" install -r "$INSTALL_DIR/requirements.txt"

echo "Setup Server Service"
sudo install -m 644 "$INSTALL_DIR/deploy/signage.service" /etc/systemd/system/signage.service
sudo sed -i "s|__USER__|$SERVICE_USER|g; s|__INSTALL_DIR__|$INSTALL_DIR|g" /etc/systemd/system/signage.service
sudo systemctl daemon-reload
sudo systemctl enable --now signage.service

echo "Setup Kiosk Autostart"
mkdir -p "$HOME/.config/autostart"
sed "s|__START_URL__|http://127.0.0.1:8000/|g" "$INSTALL_DIR/deploy/signage-kiosk.desktop" > "$HOME/.config/autostart/signage-kiosk.desktop"
chmod 644 "$HOME/.config/autostart/signage-kiosk.desktop"

echo "Install finished. Reboot System!"
