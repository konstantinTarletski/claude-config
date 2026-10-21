# claude-config — общие настройки Claude Code (v2.2)

Здесь **по-настоящему** лежат мои общие правила и скиллы — то, что не зависит от проекта и
переезжает со мной. В `~/.claude` — только симлинки сюда (их создаёт `install.sh`). Правишь файл по
любому из путей — меняется файл здесь; коммитишь отсюда.

## Что где

Как читать правила (`RULES`: номера `ФАЙЛ.РАЗДЕЛ.N`, профиль, проект, версии) — [`home/CLAUDE.md`](home/CLAUDE.md);
как их вести и переводить проекты на новую версию — скилл `home/personal/skills/rules/`. Дерево — ниже. Версии — теги
`v1.0`, `v2.0`…, что поменялось — [`CHANGELOG.md`](CHANGELOG.md).

**Профиль** (с 2.1) — всё «про меня»: кто я, как общаться и работать, разрешения, система и инструменты, доступы
машины, папки, мои события. Файл `home/personal/users/<имя>_<фирма>.md` — свой на каждое окружение, по шаблону
`home/personal/templates/user.md`; активный — симлинк `~/.claude/user.md`, его создаёт `install.sh`. Правила ссылаются
на профиль по номеру (`USER.PREF.1`), сами фактов о человеке не держат.

**Фирма** (с 2.2) — `home/personal/firms/<фирма>.md` по шаблону `templates/firm.md`, подключается из профиля: своя
фирма и клиенты — проекты (с синонимами), репозитории, системы (есть / нет доступа / не проверено, адрес, имя токена).

**Профиль и фирма — не в git** (`.gitignore`): репозиторий публичный. Бэкап и перенос на другую машину — сам.

### Дерево (размеры — для контроля, `RULES.SIZE`)

```
~/.claude/                                         # симлинки, все — через claude-config (путь в одном месте)
├── claude-config                                  # ссылка на этот репозиторий — ЕДИНСТВЕННОЕ место с путём к нему
├── CLAUDE.md                             10.2 КБ  # RULES (как читать), коды файлов и утилиты, @-импорты
├── user.md       USER                             # симлинк на активный профиль (RULES.USER.1)
├── personal/                                      # ПЕРЕНОСИМОЕ (RULES.PORT)
│   ├── users/                                     # ПРОФИЛИ — не в git; @ только активный (через user.md)
│   │   ├── <имя>_<фирма>.md            ~12.0 КБ   # я и окружение: ABOUT PREF WORK PERM SYS DEV ACC FOLD EVENT
│   │   └── <имя>_<фирма>.settings.json            # настройки Claude Code — симлинк ~/.claude/settings.json
│   ├── firms/                                     # ФИРМЫ — не в git; @ из профиля (RULES.USER.2)
│   │   └── <фирма>.md          FIRM     ~6.6 КБ   # своя фирма и клиенты: проекты, репозитории, системы
│   ├── rules/                                     # КАК РАБОТАЕМ — @, всегда
│   │   ├── comm.md       COMM           10.5 КБ   # язык и перевод, коротко, учёба, объяснения, вопросы, «пошло не так»
│   │   ├── work.md       WORK           12.0 КБ   # тикет, дисциплина, прогоны, проверка, ревью, оценка, сдача
│   │   ├── safe.md       SAFE            3.3 КБ   # секреты, чужое, разрушительные шаги, разрешения
│   │   ├── files.md      FILES          11.0 КБ   # что куда писать, документы задач, утилиты
│   │   └── integ.md      INTEG           6.3 КБ   # токены, VPN, трекер, wiki, git-сервер, логи, почта, чат
│   ├── tech/                                      # ТЕХНОЛОГИИ — @, всегда: SETUP / RULE / TRAP
│   │   ├── code.md       CODE            5.8 КБ   # общее для любого кода + журнал замечаний ревью
│   │   ├── java.md       JAVA            11.8 КБ   # sdkman; MapStruct; Jackson 3, Spring, JUnit, логи в тестах (бэк)
│   │   ├── gradle.md     GRADL           4.2 КБ   # gradlew в WSL, старый Gradle, отчёты, исходники, Lombok (бэк)
│   │   ├── api.md        API             1.1 КБ   # OpenAPI: map-ключи, тексты ошибок                  (бэк+фронт)
│   │   ├── node.md       NODE            5.1 КБ   # nvm; node_modules, npm и сертификаты, npx-форматтер      (фронт)
│   │   ├── ng.md         NG              3.7 КБ   # effect/untracked; ng-zorro, шаблоны, playwright         (фронт)
│   │   ├── git.md        GIT             3.7 КБ   # CRLF, HTTPS из WSL, коммит из cmd, ignored-файл при смене ветки
│   │   ├── wsl.md        WSL             7.7 КБ   # окружение; localhost, Docker, симлинки, CRLF, форматтер
│   │   ├── tls.md        TLS             2.2 КБ   # PKIX, неполная цепочка
│   │   └── sql.md        SQL             4.7 КБ   # Flyway: удалённый R__, правка V; Oracle: VARCHAR2; PG: пояс JVM (бэк)
│   ├── tools/                                     # УТИЛИТЫ (FILES.TOOLS) — не грузятся, запускаются
│   │   ├── jira.py                                # тикет текстом, --attach, --changelog
│   │   ├── jira-worklog.py                        # журнал часов → worklog Jira один в один, сверка (/timelog-askend)
│   │   ├── wiki.py                                # страница → текст с пометками [+новое+] ~~убрано~~, вложения
│   │   ├── bb-pr.py                               # PR: статус, ревьюеры, сборка, комментарии
│   │   ├── test-count.sh                          # тесты в JUnit-отчётах и их свежесть
│   │   └── flyway-checksum.py                     # контрольная сумма миграции
│   ├── skills/<имя>/SKILL.md                      # ПРОЦЕДУРЫ по вызову: rules (ведение правил + переезд версий:
│   │                                              #   v1-to-v2.md, v2.0-to-v2.1.md, v2.1-to-v2.2.md), ticket, estimate,
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

Всего грузится (`CLAUDE.md` + `user.md` + файл фирмы + `rules/` + `tech/`): **122.0 КБ** (+ `CLAUDE.md` и `.claude/` текущего проекта).

**Проектного здесь нет.** `CLAUDE.md` проекта (метка версии, `PROJ.*`), `.claude/work.md`, `.claude/integ.md`,
`.claude/tech/*.md`, документы по задачам `.claude/tickets/`, `.sdkmanrc` / `.nvmrc` — лежат обычными файлами в самом
проекте и скрыты от git через `<repo>/.git/info/exclude`. Проект на старой версии — ассистент предложит переезд
(`RULES.MIGR`).

**После `git pull` новой версии — обязательно `./install.sh`** (новые скиллы, профиль; без него, например, нет скилла
`/rules`), потом переезд своих проектов: ассистент сам предложит (`RULES.MIGR.1`), инструкции — в
`home/personal/skills/rules/` (`v1-to-v2.md`, `v2.0-to-v2.1.md`, `v2.1-to-v2.2.md` — со старой версии подряд). **На
2.2 — до `git pull` сохранить свой профиль**, если он был в git (`v2.1-to-v2.2.md`, §2).

Секретов здесь тоже нет: токены — в `~/.bashrc`, доступы к Artifactory — в `~/.gradle/gradle.properties`.

## Развернуть на новой машине

```bash
git clone git@github.com:konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config
./install.sh --dry-run   # показать, что будет сделано
./install.sh                              # профилей несколько — спросит, с каким работаем
./install.sh --profile <имя>_<фирма>      # или выбрать/сменить профиль сразу
```

Репозиторий можно положить куда угодно: путь к нему знает только ссылка `~/.claude/claude-config` (остальные ссылки —
через неё). Переложил — `./install.sh` из нового места.

Свой профиль, настройки (`<имя>_<фирма>.settings.json`) и файл фирмы — перенести со старой машины (они не в git) или создать по шаблонам:
`home/personal/templates/user.md` → `home/personal/users/<имя>_<фирма>.md`, `templates/firm.md` →
`home/personal/firms/<фирма>.md` (версии — проверить командами, `RULES.USER.1`), потом `./install.sh`. Повторный запуск безопасен. Существующий файл, совпадающий с копией, заменяется симлинком;
отличающийся — сохраняется как `<файл>.bak-<дата>`.

## Разрешения (`~/.claude/settings.json`)

С 2.2 — **рядом с профилем**: `home/personal/users/<имя>_<фирма>.settings.json` (не в git — там пути и имена
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

## Строка состояния (claude-pace)

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

## Ограничения

- Симлинки — WSL-шные: из WSL читаются, Windows-программы их не видят. Настоящие Windows-симлинки
  (`mklink`) требуют прав администратора или Developer Mode. Claude Code запускается из WSL.
- Репозиторий хранится с LF (`.gitattributes`), одинаково для WSL- и Windows-git.
