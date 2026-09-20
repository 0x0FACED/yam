# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной
> задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-20.
- Стадия: visual implementation pass; Phase 2 и redesign Дневника завершены.
- Текущий статус: остановлено перед Food Search для визуального review Дневника.

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
- `lib/core/ui/nutrition/yam_progress_bar.dart` и
  `lib/core/ui/feedback/yam_undo_snack_bar.dart` являются минимальными shared
  primitives для уже повторяющихся progress/Undo patterns.

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
- `meal_section.dart` реализует meal time, kcal total, contextual add, плотные
  разделенные rows, adaptive large-text layout и tappable row state.
- Global и meal add продолжают открывать Food Search; result reveal, highlight
  и snackbar Undo сохранены.
- Demo summary больше не захардкожен отдельно: kcal и Б/Ж/У вычисляются из
  видимых `DiaryPrototypeEntry`. Базовый день согласован на 1840 kcal,
  Б 126, Ж 61, У 184.
- Вода и profile/avatar намеренно отсутствуют.

## Остальной UI

- Food Search и Add Food sheet пока остаются предыдущим presentation-прототипом
  и являются следующим visual slice после review.
- Statistics и Settings пока route placeholders.
- Edit Diary Entry, Create Product, Goals и onboarding еще не реализованы.
- Tap по diary row сейчас показывает selection/highlight state; настоящий Edit
  Entry sheet будет подключен в своем slice.

## Проверка

- `flutter gen-l10n` и `dart format lib test` -- успешно.
- `flutter analyze` -- успешно, issues не найдено.
- `flutter test` -- успешно, 27 тестов.
- Добавлены unit tests derived diary totals и theme semantics.
- Golden verification покрывает compact light RU, compact dark EN, wide light
  EN и compact dark RU при 200% text scale в
  `test/features/diary/presentation/goldens/`.
- Отдельные performance-бенчмарки удалены согласно ADR 0008.

## Следующее Действие

- После review Дневника начать redesign Food Search по
  `agents/design/yam_food_search.html`, не переходя к Add Food sheet раньше
  завершения этого slice.

## Блокеры

- Нет.
