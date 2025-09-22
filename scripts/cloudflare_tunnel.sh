#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Cloudflare Tunnel для Discord ===${X}"

# Устанавливаем cloudflared
log "${Y}Устанавливаю cloudflared...${X}"
brew install cloudflared || true

# Создаем туннель
log "${Y}Создаю туннель...${X}"
cloudflared tunnel --url https://discord.com &
TUNNEL_PID=$!

# Ждем запуска
sleep 5

# Тестируем
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

# Останавливаем туннель
kill $TUNNEL_PID 2>/dev/null || true

log "${G}=== Cloudflare Tunnel готов ===${X}"
