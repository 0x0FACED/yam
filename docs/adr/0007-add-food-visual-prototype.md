# ADR 0007: Presentation Prototype Добавления Еды

- Статус: принято
- Дата: 2026-09-18
- Область действия: presentation-only prototype
- Sunset condition: начало реализации реального domain/persistence add-food flow

## Контекст

Перед реализацией persistence и полной бизнес-логики было необходимо
проверить главный UX-сценарий YAM:

- поиск продукта;
- выбор количества и порции;
- выбор приёма пищи;
- quick add;
- возврат в дневник;
- Undo.

Цель slice состояла в проверке interaction model и visual flow,
а не в проектировании окончательной domain/data архитектуры.

## Решение

Для presentation prototype:

- добавление еды открывается отдельным полноэкранным task-screen
  поверх основной навигации;

- до ввода query отображаются contextual demo sections:
  часто используемые, недавние и избранные продукты;

- tap по product row открывает quick-add bottom sheet;

- отдельное quick-add действие добавляет последнюю/предложенную порцию
  без открытия sheet;

- вход из конкретного meal section заранее выбирает этот meal;

- общий entry point требует явного выбора meal в рамках prototype;

- после добавления запись визуально появляется в дневнике,
  кратко подсвечивается и может быть отменена через snackbar Undo;

- данные prototype существуют только в памяти;

- поиск использует presentation fixtures;

- barcode не входит в этот prototype slice;

- prototype models остаются presentation-only и не становятся
  будущими domain или persistence entities.

## Важное ограничение области действия

In-memory storage, fixture search и отсутствие persistence являются
ограничениями только этого prototype slice.

Они НЕ являются долгосрочными product или architecture requirements.

Когда начинается real implementation:

- demo data заменяются domain/data sources;
- persistence подключается через принятый local-first stack;
- prototype state не переносится в production domain model;
- visual/interaction contract сохраняется, если он не superseded
  последующим product/design decision.

Этот ADR не запрещает:

- Drift persistence;
- Riverpod application state;
- local search;
- barcode в последующем slice;
- remote product providers в последующем scope.

## Сохраняемый UX-контракт

После завершения prototype следующая реализация должна по возможности
сохранить проверенные interaction decisions:

- add-food как task flow поверх основной навигации;
- contextual meal preselection;
- быстрый add для повторяющейся еды;
- quantity editing через compact sheet;
- immediate visual feedback;
- Undo для обратимых действий.

Изменение этих interaction decisions требует отдельного явного product/design
решения, а не должно происходить автоматически при подключении persistence.

## Последствия

Prototype позволил проверить UX до выбора окончательных repository/provider
границ.

При реализации real data flow агент должен заменить presentation fixtures
и in-memory state, но не обязан заново проектировать уже принятый UX.