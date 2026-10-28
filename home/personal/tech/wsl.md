# WSL — WSL и Windows: сеть, симлинки, Docker, окончания строк

- **WSL.SETUP.2** Доступы сборки (Nexus, Artifactory, npm) → в профиле WSL: `~/.gradle/gradle.properties`,
  `~/.m2/settings.xml`, `~/.npmrc`; секреты туда переносит пользователь (`SAFE.SECR.1`).
- **WSL.SETUP.3** На будущее → репозитории в файловой системе Linux (`~/code`), а не на `/mnt/c`: нет CRLF и
  Windows-бинарников, в разы быстрее; IntelliJ открывает через `\\wsl$\…`.
- **WSL.TRAP.1** WSL-симлинк на `/mnt/c` → Windows-программа: «The file cannot be accessed» → это симлинк WSL, не NTFS
  → симлинки — только для того, что читает WSL; Windows-программе — копия.
- **WSL.TRAP.2** Переменная из `~/.bashrc` пустая в сессии → `.bashrc` читается только интерактивным шеллом → в
  терминале `source ~/.bashrc`; в сессии ассистента — `tools/with-token.sh` (`INTEG.ALL.1`).
- **WSL.TRAP.3** Из WSL `curl localhost:<порт>` к приложению в Windows → «Couldn't connect» → WSL2 в NAT, `localhost` в
  WSL — сама VM → запрос со стороны Windows (`cmd.exe /c "curl …"`) или `networkingMode=mirrored` в `.wslconfig`.
  Обратно работает: сервер в WSL виден из Windows по `localhost` (проверено 27.10.2026, WSL 3.0).
- **WSL.TRAP.7** Форматтер в WSL → проверка в Windows падает на весь файл → WSL-git не видит `core.autocrlf` и пишет LF
  (`GIT.TRAP.1`) → форматировать тем же окружением, что собираешь (`cmd.exe /c "… gradlew.bat spotlessApply"`).
