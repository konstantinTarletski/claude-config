#!/usr/bin/env bash
# Разворачивает claude-config: симлинки в ~/.claude (CLAUDE.md, personal/, скиллы).
# Повторный запуск безопасен. Использование: ./install.sh [--dry-run]
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

run() { if $DRY_RUN; then echo "  [dry-run] $*"; else "$@"; fi; }

# link <источник в claude-config> <куда положить симлинк>
link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    if diff -rq "$src" "$dst" >/dev/null 2>&1; then
      echo "~ $dst (совпадает, заменяю симлинком)"
      run rm -rf "$dst"
    else
      local bak="$dst.bak-$(date +%Y%m%d%H%M%S)"
      echo "! $dst отличается — сохраняю как $bak"
      run mv "$dst" "$bak"
    fi
  else
    echo "+ $dst"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
}

echo "== ~/.claude"
link "$CONFIG_DIR/home/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
link "$CONFIG_DIR/home/personal" "$CLAUDE_HOME/personal"
for skill in "$CONFIG_DIR"/home/personal/skills/*/; do
  name="$(basename "$skill")"
  dst="$CLAUDE_HOME/skills/$name"
  [[ -L "$dst" ]] || { echo "+ $dst"; run mkdir -p "$CLAUDE_HOME/skills"; run ln -s "../personal/skills/$name" "$dst"; }
done

echo "Готово."
