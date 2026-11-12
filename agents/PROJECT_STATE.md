# Состояние Проекта

> Краткий handoff. Подробная хронология — в Git; правила — в `AGENTS.md`.

## Обновлено

- Дата: 2026-11-13.
- Рабочая alpha local-first: Дневник, свои продукты, вес/цели, Статистика,
  необязательный OFF, полный backup `.yam`, обмен «Моими блюдами» JSON.
- ИИ-помощник: текст/голос/фото → редактируемый черновик → явное подтверждение; ручной ввод offline.
- HTTP/HTTPS/SOCKS5-прокси из Настроек: защищённые per-device credentials, без direct fallback.
- SQLite `yam` — schema v8. Полные копии — format v3, импорт v1/v2/v3.
- Подготовлен релиз `0.7.2+15`: изменения из Unreleased включены в заметки 0.7.2.

## Принятые Решения

- Product/data: ADR 0001/0002/0015–0020; релевантные разделы blueprint.
  Более новые ADR заменяют только явно названные ограничения.
- Дизайн: ADR 0003/0010–0012, экранные HTML и `yam_components_2.html`.
  Нет «Для вас», вымышленной истории, inline quick add и verified badge.
- ADR 0017: энергия своей еды рассчитывается из БЖУ; дневные итоги используют
  сохранённую энергию snapshots, а не пересчитывают её из дневных БЖУ.
- ADR 0021/0022: отдельный optional OFF/local-first cache и локальные бренды.
- ADR 0023/0026/0028: редактирование UserFood не меняет историю; категории —
  исходный текст/код, nullable описание и правка/удаление из всех вкладок поиска.
- ADR 0024 (backup): атомарные replace/supplement, проверка до записи,
  сохранение deviceId получателя, восстановление из первого онбординга.
- ADR 0025 (CI)/0027/0031/0035: подписанные релизы, Android updater, строгие
  version/changelog contracts; заголовок без build suffix, без правки старых релизов.
- ADR 0029/0032/0033: календарные статусы, исторические цели, интерактивные
  графики, native overscroll и контрастные семантические цвета Статистики.
- ADR 0030/0034: совместимые дополнительные поля backup, `yam-foods` v1,
  три режима JSON-импорта; повторяющиеся штрихкоды разрешены в schema v6/backup v3.
- ADR 0036: текст однострочного поля проходит через padding; разнесённые быстрые
  нажатия ставят курсор, близкие сохраняют штатное выделение.
- [ADR 0037](../docs/adr/0037-ai-food-entry-assistant.md): официальный ChatGPT
  OAuth + OpenAI API-key, клиентские инструменты без записи, atomic confirm,
  сохранение оценки, privacy/credentials, медиа и dependency strategy.
  Для native STT macOS минимум 11.0 (было 10.15), iOS остаётся 13.0.
  Android OS auto-backup/transfer отключён; явный перенос остаётся через `.yam`.
- [ADR 0038](../docs/adr/0038-application-network-proxy.md): явная общая фабрика
  app HTTP, HTTP/HTTPS CONNECT и SOCKS5, secure per-device settings, fail-closed,
  немедленная смена маршрута; внешний браузер/native STT остаются на маршруте ОС.
- [ADR 0039](../docs/adr/0039-assistant-chat-presentation.md)/[0040](../docs/adr/0040-assistant-direct-entry.md):
  Markdown без HTML/WebView; прямой вход без повторного вступления, composer всегда снизу.
  [ADR 0041](../docs/adr/0041-assistant-sticky-scroll.md): автоскролл только у нижнего края.
  [ADR 0042](../docs/adr/0042-assistant-image-paste.md): обычная вставка фото/текста, `pasteboard 0.5`.
- [ADR 0043](../docs/adr/0043-assistant-local-chat-history.md): локальный текстовый
  архив чатов, ручное включение контекста (12 сообщений / 12 000 символов), без медиа/tools.
  `.yam` v3 включает новый optional файл; старые копии читаются, старые бинарники новый ZIP не читают.
- [ADR 0044](../docs/adr/0044-expanded-day-details.md): карточка КБЖУ раскрывается
  в подробности дня; все порции с КБЖУ, вклад от факта, исторические цели,
  локальные факты и обратное сворачивание без потери позиции Дневника.
- [ADR 0045](../docs/adr/0045-yam-chat-and-floating-actions.md): YAM, думающий маскот, контекст на открытый чат, UTC `sentAt`, именованные порции.
- [ADR 0046](../docs/adr/0046-viewport-floating-actions.md): viewport-overlay без подложки, тень кнопки и измеряемый end padding.
- [ADR 0047](../docs/adr/0047-readable-nutrition-and-compact-calendars.md): контрастное БЖУ, компактные календари и точечный polish.
- [ADR 0048](../docs/adr/0048-ui-consistency-and-recovery.md): исправлены 11 замечаний consistency-аудита без редизайна и изменения данных.
- [ADR 0049](../docs/adr/0049-stable-diary-day-navigation.md): неподвижная полоска дней без анимации выделения; возврат из подробностей без повторного reveal.
- [ADR 0050](../docs/adr/0050-day-details-background-transition.md): полноэкранная fade-подложка согласует проявление всего Дневника со сворачиванием подробностей.
- [ADR 0051](../docs/adr/0051-header-save-actions.md): верхний Save/check вместо
  floating только у продукта, прокси, записи Дневника и веса; остальные flow не меняются.
- [ADR 0052](../docs/adr/0052-compact-assistant-composer.md): чат — inset 16, padding 4, радиусы ввода/ошибки/meal 8; targets 44.
- [ADR 0053](../docs/adr/0053-app-version-display.md): пользовательские версии
  без `+BUILD`; package metadata и проверки обновлений сохраняют номер сборки.

## Реализовано И Основные Файлы

### Приложение, Дневник И Каталог

- `lib/app/app.dart`, `router.dart`: adaptive shell с тремя разделами, task routes,
  обязательный первый онбординг. State — ValueNotifier/потоки; Riverpod не добавлен.
  AI connection manager создаётся без сетевого I/O; credentials читаются при входе
  в помощник/его настройки, а не при обычном запуске Дневника.
- `lib/core/data/yam_database.dart`: Drift v8, UUIDv7, installation deviceId,
  soft delete, UTC metadata и отдельные локальные diary dates. v7 добавил
  `DiaryEntries.isEstimated`, v8 — архив чатов; schemas/helpers актуальны.
  `_removeBarcodeUniqueness`: транзакционное перестроение через стабильные
  Migrator API и generated DDL, копирование всех значений, восстановление индексов/FK.
- `lib/features/diary/data/diary_repository.dart`: точные независимые snapshots,
  create/update/delete/restore и реальные Recent. Правка каталога/OFF-кэша не меняет
  историю. Оценочный признак сохраняется при update/restore и виден в row/edit sheet.
- `diary/domain/day_details.dart`: точные итоги, доли, ранжирование и выбор
  исторической цели; восемь тестов границ/точности/нулей/порядка.
- `day_details_screen.dart`: вся еда с порциями/КБЖУ по приёмам или по вкладу,
  distribution/facts/empty, live edit/delete/Undo; RU/EN, lazy rows, две колонки.
  Заголовки приёмов выделены подложкой/типографикой; divider вне InkWell в обоих режимах.
- `diary_screen.dart`, `diary_day_selector.dart`: календарная навигация вынесена
  в постоянный sliver перед loading/error/data; геометрия и reveal не сбрасываются при чтении дня.
- `day_details_route.dart`, `AppMotion`: раскрытие/сворачивание 300 мс и Hero сводки;
  `opaque: false` не перезапускает reveal; подложка плавно открывает весь UI, а не только край карточки.
  Ключ измерения на Hero сохраняет границы placeholder в полёте; Reduced motion мгновенный.
- `user_food_repository.dart`, `custom_food.dart`: атомарные UserFood/порции,
  metadata, favorite, soft delete и SQL-проверка штрихкода с исключением своего ID.
  Импортированный дубль не мешает правке неизменного штрихкода.
- `user_food_form_screen.dart`: общая create/edit форма; category/brand suggestions,
  описание, редактируемые названия всех порций с сохранением ID/коэффициентов.
- `user_food_form_screen.dart`, `proxy_settings_screen.dart`, `edit_diary_entry_sheet.dart`,
  `weight_entry_sheet.dart`: фиксированная шапка с галочкой; Close слева, Delete сохранён.
  У продукта ошибка вне прокрутки; `YamIconButton.loading` блокирует повторное нажатие.
- `yam_floating_layout.dart`/`yam_floating_actions.dart`: overlay/end padding остаётся
  для quick add, онбординга, чата и обмена; safe area/IME учитывает caller.
- `yam_text_field.dart`: viewport/tap fixes и новый `obscureText` для ключа;
  для скрытого ввода отключены autocorrect/suggestions. `yam_autocomplete_field.dart`
  переиспользует общий ввод; реальное multiline-поведение сохранено.
- `food_search_screen.dart`, adapters и `food_quick_add_sheet.dart`: свои/встроенные/
  OFF продукты, описание, реальный поиск/Recent/favorites, units без `ml == g`.
- `open_food_facts_client.dart`: Search-a-licious, от трёх символов, debounce 650 мс,
  ≥6 с между запросами, до 15 результатов; ошибки не блокируют local workflow.
  `remote_food_repository.dart`: только выбранные OFF продукты; кэш + Diary одной
  транзакцией, сохранение последнего количества и OFF/ODbL attribution.
- Builtin common-food каталог — 10 продуктов, поиск в памяти без FTS; универсальное запоминание количества не завершено.
- Quantity/edit/weight sheets используют `SafeArea.maintainBottomViewPadding`; мобильные IME-рывки отдельно не исправлялись.
- Unslop: в `app/theme` отдельные macro Text-токены; текстовые consumers
  мигрированы, цвета полос/маркеров сохранены. Настройки без пустой половины,
  full-width название quick-add, фильтры без цветной тени, иконка чата вместо искр.
- `diary_screen.dart`, `statistics_screen.dart`: локализованные read error/loading/Retry,
  epoch-защита и отсутствие ложных нулей; `DayDetailsScreen` получает live `AsyncSnapshot`,
  сохраняет route/scroll и показывает те же ошибки с повтором без автоматического закрытия.
- Меню темы/приёма/единицы прокручиваются; startup и архив используют `YamFeedbackViewport`.
  Общие кнопки/chips/presets: контрастный spinner, target ≥44×44, полные подписи.
- `YamSelectField`/`YamNumberField`/`YamDropdown`: nullable callbacks отключают ввод/focus;
  меню закрывается при отключении. Полные edit-названия, flex-header, noGoal-отметка и YAM dialog actions.

### ИИ-Помощник

- `lib/features/assistant/domain/assistant_models.dart`: сообщения, image input,
  gateway/response contract и immutable editable draft (diary/catalog-only items).
- `application/assistant_controller.dart`: completed-response/tool loop, полная
  клиентская история, повтор/отмена с epoch guard, сохранение reviewed draft при
  ошибке/неполном ответе. Отменённый/отклонённый draft не воскресает из tools state.
- `domain/assistant_conversation.dart`, `data/assistant_conversation_repository.dart`:
  SQLite-архив, sync metadata, metadata-only stream; soft delete очищает текст,
  запоздалый save не воскрешает tombstone. `assistant_history_screen.dart`: открыть/удалить.
  Controller сохраняет отправленный текст до API, только завершённый ответ после;
  ошибки записи видны и повторяются без повторного inference. Контекст архива
  включается явно один раз на открытый чат; tools reset при смене чата.
- `application/assistant_tools.dart`: search_foods/get_food/read_diary/prepare_draft.
  Builtin/UserFood/cached OFF через существующие adapters; bounded result, реальные
  ID/порции, запрет model-supplied catalog nutrients и arbitrary SQL/shell/URL.
  Только UI вызывает commit: одна транзакция, проверка актуальности каталога,
  rollback/retry и session idempotence. Новая еда может остаться только snapshot.
- `data/assistant_connection_manager.dart`: API-key, выбор режима/модели/аккаунта,
  lazy initialization, защищённое хранилище отдельно от SQLite/backup, serialized
  refresh/rotation, logout/revocation и отдельный сохранённый ключ для transcription.
- `data/chatgpt_oauth.dart`: официальный dynamic registration/returning client,
  UUIDv4 host ID, browser + loopback, PKCE/state/nonce, JWKS RS256 и проверка claims,
  scopes, refresh/revoke. Токены других приложений/внутренние ChatGPT endpoints не нужны.
- `data/openai_transport.dart`: два формата model catalog, Responses/SSE,
  fragmented UTF-8/multiline events, encrypted reasoning history, только terminal
  completion успешен. OAuth — namespace yam; API-key — plain functions.
  Ошибки наружу — только стабильные локализуемые коды, без provider body/секретов.
  Подписочный SSE допускает отсутствие Content-Type; при пустом terminal output
  используются только output_item.done в порядке индексов, после completed.
- `data/assistant_media_service.dart`: native STT, либо API ASR с собственным ключом;
  до 60 с PCM16/16kHz/mono в памяти → WAV, отмена не запускает транскрипцию.
  Mobile camera/gallery, desktop file dialog; JPEG/PNG/WebP, bounded decode в isolate,
  EXIF/GPS/прочие метаданные удаляются, ориентация сохраняется. Медиа не пишутся в БД.
  Clipboard → тот же image pipeline; лимит байтов и отмена late result после dispose.
  `pasteboard ^0.5.0`: новый native plugin, нужен полный rebuild/restart.
- macOS dev: `.vscode/launch.json`/`tasks.json`, `tool/run_macos.dart` — `.app`
  через LaunchServices, затем Flutter attach (с auth token в ignored service-info).
  Прямой VS Code → flutter run неверно атрибутирует TCC SpeechRecognition редактору
  и завершает YAM; UsageDescription/entitlements YAM уже корректны (Flutter #70374).
- `presentation/assistant_screen.dart`, `assistant_draft_review.dart`:
  `/assistant?day=YYYY-MM-DD&meal=...`, вход из Дневника; две колонки на wide,
  прокручиваемый review на compact. Редактируются дата/приём/количество/порции,
  данные нового продукта и сохранение в каталог. На compact Send/Stop — иконка.
  Текст сохраняется; ввод/фото/незавершённый draft сессионные. Потеря ввода требует подтверждения.
- `assistant_message_bubble.dart`, `assistant_markdown.dart`: сообщения без карточек,
  local time для новых `sentAt`, Markdown/выделение, таблицы/код, явные HTTP(S)-ссылки.
  `assistant_thinking_indicator.dart`: циклический маскот и текст; reduced motion без ticker.
- `assistant_screen.dart`: шапка YAM/connection/model; composer/errors/confirm над прокруткой, без футера.
  Review сохраняет ввод при reparent; видимый inset 16, padding 4, радиусы 8, targets ≥44; Switch контрастный.
  Запрос не блокирует следующий ввод/медиа/день/приём; его контекст фиксируется при старте.
  Навигация отменяет запрос/голос после подтверждения и защищена от async re-entry.
  Context controls не исчезают с IME; meal — явный default, не ограничение ИИ. Малый viewport прокручивается.
  Follow-tail только у нижнего края; `assistant_message_input.dart`: image-paste/context menu,
  штатная вставка текста/undo. Геометрия общего floating-layout по умолчанию не изменилась.
- `assistant_connection_screen.dart`: `/assistant/connection` из Настроек/помощника,
  защищённый key field, saved ChatGPT account picker, модель, welcome и usage link.
  RU/EN, privacy и правила локальной истории; native permission descriptions тоже RU/EN.
- Новые зависимости: secure_storage 10.3.4 (11.x конфликтует с win32 file_picker),
  jose, speech_to_text 7.3.0, record 6.1.2, image_picker 1.2.1; image 4.10.1 уже был
  транзитивно и теперь прямой. Текущий pinned SDK — Flutter 3.41.6 / Dart 3.11.4.
- Linux: secure storage требует libsecret/Secret Service; сборка libsecret-1-dev
  добавлена в CI/release. Голос требует API-key, parecord (pulseaudio-utils) и
  PulseAudio/PipeWire-Pulse; выбранный PCM stream path не требует ffmpeg.

### Сетевой Прокси

- `lib/core/network/proxy_settings.dart`, `proxy_settings_controller.dart`:
  настройка/валидация, сериализованное secure storage, lazy read до первого
  соединения; Android isolated namespace + `resetOnError:false`. Отмена доступна
  во время чтения хранилища: поздний результат не отправляет отменённый запрос.
- `proxy_transport.dart`: HTTP/HTTPS CONNECT, SOCKS5 auth/remote DNS/IPv6,
  fragmented handshakes, TLS к прокси и цели с обычной проверкой сертификатов.
  Смена настроек закрывает active/pending/pooled routes; прямого fallback нет.
- `lib/app/app.dart`: общая фабрика внедрена в OAuth/OpenAI/ASR/OFF/GitHub updater.
  `router.dart`, `proxy_settings_screen.dart`: `/settings/proxy`, поля host/port/
  username/password, скрытый пароль, enable/protocol, ошибки и сохранение RU/EN.

### Статистика, Обмен И Релизы

- `statistics_models.dart`, `statistics_repository.dart`: реальные питание/вес,
  версии целей, local dates, средние только по дням с едой; пропуск не равен нулю.
  Onboarding атомарно сохраняет цели/вес; неизменное взвешивание не дублируется.
- Статистика: interactive weight/calorie points, клавиатура/ведение, historical
  target line, календарь и day details. Дневник использует общие статусы недели
  ±10%; selected/today/empty различаются. Нет вымышленных графиков/верхней сводки.
  Календари на 320/360 px показывают семь дней с hit targets ≥44 px; ниже 308 px — scroll fallback.
- `food_library_repository.dart`, `food_library_codec.dart`: активные свои продукты/
  порции в UTF-8 `yam-foods` v1, точные kcal/БЖУ/basis/units/description. Без Diary,
  goals/weights/OFF/избранного/device metadata. Atomic replace/mergeDeduplicated/
  mergeAll; новая UUID/metadata установки, полная проверка до записи, isolate decode.
  Лимиты 64 МиБ / 50 000 продуктов / 250 000 порций; JSON-path ошибки.
- `food_library_file_service.dart`, `food_library_settings_section.dart` и общий
  `yam_action_sheet.dart`: file dialogs, immutable preview, confirm/result, RU/EN.
  Формат — `docs/food-library-format.md`. `food-library/`: 270 продуктов ВкусВилл/
  Глобус/Магнит, all.json и 11 категорий, report/excluded; это только content.
- `backup_repository.dart`, `backup_codec.dart`: согласованный снимок семи таблиц,
  точные metadata/tombstones, bounded ZIP/CRC/isolate; проверка до atomic replace/
  supplement. Existing IDs/deviceId не меняются; повтор supplement идемпотентен.
  v3 допускает повтор barcode; старые v1/v2 нет. Optional isEstimated переносится;
  отсутствие → false, явный null/не-bool отвергается. Нового поколения формата нет.
  Optional `assistant_conversations.json` переносит чаты/tombstones; отсутствие → пустой архив.
  После импорта router/Undo сбрасываются; отсутствие целей ведёт в онбординг.
- CI/release: pinned SDK, enforce-lockfile, l10n, analyze/full suite/coverage;
  signed Android APK, Linux x64 bundle, macOS universal zip, SHA256SUMS, draft до
  загрузки. `tool/changelog.dart`/`release_metadata.dart` проверяют tag/pubspec/notes.
- `settings_screen.dart`, `app_update_settings_section.dart`: отображают только
  публичную версию; `app_update.dart`/`github_update_client.dart` сохраняют
  `+BUILD` для сравнения и имени Android APK.
- Android updater: latest stable GitHub release, .part stream, длина/SHA256,
  проверка пакета/версии/подписи, system install. Отмена сохраняет APK; package
  replacement/startup очищает завершённое. Другие платформы updater не показывают.
- `CHANGELOG.md`: заметки 0.7.2 включают верхний Save, компактный чат, стабильную
  навигацию по дням и версию без номера сборки. GitHub Release отсутствует;
  локальный и удалённый тег `v0.7.2` указывают на предыдущий commit, не на эти изменения.
- `test/core/network/proxy_fixture.dart`: при ошибке чтения туннеля target
  закрывается в `finally`; RST раньше оставлял origin открытым и блокировал тест.

## Проверка

- `dart format`, `flutter analyze`, `flutter pub get --enforce-lockfile`,
  `flutter gen-l10n` и проверка release metadata для `v0.7.2` прошли.
- Фокусные тесты настроек и updater: 58 прошли, включая версии в UI и имя APK.
- Полный `flutter test --no-pub --coverage` без системного прокси: 460 прошли.
  В диагностике воспроизведён TCP RST с оставшимся открытым origin;
  после исправления 300 отмен и отдельный сценарий RST завершились успешно.
- macOS debug собран и запущен, Дневник виден; переход в настройки через
  автоматизацию недоступен из-за запрета macOS на System Events.
- Native macOS чата: RU/EN, Light/Dark, 320–1120 px, текст ×2, synthetic IME.
  Ввод/ошибка/meal: радиус 8; targets ≥44; UI-выбор Dinner передан в запрос; focus/selection сохранены.
  Плотность: inset 28→16, начало текста 44→28, высота 152→144 при ширине 390. Flutter/runtime errors=0.
  Toolbar/draft/error compact/wide и четыре формы Save/cancel/delete, product SQLite/proxy storage проверены.

## Следующее Действие И Ограничения

- **Следующее:** владельцу зафиксировать изменения и перенести существующий локальный
  и удалённый тег `v0.7.2` на итоговый commit; проверить release workflow на GitHub.
- Приёмка новой APK на Android с реальной IME не выполнена; физические Android/iOS недоступны.
- OpenAI text inference через подписку подтверждён; tools/фото/confirm и mobile OAuth не проверялись.
- Android/iOS Back/миграции, native permissions, Linux voice/Secret Service, file dialogs/updater требуют приёмки.
- macOS release ad-hoc, без Developer ID/notarization; legacy Keychain без Keychain Sharing.
- Тема/builtin favorites сессионные; язык/единицы пока только UI. Удаления всех данных и Riverpod нет.
- Не реализованы common-food база/запоминание порций, barcode, USDA, recipes, copy meal/day и sync.
- Diary midnight/lifecycle требует обработки с сохранением выбранной даты; Drift/drift_flutter pins сохранены.
