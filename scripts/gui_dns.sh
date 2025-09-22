#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка DNS через GUI ===${X}"

log "${Y}Открываю настройки сети...${X}"
open "x-apple.systempreferences:com.apple.preference.network"

log "${Y}Инструкции:${X}"
echo "1. Выбери Wi-Fi в списке слева"
echo "2. Нажми кнопку 'Advanced...'"
echo "3. Перейди на вкладку 'DNS'"
echo "4. Нажми '+' и добавь: 1.1.1.1"
echo "5. Нажми '+' и добавь: 1.0.0.1"
echo "6. Нажми 'OK' и 'Apply'"

log "${Y}После настройки DNS нажми Enter...${X}"
read -p ""

log "${Y}Очищаю кеш DNS...${X}"
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== Готово! ===${X}"
