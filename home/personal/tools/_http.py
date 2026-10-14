"""Общее для утилит: токен из env (с подгрузкой из ~/.bashrc) и GET с Bearer-авторизацией.

Не запускается сам — импортируется из jira.py, wiki.py, bb-pr.py.
"""
import json
import os
import subprocess
import sys
import urllib.error
import urllib.request


def token(var):
    """Токен из переменной окружения; нет в env (не интерактивный шелл) — взять из ~/.bashrc. Значение не печатается."""
    value = os.environ.get(var)
    if not value:
        value = subprocess.run(['bash', '-ic', f'echo -n "${var}"'], capture_output=True, text=True).stdout
    if not value:
        sys.exit(f'Нет токена в переменной {var} (INTEG.ALL.3)')
    return value


def get(url, token_value, raw=False, timeout=30):
    req = urllib.request.Request(url, headers={'Authorization': f'Bearer {token_value}', 'Accept': 'application/json'})
    try:
        with urllib.request.urlopen(req, timeout=timeout) as resp:
            data = resp.read()
            return (data, resp.geturl()) if raw else json.loads(data)
    except urllib.error.HTTPError as e:
        sys.exit(f'HTTP {e.code} {url}')
    except (urllib.error.URLError, TimeoutError) as e:
        sys.exit(f'⚠ {url} недоступен ({e}) — похоже, слетел VPN (INTEG.ALL.5)')
