# JAVA — Java и библиотеки (Spring, Jackson, MapStruct, JUnit)

Сборка — `tech/gradle.md`; OpenAPI — `tech/api.md`.

- **JAVA.SETUP.1** Версия Java → из проекта: `sourceCompatibility` / `toolchain`, `pom.xml`, образ в `Dockerfile`; версия
  Gradle-wrapper (старый Gradle на новой Java не стартует).
- **JAVA.SETUP.2** JDK в WSL → sdkman: `sdk install java <ver>` / `sdk use java <ver>`, дистрибутив как у команды
  (`-amzn`, `-tem`); нет нужной — поставить и сказать. Windows-JDK через `cmd.exe` (`GRADL.TRAP.1`) — только временно,
  сказав, чего не хватает.
- **JAVA.SETUP.3** Закрепить версию → `.sdkmanrc` (`sdk env init`), автопереключение `sdkman_auto_env=true`; нет в
  проекте → скрыть через `.git/info/exclude`.
- **JAVA.SETUP.4** [sdkman] Первая установленная версия становится `current` (даже с «n» на «set as default?») → во
  всех шеллах другая `java`. Вернуть системную: `sdk install java 25-system /usr/lib/jvm/<jdk>` → `sdk default java
  25-system`.
- **JAVA.RULE.1** [MapStruct] Явный `@Mapping` → только для разных имён или вложенных (`a.b`). «Поле не выставляется» —
  обманка: MapStruct пишет fluent-методом (`target.id( … )`, не `setId`), а warning `Unmapped target property` прячет
  `gradle -q`. Проверять в `build/generated/**/XxxMapperImpl.java` по имени поля; тест — `new XxxMapperImpl()`.
- **JAVA.RULE.2** [MapStruct, OpenAPI] Имя в API отличается от сущности регистром или суффиксом → не `@Mapping`, а
  назвать поле в OpenAPI как в сущности + заготовка правки wiki аналитику.
- **JAVA.RULE.3** [MapStruct] Общий кусок маппинга для нескольких мапперов → `interface` с `@Named default`-методом,
  мапперы наследуют, `qualifiedByName`; `uses` — только для настоящих бинов. Строки — `StringUtils.isNotBlank`. Тест —
  `new XxxMapper() {}`.
- **JAVA.RULE.4** [MapStruct] Копирование полей → методом маппинга (`Target toX(A a, B b)` + `@Mapping` для разных
  имён), не руками; руками — только то, чего MapStruct не выражает (`null`, выбор ветки), коротко. Потом — проверить в
  `*MapperImpl`, откуда какое поле.
- **JAVA.TRAP.1** [Jackson 3] Поля родителя (`id`, `version`) у наследника молча `null` (модели openapi-generator с
  `allOf` → `extends`) → Jackson 3 иначе читает аннотации на полях родителя → такие модели читать Jackson 2
  `ObjectMapper`'ом.
- **JAVA.TRAP.4** [JUnit 5 parallel, Logback] Тест логов через `ListAppender` на общем логгере «иногда» падает в полном
  прогоне → классы идут параллельно, в логгер пишут другие → фильтровать события по текущему потоку. Перехват пустой →
  [Spring Boot] параллельный тест со Spring-контекстом делает `LoggerContext.reset()` и снимает appender'ы → такой тест
  с `@Isolated`.
- **JAVA.TRAP.6** [MapStruct] `@Mapping(target = "x.y")` → у `x` остальные поля пустые, при пустых источниках `{}`
  вместо `null` → вложенные `@Mapping` отключают автомаппинг `x` → для `x` свой метод маппинга, `null` — `default`-
  обёрткой.
