# ADR 0010: Приоритет Экранной Композиции

- Статус: принято
- Дата: 2026-09-20

## Контекст

`agents/design/yam_components_2.html` создавался как каталог повторяющихся
визуальных паттернов. Approved screen references при этом задают конкретную
композицию, плотность и контекст использования этих паттернов.

Предыдущая иерархия источников ставила component catalogue выше screen HTML.
Из-за этого универсальная геометрия компонентов, например визуальные кнопки
44x44, переносилась на экраны буквально и делала интерфейс крупнее и тяжелее
approved mockups.

Минимальный touch target и визуальный размер элемента не обязаны совпадать.
Компактная кнопка может сохранять доступную область нажатия не меньше 44 logical
px.

## Решение

- Accepted ADRs определяют product semantics, accessibility и устойчивые
  design decisions.
- Canonical Flutter theme tokens определяют runtime colors, typography,
  spacing, radii, elevation и motion.
- Approved screen HTML определяет screen-level composition, hierarchy,
  density, spacing intent и визуальную геометрию контекстных элементов.
- `yam_components_2.html` используется как каталог базовых паттернов и fallback
  для состояний, которые не определены screen reference. Он не переопределяет
  явно показанную экранную композицию.
- Shared Flutter components должны уметь выражать approved screen patterns, а
  не заставлять все контексты использовать одну визуальную геометрию.
- Interactive hit targets остаются не меньше 44 logical px даже когда видимая
  форма элемента меньше.

При конфликте screen reference с ADR или semantic token побеждает ADR/token.
При конфликте screen reference с component catalogue для screen-level
композиции побеждает screen reference.

## Последствия

- Diary, Food Search и Settings выравниваются по соответствующим screen HTML.
- Глобальный Diary FAB удаляется: approved screen использует контекстные add
  actions каждого meal section.
- Компактные icon, chip и quick-add controls сохраняют доступные touch targets.
- Golden tests фиксируют approved экранную композицию, а не component showcase.
