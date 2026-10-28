[← README](../README.md)

# Строка состояния (claude-pace)

[claude-pace](https://github.com/Astro-Han/claude-pace) (MIT) — однофайловый bash-скрипт: модель и контекст, ветка
и дифф, расход квоты за 5 часов и 7 дней и «темп» (успеваю ли в лимит). Сети не использует, пишет только кеш
в `~/.cache/claude-pace`. Копия скрипта — `home/personal/statusline/claude-pace.sh` (release от 30.09.2026,
sha256 `0dd4fecb…a020b`), доступна как `~/.claude/personal/statusline/claude-pace.sh` через симлинк `personal`.

На новой машине:

```bash
sudo apt-get install -y jq      # единственная зависимость; без неё в строке «[needs jq]»
```

Подключение (`statusLine`) — уже в шаблоне `templates/settings.json`.

Обновить скрипт: скачать `https://github.com/Astro-Han/claude-pace/releases/latest/download/claude-pace.sh` во
временную папку, просмотреть дифф с текущей копией (нет ли сети, `eval`, записи вне кеша) и только потом заменить.
