# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной
> задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-25.
- Стадия: visual implementation pass; Дневник, Food Search, Add Food sheet и
  Settings реализованы по approved references.
- Текущий статус: пользовательские продукты и записи Дневника хранятся в
  SQLite v2; Дневник пуст при новом запуске и поддерживает edit/delete с Undo.

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
- Упрощённый Food Search, реальные recent за текущую сессию и метаданные:
  `docs/adr/0012-food-search-interactions.md`. Он заменяет в текущем прототипе
  контракт one-tap quick add из ADR 0002/0007.
- Онбординг по кнопке из Настроек, session-значения и motion:
  `docs/adr/0013-onboarding-session-and-motion.md`.
- Неподвижный progress и независимые цели КБЖУ с подсказкой 4/9/4:
  `docs/adr/0014-onboarding-progress-and-macro-goals.md` уточняет ADR 0013.
- Добавление нескольких продуктов, избранное и единицы в sheet:
  `docs/adr/0015-add-food-sheet-and-session-flow.md` заменяет в ADR 0007
  автоматический возврат в Дневник после добавления.
- Локальный каталог созданных продуктов: `docs/adr/0016-persist-custom-foods.md`;
  builtin fixtures остаются частью приложения, Дневник сохраняется по ADR 0018.
- Ккал из БЖУ, удаление и поле-селектор категории: принятое
  `docs/adr/0017-custom-food-follow-up.md` заменяет в ADR 0016 правило
  независимого ручного ввода ккал новых продуктов.
- `docs/adr/0018-persist-and-edit-diary-entries.md`: сохраняемый Дневник без
  демо-записей, точные снимки и edit bottom sheet; завершает in-memory
  ограничения ADR 0007/0012/0015 для записей и Recent.
- Performance-оптимизация до реальной проблемы отложена ADR 0008; обязательных
  profile-бенчмарков и числовых бюджетов у MVP нет.

## Зафиксированный Scope Визуального Прохода

- Основные разделы: Дневник, Статистика, Настройки.
- Onboarding: Цель -> Вес -> Цели питания; `/onboarding` — отдельный flow из
  Настроек без изменения cold-start до появления persisted state.
- Goals редактирует только kcal, белки, жиры, углеводы, текущий и целевой вес.
- Hydration/water и account/profile UI не входят в текущий проход.
- Barcode scanning не реализуется; в Create Product допустим ручной barcode.
- Add Food action редактирования nutrition/name не показывается без маршрута.
- Сохраняются свои продукты, порции, избранное и дневные записи; Recent
  вычисляется из записей. Встроенный каталог остаётся fixture; remote API,
  sync и account не строятся.

## Реализованная Основа

- `lib/app/app.dart` запускает локализованный `MaterialApp.router` с System,
  Light и Dark themes и существующим startup-intro; `SessionProfile` живёт
  в `ValueNotifier` только до перезапуска, `YamEntranceScope` запускает
  одноразовое мягкое проявление семантических блоков после интро/онбординга.
- `YamDatabase` в `lib/core/data/yam_database.dart` (Drift/SQLite) создаётся
  в `YamApp` вместе с `UserFoodRepository` и `DiaryRepository`. Схема v2:
  user foods, servings, diary entries и installation deviceId. Экспорт v1/v2,
  сгенерированный schema helper и миграционный тест в `test/features/`;
  UUID v7, UTC metadata и soft delete у всех сохранённых сущностей.
- `startup_screen.dart` берёт фон интро из `Theme.scaffoldBackgroundColor`;
  `startup_artwork.dart` заранее загружает SVG для обеих тем и заменяет только
  тёмные ink-заливки на `AppColors.darkTextPrimary` в dark-версии. Для fallback
  SVG используется тот же `ColorMapper`. Это следует ADR 0003; выбор темы
  по-прежнему session-only по ADR 0009.
- Нативный launch-фон совпадает с `AppTheme`: Android использует day/night
  `yam_launch_background` (включая Android 12+ splash), iOS — адаптивный
  `LaunchBackground.colorset` в `LaunchScreen.storyboard`.
- `lib/app/router.dart` использует `StatefulShellRoute.indexedStack` для Diary,
  Statistics и Settings; `/add-food` и `/onboarding` — task-screen над shell.
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
- Переиспользуемые `YamChoiceCard`, `YamNumberField`, `YamStepProgress`,
  `YamEntranceReveal` находятся в `lib/core/ui/`; длительности/кривые —
  в `lib/app/theme/app_motion.dart`. Reveal использует только opacity без
  перемещения/масштаба и уважает `MediaQuery.disableAnimations`.
- `YamTextField` в `lib/core/ui/forms/` используется для названия, бренда и
  штрихкода; `YamSelectField` — полноширинное поле категории без ввода.
  `lib/core/ui/selection/yam_dropdown.dart` задаёт общую компактную поверхность
  списка, выбранное состояние, клавиатурный фокус и прокрутку длинных меню.
- `YamGoalSliderField` в `lib/core/ui/forms/` объединяет точный числовой ввод
  с ползунком (шаг 5 г, диапазон расширяется для введённых вручную значений).
  `YamNumberField` использует более крупную каноническую типографику и
  увеличенную поверхность для веса, ккал и значений БЖУ.
- `YamRepeatIconButton` в `lib/core/ui/buttons/` делает одно изменение по тапу,
  затем ускоряет повторение единичных шагов при удержании; прекращает его на
  отпускании/свайпе/закрытии. `YamSnackBar` теперь подходит и для success без
  действия: общий overlay presenter в `yam_snack_bar.dart` показывает его и
  Undo поверх экранов/sheet. Оба пути используют fade-in 220 мс и fade-out
  180 мс из `AppMotion`, у action-текста остаётся доступный Undo, success без
  действия не перекрывает нажатия на sheet; при смене уведомления старое
  заменяется без наложения.
- Shared controls разделяют visual geometry и accessibility geometry: compact
  icon/chip presentation сохраняет touch target не меньше 44 dp; у
  `YamFilterChip` и `YamMealChip` ripple ограничен видимой pill-поверхностью.

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
- `daily_nutrition_summary.dart` показывает kcal, remaining/over-target state и
  подписанные macro progress indicators в обеих темах.
- `meal_section.dart` форматирует feature-data для shared
  `YamMealSectionHeader` и `YamDiaryFoodRow`; верхний отступ карточки уменьшен,
  видимая контекстная «+» увеличена до 36 dp при 44+ dp hit target, калории
  разделены на число и приглушённую единицу. Adaptive large-text layout,
  contextual add и tappable highlight state сохранены.
- `DiaryScreen` подписывается на выбранный локальный день; никаких демо-записей
  нет. Контекстный и общий Add Food сохраняют точные записи через
  `DiaryRepository`; экран поиска остаётся открыт, Undo и подсветка последнего
  добавления работают. Итоги суммируют точные сохранённые нутриенты до
  округления отображения. Цели по-прежнему из `SessionProfile` текущего запуска.
- Тап по записи открывает `edit_diary_entry_sheet.dart`: количество и единицы,
  приём пищи через `YamDropdown`, предпросмотр КБЖУ, Save и корзина. Удаление
  soft delete без диалога с Undo; закрытие sheet отменяет несохранённые правки.
  Редактирование использует снимки порций и КБЖУ, поэтому работает даже после
  удаления источника из каталога. Выбранный день остаётся прежним.

## Остальной UI

- `lib/features/onboarding/presentation/onboarding_screen.dart` реализует
  три локализованных шага по эталонам (файлы 1 → 3 → 2). Фиксированная шапка
  показывает единую плашку «Шаг X из 3» и плавно заполняющиеся сегменты;
  перелистывается только контент. Back/Close остаются в одном слоте. Исходные
  значения из HTML примеров, повторное открытие подставляет сессию; отмена не
  сохраняет ввод. Ккал и БЖУ независимы: `onboarding_input.dart` вычисляет
  только информативную энергию 4/9/4 и разницу с целью (демо +35 ккал), скрывая
  подсказку при невалидном вводе. Inline-валидация остаётся.
- `lib/features/food_search/presentation/food_search_screen.dart` содержит
  compact search header, contextual meal selector, create action и три вкладки:
  Недавние (по умолчанию), Мои блюда и Избранное. Вход не открывает клавиатуру;
  поле фокусируется по нажатию. Для вертикального списка включён штатный
  Android stretch overscroll даже при коротком/пустом содержимом. Task-content
  ограничен 448 dp и центрируется на wide layouts.
- Food Search наблюдает локальные user foods, объединяет их с demo fixtures,
  использует сохранённое избранное у созданных продуктов и session-флаги у
  fixture. Сохранение возвращает во вкладку «Мои блюда», очистив запрос,
  и не открывает sheet автоматически; выбранный приём сохраняется.
- Header, search, meal/filter controls, product rows, loading/error/empty states
  и основные действия используют shared `Yam*` API. Feature widgets только
  форматируют localized display values и dispatch intent.
- `YamProductRow`/`food_search_result_row.dart`: нажатие и подсветка охватывают
  всю строку и открывают sheet количества; отдельного inline quick add и
  галочки verified нет. Перед названием избранного продукта стоит звезда;
  вторичная строка показывает локализованную категорию и фактический бренд
  через ` · ` (без подмены источником каталога и порцией).
- Recent теперь приходят из четырёх последних разных продуктов в SQLite
  (включая предыдущие запуски); Undo и удаление меняют выдачу. Fixture-избранное
  остаётся сессионным, избранное созданных продуктов персистентно. Категории
  локализованы в `lib/l10n/`, включая «Другое».
- `food_quick_add_sheet.dart` сохраняет meal chip, editable quantity, presets и
  nutrition preview; CTA без повторения ккал закрывает только sheet. Выбранный
  в sheet приём запоминается для следующего продукта. Избранное переключается
  звездой с доступным SnackBar поверх sheet. Meal chip открывает общий
  `YamDropdown` с иконками и отметкой выбранного приёма.
- `YamQuantityControl` показывает поддерживаемые единицы открытой строкой
  вместо PopupMenu, крупное число и `+`/`−` с радиусом как в Дневнике. При
  смене единицы физический объём/масса остаётся прежним: точное значение
  хранится отдельно от округлённого текстового отображения, размер порции
  указан под контролом. Тап шага ±1, удержание ускоряет повтор.
- `food_search_prototype_data.dart` задаёт граммы и порции для всех твёрдых
  fixture-продуктов, 55 г на яйцо, а для жидкостей мл/стакан/порцию без
  допущения мл = г. Для пользовательского продукта единицы и коэффициенты
  задаются при создании, дополнительная порция не обязательна.
- `create_product_screen.dart` реализует `/add-food/create`: название,
  полноширинный селектор категории, бренд, базис 100 г/100 мл/1 порция
  (с обязательным эквивалентом), БЖУ, дополнительные единицы и ручной
  штрихкод. `custom_food.dart` вычисляет ккал 4/9/4 на выбранный базис;
  превью округляется только для UI, сохранение продукта+порций атомарное.
- Удержание строки в «Моих блюдах» открывает локализованный диалог; подтверждение
  в `user_food_repository.dart` атомарно ставит `deletedAt` продукту и порциям,
  освобождает штрихкод и исключает продукт из поиска/избранного. Снимки
  записей Дневника не изменяются. Схема БД теперь v2; тестовые старые ккал
  специально не пересчитываются (ADR 0017, до релиза 1.0.0).
- Общий entry point по-прежнему требует meal, meal-specific entry сохраняет
  preselection; пересчёт нутриентов и Undo сохранены по ADR 0007/0012/0015.
  Barcode и edit nutrition/name action не добавлены без маршрутов.
- `lib/features/settings/presentation/settings_screen.dart` реализует compact и
  wide grouped-list layout: goals/weight summary, app preferences, data state и
  About/version. Theme picker реально переключает System/Light/Dark на время
  текущего запуска через app-level `ValueNotifier<ThemeMode>` по ADR 0009.
- В Goals-секции Settings есть действие «Пройти онбординг»; завершение
  возвращает сюда и сразу обновляет summary веса и целей. Введённые цели
  одновременно отражаются в Diary.
- Units/language/goals/data rows не имитируют persistence или отсутствующие
  маршруты; export/delete явно помечены недоступными. Group surfaces, row
  density и 56 dp header выровнены по screen reference без тяжёлых outlines.
- `YamSettingsRow` растягивает trailing-область до правого края; values больше
  не остаются около центра при коротком тексте.
- Statistics пока остаётся route placeholder.
- Отдельный Goals editor ещё не реализован.

## Проверка

- `dart run build_runner build --delete-conflicting-outputs`, `flutter gen-l10n`,
  `dart format`, `flutter analyze`, `git diff --check` — успешно. С разрешения
  пользователя запущены только 5 прицельных файлов тестов (11 тестов):
  миграция v1→v2 с продуктом, повторное открытие Дневника, edit/delete/Undo,
  точность и прежний food repository — все прошли. UI-тесты не запускались;
  визуальное поведение проверяется вручную.

## Следующее Действие

- Вручную проверить добавление, редактирование и Undo записи после перезапуска
  в обеих темах, включая крупный текст и выбор другого приёма пищи.

## Блокеры

- Тема, цели, вес и избранное builtin fixture по-прежнему живут в памяти.
  Текущий Flutter SDK требует pinned Drift 2.31 / drift_flutter 0.2.4;
  iOS сборка на Linux и ручная UI-проверка edit sheet не проводились.
  Старые Diary/Food Search goldens не соответствуют обновлённым экранам.
