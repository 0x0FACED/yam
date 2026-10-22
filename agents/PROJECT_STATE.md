# Состояние Проекта

> Краткий handoff. Подробная хронология — в Git; рабочие правила — в `AGENTS.md`.

## Обновлено

- Дата: 2026-10-23.
- Стадия: рабочая alpha local-first MVP с необязательным поиском Open Food Facts
  (OFF) и полным экспортом/импортом резервных копий; MVP ещё не закрыт целиком.
- SQLite `yam` имеет schema v4. Локальные данные и Дневник работают без сети;
  онбординг обязателен при первом запуске.
- CI/CD добавлен для GitHub push/PR и релизных тегов Android/Linux/macOS;
  удалённый прогон ещё не выполнялся, signing Secrets на репозитории пока нет.

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
- `docs/adr/0024-backup-export-and-import.md`: версионированная `.yam`-копия,
  атомарные «Заменить» и «Дополнить», сохранение ID установки-получателя,
  восстановление из Настроек и обязательного первого онбординга.
- `docs/adr/0025-github-ci-releases-and-runtime-version.md`: полный CI, теги
  `vMAJOR.MINOR.PATCH` с проверкой pubspec, release signing через Secrets,
  общий номер сборки из release run counter и runtime package metadata.
  Пользователь согласовал удаление старых прототипных goldens вместо skip.
- `docs/adr/0026-preserve-stored-food-categories.md`: категории сохраняются как
  исходный текст, предустановки UI не ограничивают backup. Схема v4 и формат
  `.yam` v1 не меняются; неизвестные категории не подменяются и не удаляются.

## Реализовано

- `lib/app/app.dart` и `router.dart`: локализованный adaptive shell с Дневником,
  Статистикой и Настройками; `/add-food` — task-screen. Первый запуск требует
  онбординга; ошибка начальной загрузки ведёт к Retry, а не к пустому профилю.
  Тема System/Light/Dark сессионная.
- `.github/workflows/ci.yml`, `release.yml` и общий
  `.github/actions/setup-flutter/action.yml`: Flutter закреплён в `.fvmrc`,
  enforce-lockfile, l10n, анализ и весь набор тестов с coverage на push/PR.
  Теги запускают те же проверки, signed Android APK, Linux x64 tar и macOS
  universal zip; SHA-pinned Actions, read permissions до job публикации,
  checksums и draft до завершения загрузки всех артефактов.
- `tool/release_metadata.dart`: YAML parser pubspec, строгое совпадение тега,
  canonical SemVer/положительный Android build number, одинаковые значения
  build flags и имён артефактов. CI BUILD — `github.run_number`;
  локальный BUILD — из pubspec. Инструкции ключа/Secrets/тегов в README.
- `lib/main.dart`, `app.dart`, `router.dart`, Settings: `package_info_plus`
  загружается один раз; реальная версия с build number явно передаётся в
  Настройки и About. Константа версии удалена; тестовые callers используют
  явную fixture. `linux/version.json.in` и CMake исправляют Flutter 3.38.5:
  native asset берёт CLI overrides из generated `FLUTTER_VERSION_*`,
  а не старые значения pubspec. Перед упаковкой CI проверяет сам asset.
- `android/app/build.gradle.kts`: release требует постоянный ключ через env,
  debug fallback удалён; debug не требует release secrets. `.gitignore`
  исключает приватные keystore/key.properties и генерируемый `.fvm/`.
- `lib/features/backup/data/backup_repository.dart` и `backup_codec.dart`:
  согласованный экспорт всех шести таблиц, включая tombstones/метаданные,
  в ZIP с manifest и JSON. Формат v1 независим от схемы SQLite v4; точность
  и исторические снимки сохраняются. Полная проверка перед записью, ограничение
  файла/распаковки/числа строк, CRC; кодек работает вне UI isolate.
  Замена и дополнение транзакционны. Дополнение не меняет существующие ID
  и пропускает конфликтующие продукты со всеми порциями; повтор идемпотентен.
- `backup_codec.dart`, модель/адаптеры/форматирование Food Search и форма
  UserFood: пользовательские категории сохраняются и отображаются без
  `.values.byName()`; правка других полей не меняет категорию. Ошибка подготовки
  экспорта отделена от ошибки входного файла, тексты RU/EN в ARB.
- `backup_file_service.dart`, `backup_settings_section.dart`, Settings и
  Onboarding: системный выбор/сохранение файла, предпросмотр состава,
  оба режима импорта, отдельное подтверждение замены, progress/errors/result
  в RU/EN. После импорта `app.dart` перечитывает профиль и пересоздаёт router:
  старые экраны/Undo сбрасываются, копия без целей возвращает в онбординг.
  `file_picker` 10.3.x сохраняет текущий iOS target; macOS entitlements разрешают
  чтение/запись выбранных пользователем файлов. Сессионная тема не экспортируется.
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
- Встроенный каталог — 10 вручную заданных продуктов в
  `food_search_prototype_data.dart`, не импорт полноценной common-food базы.
  Локальный поиск фильтрует имена/бренды в памяти, FTS пока нет.
  Последнее выбранное количество сохраняется для OFF; у UserFood адаптер
  возвращает базовую/заданную по умолчанию порцию, а у встроенных — fixture.
- Состояние приложения пока управляется `ValueNotifier` и потоками
  репозиториев; Riverpod из планируемого стека не подключён.

## Проверка

- `flutter pub get --enforce-lockfile`, `flutter gen-l10n`, `dart format`
  изменённых файлов и `flutter analyze --no-pub` прошли; анализатор без ошибок.
- Весь `flutter test --no-pub --coverage` — 109 тестов пройдены, включая
  11 backup-регрессий и 8 проверок релизной версии. По решению пользователя
  удалены 3 устаревших golden-test файла и 13 PNG; исключений в CI нет.
- Оба workflow прошли actionlint 1.7.12 с ShellCheck 0.11.0. Реальный CLI
  проверен с совпадающим/ошибочным тегом, override, неверными числами/флагами
  и GITHUB_OUTPUT. Реальный preflight из YAML блокирует отсутствие Secrets
  и не выводит их значения при наличии конфигурации.
- Linux runtime с build overrides: PackageInfo, строка Settings и About
  показывают `0.9.8+321`, Flutter errors — 0; снимки просмотрены.
  Сначала воспроизведено расхождение Linux version.json, затем подтверждён
  CMake fix. Обычная release-сборка и настоящий tar полного bundle прошли:
  executable permissions, engine/assets и metadata `0.1.0+1` проверены.
- Android release реально собран с временным тестовым ключом; apksigner
  подтвердил нужный сертификат, aapt — versionName `0.9.8`/versionCode `321`.
  Без ключей release signing отклонён; обычный debug APK без Secrets собран.
  Временный keystore и подписанный им release APK удалены; реальный ключ
  приложения и GitHub Secrets не создавались.
- На приватной диагностической копии Android-базы SQLite integrity check прошёл;
  воспроизведён отказ экспорта из-за нестандартной категории. После исправления
  экспорт и восстановление сохранили все поля шести таблиц; исходные записи
  не переписывались. Личные данные и диагностические файлы в репозиторий не
  добавлялись; проверенная переносимая копия сохранена вне каталога приложения.
- Исправленный debug APK установлен через `adb install -r` прежним ключом,
  без удаления приложения и очистки данных. Пользователь подтвердил успешные
  экспорт и восстановление на телефоне.
- UI smoke подтвердил поиск/правку нестандартной категории и RU-ошибку экспорта.
  EN-этап временного UI smoke не завершён успешно; ручная проверка release
  сценария в обеих локалях остаётся предрелизной задачей.
- GitHub Actions включены, разрешены все Actions; список repository Secrets
  пуст. GitHub-hosted workflow и macOS build локально не запускались.
  Репозиторий приватный, тегов и релизов пока нет. В корне нет LICENSE;
  лицензию нужно определить, если исходники будут открываться публично.

## Следующее Действие

- Владельцу настроить постоянный Android release-ключ и четыре Secrets по README;
  затем отправить изменения без тега и дождаться первого зелёного GitHub CI.

## Блокеры

- Тема и избранное встроенных fixture пока сессионные. В Настройках единицы
  и язык только отображаются; цели меняются через повторный онбординг.
  Удаление всех данных отдельным действием пока не реализовано.
- Встроенная база и запоминание последней порции для всех источников ещё
  не завершены. Barcode scanner, USDA, recipes, copy meal/day и sync не
  реализованы; это последующие срезы, не повод расширять ближайшую задачу.
- Для настоящего release отсутствуют `ANDROID_KEYSTORE_BASE64`,
  `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS`, `ANDROID_KEY_PASSWORD`.
  macOS universal/ad-hoc сборка описана, но требует проверки macOS runner;
  Apple Developer ID/notarization в pipeline не входят.
- Дневник всё ещё требует обработки смены локального дня через полночь/
  возврат из фона с сохранением вручную выбранной исторической даты.
- Текущий Flutter SDK требует pinned Drift 2.31 / drift_flutter 0.2.4.
  iOS build на Linux и ручная проверка OFF на устройствах не проводились.
  Ручную приёмку Light/Dark календаря и брендов ещё нужно провести.
- Системные файловые диалоги iOS/macOS вживую ещё не проверялись.
  Перед первым выпуском нужна ручная приёмка подписанного release APK и desktop
  артефактов. Текущий workflow сам публикует Release после сборок; для первой
  приёмки рекомендуется оставить draft до ручного подтверждения.
