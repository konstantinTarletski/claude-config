[← README](../README.md)

# Дерево файлов

Размеры — для контроля (`RULES.SIZE`): обновляются при каждой правке файла.

```
~/.claude/                                         # симлинки, все — через claude-config (путь в одном месте)
├── claude-config                                  # ссылка на этот репозиторий — ЕДИНСТВЕННОЕ место с путём к нему
├── CLAUDE.md                              6.9 КБ  # RULES (как читать), коды файлов и утилиты, @-импорты
├── user.md       USER                             # симлинк на активный профиль (RULES.USER.1)
├── private/                                       # ЛИЧНОЕ — вне репозитория (папка или ссылка, install.sh --private)
│   ├── users/                                     # ПРОФИЛИ; @ только активный (через user.md)
│   │   ├── <имя>_<фирма>.md            ~13.0 КБ   # я и окружение: ABOUT PREF WORK PERM SYS DEV ACC FOLD EVENT OFF
│   │   └── <имя>_<фирма>.settings.json            # настройки Claude Code — симлинк ~/.claude/settings.json
│   └── firms/                                     # ФИРМЫ; @ из профиля (RULES.USER.2)
│       └── <фирма>.md          FIRM     ~6.8 КБ   # своя фирма и клиенты: проекты, репозитории, системы
├── personal/                                      # ПЕРЕНОСИМОЕ (RULES.PORT)
│   ├── rules/                                     # КАК РАБОТАЕМ — @, всегда
│   │   ├── comm.md       COMM            5.6 КБ   # перевод, форма ответа, учёба, объяснения, вопросы, «пошло не так»
│   │   ├── work.md       WORK            4.7 КБ   # что всегда: ветка, коммит, фоновые прогоны, сборка, ревью
│   │   ├── safe.md       SAFE            1.7 КБ   # секреты, папки пользователя, удаление, правка файлов
│   │   ├── files.md      FILES           6.6 КБ   # что куда писать, какие грабли записывать, документы задач, утилиты
│   │   └── integ.md      INTEG           3.0 КБ   # токены, VPN, что не видно в тикете и в wiki
│   ├── tech/                                      # ТЕХНОЛОГИИ — @, всегда: SETUP / RULE / TRAP
│   │   ├── code.md       CODE            4.0 КБ   # общее для любого кода + журнал замечаний ревью
│   │   ├── java.md       JAVA            4.0 КБ   # sdkman; MapStruct; Jackson 3, логи в тестах (бэк)
│   │   ├── gradle.md     GRADL           1.9 КБ   # gradlew в WSL, отчёты, Lombok, Windows-демон (бэк)
│   │   ├── api.md        API             0.6 КБ   # OpenAPI: map-ключи, тексты ошибок                  (бэк+фронт)
│   │   ├── node.md       NODE            1.2 КБ   # nvm; node_modules из Windows                     (фронт)
│   │   ├── ng.md         NG              0.6 КБ   # effect/untracked                                       (фронт)
│   │   ├── git.md        GIT             1.7 КБ   # CRLF, HTTPS из WSL, коммит из cmd, ignored-файл при смене ветки
│   │   ├── wsl.md        WSL             1.9 КБ   # окружение; localhost, симлинки, форматтер
│   │   ├── tls.md        TLS             0.6 КБ   # PKIX в чужом сервисе
│   │   └── sql.md        SQL             1.9 КБ   # Flyway: удалённый R__, правка V; PG: пояс JVM (бэк)
│   ├── tools/                                     # УТИЛИТЫ (FILES.TOOLS) — не грузятся, запускаются
│   │   ├── jira.py                                # тикет текстом, --attach, --changelog
│   │   ├── jira-worklog.py                        # журнал часов → worklog Jira один в один, сверка (/timelog-askend)
│   │   ├── wiki.py                                # страница → текст с пометками [+новое+] ~~убрано~~, вложения
│   │   ├── bb-pr.py                               # PR: статус, ревьюеры, сборка, комментарии
│   │   ├── test-count.sh                          # тесты в JUnit-отчётах и их свежесть
│   │   ├── with-token.sh                          # команда с токеном из ~/.bashrc (значение не печатается)
│   │   ├── session-time.py                        # часы по сессии: разбор / реализация (для /estimate)
│   │   └── flyway-checksum.py                     # контрольная сумма миграции
│   ├── skills/<имя>/SKILL.md                      # ПРОЦЕДУРЫ по вызову: rules (ведение правил + переезд версий:
│   │                                              #   v1-to-v2.md … v2.2-to-v3.0.md), ticket (по шагам), estimate,
│   │                                              #   commit-message, review-lessons, timelog-askend
│   ├── statusline/                                # скрипт строки состояния
│   └── templates/                                 # user.md — профиль; firm.md — фирма; settings.json — настройки
│                                                  #   Claude Code (разрешения, тема); ticket.md — документ задачи;
│                                                  #   timelog-askend.md — часы проекта; project/ — заготовка
└── projects/<проект>/memory/                      # память ассистента (контекст разговоров, не факты — они в USER)

<repo>/                                            # скрыто через .git/info/exclude
├── CLAUDE.md                                      # метка версии; PROJ.*; @-импорты .claude/*.md (или главного группы)
└── .claude/
    ├── work.md  integ.md  …                       # отличия от общих правил — те же номера (RULES.PROJ)
    ├── tech/<тех>.md                              # проектные SETUP / RULE / TRAP
    ├── review.md                                  # замечания ревью (WORK.REVW)
    ├── <скилл>.md                                 # настройки скилла (timelog-askend.md) — без @
    ├── tools/  skills/                            # утилиты и процедуры проекта
    └── tickets/                                   # <KEY>.md, <KEY>.in.*, <KEY>.out.* (FILES.DOCS)
```

Всего грузится (`CLAUDE.md` + `user.md` + файл фирмы + `rules/` + `tech/`): **67.7 КБ** (+ `CLAUDE.md` и `.claude/` текущего проекта).

**Проектного здесь нет.** `CLAUDE.md` проекта (метка версии, `PROJ.*`), `.claude/work.md`, `.claude/integ.md`,
`.claude/tech/*.md`, документы по задачам `.claude/tickets/`, `.sdkmanrc` / `.nvmrc` — лежат обычными файлами в самом
проекте и скрыты от git через `<repo>/.git/info/exclude`. Проект на старой версии — ассистент предложит переезд
(`RULES.MIGR`).
