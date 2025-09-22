#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Оживление десктопной версии Discord ===${X}"

# Очищаем кеш Discord
log "${Y}Очищаю кеш Discord...${X}"
rm -rf ~/Library/Application\ Support/discord/Cache/* 2>/dev/null || true
rm -rf ~/Library/Application\ Support/discord/Code\ Cache/* 2>/dev/null || true
rm -rf ~/Library/Application\ Support/discord/GPUCache/* 2>/dev/null || true

# Создаем скрипт для изменения DNS через osascript
log "${Y}Создаю скрипт изменения DNS...${X}"
cat > /tmp/fix_dns.sh << 'DNS_SCRIPT'
#!/bin/bash
# Получаем активный интерфейс
ACTIVE_INTERFACE=$(route get default | grep interface | awk '{print $2}')
SERVICE_NAME=$(networksetup -listallhardwareports | grep -A1 "Hardware Port: $ACTIVE_INTERFACE" | grep "Device:" | awk '{print $2}')
if [[ -z "$SERVICE_NAME" ]]; then
    SERVICE_NAME="Wi-Fi"
fi

# Устанавливаем DNS Cloudflare
networksetup -setdnsservers "$SERVICE_NAME" 1.1.1.1 1.0.0.1

# Очищаем кеш DNS
dscacheutil -flushcache
killall -HUP mDNSResponder

# Устанавливаем альтернативные DNS
networksetup -setdnsservers "$SERVICE_NAME" 8.8.8.8 8.8.4.4
dscacheutil -flushcache
killall -HUP mDNSResponder

# Возвращаем Cloudflare DNS
networksetup -setdnsservers "$SERVICE_NAME" 1.1.1.1 1.0.0.1
dscacheutil -flushcache
killall -HUP mDNSResponder
DNS_SCRIPT

chmod +x /tmp/fix_dns.sh

# Запускаем через osascript
log "${Y}Запускаю исправление DNS...${X}"
osascript -e "do shell script \"/tmp/fix_dns.sh\" with administrator privileges"

# Запускаем Discord
log "${Y}Запускаю Discord...${X}"
open -a Discord || open /Applications/Discord.app || open /System/Applications/Discord.app

# Ждем и проверяем
sleep 5
log "${Y}Проверяю Discord...${X}"
ps aux | grep -i discord | grep -v grep || true

log "${G}=== Discord запущен ===${X}"
log "${Y}Попробуй войти в Discord!${X}"
