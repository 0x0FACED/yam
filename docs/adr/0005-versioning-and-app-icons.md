# ADR 0005: Версионирование И Иконки Приложения

- Статус: принято
- Дата: 2026-09-18

## Контекст

Версия и визуальная идентичность приложения должны одинаково попадать в Android, iOS, macOS, Windows, Linux и Web builds. Ручное независимое изменение platform metadata приводит к расхождениям перед публикацией.

## Решение

- `version` в `pubspec.yaml` является source of truth и имеет формат `MAJOR.MINOR.PATCH+BUILD`.
- До стабильного MVP используется major version `0`. Исходная версия прототипа -- `0.1.0+1`.
- `MAJOR.MINOR.PATCH` следует SemVer и описывает пользовательскую версию. `BUILD` монотонно увеличивается для каждого загружаемого в store build; CI может переопределять его через `--build-number`.
- Версия `1.0.0` резервируется для стабильного local-first MVP, пригодного для ежедневного использования.
- `assets/icons/app_icon_1024.png` является исходной full-color иконкой. Android adaptive foreground и monochrome используют специализированные ассеты из той же директории.
- `flutter_launcher_icons` генерирует Android, iOS, macOS, Windows и Web resources. Linux runner упаковывает исходный PNG в bundle и устанавливает его как GTK window icon.
- Отображаемое имя на всех платформах -- `YAM`; application/bundle identifiers не меняются этим решением.

## Последствия

- Изменение публичной версии выполняется один раз в `pubspec.yaml`.
- После изменения исходных иконок нужно выполнить `dart run flutter_launcher_icons` и проверить platform diffs.
- Packaging для магазинов и Linux desktop integration может позже добавить signing, `.desktop` и distro-specific metadata, не меняя источник иконки и схему версии.
