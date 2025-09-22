#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}Удаляю старую регистрацию...${X}"
warp-cli registration delete || true

log "${Y}Создаю новую регистрацию...${X}"
warp-cli registration new || true

log "${Y}Проверяю статус...${X}"
warp-cli status || true

log "${Y}Устанавливаю режим...${X}"
sudo warp-cli mode warp || true

log "${Y}Подключаюсь...${X}"
sudo warp-cli connect || true

log "${Y}Финальная проверка...${X}"
warp-cli status || true

log "${G}Готово!${X}"
