#!/usr/bin/env bash

set -Eeuo pipefail

ENV_FILE="/etc/environment"
SERVICE_ENV_FILE="/etc/voelk-signage.env"

rm -f "$ENV_FILE*"
rm -f "$SERVICE_ENV_FILE*"
