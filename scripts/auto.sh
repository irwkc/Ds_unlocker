#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL="$SCRIPT_DIR/install.sh"
CTL="$SCRIPT_DIR/ctl.sh"

require_root(){
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    log "${Y}Запускаю через sudo...${X}"
    exec sudo -E "$0" "$@"
  fi
}

main(){
  require_root "$@"
  log "${Y}1/3 Установка зависимостей и Cloudflare WARP...${X}"
  bash "$INSTALL"
  log "${Y}2/3 Подключение WARP...${X}"
  bash "$CTL" connect || true
  log "${Y}3/3 Диагностика Discord...${X}"
  bash "$CTL" probe gateway.discord.gg || true
  log "${G}Готово. Discord должен открываться.${X}"
}

main "$@"
