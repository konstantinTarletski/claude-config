# SQL — БД и миграции (PostgreSQL, Flyway)

Конкретика проекта (контейнер, схема, кто и где может писать) — `<repo>/.claude/tech/sql.md`.

## SQL.TRAP — грабли

- **SQL.TRAP.1** [Flyway, проверено на 11] **Удалил `R__`-файл (repeatable) — на всех окружениях приложение не стартует.**
  **Симптом:** после деплоя — `Validate failed: Detected applied migration not resolved locally: <описание>`, бэк
  останавливается.
  **Причина:** в `flyway_schema_history` каждой уже накатанной базы осталась строка про удалённый файл. Flyway при старте
  сначала **сверяет** историю с файлами (validate) и только потом **выполняет** новые миграции — поэтому `DELETE FROM
  flyway_schema_history` внутри новой `V`-миграции не поможет (до неё не дойдёт), а ещё и сменит её контрольную сумму.
  Столбец `script` хранит путь с подпапкой (`trigger/R__…sql`), а не только имя.
  **Как правильно:** удаляя `R__`-файлы, **сразу** дать SQL для окружений (`DELETE … WHERE script IN ('<папка>/R__….sql')`,
  выполняется вручную на каждом до деплоя) и сказать о нём в PR; или убрать автоматически — callback `beforeValidate.sql`
  в папке миграций (выполняется до сверки), `ignoreMigrationPatterns: "*:missing"` / `repair()` при старте (но они
  прячут и случайные потери). Выбор — за командой.
- **SQL.TRAP.2** [Flyway] **Поправил уже применённую `V`-миграцию — `checksum mismatch`** там, где она накатана (у
  коллег локально, на окружениях). До сдачи тикета — можно, но сразу дать `UPDATE flyway_schema_history SET checksum =
  <новая> WHERE version = '<версия>'`; сумма — `tools/flyway-checksum.py` (CRC32 по строкам без переводов строк,
  знаковый int; сначала сверить старую с БД). После деплоя на окружения — не трогать, только новой миграцией.
- **SQL.TRAP.3** [Oracle 19] **Длина `VARCHAR2`: `DATA_LENGTH` — байты, предел — `CHAR_LENGTH`.**
  **Симптом:** миграция с `INSERT` падает на деплое `ORA-12899: value too large for column … (actual: 268, maximum: 255)`,
  хотя `all_tab_columns.DATA_LENGTH` = 1020; приложение не стартует.
  **Причина:** колонка объявлена в символах (`CHAR_USED = 'C'`): `DATA_LENGTH` = символы × 4 байта, предел — `CHAR_LENGTH`.
  Компиляция и юнит-тесты текст миграции не проверяют.
  **Как правильно:** длину сверять по `CHAR_LENGTH` и `CHAR_USED`; вставляемый текст — посчитать в символах до коммита.
  Упавший changeset Liquibase не записывается в `DATABASECHANGELOG` — файл можно поправить без проблем с контрольной суммой
  (проверить, что строки там нет).
- **SQL.TRAP.4** [PostgreSQL 18, Java на Windows] **Приложение не подключается: `invalid value for parameter "TimeZone":
  "Europe/Kiev"`.**
  **Симптом:** запуск не из IDE (`gradlew bootRun`) падает на старте JPA (`Unable to determine Dialect without JDBC
  metadata`), в причине — `PSQLException: FATAL: invalid value for parameter "TimeZone": "Europe/Kiev"`; из IDE — работает.
  **Причина:** часовой пояс Windows «FLE Standard Time» (Эстония, Финляндия, Украина) Java переводит в `Europe/Kiev`,
  драйвер передаёт его серверу, а в базе tzdata у PostgreSQL этого старого имени уже нет (`Europe/Kyiv`). IDE в своей
  конфигурации запуска задаёт пояс явно.
  **Как правильно:** задать пояс JVM явно: `-Duser.timezone=Europe/Tallinn` (через `JAVA_TOOL_OPTIONS` в той же команде:
  `cmd.exe /c "set JAVA_TOOL_OPTIONS=-Duser.timezone=Europe/Tallinn&& … gradlew.bat bootRun"`).
