#!/usr/bin/env bash
set -e
git clone --depth 1 -b "$UPSTREAM_BRANCH" "$UPSTREAM_REPO" openwrt
cd openwrt
echo "cloned HEAD=$(git rev-parse HEAD) expect=$UP_SHA"
