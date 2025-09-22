#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка DNS без sudo ===${X}"

# Создаем скрипт для изменения DNS
log "${Y}Создаю скрипт изменения DNS...${X}"
cat > /tmp/set_dns.sh << 'SCRIPT'
#!/bin/bash
# Получаем активный интерфейс
ACTIVE_INTERFACE=$(route get default | grep interface | awk '{print $2}')
SERVICE_NAME=$(networksetup -listallhardwareports | grep -A1 "Hardware Port: $ACTIVE_INTERFACE" | grep "Device:" | awk '{print $2}')
if [[ -z "$SERVICE_NAME" ]]; then
    SERVICE_NAME="Wi-Fi"
fi
networksetup -setdnsservers "$SERVICE_NAME" 1.1.1.1 1.0.0.1
dscacheutil -flushcache
killall -HUP mDNSResponder
SCRIPT

chmod +x /tmp/set_dns.sh

# Запускаем через osascript для получения прав
log "${Y}Запускаю настройку DNS...${X}"
osascript -e "do shell script \"/tmp/set_dns.sh\" with administrator privileges"

# Тестируем
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== Готово! ===${X}"
