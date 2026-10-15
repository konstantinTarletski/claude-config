# NODE — Node.js и npm

Angular — `tech/ng.md`; WSL — `tech/wsl.md`.

## NODE.SETUP — установка

- **NODE.SETUP.1** Версию **не угадывать — брать из проекта**, по приоритету: `.nvmrc`, `engines` в `package.json`,
  базовый образ в `Dockerfile`, образ в CI; мажорная версия фреймворка (Angular/…) задаёт допустимый диапазон Node.
- **NODE.SETUP.2** Работаем из WSL (`USER.SYS.1`, что стоит — `USER.DEV.3`) — **Node из WSL через nvm** (`~/.nvm`): `nvm install <ver>` / `nvm use <ver>`
  (в начале команды, если нет автопереключения). Закрепить — `.nvmrc` в корне; если его нет в git проекта — скрыть
  через `.git/info/exclude`, если есть — пользоваться им.
- **NODE.SETUP.3** `node_modules` должны быть установлены **WSL-нодой** (в Windows-установке — бинарники `win32-*`,
  `NODE.TRAP.1`). Переустановка из WSL ломает сборку в Windows — только с моего согласия (`USER.PERM.2`).

## NODE.TRAP — грабли

- **NODE.TRAP.1** **WSL + `node_modules`, установленные из Windows.**
  **Симптом:** в WSL `npx vitest` / `npm run build` падают на всех файлах, например `Failed to resolve import
  "@core/..."`, хотя код в порядке.
  **Причина:** репозиторий на `/mnt/c/...`, зависимости ставились Windows-нодой — в `node_modules` нативные бинарники
  под Windows (`@esbuild/win32-x64`, `@rollup/rollup-win32-*`), алиасы из `tsconfig` резолвятся не так.
  **Как правильно:** проверить `ls node_modules/@esbuild`; если `win32-*` — запускать через Windows-ноду:
  `cmd.exe /c "cd /d C:\path\to\repo && npm test"`. Не переустанавливать без спроса.
- **NODE.TRAP.2** **npm из WSL: `SELF_SIGNED_CERT_IN_CHAIN` на внутреннем реестре.**
  **Симптом:** `curl https://<внутренний-реестр>` — 200, а `npm view` / `npm ci` — `self-signed certificate in
  certificate chain`.
  **Причина:** корпоративный CA добавлен в системное хранилище Linux (`/usr/local/share/ca-certificates`), а Node
  использует свой встроенный набор CA.
  **Как правильно:** `export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt` в `~/.bashrc`. Не отключать
  проверку (`strict-ssl=false`).
- **NODE.TRAP.3** **`npm ci`: «package.json and package-lock.json … are in sync».**
  **Симптом:** `npm ci` сразу падает с `EUSAGE … Missing: <pkg> from lock file`.
  **Причина:** lock-файл не соответствует `package.json` — часто это незакоммиченные правки пользователя в
  `package-lock.json`.
  **Как правильно:** `npm ci` в этом случае ничего не удаляет — старые `node_modules` целы. Сначала `git status`;
  lock-файл пользователя не перегенерировать (`npm install`) без спроса.
- **NODE.TRAP.4** **`node_modules` от другой ветки.**
  **Симптом:** `ng build` → «Could not find the '@angular-devkit/build-angular:browser' builder», `tsc` → сотни «Cannot
  find module '@angular/...'», хотя код в порядке.
  **Причина:** переключились на ветку с другой мажорной версией фреймворка, а `node_modules` остались от прежней
  (сравнить `package.json` и `node_modules/<пакет>/package.json` → `version`).
  **Как правильно:** `npm ci` на нужной ветке — но это заменит зависимости для другой ветки, поэтому только с
  согласия. Без переустановки — хотя бы `tsc --noEmit` и отфильтровать ошибки по изменённым файлам.
- **NODE.TRAP.5** **Форматтер не в зависимостях проекта: `npx` берёт последнюю версию.**
  **Симптом:** `npx prettier --check` ругается даже на файлы, где изменены 1–2 строки.
  **Причина:** пакета нет в `devDependencies`, `npx` скачивает свежую версию, а код под неё не отформатирован
  (форматировал плагин редактора со своими настройками).
  **Как правильно:** не прогонять по чужим файлам. Новые файлы — `--write` целиком, в изменённых — вручную держать
  стиль соседнего кода.
