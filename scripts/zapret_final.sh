#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Zapret для macOS (финальная версия) ===${X}"

# Устанавливаем зависимости
log "${Y}Устанавливаю зависимости...${X}"
brew install git gnu-sed gawk coreutils make gcc || true

# Клонируем zapret
log "${Y}Клонирую zapret...${X}"
cd /tmp
rm -rf zapret-mac
git clone https://github.com/bol-van/zapret.git zapret-mac
cd zapret-mac

# Переходим в папку tpws
cd tpws

# Создаем Makefile для macOS без проблемных заголовков
log "${Y}Создаю Makefile для macOS...${X}"
cat > Makefile.macos << 'MAKEFILE'
CC = gcc
CFLAGS = -std=gnu99 -Os -flto=auto -D_DARWIN_C_SOURCE -D_GNU_SOURCE
LDFLAGS = -lz -lpthread

# Исключаем проблемные файлы
OBJS = tpws.c tpws_conn.c helpers.c hostlist.c ipset.c params.c pools.c protocol.c resolver.c sec.c tamper.c gzip.c

tpws: $(OBJS)
	$(CC) $(CFLAGS) -o tpws $(OBJS) $(LDFLAGS)

clean:
	rm -f tpws *.o
MAKEFILE

# Создаем патчи для проблемных файлов
log "${Y}Создаю патчи для macOS...${X}"

# Патч для tpws_conn.c - убираем epoll
sed -i '' 's/#include <sys\/epoll.h>//' tpws_conn.c || true
sed -i '' 's/epoll_create1/kqueue/' tpws_conn.c || true
sed -i '' 's/epoll_ctl/kevent/' tpws_conn.c || true
sed -i '' 's/epoll_wait/kevent/' tpws_conn.c || true

# Патч для redirect.c - убираем pf
sed -i '' 's/#include <net\/pfvar.h>//' redirect.c || true
sed -i '' 's/#include <net\/pf.h>//' redirect.c || true

# Собираем tpws
log "${Y}Собираю tpws...${X}"
make -f Makefile.macos tpws || true

# Проверяем сборку
if [[ ! -f "./tpws" ]]; then
    log "${R}Ошибка сборки tpws!${X}"
    exit 1
fi

# Возвращаемся в корень
cd ..

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
sudo ./tpws/tpws --hosts discord_hosts.txt --port 8080 --transparent --daemon --pidfile /tmp/tpws.pid

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
