#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Веб-версия Discord ===${X}"

# Открываем Discord в браузере с измененным User-Agent
log "${Y}Открываю Discord в браузере...${X}"
open "https://discord.com/app"

# Создаем скрипт для браузера
log "${Y}Создаю скрипт для браузера...${X}"
cat > /tmp/discord_ua.js << 'JS'
// Изменяем User-Agent для обхода блокировок
Object.defineProperty(navigator, 'userAgent', {
  get: function() { return 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'; }
});
JS

log "${G}=== Discord открыт в браузере ===${X}"
log "${Y}Попробуй использовать Discord в браузере!${X}"
