#!/usr/bin/env bash
set -e
mkdir -p "$GITHUB_WORKSPACE/release"
find bin/targets -type f \( -name '*xdr6088*-sysupgrade.bin' -o -name '*xdr6088*-factory.bin' \) -exec cp -v {} "$GITHUB_WORKSPACE/release/" \;
ls -lh "$GITHUB_WORKSPACE/release/" || true
N=$(find "$GITHUB_WORKSPACE/release/" -type f \( -name '*-sysupgrade.bin' -o -name '*-factory.bin' \) | wc -l)
echo "firmware count=$N"
if [ "$N" -lt 1 ]; then echo "FATAL no xdr6088 firmware"; exit 1; fi
