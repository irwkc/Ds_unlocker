#!/usr/bin/env bash
set -euo pipefail

# Colors
Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"

say() { printf "%b\n" "$1"; }

die() { say "${R}ERR:${X} $1"; exit 1; }

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
  brew install git gnu-sed gawk coreutils || true
}

main() {
  # Не требуем root для установки зависимостей
  install_xcode_clt
  install_brew
  brew_install_pkgs
  say "${G}Готово. Зависимости установлены.${X}"
}

main "$@"
