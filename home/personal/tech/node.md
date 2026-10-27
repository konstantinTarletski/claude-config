# NODE — Node.js и npm

Angular — `tech/ng.md`; WSL — `tech/wsl.md`.

- **NODE.SETUP.1** Версия Node → из проекта: `.nvmrc`, `engines`, образ в `Dockerfile` или CI; мажорная версия
  фреймворка задаёт диапазон.
- **NODE.SETUP.2** Node → через nvm в том окружении, где запускаем (что стоит — `USER.DEV.3`): `nvm install <ver>` /
  `nvm use <ver>`. Закрепить → `.nvmrc` (нет в git проекта — скрыть через `.git/info/exclude`).
- **NODE.SETUP.3** `node_modules` → ставить той же Node, что запускает (WSL или Windows). Переустановка ломает сборку в
  другом окружении → только с моего согласия.
- **NODE.TRAP.1** В WSL `npm run build` / `vitest` падают на всех файлах (`Failed to resolve import "@core/…"`) →
  `node_modules` ставились Windows-Node (`@esbuild/win32-x64`) → запускать Windows-Node: `cmd.exe /c "cd /d C:\… && npm
  test"`; не переустанавливать без спроса.
- **NODE.TRAP.2** `curl` к внутреннему реестру — 200, а `npm` — `SELF_SIGNED_CERT_IN_CHAIN` → Node не видит системные CA
  Linux → `export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt` в `~/.bashrc`; `strict-ssl=false` — нельзя.
- **NODE.TRAP.4** После смены ветки `ng build` / `tsc` — «Could not find builder», сотни «Cannot find module» →
  `node_modules` от другой мажорной версии → `npm ci` на нужной ветке (только с согласия); без этого — `tsc --noEmit` и
  ошибки по своим файлам.
- **NODE.TRAP.5** `npx prettier --check` ругается на файлы с правкой в 1–2 строки → prettier не в `devDependencies`,
  `npx` берёт свежую версию → не прогонять по чужим файлам; новые — `--write`, в изменённых — стиль соседнего кода.
