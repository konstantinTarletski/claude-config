# Грабли: git

Сломалось, не компилируется, не запускается. Общими словами, без проекта. Формат: симптом → причина → как правильно.

## WSL-git показывает изменёнными все файлы репозитория

**Симптом:** в WSL `git status` — сотни `M`, `git diff --stat` — «N insertions(+), N deletions(-)»
с равными числами; `git diff --ignore-cr-at-eol` пуст.
**Причина:** репозиторий выкачан Windows-git'ом с `core.autocrlf=true` (системный конфиг
`C:/Program Files/Git/etc/gitconfig`): в рабочей копии CRLF, в индексе LF. WSL-git этого
конфига не видит и сравнивает байты.
**Как правильно:** статус, дифф и коммит — Windows-git'ом: `cmd.exe /c "git status --short"`,
`cmd.exe /c "git diff --numstat"` или IDE. Проверить: `cmd.exe /c "git config --show-origin core.autocrlf"`.
Из WSL `git add -A` не делать — закоммитит CRLF во все файлы. Новые файлы можно писать с LF —
Windows-git при коммите нормализует (выдаст warning «LF will be replaced by CRLF» — это нормально).

## Git по HTTPS из WSL: «could not read Username»

**Симптом:** `git fetch` в WSL → `fatal: could not read Username for 'https://…'`.
**Причина:** учётные данные хранит только Windows-git (Credential Manager), WSL-git их не видит.
**Как правильно:** `fetch`/`pull`/`push` — Windows-git'ом (`cmd.exe /c "git fetch origin"`) или из IDE.
Без этого локальные `origin/*` в WSL могут быть устаревшими — учитывать, если на них завязан `ratchetFrom`
или сравнение веток.
