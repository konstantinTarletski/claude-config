#!/usr/bin/env bash
# Разворачивает claude-config: симлинки в ~/.claude (CLAUDE.md, personal/, скиллы, user.md — активный профиль,
# settings.json). Путь к репозиторию — ОДНА ссылка ~/.claude/claude-config, остальные — относительные через неё:
# переехал репозиторий — поменять только её (или ./install.sh из нового места).
# Личное (профили, файлы фирм, settings.json) — вне репозитория, в ~/.claude/private/{users,firms}; это папка или
# ссылка на неё (WSL: --private /mnt/c/Users/<user>/.claude/private — те же файлы видны и из Windows).
# Повторный запуск безопасен. Использование: ./install.sh [--dry-run] [--profile <имя>_<фирма>] [--private <папка>]
#   [--migrate] — переход с 2.x: скопировать профили и фирмы из home/personal/{users,firms} в ~/.claude/private.
set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
HUB="$CLAUDE_HOME/claude-config"
DRY_RUN=false
PROFILE=""
PRIVATE_SRC=""
MIGRATE=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --profile) PROFILE="${2:-}"; shift ;;
    --private) PRIVATE_SRC="${2:-}"; shift ;;
    --migrate) MIGRATE=true ;;
    *) echo "Неизвестный параметр: $1" >&2; exit 1 ;;
  esac
  shift
done

run() { if $DRY_RUN; then echo "  [dry-run] $*"; else "$@"; fi; }

# link <цель, относительно ~/.claude> <куда положить симлинк в ~/.claude>
link() {
  local src="$1" dst="$2"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    return
  fi
  if [[ -L "$dst" ]]; then
    echo "~ $dst (ссылка — переставляю: $(readlink "$dst") -> $src)"
    run rm "$dst"
  elif [[ -e "$dst" ]]; then
    if diff -rq "$CLAUDE_HOME/$src" "$dst" >/dev/null 2>&1; then
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
if [[ -L "$HUB" && "$(readlink "$HUB")" == "$CONFIG_DIR" ]]; then
  echo "= $HUB -> $CONFIG_DIR"
elif [[ -e "$HUB" && ! -L "$HUB" ]]; then
  echo "! $HUB — не ссылка, разберись руками" >&2; exit 1
else
  echo "+ $HUB -> $CONFIG_DIR"
  run ln -sfn "$CONFIG_DIR" "$HUB"
fi
# Свой локальный ~/.claude/CLAUDE.md (настройки этого компьютера), который подключает правила строкой
# @~/.claude/claude-config/home/CLAUDE.md, — не трогать.
if [[ -f "$CLAUDE_HOME/CLAUDE.md" && ! -L "$CLAUDE_HOME/CLAUDE.md" ]] &&
   grep -q '^@~/\.claude/claude-config/home/CLAUDE\.md' "$CLAUDE_HOME/CLAUDE.md"; then
  echo "= $CLAUDE_HOME/CLAUDE.md (локальный, подключает claude-config)"
else
  link "claude-config/home/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
fi
link "claude-config/home/personal" "$CLAUDE_HOME/personal"
for skill in "$CONFIG_DIR"/home/personal/skills/*/; do
  name="$(basename "$skill")"
  dst="$CLAUDE_HOME/skills/$name"
  [[ -L "$dst" ]] || { echo "+ $dst"; run mkdir -p "$CLAUDE_HOME/skills"; run ln -s "../personal/skills/$name" "$dst"; }
done

# Личное (RULES.USER.1–2): ~/.claude/private — папка или ссылка (--private); в ней users/ и firms/.
echo "== личное"
PRIVATE="$CLAUDE_HOME/private"
if [[ -n "$PRIVATE_SRC" ]]; then
  [[ -d "$PRIVATE_SRC" ]] || { echo "+ $PRIVATE_SRC"; run mkdir -p "$PRIVATE_SRC/users" "$PRIVATE_SRC/firms"; }
  if [[ -L "$PRIVATE" && "$(readlink "$PRIVATE")" == "$PRIVATE_SRC" ]]; then
    echo "= $PRIVATE -> $PRIVATE_SRC"
  elif [[ -e "$PRIVATE" && ! -L "$PRIVATE" ]]; then
    echo "! $PRIVATE — уже папка; перенеси её содержимое в $PRIVATE_SRC и убери, потом запусти снова" >&2; exit 1
  else
    echo "+ $PRIVATE -> $PRIVATE_SRC"
    run ln -sfn "$PRIVATE_SRC" "$PRIVATE"
  fi
elif [[ -L "$PRIVATE" ]]; then
  echo "= $PRIVATE -> $(readlink "$PRIVATE")"
elif [[ -d "$PRIVATE" ]]; then
  echo "= $PRIVATE"
else
  echo "+ $PRIVATE"
  run mkdir -p "$PRIVATE/users" "$PRIVATE/firms"
fi
# До 3.0 профили и фирмы лежали в репозитории: --migrate копирует их сюда (оригиналы не трогает, своё не затирает).
OLD="$CONFIG_DIR/home/personal"
if ls "$OLD"/users/* "$OLD"/firms/* >/dev/null 2>&1; then
  if $MIGRATE; then
    for d in users firms; do
      for f in "$OLD/$d"/*; do
        [[ -f "$f" ]] || continue
        if [[ -e "$PRIVATE/$d/$(basename "$f")" ]]; then echo "= $PRIVATE/$d/$(basename "$f") (уже есть, не трогаю)"
        else echo "+ $PRIVATE/$d/$(basename "$f")"; run mkdir -p "$PRIVATE/$d"; run cp -p "$f" "$PRIVATE/$d/"
          # строка подключения фирмы в профиле: @~/.claude/personal/firms/ -> @~/.claude/private/firms/
          [[ "$d" == users && "$f" == *.md ]] &&
            run sed -i 's#^@~/\.claude/personal/firms/#@~/.claude/private/firms/#' "$PRIVATE/$d/$(basename "$f")"
        fi
      done
    done
    echo "  Проверь, что всё на месте, потом удали старое: rm -r $OLD/users $OLD/firms"
  else
    echo "! в репозитории остались профили или фирмы (до 3.0) — скопировать их в $PRIVATE: ./install.sh --migrate"
  fi
fi

# Профиль (RULES.USER.1): ~/.claude/user.md -> private/users/<имя>_<фирма>.md.
# Уже выбран и файл есть — не трогать; --profile — взять его; один профиль — взять молча; несколько — спросить.
echo "== профиль"
USERS_DIR="$PRIVATE/users"
USER_LINK="$CLAUDE_HOME/user.md"
mapfile -t profiles < <(ls "$USERS_DIR"/*.md 2>/dev/null | xargs -r -n1 basename | sed 's/\.md$//')
choice=""
if [[ -n "$PROFILE" ]]; then
  [[ -f "$USERS_DIR/$PROFILE.md" ]] || { echo "! нет профиля $USERS_DIR/$PROFILE.md" >&2; exit 1; }
  choice="$PROFILE"
elif [[ -L "$USER_LINK" && "$(readlink "$USER_LINK")" == personal/users/* ]]; then
  # профиль до 3.0 — переставить на private, если он туда уже скопирован (--migrate)
  old_prof="$(basename "$(readlink "$USER_LINK")" .md)"
  if [[ -f "$USERS_DIR/$old_prof.md" ]] || $DRY_RUN; then choice="$old_prof"
  else echo "! $USER_LINK -> $(readlink "$USER_LINK") (до 3.0) — сначала ./install.sh --migrate"; fi
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
  echo "+ $USER_LINK -> private/users/$choice.md"
  run ln -sfn "private/users/$choice.md" "$USER_LINK"
fi

# Настройки Claude Code: ~/.claude/settings.json -> users/<профиль>.settings.json (рядом с профилем, не в git).
# Claude Code может переписать симлинк обычным файлом (/config, /model) — тогда сказать, ничего не теряя.
echo "== settings.json"
SETTINGS_LINK="$CLAUDE_HOME/settings.json"
if [[ -L "$USER_LINK" ]]; then
  prof="$(basename "$(readlink "$USER_LINK")" .md)"
  [[ -n "$choice" ]] && prof="$choice"
  src="$USERS_DIR/$prof.settings.json"
  rel="private/users/$prof.settings.json"
  if [[ ! -f "$src" ]]; then
    echo "! нет $src — скопируй шаблон $CONFIG_DIR/home/personal/templates/settings.json (или свой ~/.claude/settings.json),"
    echo "  подставь пути и токены и запусти снова"
  elif [[ -L "$SETTINGS_LINK" && "$(readlink "$SETTINGS_LINK")" == "$rel" ]]; then
    echo "= $SETTINGS_LINK -> $rel"
  elif [[ -L "$SETTINGS_LINK" || ! -e "$SETTINGS_LINK" ]] || cmp -s "$src" "$SETTINGS_LINK"; then
    echo "+ $SETTINGS_LINK -> $rel"
    run ln -sfn "$rel" "$SETTINGS_LINK"
  else
    echo "! $SETTINGS_LINK — обычный файл и отличается от users/$prof.settings.json (Claude Code переписал ссылку?)."
    echo "  Сравни: diff $SETTINGS_LINK $src — нужное перенеси в $src, потом: rm $SETTINGS_LINK && ./install.sh"
  fi
fi

# Файл фирмы (RULES.USER.2): профиль подключает его строкой @~/.claude/private/firms/<фирма>.md — есть ли он.
echo "== фирма"
if [[ -f "$USER_LINK" ]]; then
  firm_refs="$(grep -o '^@~/\.claude/private/firms/[^ ]*\.md' "$USER_LINK" || true)"
  if [[ -z "$firm_refs" ]]; then
    echo "! в профиле нет строки @~/.claude/private/firms/<фирма>.md — создай файл фирмы по"
    echo "  $CONFIG_DIR/home/personal/templates/firm.md и подключи его в профиле"
  fi
  for ref in $firm_refs; do
    f="$PRIVATE/${ref#@~/.claude/private/}"
    if [[ -f "$f" ]]; then echo "= $f"
    else echo "! нет $f — скопируй шаблон $CONFIG_DIR/home/personal/templates/firm.md и заполни"; fi
  done
fi

echo "Готово."
