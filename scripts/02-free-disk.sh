#!/usr/bin/env bash
set -e
sudo swapoff -a
sudo rm -f /swapfile
sudo rm -rf /usr/share/dotnet /usr/local/lib/android /opt/ghc /opt/hostedtoolcache/CodeQL
sudo apt-get clean
df -h
