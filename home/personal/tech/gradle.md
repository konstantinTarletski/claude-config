# GRADL — Gradle

Java и установка — `tech/java.md`; WSL и окончания строк — `tech/wsl.md`.

- **GRADL.TRAP.1** `./gradlew` в WSL: `/usr/bin/env: 'sh\r'` или «No such file or directory» → выкачан Windows-git'ом с
  CRLF (`GIT.TRAP.1`) → `gradlew text eol=lf` в `.git/info/attributes` + `cmd.exe /c "del gradlew && git checkout --
  gradlew"` (просто `checkout` не перепишет). То же для `mvnw`, `*.sh`.
  Запасной вариант (JDK или доступы только в Windows) → `cmd.exe /c "set JAVA_HOME=C:\Users\<user>\.jdks\<jdk>&&
  gradlew.bat …"` — без пробела перед `&&`.
- **GRADL.TRAP.2** [Gradle 7.x] «Unsupported class file major version» → Gradle 7.6 не знает Java > 19 → нужная Java в
  sdkman (`JAVA.SETUP.2`), временно — JDK из IntelliJ (`.jdks`) через `cmd.exe`.
- **GRADL.TRAP.3** Сборка упала, а в `build/test-results/**/TEST-*.xml` «всё зелёное» → Gradle не чистит старые отчёты
  → смотреть код выхода и время XML; цифры — только из свежих (`tools/test-count.sh`).
- **GRADL.TRAP.4** Класса из внутренней библиотеки нет в репозитории → это артефакт → исходники (`*-sources.jar`) в
  `~/.gradle/caches/modules-2/files-2.1/<group>/<artifact>/<version>/` (Windows — `C:\Users\<user>\.gradle\…`, Maven —
  `~/.m2/repository/…`), распаковать в scratchpad. Баг там → `WORK.DISC.7`.
- **GRADL.TRAP.6** [Lombok] После смены ветки `compileJava` — «100 errors» (`cannot find symbol log`) → сломалась
  инкрементальная компиляция, код в порядке → `compileJava --rerun-tasks`.
- **GRADL.TRAP.7** [Gradle 8.11, WSL 3.0] Сборка в WSL: `Input/output error` из `DefaultFileLockManager`, потом модуль
  «не видит» соседний (`package … does not exist`) → проект на `/mnt/c`, жив Windows-демон (IntelliJ, `gradlew.bat`) и
  держит замки в `<repo>/.gradle/` → `cmd.exe /c "set JAVA_HOME=<Windows-JDK>&& gradlew.bat --stop"`; демоны другой Java
  `--stop` не видит → `Stop-Process` по `GradleDaemon` в `Get-CimInstance Win32_Process`. Одну папку из Windows и WSL
  одновременно не собирать. (×2, 27.10.2026)
