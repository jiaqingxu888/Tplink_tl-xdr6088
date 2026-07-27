#!/usr/bin/env bash
set -e
sudo timedatectl set-timezone "$TZ" || sudo ln -sf "/usr/share/zoneinfo/$TZ" /etc/localtime
echo "BUILD_DATE=$(date +%Y%m%d-%H%M)" >> "$GITHUB_ENV"
