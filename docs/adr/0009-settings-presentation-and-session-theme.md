# ADR 0009: Settings Presentation И Session Theme

- Статус: принято
- Дата: 2026-09-20
- Область действия: текущий visual implementation pass
- Sunset condition: подключение persisted user settings

## Контекст

Approved Settings reference включает цели, вес, тему, единицы, язык, data
actions и About. При этом в текущем приложении ещё нет persistence для
настроек, domain-flow целей и веса, import/export или удаления пользовательских
данных.

Тема уже имеет канонические Light, Dark и System варианты, но до этого всегда
использовала системное значение без пользовательского выбора.

## Решение

- `/settings` получает полноценный локализованный адаптивный экран по
  `agents/design/yam_settings.html`.
- Theme picker поддерживает `System`, `Light` и `Dark` и применяется на уровне
  `MaterialApp.router`.
- Выбранная тема живёт только в памяти текущего запуска. UI не утверждает, что
  выбор сохранён между запусками.
- Goals, weight, units, language, export и delete rows отображают текущий
  presentation scope, но не запускают фиктивное сохранение или отсутствующие
  маршруты.
- About может использовать локальный системный dialog; версия соответствует
  текущему build name проекта.
- Persisted settings model, repository/provider boundary и migrations
  проектируются отдельно при начале functional settings slice.

## Последствия

- Theme switching можно проверить до появления persistence.
- Экран соответствует approved composition без ложной функциональности.
- При подключении persisted settings session state заменяется реальным
  источником данных без изменения визуального контракта экрана.
