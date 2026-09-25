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

```bash
cp -r personal ~/.claude/personal
cp CLAUDE.md ~/.claude/CLAUDE.md     # или дописать импорты в существующий
```

Скиллы подключить симлинком (Claude ищет их в `~/.claude/skills/`):

```bash
ln -s ../personal/skills/estimate ~/.claude/skills/estimate
ln -s ../personal/skills/ticket ~/.claude/skills/ticket
# или просто ./install.sh из claude-config
```

`~/.claude/CLAUDE.md` должен содержать:

```
@~/.claude/personal/structure.md
@~/.claude/personal/communication.md
@~/.claude/personal/workflow.md
@~/.claude/personal/gotchas.md
@~/.claude/personal/environment.md
```

Удобно держать папку в личном git-репозитории — тогда перенос = `git clone`.
