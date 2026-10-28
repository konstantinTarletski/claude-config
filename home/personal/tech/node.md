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
