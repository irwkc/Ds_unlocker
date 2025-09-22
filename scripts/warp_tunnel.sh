#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка WARP туннеля ===${X}"

# Останавливаем WARP
log "${Y}Останавливаю WARP...${X}"
warp-cli disconnect || true

# Устанавливаем режим туннеля
log "${Y}Устанавливаю режим туннеля...${X}"
sudo warp-cli mode warp || true

# Подключаемся
log "${Y}Подключаюсь к WARP...${X}"
sudo warp-cli connect || true

# Проверяем статус
log "${Y}Проверяю статус...${X}"
warp-cli status || true

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== WARP туннель настроен ===${X}"
