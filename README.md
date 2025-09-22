# Ds_unlocker

Одна команда, чтобы поднять Discord без полного VPN (macOS).

## Быстрый старт

### Автозапуск (опционально)

```bash
$HOME/Desktop/Ds_unlocker/scripts/autostart_install.sh
```


```bash
curl -fsSL https://raw.githubusercontent.com/irwkc/Ds_unlocker/main/scripts/auto.sh | bash
```

Локально из клонированного репо:
```bash
sudo "$HOME/Desktop/Ds_unlocker/scripts/auto.sh"
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
