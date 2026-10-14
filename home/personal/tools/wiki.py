#!/usr/bin/env python3
"""Страница Confluence → текст: таблицы через «|», код-блоки, пометки изменений (новое [+…+], убранное ~~…~~).

  wiki.py <id | ссылка на страницу | короткая ссылка /x/…> --url <https://wiki…> --token-env <ИМЯ> [--out <файл>]
          [--attachments] [--children]

--out          сохранить текст в файл (для документа задачи: <KEY>.in.wiki-<id>.txt — FILES.DOCS.2), иначе в stdout
--attachments  список вложений (диаграммы, картинки) — INTEG.WIKI.3
--children     список подстраниц
Зелёный текст считается «новым», <s> — «убранным» (INTEG.WIKI.4).
"""
import argparse
import html
import os
import re
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from _http import get, token  # noqa: E402

p = argparse.ArgumentParser()
p.add_argument('page')
p.add_argument('--url', required=True)
p.add_argument('--token-env', required=True)
p.add_argument('--out')
p.add_argument('--attachments', action='store_true')
p.add_argument('--children', action='store_true')
a = p.parse_args()

base = a.url.rstrip('/')
t = token(a.token_env)

page = a.page
if not page.isdigit():
    m = re.search(r'/pages/(\d+)', page) or re.search(r'pageId=(\d+)', page)
    if not m:  # короткая ссылка /x/… — пройти редирект
        url = page if page.startswith('http') else f'{base}/x/{page.split("/x/")[-1]}'
        _, final = get(url, t, raw=True)
        m = re.search(r'/pages/(\d+)', final) or re.search(r'pageId=(\d+)', final)
        if not m:
            sys.exit(f'Не нашёл id страницы: {final}')
    page = m.group(1)

d = get(f'{base}/rest/api/content/{page}?expand=body.storage,version,ancestors', t)
body = d['body']['storage']['value']
code = re.findall(r'<!\[CDATA\[(.*?)\]\]>', body, re.S)
body = re.sub(r'<s>(.*?)</s>', r'~~\1~~', body, flags=re.S)
body = re.sub(r'<del>(.*?)</del>', r'~~\1~~', body, flags=re.S)
body = re.sub(r'<span style="[^"]*text-decoration:\s*line-through[^"]*"[^>]*>(.*?)</span>', r'~~\1~~', body, flags=re.S)
body = re.sub(r'<span style="color:\s*var\(--ds-icon-success,#22a06b\);?"[^>]*>(.*?)</span>', r'[+\1+]', body, flags=re.S)
body = re.sub(r'<span style="color:\s*rgb\(0,\s*1[0-9]{2},\s*[0-9]+\);?"[^>]*>(.*?)</span>', r'[+\1+]', body, flags=re.S)
text = re.sub(r'<br ?/?>|</p>|</tr>|</h\d>|</li>', '\n', body)
text = re.sub(r'</t[dh]>', ' | ', text)
text = html.unescape(re.sub(r'<[^>]+>', '', text))
text = re.sub(r'\n{3,}', '\n\n', text)

path = ' / '.join(x['title'] for x in d.get('ancestors', []))
out = [f"== {d['title']} | id {page} | v{d['version']['number']} {d['version']['when'][:10]} {d['version']['by']['displayName']}",
       f'path: {path}', '', text]
if code:
    out += ['', '=== CODE BLOCKS ==='] + [f'--- {i + 1} ---\n{c}' for i, c in enumerate(code)]
if a.attachments:
    att = get(f'{base}/rest/api/content/{page}/child/attachment?expand=version&limit=100', t)
    out += ['', '=== ATTACHMENTS ==='] + [
        f"{x['title']} | v{x['version']['number']} {x['version']['when'][:10]} | {base}{x['_links']['download']}"
        for x in att['results']]
if a.children:
    ch = get(f'{base}/rest/api/content/{page}/child/page?limit=100', t)
    out += ['', '=== CHILDREN ==='] + [f"{x['id']} {x['title']}" for x in ch['results']]

result = '\n'.join(out)
if a.out:
    with open(a.out, 'w', encoding='utf-8') as fh:
        fh.write(result)
    print(f"saved {a.out}: {d['title']} v{d['version']['number']} ({len(result)} chars)")
else:
    print(result)
