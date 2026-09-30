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

## sdkman: первая установленная Java становится версией по умолчанию

**Симптом:** после `sdk install java 17…` (даже с ответом «n» на «set as default?») во всех шеллах
`java` — 17, хотя системная была другой.
**Причина:** первая установленная версия кандидата sdkman всегда делается `current`.
**Как правильно:** зарегистрировать системную Java как локальную версию и вернуть её по умолчанию:
`sdk install java 25-system /usr/lib/jvm/<jdk>` → `sdk default java 25-system`. Версию проекта —
через `.sdkmanrc` (+ `sdkman_auto_env=true`).

## WSL-симлинки на `/mnt/c` не видны Windows

**Симптом:** `ln -s` из WSL на диске C: работает в WSL, а Windows-программа пишет «The file cannot be
accessed by the system».
**Причина:** WSL создаёт свой тип симлинка; настоящий NTFS-симлинк (`mklink`) требует прав
администратора или Developer Mode.
**Как правильно:** симлинки — только для того, что читается из WSL (Claude Code). Если файл нужен
Windows-программе — копия, не симлинк.

## Переменная из `~/.bashrc` пустая в текущей сессии

**Симптом:** токен дописан в `~/.bashrc`, а `echo "$VAR"` в уже открытом терминале / сессии
ассистента пуст.
**Причина:** `.bashrc` читается только при старте интерактивного шелла.
**Как правильно:** в терминале — `source ~/.bashrc`. В сессии ассистента, не печатая значение:
`export VAR=$(bash -ic 'echo -n "$VAR"' 2>/dev/null)` в той же команде перед использованием.
Токены не вставлять в чат (в т.ч. в выводе терминала) — если попал, перевыпустить.

## Внутренний сервис не отвечает (Jira, wiki, реестр, git-сервер)

**Симптом:** `curl` / `git fetch` к внутреннему адресу висит и падает по таймауту (`(28) Failed to connect`),
хотя недавно работало.
**Причина:** скорее всего слетел VPN.
**Как правильно:** запросы к внутренним сервисам — с таймаутом (`curl -m 20`). Не ответило — **сразу сказать
пользователю** «<сервис> недоступен, похоже, слетел VPN» и дождаться ответа; не повторять в фоне, не ждать
минутами, не подменять данные молча — если продолжаю без них, сказать, откуда взял вместо.

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

## `sed` на CRLF-файлах: смешанные окончания строк

**Симптом:** после `sed -i 's/…/&\nновая строка/'` `file` показывает «with CRLF, LF line terminators».
**Причина:** вставленный `\n` — голый LF, остальные строки файла заканчиваются на `\r\n`.
**Как правильно:** править инструментом, который сохраняет окончания строк (Edit), или вставлять
`\r\n`. Починить: `sed -i 's/\([^\r]\)$/\1\r/; s/^$/\r/' <файл>`, затем `file <файл>`.

## Форматтер из WSL, проверка в Windows — «violations» на весь файл

**Симптом:** после `spotlessApply` (или другого форматтера) в WSL сборка в Windows падает на
проверке формата, и дифф — весь файл целиком.
**Причина:** форматтер ставит окончания строк по git-атрибутам. WSL-git не видит системный
`core.autocrlf=true` Windows-git'а и пишет LF, а Windows-сборка ждёт CRLF.
**Как правильно:** форматировать тем же окружением, в котором собираешь и проверяешь (Windows-обёртка
`cmd.exe /c "… gradlew.bat spotlessApply"`). Проверка — `file <путь>`.

## Форматтер не в зависимостях проекта: `npx` берёт последнюю версию

**Симптом:** `npx prettier --check` ругается даже на файлы, где изменены 1–2 строки.
**Причина:** пакета нет в `devDependencies`, `npx` скачивает свежую версию, а существующий код под неё
не отформатирован (форматирование делал плагин редактора со своими настройками).
**Как правильно:** не прогонять по чужим файлам. Новые файлы — `--write` целиком, в изменённых —
вручную держать стиль соседнего кода.

## Docker Desktop в Windows, а из WSL Docker не виден

**Симптом:** в WSL `docker info` → `dial unix /var/run/docker.sock: connect: no such file or directory`,
Testcontainers не стартуют; при этом `cmd.exe /c "docker info"` отвечает.
**Причина:** в Docker Desktop не включена WSL-интеграция для этого дистрибутива.
**Как правильно:** постоянно — Docker Desktop → Settings → Resources → WSL integration (включает
пользователь). Временно — запускать тесты Windows-сборкой через `cmd.exe` (см. «`./gradlew` в WSL»:
`set JAVA_HOME=…&& gradlew.bat integrationTest --tests *Xxx*`).

## Git по HTTPS из WSL: «could not read Username»

**Симптом:** `git fetch` в WSL → `fatal: could not read Username for 'https://…'`.
**Причина:** учётные данные хранит только Windows-git (Credential Manager), WSL-git их не видит.
**Как правильно:** `fetch`/`pull`/`push` — Windows-git'ом (`cmd.exe /c "git fetch origin"`) или из IDE.
Без этого локальные `origin/*` в WSL могут быть устаревшими — учитывать, если на них завязан `ratchetFrom`
или сравнение веток.

## Gradle: отчёты тестов от прошлого запуска

**Симптом:** сборка упала (например, на проверке формата), а в `build/test-results/**/TEST-*.xml`
«все тесты зелёные».
**Причина:** Gradle не чистит отчёты; если задача тестов не запускалась или была `UP-TO-DATE`, лежат
старые файлы.
**Как правильно:** смотреть код выхода сборки и время изменения XML (`stat`/`ls -l`) относительно
старта. Цифры брать только из свежих отчётов.

## Исходники внешней зависимости — в Gradle-кэше

**Симптом:** класс из внутренней библиотеки (`implementation("group:artifact:…")`) не найти в репозитории.
**Причина:** это артефакт из реестра; исходники есть, только если опубликован `*-sources.jar`.
**Как правильно:** `~/.gradle/caches/modules-2/files-2.1/<group>/<artifact>/<version>/*/`
(при сборке из Windows — в `C:\Users\<user>\.gradle\…`). `*-sources.jar` распаковать в scratchpad.
Нашёлся баг в такой библиотеке — не обходить в своём коде, а сказать пользователю (`workflow.md` →
«Причина — во внутренней библиотеке»).

## Jackson 3 не видит `@JsonProperty` на унаследованных полях

**Симптом:** при десериализации в класс-наследник (например, сгенерированный openapi-generator с
`allOf` → `extends`) поля базового класса (`id`, `version`) молча `null`.
**Причина:** Jackson 3 (`tools.jackson`) иначе обрабатывает аннотации на полях родителя, чем Jackson 2
(`com.fasterxml`), под который написан сгенерированный код.
**Как правильно:** такие модели читать Jackson 2 `ObjectMapper`'ом. Jackson 3 — только для `JsonNode` и
своих простых типов.

## OpenAPI 3.0: ключи map не валидируются, тексты bean-validation стандартные

**Симптом:** нужно проверить ключи тела `{"<key>": …}` (`additionalProperties`) или выдать свой текст
ошибки, а в спеке это не выразить.
**Причина:** `propertyNames` появился только в OpenAPI 3.1. openapi-generator (spring) превращает
`pattern`/`maxLength` в `@Pattern`/`@Size` без своего `message` — текст берётся из
`messages.properties` или из дефолтов Hibernate Validator.
**Как правильно:** если нужен конкретный текст (часто требует аналитик), проверять в коде
делегата/контроллера и бросать исключение приложения; в спеке оставить описание.

## JUnit `@CsvSource`: значения — только константы времени компиляции

**Симптом:** `"A".repeat(101) + " | …"` в `@CsvSource` → ошибка компиляции «element value must be a
constant expression».
**Причина:** аргументы аннотаций в Java — только compile-time константы.
**Как правильно:** вычисляемые значения — в отдельный `@Test` или `@MethodSource`.

## Confluence REST: короткие ссылки `/x/XXXX`

**Симптом:** по короткой ссылке из тикета нужен id страницы для `/rest/api/content/<id>`.
**Причина:** `/x/…` редиректит через `tinyurl.action`, id в самой ссылке не виден.
**Как правильно:** `curl -sSL -o /dev/null -w '%{url_effective}' -H "Authorization: Bearer …" <ссылка>` —
в итоговом URL `/pages/<id>/`.

## Angular `effect`: зависимость от сигналов, прочитанных в вызванном методе

**Симптом:** пагинация «не работает»: номер страницы меняется, данные — нет; в Network на один клик два запроса —
нужный `offset` и следом `offset=0`.
**Причина:** `effect` отслеживает **все** сигналы, прочитанные синхронно во время его выполнения, в том числе внутри
вызванных методов. `effect(() => { const id = this.id(); this.page.set(1); this.fetch(id); })`, где `fetch` читает
`this.page()`, зависит и от `page`: смена страницы перезапускает эффект, тот сбрасывает её на 1 и перезапрашивает.
Вход компонента за один цикл 1 → 2 → 1, Angular изменения не видит, а UI-библиотека уже показывает 2.
**Как правильно:** оставить в эффекте только нужные зависимости, остальное — в `untracked(() => …)`:
`effect(() => { const id = this.id(); untracked(() => { this.page.set(1); this.fetch(id); }); })`.
Запись сигнала (`set`) зависимостью не делает — только чтение.

## Тест Angular-компонента с ng-zorro `nz-tabset`: `NG05105 @tabSwitchMotion`

**Симптом:** `fixture.detectChanges()` → `NG05105: Unexpected synthetic property @tabSwitchMotion found`.
**Причина:** компоненты ng-zorro используют анимации Angular, а в `TestBed` провайдер анимаций не подключён.
**Как правильно:** в `providers` теста — `provideNoopAnimations()` из `@angular/platform-browser/animations`.
Эффекты компонента (`effect` в конструкторе) выполняются при change detection — без `fixture.detectChanges()`
они в тесте не сработают.

## MapStruct молча не маппит поле (`id` у сущности из чужого jar)

**Симптом:** в ответе поле (часто `id`) всегда `null`, сборка зелёная.
**Причина:** неразмеченное поле цели по умолчанию — только warning (`unmappedTargetPolicy = WARN`), а `gradle -q` /
CI его не показывают. Типичный случай — сущность из jar-библиотеки, чей родитель (с Lombok-геттером `getId`)
MapStruct при неявном сопоставлении не увидел.
**Как правильно:** после добавления маппера открыть `build/generated/sources/annotationProcessor/**/XxxMapperImpl.java`
и проверить, что все поля выставляются; для полей родителя — явный `@Mapping(source = "id", target = "id")`.
Юнит-тест маппера — через сгенерированный `new XxxMapperImpl()` (`Mappers.getMapper` требует `mapstruct` в test
classpath, его там может не быть).
