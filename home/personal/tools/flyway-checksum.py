#!/usr/bin/env python3
"""Контрольная сумма Flyway для SQL-миграции — как в flyway_schema_history.checksum.

  flyway-checksum.py <файл.sql> [...]

CRC32 по строкам файла без переводов строк (UTF-8, BOM убирается), знаковый int. Нужна, когда своя ещё не
сданная V-миграция поменялась, а у пользователя локально уже применена старая: сверить старую сумму с БД и дать
UPDATE flyway_schema_history SET checksum = <новая> WHERE version = '<версия>'.
"""
import sys
import zlib

for path in sys.argv[1:]:
    with open(path, 'rb') as fh:
        text = fh.read().decode('utf-8')
    crc = 0
    for line in text.lstrip('﻿').splitlines():
        crc = zlib.crc32(line.encode('utf-8'), crc)
    print(crc - (1 << 32) if crc >= (1 << 31) else crc, path)
