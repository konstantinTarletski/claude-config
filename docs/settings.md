[← README](../README.md)

# Настройки Claude Code (`~/.claude/settings.json`)

**Рядом с профилем**: `~/.claude/private/users/<имя>_<фирма>.settings.json` (вне репозитория — там пути и имена
токенов), `~/.claude/settings.json` — симлинк на него (`install.sh`). Нет своего — копия шаблона
`home/personal/templates/settings.json`, подставить пути и токены. В шаблоне:

- `Edit(...)` для заметок (`.claude/**`, `CLAUDE.md` проектов, `claude-config`, `~/.claude/personal`) — пишутся без
  запроса;
- `Bash(...)` для команд только на чтение (`git status/log/diff/show`, `ls`, `grep`, `head`, `tail`, `sed -n`,
  Windows-git `status/diff/log/fetch`, `curl` к Jira с токеном);
- `ask` для `.claude/settings*.json` проектов — чтобы ассистент не мог сам себе расширить разрешения;
- строка состояния и тема `dark` (тёмный фон терминала; `light` даёт тёмно-синий, которого на тёмном не видно).

`/config` пишет через симлинк, ссылка остаётся (проверено 21.10.2026, Claude Code на WSL). Если когда-нибудь
перепишет её обычным файлом — `./install.sh` это заметит и скажет.
