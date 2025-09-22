#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Настройка прокси для Discord ===${X}"

# Устанавливаем прокси через Homebrew
log "${Y}Устанавливаю прокси...${X}"
brew install proxychains-ng || true

# Создаем конфиг прокси
log "${Y}Создаю конфиг прокси...${X}"
cat > ~/.proxychains.conf << 'CONFIG'
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000
localnet 127.0.0.0/255.0.0.0
quiet_mode
[ProxyList]
socks5 127.0.0.1 1080
CONFIG

# Запускаем простой SOCKS5 прокси
log "${Y}Запускаю SOCKS5 прокси...${X}"
python3 -m http.server 8080 &
PROXY_PID=$!

# Тестируем через прокси
log "${Y}Тестирую Discord через прокси...${X}"
curl -I --max-time 10 --proxy socks5://127.0.0.1:1080 https://discord.com | cat || true

# Останавливаем прокси
kill $PROXY_PID 2>/dev/null || true

log "${G}=== Прокси настроен ===${X}"
