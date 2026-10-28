[← README](../README.md)

# Установка и обновление

## Новая машина

```bash
git clone git@github.com:konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config
./install.sh --dry-run   # показать, что будет сделано
./install.sh                              # профилей несколько — спросит, с каким работаем
./install.sh --profile <имя>_<фирма>      # или выбрать/сменить профиль сразу
./install.sh --private /mnt/c/Users/<user>/.claude/private   # WSL: личное — в папке Windows
./install.sh --migrate                    # переход с 2.x: скопировать профили и фирмы из репозитория в private
```

Репозиторий можно положить куда угодно: путь к нему знает только ссылка `~/.claude/claude-config` (остальные ссылки —
через неё). Переложил — `./install.sh` из нового места.

Свой профиль, настройки (`<имя>_<фирма>.settings.json`) и файл фирмы — перенести со старой машины (они вне репозитория) или создать по шаблонам:
`home/personal/templates/user.md` → `~/.claude/private/users/<имя>_<фирма>.md`, `templates/firm.md` →
`~/.claude/private/firms/<фирма>.md` (версии — проверить командами, `RULES.USER.1`), потом `./install.sh`. Повторный запуск безопасен. Существующий файл, совпадающий с копией, заменяется симлинком;
отличающийся — сохраняется как `<файл>.bak-<дата>`.


## После `git pull` новой версии

Обязательно `./install.sh` (новые скиллы, ссылки). Переход со старой версии —
`home/personal/skills/rules/v*-to-v*.md`, по очереди; свои проекты ассистент предложит перевести сам (`RULES.MIGR.1`).

Секретов здесь тоже нет: токены — в `~/.bashrc`, доступы к Artifactory — в `~/.gradle/gradle.properties`.


## Ограничения

- Симлинки — WSL-шные: из WSL читаются, Windows-программы их не видят. Настоящие Windows-симлинки
  (`mklink`) требуют прав администратора или Developer Mode. Claude Code запускается из WSL.
- Репозиторий хранится с LF (`.gitattributes`), одинаково для WSL- и Windows-git.
