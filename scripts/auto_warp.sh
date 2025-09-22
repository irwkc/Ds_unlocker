#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

# Полностью автоматическая настройка WARP
log "${Y}=== Автоматическая настройка WARP ===${X}"

# 1. Останавливаем все процессы WARP
log "${Y}1/7 Останавливаю все процессы WARP...${X}"
sudo pkill -f warp || true
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.warp* 2>/dev/null || true
sudo launchctl unload /Library/LaunchAgents/com.cloudflare.warp* 2>/dev/null || true

# 2. Удаляем старые конфиги
log "${Y}2/7 Очищаю старые конфигурации...${X}"
sudo rm -rf /Library/Application\ Support/CloudflareWARP 2>/dev/null || true
sudo rm -rf ~/Library/Application\ Support/CloudflareWARP 2>/dev/null || true
sudo rm -rf /var/root/Library/Application\ Support/CloudflareWARP 2>/dev/null || true

# 3. Запускаем daemon
log "${Y}3/7 Запускаю WARP daemon...${X}"
sudo launchctl load /Library/LaunchDaemons/com.cloudflare.warp* 2>/dev/null || true
sleep 3

# 4. Удаляем старую регистрацию
log "${Y}4/7 Удаляю старую регистрацию...${X}"
warp-cli registration delete 2>/dev/null || true
sleep 2

# 5. Создаем новую регистрацию
log "${Y}5/7 Создаю новую регистрацию...${X}"
for i in {1..5}; do
  if warp-cli registration new 2>/dev/null; then
    log "${G}Регистрация успешна!${X}"
    break
  else
    log "${Y}Попытка $i/5... жду 3 сек${X}"
    sleep 3
  fi
done

# 6. Устанавливаем режим
log "${Y}6/7 Устанавливаю режим WARP...${X}"
sudo warp-cli mode warp || true

# 7. Подключаемся
log "${Y}7/7 Подключаюсь к WARP...${X}"
sudo warp-cli connect || true

# Проверяем результат
log "${Y}Проверяю статус...${X}"
warp-cli status || true

log "${G}=== Готово! WARP настроен автоматически ===${X}"
