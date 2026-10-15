# WSL — WSL и Windows: сеть, симлинки, Docker, окончания строк, переменные окружения

## WSL.SETUP — окружение

- **WSL.SETUP.1** Работаем из WSL (`USER.SYS.1`; версии и что установлено — `USER.DEV`), поэтому **JDK и Node — из WSL** (`JAVA.SETUP.2`, `NODE.SETUP.2`), а не
  Windows-версии через `cmd.exe`; те — только временно и с сообщением, чего не хватает.
- **WSL.SETUP.2** **Доступы сборки** (Artifactory/Nexus/npm registry) — в WSL-профиле: `~/.gradle/gradle.properties`,
  `~/.m2/settings.xml`, `~/.npmrc`. Секреты туда переносит пользователь сам (`SAFE.SECR.1`).
- **WSL.SETUP.3** На будущее: лучший вариант — репозитории в файловой системе Linux (`~/code/...`), а не на `/mnt/c`:
  нет CRLF и Windows-бинарников в `node_modules`, файловые операции в разы быстрее. IntelliJ открывает такие проекты
  через `\\wsl$\...` (или WSL-режим IDE).

## WSL.TRAP — грабли

- **WSL.TRAP.1** **WSL-симлинки на `/mnt/c` не видны Windows.**
  **Симптом:** `ln -s` из WSL на диске C: работает в WSL, а Windows-программа пишет «The file cannot be accessed by the
  system».
  **Причина:** WSL создаёт свой тип симлинка; настоящий NTFS-симлинк (`mklink`) требует прав администратора или
  Developer Mode.
  **Как правильно:** симлинки — только для того, что читается из WSL. Нужен Windows-программе — копия.
- **WSL.TRAP.2** **Переменная из `~/.bashrc` пустая в текущей сессии.**
  **Симптом:** токен дописан в `~/.bashrc`, а `echo "$VAR"` в открытом терминале / сессии ассистента пуст.
  **Причина:** `.bashrc` читается только при старте интерактивного шелла.
  **Как правильно:** в терминале — `source ~/.bashrc`; в сессии ассистента — `INTEG.ALL.4`.
- **WSL.TRAP.3** **WSL2 не видит `localhost` Windows.**
  **Симптом:** приложение запущено в Windows (IntelliJ, Docker Desktop), а из WSL `curl localhost:8080` → `Couldn't
  connect`; из Windows (`cmd.exe /c "curl …"`) — `200`.
  **Причина:** WSL2 по умолчанию в NAT-сети: `localhost` в WSL — сама VM.
  **Как правильно:** запросы — со стороны Windows (`cmd.exe /c "curl …"`, `cmd.exe /c "npm run …"`). Постоянно —
  `networkingMode=mirrored` в `%UserProfile%\.wslconfig` (меняет пользователь, нужен `wsl --shutdown`).
- **WSL.TRAP.4** **Docker Desktop в Windows, а из WSL Docker не виден.**
  **Симптом:** в WSL `docker info` → `dial unix /var/run/docker.sock: connect: no such file or directory`,
  Testcontainers не стартуют; `cmd.exe /c "docker info"` отвечает.
  **Причина:** в Docker Desktop не включена WSL-интеграция для этого дистрибутива.
  **Как правильно:** постоянно — Docker Desktop → Settings → Resources → WSL integration → включить свой дистрибутив
  → Apply & restart (включает пользователь), затем новый терминал. [Docker Desktop 4.95, WSL 3.0] После этого из WSL
  работают `docker`, `docker compose`, `docker exec` и Testcontainers — тот же движок и те же контейнеры, что в
  Windows. Apply & restart **останавливает контейнеры** (поднимутся только с `restart: always`) — после поднять
  `docker compose up -d`. Пока не включено — тесты Windows-сборкой через `cmd.exe` (`GRADL.TRAP.1`), `docker exec` —
  тоже через `cmd.exe`. Форматтер — всё равно Windows-сборкой (`WSL.TRAP.7`, дело в CRLF, а не в Docker).
- **WSL.TRAP.5** **Python `open()` на CRLF-файлах.**
  **Симптом:** после правки скриптом файл целиком «изменился» или сменились окончания строк.
  **Причина:** текстовый режим с universal newlines читает `\r\n` как `\n` и пишет `\n`.
  **Как правильно:** `'rb'`/`'wb'` и сохранять исходные окончания; после — `file <путь>` и `git diff --stat`.
- **WSL.TRAP.6** **`sed` на CRLF-файлах: смешанные окончания строк.**
  **Симптом:** после `sed -i 's/…/&\nновая строка/'` `file` показывает «with CRLF, LF line terminators».
  **Причина:** вставленный `\n` — голый LF.
  **Как правильно:** править Edit'ом (`SAFE.PERM.1`) или вставлять `\r\n`. Починить:
  `sed -i 's/\([^\r]\)$/\1\r/; s/^$/\r/' <файл>`, затем `file <файл>`.
- **WSL.TRAP.7** **Форматтер из WSL, проверка в Windows — «violations» на весь файл.**
  **Симптом:** после `spotlessApply` (или другого форматтера) в WSL сборка в Windows падает на проверке формата, дифф —
  весь файл.
  **Причина:** форматтер ставит окончания строк по git-атрибутам; WSL-git не видит `core.autocrlf=true` Windows-git'а и
  пишет LF, а Windows-сборка ждёт CRLF (`GIT.TRAP.1`).
  **Как правильно:** форматировать тем же окружением, в котором собираешь (`cmd.exe /c "… gradlew.bat spotlessApply"`).
  Проверка — `file <путь>`.
- **WSL.TRAP.8** **`sed -i` рвёт симлинк.**
  **Симптом:** после `sed -i … ~/.claude/CLAUDE.md` правка не попала в репозиторий, на который смотрел симлинк; сам
  `~/.claude/CLAUDE.md` теперь обычный файл и живёт отдельно.
  **Причина:** GNU `sed -i` пишет новый файл и подменяет им путь, не идя по ссылке (нужен `--follow-symlinks`).
  **Как правильно:** править Edit'ом (`SAFE.PERM.1`); после случайной подмены — сравнить с оригиналом и вернуть ссылку
  (`ln -s <оригинал> <путь>`).
- **WSL.TRAP.9** [WSL 3.0, Docker Desktop 4.95] **После обновления WSL Docker Desktop не стартует.**
  **Симптом:** `docker ps` (и из `cmd.exe`) → `Docker Desktop is unable to start`; `wsl -l -v` — `docker-desktop`
  `Stopped`.
  **Причина:** Docker Desktop держит свой WSL-дистрибутив; после обновления WSL он не поднялся сам.
  **Как правильно:** перезапустить Docker Desktop (Quit → запустить; 15.10.2026 помогло); не помогло — Troubleshoot →
  Restart, затем обновить Docker Desktop. `wsl --shutdown` рвёт сессию ассистента — делает пользователь сам. После
  обновления WSL проверить и остальное: `java -version`, `node -v`, `git`, симлинки `~/.claude`, сеть/VPN.
