#!/usr/bin/env bash
# Сколько тестов в JUnit XML-отчётах и насколько они свежие (GRADL.TRAP.3).
#
#   test-count.sh [папка ...]      по умолчанию: build/test-results/*  (Gradle); для Maven — target/surefire-reports
#
# По каждой папке: тестов, падений, ошибок, пропущено, время самого нового отчёта. Сравнить время со стартом сборки.
set -euo pipefail
dirs=("$@")
[[ ${#dirs[@]} -eq 0 ]] && dirs=(build/test-results/*)
for d in "${dirs[@]}"; do
  [[ -d "$d" ]] || { echo "$d: нет папки"; continue; }
  files=("$d"/TEST-*.xml)
  [[ -e "${files[0]}" ]] || { echo "$d: нет отчётов"; continue; }
  grep -ho '<testsuite [^>]*' "${files[@]}" | awk -v dir="$d" '
    { for (i = 1; i <= NF; i++) { split($i, kv, "="); gsub(/"/, "", kv[2]); v[kv[1]] += kv[2] } }
    END { printf "%s: тестов %d, падений %d, ошибок %d, пропущено %d", dir, v["tests"], v["failures"], v["errors"], v["skipped"] }'
  echo ", новейший отчёт $(ls -t "${files[@]}" | head -1 | xargs stat -c %y | cut -c1-19)"
done
