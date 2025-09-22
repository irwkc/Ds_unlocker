#!/usr/bin/env bash
set -euo pipefail

PLIST_SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/launchd/com.irwkc.ds_unlocker.connect.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.irwkc.ds_unlocker.connect.plist"

mkdir -p "$HOME/Library/LaunchAgents"
cp "$PLIST_SRC" "$PLIST_DST"
launchctl unload "$PLIST_DST" 2>/dev/null || true
launchctl load -w "$PLIST_DST"
echo "Автозапуск установлен. Перезайди в систему или выполни: launchctl start com.irwkc.ds_unlocker.connect"
