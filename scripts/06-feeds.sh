#!/usr/bin/env bash
set -e
./scripts/feeds update -a
./scripts/feeds install -a
