#!/usr/bin/env bash
# Run a command with a token from ~/.bashrc loaded into the environment (INTEG.ALL.1); the value is never printed.
# The session shell is not interactive, so variables from ~/.bashrc are empty there (WSL.TRAP.2).
#   with-token.sh <VAR> '<command using $VAR>'        - single quotes: $VAR is expanded inside, not by the caller
#   with-token.sh NORTAL_GITLAB_TOKEN 'curl -s -m 20 -H "PRIVATE-TOKEN: $NORTAL_GITLAB_TOKEN" https://gitlab.example.com/api/v4/user'
set -euo pipefail
var="${1:?usage: with-token.sh <VAR> '<command>'}"
cmd="${2:?usage: with-token.sh <VAR> '<command>'}"
if [ -z "${!var:-}" ]; then
  value="$(bash -ic "echo -n \"\$$var\"" 2>/dev/null)"
  [ -n "$value" ] || { echo "No token in $var (~/.bashrc, INTEG.ALL.3)" >&2; exit 1; }
  export "$var=$value"
fi
exec bash -c "$cmd"
