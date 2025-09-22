#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== HTTP прокси для Discord ===${X}"

# Устанавливаем прокси
log "${Y}Устанавливаю прокси...${X}"
brew install privoxy || true

# Создаем конфиг прокси
log "${Y}Создаю конфиг прокси...${X}"
cat > /tmp/privoxy.conf << 'CONFIG'
listen-address 127.0.0.1:8118
forward-socks5 / 127.0.0.1:9050 .
CONFIG

# Запускаем прокси
log "${Y}Запускаю прокси...${X}"
privoxy /tmp/privoxy.conf &
PROXY_PID=$!

# Ждем запуска
sleep 3

# Настраиваем прокси
log "${Y}Настраиваю прокси...${X}"
export HTTP_PROXY=http://127.0.0.1:8118
export HTTPS_PROXY=http://127.0.0.1:8118

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

# Останавливаем прокси
kill $PROXY_PID 2>/dev/null || true

log "${G}=== HTTP прокси готов ===${X}"
