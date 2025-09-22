#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Автоматическая настройка DNS ===${X}"

# Получаем активный интерфейс
ACTIVE_INTERFACE=$(route get default | grep interface | awk '{print $2}')
log "${Y}Активный интерфейс: $ACTIVE_INTERFACE${X}"

# Получаем имя сервиса для этого интерфейса
SERVICE_NAME=$(networksetup -listallhardwareports | grep -A1 "Hardware Port: $ACTIVE_INTERFACE" | grep "Device:" | awk '{print $2}')
if [[ -z "$SERVICE_NAME" ]]; then
    SERVICE_NAME="Wi-Fi"
fi
log "${Y}Использую сервис: $SERVICE_NAME${X}"

# Устанавливаем DNS Cloudflare
log "${Y}Устанавливаю DNS Cloudflare...${X}"
sudo networksetup -setdnsservers "$SERVICE_NAME" 1.1.1.1 1.0.0.1

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

log "${G}=== DNS настроен автоматически ===${X}"
