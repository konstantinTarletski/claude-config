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
- **WSL.TRAP.4** В WSL `docker info` → «no such file … docker.sock», Testcontainers не стартуют → в Docker Desktop не
  включена WSL-интеграция → Settings → Resources → WSL integration → свой дистрибутив → Apply & restart (останавливает
  контейнеры — поднять `docker compose up -d`). [Rancher Desktop, moby 29.5] То же самое: WSL-интеграция → из WSL
  работает, а `docker.exe` из Windows — «timed out dialing Hyper-V socket».
- **WSL.TRAP.5** Python-правка CRLF-файла сменила все окончания строк → текстовый режим пишет `\n` → `'rb'`/`'wb'`;
  после — `file <путь>`.
- **WSL.TRAP.6** После `sed` с `\n` файл «with CRLF, LF line terminators» → вставлен голый LF → править Edit'ом;
  починить: `sed -i 's/\([^\r]\)$/\1\r/; s/^$/\r/' <файл>`.
- **WSL.TRAP.7** Форматтер в WSL → проверка в Windows падает на весь файл → WSL-git не видит `core.autocrlf` и пишет LF
  (`GIT.TRAP.1`) → форматировать тем же окружением, что собираешь (`cmd.exe /c "… gradlew.bat spotlessApply"`).
- **WSL.TRAP.8** После `sed -i` по симлинку правка не попала в оригинал, ссылка стала файлом → GNU `sed -i` подменяет
  путь → править Edit'ом; подменил — сравнить с оригиналом и вернуть `ln -s`.
- **WSL.TRAP.9** [WSL 3.0, Docker Desktop 4.95] После обновления WSL → «Docker Desktop is unable to start» → его
  WSL-дистрибутив не поднялся → перезапустить Docker Desktop, не помогло — Troubleshoot → Restart. `wsl --shutdown`
  рвёт сессию — делает пользователь. После обновления WSL проверить `java`, `node`, `git`, симлинки `~/.claude`, VPN.
