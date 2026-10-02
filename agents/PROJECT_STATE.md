# Состояние Проекта

> Краткий handoff. Подробная хронология — в Git; рабочие правила — в `AGENTS.md`.

## Обновлено

- Дата: 2026-09-28.
- Стадия: local-first MVP с необязательным поиском Open Food Facts (OFF).
- SQLite `yam` имеет schema v4. Локальные данные и Дневник работают без сети;
  онбординг обязателен при первом запуске.

## Решения И Источники

- `docs/adr/0021-open-food-facts-search-and-selected-cache.md` — OFF-секция,
  local-first/debounce, выборочный кэш и аддитивная миграция v3→v4; заменяет
  отсрочку remote search ADR 0001, прототипный поиск ADR 0007 и scope этого
  handoff. Три вкладки и правило цельной строки из ADR 0012 сохраняются.
- Дизайн: `agents/design/README.md`, ADR 0003/0010/0011/0012,
  `agents/design/yam_food_search.html` и `yam_components_2.html`. Экранный
  HTML уступает ADR 0012 там, где показывает «Для вас», выдуманные подборки,
  отдельный quick add или verified badge.
- Остальной продуктовый и data contract: ADR 0001/0002/0015/0016/0017/0018/
  0019/0020 и соответствующие разделы `agents/PROJECT_BLUEPRINT.md`.
- `docs/adr/0022-local-brand-suggestions.md`: подсказки из локальных брендов
  UserFoods/RemoteFoods без изменения схемы; произвольный ввод сохраняется.
- `docs/adr/0023-edit-user-foods.md`: редактировать можно только активные
  UserFoods из «Моих блюд», без изменения существующих снимков Дневника;
  ккал вычисляются по ADR 0017, схема БД остаётся v4.

## Реализовано

- `lib/app/app.dart` и `router.dart`: локализованный adaptive shell с Дневником,
  Статистикой и Настройками; `/add-food` — task-screen. Первый запуск требует
  онбординга; ошибка начальной загрузки ведёт к Retry, а не к пустому профилю.
  Тема System/Light/Dark сессионная.
- `lib/core/data/yam_database.dart`: Drift/SQLite schema v4, UUID v7 для
  пользовательских данных, installation deviceId, soft delete, UTC metadata,
  локальные diary dates; существующее имя базы `yam` не менялось. Миграции
  v1→v2→v3→v4 оставляют старые таблицы и записи нетронутыми. Экспорты схем
  v1–v4 и generated fixtures в `test/features/food_search/data/`.
- `lib/features/food_search/data/open_food_facts_client.dart`: инъецируемый
  Search-a-licious GET-клиент с User-Agent, запросом 15 результатов и нужных
  полей, интервалом ≥6 с. Нормализация отбрасывает неполные/некорректные
  КБЖУ; `_100g` остаётся на 100 г, объём не переводится в массу, порции из
  упаковки не выводятся. ID поиска — `off:<code>`.
- `lib/features/food_search/data/remote_food_repository.dart`: отдельная
  таблица OFF с source+code, UUID v7 локальной записи, точными нутриентами,
  избранным и метаданными. Результаты запросов не сохраняются; выбор для
  избранного или Дневника сохраняется. Добавление в кэш и Дневник происходит
  в одной транзакции; последнее выбранное количество запоминается. OFF не
  попадает в «Мои блюда»; кэш доступен при локальном
  поиске, в Recent и Избранном после перезапуска.
- `lib/features/food_search/presentation/food_search_screen.dart`:
  «Недавние»/«Мои блюда»/«Избранное» остаются локальными. При запросе от трёх
  символов локальная выдача появляется сразу, ниже OFF-секция после debounce
  650 мс. Её loading/empty/error/Retry не перекрывают локальные продукты;
  поздние ответы старого запроса игнорируются. Результат открывает прежний
  quantity/meal sheet; добавление оставляет поиск открытым и поддерживает Undo.
  В секции — ссылки на OFF и ODbL; бренд/категория показываются по ADR 0012.
  `remote_food_adapter.dart` использует существующую модель и UI-компоненты.
- `lib/features/diary/data/diary_repository.dart` хранит неизменяемые снимки
  имени, базиса, порций и точных нутриентов; изменение OFF-кэша не пересчитывает
  историю. Recent берётся из реальных записей SQLite. Обычный flow Diary,
  edit sheet и статистика сохранены.
- `diary_prototype_data.dart`, `meal_section.dart` и `yam_diary_rows.dart`:
  фиктивное время убрано из модели и заголовков приёмов в узкой/широкой
  компоновке. `lib/app/theme/app_theme.dart` задаёт поверхности, контраст и
  форму стандартного календаря через DatePickerTheme для Light и Dark;
  выбранное сегодня использует контрастный `onPrimary`, невыбранное сегодня —
  `primary` через штатные Material state defaults. Правила выбора дат не менялись.
- `lib/features/food_search/data/user_food_repository.dart`: атомарное
  обновление UserFood и порций с сохранением ID/метаданных, soft delete
  удалённых порций и исключением собственного штрихкода при проверке.
  `loadFoods()` выполняет прямое согласованное чтение вместо ожидания stream.
- `lib/features/food_search/presentation/user_food_form_screen.dart`:
  общая форма создания/редактирования; сохранённые поля и порции загружаются
  без округления, основной ID порции и `defaultAmount` сохраняются. Подсказки
  локальных брендов доступны мышью, касанием и клавиатурой.
- `food_search_screen.dart`, `widgets/food_search_result_row.dart` и
  `lib/app/router.dart`: меню «Ещё» только у UserFood в «Моих блюдах», пункты
  правки/удаления и маршрут `/add-food/edit`; тап по строке и long-press delete
  сохранены. RU/EN строки в ARB и generated l10n.
- Для внешних ссылок добавлен `url_launcher`; Android main manifest разрешает
  INTERNET, macOS sandbox — исходящие соединения.

## Проверка

- `flutter gen-l10n`, `dart format` изменённых Dart-файлов,
  `flutter analyze`, `git diff --check` — выполнены.
- Четыре целевых файла `flutter test` (UserFoodRepository, форма, Food Search,
  DiaryRepository) — пройдены с `NO_PROXY=localhost,127.0.0.1` и ограничением
  запуска тестов одной минутой. Проверены атомарность/метаданные порций,
  предзаполнение, редактирование через меню в EN/RU, fallback маршрута,
  сохранение прежних снимков и новые значения в последующих записях Дневника.
- Запуск Linux не состоялся: существующая конфигурация сборки JNI ссылается
  на отсутствующий `/usr/lib/jvm/java-26-openjdk/lib/server/libjvm.so`.
  Повторный запуск с установленным JDK 17 не переконфигурировал Ninja.
  После просьбы пользователя запуск на устройстве прекращён; ручная
  визуальная проверка не выполнялась.

## Следующее Действие

- Исправить переход Дневника на новый локальный день после полуночи/возврата
  из фона, сохраняя вручную выбранную историческую дату.

## Блокеры

- Тема и избранное встроенных fixture пока сессионные; export/import нет.
  Текущий Flutter SDK требует pinned Drift 2.31 / drift_flutter 0.2.4.
  iOS build на Linux и ручная проверка OFF на устройствах не проводились.
  Старые Diary/Food Search/Settings goldens требуют пересъёмки. Ручную приёмку
  Light/Dark календаря и брендов на устройстве ещё нужно провести.
