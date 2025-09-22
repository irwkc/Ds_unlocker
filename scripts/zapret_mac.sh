#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Установка zapret для macOS ===${X}"

# Устанавливаем зависимости
log "${Y}Устанавливаю зависимости...${X}"
brew install git gnu-sed gawk coreutils || true

# Клонируем zapret
log "${Y}Клонирую zapret...${X}"
cd /tmp
git clone https://github.com/bol-van/zapret.git zapret-mac || true
cd zapret-mac

# Собираем tpws
log "${Y}Собираю tpws...${X}"
make tpws || true

# Создаем конфиг для Discord
log "${Y}Создаю конфиг для Discord...${X}"
cat > discord.conf << 'CONFIG'
# Discord domains
discord.com
discordapp.com
discord.gg
gateway.discord.gg
cdn.discordapp.com
media.discordapp.net
status.discord.com
CONFIG

# Создаем скрипт запуска
log "${Y}Создаю скрипт запуска...${X}"
cat > start_discord.sh << 'SCRIPT'
#!/bin/bash
cd /tmp/zapret-mac
sudo ./tpws --hosts discord.conf --port 8080 --transparent --daemon
SCRIPT

chmod +x start_discord.sh

# Запускаем
log "${Y}Запускаю zapret...${X}"
sudo ./start_discord.sh || true

# Настраиваем pf правила
log "${Y}Настраиваю pf правила...${X}"
cat > /tmp/discord.pf << 'PF'
# Discord redirect rules
rdr pass on en0 inet proto tcp to any port 443 -> 127.0.0.1 port 8080
rdr pass on en0 inet proto tcp to any port 80 -> 127.0.0.1 port 8080
PF

sudo pfctl -f /tmp/discord.pf || true
sudo pfctl -e || true

log "${G}=== Zapret настроен для Discord ===${X}"
log "${Y}Попробуй открыть Discord!${X}"
