# Личные настройки Claude Code — переносимые

Правила, которые действуют во всех проектах. Подключаются из `~/.claude/CLAUDE.md` через
`@`-импорты. Здесь нет ничего специфичного для конкретной компании или проекта — это живёт в
`<repo>/CLAUDE.md` и `<repo>/.claude/`.

| Файл | О чём |
|---|---|
| `structure.md` | Карта файлов: что где лежит и что куда писать (в т.ч. проектные `gotchas.md`, тикеты, скиллы) |
| `communication.md` | Язык, переводы, объяснения через код и прецеденты, когда задавать вопросы |
| `skills/estimate/SKILL.md` | Скилл `/estimate`: три оценки — сеньор без знания проекта / реально ушло / чистый кодинг |
| `skills/ticket/SKILL.md` | Скилл `/ticket <KEY>`: общий порядок работы над тикетом; параметры — раздел «Задачи» в `CLAUDE.md` проекта |
| `templates/ticket.md` | Шаблон документа по задаче `<repo>/.claude/tickets/<KEY>.md` |
| `gotchas.md` | Общие грабли — не про конкретный проект (WSL, инструменты, библиотеки) |
| `workflow.md` | Дисциплина изменений, куда записывать договорённости, документ по задаче |
| `environment.md` | Java и Node — свои, из WSL (sdkman, nvm); как выбрать версию; CRLF и доступы |

## Перенос на новую машину

Всё это лежит в репозитории `claude-config` (`home/personal/`), в `~/.claude` — симлинки:

```bash
git clone git@github.com:konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config && ./install.sh
```

`install.sh` создаёт `~/.claude/CLAUDE.md`, `~/.claude/personal` и `~/.claude/skills/<имя>` для каждого
скилла из `skills/`. Подробности — `README.md` в корне репозитория.
