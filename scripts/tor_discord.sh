#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Tor для Discord ===${X}"

# Устанавливаем Tor
log "${Y}Устанавливаю Tor...${X}"
brew install tor || true

# Запускаем Tor
log "${Y}Запускаю Tor...${X}"
tor --SOCKSPort 9050 &
TOR_PID=$!

# Ждем запуска
sleep 5

# Настраиваем прокси
log "${Y}Настраиваю прокси...${X}"
export ALL_PROXY=socks5://127.0.0.1:9050
export HTTP_PROXY=socks5://127.0.0.1:9050
export HTTPS_PROXY=socks5://127.0.0.1:9050

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

# Останавливаем Tor
kill $TOR_PID 2>/dev/null || true

log "${G}=== Tor готов ===${X}"
