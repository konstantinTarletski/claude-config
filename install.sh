#!/usr/bin/env bash
# Разворачивает claude-config: симлинки в ~/.claude (CLAUDE.md, personal/, скиллы, user.md — активный профиль,
# settings.json). Путь к репозиторию — ОДНА ссылка ~/.claude/claude-config, остальные — относительные через неё:
# переехал репозиторий — поменять только её (или ./install.sh из нового места).
# Личное (профили, фирмы, люди, проекты, интеграции, settings.json) — вне репозитория, в ~/.claude/private; это папка или
# ссылка на неё (WSL: --private /mnt/c/Users/<user>/.claude/private — те же файлы видны и из Windows).
# Windows: тот же скрипт из Git Bash — вместо симлинков junction, заглушки и жёсткая ссылка (см. WIN ниже).
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

# Windows (Git Bash): ln -s без админа или Developer Mode делает копию, а не ссылку → папка — junction (mklink /J),
# CLAUDE.md и user.md — заглушка с @-импортом, settings.json — жёсткая ссылка (mklink /H). Запуск тот же: ./install.sh.
WIN=false
case "$(uname -s)" in MINGW* | MSYS*) WIN=true; export MSYS_NO_PATHCONV=1 ;; esac
# symlink <цель, относительно папки ссылки или абсолютная> <ссылка>; в Windows — junction на ту же папку
symlink() {
  if $WIN; then
    local abs; abs="$(cd "$(dirname "$2")" && readlink -f "$1")"
    run cmd /c mklink /J "$(cygpath -w "$2")" "$(cygpath -w "$abs")" >/dev/null
  else
    run ln -sfn "$1" "$2"
  fi
}
# unlink_dst <ссылка> — убрать ссылку; junction — через rmdir (rm может пойти внутрь папки)
unlink_dst() { if $WIN && [[ -d "$1" ]]; then run cmd /c rmdir "$(cygpath -w "$1")"; else run rm "$1"; fi; }
# same <ссылка> <цель, относительно папки ссылки или абсолютная> — ссылка уже ведёт туда
same() { [[ -L "$1" && "$(readlink -f "$1")" == "$(cd "$(dirname "$1")" && readlink -f "$2")" ]]; }

# link <цель, относительно ~/.claude> <куда положить симлинк в ~/.claude>
link() {
  local src="$1" dst="$2"
  if same "$dst" "$src"; then
    return
  fi
  if [[ -L "$dst" ]]; then
    echo "~ $dst (ссылка — переставляю: $(readlink "$dst") -> $src)"
    unlink_dst "$dst"
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
  symlink "$src" "$dst"
}

echo "== ~/.claude"
if same "$HUB" "$CONFIG_DIR"; then
  echo "= $HUB -> $CONFIG_DIR"
elif [[ -e "$HUB" && ! -L "$HUB" ]]; then
  echo "! $HUB — не ссылка, разберись руками" >&2; exit 1
else
  echo "+ $HUB -> $CONFIG_DIR"
  [[ -L "$HUB" ]] && unlink_dst "$HUB"
  symlink "$CONFIG_DIR" "$HUB"
fi
# Свой локальный ~/.claude/CLAUDE.md (настройки этого компьютера), который подключает правила строкой
# @~/.claude/claude-config/home/CLAUDE.md, — не трогать.
if [[ -f "$CLAUDE_HOME/CLAUDE.md" && ! -L "$CLAUDE_HOME/CLAUDE.md" ]] &&
   grep -q '^@~/\.claude/claude-config/home/CLAUDE\.md' "$CLAUDE_HOME/CLAUDE.md"; then
  echo "= $CLAUDE_HOME/CLAUDE.md (локальный, подключает claude-config)"
elif $WIN; then
  if [[ -e "$CLAUDE_HOME/CLAUDE.md" ]]; then
    bak="$CLAUDE_HOME/CLAUDE.md.bak-$(date +%Y%m%d%H%M%S)"
    echo "! $CLAUDE_HOME/CLAUDE.md отличается — сохраняю как $bak"
    run mv "$CLAUDE_HOME/CLAUDE.md" "$bak"
  fi
  echo "+ $CLAUDE_HOME/CLAUDE.md (заглушка: @~/.claude/claude-config/home/CLAUDE.md)"
  $DRY_RUN || echo '@~/.claude/claude-config/home/CLAUDE.md' > "$CLAUDE_HOME/CLAUDE.md"
else
  link "claude-config/home/CLAUDE.md" "$CLAUDE_HOME/CLAUDE.md"
fi
link "claude-config/home/personal" "$CLAUDE_HOME/personal"
for skill in "$CONFIG_DIR"/home/personal/skills/*/; do
  name="$(basename "$skill")"
  dst="$CLAUDE_HOME/skills/$name"
  [[ -L "$dst" ]] || { echo "+ $dst"; run mkdir -p "$CLAUDE_HOME/skills"; symlink "../personal/skills/$name" "$dst"; }
done

# Личное (RULES.USER.1–2): ~/.claude/private — папка или ссылка (--private); в ней users/ и firms/.
echo "== личное"
PRIVATE="$CLAUDE_HOME/private"
if [[ -n "$PRIVATE_SRC" ]]; then
  [[ -d "$PRIVATE_SRC" ]] || { echo "+ $PRIVATE_SRC"; run mkdir -p "$PRIVATE_SRC/users" "$PRIVATE_SRC/firms"; }
  if same "$PRIVATE" "$PRIVATE_SRC"; then
    echo "= $PRIVATE -> $PRIVATE_SRC"
  elif [[ -e "$PRIVATE" && ! -L "$PRIVATE" ]]; then
    echo "! $PRIVATE — уже папка; перенеси её содержимое в $PRIVATE_SRC и убери, потом запусти снова" >&2; exit 1
  else
    echo "+ $PRIVATE -> $PRIVATE_SRC"
    [[ -L "$PRIVATE" ]] && unlink_dst "$PRIVATE"
    symlink "$PRIVATE_SRC" "$PRIVATE"
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
# Windows: user.md — заглушка со строкой @~/.claude/private/users/<профиль>.md → имя профиля из неё
stub_profile() { sed -n 's#^@~/\.claude/private/users/\(.*\)\.md$#\1#p' "$USER_LINK" 2>/dev/null | head -1; }
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
elif $WIN && [[ -n "$(stub_profile)" ]]; then
  echo "= $USER_LINK (заглушка) -> private/users/$(stub_profile).md"
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
  if [[ -e "$USER_LINK" && ! -L "$USER_LINK" && -z "$(stub_profile)" ]]; then
    bak="$USER_LINK.bak-$(date +%Y%m%d%H%M%S)"
    echo "! $USER_LINK — обычный файл, сохраняю как $bak"
    run mv "$USER_LINK" "$bak"
  fi
  echo "+ $USER_LINK -> private/users/$choice.md"
  if $WIN; then
    $DRY_RUN || echo "@~/.claude/private/users/$choice.md" > "$USER_LINK"
  else
    run ln -sfn "private/users/$choice.md" "$USER_LINK"
  fi
fi
prof="$choice"
[[ -z "$prof" && -L "$USER_LINK" ]] && prof="$(basename "$(readlink "$USER_LINK")" .md)"
[[ -z "$prof" ]] && prof="$(stub_profile)"

# Настройки Claude Code: ~/.claude/settings.json -> users/<профиль>.settings.json (рядом с профилем, не в git).
# Windows — жёсткая ссылка (тот же файл под двумя именами). Claude Code может переписать ссылку обычным файлом
# (/config, /model) — тогда сказать, ничего не теряя.
echo "== settings.json"
SETTINGS_LINK="$CLAUDE_HOME/settings.json"
if [[ -n "$prof" ]]; then
  src="$USERS_DIR/$prof.settings.json"
  rel="private/users/$prof.settings.json"
  if [[ ! -f "$src" ]]; then
    echo "! нет $src — скопируй шаблон $CONFIG_DIR/home/personal/templates/settings.json (или свой ~/.claude/settings.json),"
    echo "  подставь пути и токены и запусти снова"
  elif [[ -L "$SETTINGS_LINK" && "$(readlink "$SETTINGS_LINK")" == "$rel" ]] || { $WIN && [[ "$SETTINGS_LINK" -ef "$src" ]]; }; then
    echo "= $SETTINGS_LINK -> $rel"
  elif [[ -L "$SETTINGS_LINK" || ! -e "$SETTINGS_LINK" ]] || cmp -s "$src" "$SETTINGS_LINK"; then
    echo "+ $SETTINGS_LINK -> $rel"
    if $WIN; then
      [[ -e "$SETTINGS_LINK" ]] && run rm "$SETTINGS_LINK"
      run cmd /c mklink /H "$(cygpath -w "$SETTINGS_LINK")" "$(cygpath -w "$src")" >/dev/null
    else
      run ln -sfn "$rel" "$SETTINGS_LINK"
    fi
  else
    echo "! $SETTINGS_LINK — обычный файл и отличается от users/$prof.settings.json (Claude Code переписал ссылку?)."
    echo "  Сравни: diff $SETTINGS_LINK $src — нужное перенеси в $src, потом: rm $SETTINGS_LINK && ./install.sh"
  fi
fi

# Файл фирмы (RULES.USER.2): профиль подключает его строкой @~/.claude/private/firms/<фирма>.md — есть ли он.
echo "== фирма"
PROFILE_FILE="$USER_LINK"
[[ -n "$(stub_profile)" ]] && PROFILE_FILE="$USERS_DIR/$(stub_profile).md"
if [[ -f "$PROFILE_FILE" ]]; then
  firm_refs="$(grep -o '^@~/\.claude/private/firms/[^ ]*\.md' "$PROFILE_FILE" || true)"
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

# Люди, проекты, интеграции (RULES.USER.2, с 3.2): профиль подключает их строками @~/.claude/private/<файл>.md.
echo "== люди, проекты, интеграции"
if [[ -f "$PROFILE_FILE" ]]; then
  for name in people projects integrations; do
    f="$PRIVATE/$name.md"
    if ! grep -q "^@~/\.claude/private/$name\.md" "$PROFILE_FILE"; then
      echo "! в профиле нет строки @~/.claude/private/$name.md — переезд: $CONFIG_DIR/home/personal/skills/rules/v3.1-to-v3.2.md"
    elif [[ -f "$f" ]]; then echo "= $f"
    else echo "! нет $f — скопируй шаблон $CONFIG_DIR/home/personal/templates/$name.md и заполни"; fi
  done
fi

echo "Готово."
