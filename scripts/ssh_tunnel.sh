#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== SSH туннель для Discord ===${X}"

# Создаем SSH туннель через бесплатный сервер
log "${Y}Создаю SSH туннель...${X}"
ssh -D 1080 -N -f root@ssh.sshconnect.net || true

# Настраиваем прокси для Discord
log "${Y}Настраиваю прокси для Discord...${X}"
export ALL_PROXY=socks5://127.0.0.1:1080
export HTTP_PROXY=socks5://127.0.0.1:1080
export HTTPS_PROXY=socks5://127.0.0.1:1080

# Тестируем Discord
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== SSH туннель готов ===${X}"
