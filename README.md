# Ds_unlocker

Одна команда, чтобы поднять Discord без полного VPN (macOS).

## Быстрый старт

**Самый простой способ:**
```bash
curl -fsSL https://raw.githubusercontent.com/irwkc/Ds_unlocker/main/scripts/quick.sh | bash
```

**Альтернатива (если первая не работает):**
```bash
git clone https://github.com/irwkc/Ds_unlocker.git && cd Ds_unlocker && sudo bash scripts/auto.sh
```

### Автозапуск (опционально)
```bash
$HOME/Desktop/Ds_unlocker/scripts/autostart_install.sh
```

## Ручные команды (если нужно)
```bash
sudo "$HOME/Desktop/Ds_unlocker/scripts/install.sh"   # установка зависимостей и WARP
"$HOME/Desktop/Ds_unlocker/scripts/ctl.sh" status      # статус
"$HOME/Desktop/Ds_unlocker/scripts/ctl.sh" connect     # подключить
"$HOME/Desktop/Ds_unlocker/scripts/ctl.sh" probe       # диагностика
"$HOME/Desktop/Ds_unlocker/scripts/ctl.sh" disconnect  # отключить
```

Домены в `scripts/domains.txt`.
