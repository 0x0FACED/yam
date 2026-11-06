import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/assistant/application/assistant_tools.dart';
import 'package:yam/features/assistant/domain/assistant_models.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

Map<String, dynamic> _product({String name = 'Soup', String? barcode}) => {
  'name': name,
  'category': 'Homemade',
  'basis': 'milliliters',
  'basisAmount': 100,
  'proteinG': 3.1234567890123,
  'fatG': 1.9876543210987,
  'carbsG': 7.1234567890123,
  'barcode': ?barcode,
  'servings': [
    {'unit': 'glass', 'baseAmount': 237.1234567890123},
  ],
};

Map<String, dynamic> _newItem({
  String? barcode,
  bool save = false,
  bool add = true,
}) => {
  'newProduct': _product(barcode: barcode),
  'servingId': 'new-serving-0',
  'amount': 1.234567890123,
  'isEstimated': true,
  'saveToCatalog': save,
  'addToDiary': add,
};

Future<Map<String, dynamic>> _prepare(
  AssistantTools tools,
  List<Map<String, dynamic>> items,
) => tools.execute('prepare_draft', {
  'day': '2026-11-06',
  'mealId': 'dinner',
  'items': items,
});

void main() {
  late YamDatabase db;
  late UserFoodRepository userFoods;
  late DiaryRepository diary;
  late AssistantTools tools;
  final day = DateTime(2026, 11, 6);

  setUp(() {
    db = YamDatabase(NativeDatabase.memory());
    userFoods = UserFoodRepository(db);
    diary = DiaryRepository(db);
    tools = AssistantTools(
      database: db,
      userFoods: userFoods,
      diary: diary,
      locale: const Locale('en'),
    );
  });
  tearDown(() => db.close());

  test(
    'tools are function-only; unknown calls and forged arguments cannot write',
    () async {
      expect(tools.definitions.map((tool) => tool['type']).toSet(), {
        'function',
      });
      expect(await tools.execute('commit', {}), {
        'error': {'code': 'unknown_tool'},
      });
      final result = await _prepare(tools, [
        {'foodId': 'rolled-oats', 'servingId': 'grams', 'amount': 80},
      ]);
      expect(result['error'], {'code': 'food_lookup_required'});
      await tools.execute('get_food', {'foodId': 'rolled-oats'});
      expect(
        (await _prepare(tools, [
          {
            'foodId': 'rolled-oats',
            'servingId': 'grams',
            'amount': 80,
            'nutritionPerBasis': {'kcal': 0},
          },
        ]))['error'],
        {'code': 'invalid_arguments'},
      );
      expect(await db.select(db.diaryEntries).get(), isEmpty);
      expect(await db.select(db.userFoods).get(), isEmpty);
      expect(await db.select(db.installationValues).get(), isEmpty);
    },
  );

  test(
    'bounded localized search includes exact real servings, not entire catalog',
    () async {
      final russian = AssistantTools(
        database: db,
        userFoods: userFoods,
        diary: diary,
        locale: const Locale('ru'),
      );
      final result = await russian.execute('search_foods', {
        'query': 'молоко',
        'limit': 1,
      });
      final foods = result['foods'] as List;
      expect(foods, hasLength(1));
      expect((foods.single as Map)['name'], 'Молоко 2,5%');
      expect((foods.single as Map)['baseUnit'], 'milliliters');
      expect(
        (await tools.execute('search_foods', {
          'query': '',
          'limit': 20,
        }))['error'],
        isNotNull,
      );
    },
  );

  test(
    'canonical coefficients and full precision survive confirmation and reentry',
    () async {
      await tools.execute('get_food', {'foodId': 'milk-25'});
      expect(
        (await _prepare(tools, [
          {'foodId': 'milk-25', 'servingId': 'glass', 'amount': 1.234567890123},
        ]))['error'],
        isNull,
      );
      final draft = tools.draft!;
      expect(draft.items.single.canonicalQuantity, 250 * 1.234567890123);
      expect(await db.select(db.diaryEntries).get(), isEmpty);
      final first = tools.commit(draft);
      final second = tools.commit(draft);
      expect(identical(first, second), isTrue);
      final ids = await first;
      expect(await second, ids);
      expect(await tools.commit(draft), ids);
      final entries = await diary.watchDay(day).first;
      expect(entries, hasLength(1));
      expect(entries.single.food.baseUnit, DiaryBaseUnit.milliliters);
      expect(entries.single.canonicalQuantity, 250 * 1.234567890123);
      expect(entries.single.nutrition.kcal, 52 * (250 * 1.234567890123 / 100));
      expect(entries.single.isEstimated, isFalse);
    },
  );

  test(
    'estimated diary-only new product uses macro policy and never pollutes catalog',
    () async {
      expect((await _prepare(tools, [_newItem()]))['error'], isNull);
      final item = tools.draft!.items.single;
      final expected =
          item.newFood!.energyKcal * (item.canonicalQuantity / 100);
      expect(await db.select(db.userFoods).get(), isEmpty);
      expect(await db.select(db.diaryEntries).get(), isEmpty);
      await tools.commit(tools.draft!);
      expect(await userFoods.loadFoods(), isEmpty);
      final saved = (await diary.watchDay(day).first).single;
      expect(saved.isEstimated, isTrue);
      expect(saved.nutrition.kcal, expected);
      expect(saved.canonicalQuantity, 237.1234567890123 * 1.234567890123);
    },
  );

  test('catalog-only product saves no diary and is idempotent', () async {
    await _prepare(tools, [_newItem(save: true, add: false)]);
    final draft = tools.draft!;
    expect(draft.hasDiaryItems, isFalse);
    expect(await tools.commit(draft), isEmpty);
    expect(await tools.commit(draft), isEmpty);
    final saved = (await userFoods.loadFoods()).single;
    expect(saved.food.energyKcal, draft.items.single.newFood!.energyKcal);
    expect(saved.food.basisUnit, 'milliliters');
    expect(await diary.watchDay(day).first, isEmpty);
  });

  test(
    'UI can edit custom food and save linked catalog and diary snapshot together',
    () async {
      await _prepare(tools, [_newItem(save: true)]);
      final original = tools.draft!;
      final item = original.items.single;
      const edited = CustomFoodDraft(
        name: 'Edited soup',
        category: 'Other',
        basis: CustomFoodBasis.milliliters,
        basisAmount: 100,
        displayBasis: CustomFoodDisplayBasis.perHundredMilliliters,
        proteinG: 5,
        fatG: 2,
        carbsG: 9,
        servings: [
          CustomServingDraft(
            unit: CustomServingUnit.glass,
            baseAmount: 180.125,
            defaultAmount: 1,
          ),
        ],
      );
      final changed = item.copyWith(
        newFood: edited,
        food: tools.snapshotForNewFood(edited, foodId: item.food.foodId),
        amount: 0.5,
      );
      await tools.commit(original.copyWith(items: [changed], mealId: 'lunch'));
      final food = (await userFoods.loadFoods()).single;
      final entry = (await diary.watchDay(day).first).single;
      expect(entry.food.foodId, food.food.id);
      expect(entry.food.name, 'Edited soup');
      expect(entry.canonicalQuantity, 90.0625);
      expect(entry.nutrition.kcal, edited.energyKcal * 0.900625);
      expect(entry.mealId, 'lunch');
      expect(entry.isEstimated, isTrue);
    },
  );

  test(
    'a later catalog conflict rolls back ALL products and entries, then retry works',
    () async {
      await _prepare(tools, [
        _newItem(barcode: '123', save: true),
        _newItem(barcode: '123', save: true),
      ]);
      final draft = tools.draft!;
      await expectLater(tools.commit(draft), throwsA(isA<AssistantFailure>()));
      expect(await db.select(db.userFoods).get(), isEmpty);
      expect(await db.select(db.userServings).get(), isEmpty);
      expect(await db.select(db.diaryEntries).get(), isEmpty);
      expect(await db.select(db.installationValues).get(), isEmpty);
      final second = draft.items.last;
      final updated = second.copyWith(saveToCatalog: false);
      final ids = await tools.commit(
        draft.copyWith(items: [draft.items.first, updated]),
      );
      expect(ids, hasLength(2));
      expect(await userFoods.loadFoods(), hasLength(1));
      expect(await diary.watchDay(day).first, hasLength(2));
    },
  );

  test(
    'failure after an entry insertion rolls back and the exact same draft can retry',
    () async {
      final failing = _FailOnceDiary(db);
      final retryTools = AssistantTools(
        database: db,
        userFoods: userFoods,
        diary: failing,
        locale: const Locale('en'),
      );
      await _prepare(retryTools, [_newItem(save: true)]);
      final draft = retryTools.draft!;
      await expectLater(
        retryTools.commit(draft),
        throwsA(isA<AssistantFailure>()),
      );
      expect(await userFoods.loadFoods(), isEmpty);
      expect(await diary.watchDay(day).first, isEmpty);
      expect(await retryTools.commit(draft), hasLength(1));
      expect(await retryTools.commit(draft), hasLength(1));
      expect(await userFoods.loadFoods(), hasLength(1));
      expect(await diary.watchDay(day).first, hasLength(1));
    },
  );

  test(
    'existing catalog snapshots cannot be replaced with fabricated nutrition',
    () async {
      await tools.execute('get_food', {'foodId': 'rolled-oats'});
      await _prepare(tools, [
        {'foodId': 'rolled-oats', 'servingId': 'grams', 'amount': 80},
      ]);
      final draft = tools.draft!;
      final item = draft.items.single;
      final forged = DiaryFoodSnapshot(
        foodId: item.food.foodId,
        name: item.food.name,
        baseUnit: item.food.baseUnit,
        basisAmount: item.food.basisAmount,
        servings: item.food.servings,
        nutritionPerBasis: const DiaryNutrition(
          kcal: 0,
          protein: 0,
          fat: 0,
          carbs: 0,
        ),
      );
      await expectLater(
        tools.commit(draft.copyWith(items: [item.copyWith(food: forged)])),
        throwsA(isA<AssistantFailure>()),
      );
      expect(await diary.watchDay(day).first, isEmpty);
      expect(await tools.commit(draft), hasLength(1));
    },
  );

  test(
    'unknown draft and extra item identity cannot obtain commit capability',
    () async {
      await _prepare(tools, [_newItem()]);
      final draft = tools.draft!;
      await expectLater(
        tools.commit(
          AssistantDraft(
            id: 'invented',
            day: draft.day,
            mealId: draft.mealId,
            items: draft.items,
          ),
        ),
        throwsA(isA<AssistantFailure>()),
      );
      await expectLater(
        tools.commit(
          draft.copyWith(items: [draft.items.single, draft.items.single]),
        ),
        throwsA(isA<AssistantFailure>()),
      );
      expect(await diary.watchDay(day).first, isEmpty);
    },
  );

  test(
    'catalog edits after preparation cannot silently change confirmed nutrition',
    () async {
      await _prepare(tools, [_newItem(save: true, add: false)]);
      await tools.commit(tools.draft!);
      final saved = (await userFoods.loadFoods()).single;
      await tools.execute('get_food', {'foodId': saved.food.id});
      await _prepare(tools, [
        {'foodId': saved.food.id, 'servingId': 'milliliters', 'amount': 100},
      ]);
      final prepared = tools.draft!;
      await userFoods.update(
        saved.food.id,
        const CustomFoodDraft(
          name: 'Changed recipe',
          category: 'Homemade',
          basis: CustomFoodBasis.milliliters,
          basisAmount: 100,
          displayBasis: CustomFoodDisplayBasis.perHundredMilliliters,
          proteinG: 10,
          fatG: 10,
          carbsG: 10,
          servings: [],
        ),
      );
      await expectLater(
        tools.commit(prepared),
        throwsA(
          isA<AssistantFailure>().having(
            (error) => error.code,
            'code',
            'food_changed',
          ),
        ),
      );
      expect(await diary.watchDay(day).first, isEmpty);
    },
  );

  test('read_diary is scoped and preserves estimated flag', () async {
    await _prepare(tools, [_newItem()]);
    await tools.commit(tools.draft!);
    final read = await tools.execute('read_diary', {'day': '2026-11-06'});
    expect((read['entries'] as List).single['isEstimated'], isTrue);
    expect(
      (await tools.execute('read_diary', {'day': '2026-11-07'}))['entries'],
      isEmpty,
    );
    expect(
      (await tools.execute('read_diary', {'day': '2026-02-30'}))['error'],
      isNotNull,
    );
  });

  for (final amount in [0, -1, double.nan, double.infinity]) {
    test(
      'rejects invalid amount $amount without replacing an earlier valid draft',
      () async {
        await _prepare(tools, [_newItem()]);
        final original = tools.draft;
        expect(
          (await _prepare(tools, [
            {..._newItem(), 'amount': amount},
          ]))['error'],
          isNotNull,
        );
        expect(identical(tools.draft, original), isTrue);
        expect(await diary.watchDay(day).first, isEmpty);
      },
    );
  }

  test(
    'rejects invalid date, meal, unit and new-product energy injection',
    () async {
      for (final override in <Map<String, dynamic>>[
        {'day': '2026-02-30'},
        {'day': '2026-11-06T00:00:00Z'},
        {'mealId': 'brunch'},
      ]) {
        final result = await tools.execute('prepare_draft', {
          'day': '2026-11-06',
          'mealId': 'dinner',
          'items': [_newItem()],
          ...override,
        });
        expect(result['error'], isNotNull);
      }
      expect(
        (await _prepare(tools, [
          {..._newItem(), 'servingId': 'grams'},
        ]))['error'],
        isNotNull,
      );
      expect(
        (await _prepare(tools, [
          {
            ..._newItem(),
            'newProduct': {..._product(), 'energyKcal': 1},
          },
        ]))['error'],
        isNotNull,
      );
      expect(await db.select(db.diaryEntries).get(), isEmpty);
    },
  );
}

class _FailOnceDiary extends DiaryRepository {
  _FailOnceDiary(super.database);
  bool fail = true;
  @override
  Future<String> create(DiaryEntryDraft draft) async {
    final id = await super.create(draft);
    if (fail) {
      fail = false;
      throw StateError('private SQL/database failure must not escape');
    }
    return id;
  }
}
