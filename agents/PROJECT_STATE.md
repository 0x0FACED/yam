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
- `user_food_repository.dart` читает бренды неудалённых UserFoods и RemoteFoods,
  обрезает пробелы, объединяет варианты без учёта регистра и выдаёт до пяти
  отсортированных префиксных совпадений. `create_product_screen.dart` использует
  RawAutocomplete поверх существующего YamTextField: мышь/касание/клавиатура,
  свободный ввод; при следующем открытии формы сохранённый бренд доступен.
- RU/EN UI строки — в ARB с generated l10n. Для внешних ссылок добавлен
  `url_launcher`; Android main manifest разрешает INTERNET, macOS sandbox —
  исходящие соединения.

## Проверка

- `dart run build_runner build --delete-conflicting-outputs`,
  `dart run drift_dev schema dump ...` и `schema generate ...`,
  `flutter gen-l10n`, `dart format` — выполнены.
- Миграционный тест из заполненной реальной схемы v3 сравнивает все строки
  старых таблиц до и после перехода; пути v1/v2→v4 также проходят.
- Прицельные тесты миграций, DiaryRepository, UserFoodRepository,
  StatisticsRepository, OFF-нормализации/кэша, сетевых состояний и Retry,
  существующего и нового Food Search UI — пройдены. Полный suite и goldens
  не запускались.
- `flutter analyze` и `git diff --check` — успешно. Для Flutter-тестов в этой
  среде требовалось задать `NO_PROXY=localhost,127.0.0.1`.
- После изменений выполнены `dart format` и `flutter analyze` (без замечаний);
  целевые тесты `diary_screen`, `diary_prototype_data`, `yam_components`,
  `user_food_repository`, `create_product_screen` прошли (27 тестов). Тесты
  проверяют темы календаря, оба размера Дневника, сортировку/удаление брендов,
  выбор подсказки касанием и клавиатурой, свободный ввод. Запуск Linux
  с `NO_PROXY=localhost,127.0.0.1 flutter run -d linux --no-pub --trace-startup`
  прошёл до первого кадра. Настройки темы и взаимодействия проверены
  widget-тестами; ручная интерактивная приёмка Light/Dark ещё не проведена.
- Исправлен конфликт цвета цифры выбранного сегодняшнего дня с фоном круга:
  `dart format`, `flutter analyze`, `flutter test`
  `test/features/diary/presentation/diary_screen_test.dart` (14 тестов,
  включая проверку фактического цвета текста в Light/Dark) — успешно.

## Следующее Действие

- Исправить переход Дневника на новый локальный день после полуночи/возврата
  из фона, сохраняя вручную выбранную историческую дату.

## Блокеры

- Тема и избранное встроенных fixture пока сессионные; export/import нет.
  Текущий Flutter SDK требует pinned Drift 2.31 / drift_flutter 0.2.4.
  iOS build на Linux и ручная проверка OFF на устройствах не проводились.
  Старые Diary/Food Search/Settings goldens требуют пересъёмки. Ручную приёмку
  Light/Dark календаря и брендов на устройстве ещё нужно провести.
