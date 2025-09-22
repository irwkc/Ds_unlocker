#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Очистка zapret ===${X}"

# Останавливаем tpws
log "${Y}Останавливаю tpws...${X}"
sudo pkill -f tpws || true

# Удаляем pf правила
log "${Y}Удаляю pf правила...${X}"
sudo pfctl -d || true
sudo pfctl -f /etc/pf.conf || true

# Удаляем zapret
log "${Y}Удаляю zapret...${X}"
sudo rm -rf /tmp/zapret-mac || true
sudo rm -f /tmp/discord.pf || true

# Останавливаем WARP
log "${Y}Останавливаю WARP...${X}"
warp-cli disconnect || true

# Возвращаем DNS по умолчанию
log "${Y}Возвращаю DNS по умолчанию...${X}"
sudo networksetup -setdnsservers "Wi-Fi" "Empty" || true

log "${G}=== Очистка завершена ===${X}"
