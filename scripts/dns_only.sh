#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка DNS-only режима WARP ===${X}"

# Останавливаем WARP
log "${Y}Останавливаю WARP...${X}"
sudo warp-cli disconnect || true

# Устанавливаем DNS-only режим
log "${Y}Устанавливаю DNS-only режим...${X}"
sudo warp-cli mode doh || true

# Подключаемся
log "${Y}Подключаюсь...${X}"
sudo warp-cli connect || true

# Проверяем статус
log "${Y}Проверяю статус...${X}"
warp-cli status || true

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== DNS-only режим настроен ===${X}"
