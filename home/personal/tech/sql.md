# SQL — БД и миграции (PostgreSQL, Oracle, Flyway, Liquibase)

Конкретика проекта (контейнер, схема, кто где пишет) — `<repo>/.claude/tech/sql.md`.

- **SQL.TRAP.1** [Flyway 11] Удалил `R__`-файл → на всех окружениях «Detected applied migration not resolved locally»,
  бэк не стартует → в `flyway_schema_history` осталась строка, а сверка идёт до новых миграций (`DELETE` в новой `V` не
  поможет) → сразу дать SQL для окружений (`DELETE … WHERE script IN ('<папка>/R__….sql')` — путь с подпапкой) и
  сказать в PR; или `beforeValidate.sql` / `ignoreMigrationPatterns: "*:missing"` (прячут и случайные потери) — решает
  команда.
- **SQL.TRAP.2** [Flyway] Поправил применённую `V`-миграцию → `checksum mismatch` у коллег и на окружениях → до сдачи
  можно, но сразу дать `UPDATE flyway_schema_history SET checksum = <новая> WHERE version = '<версия>'` (сумма —
  `tools/flyway-checksum.py`, сначала сверить старую с БД); после деплоя — только новой миграцией.
- **SQL.TRAP.3** [Oracle 19] `ORA-12899 (actual: 268, maximum: 255)`, хотя `DATA_LENGTH` = 1020 → колонка в символах
  (`CHAR_USED = 'C'`), `DATA_LENGTH` — байты → сверять по `CHAR_LENGTH`, текст считать в символах до коммита. Упавший
  changeset Liquibase в `DATABASECHANGELOG` не пишется — файл можно поправить.
- **SQL.TRAP.4** [PostgreSQL 17–18, Java на Windows] Старт падает (`Unable to determine Dialect`, `HikariPool … Failed to
  initialize pool`), в причине — `invalid value for parameter "TimeZone": "Europe/Kiev"` → пояс Windows «FLE Standard
  Time» Java переводит в `Europe/Kiev`, а в tzdata PostgreSQL его уже нет → задать пояс JVM:
  `JAVA_TOOL_OPTIONS=-Duser.timezone=Europe/Tallinn` (в команде, в `.env` или в конфигурации IDE).
