# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-18
- Стадия: app shell, UI-прототип дневника и визуальный flow добавления еды завершены.
- Последняя завершенная задача: реализован интерактивный presentation-only прототип поиска и добавления еды без persistence.

## Базовые Сведения

- Продукт: YAM, Yet Another Macrotracker, local-first трекер питания.
- Главные платформы: Android и iOS. macOS и Linux поддерживаются как desktop-платформы согласно blueprint.
- Приоритеты: сначала локальные данные, крайне быстрый ввод еды, корректные расчеты, стабильная история дневника, простой UX, sync позже.
- Состав и очередность MVP определяет ADR 0002 и он заменяет противоречащую ему разбивку версий в blueprint. Непротиворечащие архитектурные и data-решения blueprint остаются в силе.

## Авторитетные Источники

- Полные продуктовые и технические требования: `agents/PROJECT_BLUEPRINT.md`.
- Правила работы агентов: `AGENTS.md`.
- Долговременные архитектурные решения: `docs/adr/`.
- Принятый исходный набор решений: `docs/adr/0001-foundational-product-and-data-decisions.md`.
- Продуктовый scope и пользовательские workflow: `docs/adr/0002-product-scope.md`.
- Визуальное направление и токены: `docs/adr/0003-design-direction.md`.
- Breakpoints и структура adaptive shell: `docs/adr/0004-adaptive-navigation.md`.
- Версионирование и platform icons: `docs/adr/0005-versioning-and-app-icons.md`.
- Политика производительности прокрутки: `docs/adr/0006-scroll-performance-policy.md`.
- UX визуального прототипа добавления еды: `docs/adr/0007-add-food-visual-prototype.md`.

## Принятые UX И Design Ориентиры

- Основная навигация на compact layout состоит из трех разделов: дневник, статистика и настройки. Добавление еды -- contextual action дневника, а не отдельный раздел.
- Повторное добавление распространенной еды должно занимать одно нажатие с запомненной порцией и возможностью `Отменить`.
- Добавление еды открывается отдельным task-screen поверх основной навигации. Вход из meal section заранее выбирает прием пищи; общий FAB требует явного выбора.
- На текущем presentation-only этапе добавленная еда живет только в памяти `DiaryScreen`, визуально обновляет demo-дневник и удаляется через snackbar `Отменить`.
- Дневник показывает читаемую сводку калорий и Б/Ж/У, а приемы пищи и строки продуктов строятся преимущественно отступами, типографикой и разделителями, а не множеством карточек.
- Визуальное направление -- playful utility: теплые light/dark themes, спокойная работа с данными, маскот только в уместных второстепенных состояниях, без осуждающего UX.
- Токены реализации определены в ADR 0003: `AppColors`, `AppTypography`, `AppSpacing`, `AppRadius`, `AppMotion` и `AppTheme`. Базовые `Brand Purple`, macro colors и `Brand Ink` берутся из `assets/inapp/yam_mark.svg`; semantic UI-оттенки тем допускают производные значения для контраста. Macro indicators требуют подписи или значения помимо цвета.

## Текущее Состояние Репозитория

- `lib/main.dart` запускает `YamApp`; стандартный counter scaffold удален.
- `lib/app/app.dart` содержит Material app bootstrap, system light/dark theme, generated l10n, startup gate и `go_router`.
- `lib/app/router.dart` и `lib/app/navigation/adaptive_navigation_shell.dart` реализуют три stateful branches: дневник, статистика и настройки. До 800 dp используется нижний `NavigationBar`, от 800 dp -- `NavigationRail`, от 1200 dp -- extended rail.
- `lib/features/diary/presentation/diary_screen.dart` содержит адаптивный прототип дневника: day navigation, week strip, calendar, возврат на сегодня, сводку калорий/БЖУ, meal sections, строки еды и contextual add actions.
- Общий FAB и `+` meal sections открывают `/add-food`. Typed route result временно добавляет demo-запись в выбранный прием, обновляет demo-сводку, прокручивает к строке и подсвечивает ее; Undo удаляет запись.
- Compact-дневник построен отдельными lazy slivers; day selector, summary и meal sections не находятся в одном заранее строящемся `Column`. Wide layout остается ограниченной двухколоночной композицией.
- Сегодняшний день временно наполняется согласованными demo-данными из `diary_prototype_data.dart`; другие даты пусты. Это presentation-only fixture без persistence и не является будущей domain/data model.
- На ширине доступного контента от 1040 dp summary и meals образуют две колонки; основной контент ограничен 1120 dp.
- Statistics и Settings пока являются локализованными route placeholders.
- `lib/features/food_search/presentation/food_search_screen.dart` реализует полноэкранный адаптивный поиск с autofocus, частыми, недавними и избранными demo-продуктами, query/empty states, явным meal selector и placeholder создания своего продукта.
- `lib/features/food_search/presentation/widgets/food_quick_add_sheet.dart` реализует visual quick-add: количество, единицы и порции, шаги/пресеты, обязательный meal, preview калорий и БЖУ, возврат результата в дневник.
- `food_search_prototype_data.dart` содержит только presentation fixture и простой demo-пересчет порций. Эти классы нельзя переносить в будущие domain/data layers.
- `lib/features/startup/presentation/startup_screen.dart` собирает интро из отдельных SVG через один `AnimationController`: батат появляется, затем Y/A/M последовательно вылетают из его рта по плавным высоким дугам и формируют надпись сверху. Обычная длительность -- 1400 ms с короткой финальной паузой; при Reduce Motion используется fade на 150 ms.
- `lib/features/startup/presentation/startup_artwork.dart` до `runApp` декодирует семь SVG в `Picture`; во время animation tick меняются только opacity/transform, а сами изображения рисуются через `CustomPainter` внутри `RepaintBoundary`. При ошибке предзагрузки остается fallback через `SvgPicture.asset`.
- Palette, light/dark theme, navigation/FAB/snackbar styles, spacing, radius, motion и breakpoints централизованы в `lib/app/theme/`. Токены расширяются только по реальной потребности экранов.
- `lib/app/theme/app_scroll_behavior.dart` глобально отключает дорогой Android stretch overscroll, сохраняя platform scroll physics. На reference Android 120 Гц это снизило raster p99 дневника с `12.421 ms` до `3.043 ms`, worst -- с `13.449 ms` до `3.912 ms`.
- Generated l10n настроен через `l10n.yaml` и ARB в `lib/l10n/`; доступны `en` и `ru`.
- Runtime-зависимости: `flutter_svg`, `go_router`, `intl` и `cupertino_icons`; последний предоставляет шрифт для подключенного generated l10n `GlobalCupertinoLocalizations`. Riverpod и Drift еще не добавлены.
- Брендовые ассеты доступны в `assets/icons/` и `assets/inapp/`; не перерисовывать и не заменять их без продуктовой задачи.
- Версия приложения -- `0.1.0+1`; `pubspec.yaml` является source of truth. `flutter_launcher_icons` генерирует Android/iOS/macOS/Windows/Web resources; Linux runner упаковывает PNG и устанавливает GTK window icon. Display name на всех платформах -- `YAM`.
- `integration_test/diary_scroll_performance_test.dart` выполняет profile benchmark реальных fling-жестов и проверяет p99 build/raster против бюджета 120 Гц `8.33 ms`.

## Известные Ограничения

- Store signing и окончательные application/bundle identifiers еще не определены; Android release пока подписывается debug key из шаблона.
- Нативные iOS/macOS/Windows builds не проверяются на текущем Linux host; их icon resources и metadata сгенерированы и проверены конфигурационно.
- Стандартный Flutter README еще нужно заменить; его нельзя считать документацией продукта.
- Startup animation сейчас показывается при каждом холодном запуске процесса. При подключении persisted onboarding/startup state нужно соблюдать ADR 0002: полноценное intro не должно навязываться при каждом обычном запуске.
- Дневник и food search используют demo-state. Поиск фильтрует только встроенный fixture; recent/favorite/frequent статичны, создание продукта показывает placeholder, barcode отсутствует, данные не сохраняются после пересоздания `DiaryScreen`.
- Нельзя строить persistence на `DiaryPrototype*` или `FoodSearchPrototype*` классах.

## Следующее Действие

- После визуальной проверки add-food flow реализовать следующий visual slice -- экран создания собственного продукта, подключив текущий placeholder без persistence.

## Блокеры

- Нет.

## Проверка

- `flutter gen-l10n` и `dart format --output=none --set-exit-if-changed lib test integration_test` -- успешно.
- `flutter analyze` -- успешно, issues не найдено.
- `NO_PROXY=localhost,127.0.0.1 no_proxy=localhost,127.0.0.1 flutter test` -- успешно, 17 тестов. Покрыты оба входа в add-food, shell overlay, autofocus, поиск и empty state, meal validation, quick-add, временная запись, Undo, wide layout и 200% text scale.
- Profile benchmark на `dd1bda94`, Android 16: build p99 `1.601 ms`, raster p99 `2.785 ms`, worst raster `4.294 ms`, missed build/raster budget `0`; лимиты 120 Гц пройдены.
- Post-change release builds не подтверждены: последовательная команда сборки была остановлена пользователем во время Android Gradle; пользователь собирает приложение самостоятельно.
