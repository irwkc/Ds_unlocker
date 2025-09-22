#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
msg(){ printf "%b\n" "$1"; }

default_domains_file="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/domains.txt"
DOMAINS_FILE="${DOMAINS_FILE:-$default_domains_file}"

# Detect warp-cli path
WARP=warp-cli
command -v /opt/homebrew/bin/warp-cli >/dev/null 2>&1 && WARP=/opt/homebrew/bin/warp-cli
command -v /usr/local/bin/warp-cli >/dev/null 2>&1 && WARP=/usr/local/bin/warp-cli

ensure_domains(){
  [[ -s "$DOMAINS_FILE" ]] || { msg "${R}Нет domains.txt${X}"; exit 1; }
}

connect(){
  sudo "$WARP" set-mode warp || true
  sudo "$WARP" connect || true
}

disconnect(){
  sudo "$WARP" disconnect || true
}

status(){
  "$WARP" status || true
}

# Simple diagnostics for Discord endpoints
probe(){
  local host="${1:-gateway.discord.gg}"
  msg "${Y}Проверяю $host...${X}"
  ping -c 2 "$host" | cat || true
  curl -I --max-time 10 "https://$host" | cat || true
}

usage(){
  cat <<USG
Usage: $0 [connect|disconnect|status|probe [host]]
USG
}

case "${1:-}" in
  connect) connect ;;
  disconnect) disconnect ;;
  status) status ;;
  probe) shift; probe "${1:-gateway.discord.gg}" ;;
  *) usage ;;
 esac
