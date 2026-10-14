#!/usr/bin/env python3
"""Тикет Jira коротким текстом: статус, исполнитель, описание, комментарии, связи, вложения.

  jira.py <KEY> --url <https://jira…> --token-env <ИМЯ_ПЕРЕМЕННОЙ> [--attach <папка>] [--changelog]

--attach   скачать вложения в папку с приставкой <KEY>.in. (FILES.DOCS.2)
--changelog  история смены статусов (кто, когда)
Токен — из переменной окружения (INTEG.ALL); адрес и имя переменной — INTEG.TRACK проекта.
"""
import argparse
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _http import get, token  # noqa: E402

p = argparse.ArgumentParser()
p.add_argument('key')
p.add_argument('--url', required=True)
p.add_argument('--token-env', required=True)
p.add_argument('--attach')
p.add_argument('--changelog', action='store_true')
a = p.parse_args()

base = a.url.rstrip('/')
t = token(a.token_env)
fields = 'summary,description,status,assignee,reporter,priority,comment,issuelinks,labels,attachment,parent'
expand = '&expand=changelog' if a.changelog else ''
d = get(f'{base}/rest/api/2/issue/{a.key}?fields={fields}{expand}', t)
f = d['fields']

print(f"{a.key} | {f['status']['name']} | {(f.get('priority') or {}).get('name')}")
print(f"ASSIGNEE: {(f.get('assignee') or {}).get('displayName')} | REPORTER: {(f.get('reporter') or {}).get('displayName')}")
print(f"SUMMARY: {f['summary']}")
if f.get('parent'):
    print(f"PARENT: {f['parent']['key']} {f['parent']['fields'].get('summary')}")
print(f"\n--- DESCRIPTION ---\n{f.get('description') or ''}")
for c in f['comment']['comments']:
    print(f"\n--- COMMENT {c['created'][:16]} {c['author']['displayName']} ---\n{c['body']}")
for link in f.get('issuelinks', []):
    i = link.get('inwardIssue') or link.get('outwardIssue') or {}
    fi = i.get('fields', {})
    print(f"LINK: {link['type']['name']} {i.get('key')} {fi.get('summary')} [{fi.get('status', {}).get('name')}]")
for att in f.get('attachment', []):
    print(f"ATTACH: {att['filename']} ({att['size']} B)")
if a.changelog:
    print('\n--- STATUS HISTORY ---')
    for h in d['changelog']['histories']:
        for item in h['items']:
            if item['field'] == 'status':
                print(f"{h['created'][:16]} {h['author']['displayName']}: {item['fromString']} → {item['toString']}")

if a.attach:
    os.makedirs(a.attach, exist_ok=True)
    for att in f.get('attachment', []):
        data, _ = get(att['content'], t, raw=True)
        path = os.path.join(a.attach, f"{a.key}.in.{att['filename']}")
        with open(path, 'wb') as out:
            out.write(data)
        print(f'saved {path}')
