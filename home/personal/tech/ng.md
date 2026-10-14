# NG — Angular, TypeScript, ng-zorro

Node и npm — `tech/node.md`.

## NG.RULE — как писать

- **NG.RULE.1** [Angular 16+, сигналы] **`effect`: зависимости — только нужные, остальное в `untracked`.**
  **Симптом:** пагинация «не работает»: номер страницы меняется, данные — нет; в Network на один клик два запроса —
  нужный `offset` и следом `offset=0`.
  **Причина:** `effect` отслеживает **все** сигналы, прочитанные синхронно во время его выполнения, в том числе внутри
  вызванных методов. `effect(() => { const id = this.id(); this.page.set(1); this.fetch(id); })`, где `fetch` читает
  `this.page()`, зависит и от `page`: смена страницы перезапускает эффект, тот сбрасывает её на 1 и перезапрашивает.
  **Как правильно:** оставить в эффекте только нужные зависимости, остальное — в `untracked(() => …)`:
  `effect(() => { const id = this.id(); untracked(() => { this.page.set(1); this.fetch(id); }); })`. Запись сигнала
  (`set`) зависимостью не делает — только чтение.

## NG.TRAP — грабли

- **NG.TRAP.1** [ng-zorro] **Тест компонента с `nz-tabset`: `NG05105 @tabSwitchMotion`.**
  **Симптом:** `fixture.detectChanges()` → `NG05105: Unexpected synthetic property @tabSwitchMotion found`.
  **Причина:** компоненты ng-zorro используют анимации Angular, а в `TestBed` провайдер анимаций не подключён.
  **Как правильно:** в `providers` теста — `provideNoopAnimations()` из `@angular/platform-browser/animations`. Эффекты
  компонента (`effect` в конструкторе) выполняются при change detection — без `fixture.detectChanges()` они не сработают.
- **NG.TRAP.2** **`tsc --noEmit` чистый, а `ng serve` / `ng build` падает `TS2345` в шаблоне.**
  **Симптом:** `tsc --noEmit -p tsconfig.app.json` и unit-тесты зелёные, а `ng serve` → `ERROR TS2345 … [plugin
  angular-compiler]` со строкой `*.component.html`.
  **Причина:** `tsc` не видит шаблоны — их типы проверяет только компилятор Angular (`strictTemplates`) при сборке.
  Частый случай — `null` в типе: `(rowClick)="f($event['id'])"`, где у модели `id: number | null` (nullable из OpenAPI),
  а метод принимает `id?: number`.
  **Как правильно:** проверять `ng build` (`WORK.CHECK.2`); метод, куда приходят поля из модели, объявлять с тем же
  типом (`id?: number | null`) и нормализовать внутри (`id ?? undefined`).
- **NG.TRAP.3** [Playwright] **`playwright.config.ts` в IDE красный** (`require`, `process` — «Cannot find name»).
  **Причина:** нет `@types/node` и файл не входит ни в один `tsconfig` (корневой `"files": []`, `tsconfig.app/spec` —
  только `src`).
  **Как правильно:** на запуск не влияет (Playwright транспилирует без проверки типов) — не чинить в рамках задачи. E2E
  — не мёртвый код: проверить, гоняет ли их CI (`WORK.CHECK.2`).
