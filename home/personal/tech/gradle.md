# GRADL — Gradle

Java и её установка — `tech/java.md`; WSL и окончания строк — `tech/wsl.md`.

## GRADL.TRAP — грабли

- **GRADL.TRAP.1** **`./gradlew` в WSL: «No such file or directory».**
  **Симптом:** `./gradlew ...` → `/usr/bin/env: 'sh\r'` или `timeout: failed to run command './gradlew': No such file or
  directory`.
  **Причина:** репозиторий выкачан Windows-git'ом с CRLF (`GIT.TRAP.1`): первая строка `#!/bin/sh\r`.
  **Как правильно:** локально `gradlew text eol=lf` в `.git/info/attributes` + пересоздать файл Windows-git'ом:
  `cmd.exe /c "del gradlew && git checkout -- gradlew"` (просто `git checkout` не перепишет — git считает файл
  неизменённым). `bash gradlew` CRLF не лечит. То же для `mvnw` и `*.sh`. **Запасной вариант**, пока JDK нужной версии и `gradle.properties` с
  доступами есть только в Windows, — Windows-обёртка из WSL:
  `cmd.exe /c "set JAVA_HOME=C:\Users\<user>\.jdks\<jdk>&& gradlew.bat test --tests *XxxTest*"`. Без пробела перед
  `&&` — иначе пробел попадёт в `JAVA_HOME`. `cmd.exe` сам встаёт в Windows-путь текущего каталога `/mnt/c/...`.
- **GRADL.TRAP.2** [Gradle 7.x] **Старый Gradle не стартует на новой Java** («Unsupported class file major version»).
  **Причина:** Gradle 7.6 не поддерживает Java > 19, а в WSL стоит только свежая.
  **Как правильно:** поставить нужную Java в sdkman (`JAVA.SETUP.2`). Временно — JDK, скачанные IntelliJ
  (`C:\Users\<user>\.jdks\`), через `cmd.exe` (`GRADL.TRAP.1`).
- **GRADL.TRAP.3** **Отчёты тестов от прошлого запуска.**
  **Симптом:** сборка упала (например, на проверке формата), а в `build/test-results/**/TEST-*.xml` «все тесты зелёные».
  **Причина:** Gradle не чистит отчёты; если задача тестов не запускалась или была `UP-TO-DATE`, лежат старые файлы.
  **Как правильно:** смотреть код выхода сборки и время изменения XML относительно старта; цифры — только из свежих
  отчётов (`tools/test-count.sh`). Убедиться, что тесты реально запускались, а не «BUILD SUCCESSFUL» без тестов.
- **GRADL.TRAP.4** **Исходники внешней зависимости — в Gradle-кэше.**
  **Симптом:** класс из внутренней библиотеки (`implementation("group:artifact:…")`) не найти в репозитории.
  **Причина:** это артефакт из реестра; исходники есть, только если опубликован `*-sources.jar`.
  **Как правильно:** `~/.gradle/caches/modules-2/files-2.1/<group>/<artifact>/<version>/*/` (при сборке из Windows — в
  `C:\Users\<user>\.gradle\…`; Maven — `~/.m2/repository/<group-путь>/<artifact>/<version>/`). `*-sources.jar`
  распаковать в scratchpad. Нашёлся баг в такой библиотеке — не обходить
  (`WORK.DISC.7`).
- **GRADL.TRAP.5** **Не переключать ветку во время сборки.** Часть файлов компилируется уже из другой ветки — падает
  компиляция (`integrationTest` и т. п.) без причины в коде. Дождаться конца сборки.
- **GRADL.TRAP.6** [Lombok] **После смены ветки `compileJava` — «100 errors»** (`cannot find symbol log`, `is not
  abstract … isActive()`, `import requires canonical name for Fields`): сломалась инкрементальная компиляция, Lombok не
  отработал; код в порядке. Лечится `compileJava --rerun-tasks`.
