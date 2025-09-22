#!/usr/bin/env bash
set -euo pipefail

# Colors
Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"

say() { printf "%b\n" "$1"; }

die() { say "${R}ERR:${X} $1"; exit 1; }

require_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    die "Требуются права sudo. Запусти: sudo $0"
  fi
}

need_cmd() { command -v "$1" >/dev/null 2>&1; }

install_xcode_clt() {
  if need_cmd xcode-select; then
    if ! xcode-select -p >/dev/null 2>&1; then
      say "${Y}Устанавливаю Xcode Command Line Tools...${X}"
      xcode-select --install || true
      say "${Y}Если появилось окно установки — заверши его, затем перезапусти скрипт.${X}"
      exit 0
    fi
  fi
}

install_brew() {
  if ! need_cmd brew; then
    say "${Y}Устанавливаю Homebrew...${X}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$($(uname -m | grep -q arm && echo "/opt/homebrew/bin/brew" || echo "/usr/local/bin/brew") shellenv)"
  fi
}

brew_install_pkgs() {
  say "${Y}Ставлю зависимости через brew...${X}"
  brew install cloudflare-warp git gnu-sed gawk coreutils || true
}

setup_warp() {
  say "${Y}Включаю WARP (без Zero Trust).${X}"
  /usr/local/bin/warp-cli --version >/dev/null 2>&1 || /opt/homebrew/bin/warp-cli --version >/dev/null 2>&1 || true
  local WARP=warp-cli
  command -v /opt/homebrew/bin/warp-cli >/dev/null 2>&1 && WARP=/opt/homebrew/bin/warp-cli
  command -v /usr/local/bin/warp-cli >/dev/null 2>&1 && WARP=/usr/local/bin/warp-cli
  $WARP set-mode warp || true
  $WARP register || true
  $WARP connect || true
}

main() {
  require_root
  install_xcode_clt
  install_brew
  brew_install_pkgs
  setup_warp
  say "${G}Готово. Cloudflare WARP установлен и включен. Используй scripts/ctl.sh для управления.${X}"
}

main "$@"
