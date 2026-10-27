# API — OpenAPI и генерация кода по контракту

Маппинг моделей в Java — `JAVA.RULE.1–2`.

- **API.RULE.1** [OpenAPI 3.0] Проверить ключи map (`additionalProperties`) или дать свой текст ошибки → в спеке не
  выразить (`propertyNames` — с 3.1; openapi-generator делает `@Pattern`/`@Size` без своего `message`) → проверять в
  коде делегата или контроллера и бросать исключение приложения; в спеке — описание.
