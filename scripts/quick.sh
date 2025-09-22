#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

REPO_URL="https://github.com/irwkc/Ds_unlocker.git"
TEMP_DIR="$(mktemp -d)/Ds_unlocker"

log "${Y}Качаю репозиторий...${X}"
git clone "$REPO_URL" "$TEMP_DIR" || die "Не удалось клонировать репозиторий"

log "${Y}Устанавливаю зависимости...${X}"
cd "$TEMP_DIR"
bash scripts/install.sh

log "${Y}Запускаю zapret для Discord...${X}"
bash scripts/zapret_mac_real.sh

log "${G}Готово! Discord должен работать.${X}"
