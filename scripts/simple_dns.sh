#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Простая настройка DNS ===${X}"

# Создаем резервную копию
log "${Y}Создаю резервную копию...${X}"
sudo cp /etc/resolv.conf /etc/resolv.conf.backup 2>/dev/null || true

# Устанавливаем DNS
log "${Y}Устанавливаю DNS Cloudflare...${X}"
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf > /dev/null

# Очищаем кеш
log "${Y}Очищаю кеш DNS...${X}"
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Тестируем
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== Готово! ===${X}"
