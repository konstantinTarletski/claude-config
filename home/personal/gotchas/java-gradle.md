# Грабли: Java, Gradle, JVM-библиотеки

Сломалось, не компилируется, не запускается. Общими словами, без проекта. Формат: симптом → причина → как правильно.

## `./gradlew` в WSL: «No such file or directory»

**Симптом:** `./gradlew ...` → `/usr/bin/env: 'sh\r'` или `timeout: failed to run command './gradlew': No such file or directory`.
**Причина:** тот же CRLF: первая строка `#!/bin/sh\r`.
**Как правильно:** локально `gradlew text eol=lf` в `.git/info/attributes` + пересоздать файл
Windows-git'ом: `cmd.exe /c "del gradlew && git checkout -- gradlew"` (просто `git checkout` файл не перепишет — git
считает его неизменённым). Java — из sdkman (см. `environment.md`). **Запасной вариант**, пока JDK нужной версии
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
Нашёлся баг в такой библиотеке — не обходить в своём коде, а сказать пользователю (`~/.claude/CLAUDE.md` →
«Работа»).

## Jackson 3 не видит `@JsonProperty` на унаследованных полях

**Симптом:** при десериализации в класс-наследник (например, сгенерированный openapi-generator с
`allOf` → `extends`) поля базового класса (`id`, `version`) молча `null`.
**Причина:** Jackson 3 (`tools.jackson`) иначе обрабатывает аннотации на полях родителя, чем Jackson 2
(`com.fasterxml`), под который написан сгенерированный код.
**Как правильно:** такие модели читать Jackson 2 `ObjectMapper`'ом. Jackson 3 — только для `JsonNode` и
своих простых типов.

## JUnit `@CsvSource`: значения — только константы времени компиляции

**Симптом:** `"A".repeat(101) + " | …"` в `@CsvSource` → ошибка компиляции «element value must be a
constant expression».
**Причина:** аргументы аннотаций в Java — только compile-time константы.
**Как правильно:** вычисляемые значения — в отдельный `@Test` или `@MethodSource`.
