#!/usr/bin/env bash

set -Eeuo pipefail

ENV_FILE="/etc/environment"
SERVICE_ENV_FILE="/etc/voelk-signage.env"

sudo rm -f "$ENV_FILE" "$ENV_FILE".backup.*
sudo rm -f "$SERVICE_ENV_FILE" "$SERVICE_ENV_FILE".backup.*
