# JAVA — Java и библиотеки Java-мира (Spring, Jackson, MapStruct, JUnit)

Сборка (Gradle) — `tech/gradle.md`; OpenAPI — `tech/api.md`; WSL — `tech/wsl.md`.

## JAVA.SETUP — установка

- **JAVA.SETUP.1** Версию **не угадывать — брать из проекта**, по приоритету: `sourceCompatibility` / `toolchain` в
  `build.gradle(.kts)` / `pom.xml`, базовый образ в `Dockerfile`, версия Gradle-wrapper (старый Gradle не запускается
  на новой Java — `GRADL.TRAP.2`).
- **JAVA.SETUP.2** Работаем из WSL (`USER.SYS.1`, что стоит — `USER.DEV.2`) — **JDK из WSL через sdkman** (`~/.sdkman`): `sdk install java <ver>` /
  `sdk use java <ver>`. Нужной версии нет — поставить и сказать об этом. Дистрибутив — тот же, что у команды/IDE (часто
  Corretto `-amzn` или Temurin `-tem`).
- **JAVA.SETUP.3** Закрепить версию: `.sdkmanrc` (`sdk env init`) в корне, автопереключение — `sdkman_auto_env=true` в
  `~/.sdkman/etc/config`; если в проекте его нет — скрыть через `.git/info/exclude`.
- **JAVA.SETUP.4** [sdkman] **Первая установленная версия кандидата становится `current`** (даже с ответом «n» на «set
  as default?») — во всех шеллах вдруг другая `java`. Зарегистрировать системную Java и вернуть её:
  `sdk install java 25-system /usr/lib/jvm/<jdk>` → `sdk default java 25-system`.
- **JAVA.SETUP.5** Запасной вариант — Windows-JDK через `cmd.exe` (`GRADL.TRAP.1`) — только временно и с явным
  сообщением, чего не хватает (версия в sdkman, доступы, CRLF).

## JAVA.RULE — как писать

- **JAVA.RULE.1** [MapStruct] **Явный `@Mapping` — только для разных имён.**
  **Ошибка:** кажется, что поле (например, `id`) в сгенерированном маппере не выставляется, и добавляется
  `@Mapping(source = "x", target = "x")` — а он лишний (ревьюер спросит «зачем»).
  **Почему кажется:** (1) MapStruct пишет в цель через **fluent-метод**, если он есть (`target.id( entity.getId() )`, так у
  моделей openapi-generator), а не `setId(...)` — поиск по `setId` ничего не найдёт; (2) неразмеченное поле цели — только
  warning (`Unmapped target property: "x"`), а `gradle -q` его скрывает.
  **Как правильно:** открыть `build/generated/sources/annotationProcessor/**/XxxMapperImpl.java` и искать **имя поля**
  (`id(`, `getId()`); предупреждения — сборкой без `-q` (`compileJava --rerun-tasks`). Явный `@Mapping` — только для
  полей с **разными** именами или вложенных (`source = "a.b"`). Юнит-тест маппера — через `new XxxMapperImpl()`
  (`Mappers.getMapper` требует `mapstruct` в test classpath).
- **JAVA.RULE.2** [MapStruct, OpenAPI] **Разные имена — сначала выровнять, потом маппить.** Поле API (из спеки
  аналитика) отличается от сущности только регистром или суффиксом (`cronExpressionTimezone` / `…TimeZone`) — не писать
  `@Mapping`, а назвать поле в OpenAPI как в сущности и дать аналитику заготовку правки wiki. `@Mapping` остаётся только
  для вложенных (`a.b`) и действительно разных по смыслу имён.

- **JAVA.RULE.3** [MapStruct] **Общий кусок маппинга — интерфейс с `default`-методом.**
  **Ошибка:** правило для одного поля (например, «короткое имя, а если пусто — код»), нужное в нескольких мапперах,
  вынесено в отдельный Spring-бин (`@Component`-класс) и подключено через `uses = …` — ревьюер: «class → interface,
  используй default-метод».
  **Как правильно:** `interface XxxMapper { @Named("xxx") default String xxx(Entity e) { … } }`, мапперы его
  наследуют (`… extends BaseMapper<E, R>, XxxMapper`) и берут `@Mapping(source = ".", target = "…", qualifiedByName =
  "xxx")`; `uses` — только для того, что правда бин (сервис, справочник из БД). Проверка строк — готовые утилиты
  (`StringUtils.isNotBlank`), не ручное `!= null && !isBlank()`. Юнит-тест — `new XxxMapper() {}`. Перед правкой маппера —
  соседние мапперы (`CODE.RULE.6`; `JAVA.RULE.1–2` — тоже про MapStruct).

## JAVA.TRAP — грабли

- **JAVA.TRAP.1** [Jackson 3] **Не видит `@JsonProperty` на унаследованных полях.**
  **Симптом:** при десериализации в класс-наследник (сгенерированный openapi-generator с `allOf` → `extends`) поля
  базового класса (`id`, `version`) молча `null`.
  **Причина:** Jackson 3 (`tools.jackson`) иначе обрабатывает аннотации на полях родителя, чем Jackson 2
  (`com.fasterxml`), под который написан сгенерированный код.
  **Как правильно:** такие модели читать Jackson 2 `ObjectMapper`'ом. Jackson 3 — только для `JsonNode` и своих простых
  типов.
- **JAVA.TRAP.2** [Spring 4.0] **RestTemplate падает на лишних полях JSON, нет хелперов авторизации.**
  **Симптом:** ответ внешнего API не читается: `UnrecognizedPropertyException`, хотя нужные поля в DTO есть;
  `HttpHeaders.setBasicAuth` и `HttpHeaders.AUTHORIZATION` — «cannot find symbol».
  **Причина:** в Spring 4.0 `MappingJackson2HttpMessageConverter` создаёт голый `new ObjectMapper()` —
  `FAIL_ON_UNKNOWN_PROPERTIES=true` (выключать стал `Jackson2ObjectMapperBuilder` в 4.1); `setBasicAuth` — с 5.1,
  константа `AUTHORIZATION` — позже 4.0.
  **Как правильно:** DTO ответов — `@JsonIgnoreProperties(ignoreUnknown = true)`; Basic — вручную:
  `headers.set("Authorization", "Basic " + Base64.getEncoder().encodeToString((user + ":" + pass).getBytes(UTF_8)))`.
  Проверить: `new MappingJackson2HttpMessageConverter().getObjectMapper().isEnabled(FAIL_ON_UNKNOWN_PROPERTIES)`.
- **JAVA.TRAP.3** [JUnit 5] **`@CsvSource`: значения — только константы времени компиляции.**
  **Симптом:** `"A".repeat(101) + " | …"` в `@CsvSource` → «element value must be a constant expression».
  **Причина:** аргументы аннотаций в Java — только compile-time константы.
  **Как правильно:** вычисляемые значения — в отдельный `@Test` или `@MethodSource`.
- **JAVA.TRAP.4** [JUnit 5 parallel, Logback] **Тест логов «иногда» падает в полном прогоне.**
  **Симптом:** тест проверяет запись в логе через `ListAppender` на общем (статическом) логгере; отдельно зелёный, а в
  полном прогоне изредка проверяет чужую запись.
  **Причина:** классы тестов идут параллельно (`junit.jupiter.execution.parallel.mode.classes.default=concurrent`), в
  тот же логгер одновременно пишут другие тесты. `@Execution(SAME_THREAD)` на своём классе не помогает — мешают другие.
  **Как правильно:** фильтровать события по потоку прямо в `ListAppender` (принимать только события текущего потока).
  **Обратный симптом — перехват пустой** (`ListAppender` отцеплен и остановлен): [Spring Boot] параллельно идёт
  тест, поднимающий Spring-контекст (`@WebMvcTest`, `@SpringBootTest`), — при старте Spring Boot делает
  `LoggerContext.reset()` и снимает все appender'ы со всех логгеров. Фильтр по потоку не спасает. Такой тест — с
  `@Isolated` (JUnit 5.7+: идёт, когда никто другой не идёт). Проверить механизм — вызвать `reset()` посреди теста.
- **JAVA.TRAP.5** [Spring] **`@Cacheable` не срабатывает при вызове из того же бина.**
  **Симптом:** метод с `@Cacheable` каждый раз ходит во внешнюю систему.
  **Причина:** Spring-прокси не перехватывает self-invocation (`this.cachedMethod()`).
  **Как правильно:** кэшируемые вызовы — в отдельный бин (`*CacheService`) и вызывать его снаружи. То же для
  `@Transactional`, `@Async` и других аннотаций через прокси.
