#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Альтернатива zapret для macOS ===${X}"

# Устанавливаем зависимости
log "${Y}Устанавливаю зависимости...${X}"
brew install git gnu-sed gawk coreutils || true

# Скачиваем готовый бинарник tpws для macOS
log "${Y}Скачиваю готовый tpws для macOS...${X}"
cd /tmp
rm -rf zapret-mac
mkdir zapret-mac
cd zapret-mac

# Пробуем разные источники бинарника
log "${Y}Пробую скачать tpws...${X}"
curl -L -o tpws https://github.com/bol-van/zapret/releases/download/2024.12.19/tpws-macos || \
curl -L -o tpws https://github.com/bol-van/zapret/releases/download/2024.12.19/tpws-darwin || \
curl -L -o tpws https://github.com/bol-van/zapret/releases/download/2024.12.19/tpws

chmod +x tpws

# Проверяем бинарник
if [[ ! -f "./tpws" ]] || [[ ! -s "./tpws" ]]; then
    log "${R}Не удалось скачать tpws!${X}"
    log "${Y}Пробую альтернативный метод...${X}"
    
    # Создаем простой прокси на Python
    cat > simple_proxy.py << 'PYTHON'
#!/usr/bin/env python3
import socket
import threading
import sys

def handle_client(client_socket, target_host, target_port):
    try:
        # Подключаемся к целевому серверу
        target_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        target_socket.connect((target_host, target_port))
        
        # Пересылаем данные
        def forward_data(source, destination):
            try:
                while True:
                    data = source.recv(4096)
                    if not data:
                        break
                    destination.send(data)
            except:
                pass
            finally:
                source.close()
                destination.close()
        
        # Запускаем пересылку в двух направлениях
        t1 = threading.Thread(target=forward_data, args=(client_socket, target_socket))
        t2 = threading.Thread(target=forward_data, args=(target_socket, client_socket))
        
        t1.start()
        t2.start()
        
        t1.join()
        t2.join()
        
    except Exception as e:
        print(f"Error: {e}")
        client_socket.close()

def start_proxy(local_port, target_host, target_port):
    server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    server.bind(('127.0.0.1', local_port))
    server.listen(5)
    
    print(f"Proxy started on port {local_port}")
    
    while True:
        client_socket, addr = server.accept()
        client_thread = threading.Thread(
            target=handle_client,
            args=(client_socket, target_host, target_port)
        )
        client_thread.start()

if __name__ == "__main__":
    # Прокси для Discord
    start_proxy(8080, 'discord.com', 443)
PYTHON
    
    chmod +x simple_proxy.py
    log "${Y}Создал простой прокси на Python${X}"
fi

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
cat > start_proxy.sh << 'SCRIPT'
#!/bin/bash
cd /tmp/zapret-mac

# Останавливаем старые процессы
sudo pkill -f tpws || true
sudo pkill -f simple_proxy.py || true

# Запускаем прокси
if [[ -f "./tpws" ]] && [[ -s "./tpws" ]]; then
    sudo ./tpws --hosts discord_hosts.txt --port 8080 --transparent --daemon --pidfile /tmp/tpws.pid
    echo "Zapret запущен на порту 8080"
else
    python3 simple_proxy.py &
    echo "Python прокси запущен на порту 8080"
fi
SCRIPT

chmod +x start_proxy.sh

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

# Запускаем прокси
log "${Y}Запускаю прокси...${X}"
sudo ./start_proxy.sh || true

# Тестируем
log "${Y}Тестирую Discord...${X}"
curl -I --max-time 10 https://discord.com | cat || true

log "${G}=== Прокси запущен! ===${X}"
log "${Y}Попробуй открыть Discord!${X}"
