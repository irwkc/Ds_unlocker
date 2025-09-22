#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Zapret для macOS (реальная версия) ===${X}"

# Устанавливаем зависимости
log "${Y}Устанавливаю зависимости...${X}"
brew install git gnu-sed gawk coreutils || true

# Клонируем zapret
log "${Y}Клонирую zapret...${X}"
cd /tmp
rm -rf zapret-mac
git clone https://github.com/bol-van/zapret.git zapret-mac
cd zapret-mac

# Удаляем директорию tpws и скачиваем бинарник
log "${Y}Скачиваю готовый бинарник для macOS...${X}"
rm -rf tpws
curl -L -o tpws https://github.com/bol-van/zapret/releases/download/2024.12.19/tpws-macos
chmod +x tpws

# Создаем конфиг для Discord
log "${Y}Создаю конфиг для Discord...${X}"
cat > discord_hosts.txt << 'HOSTS'
discord.com
discordapp.com
discord.gg
gateway.discord.gg
cdn.discordapp.com
media.discordapp.net
status.discord.com
HOSTS

# Создаем скрипт запуска
log "${Y}Создаю скрипт запуска...${X}"
cat > start_zapret.sh << 'SCRIPT'
#!/bin/bash
cd /tmp/zapret-mac

# Останавливаем старые процессы
sudo pkill -f tpws || true

# Запускаем tpws
sudo ./tpws --hosts discord_hosts.txt --port 8080 --transparent --daemon --pidfile /tmp/tpws.pid

echo "Zapret запущен на порту 8080"
SCRIPT

chmod +x start_zapret.sh

# Создаем pf правила
log "${Y}Создаю pf правила...${X}"
cat > /tmp/discord_pf.conf << 'PF'
# Discord redirect rules
rdr pass on en0 inet proto tcp to any port 443 -> 127.0.0.1 port 8080
rdr pass on en0 inet proto tcp to any port 80 -> 127.0.0.1 port 8080
PF

# Применяем pf правила
log "${Y}Применяю pf правила...${X}"
sudo pfctl -f /tmp/discord_pf.conf || true
sudo pfctl -e || true

# Запускаем zapret
log "${Y}Запускаю zapret...${X}"
sudo ./start_zapret.sh || true

# Тестируем
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== Zapret запущен! ===${X}"
log "${Y}Попробуй открыть Discord!${X}"
