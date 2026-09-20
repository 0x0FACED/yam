# ADR 0003: Визуальное Направление YAM

- Статус: принято
- Дата: 2026-09-15
- Обновлено: 2026-09-20

## Контекст

YAM должен иметь собственный узнаваемый визуальный язык, но оставаться
в первую очередь быстрым utility-инструментом для ежедневного ввода данных.

Нужно избежать как безликого default Material UI, так и декоративного
fitness-интерфейса, который мешает работе с дневником.

Точные implementation tokens со временем могут уточняться в ходе реальной
разработки и не должны быть навечно зафиксированы ADR.

## Решение

### Общий характер

Визуальное направление YAM:

> Playful utility.

Интерфейс должен быть:

- спокойным;
- компактным;
- современным;
- дружелюбным;
- слегка живым;
- information-dense там, где это помогает ежедневному использованию.

Он не должен выглядеть как:

- медицинская система;
- агрессивный fitness tracker;
- детская игра;
- dashboard ради dashboard;
- generic Material template;
- glassmorphism showcase;
- интерфейс из вложенных декоративных карточек.

### Иерархия

Для группировки прежде всего используются:

- spacing;
- typography;
- alignment;
- subtle dividers;
- semantic surfaces.

Новая карточка или elevated surface добавляется только когда существует
реальная смысловая группа.

Не помещать каждую строку, поле или meal section в отдельную карточку.

### Brand accent

Фиолетовый является главным interaction/brand accent YAM.

Он используется для:

- primary actions;
- selected state;
- focus state;
- active navigation;
- ограниченных брендовых акцентов.

Фиолетовый не используется как случайный цвет данных.

### Nutrition semantics

Макронутриенты имеют стабильную семантику:

- protein — orange;
- fat — lime;
- carbohydrates — cyan.

Эти цвета используются только для nutrition semantics.

Они не должны переиспользоваться как generic success/warning/error
или произвольные analytics states.

Цвет никогда не является единственным способом передачи значения.

### Goal/status semantics

Состояния цели, ошибки, предупреждения и успеха имеют собственные
semantic tokens и не используют macro colors только из-за визуального сходства.

### Themes

YAM имеет полноценные:

- Light;
- Dark;
- System.

Обе темы сохраняют одинаковую информационную иерархию.

Dark theme не является простой инверсией Light.

### Typography

Основной UI использует Inter или эквивалентный системный sans-serif,
если это необходимо платформе.

Числовые данные, особенно nutrition и statistics, должны иметь стабильное
выравнивание и по возможности tabular figures.

Использование отдельного display-font не является обязательным.

### Geometry

Интерфейс использует мягкие, но не чрезмерно округлые формы.

Interactive hit targets должны быть не меньше 44 logical px,
предпочтительно около 48 px для основных touch controls.

### Mascot

Маскот YAM используется ограниченно:

- startup/intro;
- onboarding, если это не мешает заполнению;
- empty states;
- About;
- некоторые success/error states.

Маскот не используется просто для заполнения пространства и не должен
постоянно присутствовать на основном diary/statistics UI.

### Motion

Motion короткий и функциональный.

Он может использовать:

- fade;
- небольшое смещение;
- scale;
- reveal/morph между связанными состояниями.

Motion не должен:

- задерживать ввод;
- проигрываться постоянно;
- маскировать loading;
- мешать repeated workflows.

Reduce Motion должен уважаться.

### Approved references

Approved visual references находятся в `agents/design/`.

Они определяют:

- composition;
- visual hierarchy;
- density;
- spacing intent;
- screen-level component usage.

Generated HTML является visual reference, а не production implementation.

Нельзя буквально копировать:

- Tailwind/CSS structure;
- browser-specific controls;
- inline raw colors;
- fake OS chrome;
- случайные inconsistencies generated mockups.

### Implementation source of truth

Этот ADR фиксирует семантику и visual philosophy.

Точные runtime values для:

- colors;
- typography;
- spacing;
- radius;
- elevation;
- motion;
- breakpoints

живут в canonical Flutter theme/token implementation.

Approved `agents/design/yam_components_2.html` используется как visual reference
при развитии этих tokens.

Изменение semantic meaning требует отдельного design decision.

Небольшая корректировка конкретного token value для контраста или
visual matching не требует нового ADR.

### Shared components

Повторяющиеся approved UI patterns должны реализовываться через
shared YAM components, а не копироваться между feature screens.

Feature code не должен вводить локальные альтернативы уже существующим:

- buttons;
- inputs;
- number fields;
- selects;
- list rows;
- sheets;
- snackbars;
- nutrition indicators.

## Последствия

UI implementation должна сохранять характер YAM без копирования HTML-кода.

Agent не должен изобретать новый visual language внутри отдельной feature.

Approved screen reference важнее собственной эстетической интерпретации,
если это не конфликтует с product/architecture decision.