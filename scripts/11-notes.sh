#!/usr/bin/env bash
set -e
BIN=$(find "$GITHUB_WORKSPACE/release/" -name '*-sysupgrade.bin' | head -1)
MANIFEST=$(find bin/targets -name '*.manifest' | head -1)
PJSON=$(find bin/targets -name 'profiles.json' | head -1)
SIZE=$(ls -lh "$BIN" | awk '{print $5}')
VER=$(grep -oE '"version_number": *"[^"]*"' "$PJSON" | head -1 | cut -d'"' -f4)
VCODE=$(grep -oE '"version_code": *"[^"]*"' "$PJSON" | head -1 | cut -d'"' -f4)
UP_SHA_SHORT=${UP_SHA:0:10}
RUN_URL="${GITHUB_RUN_URL:-https://github.com/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}}"
SHA256_SUMS=$(cd "$GITHUB_WORKSPACE/release" && sha256sum ./*.bin 2>/dev/null | sed 's# \./# #' || true)
PKG_COUNT=0
PKGS_LIST="（未获取到包列表）"
if [ -n "$MANIFEST" ] && [ -f "$MANIFEST" ]; then
  PKG_COUNT=$(awk -F' - ' 'NF>=1 && $1!="" {print $1}' "$MANIFEST" | sort -u | wc -l | tr -d ' ')
  PKGS_LIST=$(awk -F' - ' 'NF>=1 && $1!="" {print $1}' "$MANIFEST" | sort -u | paste -sd ', ')
fi
SEL_COUNT=0
SEL_PKGS=""
if [ -f "$GITHUB_WORKSPACE/$DEFCFG_FILE" ]; then
  SEL_COUNT=$(grep -cE '^CONFIG_PACKAGE_.*=y' "$GITHUB_WORKSPACE/$DEFCFG_FILE" || true)
  SEL_PKGS=$(grep -E '^CONFIG_PACKAGE_.*=y' "$GITHUB_WORKSPACE/$DEFCFG_FILE" | sed -E 's/^CONFIG_PACKAGE_//; s/=y$//' | sort -u | paste -sd ', ')
fi
OUT=/tmp/notes.md
{
  echo "# 📦 $DEVICE_NAME · $BUILD_DATE"
  echo ""
  echo "- 🖥️ 设备：$DEVICE_NAME"
  echo "- 🏷️ 版本：${VER:-unknown} (${VCODE:-unknown})"
  echo "- 🔀 上游仓库：$UPSTREAM_REPO"
  echo "- 🔖 本次 Commit：[$UP_SHA_SHORT]($UPSTREAM_REPO/commit/$UP_SHA)"
  echo "- 🧬 指纹：$FP"
  echo "- 📐 大小：$SIZE"
  echo "- 🌐 默认IP：$DEFAULT_IP"
  echo "- 🕒 时间：$BUILD_DATE (Asia/Shanghai)"
  echo "- ⚡ 特性：内核 BPF / XDP 已启用（dae 就绪）"
  echo ""
  echo "## ✅ 校验和 SHA256"
  echo '```'
  echo "$SHA256_SUMS"
  echo '```'
  echo ""
  echo "## ⭐ 配置启用的软件包（$SEL_COUNT 个）"
  if [ "${#SEL_PKGS}" -gt 800 ]; then
    echo "$(echo "$SEL_PKGS" | cut -c1-800) ……（共 $SEL_COUNT 个，完整见下方折叠）"
  elif [ -n "$SEL_PKGS" ]; then
    echo "$SEL_PKGS"
  else
    echo "（defconfig 未显式指定额外包，全部见下方折叠）"
  fi
  echo ""
  echo "<details>"
  echo "<summary>📦 查看全部内置包（含依赖，共 $PKG_COUNT 个，点击展开）</summary>"
  echo ""
  echo "$PKGS_LIST"
  echo ""
  echo "</details>"
  echo ""
  echo "## 🔄 升级提示"
  echo '1. Web：系统 → 备份/升级 → 上传 sysupgrade.bin'
  echo '2. 命令行：sysupgrade -n /tmp/固件.bin （-n 不保留配置）'
  echo '3. 升级前备份；跨大版本建议不保留配置'
  echo ""
  echo "---"
  echo "🤖 自动构建 · [查看本次构建日志]($RUN_URL)"
} > "$OUT"
echo "---- notes preview ----"
cat "$OUT"
