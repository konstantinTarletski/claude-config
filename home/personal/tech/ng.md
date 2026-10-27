# NG — Angular, TypeScript, ng-zorro

Node и npm — `tech/node.md`.

- **NG.RULE.1** [Angular 16+, сигналы] Пагинация «не работает», на клик два запроса (нужный `offset` и `offset=0`) →
  `effect` зависит от всех сигналов, прочитанных синхронно, в том числе внутри вызванных методов → в эффекте читать
  только нужное, остальное в `untracked(() => …)`. Запись (`set`) зависимостью не делает.
- **NG.TRAP.1** [ng-zorro] Тест компонента с `nz-tabset` → `NG05105 @tabSwitchMotion` → нет провайдера анимаций →
  `provideNoopAnimations()` в `providers`. `effect` в конструкторе срабатывает только после `fixture.detectChanges()`.
- **NG.TRAP.2** `tsc --noEmit` и тесты зелёные, а `ng build` — `TS2345` в `*.component.html` → типы шаблонов проверяет
  только компилятор Angular → проверять `ng build` (`WORK.CHECK.2`). Частый случай — `null` из OpenAPI: метод объявлять
  `id?: number | null` и нормализовать внутри.
