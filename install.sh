#!/usr/bin/env bash
# Разворачивает claude-config: симлинки в ~/.claude (CLAUDE.md, personal/, скиллы, user.md — активный профиль).
# Повторный запуск безопасен. Использование: ./install.sh [--dry-run] [--profile <имя>_<фирма>]
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
DRY_RUN=false
PROFILE=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --profile) PROFILE="${2:-}"; shift ;;
    *) echo "Неизвестный параметр: $1" >&2; exit 1 ;;
  esac
  shift
done

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

# Профиль (RULES.USER.1): ~/.claude/user.md -> personal/users/<имя>_<фирма>.md.
# Уже выбран и файл есть — не трогать; --profile — взять его; один профиль — взять молча; несколько — спросить.
echo "== профиль"
USERS_DIR="$CONFIG_DIR/home/personal/users"
USER_LINK="$CLAUDE_HOME/user.md"
mapfile -t profiles < <(ls "$USERS_DIR"/*.md 2>/dev/null | xargs -r -n1 basename | sed 's/\.md$//')
choice=""
if [[ -n "$PROFILE" ]]; then
  [[ -f "$USERS_DIR/$PROFILE.md" ]] || { echo "! нет профиля $USERS_DIR/$PROFILE.md" >&2; exit 1; }
  choice="$PROFILE"
elif [[ -L "$USER_LINK" && -f "$USER_LINK" ]]; then
  echo "= $USER_LINK -> $(readlink "$USER_LINK")"
elif [[ ${#profiles[@]} -eq 0 ]]; then
  echo "! профилей нет: скопируй $CONFIG_DIR/home/personal/templates/user.md в $USERS_DIR/$(whoami)_<фирма>.md,"
  echo "  заполни и запусти снова (профиль не в git — RULES.USER.1)"
elif [[ ${#profiles[@]} -eq 1 && "${profiles[0]}" == "$(whoami)_"* ]]; then
  choice="${profiles[0]}"
elif [[ ${#profiles[@]} -eq 1 ]]; then
  # Единственный профиль — не по логину: скорее всего чужой. Сказать, что он есть, и не брать молча.
  echo "! есть профиль ${profiles[0]} — он не по твоему логину ($(whoami)), похоже, чужой."
  echo "  Свой: скопируй шаблон $CONFIG_DIR/home/personal/templates/user.md в $USERS_DIR/$(whoami)_<фирма>.md,"
  echo "  заполни и запусти снова."
  echo "  Всё-таки этот: ./install.sh --profile ${profiles[0]}"
elif [[ -t 0 ]] && ! $DRY_RUN; then
  echo "С каким профилем работаем на этой машине?"
  select p in "${profiles[@]}"; do [[ -n "$p" ]] && { choice="$p"; break; }; done
else
  echo "! профилей несколько (${profiles[*]}) — запусти с --profile <имя>"
fi
if [[ -n "$choice" ]]; then
  if [[ -e "$USER_LINK" && ! -L "$USER_LINK" ]]; then
    bak="$USER_LINK.bak-$(date +%Y%m%d%H%M%S)"
    echo "! $USER_LINK — обычный файл, сохраняю как $bak"
    run mv "$USER_LINK" "$bak"
  fi
  echo "+ $USER_LINK -> users/$choice.md"
  run ln -sfn "$USERS_DIR/$choice.md" "$USER_LINK"
fi

# Файл фирмы (RULES.USER.2): профиль подключает его строкой @~/.claude/personal/firms/<фирма>.md — есть ли он.
echo "== фирма"
if [[ -f "$USER_LINK" ]]; then
  firm_refs="$(grep -o '^@~/\.claude/personal/firms/[^ ]*\.md' "$USER_LINK" || true)"
  if [[ -z "$firm_refs" ]]; then
    echo "! в профиле нет строки @~/.claude/personal/firms/<фирма>.md — создай файл фирмы по"
    echo "  $CONFIG_DIR/home/personal/templates/firm.md и подключи его в профиле"
  fi
  for ref in $firm_refs; do
    f="$CONFIG_DIR/home/personal/${ref#@~/.claude/personal/}"
    if [[ -f "$f" ]]; then echo "= $f"
    else echo "! нет $f — скопируй шаблон $CONFIG_DIR/home/personal/templates/firm.md и заполни"; fi
  done
fi

echo "Готово."
