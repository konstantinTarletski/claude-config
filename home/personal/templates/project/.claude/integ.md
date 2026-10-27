# INTEG — <проект>: внешние системы

Общие правила — `INTEG` в `~/.claude/personal/rules/integ.md`. Здесь — адреса, переменные, где создаётся токен.

- **INTEG.ALL.2** (дополняет) Токены проекта: трекер — `$<ФИРМА>_JIRA_TOKEN`, wiki — `$<ФИРМА>_CONFLUENCE_TOKEN`,
  git-сервер — `$<ФИРМА>_BITBUCKET_TOKEN`. <Заведены до правила с другими именами — пометка «(заменяет)» и как есть.>
- **INTEG.TRACK.101** Трекер — `<адрес>`, проект `<KEY>`; токен: <где в системе создать, права>.
  `~/.claude/personal/tools/jira.py <KEY> --url <адрес> --token-env <переменная>`
- **INTEG.WIKI.101** Wiki — `<адрес>`, пространство `<…>`; токен: <где создать>.
  `~/.claude/personal/tools/wiki.py <id> --url <адрес> --token-env <переменная>`
- **INTEG.GIT.101** Git-сервер — `<адрес>`, проект `<P>`, репозитории `<…>`; токен (только чтение): <где
  создать>. `~/.claude/personal/tools/bb-pr.py <P> <repo> <N> --url <адрес> --token-env <переменная>`
