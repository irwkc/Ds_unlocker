#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}Останавливаю WARP daemon...${X}"
sudo launchctl stop com.cloudflare.warp || true
sleep 2

log "${Y}Запускаю WARP daemon...${X}"
sudo launchctl start com.cloudflare.warp || true
sleep 3

log "${Y}Регистрирую устройство...${X}"
warp-cli registration new || true
sleep 2

log "${Y}Проверяю статус...${X}"
warp-cli status || true

log "${Y}Устанавливаю режим и подключаюсь...${X}"
sudo warp-cli mode warp || true
sudo warp-cli connect || true

log "${Y}Финальная проверка...${X}"
warp-cli status || true

log "${G}Готово!${X}"
