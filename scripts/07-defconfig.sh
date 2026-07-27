#!/usr/bin/env bash
set -e
if [ ! -f "../$DEFCFG_FILE" ]; then echo "FATAL defconfig not found: $DEFCFG_FILE"; exit 1; fi
cp "../$DEFCFG_FILE" .config
make defconfig
echo "---- device switches =y ----"
grep -E 'CONFIG_TARGET_.*_DEVICE_.*=y' .config || echo "(none)"
if grep -qE 'CONFIG_TARGET_.*_DEVICE_tplink_tl-xdr6088=y' .config; then
  echo "OK xdr6088 selected"
else
  echo "FATAL xdr6088 NOT selected -> fix device line in defconfig"
  echo "need: CONFIG_TARGET_mediatek_filogic_DEVICE_tplink_tl-xdr6088=y and CONFIG_TARGET_mediatek_filogic=y"
  exit 1
fi
