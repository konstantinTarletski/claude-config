# Общие правила для всех проектов

Главный файл: дерево настроек, правило размера и подключение. Все правила подключены `@`-импортами ниже и
**грузятся всегда** — ничего не надо «вспомнить открыть». Куда что писать — `rules/structure.md`.

## Дерево (размеры — для контроля)

```
~/.claude/                                       # симлинки в /mnt/c/code/claude-config/home
├── CLAUDE.md                            6.0 КБ  # ЭТОТ ФАЙЛ: дерево, правило размера, @-импорты
├── personal/                                    # ПЕРЕНОСИМОЕ, без специфики компании/проекта
│   ├── rules/                                   # КАК РАБОТАЕМ — @, всегда
│   │   ├── communication.md             7.2 КБ  # язык, переводы, коротко, объяснения через код, вопросы, «пошло не так»
│   │   ├── workflow.md                  6.1 КБ  # тикет → разбор → «делай» → ревью MR/PR → проверка → сдача задачи
│   │   ├── safety.md                    2.6 КБ  # секреты, чужое не трогать, разрушительные шаги, разрешения
│   │   └── structure.md                11.9 КБ  # что куда писать, переносимость, «не дублировать»
│   ├── code-rules/                              # КАК ПИСАТЬ КОД — @, всегда; растёт по языкам
│   │   ├── general.md                   4.4 КБ  # импорты, «каждая строка доказана», где живёт код + журнал ревью
│   │   ├── java.md                      3.3 КБ  # MapStruct (лишний @Mapping, выровнять имена), OpenAPI-валидация
│   │   └── angular.md                   1.6 КБ  # effect / untracked
│   ├── gotchas/                                 # ЧТО ЛОМАЕТСЯ — @, всегда; растёт по технологиям
│   │   ├── wsl-windows.md               5.3 КБ  # localhost, симлинки, Docker, CRLF, переменные окружения
│   │   ├── git.md                       2.0 КБ  # WSL-git и CRLF, HTTPS-авторизация
│   │   ├── java-gradle.md               6.9 КБ  # gradlew, sdkman, отчёты тестов, исходники зависимостей, Jackson, Spring 4.0, JUnit
│   │   ├── node-angular.md              5.9 КБ  # node_modules, npm, сертификаты, ng build, ng-zorro
│   │   ├── services.md                  4.3 КБ  # VPN, Jira, Confluence, Bitbucket
│   │   └── tls.md                       2.4 КБ  # PKIX, неполная цепочка сертификатов
│   ├── environment.md                   3.6 КБ  # как поставить и выбрать Java/Node (sdkman, nvm)
│   ├── skills/<имя>/SKILL.md                    # ПРОЦЕДУРЫ по вызову: ticket, estimate, commit-message, review-lessons
│   ├── statusline/                              # скрипт строки состояния
│   └── templates/                               # ticket.md — документ задачи; project/ — заготовка нового проекта
└── projects/<проект>/memory/                    # память ассистента (личный контекст)

<repo>/                                          # скрыто через .git/info/exclude
├── CLAUDE.md                                    # устройство и команды проекта, «Задачи»; @-импортирует .claude/*.md
└── .claude/
    ├── tasks.md                                 # трекер, wiki, люди, калибровка — общий для связанных репозиториев
    ├── gotchas.md                               # грабли проекта
    ├── review.md                                # замечания ревью MR/PR — не повторять
    ├── skills/<имя>/SKILL.md                    # процедуры проекта
    └── tickets/<KEY>.md                         # документы по задачам (не грузятся, читать по задаче)
```

Всего грузится (`CLAUDE.md` + `personal/`): **74 КБ** (+ `CLAUDE.md` и `.claude/*.md` текущего проекта).

## Правило размера — маркер ⚠

- **Изменил, добавил или удалил файл — обновить его строку и размер в дереве** (`wc -c` / 1024, до 0.1 КБ) и итог.
- **Файл больше 12 КБ — поставить ⚠ и сказать мне** одной строкой: какой файл, сколько, как предлагаю разбить (по
  темам/технологиям — новый файл в той же папке). Без моего «да» не разбивать.
- **Итог больше 150 КБ** — сказать мне: что разрослось и что можно сжать или вынести.
- Новый файл в `rules/`, `code-rules/`, `gotchas/` — сразу строка в дереве и `@`-импорт ниже.

## Подключение

@~/.claude/personal/rules/communication.md
@~/.claude/personal/rules/workflow.md
@~/.claude/personal/rules/safety.md
@~/.claude/personal/rules/structure.md
@~/.claude/personal/code-rules/general.md
@~/.claude/personal/code-rules/java.md
@~/.claude/personal/code-rules/angular.md
@~/.claude/personal/gotchas/wsl-windows.md
@~/.claude/personal/gotchas/git.md
@~/.claude/personal/gotchas/java-gradle.md
@~/.claude/personal/gotchas/node-angular.md
@~/.claude/personal/gotchas/services.md
@~/.claude/personal/gotchas/tls.md
@~/.claude/personal/environment.md
