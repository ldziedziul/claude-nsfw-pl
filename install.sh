#!/usr/bin/env bash
#
# Merge claude-nsfw-pl spinner verbs into your local Claude Code settings.json.
# Backs up the existing file to settings.json.bak before writing.
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VERBS_FILE="$SCRIPT_DIR/spinner-verbs.json"

CONFIG_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SETTINGS="$CONFIG_DIR/settings.json"

if ! command -v jq >/dev/null 2>&1; then
  echo "error: jq is required but not installed (https://jqlang.github.io/jq/)" >&2
  exit 1
fi

if [ ! -f "$VERBS_FILE" ]; then
  echo "error: cannot find $VERBS_FILE" >&2
  exit 1
fi

mkdir -p "$CONFIG_DIR"

if [ -f "$SETTINGS" ]; then
  cp "$SETTINGS" "$SETTINGS.bak"
  echo "backed up existing settings to $SETTINGS.bak"
else
  echo '{}' > "$SETTINGS"
  echo "created new $SETTINGS"
fi

tmp="$SETTINGS.tmp"
jq -s '.[0] * .[1]' "$SETTINGS" "$VERBS_FILE" > "$tmp"
mv "$tmp" "$SETTINGS"

echo "installed $(jq '.spinnerVerbs.verbs | length' "$VERBS_FILE") spinner verbs into $SETTINGS"
echo "restart Claude Code to see them. To revert: mv \"$SETTINGS.bak\" \"$SETTINGS\""
