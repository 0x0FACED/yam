# Local-First Nutrition Tracker — Project Blueprint

> Рабочий blueprint для разработки кроссплатформенного трекера питания.
>
> Цель документа: зафиксировать продуктовые и технические решения так, чтобы локальный coding agent мог постепенно реализовывать проект без повторного проектирования базовых вещей на каждом шаге.

---

## 1. Идея проекта

Нужно сделать удобный, быстрый и приятный трекер питания, калорий, БЖУ, веса и связанных метрик.

Основная проблема существующих приложений вроде FatSecret — плохой UX, лишние действия, перегруженные интерфейсы, ограничения бесплатных версий и сильная зависимость от сервера.

Наше приложение должно быть:

- **local-first**;
- полноценно работающим без интернета;
- быстрым при ежедневном использовании;
- бесплатным для базового использования;
- кроссплатформенным;
- пригодным для постепенного развития;
- не завязанным на backend;
- готовым к будущему серверному sync без переписывания модели данных.

Целевые платформы:

- Android;
- iOS;
- macOS;
- Linux;
- потенциально позже:
  - Windows;
  - Web.

Основной клиентский стек — **Flutter**.

---

# 2. Главные продуктовые принципы

## 2.1. Local-first

Локальная SQLite-база является главным источником истины.

Интернет не должен требоваться для:

- просмотра текущего дня;
- просмотра истории;
- добавления локально известных продуктов;
- добавления недавно использованных продуктов;
- изменения количества продукта;
- расчёта калорий;
- расчёта БЖУ;
- просмотра статистики;
- просмотра графиков;
- добавления собственного продукта;
- создания рецепта;
- внесения веса;
- просмотра trend weight;
- изменения целей;
- экспорта данных.

Удалённые API используются только как дополнительные источники продуктов.

Схема:

```text
Remote API
    ↓
normalize
    ↓
Local SQLite
    ↓
Application
```

После загрузки продукта из внешнего источника он сохраняется локально.

---

## 2.2. Скорость ежедневного использования важнее количества функций

Главное действие приложения:

> «Я только что что-то съел — хочу занести это максимально быстро».

Добавление регулярно используемой еды должно занимать 1–2 действия.

Плохой workflow:

```text
Добавить
→ поиск
→ продукт
→ количество
→ единица
→ подтверждение
→ ещё одно подтверждение
```

Хороший workflow:

```text
+
→ tap по недавнему продукту
```

Tap по недавно использованному продукту должен добавлять его с последней использованной порцией.

Например:

```text
Neo High Protein
Последняя порция: 30 г

tap → +30 г
```

Редактирование количества можно делать:

- long press;
- swipe;
- tap по уже добавленной записи;
- отдельным быстрым quantity editor.

---

## 2.3. Offline-first UX

При запуске приложения пользователь никогда не должен ждать сеть.

Сначала отображаются локальные данные.

Например поиск:

```text
User input
   ↓
Local FTS
   ↓
immediate results
   ↓
remote search after debounce
   ↓
merge results
```

Remote search не блокирует интерфейс.

---

## 2.4. Исторические данные должны быть стабильными

Нельзя хранить diary entry только как ссылку на внешний продукт.

Плохая схема:

```text
DiaryEntry
  food_id -> OpenFoodFacts product
```

Если информация во внешней базе изменится, изменится история пользователя.

Поэтому при добавлении еды создаётся snapshot нутриентов.

Пример:

```text
DiaryEntry
    food_id
    food_name_snapshot
    brand_snapshot
    amount
    unit
    kcal_snapshot
    protein_snapshot
    fat_snapshot
    carbs_snapshot
    ...
```

Если завтра Open Food Facts изменит данные продукта, вчерашний дневник не изменится.

---

# 3. Технологический стек

## 3.1. Client

```text
Flutter
Dart
```

---

## 3.2. State management

Предпочтительно:

```text
Riverpod
```

Причины:

- хорошо подходит для Flutter;
- удобно тестируется;
- нормальная dependency injection модель;
- не требует тяжёлой архитектуры.

Не нужно создавать чрезмерно сложные abstraction layers.

---

## 3.3. Routing

```text
go_router
```

---

## 3.4. Database

```text
SQLite
+
Drift
```

SQLite — source of truth.

Drift нужен для:

- type-safe запросов;
- миграций;
- reactive queries;
- desktop/mobile поддержки;
- фонового выполнения запросов;
- удобной работы с SQLite.

Для тяжёлых запросов использовать background isolate / `createInBackground`.

---

## 3.5. Local search

```text
SQLite FTS5
```

Использовать для:

- продуктов;
- брендов;
- рецептов;
- собственных продуктов;
- cached remote products.

---

## 3.6. HTTP

Возможный вариант:

```text
Dio
```

Но networking должен быть абстрагирован через provider/repository слой.

---

## 3.7. Charts

Предпочтительно:

```text
fl_chart
```

Нужные типы графиков:

- line chart;
- bar chart;
- возможно pie/donut;
- weight trend;
- calories trend;
- macros trend;
- expenditure trend.

---

## 3.8. Barcode scanner

На mobile/macOS можно использовать:

```text
mobile_scanner
```

Нужно учитывать capability detection.

Не писать по всему приложению:

```dart
if (Platform.isLinux)
```

Вместо этого:

```text
PlatformCapabilities
    cameraBarcodeScanner
    localNetworkDiscovery
    fileShare
    biometricAuth
    ...
```

UI реагирует на capabilities.

---

## 3.9. IDs

Для пользовательских сущностей:

```text
UUID v7
```

Не использовать auto-increment ID как глобальную идентичность сущности.

SQLite integer rowid можно использовать внутренне при необходимости, но public/entity ID должен быть UUID.

Это упростит будущий sync.

---

# 4. Высокоуровневая архитектура

```text
┌──────────────────────────────────────────────┐
│                  Flutter UI                  │
│                                              │
│ Diary │ Foods │ Recipes │ Stats │ Settings   │
└───────────────────────┬──────────────────────┘
                        │
┌───────────────────────▼──────────────────────┐
│                Application Layer             │
│                                              │
│ AddFood                                      │
│ UpdateDiaryEntry                             │
│ SearchFood                                   │
│ CreateRecipe                                 │
│ CalculateDailyNutrition                      │
│ CalculateTargets                             │
│ CalculateWeightTrend                         │
│ ExportData                                   │
│ ImportData                                   │
│ Sync                                         │
└───────────────────────┬──────────────────────┘
                        │
       ┌────────────────┼────────────────┐
       │                │                │
       ▼                ▼                ▼
   SQLite/Drift     Food APIs       Sync Transport
                        │
                ┌───────┴────────┐
                │                │
          Open Food Facts       USDA
```

---

# 5. Структура проекта

Не нужно делать enterprise Clean Architecture с десятками интерфейсов для каждой операции.

Предпочтительно feature-first:

```text
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme/
│
├── core/
│   ├── database/
│   ├── network/
│   ├── sync/
│   ├── platform/
│   ├── utils/
│   └── ui/
│
├── domain/
│   ├── food/
│   ├── nutrition/
│   ├── diary/
│   ├── recipe/
│   ├── weight/
│   └── goals/
│
├── features/
│   ├── onboarding/
│   ├── diary/
│   ├── foods/
│   ├── food_search/
│   ├── barcode/
│   ├── recipes/
│   ├── stats/
│   ├── weight/
│   ├── import_export/
│   ├── sync/
│   └── settings/
│
└── main.dart
```

Внутри feature можно иметь:

```text
feature/
├── data/
├── domain/
├── application/
└── presentation/
```

Но только если это реально помогает.

Не создавать интерфейс ради интерфейса.

---

# 6. Источники продуктов

## 6.1. Open Food Facts

Основной источник брендовых продуктов.

Использовать для:

- barcode;
- названий;
- брендов;
- фотографий;
- ингредиентов;
- аллергенов;
- энергетической ценности;
- БЖУ;
- serving information.

Особенно полезно для магазинных продуктов.

Важно:

- не делать search-as-you-type напрямую против API;
- использовать debounce;
- кэшировать найденные продукты;
- повторно искать сначала локально.

---

## 6.2. USDA FoodData Central

Использовать преимущественно для generic foods:

```text
banana
apple
rice
chicken breast
egg
potato
salmon
oatmeal
beef
milk
...
```

Полезен как более структурированный источник нутриентов.

---

## 6.3. Built-in common foods database

Желательно поставлять приложение с небольшой встроенной базой базовых продуктов.

Примерный объём первой версии:

```text
500–2000 foods
```

Она должна позволять использовать приложение сразу после установки без интернета.

Примеры:

```text
Яйцо
Банан
Яблоко
Рис белый
Рис бурый
Гречка
Овсянка
Картофель
Куриная грудка
Куриное бедро
Говядина
Свинина
Лосось
Тунец
Творог
Молоко
Хлеб
Сыр
...
```

В будущем можно расширить.

---

# 7. Unified food model

Все внешние источники должны преобразовываться в одну внутреннюю модель.

Например:

```text
Food
├── id
├── source
├── sourceId
├── barcode
│
├── name
├── brand
│
├── nutritionBasis
├── nutrients
│
├── servings
│
├── image
│
├── createdAt
├── updatedAt
└── metadata
```

Source:

```text
local
builtin
open_food_facts
usda
```

---

# 8. Nutrient model

Минимальный набор:

```text
energyKcal
proteinG
fatG
carbsG
fiberG
sugarsG
saltG
sodiumMg
```

Позже можно добавить:

```text
saturatedFat
cholesterol
potassium
calcium
iron
magnesium
vitaminD
vitaminB12
...
```

Но MVP не должен зависеть от полного набора micronutrients.

---

# 9. Measurement model

Нельзя считать, что всё выражается только в граммах.

Нужны типы:

```text
Mass
Volume
Piece
Serving
```

Пример:

```text
100 г молока
```

и:

```text
100 мл молока
```

не являются универсально одинаковыми величинами.

Не использовать глобальное:

```text
1 ml == 1 g
```

Для продукта может быть:

```text
NutritionBasis.mass(100 g)
```

или:

```text
NutritionBasis.volume(100 ml)
```

Serving examples:

```text
1 piece  -> 58 g
1 scoop  -> 30 g
1 slice  -> 28 g
1 cup    -> 240 ml
```

---

# 10. Diary model

Дневник разбит на meal sections.

По умолчанию:

```text
Breakfast
Lunch
Dinner
Snacks
```

Пользователь должен иметь возможность:

- переименовать;
- изменить порядок;
- удалить;
- добавить свои.

Пример:

```text
Today

Breakfast
  Eggs       3 pcs
  Bread      80 g

Lunch
  Chicken    220 g
  Rice       280 g

Dinner

Snacks
```

---

## 10.1. DiaryEntry

Примерная модель:

```text
DiaryEntry
├── id: UUID
├── diaryDayId
├── mealSectionId
├── foodId?
│
├── foodNameSnapshot
├── brandSnapshot
│
├── quantity
├── unit
│
├── kcalSnapshot
├── proteinSnapshot
├── fatSnapshot
├── carbsSnapshot
├── fiberSnapshot
├── ...
│
├── createdAt
├── updatedAt
├── deletedAt
└── deviceId
```

---

# 11. UX главного экрана

Пример mobile UI:

```text
                Сегодня

           1724 / 2200 kcal

    Protein       Fat        Carbs
   124 / 160    54 / 70    172 / 220


Завтрак                               482
─────────────────────────────────────────
Яйца                    3 шт           216
Хлеб                    80 г           190
Молоко                 150 мл           76
                                      ＋

Обед                                  711
─────────────────────────────────────────
Куриная грудка         220 г           363
Рис                    280 г           348
                                      ＋


                         ＋ Добавить
```

Ключевой принцип:

> Дневник должен быть читаемым без открытия деталей.

---

# 12. Add Food UX

После нажатия `+`:

```text
┌──────────────────────────────────────┐
│ 🔎 Найти продукт                     │
├──────────────────────────────────────┤
│                                      │
│ Быстро                               │
│                                      │
│ Творог          180 г       216 kcal │
│ Банан            160 г       142 kcal │
│ Протеин           30 г       112 kcal │
│ Молоко           250 мл      130 kcal │
│                                      │
│ Недавние                             │
│ ...                                  │
│                                      │
│ [ Штрихкод ]     [ Свой продукт ]   │
└──────────────────────────────────────┘
```

Приоритет выдачи:

1. favourites;
2. frequently used;
3. recently used;
4. local cached matches;
5. built-in foods;
6. remote results.

---

# 13. Search architecture

```text
User types
    │
    ▼
SQLite FTS5
    │
    ├── favorites
    ├── history
    ├── own foods
    ├── recipes
    ├── builtin
    └── remote cache
    │
    ▼
Immediate results

after debounce
    │
    ▼
Remote providers
    │
    ├── Open Food Facts
    └── USDA
    │
    ▼
Normalize
    │
    ▼
Merge / rank
    │
    ▼
Cache selected/useful result
```

Не обязательно сохранять абсолютно каждый remote search result навечно.

Можно:

- сохранять выбранные;
- делать bounded cache;
- иметь `last_accessed_at`;
- очищать старые редко используемые remote cache records.

---

# 14. Ranking поиска

Результаты можно ранжировать примерно так:

```text
exact local match
favorite
frequently used
recently used
prefix match
substring match
brand relevance
remote result
```

В будущем можно использовать usage score.

Например:

```text
score =
    textScore
  + favoriteBoost
  + log(useCount + 1)
  + recencyBoost
```

---

# 15. Recipes

Recipe — полноценная сущность.

Пример:

```text
Сырники

Творог       500 г
Яйца           2 шт
Мука         100 г
Сахар         30 г
Масло         15 г
───────────────────
Вес блюда    720 г
```

Приложение считает:

```text
TOTAL
1238 kcal

PER 100 G
172 kcal
P 14.8
F 6.1
C 14.3
```

После этого пользователь может добавить:

```text
Сырники
237 г
```

---

## 15.1. Cooked weight

Очень важная функция:

```text
Raw ingredients weight: 1100 g
Cooked final weight:     743 g
Calories remain:        1238 kcal
```

Нутриенты на 100 г считаются относительно фактического итогового веса блюда.

Это позволяет корректно учитывать испарение воды.

---

# 16. Custom foods

Пользователь должен иметь возможность создать продукт вручную.

Минимальные поля:

```text
name
brand?
barcode?
nutrition basis
kcal
protein
fat
carbs
fiber?
servings[]
```

Можно также добавить:

```text
photo
notes
```

---

# 17. Barcode flow

Mobile/macOS:

```text
Scan barcode
   ↓
Local barcode lookup
   ↓
if found:
    show local food
else:
    Open Food Facts
   ↓
normalize
   ↓
preview
   ↓
save locally
   ↓
add to diary
```

На Linux barcode scanner может быть недоступен через camera plugin.

Это не должно ломать остальной функционал.

Возможно позже:

- webcam plugin;
- USB scanner;
- manual barcode input.

USB barcode scanners часто работают как HID keyboard.

---

# 18. Daily nutrition calculation

Все расчёты должны быть локальными.

Для каждого дня:

```text
totalKcal
totalProtein
totalFat
totalCarbs
totalFiber
...
```

Можно считать SQL aggregate запросом или reactive derived state.

Не хранить totals как единственный source of truth.

Source of truth — diary entries.

---

# 19. Goals

Onboarding:

```text
sex
birth date
height
weight
activity
goal
desired rate
```

Goals:

```text
lose
maintain
gain
```

Темп:

```text
-0.25 kg/week
-0.50 kg/week
-0.75 kg/week
...
```

Не нужно агрессивно навязывать конкретный дефицит.

---

# 20. Initial calorie estimation

Для первого запуска можно использовать BMR formula, например Mifflin–St Jeor.

Затем:

```text
BMR
 × activity coefficient
 = estimated TDEE
```

Но это только initial estimate.

---

# 21. Adaptive expenditure estimation

В будущем реализовать адаптивную оценку расхода энергии.

Входные данные:

```text
calorie intake history
+
weight trend history
```

Выход:

```text
estimated TDEE
```

Пример:

```text
Estimated expenditure
2746 kcal/day

Average intake
2201 kcal/day

Estimated deficit
545 kcal/day

Expected rate
~0.49 kg/week
```

Это должен быть отдельный domain module, который можно улучшать независимо от UI.

---

# 22. Weight tracking

Пользователь может вводить вес в любой день.

```text
WeightEntry
├── id
├── timestamp
├── weight
├── source
├── createdAt
├── updatedAt
└── deviceId
```

Source:

```text
manual
import
healthkit
health_connect
...
```

Интеграции со health services — позже.

---

# 23. Trend weight

Не надо оценивать прогресс только по raw weight.

Пример:

```text
Raw:
100.2
99.4
100.1
99.6
100.5

Trend:
100.0
99.95
99.91
99.86
99.82
```

На UI:

```text
Today
99.6 kg

Trend
99.9 kg

7 days
-0.4 kg

30 days
-1.8 kg
```

Алгоритм trend smoothing можно выбирать позже.

Важно, чтобы он:

- был детерминированным;
- работал локально;
- был тестируемым;
- не зависел от UI.

---

# 24. Statistics

MVP stats:

## Nutrition

```text
Calories per day
Protein per day
Fat per day
Carbs per day
```

## Weight

```text
Raw weight
Trend weight
7-day change
30-day change
```

## Goal adherence

```text
days within calorie range
average calorie intake
average protein
```

---

# 25. Graph UX

Графики должны быть простыми и читаемыми.

Не строить dashboard ради dashboard.

Примеры:

### Weight

```text
raw weight
trend weight
```

на одном line chart.

### Calories

```text
daily intake
target
```

### Protein

```text
daily protein
target
```

### Expenditure

После появления adaptive TDEE:

```text
estimated expenditure
average intake
```

---

# 26. Mobile navigation

Пример:

```text
BottomNavigationBar

Today
Stats
Weight
Settings
```

Foods и Recipes могут быть доступны:

- через search;
- через отдельные экраны;
- через Settings/Library;
- через adaptive navigation.

---

# 27. Desktop navigation

Не растягивать мобильный UI на 1600 px.

Использовать adaptive layout.

Пример:

```text
┌───────────────┬──────────────────────────────────┐
│ Today         │                                  │
│ Foods         │                                  │
│ Recipes       │            Content               │
│ Stats         │                                  │
│ Weight        │                                  │
│ Settings      │                                  │
└───────────────┴──────────────────────────────────┘
```

На desktop:

```text
NavigationRail / sidebar
```

На mobile:

```text
BottomNavigationBar
```

Domain/data layer общий.

---

# 28. Local database — preliminary entities

Ниже не окончательная SQL schema, а базовая модель.

```text
users_profile
devices

foods
food_servings
food_nutrients

recipes
recipe_ingredients

meal_sections

diary_days
diary_entries

weight_entries

goals
settings

remote_food_cache

change_log
sync_peers
```

---

# 29. Food table

Примерно:

```text
foods
────────────────────────────────────────────
id UUID PK

source
source_id
barcode

name
brand

basis_type
basis_amount

energy_kcal
protein_g
fat_g
carbs_g
fiber_g
sugars_g
salt_g
sodium_mg

image_url?
image_local_path?

is_favorite
use_count
last_used_at

created_at
updated_at
deleted_at

device_id
```

Необязательно нормализовывать все nutrients в первой версии.

При расширении micronutrients можно перейти на отдельную `food_nutrients`.

---

# 30. Recipe tables

```text
recipes
────────────────────
id
name

final_weight_g

created_at
updated_at
deleted_at
device_id
```

```text
recipe_ingredients
────────────────────
id
recipe_id
food_id

quantity
unit

nutrition snapshot if needed

created_at
updated_at
deleted_at
device_id
```

---

# 31. Meal sections

```text
meal_sections
────────────────────
id
name
position
enabled

created_at
updated_at
deleted_at
device_id
```

Default:

```text
Breakfast
Lunch
Dinner
Snacks
```

---

# 32. Soft delete

Для sync-friendly сущностей использовать:

```text
deleted_at
```

вместо немедленного hard delete.

Позже sync сможет передавать tombstone другим устройствам.

Физическое удаление можно делать через garbage collection после безопасного периода.

---

# 33. Change log

С самого начала заложить журнал изменений.

```text
change_log
────────────────────────
sequence
change_id UUID
entity_type
entity_id
operation

changed_at
device_id
```

Operations:

```text
create
update
delete
```

Это облегчит:

- export delta;
- local sync;
- server sync;
- debugging.

Необязательно сразу строить CRDT.

---

# 34. Device identity

Каждая установка генерирует:

```text
device_id UUID
```

Например:

```text
phone
macbook
linux_pc
```

Display name можно хранить отдельно.

`device_id` сохраняется вместе с изменениями.

---

# 35. Sync architecture

Backend не должен быть частью domain model.

```text
                 Local SQLite
                      │
               ┌──────┴──────┐
               │             │
              UI         Sync Engine
                             │
                  ┌──────────┼───────────┐
                  │          │           │
                File        LAN        Server
              Import      P2P Sync      Later
```

---

# 36. Sync v0 — export/import

Самый простой первый вариант.

```text
SQLite/domain state
      ↓
export
      ↓
.foodtrack archive
```

Файл можно передать:

- AirDrop;
- Telegram;
- USB;
- local file sharing;
- cloud drive;
- messenger.

После импорта:

```text
validate
→ migrate
→ merge/replace
```

На раннем этапе можно поддержать только full backup/restore.

Позже — merge.

---

# 37. Export format

Не экспортировать raw SQLite как единственный официальный формат.

Желательно иметь versioned application-level format.

Например:

```text
.foodtrack
```

Это zip archive:

```text
manifest.json
profile.json
foods.jsonl
recipes.jsonl
diary.jsonl
weights.jsonl
settings.json
attachments/
```

или protobuf/messagepack позже.

Manifest:

```json
{
  "format": "foodtrack",
  "version": 1,
  "exportedAt": "2026-09-15T12:00:00Z",
  "deviceId": "..."
}
```

Плюсы:

- миграции;
- дебаг;
- portability;
- независимость от SQLite schema.

---

# 38. Sync v1 — QR pairing + LAN

QR не должен содержать всю базу.

QR используется для pairing.

Пример:

```text
Mac
 │
 │ Start local sync session
 ▼
local server
192.168.1.24:48321
 │
 ├── ephemeral keypair
 └── session token
        │
        ▼
       QR
        │
        ▼
Android scans
        │
        ▼
Connect over LAN
        │
        ▼
Encrypted sync
```

QR payload conceptual example:

```json
{
  "version": 1,
  "address": "192.168.1.24:48321",
  "session": "...",
  "publicKey": "..."
}
```

---

# 39. LAN discovery

После первого pairing можно добавить:

```text
mDNS / Bonjour
```

UI:

```text
Nearby devices

MacBook Pro
Last sync: yesterday

Linux Desktop
Last sync: 3 days ago
```

Pairing state сохраняется локально.

---

# 40. Why not Bluetooth initially

Bluetooth sync на раннем этапе не нужен.

Причины:

```text
Android BLE
iOS BLE
macOS BLE
Linux BlueZ
permissions
background restrictions
MTU
fragmentation
reconnects
pairing
platform-specific bugs
```

Это легко превращает nutrition app в Bluetooth engineering project.

Приоритет:

```text
v0 file export
v1 LAN
v2 server sync
```

Bluetooth можно добавить позже как optional transport.

---

# 41. Sync v2 — server

Будущий backend:

```text
Go
PostgreSQL
```

Пример:

```text
Android ─┐
iPhone  ─┼──► Go Sync API ───► PostgreSQL
macOS   ─┤
Linux   ─┘
```

Но сервер не должен хранить бизнес-логику расчёта питания как единственную реализацию.

Client должен оставаться полноценно работоспособным offline.

---

# 42. Future sync protocol

Возможный high-level flow:

```text
client:
    last_server_cursor = 10392

POST /sync/push
    local changes after local cursor

GET /sync/pull?cursor=10392
    remote changes

apply transaction
update cursor
```

Conflict strategy можно определить позже.

На первом этапе достаточно last-write-wins для большинства простых пользовательских сущностей.

Для diary entries предпочтительно entity-level merge, а не whole-day overwrite.

---

# 43. Security future considerations

Для LAN sync:

- ephemeral session token;
- encrypted transport;
- pairing confirmation;
- expiry;
- replay protection.

Для server sync:

- account auth;
- refresh/access tokens;
- encrypted transport;
- optional E2EE можно рассмотреть позже.

Не нужно реализовывать всё это в MVP.

---

# 44. Privacy

Так как приложение health-adjacent, желательно придерживаться принципов:

- локальные данные по умолчанию;
- отсутствие обязательного аккаунта;
- отсутствие analytics по умолчанию либо opt-in;
- прозрачный export;
- прозрачное удаление данных.

---

# 45. Performance

На этапе MVP нет числовых performance-бюджетов и обязательных profile-прогонов.
Оптимизация выполняется после появления воспроизводимой пользовательской
проблемы или измеримой деградации.

Базовые ограничения остаются простыми:

- локальный UI не ждёт network;
- тяжёлая работа не запускается из `build`;
- неограниченные коллекции используют ленивые списки;
- caching, isolates и специальные performance-решения добавляются только при
  подтвержденной необходимости.

---

# 46. Database indexes

Предварительно нужны индексы по:

```text
foods.barcode
foods.source + source_id
foods.last_used_at

diary_entries.date/day_id
diary_entries.food_id

weight_entries.timestamp

change_log.sequence
change_log.entity_id

recipe_ingredients.recipe_id
```

И FTS table для food search.

---

# 47. Caching policy

Remote products:

```text
remote result
    ↓
selected by user?
    yes → persist indefinitely
    no  → optional bounded cache
```

Можно использовать:

```text
last_accessed_at
cache_priority
```

Не хранить бесконечно все результаты remote searches.

---

# 48. Image caching

Фото продуктов не являются критическими данными.

Хранить:

```text
remote image URL
```

и optional disk cache.

Не включать большие image blobs в SQLite.

При offline отсутствии изображения UI должен спокойно работать без него.

---

# 49. Theme and visual design

Требования:

- clean;
- calm;
- modern;
- fast;
- minimal visual noise;
- dark mode;
- light mode;
- system theme;
- хорошие desktop layouts;
- большие touch targets;
- аккуратные animations, но не в ущерб скорости.

Не превращать приложение в gamified fitness app.

---

# 50. Non-goals MVP

Не делать в первой версии:

- social network;
- friends;
- leaderboard;
- AI coach;
- generated meal plans;
- subscription;
- ads;
- calorie streak gamification;
- giant recipe marketplace;
- cloud account;
- Bluetooth sync;
- HealthKit;
- Health Connect;
- Wear OS;
- Apple Watch;
- ML food recognition;
- photo calorie estimation.

---

# 51. MVP v0.1

Минимальная usable версия:

## App shell

- Flutter project;
- adaptive layout;
- dark/light themes;
- Riverpod;
- go_router.

## Database

- Drift;
- migrations;
- UUID entities.

## Diary

- current day;
- day navigation;
- meal sections;
- add/edit/delete food;
- daily calories;
- daily macros.

## Foods

- custom foods;
- built-in common foods;
- local search;
- favorites;
- recent foods;
- last portion quick add.

## Weight

- add weight;
- history;
- simple line chart.

## Settings

- calorie target;
- protein/fat/carbs targets;
- units;
- theme.

После этой версии приложением уже должно быть можно реально пользоваться каждый день.

---

# 52. MVP v0.2

Добавить:

- Open Food Facts;
- barcode scanner;
- local remote-food cache;
- USDA;
- better search ranking;
- food serving units;
- copy meal/day;
- recipe creation;
- cooked recipe weight.

---

# 53. v0.3

Добавить:

- richer statistics;
- trend weight;
- onboarding;
- automatic initial calorie target;
- calorie adherence;
- macro adherence;
- better desktop UX.

---

# 54. v0.4

Добавить:

- export/import;
- `.foodtrack` format;
- backup/restore;
- schema/version compatibility;
- changelog foundation.

---

# 55. v0.5

Добавить:

- QR pairing;
- LAN transfer;
- sync peers;
- encrypted local sync;
- conflict handling;
- incremental sync.

---

# 56. v1.0

К этому моменту приложение должно:

- стабильно работать offline;
- поддерживать Android/iOS/macOS/Linux;
- иметь удобный дневник;
- иметь продукты;
- иметь recipes;
- иметь barcode;
- иметь хороший local search;
- иметь статистику;
- иметь weight trend;
- иметь local device sync;
- иметь import/export;
- иметь понятные migrations.

Backend всё ещё необязателен.

---

# 57. Later roadmap

После того как приложение реально используется:

```text
Go sync backend
PostgreSQL
accounts
server sync
Health Connect
HealthKit
adaptive TDEE
micronutrients
better nutrition analytics
desktop barcode support
widgets
notifications
wearables
```

Только после доказанной необходимости.

---

# 58. Testing strategy

## Unit tests

Обязательно покрыть:

- nutrition scaling;
- servings conversion;
- recipe calculation;
- cooked-weight calculation;
- daily aggregation;
- goal calculation;
- trend weight;
- import/export;
- sync merge logic.

Особенно важно избегать floating point surprises.

---

## Database tests

Проверить:

- migrations;
- inserts;
- soft delete;
- FTS;
- history queries;
- aggregation;
- changelog generation.

---

## Golden/widget tests

Полезны для ключевых экранов:

- diary;
- add food;
- recipe editor;
- stats;
- desktop layout.

---

# 59. Numeric correctness

Не размазывать arithmetic по UI.

Должны быть отдельные value/domain objects.

Например:

```text
Energy
Mass
Volume
Protein
Fat
Carbohydrates
Serving
Nutrition
```

Не обязательно делать hyper-OOP.

Но функции вроде:

```text
nutrition.scale(amount)
recipe.nutritionPer100g()
day.totalNutrition()
```

должны жить вне widgets.

---

# 60. Floating point

Нутриенты могут храниться как REAL, но:

- вычисления должны иметь единый подход;
- UI rounding не должен менять stored value;
- отображение и internal precision разделены.

Например:

```text
stored protein = 28.374
display = 28.4 g
```

Не сохранять обратно `28.4` после отображения.

---

# 61. Date handling

Diary day — это локальная календарная дата пользователя, а не просто UTC timestamp.

Важно различать:

```text
LocalDate
Instant/Timestamp
```

Пример:

```text
2026-09-15
```

для дневника.

А:

```text
2026-09-15T12:41:28Z
```

для created_at.

Не вычислять diary day тупо через UTC date.

---

# 62. Locale

Заложить локализацию с начала.

Минимум потенциально:

```text
ru
en
```

Не хардкодить UI strings в widgets.

Food names из внешних API могут иметь локализованные варианты.

---

# 63. Units

Настройки:

```text
kg / lb

g / oz

ml / fl oz
```

Внутренне желательно хранить canonical units:

```text
grams
milliliters
kilograms
kcal
```

А UI делает conversion.

---

# 64. Accessibility

Базовые требования:

- semantics;
- достаточный touch area;
- масштабирование текста;
- не кодировать состояние только цветом;
- keyboard navigation на desktop;
- shortcuts позже.

---

# 65. Desktop quality

Desktop должен поддерживать:

- keyboard;
- mouse;
- focus;
- shortcuts;
- resizable windows;
- wide layouts;
- context menus where useful.

Пример shortcut:

```text
Ctrl/Cmd + K → food search
Ctrl/Cmd + N → add food
Ctrl/Cmd + , → settings
```

Позже можно добавить command palette.

---

# 66. Useful quick actions

В будущем:

```text
Copy breakfast from yesterday
Repeat yesterday
Add last meal
Add favorite
Duplicate entry
Move entry to another meal
Change amount inline
```

Именно такие функции дают больше UX-ценности, чем AI.

---

# 67. Product philosophy

Каждый feature оценивается вопросом:

> Делает ли он ежедневный tracking быстрее, проще или точнее?

Если нет — скорее всего feature не нужен сейчас.

---

# 68. First development milestones

Практический порядок реализации.

## Milestone 1 — Skeleton

Сделать:

```text
Flutter project
Riverpod
go_router
theme
adaptive shell
Drift initialization
```

Приложение запускается на:

```text
Android
macOS
Linux
```

Затем проверить iOS.

---

## Milestone 2 — Domain model

Реализовать:

```text
Food
Nutrition
Serving
DiaryEntry
MealSection
WeightEntry
Goal
```

И unit tests на расчёты.

---

## Milestone 3 — Database

Таблицы:

```text
foods
meal_sections
diary_entries
weight_entries
settings
```

Миграции `v1`.

---

## Milestone 4 — Diary

Полностью рабочий локальный дневник.

Это первая точка, когда приложение уже полезно.

---

## Milestone 5 — Local foods

Добавить:

```text
custom food
favorites
recent
quick-add
FTS
```

---

## Milestone 6 — Built-in foods

Импорт небольшой встроенной common-food базы.

---

## Milestone 7 — Remote foods

Open Food Facts.

Потом USDA.

---

## Milestone 8 — Barcode

Добавить scanner там, где platform capability доступна.

---

## Milestone 9 — Recipes

Полный recipe flow.

---

## Milestone 10 — Stats

Weight + nutrition charts.

---

## Milestone 11 — Export

Versioned `.foodtrack`.

---

## Milestone 12 — Local sync

QR pairing + LAN.

---

# 69. Decisions that should remain flexible

Пока НЕ фиксировать намертво:

- exact sync conflict algorithm;
- backend API;
- authentication;
- server schema;
- CRDT;
- HealthKit;
- Health Connect;
- final design system;
- exact adaptive TDEE formula;
- protobuf vs JSON;
- cloud deployment.

Это premature optimization/design.

---

# 70. Decisions that should be fixed early

Нужно определиться сразу:

- local-first;
- SQLite source of truth;
- UUID;
- soft delete;
- diary nutrition snapshot;
- canonical units;
- date model;
- migration strategy;
- feature-first project structure;
- remote providers normalized into local Food model;
- UI never blocks on remote API.

Эти вещи потом дорого менять.

---

# 71. Suggested coding-agent rules

Локальному coding agent желательно дать следующие правила:

1. Не вводить новые библиотеки без причины.
2. Не создавать абстракции «на будущее», если нет второго implementation.
3. Не строить backend до завершения usable local MVP.
4. Любая новая persisted entity должна быть sync-friendly.
5. Все schema changes должны идти через Drift migration.
6. Business calculations не должны жить во Flutter widgets.
7. Network failures не должны ломать local functionality.
8. Remote product data всегда normalize в domain model.
9. Diary history должна оставаться стабильной после изменения food source.
10. Любой основной workflow оценивать по количеству taps/clicks.
11. Desktop UI не должен быть просто stretched mobile UI.
12. Любой сложный расчёт должен иметь unit tests.
13. Не использовать platform checks напрямую в feature UI, если можно выразить capability.
14. Не менять архитектуру проекта только ради следования design pattern.
15. Перед крупным изменением обновлять этот blueprint или отдельный ADR.

---

# 72. ADRs

Для важных решений можно создать:

```text
docs/adr/
```

Например:

```text
0001-local-first.md
0002-sqlite-drift.md
0003-diary-snapshots.md
0004-uuid-v7.md
0005-sync-changelog.md
0006-food-provider-normalization.md
```

Это поможет не забывать, почему решение было принято.

---

# 73. Suggested repository structure

```text
nutrition-tracker/
├── README.md
├── PROJECT_BLUEPRINT.md
├── pubspec.yaml
│
├── docs/
│   ├── adr/
│   ├── database.md
│   ├── sync.md
│   └── ux.md
│
├── assets/
│   ├── foods/
│   └── icons/
│
├── lib/
│   ├── app/
│   ├── core/
│   ├── domain/
│   ├── features/
│   └── main.dart
│
├── test/
│
├── android/
├── ios/
├── macos/
├── linux/
└── windows/
```

Windows можно оставить generated, даже если официально не приоритет.

---

# 74. Definition of "good"

Приложение считается хорошим, если пользователь может:

1. открыть его;
2. увидеть сегодняшний intake;
3. нажать `+`;
4. тапнуть по часто используемому продукту;
5. закрыть приложение;

за несколько секунд.

И при этом:

- всё работает offline;
- история не ломается;
- расчёты правильные;
- графики понятные;
- приложение не требует аккаунт;
- данные принадлежат пользователю;
- можно сделать backup;
- позже можно бесшовно подключить sync.

---

# 75. Immediate next task

Начинать не с API и не с barcode.

Первый development slice:

```text
1. Flutter project
2. Riverpod
3. go_router
4. Drift
5. adaptive app shell
6. domain Nutrition/Food
7. meal sections
8. diary entries
9. daily totals
10. local custom food
```

После этого должна появиться первая версия, в которой можно вручную создать несколько своих продуктов и реально вести дневник.

Это важнее любых внешних интеграций.

Когда этот slice стабилен:

```text
→ local search
→ built-in foods
→ Open Food Facts
→ barcode
→ recipes
→ stats
→ export
→ sync
```

---

# 76. Core mantra

```text
LOCAL FIRST
FAST INPUT
CORRECT CALCULATIONS
STABLE HISTORY
GOOD UX
SYNC LATER
```

Если архитектурное или продуктовое решение противоречит этим принципам — его нужно отдельно обосновать.
