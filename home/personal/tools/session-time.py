#!/usr/bin/env python3
"""Активное время по сессии Claude Code: разбор (от ссылки на тикет до «делай») и реализация (от «делай» до конца).

Паузы больше 20 минут не считаются. Берёт самый свежий файл сессии проекта (или указанный --session).
  session-time.py [--go <маркер «делай»>] [--session <файл.jsonl>] -- <каталог в ~/.claude/projects> <KEY>
  session-time.py --go делай -- -mnt-c-code-shop-be SA-2176      (каталог начинается с «-» — поэтому «--»)
Фоновые прогоны (сборка, тесты) в сессию не пишутся — их длительность добавить отдельно.
"""
import argparse
import glob
import json
import os
from datetime import datetime

PAUSE = 1200  # секунд


def load(path):
    rows = []
    for line in open(path, encoding='utf-8'):
        try:
            d = json.loads(line)
        except ValueError:
            continue
        if not d.get('timestamp'):
            continue
        t = datetime.fromisoformat(d['timestamp'].replace('Z', '+00:00'))
        c = d.get('message', {}).get('content') if d.get('type') == 'user' else ''
        if isinstance(c, list):
            c = ' '.join(x.get('text', '') for x in c if isinstance(x, dict))
        rows.append((t, c if isinstance(c, str) else ''))
    return sorted(rows, key=lambda r: r[0])


def active(rows, a, b):
    ts = [t for t, _ in rows if a <= t <= b]
    return round(sum((q - p).total_seconds() for p, q in zip(ts, ts[1:]) if (q - p).total_seconds() < PAUSE) / 3600, 2)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('project')
    ap.add_argument('key')
    ap.add_argument('--go', default='делай')
    ap.add_argument('--session')
    a = ap.parse_args()
    path = a.session or max(glob.glob(os.path.expanduser(f'~/.claude/projects/{a.project}/*.jsonl')), key=os.path.getmtime)
    rows = load(path)
    start = next((t for t, x in rows if a.key in x), None)
    if start is None:
        raise SystemExit(f'{a.key} не найден в сообщениях {path}')
    go = next((t for t, x in rows if t > start and a.go in x), None)
    end = rows[-1][0]
    if go is None:
        print('разбор', active(rows, start, end), '(«делай» не найдено)')
    else:
        print('разбор', active(rows, start, go), 'реализация', active(rows, go, end))


if __name__ == '__main__':
    main()
