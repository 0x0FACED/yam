# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной
> задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-20.
- Стадия: visual implementation pass; Дневник, Food Search и Add Food sheet
  переведены на канонические shared-компоненты.
- Текущий статус: Add Food sheet завершён; следующий slice -- Edit Diary Entry.

## Авторитетные Источники

- Правила работы: `AGENTS.md`.
- Product/architecture blueprint: `agents/PROJECT_BLUEPRINT.md`.
- Принятые решения: `docs/adr/`.
- Визуальная иерархия источников: `agents/design/README.md`.
- Визуальное направление и токены: `docs/adr/0003-design-direction.md`.
- Adaptive shell: `docs/adr/0004-adaptive-navigation.md`.
- UX presentation-flow добавления еды: `docs/adr/0007-add-food-visual-prototype.md`.
- Performance-оптимизация до реальной проблемы отложена ADR 0008; обязательных
  profile-бенчмарков и числовых бюджетов у MVP нет.

## Зафиксированный Scope Визуального Прохода

- Основные разделы: Дневник, Статистика, Настройки.
- Onboarding: Цель -> Вес -> Цели питания; `/onboarding` будет отдельным
  presentation-flow без изменения cold-start до появления persisted state.
- Goals редактирует только kcal, белки, жиры, углеводы, текущий и целевой вес.
- Hydration/water и account/profile UI не входят в текущий проход.
- Barcode scanning не реализуется; в Create Product допустим ручной barcode.
- Add Food action редактирования nutrition/name не показывается без маршрута.
- Persistence, remote API, sync, account и production ranking не строятся.

## Реализованная Основа

- `lib/app/app.dart` запускает локализованный `MaterialApp.router` с System,
  Light и Dark themes и существующим startup-intro.
- `lib/app/router.dart` использует `StatefulShellRoute.indexedStack` для Diary,
  Statistics и Settings; `/add-food` остается task-screen над shell.
- До 800 dp используется `NavigationBar`, от 800 dp `NavigationRail`, от 1200 dp
  extended rail. Diary ограничен шириной 1120 dp и переходит в две колонки при
  1040 dp доступного content width.
- `lib/app/theme/app_typography.dart` задает именованную шкалу typography и
  tabular figures без новой font dependency.
- `lib/app/theme/app_semantic_colors.dart` предоставляет theme-aware success,
  warning и goal-status colors; macro semantics остаются фиксированными:
  protein orange, fat lime, carbs cyan.
- `lib/core/ui/` содержит используемые Дневником и Food Search primitives:
  `YamPrimaryButton`, `YamSecondaryButton`, `YamTextButton`, `YamIconButton`,
  `YamSearchField`, `YamFilterChip`, `YamMealChip`, `YamProductRow`,
  `YamQuantityControl`, `YamQuickAmountPresets`, `YamNutritionSummary`,
  `YamMealSectionHeader`, `YamDiaryFoodRow`, feedback/skeleton states,
  `YamSnackbar` и `YamProgressBar`. API принимают display values и callbacks и
  не зависят от feature prototype-моделей.

## Дневник

- `lib/features/diary/presentation/diary_screen.dart` соответствует approved
  hierarchy: закрепленный YAM header без mascot/profile, compact date selector,
  daily summary, meal cards и глобальный add FAB.
- Compact layout сохраняет отдельные slivers для selector, summary и lazy meal
  list. Wide layout сохраняет ограниченную двухколоночную композицию.
- `diary_day_selector.dart` использует компактную week strip, полные semantic
  dates, 44+ dp controls, selection motion и ограничение ширины на desktop.
- `daily_nutrition_summary.dart` показывает kcal, remaining/over-target state и
  подписанные macro progress indicators в обеих темах.
- `meal_section.dart` форматирует feature-data для shared
  `YamMealSectionHeader` и `YamDiaryFoodRow`; adaptive large-text layout,
  contextual add и tappable highlight state сохранены.
- Global и meal add продолжают открывать Food Search; result reveal, highlight
  и канонический floating `YamSnackbar` с Undo сохранены.
- Demo summary больше не захардкожен отдельно: kcal и Б/Ж/У вычисляются из
  видимых `DiaryPrototypeEntry`. Базовый день согласован на 1840 kcal,
  Б 126, Ж 61, У 184.
- Вода и profile/avatar намеренно отсутствуют.

## Остальной UI

- `lib/features/food_search/presentation/food_search_screen.dart` соответствует
  `agents/design/yam_food_search.html`: compact search header, contextual meal
  selector, create action, горизонтальные filters и плотные sectioned results.
- Header, search, meal/filter controls, product rows, loading/error/empty states
  и основные действия используют shared `Yam*` API. Feature widgets только
  форматируют localized display values и dispatch intent.
- `food_search_result_row.dart` сохраняет title/source/nutrition hierarchy,
  semantic macro colors, inline quick add на телефоне и adaptive stacking при
  200% text scale. Presentation fixtures разделяют breakfast suggestions и
  recent foods и содержат serving metadata из visual reference.
- `food_quick_add_sheet.dart` соответствует `agents/design/yam_add_food.html`:
  meal chip и close в header, product metadata, editable quantity stepper,
  unit menu, presets, плоский nutrition preview и динамический CTA с meal/kcal.
- Общий entry point по-прежнему требует meal, meal-specific entry сохраняет
  preselection; пересчёт нутриентов, возврат результата в Дневник и Undo
  сохранены по ADR 0007. Barcode, success-плашка и edit nutrition/name action
  намеренно не добавлены в отсутствие соответствующих маршрутов.
- Statistics и Settings пока route placeholders.
- Edit Diary Entry, Create Product, Goals и onboarding еще не реализованы.
- Tap по diary row сейчас показывает selection/highlight state; настоящий Edit
  Entry sheet будет подключен в своем slice.

## Проверка

- `dart format` изменённых Dart-файлов -- успешно.
- `flutter analyze` -- успешно, issues не найдено.
- Полный `flutter test` -- успешно, 41 тест.
- `test/core/ui/yam_components_test.dart` проверяет touch targets/callbacks,
  очистку поиска, narrow 200% product row и YAM Undo snackbar.
- Food Search golden verification покрывает compact dark RU, compact light EN,
  wide dark EN и compact dark RU при 200% text scale в
  `test/features/food_search/presentation/goldens/`.
- Add Food sheet отдельно покрыт compact light EN и compact dark RU goldens;
  widget-тест проверяет step, preset, unit switch, nutrition/CTA recalculation и
  отсутствие overflow при 200% text scale.
- Diary и Food Search golden baselines обновлены после component migration;
  compact/wide, light/dark, RU/EN и 200% text проверки проходят.
- Debug APK успешно собран, установлен и запущен на физическом Android 16 по
  Wi-Fi через `flutter run --debug --no-resident`.
- Отдельные performance-бенчмарки удалены согласно ADR 0008.

## Следующее Действие

- Реализовать Edit Diary Entry sheet по
  `agents/design/yam_edit_diary_entry.html`, переиспользуя готовые quantity,
  nutrition и button primitives.

## Блокеры

- Нет.
