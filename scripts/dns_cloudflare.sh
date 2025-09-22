#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка DNS Cloudflare ===${X}"

# Получаем активный интерфейс
INTERFACE=$(route get default | grep interface | awk '{print $2}')
log "${Y}Активный интерфейс: $INTERFACE${X}"

# Устанавливаем DNS Cloudflare
log "${Y}Устанавливаю DNS Cloudflare...${X}"
sudo networksetup -setdnsservers "$INTERFACE" 1.1.1.1 1.0.0.1 2606:4700:4700::1111 2606:4700:4700::1001

# Очищаем кеш DNS
log "${Y}Очищаю кеш DNS...${X}"
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

# Проверяем DNS
log "${Y}Проверяю DNS...${X}"
nslookup discord.com | cat || true

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== DNS Cloudflare настроен ===${X}"
log "${Y}Попробуй открыть Discord сейчас!${X}"
