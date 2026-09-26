# Состояние Проекта

> Краткий handoff для следующего агента. Обновлять после каждой содержательной
> задачи; не превращать в хронологический журнал.

## Обновлено

- Дата: 2026-09-25.
- Стадия: local-first MVP; Дневник, Food Search, Add Food, Settings и
  Statistics доступны в локальном приложении.
- Текущий статус: продукты, Дневник, цели и вес хранятся в SQLite v3;
  статистика строится из сохранённой истории. Первый запуск теперь требует
  завершения онбординга, затем открывается Дневник.

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
- Онбординг по кнопке из Настроек и motion до persistence:
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
- `docs/adr/0019-real-statistics-and-persisted-goals.md`: статистика по реальным
  данным, вес и версии целей в SQLite; заменяет сессионность и демо-значения
  онбординга ADR 0013, не меняет session-only тему ADR 0009.
- `docs/adr/0020-required-first-launch-onboarding.md` заменяет решение ADR
  0013/0019 не показывать онбординг при первом запуске; повторный вход из
  Настроек по-прежнему можно отменить.
- Performance-оптимизация до реальной проблемы отложена ADR 0008; обязательных
  profile-бенчмарков и числовых бюджетов у MVP нет.

## Зафиксированный Scope Визуального Прохода

- Основные разделы: Дневник, Статистика, Настройки.
- Onboarding: Цель -> Вес -> Цели питания; `/onboarding` — отдельный flow из
  Настроек и обязательный первый flow; до сохранения целей основные маршруты
  заблокированы. Первые числовые поля пусты.
- Goals редактирует только kcal, белки, жиры, углеводы, текущий и целевой вес.
- Hydration/water и account/profile UI не входят в текущий проход.
- Barcode scanning не реализуется; в Create Product допустим ручной barcode.
- Add Food action редактирования nutrition/name не показывается без маршрута.
- Сохраняются свои продукты, порции, избранное, дневные записи, вес и цели;
  Recent вычисляется из записей. Builtin-каталог остаётся fixture; remote API,
  sync и account не строятся.

## Реализованная Основа

- `lib/app/app.dart` запускает локализованный `MaterialApp.router` с System,
  Light/Dark, startup-intro и `YamEntranceScope`. Профиль/вес загружаются из
  SQLite в `ValueNotifier` и обновляют Diary/Settings; тема только в памяти.
  `OnboardingAccess` ждёт первичных потоков целей и веса: при отсутствии
  активных `goal_versions` нужен онбординг; ошибка БД ведёт в retry state,
  а не в форму как будто данные пусты. Отдельного флага в схеме нет.
- `YamDatabase` в `lib/core/data/yam_database.dart` (Drift/SQLite) создаётся
  в `YamApp`; схема v3: продукты/порции, Дневник, `weight_entries`,
  `goal_versions` и installation deviceId. Экспорты v1/v2/v3, генерация и
  тесты миграций v1/v2→v3 — в `test/features/`. Persisted user records используют
  UUID v7, UTC metadata, локальный календарный день и soft delete.
- Startup использует фон темы и SVG для обеих тем по ADR 0003; тема остаётся
  session-only по ADR 0009.
- Нативный launch-фон совпадает с `AppTheme`: Android использует day/night
  `yam_launch_background` (включая Android 12+ splash), iOS — адаптивный
  `LaunchBackground.colorset` в `LaunchScreen.storyboard`.
- `lib/app/router.dart` использует `StatefulShellRoute.indexedStack` для Diary,
  Statistics и Settings; `/add-food` и `/onboarding` — task-screen над shell.
  GoRouter redirect до окончания первого онбординга блокирует все основные
  маршруты. `/startup-check` показывает локализованную загрузку/Retry.
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
- `YamRepeatIconButton` ускоряет ±1 при удержании; `YamSnackBar` через общий
  overlay показывает success и Undo поверх экранов/sheet по `AppMotion`.

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
- `daily_nutrition_summary.dart` показывает kcal и macro progress при наличии
  сохранённой цели; без неё нет вымышленной нормы 2200 ккал.
- `meal_section.dart` форматирует сохранённые записи для shared
  `YamMealSectionHeader` и `YamDiaryFoodRow`; add/highlight и крупный текст
  поддерживаются.
- `DiaryScreen` подписывается на выбранный локальный день; никаких демо-записей
  нет. Контекстный и общий Add Food сохраняют точные записи через
  `DiaryRepository`; экран поиска остаётся открыт, Undo и подсветка последнего
  добавления работают. Итоги суммируют точные сохранённые нутриенты до
  округления отображения. Цели приходят из сохранённой версии профиля.
- Тап по записи открывает `edit_diary_entry_sheet.dart`: количество и единицы,
  приём пищи через `YamDropdown`, предпросмотр КБЖУ, Save и корзина. Удаление
  soft delete без диалога с Undo; закрытие sheet отменяет несохранённые правки.
  Редактирование использует снимки порций и КБЖУ, поэтому работает даже после
  удаления источника из каталога. Выбранный день остаётся прежним.

## Остальной UI

- `onboarding_screen.dart` сохраняет три локализованных шага с progress/reveal;
  при первом открытии нет примеров из HTML. Завершение атомарно записывает
  версию целей и первое/изменённое измерение веса через `StatisticsRepository`;
  обязательный flow нельзя закрыть или обойти Back, из Настроек можно отменить.
  Ккал и БЖУ независимы, подсказка 4/9/4 остаётся.
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
  записей Дневника не изменяются. Схема БД теперь v3; тестовые старые ккал
  специально не пересчитываются (ADR 0017, до релиза 1.0.0).
- Общий entry point по-прежнему требует meal, meal-specific entry сохраняет
  preselection; пересчёт нутриентов и Undo сохранены по ADR 0007/0012/0015.
  Barcode и edit nutrition/name action не добавлены без маршрутов.
- `lib/features/settings/presentation/settings_screen.dart` реализует compact и
  wide grouped-list layout: goals/weight summary, app preferences, data state и
  About/version. Theme picker реально переключает System/Light/Dark на время
  текущего запуска через app-level `ValueNotifier<ThemeMode>` по ADR 0009.
- В Goals-секции Settings есть действие «Пройти онбординг»; завершение
  возвращает сюда и сразу обновляет сохранённые вес и цели в Settings/Diary;
  при отсутствии данных показаны честные пустые подписи.
- Units/language/goals/data rows не имитируют persistence или отсутствующие
  маршруты; export/delete явно помечены недоступными. Group surfaces, row
  density и 56 dp header выровнены по screen reference без тяжёлых outlines.
- `lib/features/statistics/` показывает статистику 7/30/90/365 дней и «Всё»
  по агрегированным `diary_entries`, `weight_entries`, `goal_versions`.
  `StatisticsRepository` наблюдает локальные потоки, `statistics_models.dart`
  вычисляет средние только за дни с едой и регулярность ±10% по цели на дату.
  Карточки, CustomPainter-графики, БЖУ и heatmap используют Flutter tokens;
  ввод/правка веса с датой и Undo — в `weight_entry_sheet.dart`. Пустые данные
  не подменяются графиками. Тема, единицы/язык — по-прежнему session/system.
- Отдельный Goals editor ещё не реализован.

## Проверка

- `flutter gen-l10n`, `dart format`, `flutter analyze`, `git diff --check` —
  успешно. Два route/widget-теста проверили обязательный flow, повторный вход
  из Settings и Retry; прицельный тест БД подтвердил, что удаление веса не
  сбрасывает цели. Settings theme test после загрузки сохранённого профиля
  прошёл. Полный UI suite/goldens не запускались; визуальную приёмку делает
  пользователь вручную.

## Следующее Действие

- Исправить переход Дневника на новый локальный день после полуночи/возврата
  из фона, сохраняя вручную выбранную историческую дату.

## Блокеры

- Тема и избранное builtin fixture по-прежнему живут в памяти.
  Текущий Flutter SDK требует pinned Drift 2.31 / drift_flutter 0.2.4;
  export/import отсутствует, поэтому нет встроенного восстановления данных.
  iOS сборка на Linux и ручная проверка первого запуска не проводились.
  Старые Diary/Food Search/Settings goldens требуют пересъёмки после изменений.
