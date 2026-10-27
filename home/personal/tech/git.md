# GIT — git

- **GIT.TRAP.1** В WSL `git status` — сотни `M`, `diff --stat` с равными «+» и «−», `diff --ignore-cr-at-eol` пуст →
  выкачан Windows-git'ом с `core.autocrlf=true` (его системный конфиг WSL-git не видит) → статус, дифф, коммит —
  Windows-git'ом (`cmd.exe /c "git status --short"`) или IDE; из WSL `git add -A` не делать. Новые файлы с LF — можно.
- **GIT.TRAP.2** `git fetch` в WSL → «could not read Username» → учётные данные только у Windows-git →
  `cmd.exe /c "git fetch origin"` или IDE; без этого локальные `origin/*` в WSL устаревают.
- **GIT.TRAP.3** `cmd.exe /c "git commit -m \"…\""` с кириллицей или тире → «pathspec … did not match» → `cmd` режет
  сообщение → файлом: `printf '%s\n' "<сообщение>" > .git/MSG_TMP` → `cmd.exe /c "git commit -F .git/MSG_TMP"` →
  удалить файл. Так же `git tag -a -F`.
- **GIT.TRAP.4** [git 2.43] Личный игнорируемый файл пропал или стал старым после `switch` / `checkout` / `merge` →
  в той ветке путь ещё отслеживался, git молча перезаписал и потом удалил его (так 21.10.2026 стёрся профиль) → перед
  переключением проверить `git ls-tree -r <ветка> --name-only | grep <путь>` и снять копию вне репозитория; слить без
  переключения — `git fetch . <ветка>:main`.
