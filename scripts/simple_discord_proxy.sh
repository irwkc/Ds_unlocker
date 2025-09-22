#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Простой прокси для Discord ===${X}"

# Устанавливаем зависимости
log "${Y}Устанавливаю зависимости...${X}"
brew install privoxy || true

# Создаем конфиг прокси
log "${Y}Создаю конфиг прокси...${X}"
cat > /tmp/privoxy.conf << 'CONFIG'
listen-address 127.0.0.1:8118
forward-socks5 / 127.0.0.1:9050 .
HOSTS
discord.com
discordapp.com
discord.gg
gateway.discord.gg
cdn.discordapp.com
media.discordapp.net
status.discord.com
HOSTS
CONFIG

# Запускаем Tor
log "${Y}Запускаю Tor...${X}"
brew services start tor || true
sleep 5

# Запускаем прокси
log "${Y}Запускаю прокси...${X}"
privoxy /tmp/privoxy.conf &
PROXY_PID=$!

# Ждем запуска
sleep 3

# Настраиваем прокси для системы
log "${Y}Настраиваю прокси для системы...${X}"
sudo networksetup -setwebproxy "Wi-Fi" 127.0.0.1 8118 || true
sudo networksetup -setsecurewebproxy "Wi-Fi" 127.0.0.1 8118 || true

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

# Запускаем Discord
log "${Y}Запускаю Discord...${X}"
open -a Discord || open /Applications/Discord.app || open /System/Applications/Discord.app

log "${G}=== Прокси запущен! ===${X}"
log "${Y}Discord должен работать через прокси!${X}"
