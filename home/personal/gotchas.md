# Общие грабли — не про конкретный проект

То, что встретится в любом проекте: инструменты, ОС, библиотеки. Без путей, имён компании и кода
проекта. Проектные грабли — в `<repo>/.claude/gotchas.md`. Формат: симптом → причина → как правильно.

## WSL + `node_modules`, установленные из Windows

**Симптом:** в WSL `npx vitest` / `npm run build` падают на всех файлах, например
`Failed to resolve import "@core/..."`, хотя код в порядке.
**Причина:** репозиторий лежит на `/mnt/c/...`, зависимости ставились Windows-нодой — в
`node_modules` нативные бинарники под Windows (`@esbuild/win32-x64`, `@rollup/rollup-win32-*`),
алиасы из `tsconfig` резолвятся не так.
**Как правильно:** проверить `ls node_modules/@esbuild`; если `win32-*` — запускать через
Windows-ноду: `cmd.exe /c "cd /d C:\path\to\repo && npm test"`. Не переустанавливать зависимости
из WSL без спроса — сломается у пользователя в Windows.

## WSL-git показывает изменёнными все файлы репозитория

**Симптом:** в WSL `git status` — сотни `M`, `git diff --stat` — «N insertions(+), N deletions(-)»
с равными числами; `git diff --ignore-cr-at-eol` пуст.
**Причина:** репозиторий выкачан Windows-git'ом с `core.autocrlf=true` (системный конфиг
`C:/Program Files/Git/etc/gitconfig`): в рабочей копии CRLF, в индексе LF. WSL-git этого
конфига не видит и сравнивает байты.
**Как правильно:** статус, дифф и коммит — Windows-git'ом: `cmd.exe /c "git status --short"`,
`cmd.exe /c "git diff --numstat"` или IDE. Проверить: `cmd.exe /c "git config --show-origin core.autocrlf"`.
Из WSL `git add -A` не делать — закоммитит CRLF во все файлы. Новые файлы можно писать с LF —
Windows-git при коммите нормализует (выдаст warning «LF will be replaced by CRLF» — это нормально).

## `./gradlew` в WSL: «No such file or directory»

**Симптом:** `./gradlew ...` → `/usr/bin/env: 'sh\r'` или `timeout: failed to run command './gradlew': No such file or directory`.
**Причина:** тот же CRLF: первая строка `#!/bin/sh\r`.
**Как правильно:** локально `gradlew text eol=lf` в `.git/info/attributes` + пересоздать файл
Windows-git'ом, Java — из sdkman (см. `environment.md`). **Запасной вариант**, пока JDK нужной версии
и `gradle.properties` с доступами есть только в Windows, — Windows-обёртка из WSL:
`cmd.exe /c "set JAVA_HOME=C:\Users\<user>\.jdks\<jdk>&& gradlew.bat test --tests *XxxTest*"`.
Без пробела перед `&&` — иначе пробел попадёт в `JAVA_HOME`. `cmd.exe` сам встаёт в Windows-путь
текущего каталога `/mnt/c/...`. Результаты — `build/test-results/test/*.xml` (посчитать `tests=`/`failures=`,
чтобы убедиться, что тесты реально запускались, а не «BUILD SUCCESSFUL» без тестов).

## Нужная версия Java в WSL

**Симптом:** старый Gradle (7.x) не стартует или падает на «Unsupported class file major version».
**Причина:** в WSL стоит только свежая Java; Gradle 7.6 не поддерживает Java > 19.
**Как правильно:** поставить нужную версию в sdkman (`sdk install java 17.x-amzn`) — см.
`environment.md`. `bash gradlew` CRLF не лечит (CRLF во всех строках) — нужен `eol=lf` для `gradlew`.
Временный запасной вариант — JDK, скачанные IntelliJ (`C:\Users\<user>\.jdks\`), через `cmd.exe`.

## Переменная из `~/.bashrc` пустая в текущей сессии

**Симптом:** токен дописан в `~/.bashrc`, а `echo "$VAR"` в уже открытом терминале / сессии
ассистента пуст.
**Причина:** `.bashrc` читается только при старте интерактивного шелла.
**Как правильно:** в терминале — `source ~/.bashrc`. В сессии ассистента, не печатая значение:
`export VAR=$(bash -ic 'echo -n "$VAR"' 2>/dev/null)` в той же команде перед использованием.
Токены не вставлять в чат (в т.ч. в выводе терминала) — если попал, перевыпустить.

## npm из WSL: `SELF_SIGNED_CERT_IN_CHAIN` на внутреннем реестре

**Симптом:** `curl https://<внутренний-реестр>` отвечает 200, а `npm view` / `npm ci` падают с
`self-signed certificate in certificate chain`.
**Причина:** корпоративный CA добавлен в системное хранилище Linux (`/usr/local/share/ca-certificates`),
а Node по умолчанию использует свой встроенный набор CA.
**Как правильно:** `export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt` в `~/.bashrc`
(прописано 25.09.2026). Не отключать проверку (`strict-ssl=false`).

## `npm ci`: «package.json and package-lock.json … are in sync»

**Симптом:** `npm ci` сразу падает с `EUSAGE … Missing: <pkg> from lock file`.
**Причина:** lock-файл не соответствует `package.json` — часто это незакоммиченные правки
пользователя в `package-lock.json`.
**Как правильно:** `npm ci` в этом случае ничего не удаляет — старые `node_modules` целы. Сначала
`git status`; lock-файл пользователя не перегенерировать (`npm install`) без спроса.

## `node_modules` от другой ветки

**Симптом:** `ng build` → «Could not find the '@angular-devkit/build-angular:browser' builder»,
`tsc` → сотни «Cannot find module '@angular/...'», хотя код в порядке.
**Причина:** переключились на ветку с другой мажорной версией фреймворка, а `node_modules`
остались от прежней (сравнить `package.json` и `node_modules/<пакет>/package.json` → `version`).
**Как правильно:** `npm ci` на нужной ветке — но это заменит зависимости для другой ветки, поэтому
только с согласия пользователя. Без переустановки — хотя бы `tsc --noEmit` и отфильтровать ошибки
по изменённым файлам.

## Python `open()` на CRLF-файлах

**Симптом:** после правки скриптом файл целиком «изменился» или сменились окончания строк.
**Причина:** текстовый режим с universal newlines читает `\r\n` как `\n` и пишет обратно `\n`.
**Как правильно:** читать/писать в `'rb'`/`'wb'` и сохранять исходные окончания; после правки —
`file <путь>` и `git diff --stat`.
