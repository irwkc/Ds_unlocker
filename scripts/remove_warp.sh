#!/usr/bin/env bash
set -euo pipefail

Y="\033[33m"; G="\033[32m"; R="\033[31m"; X="\033[0m"
log(){ printf "%b\n" "$1"; }

log "${Y}=== Удаление WARP ===${X}"

# Останавливаем WARP
log "${Y}Останавливаю WARP...${X}"
warp-cli disconnect || true
sudo launchctl unload /Library/LaunchDaemons/com.cloudflare.warp* 2>/dev/null || true

# Удаляем WARP через Homebrew
log "${Y}Удаляю WARP через Homebrew...${X}"
brew uninstall cloudflare-warp || true

# Удаляем конфиги
log "${Y}Удаляю конфиги WARP...${X}"
sudo rm -rf /Library/Application\ Support/CloudflareWARP 2>/dev/null || true
sudo rm -rf ~/Library/Application\ Support/CloudflareWARP 2>/dev/null || true
sudo rm -rf /var/root/Library/Application\ Support/CloudflareWARP 2>/dev/null || true

# Удаляем launchd сервисы
log "${Y}Удаляю launchd сервисы...${X}"
sudo rm -f /Library/LaunchDaemons/com.cloudflare.warp* 2>/dev/null || true
sudo rm -f /Library/LaunchAgents/com.cloudflare.warp* 2>/dev/null || true

log "${G}=== WARP полностью удален ===${X}"
