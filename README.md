# claude-config — общие настройки Claude Code (v2.1)

Здесь **по-настоящему** лежат мои общие правила и скиллы — то, что не зависит от проекта и
переезжает со мной. В `~/.claude` — только симлинки сюда (их создаёт `install.sh`). Правишь файл по
любому из путей — меняется файл здесь; коммитишь отсюда.

## Что где

Как читать правила (`RULES`: номера `ФАЙЛ.РАЗДЕЛ.N`, профиль, проект, версии) — [`home/CLAUDE.md`](home/CLAUDE.md);
как их вести и переводить проекты на новую версию — скилл `home/personal/skills/rules/`. Дерево — ниже. Версии — теги
`v1.0`, `v2.0`…, что поменялось — [`CHANGELOG.md`](CHANGELOG.md).

**Профиль** (с 2.1) — всё «про меня»: кто я, как общаться и работать, разрешения, система и инструменты, доступы
(только имена), папки, мои события. Файл `home/personal/users/<имя>_<фирма>.md` — свой на каждое окружение (новая
фирма — копия, переписать окружение); активный — симлинк `~/.claude/user.md` (не в git), его создаёт `install.sh`.
Правила ссылаются на профиль по номеру (`USER.PREF.1`), сами фактов о человеке не держат.

### Дерево (размеры — для контроля, `RULES.SIZE`)

```
~/.claude/                                         # симлинки в /mnt/c/code/claude-config/home
├── CLAUDE.md                              8.3 КБ  # RULES (как читать), коды файлов и утилиты, @-импорты
├── user.md       USER                             # симлинк на активный профиль (не в git, RULES.USER.1)
├── personal/                                      # ПЕРЕНОСИМОЕ (RULES.PORT)
│   ├── users/                                     # ПРОФИЛИ — @ только активный (через user.md)
│   │   └── tarlekon_askend.md            9.6 КБ   # я и окружение в Askend: ABOUT PREF WORK PERM SYS DEV ACC FOLD EVENT
│   ├── rules/                                     # КАК РАБОТАЕМ — @, всегда
│   │   ├── comm.md       COMM            9.9 КБ   # язык и перевод, коротко, учёба, объяснения, вопросы, «пошло не так»
│   │   ├── work.md       WORK           10.7 КБ   # тикет, дисциплина, прогоны, проверка, ревью, оценка, сдача
│   │   ├── safe.md       SAFE            3.4 КБ   # секреты, чужое, разрушительные шаги, разрешения
│   │   ├── files.md      FILES          10.0 КБ   # что куда писать, документы задач, утилиты
│   │   └── integ.md      INTEG           5.9 КБ   # токены, VPN, трекер, wiki, git-сервер, логи, почта, чат
│   ├── tech/                                      # ТЕХНОЛОГИИ — @, всегда: SETUP / RULE / TRAP
│   │   ├── code.md       CODE            4.6 КБ   # общее для любого кода + журнал замечаний ревью
│   │   ├── java.md       JAVA            7.8 КБ   # sdkman; MapStruct; Jackson 3, Spring, JUnit, логи в тестах (бэк)
│   │   ├── gradle.md     GRADL           4.2 КБ   # gradlew в WSL, старый Gradle, отчёты, исходники, Lombok (бэк)
│   │   ├── api.md        API             1.1 КБ   # OpenAPI: map-ключи, тексты ошибок                  (бэк+фронт)
│   │   ├── node.md       NODE            5.1 КБ   # nvm; node_modules, npm и сертификаты, npx-форматтер      (фронт)
│   │   ├── ng.md         NG              3.7 КБ   # effect/untracked; ng-zorro, шаблоны, playwright         (фронт)
│   │   ├── git.md        GIT             2.2 КБ   # CRLF, HTTPS из WSL, коммит из cmd
│   │   ├── wsl.md        WSL             7.7 КБ   # окружение; localhost, Docker, симлинки, CRLF, форматтер
│   │   ├── tls.md        TLS             2.2 КБ   # PKIX, неполная цепочка
│   │   └── sql.md        SQL             2.5 КБ   # Flyway: удалённый R__-файл, правка применённой V    (бэк)
│   ├── tools/                                     # УТИЛИТЫ (FILES.TOOLS) — не грузятся, запускаются
│   │   ├── jira.py                                # тикет текстом, --attach, --changelog
│   │   ├── wiki.py                                # страница → текст с пометками [+новое+] ~~убрано~~, вложения
│   │   ├── bb-pr.py                               # PR: статус, ревьюеры, сборка, комментарии
│   │   ├── test-count.sh                          # тесты в JUnit-отчётах и их свежесть
│   │   └── flyway-checksum.py                     # контрольная сумма миграции
│   ├── skills/<имя>/SKILL.md                      # ПРОЦЕДУРЫ по вызову: rules (ведение правил + переезд версий:
│   │                                              #   v1-to-v2.md, v2.0-to-v2.1.md), ticket, estimate,
│   │                                              #   commit-message, review-lessons, timelog
│   ├── statusline/                                # скрипт строки состояния
│   └── templates/                                 # ticket.md — документ задачи; project/ — заготовка проекта
└── projects/<проект>/memory/                      # память ассистента (контекст разговоров, не факты — они в USER)

<repo>/                                            # скрыто через .git/info/exclude
├── CLAUDE.md                                      # метка версии; PROJ.*; @-импорты .claude/*.md (или главного группы)
└── .claude/
    ├── work.md  integ.md  …                       # отличия от общих правил — те же номера (RULES.PROJ)
    ├── tech/<тех>.md                              # проектные SETUP / RULE / TRAP
    ├── review.md                                  # замечания ревью (WORK.REVW)
    ├── <скилл>.md                                 # настройки скилла (timelog.md) — без @
    ├── tools/  skills/                            # утилиты и процедуры проекта
    └── tickets/                                   # <KEY>.md, <KEY>.in.*, <KEY>.out.* (FILES.DOCS)
```

Всего грузится (`CLAUDE.md` + `user.md` + `rules/` + `tech/`): **98.9 КБ** (+ `CLAUDE.md` и `.claude/` текущего проекта).

**Проектного здесь нет.** `CLAUDE.md` проекта (метка версии, `PROJ.*`), `.claude/work.md`, `.claude/integ.md`,
`.claude/tech/*.md`, документы по задачам `.claude/tickets/`, `.sdkmanrc` / `.nvmrc` — лежат обычными файлами в самом
проекте и скрыты от git через `<repo>/.git/info/exclude`. Проект на старой версии — ассистент предложит переезд
(`RULES.MIGR`).

**После `git pull` новой версии — обязательно `./install.sh`** (новые скиллы, профиль; без него, например, нет скилла
`/rules`), потом переезд своих проектов: ассистент сам предложит (`RULES.MIGR.1`), инструкции — в
`home/personal/skills/rules/` (`v1-to-v2.md`, `v2.0-to-v2.1.md`; с v1 — обе подряд).

Секретов здесь тоже нет: токены — в `~/.bashrc`, доступы к Artifactory — в `~/.gradle/gradle.properties`.

## Развернуть на новой машине

```bash
git clone git@github.com:konstantinTarletski/claude-config.git /mnt/c/code/claude-config
cd /mnt/c/code/claude-config
./install.sh --dry-run   # показать, что будет сделано
./install.sh                              # профилей несколько — спросит, с каким работаем
./install.sh --profile <имя>_<фирма>      # или выбрать/сменить профиль сразу
```

Своего профиля ещё нет — создать `home/personal/users/<имя>_<фирма>.md` копией любого и переписать **все** разделы
(версии — проверить командами, `RULES.USER.1`), потом `./install.sh`. Повторный запуск безопасен. Существующий файл, совпадающий с копией, заменяется симлинком;
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
