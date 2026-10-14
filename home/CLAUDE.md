<!-- claude-config: 2.0 -->
# Общие правила для всех проектов

Оглавление, как читать правила и подключение. Все файлы правил подключены `@`-импортами внизу и **грузятся
всегда** — ничего не надо «вспомнить открыть». Куда писать находки по ходу работы — `FILES`.

## RULES — как читать правила

Как **вести** правила (номера, размеры, новый файл, устаревшее, коммит, переезд) — скилл `/rules`.

- **RULES.CODE.1** Номер правила — **`ФАЙЛ.РАЗДЕЛ.N`** (`COMM.LANG.3`): коды файла и раздела — 3–5 латинских букв,
  `N` — число. Код файла — в дереве ниже.
- **RULES.CODE.3** В `tech/` разделы одинаковые во всех файлах: **`SETUP`** — установка, **`RULE`** — как писать,
  **`TRAP`** — грабли (симптом → причина → как правильно).
- **RULES.CODE.4** Найти правило по номеру — общее и проектное сразу:
  `grep -rn "WORK.DISC.5" ~/.claude/CLAUDE.md ~/.claude/personal <repo>/CLAUDE.md <repo>/.claude`.
- **RULES.PROJ.1** Приоритет: **моё слово в чате → правило проекта → общее правило.**
- **RULES.PROJ.2** У проекта **та же раскладка и те же номера**: `<repo>/.claude/work.md` ↔ `rules/work.md`,
  `<repo>/.claude/tech/java.md` ↔ `tech/java.md`. В проекте — только отличия и конкретика (адреса, команды, классы).
- **RULES.PROJ.3** Правило проекта с тем же номером **дополняет** общее; **заменяет** — только с пометкой
  **`(заменяет)`** после номера. Номера от 101 — свои правила проекта.
- **RULES.PROJ.6** Разделы только проекта — код **`PROJ`** в `<repo>/CLAUDE.md`: `PROJ.ABOUT` о проекте и соседях,
  `PROJ.CMD` команды, `PROJ.ARCH` архитектура, `PROJ.TEAM` люди, `PROJ.TOOLS` утилиты.
- **RULES.PROJ.7** **Метка версии** — первая строка `<repo>/CLAUDE.md`: `<!-- claude-config: 2.0 -->`. Командный
  `CLAUDE.md`, лежащий в git проекта, — не наш (`FILES.WHERE.7`): своё — в `.claude/`.
- **RULES.PROJ.8** **Связанные репозитории** (бэк + фронт, группа проектов одного клиента): общее — в файлах главного
  репозитория (`.claude/work.md`, `integ.md`, `review.md`, общий `PROJ.TEAM`), остальные подключают их
  `@../<главный>/.claude/…`; пометка «(только <репо>)» — остальных не касается; свои номера второго — после номеров
  главного.
- **RULES.VER.1** Правило/граблю с меткой версии (`[Spring Boot 3+]`, `[Angular ≤ 15]`, `[Spring 4.0–4.3]`) применять,
  только если версия в проекте подходит; версию проекта смотреть до первой правки (`SETUP`). Без метки — для всех
  версий.
- **RULES.EDIT.1** **Правила** (`CLAUDE.md`, `personal/rules/`, `RULE` и `SETUP` в `personal/tech/`, правила проекта)
  меняю **только после «меняй»**: сначала обсуждаем, я предлагаю текст и номер. **Сразу, без «меняй»** — документы
  задач, грабли (`TRAP`, общие и проектные), замечания ревью, калибровка оценок, память (`FILES.NOW.1`).
- **RULES.EDIT.5** **Правка файла правил** — общего или проектного (всё, кроме `tickets/`, `review.md`, калибровки и
  памяти), в том числе новая грабля, — **сначала скилл `/rules`**.
- **RULES.MIGR.1** Проект без метки `<!-- claude-config: … -->` или со старой версией — сказать одной строкой «проект
  на v1, перевести на v2 (`/rules`)?» и ждать «да».

## Дерево (размеры — для контроля)

```
~/.claude/                                         # симлинки в /mnt/c/code/claude-config/home
├── CLAUDE.md                             10.1 КБ  # ЭТОТ ФАЙЛ: RULES (как читать), дерево, @-импорты
├── personal/                                      # ПЕРЕНОСИМОЕ (RULES.PORT)
│   ├── rules/                                     # КАК РАБОТАЕМ — @, всегда
│   │   ├── comm.md       COMM            9.3 КБ   # язык и перевод, коротко, учёба, объяснения, вопросы, «пошло не так»
│   │   ├── work.md       WORK           10.5 КБ   # тикет, дисциплина, прогоны, проверка, ревью, оценка, сдача
│   │   ├── safe.md       SAFE            3.3 КБ   # секреты, чужое, разрушительные шаги, разрешения
│   │   ├── files.md      FILES           9.0 КБ   # что куда писать, документы задач, утилиты
│   │   └── integ.md      INTEG           5.9 КБ   # токены, VPN, трекер, wiki, git-сервер, логи, почта, чат
│   ├── tech/                                      # ТЕХНОЛОГИИ — @, всегда: SETUP / RULE / TRAP
│   │   ├── code.md       CODE            4.6 КБ   # общее для любого кода + журнал замечаний ревью
│   │   ├── java.md       JAVA            7.8 КБ   # sdkman; MapStruct; Jackson 3, Spring, JUnit, логи в тестах (бэк)
│   │   ├── gradle.md     GRADL           4.2 КБ   # gradlew в WSL, старый Gradle, отчёты, исходники, Lombok (бэк)
│   │   ├── api.md        API             1.1 КБ   # OpenAPI: map-ключи, тексты ошибок                  (бэк+фронт)
│   │   ├── node.md       NODE            5.0 КБ   # nvm; node_modules, npm и сертификаты, npx-форматтер      (фронт)
│   │   ├── ng.md         NG              3.7 КБ   # effect/untracked; ng-zorro, шаблоны, playwright         (фронт)
│   │   ├── git.md        GIT             2.2 КБ   # CRLF, HTTPS из WSL, коммит из cmd
│   │   ├── wsl.md        WSL             6.1 КБ   # окружение; localhost, Docker, симлинки, CRLF, форматтер
│   │   └── tls.md        TLS             2.2 КБ   # PKIX, неполная цепочка
│   ├── tools/                                     # УТИЛИТЫ (FILES.TOOLS) — не грузятся, запускаются
│   │   ├── jira.py                                # тикет текстом, --attach, --changelog
│   │   ├── wiki.py                                # страница → текст с пометками [+новое+] ~~убрано~~, вложения
│   │   ├── bb-pr.py                               # PR: статус, ревьюеры, сборка, комментарии
│   │   ├── test-count.sh                          # тесты в JUnit-отчётах и их свежесть
│   │   └── flyway-checksum.py                     # контрольная сумма миграции
│   ├── skills/<имя>/SKILL.md                      # ПРОЦЕДУРЫ по вызову: rules (ведение правил + переезд версий), ticket,
│   │                                              #   estimate, commit-message, review-lessons, timelog
│   ├── statusline/                                # скрипт строки состояния
│   └── templates/                                 # ticket.md — документ задачи; project/ — заготовка проекта
└── projects/<проект>/memory/                      # память ассистента (личный контекст)

<repo>/                                            # скрыто через .git/info/exclude
├── CLAUDE.md                                      # метка версии; PROJ.*; @-импорты .claude/*.md
└── .claude/
    ├── work.md  integ.md  …                       # отличия от общих правил — те же номера (RULES.PROJ)
    ├── tech/<тех>.md                              # проектные SETUP / RULE / TRAP
    ├── review.md                                  # замечания ревью (WORK.REVW)
    ├── <скилл>.md                                 # настройки скилла (timelog.md) — без @
    ├── tools/  skills/                            # утилиты и процедуры проекта
    └── tickets/                                   # <KEY>.md, <KEY>.in.*, <KEY>.out.* (FILES.DOCS)
```

Всего грузится (`CLAUDE.md` + `rules/` + `tech/`): **85.1 КБ** (+ `CLAUDE.md` и `.claude/` текущего проекта).

## Подключение

@~/.claude/personal/rules/comm.md

@~/.claude/personal/rules/work.md

@~/.claude/personal/rules/safe.md

@~/.claude/personal/rules/files.md

@~/.claude/personal/rules/integ.md

@~/.claude/personal/tech/code.md

@~/.claude/personal/tech/java.md

@~/.claude/personal/tech/gradle.md

@~/.claude/personal/tech/api.md

@~/.claude/personal/tech/node.md

@~/.claude/personal/tech/ng.md

@~/.claude/personal/tech/git.md

@~/.claude/personal/tech/wsl.md

@~/.claude/personal/tech/tls.md
