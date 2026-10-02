# Грабли: Node, npm, Angular

Сломалось, не компилируется, не запускается. Общими словами, без проекта. Формат: симптом → причина → как правильно.

## WSL + `node_modules`, установленные из Windows

**Симптом:** в WSL `npx vitest` / `npm run build` падают на всех файлах, например
`Failed to resolve import "@core/..."`, хотя код в порядке.
**Причина:** репозиторий лежит на `/mnt/c/...`, зависимости ставились Windows-нодой — в
`node_modules` нативные бинарники под Windows (`@esbuild/win32-x64`, `@rollup/rollup-win32-*`),
алиасы из `tsconfig` резолвятся не так.
**Как правильно:** проверить `ls node_modules/@esbuild`; если `win32-*` — запускать через
Windows-ноду: `cmd.exe /c "cd /d C:\path\to\repo && npm test"`. Не переустанавливать зависимости
из WSL без спроса — сломается у пользователя в Windows.

## npm из WSL: `SELF_SIGNED_CERT_IN_CHAIN` на внутреннем реестре

**Симптом:** `curl https://<внутренний-реестр>` отвечает 200, а `npm view` / `npm ci` падают с
`self-signed certificate in certificate chain`.
**Причина:** корпоративный CA добавлен в системное хранилище Linux (`/usr/local/share/ca-certificates`),
а Node по умолчанию использует свой встроенный набор CA.
**Как правильно:** `export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt` в `~/.bashrc`
(прописано 25.09.2026). Не отключать проверку (`strict-ssl=false`).

## `npm ci`: «package.json and package-lock.json … are in sync»

**Симптом:** `npm ci` сразу падает с `EUSAGE … Missing: <pkg> from lock file`.
**Причина:** lock-файл не соответствует `package.json` — часто это незакоммиченные правки
пользователя в `package-lock.json`.
**Как правильно:** `npm ci` в этом случае ничего не удаляет — старые `node_modules` целы. Сначала
`git status`; lock-файл пользователя не перегенерировать (`npm install`) без спроса.

## `node_modules` от другой ветки

**Симптом:** `ng build` → «Could not find the '@angular-devkit/build-angular:browser' builder»,
`tsc` → сотни «Cannot find module '@angular/...'», хотя код в порядке.
**Причина:** переключились на ветку с другой мажорной версией фреймворка, а `node_modules`
остались от прежней (сравнить `package.json` и `node_modules/<пакет>/package.json` → `version`).
**Как правильно:** `npm ci` на нужной ветке — но это заменит зависимости для другой ветки, поэтому
только с согласия пользователя. Без переустановки — хотя бы `tsc --noEmit` и отфильтровать ошибки
по изменённым файлам.

## Форматтер не в зависимостях проекта: `npx` берёт последнюю версию

**Симптом:** `npx prettier --check` ругается даже на файлы, где изменены 1–2 строки.
**Причина:** пакета нет в `devDependencies`, `npx` скачивает свежую версию, а существующий код под неё
не отформатирован (форматирование делал плагин редактора со своими настройками).
**Как правильно:** не прогонять по чужим файлам. Новые файлы — `--write` целиком, в изменённых —
вручную держать стиль соседнего кода.

## Тест Angular-компонента с ng-zorro `nz-tabset`: `NG05105 @tabSwitchMotion`

**Симптом:** `fixture.detectChanges()` → `NG05105: Unexpected synthetic property @tabSwitchMotion found`.
**Причина:** компоненты ng-zorro используют анимации Angular, а в `TestBed` провайдер анимаций не подключён.
**Как правильно:** в `providers` теста — `provideNoopAnimations()` из `@angular/platform-browser/animations`.
Эффекты компонента (`effect` в конструкторе) выполняются при change detection — без `fixture.detectChanges()`
они в тесте не сработают.

## Angular: `tsc --noEmit` чистый, а `ng serve` / `ng build` падает `TS2345` в шаблоне

**Симптом:** `tsc --noEmit -p tsconfig.app.json` и unit-тесты зелёные, а `ng serve` → `ERROR TS2345 … [plugin
angular-compiler]` с указанием строки `*.component.html`.
**Причина:** `tsc` не видит шаблоны — их типы проверяет только компилятор Angular (`strictTemplates`) при сборке.
Частый случай — `null` в типе: `(rowClick)="f($event['id'])"`, где у модели `id: number | null` (nullable из
сгенерированной OpenAPI-модели), а метод принимает `id?: number`.
**Как правильно:** проверять `ng build` (`npm run build`), а не только `tsc`; метод, куда приходят поля из модели,
объявлять с тем же типом (`id?: number | null`) и нормализовать внутри (`id ?? undefined`).
