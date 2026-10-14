#!/usr/bin/env python3
"""PR в Bitbucket Server коротким текстом: статус, ветки, ревьюеры, сборка, комментарии (с файлом и строкой).

  bb-pr.py <PROJECT> <REPO> <N> --url <https://bitbucket…> --token-env <ИМЯ>

Токен — только на чтение (INTEG.ALL); адрес и имя переменной — INTEG.GIT проекта.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _http import get, token  # noqa: E402

p = argparse.ArgumentParser()
p.add_argument('project')
p.add_argument('repo')
p.add_argument('n')
p.add_argument('--url', required=True)
p.add_argument('--token-env', required=True)
a = p.parse_args()

base = a.url.rstrip('/')
t = token(a.token_env)
pr_url = f'{base}/rest/api/1.0/projects/{a.project}/repos/{a.repo}/pull-requests/{a.n}'
pr = get(pr_url, t)

print(f"PR #{pr['id']} {pr['state']} | {pr['title']}")
print(f"{pr['fromRef']['displayId']} → {pr['toRef']['displayId']} | автор: {pr['author']['user']['displayName']}")
print('ревьюеры: ' + ', '.join(f"{r['user']['displayName']} ({r['status']})" for r in pr['reviewers']))
commit = pr['fromRef']['latestCommit']
for b in get(f'{base}/rest/build-status/1.0/commits/{commit}', t).get('values', []):
    print(f"сборка: {b['state']} | {b.get('name')} | {b.get('url')}")

acts = get(f'{pr_url}/activities?limit=200', t)['values']
comments = [x for x in acts if x['action'] == 'COMMENTED']
print(f'\nкомментариев: {len(comments)}')
for x in reversed(comments):
    c = x['comment']
    anchor = x.get('commentAnchor') or {}
    where = f" [{anchor.get('path')}:{anchor.get('line')}]" if anchor.get('path') else ''
    print(f"\n--- {c['author']['displayName']}{where} ---\n{c['text']}")
    for reply in c.get('comments', []):
        print(f"  ↳ {reply['author']['displayName']}: {reply['text']}")
