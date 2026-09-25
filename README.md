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
    └── skills/                → ~/.claude/skills/<имя>
        ├── estimate/          /estimate <KEY>
        └── ticket/            /ticket <KEY>
```

**Проектного здесь нет.** `CLAUDE.md` проекта (с разделом «Задачи» — параметры для `/ticket`),
`.claude/gotchas.md`, документы по задачам `.claude/tickets/<KEY>.md`, `.sdkmanrc` / `.nvmrc` —
лежат обычными файлами в самом проекте и скрыты от git через `<repo>/.git/info/exclude`.

Секретов здесь тоже нет: токены — в `~/.bashrc`, доступы к Artifactory — в `~/.gradle/gradle.properties`.

## Развернуть на новой машине

```bash
git clone https://github.com/konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config
./install.sh --dry-run   # показать, что будет сделано
./install.sh
```

Повторный запуск безопасен. Существующий файл, совпадающий с копией, заменяется симлинком;
отличающийся — сохраняется как `<файл>.bak-<дата>`.

## Ограничения

- Симлинки — WSL-шные: из WSL читаются, Windows-программы их не видят. Настоящие Windows-симлинки
  (`mklink`) требуют прав администратора или Developer Mode. Claude Code запускается из WSL.
- Репозиторий хранится с LF (`.gitattributes`), одинаково для WSL- и Windows-git.
