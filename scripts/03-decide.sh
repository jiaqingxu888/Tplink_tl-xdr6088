#!/usr/bin/env bash
set -e
FORCE="${INPUT_FORCE_BUILD:-${FORCE:-false}}"
UP_SHA=$(git ls-remote "$UPSTREAM_REPO" "refs/heads/${UPSTREAM_BRANCH}" | awk '{print $1}')
if [ -z "$UP_SHA" ]; then echo "FATAL cannot resolve upstream HEAD"; exit 1; fi
FP=$( ( echo "$UP_SHA"; cat "$DEFCFG_FILE"; echo "$CFG_TARGET|$CFG_SUBTARGET|$DEVICE_NAME|$DEFAULT_IP|$UPSTREAM_BRANCH" ) | sha256sum | cut -c1-12 )
HTTP=$(curl -sS -o /tmp/rel.json -w "%{http_code}" -H "Authorization: Bearer $GITHUB_TOKEN" -H "Accept: application/vnd.github+json" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases/latest" || true)
LAST_FP=""; TAG=""
if [ "$HTTP" = "200" ]; then
  TAG=$(jq -r '.tag_name // empty' /tmp/rel.json)
  LAST_FP=$(echo "$TAG" | grep -oE '[0-9a-f]{12}' | head -1 || true)
fi
if [ "$FORCE" = "true" ]; then SB=true; REASON="force_build"
elif [ -z "$LAST_FP" ]; then SB=true; REASON="no matching release"
elif [ "$LAST_FP" != "$FP" ]; then SB=true; REASON="fingerprint changed"
else SB=false; REASON="release up-to-date"; fi
echo "==== DECIDE ===="
echo "upstream=$UP_SHA fp=$FP release=${TAG:-none} release_fp=${LAST_FP:-none} build=$SB ($REASON)"
echo "SHOULD_BUILD=$SB" >> "$GITHUB_ENV"
echo "FP=$FP" >> "$GITHUB_ENV"
echo "UP_SHA=$UP_SHA" >> "$GITHUB_ENV"
