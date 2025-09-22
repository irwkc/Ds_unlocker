#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Диагностика Discord ===${X}"

# Проверяем DNS
log "${Y}1. Проверяю DNS...${X}"
nslookup discord.com | cat || true
nslookup gateway.discord.gg | cat || true

# Проверяем доступность
log "${Y}2. Проверяю доступность Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true
curl -I --max-time 10 https://gateway.discord.gg | cat || true

# Проверяем WARP
log "${Y}3. Проверяю WARP...${X}"
warp-cli status | cat || true

# Пробуем разные DNS
log "${Y}4. Пробую разные DNS...${X}"
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf > /dev/null
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

log "${Y}5. Тестирую с Google DNS...${X}"
curl -I --max-time 10 https://discord.com | cat || true

# Возвращаем Cloudflare DNS
log "${Y}6. Возвращаю Cloudflare DNS...${X}"
echo "nameserver 1.1.1.1" | sudo tee /etc/resolv.conf > /dev/null
echo "nameserver 1.0.0.1" | sudo tee -a /etc/resolv.conf > /dev/null
sudo dscacheutil -flushcache
sudo killall -HUP mDNSResponder

log "${G}=== Диагностика завершена ===${X}"
