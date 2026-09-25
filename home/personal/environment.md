# Окружение: Java и Node — свои, из WSL

Работаем из WSL, поэтому **JDK и Node берём из WSL**, а не Windows-версии через `cmd.exe`.
Версии переключаем менеджерами:

| Что | Чем | Версия проекта |
|---|---|---|
| Java (+ при необходимости Gradle/Maven) | **sdkman** (`~/.sdkman`) | `sdk install java <ver>` / `sdk use java <ver>` |
| Node.js | **nvm** (`~/.nvm`) | `nvm install <ver>` / `nvm use <ver>` |

## Как определить нужную версию

Не угадывать — брать из проекта, по приоритету:
- Java: `sourceCompatibility` / `toolchain` в `build.gradle(.kts)` / `pom.xml`, базовый образ в
  `Dockerfile`, версия Gradle-wrapper (старый Gradle не запускается на новой Java).
- Node: `.nvmrc`, `engines` в `package.json`, базовый образ в `Dockerfile`, образ в CI; мажорная
  версия фреймворка (Angular/…) задаёт допустимый диапазон Node.

Нужной версии нет — поставить (`sdk install java 17.0.x-amzn`, `nvm install 18`) и сказать об этом.
Дистрибутив Java по умолчанию — тот же, что у команды/IDE (часто Corretto `-amzn` или Temurin `-tem`).

Закрепить версию локально: `.sdkmanrc` (`sdk env init`) и `.nvmrc` в корне репозитория — **в
`.gitignore`**, если в проекте их нет. Автопереключение по `cd` — `sdkman_auto_env=true` в
`~/.sdkman/etc/config`; для nvm — `nvm use` в начале команды.

## Что нужно, чтобы свои Java/Node работали на репозитории в `/mnt/c/...`

- **CRLF в скриптах** (`gradlew`, `mvnw`, `*.sh`): если репозиторий выкачан Windows-git'ом с
  `autocrlf=true` — локально, без коммита, прописать в `.git/info/attributes`:
  `gradlew text eol=lf` (и т.п.), затем пересоздать файл Windows-git'ом
  (`cmd.exe /c "git checkout -- gradlew"`). После этого `./gradlew` работает из WSL.
- **Доступы сборки** (Artifactory/Nexus/npm registry) — в WSL-профиле: `~/.gradle/gradle.properties`,
  `~/.m2/settings.xml`, `~/.npmrc`. Секреты туда переносит пользователь сам; ассистент их не читает
  и не печатает.
- **`node_modules`** должны быть установлены WSL-нодой (в Windows-установке — бинарники `win32-*`).
  Переустановка из WSL ломает сборку в Windows — делать с согласия пользователя.

## Запасной вариант

Windows-JDK / Windows-ноду через `cmd.exe` — только временно, пока окружение в WSL не готово, и с
явным сообщением пользователю, чего не хватает (версия в sdkman/nvm, доступы, CRLF). Конкретные
обходы — в `gotchas.md`.

## На будущее

Лучший вариант для WSL — держать репозитории в файловой системе Linux (`~/code/...`), а не на
`/mnt/c`: нет проблем с CRLF и Windows-бинарниками в `node_modules`, файловые операции в разы
быстрее. IntelliJ открывает такие проекты через `\\wsl$\...` (или WSL-режим IDE).
