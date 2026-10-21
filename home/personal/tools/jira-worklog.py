#!/usr/bin/env python3
"""Часы из журнала (/timelog-askend) — в worklog Jira, один в один: тот же день, те же часы, тот же текст.

  jira-worklog.py <ДД.ММ> [<ДД.ММ> …] --journal <файл> --ours <наша задача> --side client|ours
                  --url <https://jira…> --token-env <ПЕРЕМЕННАЯ> --zone <Europe/…> [--email <e-mail>]
                  [--year 2026] [--post]

Строки журнала: «<наша задача>/<задача клиента> -- <часы у нас>/<часы у клиента>» и под ними «- пункт».
--ours     какие строки брать (наша задача до «/», например DIRE-7)
--side     client — задача после «/» и часы у клиента; ours — задача до «/» и часы у нас
--zone     часовой пояс начала записи (00:00 местного времени)
--email    Jira Cloud (Atlassian): Basic e-mail + API token; без него — Bearer (Jira Server / Data Center)
--post     записать; без него — только показать, что будет записано и что уже есть (ничего не меняет)
Перед записью — проверка, что моих записей за этот день в задаче нет (не задваивать); после — перечитать и сверить.
Токен — из переменной окружения (INTEG.ALL); запись — только по разрешению пользователя (INTEG.ALL.1).
"""
import argparse
import base64
import json
import os
import re
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime
from zoneinfo import ZoneInfo

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _http import token  # noqa: E402

p = argparse.ArgumentParser()
p.add_argument('days', nargs='+')
p.add_argument('--journal', required=True)
p.add_argument('--ours', required=True)
p.add_argument('--side', choices=['client', 'ours'], required=True)
p.add_argument('--url', required=True)
p.add_argument('--token-env', required=True)
p.add_argument('--zone', required=True)
p.add_argument('--email')
p.add_argument('--year', type=int, default=datetime.now().year)
p.add_argument('--post', action='store_true')
a = p.parse_args()

API = a.url.rstrip('/') + '/rest/api/2'
secret = token(a.token_env)
auth = ('Basic ' + base64.b64encode(f'{a.email}:{secret}'.encode()).decode()) if a.email else ('Bearer ' + secret)
HDR = {'Authorization': auth, 'Accept': 'application/json', 'Content-Type': 'application/json; charset=utf-8'}


def call(method, path, body=None):
    req = urllib.request.Request(API + path, data=json.dumps(body).encode('utf-8') if body else None, headers=HDR,
                                 method=method)
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.loads(r.read().decode('utf-8'))
    except urllib.error.HTTPError as e:
        sys.exit(f'HTTP {e.code} {method} {path}: {e.read().decode("utf-8", "replace")[:300]}')
    except (urllib.error.URLError, TimeoutError) as e:
        sys.exit(f'⚠ {a.url} недоступен ({e}) — похоже, слетел VPN (INTEG.ALL.5)')


def entries(lines, day):
    """Строки «<ours>/<KEY> -- x/y» дня и их пункты «- …»."""
    if day not in lines:
        sys.exit(f'В журнале нет дня {day}')
    out, cur = [], None
    for line in lines[lines.index(day) + 1:]:
        if re.fullmatch(r'\d{2}\.\d{2}', line.strip()):
            break
        m = re.match(r'^(\S+)/(\S+)\s+--\s+([\d.]+)/([\d.]+)', line)
        if m and m.group(1) == a.ours:
            key, hours = (m.group(2), float(m.group(4))) if a.side == 'client' else (m.group(1), float(m.group(3)))
            cur = {'key': key, 'hours': hours, 'lines': []}
            out.append(cur)
        elif re.match(r'^\S', line):
            cur = None
        elif cur is not None and line.strip().startswith('- '):
            cur['lines'].append(line.strip())
    return out


def norm(text):
    """Текст для сверки: без пробелов по краям строк и \\r (руками вставленный текст отличается только этим)."""
    return '\n'.join(line.strip() for line in str(text or '').replace('\r\n', '\n').strip().split('\n'))


def mine(key, date, me):
    return [w for w in call('GET', f'/issue/{key}/worklog')['worklogs']
            if w['started'][:10] == date and me in (w['author'].get('accountId'), w['author'].get('name'))]


journal = open(a.journal, encoding='utf-8').read().replace('\r\n', '\n').split('\n')
myself = call('GET', '/myself')
me = myself.get('accountId') or myself.get('name')

for day in a.days:
    dd, mm = day.split('.')
    start = datetime(a.year, int(mm), int(dd), tzinfo=ZoneInfo(a.zone))
    date = start.strftime('%Y-%m-%d')
    for e in entries(journal, day):
        body = {'started': start.strftime('%Y-%m-%dT%H:%M:%S.000%z'), 'timeSpentSeconds': round(e['hours'] * 3600),
                'comment': '\n'.join(e['lines'])}
        have = mine(e['key'], date, me)
        head = f"{day} {e['key']} {e['hours']:g}h {len(e['lines'])} п."
        if have:
            same = len(have) == 1 and have[0]['timeSpentSeconds'] == body['timeSpentSeconds'] \
                and norm(have[0].get('comment')) == norm(body['comment'])
            print(head, '— уже есть,', 'совпадает с журналом' if same else 'РАСХОДИТСЯ с журналом:',
                  '' if same else [(w['id'], w['timeSpent']) for w in have])
            continue
        if not a.post:
            print(head, '— будет записано:')
            print('   ' + body['comment'].replace('\n', '\n   '))
            continue
        new_id = call('POST', f"/issue/{e['key']}/worklog", body)['id']
        back = [w for w in mine(e['key'], date, me) if w['id'] == new_id]
        same_text = bool(back) and norm(back[0].get('comment')) == norm(body['comment'])
        ok = bool(back) and back[0]['timeSpentSeconds'] == body['timeSpentSeconds'] and same_text
        print(head, f'записано id={new_id}', 'СОВПАДАЕТ' if ok else 'НЕ СОВПАДАЕТ — проверить')
    # Обратная сверка: мои записи в Jira за этот день в задачах, которых нет в журнале. В нашей Jira — только проект
    # нашей задачи (там и другие клиенты).
    jql = f'worklogAuthor = currentUser() AND worklogDate = "{date}"'
    if a.side == 'ours':
        jql += f' AND project = {a.ours.split("-")[0]}'
    keys = {i['key'] for i in call('GET', '/search?' + urllib.parse.urlencode({'jql': jql, 'fields': 'key'}))['issues']}
    for extra in sorted(keys - {e['key'] for e in entries(journal, day)}):
        print(day, extra, '— ЕСТЬ В JIRA, НЕТ В ЖУРНАЛЕ:', [(w['id'], w['timeSpent']) for w in mine(extra, date, me)])
