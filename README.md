# claude-config — мои личные настройки Claude Code

Здесь **по-настоящему** лежат мои общие правила и скиллы — то, что не зависит от проекта и
переезжает со мной. В `~/.claude` — только симлинки сюда (их создаёт `install.sh`). Правишь файл по
любому из путей — меняется файл здесь; коммитишь отсюда.

## Что где

```
home/
├── CLAUDE.md                  → ~/.claude/CLAUDE.md   (@-импорты personal/*.md)
└── personal/                  → ~/.claude/personal
    ├── structure.md           что где лежит и что куда писать
    ├── communication.md       язык, объяснения через код, вопросы
    ├── workflow.md            дисциплина изменений, документ по задаче
    ├── environment.md         Java/Node — свои из WSL (sdkman, nvm)
    ├── gotchas.md             общие грабли (WSL, CRLF, инструменты)
    ├── templates/ticket.md    шаблон документа по задаче
    ├── statusline/claude-pace.sh  строка состояния: квота 5ч/7д и темп (см. ниже)
    └── skills/                → ~/.claude/skills/<имя>
        ├── commit-message/    /commit-message [длинный] [<KEY>]
        ├── estimate/          /estimate <KEY>
        ├── review-lessons/    /review-lessons — чек-лист из замечаний ревью
        └── ticket/            /ticket <KEY>
```

**Проектного здесь нет.** `CLAUDE.md` проекта (с разделом «Задачи» — параметры для `/ticket`),
`.claude/gotchas.md`, документы по задачам `.claude/tickets/<KEY>.md`, `.sdkmanrc` / `.nvmrc` —
лежат обычными файлами в самом проекте и скрыты от git через `<repo>/.git/info/exclude`.

Секретов здесь тоже нет: токены — в `~/.bashrc`, доступы к Artifactory — в `~/.gradle/gradle.properties`.

## Развернуть на новой машине

```bash
git clone git@github.com:konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config
./install.sh --dry-run   # показать, что будет сделано
./install.sh
```

Повторный запуск безопасен. Существующий файл, совпадающий с копией, заменяется симлинком;
отличающийся — сохраняется как `<файл>.bak-<дата>`.

## Разрешения (`~/.claude/settings.json`)

Сам файл сюда не симлинкается — Claude Code переписывает его при `/model`, `/config` и т.п. Блок
`permissions` лежит копией в `home/settings.permissions.json` — на новой машине вставить его в
`~/.claude/settings.json`. Что в нём:

- `Edit(...)` для заметок (`.claude/**`, `CLAUDE.md` проектов, `claude-config`, `~/.claude/personal`) — пишутся без
  запроса;
- `Bash(...)` для команд только на чтение (`git status/log/diff/show`, `ls`, `grep`, `head`, `tail`, `sed -n`,
  Windows-git `status/diff/log/fetch`, `curl` к Jira с токеном);
- `ask` для `.claude/settings*.json` проектов — чтобы ассистент не мог сам себе расширить разрешения.

Поменял разрешения в `~/.claude/settings.json` — обновить копию:
`python3 -c "import json; d=json.load(open('$HOME/.claude/settings.json')); json.dump({'permissions': d['permissions']}, open('home/settings.permissions.json','w'), indent=2, ensure_ascii=False)"`.

## Строка состояния (claude-pace)

[claude-pace](https://github.com/Astro-Han/claude-pace) (MIT) — однофайловый bash-скрипт: модель и контекст, ветка
и дифф, расход квоты за 5 часов и 7 дней и «темп» (успеваю ли в лимит). Сети не использует, пишет только кеш
в `~/.cache/claude-pace`. Копия скрипта — `home/personal/statusline/claude-pace.sh` (release от 30.09.2026,
sha256 `0dd4fecb…a020b`), доступна как `~/.claude/personal/statusline/claude-pace.sh` через симлинк `personal`.

На новой машине:

```bash
sudo apt-get install -y jq      # единственная зависимость; без неё в строке «[needs jq]»
```

и в `~/.claude/settings.json` (сам файл не симлинкается — см. выше):

```json
"statusLine": { "type": "command", "command": "~/.claude/personal/statusline/claude-pace.sh" }
```

Обновить скрипт: скачать `https://github.com/Astro-Han/claude-pace/releases/latest/download/claude-pace.sh` во
временную папку, просмотреть дифф с текущей копией (нет ли сети, `eval`, записи вне кеша) и только потом заменить.

## Ограничения

- Симлинки — WSL-шные: из WSL читаются, Windows-программы их не видят. Настоящие Windows-симлинки
  (`mklink`) требуют прав администратора или Developer Mode. Claude Code запускается из WSL.
- Репозиторий хранится с LF (`.gitattributes`), одинаково для WSL- и Windows-git.
