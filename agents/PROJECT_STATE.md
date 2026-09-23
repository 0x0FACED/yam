# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной
> задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-23.
- Стадия: visual implementation pass; Дневник, Food Search, Add Food sheet и
  Settings реализованы по approved references.
- Текущий статус: Diary доработан по пользовательским замечаниям;
  Food Search и Settings остаются в presentation-prototype scope.

## Авторитетные Источники

- Правила работы: `AGENTS.md`.
- Product/architecture blueprint: `agents/PROJECT_BLUEPRINT.md`.
- Принятые решения: `docs/adr/`.
- Визуальная иерархия источников: `agents/design/README.md`.
- Визуальное направление и токены: `docs/adr/0003-design-direction.md`.
- Adaptive shell: `docs/adr/0004-adaptive-navigation.md`.
- UX presentation-flow добавления еды: `docs/adr/0007-add-food-visual-prototype.md`.
- Settings presentation и session-only theme: ADR 0009.
- Приоритет screen-level composition над component catalogue: ADR 0010.
- Навигация по датам и оба входа в добавление еды: ADR 0011. Он заменяет
  решение ADR 0010 об удалении глобального Diary FAB.
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
  warning и goal-status colors; macro semantics сохраняют protein orange,
  fat lime, carbs cyan. Светлая тема использует более тёмный lime для жиров
  (`AppColors.lightFat`), тёмная — исходный `AppColors.fat`.
- `lib/core/ui/` содержит используемые Дневником и Food Search primitives:
  `YamPrimaryButton`, `YamSecondaryButton`, `YamTextButton`, `YamIconButton`,
  `YamSearchField`, `YamFilterChip`, `YamMealChip`, `YamProductRow`,
  `YamQuantityControl`, `YamQuickAmountPresets`, `YamNutritionSummary`,
  `YamMealSectionHeader`, `YamDiaryFoodRow`, `YamSettingsSection`,
  `YamSettingsRow`, feedback/skeleton states, `YamSnackbar` и `YamProgressBar`.
  API принимают display values и callbacks и не зависят от feature
  prototype-моделей.
- Shared controls разделяют visual geometry и accessibility geometry: compact
  icon/chip/quick-add presentation сохраняет touch target не меньше 44 dp.

## Дневник

- `lib/features/diary/presentation/diary_screen.dart` содержит закрепленный YAM
  header, compact date selector, daily summary и meal cards. Закреплённая кнопка
  возврата к сегодня появляется в header при просмотре других дат, не сдвигая
  контент. Фиолетовый FAB вновь ведёт в общий Food Search с выбором приёма
  пищи по ADR 0011; нижний inset не даёт ему закрывать последний приём.
- В Diary через локальный `ScrollConfiguration` восстановлен штатный Android
  stretch overscroll; глобальное поведение других экранов не изменено.
- Compact layout сохраняет отдельные slivers для selector, summary и lazy meal
  list. Wide layout сохраняет ограниченную двухколоночную композицию.
- `diary_day_selector.dart` использует компактную week strip, полные semantic
  dates, 44+ dp controls и selection motion. Точка под сегодняшней датой
  сохраняется при выборе другого дня; область маркера зарезервирована у всех
  дат для стабильной высоты selector.
- Верхние промежутки между selector/summary/meals выровнены по screen-reference
  density; нижний content inset учитывает FAB без лишнего padding у shell navigation.
- `daily_nutrition_summary.dart` показывает kcal, remaining/over-target state и
  подписанные macro progress indicators в обеих темах.
- `meal_section.dart` форматирует feature-data для shared
  `YamMealSectionHeader` и `YamDiaryFoodRow`; верхний отступ карточки уменьшен,
  видимая контекстная «+» увеличена до 36 dp при 44+ dp hit target, калории
  разделены на число и приглушённую единицу. Adaptive large-text layout,
  contextual add и tappable highlight state сохранены.
- Compact contextual add каждого meal открывает Food Search с preselection;
  result reveal, highlight и канонический floating `YamSnackbar` с Undo
  сохранены.
- Demo summary больше не захардкожен отдельно: kcal и Б/Ж/У вычисляются из
  видимых `DiaryPrototypeEntry`. Базовый день согласован на 1840 kcal,
  Б 126, Ж 61, У 184.
- Вода и profile/avatar намеренно отсутствуют.

## Остальной UI

- `lib/features/food_search/presentation/food_search_screen.dart` соответствует
  `agents/design/yam_food_search.html`: compact search header, contextual meal
  selector, create action, горизонтальные pill filters и плотные sectioned
  results. Task-content ограничен 448 dp и центрируется на wide layouts.
- Header, search, meal/filter controls, product rows, loading/error/empty states
  и основные действия используют shared `Yam*` API. Feature widgets только
  форматируют localized display values и dispatch intent.
- `food_search_result_row.dart` сохраняет title/source/nutrition hierarchy,
  semantic macro colors, inline quick add на телефоне и adaptive stacking при
  200% text scale. Presentation fixtures разделяют breakfast suggestions и
  recent foods и содержат serving metadata из visual reference.
- Quick-add имеет компактную 32 dp visual surface внутри 44 dp touch target;
  Recent можно очистить в памяти текущей search session.
- `food_quick_add_sheet.dart` соответствует `agents/design/yam_add_food.html`:
  meal chip и close в header, product metadata, editable quantity stepper,
  unit menu, presets, плоский nutrition preview и динамический CTA с meal/kcal.
- Add Food close и quantity step controls используют компактные 32/36 dp
  visual surfaces внутри 44 dp targets; usual-amount metadata всегда выровнена
  по правой content-границе.
- Общий entry point по-прежнему требует meal, meal-specific entry сохраняет
  preselection; пересчёт нутриентов, возврат результата в Дневник и Undo
  сохранены по ADR 0007. Barcode, success-плашка и edit nutrition/name action
  намеренно не добавлены в отсутствие соответствующих маршрутов.
- `lib/features/settings/presentation/settings_screen.dart` реализует compact и
  wide grouped-list layout: goals/weight summary, app preferences, data state и
  About/version. Theme picker реально переключает System/Light/Dark на время
  текущего запуска через app-level `ValueNotifier<ThemeMode>` по ADR 0009.
- Units/language/goals/data rows не имитируют persistence или отсутствующие
  маршруты; export/delete явно помечены недоступными. Group surfaces, row
  density и 56 dp header выровнены по screen reference без тяжёлых outlines.
- `YamSettingsRow` растягивает trailing-область до правого края; values больше
  не остаются около центра при коротком тексте.
- Statistics пока остаётся route placeholder.
- Edit Diary Entry, Create Product, Goals и onboarding еще не реализованы.
- Tap по diary row сейчас показывает selection/highlight state; настоящий Edit
  Entry sheet будет подключен в своем slice.

## Проверка

- `dart format` изменённых Dart-файлов -- успешно.
- `flutter analyze` -- успешно, issues не найдено.
- Целевые и все прочие non-golden тесты с golden Дневника: 45 passed.
  Проверены стабильная геометрия selector при смене дня, возврат из другой
  недели, Android stretch widget, FAB и доступность последнего приёма, контраст
  light fat. Diary goldens обновлены для compact/wide, light/dark и 200% текста,
  добавлен снимок выбранного вчерашнего дня.
- Полный `flutter test` запущен: 8 несовпадений старых golden Food Search и
  Settings (в light Food Search меняется fat token; dark Settings тоже расходится
  из-за рендеринга шрифтов при отсутствии UI-изменений); их эталоны не
  перезаписаны. Найденное в том же прогоне старое ожидание
  общего цвета жиров в `test/app/theme/app_theme_test.dart` исправлено; после
  него 45 целевых и non-golden проверок проходят.
- `test/core/ui/yam_components_test.dart` проверяет touch targets/callbacks,
  очистку поиска, narrow 200% product row и YAM Undo snackbar.
- Widget-тесты дополнительно фиксируют right-edge alignment для quick amount и
  Settings values; compact icon controls сохраняют 44 dp hit target.
- Food Search golden verification покрывает compact dark RU, compact light EN,
  wide dark EN и compact dark RU при 200% text scale в
  `test/features/food_search/presentation/goldens/`.
- Add Food sheet отдельно покрыт compact light EN и compact dark RU goldens;
  widget-тест проверяет step, preset, unit switch, nutrition/CTA recalculation и
  отсутствие overflow при 200% text scale.
- Diary goldens после ADR 0011 проходят; существующие Food Search и Settings
  goldens требуют отдельной проверки воспроизводимости рендерера.
- Settings покрыт compact dark RU и wide light EN goldens; widget-тесты
  проверяют реальное session theme switching, About и layout при 200% text.
- Отдельные performance-бенчмарки удалены согласно ADR 0008.

## Следующее Действие

- Сверить Food Search и Settings golden с окружением, где были созданы
  исходные эталоны, и восстановить воспроизводимость полного `flutter test`.

## Блокеры

- Полный прогон блокируют 8 несовпадений Food Search/Settings golden
  (смена light fat token и расхождение рендеринга шрифтов); реализация Edit
  Diary Entry пока не начата.
