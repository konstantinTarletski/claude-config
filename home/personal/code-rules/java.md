# Правила кода: Java, Spring, MapStruct, OpenAPI

Проверить, когда код задачи написан, до отдачи на коммит (`/review-lessons`). Что сломалось — не сюда, а в `gotchas/`.

## MapStruct: явный `@Mapping` — только для разных имён

**Ошибка:** кажется, что поле (например, `id`) в сгенерированном маппере не выставляется, и добавляется явный
`@Mapping(source = "x", target = "x")` — а он лишний (ревьюер спросит «зачем»).
**Почему кажется:** (1) MapStruct пишет в цель через **fluent-метод**, если он есть (`target.id( entity.getId() )`, так у
моделей openapi-generator), а не `setId(...)` — поиск по `setId` ничего не найдёт; (2) неразмеченное поле цели — только
warning (`Unmapped target property: "x"`), а `gradle -q` его скрывает.
**Как правильно:** открыть `build/generated/sources/annotationProcessor/**/XxxMapperImpl.java` и искать **имя поля**
(`id(`, `getId()`), а не `setX`; предупреждения смотреть сборкой без `-q` (`compileJava --rerun-tasks`). Явный
`@Mapping` — только для полей с **разными** именами или вложенных (`source = "a.b"`). Проверено экспериментом: убрал
строку → поле всё равно маппится, warning'а нет. Юнит-тест маппера — через сгенерированный `new XxxMapperImpl()`
(`Mappers.getMapper` требует `mapstruct` в test classpath).

**Разные имена — сначала выровнять, потом маппить.** Поле API (из спеки аналитика) отличается от сущности только
регистром или суффиксом (`cronExpressionTimezone` / `cronExpressionTimeZone`, `minDelayBetweenExecutions` /
`minDelayBetweenCronExecutionsInMs`) — не писать `@Mapping`, а назвать поле в OpenAPI как в сущности и дать аналитику
заготовку правки wiki. `@Mapping` остаётся только для вложенных (`a.b`) и действительно разных по смыслу имён.

## OpenAPI 3.0: ключи map не валидируются, тексты bean-validation стандартные

**Ситуация:** нужно проверить ключи тела `{"<key>": …}` (`additionalProperties`) или выдать свой текст ошибки, а в
спеке это не выразить.
**Причина:** `propertyNames` появился только в OpenAPI 3.1. openapi-generator (spring) превращает `pattern`/`maxLength`
в `@Pattern`/`@Size` без своего `message` — текст берётся из `messages.properties` или из дефолтов Hibernate Validator.
**Как правильно:** если нужен конкретный текст (часто требует аналитик), проверять в коде делегата/контроллера и бросать
исключение приложения; в спеке оставить описание.
