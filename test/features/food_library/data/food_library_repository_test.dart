import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/food_library/data/food_library_repository.dart';
import 'package:yam/features/food_search/data/user_food_repository.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

final _created = DateTime.utc(2025, 1, 1, 12);
final _updated = DateTime.utc(2025, 1, 3, 12);
final _deleted = DateTime.utc(2025, 1, 2, 12);
const _kcal = 251.1234567890123;
const _protein = 9.1234567890123;
const _fat = 3.333333333333333;
const _carbs = 42.9876543210987;

String _id(int value) =>
    '019a0000-0000-7000-8000-${value.toRadixString(16).padLeft(12, '0')}';

void main() {
  YamDatabase database() {
    final value = YamDatabase(NativeDatabase.memory());
    addTearDown(value.close);
    return value;
  }

  test(
    'exact food presentation and independent kcal survive a roundtrip',
    () async {
      final source = database();
      await source.batch((batch) {
        batch.insertAll(source.userFoods, [
          _storedFood(1).copyWith(
            name: '  Домашняя каша  ',
            category: 'Мои рецепты 🥣',
            brand: const Value('  House brand  '),
            barcode: const Value('00012345'),
            description: const Value(
              '  Mix.\n\nRest overnight.\r\nServe cold.  ',
            ),
            basisAmount: 80.1234567890123,
            displayBasis: 'perServing',
          ),
          _storedFood(2).copyWith(
            name: 'Milk per 100 ml',
            basisUnit: 'milliliters',
            displayBasis: 'perHundredMilliliters',
          ),
          _storedFood(3).copyWith(name: 'Grams per 100 g'),
          _storedFood(4).copyWith(
            name: '100 ml is a serving',
            basisUnit: 'milliliters',
            displayBasis: 'perServing',
          ),
        ]);
        batch.insertAll(source.userServings, [
          _storedServing(10, 1).copyWith(
            baseAmount: 80.1234567890123,
            defaultAmount: 1.375,
            label: const Value('  Bowl · миска  '),
          ),
          _storedServing(11, 1).copyWith(
            unit: 'piece',
            baseAmount: 12.3456789012345,
            defaultAmount: 2.25,
            label: const Value('bar'),
          ),
          _storedServing(12, 1).copyWith(
            unit: 'scoop',
            baseAmount: 9.8765432109876,
            defaultAmount: 0.5,
          ),
          _storedServing(13, 4).copyWith(baseAmount: 100),
          _storedServing(14, 2).copyWith(
            unit: 'glass',
            baseAmount: 237.1234567890123,
            defaultAmount: 1.125,
            label: const Value('glass'),
          ),
        ]);
      });
      final before = await _state(source);
      final bytes = await FoodLibraryRepository(source).exportLibrary();
      expect(await _state(source), before, reason: 'export is read-only');
      expect(utf8.decode(bytes), contains('\n  "format": "yam-foods"'));
      final exported = _json(bytes);
      expect(exported.keys, ['format', 'version', 'foods']);
      expect(exported['format'], 'yam-foods');
      expect(exported['version'], 1);
      final first = (exported['foods'] as List).first as Map<String, dynamic>;
      expect(first['kcal'], _kcal);
      expect(first['kcal'], isNot(_protein * 4 + _fat * 9 + _carbs * 4));
      expect(first['basisAmount'], 80.1234567890123);
      expect(first['name'], '  Домашняя каша  ');
      expect(first['category'], 'Мои рецепты 🥣');
      expect(first['brand'], '  House brand  ');
      expect(
        first['description'],
        '  Mix.\n\nRest overnight.\r\nServe cold.  ',
      );
      expect(first.keys, isNot(contains('id')));
      expect(first.keys, isNot(contains('deviceId')));
      expect(first.keys, isNot(contains('isFavorite')));
      expect(first.keys, isNot(contains('createdAt')));
      expect(first.keys, isNot(contains('updatedAt')));
      expect(first.keys, isNot(contains('deletedAt')));
      final sourceIds = {
        for (final row in before['userFoods']!) row['id'],
        for (final row in before['userServings']!) row['id'],
      };

      final destination = database();
      await _identity(destination);
      final repository = FoodLibraryRepository(destination);
      final preview = await repository.inspectLibrary(bytes);
      expect(preview.foodCount, 4);
      expect(preview.servingCount, 5);
      final result = await repository.importLibrary(
        preview,
        FoodLibraryImportMode.mergeAll,
      );
      expect([result.imported, result.skipped, result.replaced], [4, 0, 0]);
      expect(_json(await repository.exportLibrary()), exported);
      final importedFoods = await destination
          .select(destination.userFoods)
          .get();
      final importedServings = await destination
          .select(destination.userServings)
          .get();
      expect(importedFoods.every((row) => !row.isFavorite), isTrue);
      for (final row in [...importedFoods, ...importedServings]) {
        final json = row is StoredUserFood
            ? row.toJson()
            : (row as StoredUserServing).toJson();
        expect((json['id'] as String)[14], '7');
        expect(sourceIds, isNot(contains(json['id'])));
        expect(json['deviceId'], _id(900));
        expect(json['createdAt'], isNot(_created.millisecondsSinceEpoch));
        expect(json['createdAt'], json['updatedAt']);
        expect(json['deletedAt'], isNull);
      }
      final userRepository = UserFoodRepository(destination);
      final editable = (await userRepository.loadFoods()).first;
      expect(
        await userRepository.update(
          editable.food.id,
          const CustomFoodDraft(
            name: 'Edited imported food',
            category: 'User category',
            basis: CustomFoodBasis.grams,
            basisAmount: 100,
            displayBasis: CustomFoodDisplayBasis.perHundredGrams,
            proteinG: 3,
            fatG: 2,
            carbsG: 1,
            servings: [],
          ),
        ),
        isTrue,
      );
    },
  );

  test(
    'export includes only active user products and active own portions',
    () async {
      final db = database();
      await _seed(db);
      await db.into(db.userServings).insert(_storedServing(12, 2));
      final before = await _state(db);
      final repository = FoodLibraryRepository(db);
      final output = _json(await repository.exportLibrary());
      final foods = (output['foods'] as List).cast<Map<String, dynamic>>();
      expect(foods, hasLength(1));
      expect(foods.single['name'], 'Oats');
      final servings = (foods.single['servings'] as List)
          .cast<Map<String, dynamic>>();
      expect(servings, hasLength(1));
      expect(servings.single.keys, [
        'unit',
        'baseAmount',
        'defaultAmount',
        'label',
      ]);
      expect(servings.single['label'], 'Bowl');
      expect(await _state(db), before);
    },
  );

  test(
    'replace only tombstones active user data and preserves historical snapshots',
    () async {
      final db = database();
      await _seed(db);
      final before = await _state(db);
      final originalFoods = await db.select(db.userFoods).get();
      final originalServings = await db.select(db.userServings).get();
      final repository = FoodLibraryRepository(db);
      final duplicate = _jsonFood({'barcode': '001', 'basisAmount': 80});
      final result = await repository.importLibrary(
        await repository.inspectLibrary(_bytes([duplicate, duplicate])),
        FoodLibraryImportMode.replace,
      );
      expect([result.imported, result.skipped, result.replaced], [2, 0, 1]);
      final after = await _state(db);
      for (final key in [
        'diary',
        'goals',
        'weights',
        'remote',
        'installation',
      ]) {
        expect(after[key], before[key], reason: key);
      }
      final rows = await db.select(db.userFoods).get();
      final old = rows.singleWhere((row) => row.id == _id(1));
      expect(old.deletedAt, isNotNull);
      expect(old.deletedAt, old.updatedAt);
      expect(old.barcode, '001');
      expect(old.deviceId, _id(800));
      expect(old.createdAt, originalFoods.first.createdAt);
      expect(
        rows.singleWhere((row) => row.id == _id(2)),
        originalFoods.singleWhere((row) => row.id == _id(2)),
      );
      final servings = await db.select(db.userServings).get();
      final oldServing = servings.singleWhere((row) => row.id == _id(10));
      expect(oldServing.deletedAt, old.deletedAt);
      expect(oldServing.updatedAt, old.deletedAt);
      expect(
        servings.singleWhere((row) => row.id == _id(11)),
        originalServings.singleWhere((row) => row.id == _id(11)),
      );
      expect(rows.where((row) => row.deletedAt == null), hasLength(2));
      expect(
        rows
            .where((row) => row.deletedAt == null)
            .every((row) => row.deviceId == _id(900)),
        isTrue,
      );
      final entries = await DiaryRepository(
        db,
      ).watchDay(DateTime(2025, 1, 1)).first;
      expect(entries, hasLength(1));
      expect(entries.single.food.name, 'Historical oats');
      expect(entries.single.food.serving(_id(10)).baseAmount, 80);
      expect(entries.single.nutrition.kcal, _kcal * 1.25);
    },
  );

  test(
    'dedup uses normalized name and brand plus exact unit basis and nutrition',
    () async {
      final db = database();
      await db.batch((batch) {
        batch.insertAll(db.userFoods, [
          _storedFood(1).copyWith(
            name: '  OAT\t bowl  ',
            brand: const Value(' ACME   Foods '),
          ),
          _storedFood(2, deleted: true).copyWith(name: 'Deleted match'),
        ]);
        batch.insert(db.remoteFoods, _remote().copyWith(name: 'Remote match'));
      });
      final before = await _state(db);
      final variants = [
        {'kcal': 251.12345678901235},
        {'protein': 9.12345678901235},
        {'fat': 3.333333333333334},
        {'carbs': 42.98765432109871},
        {'basisAmount': 80},
        {'unit': 'ml'},
        {'brand': 'Other brand'},
      ];
      final incoming = [
        _jsonFood({
          'name': 'oat  BOWL',
          'brand': 'acme\nfoods',
          'category': 'Ignored by dedup',
          'barcode': '999',
          'description': 'Do not update the existing product',
          'displayBasis': 'perServing',
        }),
        _jsonFood({
          'name': '  Rice  bowl ',
          'brand': null,
          'description': 'first',
        }),
        _jsonFood({'name': 'rice\tBOWL', 'brand': '', 'description': 'second'}),
        _jsonFood({
          'name': 'RICE bowl',
          'brand': ' \n ',
          'description': 'third',
        }),
        for (final variant in variants)
          _jsonFood({'name': 'oat bowl', 'brand': 'acme foods', ...variant}),
        _jsonFood({'name': 'Deleted match'}),
        _jsonFood({'name': 'Remote match'}),
      ];
      final repository = FoodLibraryRepository(db);
      final preview = await repository.inspectLibrary(_bytes(incoming));
      final result = await repository.importLibrary(
        preview,
        FoodLibraryImportMode.mergeDeduplicated,
      );
      expect([result.imported, result.skipped, result.replaced], [10, 3, 0]);
      final rows = await db.select(db.userFoods).get();
      expect(rows.where((row) => row.deletedAt == null), hasLength(11));
      expect(
        rows.singleWhere((row) => row.id == _id(1)).toJson(),
        before['userFoods']!.first,
      );
      expect(
        rows.singleWhere((row) => row.name == '  Rice  bowl ').description,
        'first',
      );
      expect(rows.where((row) => row.description == 'second'), isEmpty);
      expect(rows.where((row) => row.description == 'third'), isEmpty);
      expect(
        rows.where(
          (row) => row.name == 'Deleted match' && row.deletedAt == null,
        ),
        hasLength(1),
      );
      expect(rows.where((row) => row.name == 'Remote match'), hasLength(1));
      final repeated = await repository.importLibrary(
        preview,
        FoodLibraryImportMode.mergeDeduplicated,
      );
      expect(
        [repeated.imported, repeated.skipped, repeated.replaced],
        [0, 13, 0],
      );
    },
  );

  test(
    'dedup reads current active rows at import time rather than preview time',
    () async {
      final db = database();
      final repository = FoodLibraryRepository(db);
      final bytes = _bytes([_jsonFood()]);
      final preview = await repository.inspectLibrary(bytes);
      bytes.fillRange(0, bytes.length, 0);
      await db.into(db.userFoods).insert(_storedFood(1));
      final before = await _state(db);
      final result = await repository.importLibrary(
        preview,
        FoodLibraryImportMode.mergeDeduplicated,
      );
      expect([result.imported, result.skipped, result.replaced], [0, 1, 0]);
      expect(await _state(db), before);
    },
  );

  test(
    'mergeAll adds every repeated barcode and gives every entity a fresh UUIDv7',
    () async {
      final db = database();
      final repository = FoodLibraryRepository(db);
      final food = _jsonFood({
        'barcode': '00012345',
        'basisAmount': 80,
        'servings': [
          {'unit': 'piece', 'baseAmount': 40},
        ],
        'id': _id(1),
        'deviceId': 'untrusted',
        'isFavorite': true,
      });
      final preview = await repository.inspectLibrary(_bytes([food, food]));
      expect(preview.foodCount, 2);
      expect(preview.servingCount, 4);
      for (var attempt = 0; attempt < 2; attempt++) {
        final result = await repository.importLibrary(
          preview,
          FoodLibraryImportMode.mergeAll,
        );
        expect([result.imported, result.skipped, result.replaced], [2, 0, 0]);
      }
      final foods = await db.select(db.userFoods).get();
      final servings = await db.select(db.userServings).get();
      expect(foods, hasLength(4));
      expect(servings, hasLength(8));
      expect(foods.every((row) => row.barcode == '00012345'), isTrue);
      expect(foods.every((row) => !row.isFavorite), isTrue);
      final ids = [
        ...foods.map((row) => row.id),
        ...servings.map((row) => row.id),
      ];
      expect(ids.toSet(), hasLength(12));
      expect(ids.every((id) => id[14] == '7'), isTrue);
      expect(ids, isNot(contains(_id(1))));
      expect(servings.every((row) => row.defaultAmount == 1), isTrue);
      final deviceId =
          (await db.select(db.installationValues).get()).single.value;
      expect(deviceId[14], '7');
      expect(foods.every((row) => row.deviceId == deviceId), isTrue);
      expect(servings.every((row) => row.deviceId == deviceId), isTrue);
    },
  );

  test(
    'optional nulls unknown fields and UTF8 BOM are accepted with serving defaults',
    () async {
      final db = database();
      final repository = FoodLibraryRepository(db);
      final document = {
        'format': 'yam-foods',
        'version': 1,
        'futureRoot': {'enabled': true},
        'foods': [
          _jsonFood({
            'name': 'Жидкая каша',
            'unit': 'ml',
            'basisAmount': 125.1234567890123,
            'brand': null,
            'barcode': null,
            'description': null,
            'displayBasis': null,
            'servings': [
              {
                'unit': 'glass',
                'baseAmount': 250,
                'defaultAmount': null,
                'label': null,
                'futureServing': 1,
              },
            ],
            'futureFood': [1, 2, 3],
          }),
          _jsonFood({'name': 'Null portions', 'servings': null}),
        ],
      };
      final preview = await repository.inspectLibrary(
        Uint8List.fromList([
          0xef,
          0xbb,
          0xbf,
          ...utf8.encode(jsonEncode(document)),
        ]),
      );
      expect(preview.foodCount, 2);
      expect(preview.servingCount, 2);
      await repository.importLibrary(preview, FoodLibraryImportMode.mergeAll);
      final foods = await db.select(db.userFoods).get();
      final food = foods.singleWhere((row) => row.name == 'Жидкая каша');
      expect(food.basisUnit, 'milliliters');
      expect(food.displayBasis, 'perServing');
      expect(food.brand, isNull);
      expect(food.barcode, isNull);
      expect(food.description, isNull);
      final servings = await db.select(db.userServings).get();
      expect(servings.every((row) => row.defaultAmount == 1), isTrue);
      expect(
        servings.singleWhere((row) => row.unit == 'serving').baseAmount,
        food.basisAmount,
      );
      expect(
        foods.singleWhere((row) => row.name == 'Null portions').displayBasis,
        'perHundredGrams',
      );
    },
  );

  test(
    'all modes reject a later invalid row before touching any persisted state',
    () async {
      final db = database();
      await _seed(db);
      final repository = FoodLibraryRepository(db);
      final before = await _state(db);
      for (final mode in FoodLibraryImportMode.values) {
        await expectLater(
          () async => repository.importLibrary(
            await repository.inspectLibrary(
              _bytes([
                _jsonFood(),
                _jsonFood({'kcal': -1}),
              ]),
            ),
            mode,
          ),
          throwsA(_failure(FoodLibraryFailure.invalidFile, r'$.foods[1].kcal')),
        );
        expect(await _state(db), before, reason: mode.name);
      }
    },
  );

  final invalidFoods = <(Map<String, Object?>, String)>[
    ({'name': ' \t '}, r'$.foods[0].name'),
    ({'category': null}, r'$.foods[0].category'),
    ({'unit': 'kg'}, r'$.foods[0].unit'),
    ({'basisAmount': 0}, r'$.foods[0].basisAmount'),
    ({'basisAmount': -1}, r'$.foods[0].basisAmount'),
    ({'kcal': -1}, r'$.foods[0].kcal'),
    ({'protein': '3'}, r'$.foods[0].protein'),
    ({'fat': true}, r'$.foods[0].fat'),
    ({'carbs': null}, r'$.foods[0].carbs'),
    ({'brand': 1}, r'$.foods[0].brand'),
    ({'barcode': '12e3'}, r'$.foods[0].barcode'),
    ({'barcode': 123}, r'$.foods[0].barcode'),
    ({'barcode': ''}, r'$.foods[0].barcode'),
    ({'description': <String, Object?>{}}, r'$.foods[0].description'),
    ({'displayBasis': 'per10'}, r'$.foods[0].displayBasis'),
    ({'basisAmount': 80, 'displayBasis': 'per100'}, r'$.foods[0].displayBasis'),
    ({'servings': <String, Object?>{}}, r'$.foods[0].servings'),
    (
      {
        'servings': [null],
      },
      r'$.foods[0].servings[0]',
    ),
    (
      {
        'servings': [
          {'unit': 'g', 'baseAmount': 10},
        ],
      },
      r'$.foods[0].servings[0].unit',
    ),
    (
      {
        'servings': [
          {'unit': 'piece', 'baseAmount': 0},
        ],
      },
      r'$.foods[0].servings[0].baseAmount',
    ),
    (
      {
        'servings': [
          {'unit': 'piece', 'baseAmount': 10, 'defaultAmount': 0},
        ],
      },
      r'$.foods[0].servings[0].defaultAmount',
    ),
    (
      {
        'servings': [
          {'unit': 'piece', 'baseAmount': 10, 'label': 1},
        ],
      },
      r'$.foods[0].servings[0].label',
    ),
  ];
  for (var index = 0; index < invalidFoods.length; index++) {
    final (changes, path) = invalidFoods[index];
    test('invalid food field $index reports its JSON location', () async {
      final repository = FoodLibraryRepository(database());
      await expectLater(
        repository.inspectLibrary(_bytes([_jsonFood(changes)])),
        throwsA(_failure(FoodLibraryFailure.invalidFile, path)),
      );
    });
  }

  test(
    'format version document types malformed bytes and nonfinite numbers are rejected',
    () async {
      final repository = FoodLibraryRepository(database());
      final invalidDocuments = <(Object?, FoodLibraryFailure, String)>[
        ([], FoodLibraryFailure.invalidFile, r'$'),
        (
          {'format': 'yam-backup', 'version': 1, 'foods': []},
          FoodLibraryFailure.invalidFile,
          r'$.format',
        ),
        (
          {'format': 'yam-foods', 'version': 2, 'foods': []},
          FoodLibraryFailure.unsupportedVersion,
          r'$.version',
        ),
        (
          {'format': 'yam-foods', 'version': 0, 'foods': []},
          FoodLibraryFailure.invalidFile,
          r'$.version',
        ),
        (
          {'format': 'yam-foods', 'version': '1', 'foods': []},
          FoodLibraryFailure.invalidFile,
          r'$.version',
        ),
        (
          {'format': 'yam-foods', 'version': 1.0, 'foods': []},
          FoodLibraryFailure.invalidFile,
          r'$.version',
        ),
        (
          {'format': 'yam-foods', 'version': 1, 'foods': {}},
          FoodLibraryFailure.invalidFile,
          r'$.foods',
        ),
        (
          {
            'format': 'yam-foods',
            'version': 1,
            'foods': [null],
          },
          FoodLibraryFailure.invalidFile,
          r'$.foods[0]',
        ),
      ];
      for (final (value, failure, path) in invalidDocuments) {
        await expectLater(
          repository.inspectLibrary(
            Uint8List.fromList(utf8.encode(jsonEncode(value))),
          ),
          throwsA(_failure(failure, path)),
        );
      }
      for (final bytes in [
        Uint8List.fromList([0xc3, 0x28]),
        Uint8List.fromList(utf8.encode('{"private recipe secret":')),
        Uint8List(0),
      ]) {
        await expectLater(
          repository.inspectLibrary(bytes),
          throwsA(_failure(FoodLibraryFailure.invalidFile, r'$')),
        );
      }
      for (final field in ['basisAmount', 'kcal', 'protein', 'fat', 'carbs']) {
        final document = utf8.decode(
          _bytes([
            _jsonFood({field: 'nonfinite-marker'}),
          ]),
        );
        await expectLater(
          repository.inspectLibrary(
            Uint8List.fromList(
              utf8.encode(document.replaceFirst('"nonfinite-marker"', '1e309')),
            ),
          ),
          throwsA(
            _failure(FoodLibraryFailure.invalidFile, '\$.foods[0].$field'),
          ),
        );
      }
    },
  );

  test(
    'byte food and serving limits reject the file without mutation',
    () async {
      final db = database();
      final repository = FoodLibraryRepository(db);
      final before = await _state(db);
      await expectLater(
        repository.inspectLibrary(Uint8List(maxFoodLibraryFileBytes + 1)),
        throwsA(_failure(FoodLibraryFailure.tooLarge, null)),
      );
      await expectLater(
        repository.inspectLibrary(_bytes(List<Object?>.filled(50001, null))),
        throwsA(_failure(FoodLibraryFailure.tooLarge, r'$.foods')),
      );
      await expectLater(
        repository.inspectLibrary(
          _bytes([
            _jsonFood({'servings': List<Object?>.filled(250001, null)}),
          ]),
        ),
        throwsA(_failure(FoodLibraryFailure.tooLarge, r'$.foods[0].servings')),
      );
      expect(await _state(db), before);
    },
  );

  test(
    'replace rolls back tombstones inserts and installation identity on write failure',
    () async {
      final db = database();
      await db.into(db.userFoods).insert(_storedFood(1));
      await db.into(db.userServings).insert(_storedServing(10, 1));
      await db.customStatement(
        "CREATE TRIGGER reject_food BEFORE INSERT ON user_foods "
        "WHEN NEW.name = 'Rejected' BEGIN SELECT RAISE(ABORT, 'forced'); END",
      );
      final before = await _state(db);
      final repository = FoodLibraryRepository(db);
      final preview = await repository.inspectLibrary(
        _bytes([
          _jsonFood({'name': 'First valid food'}),
          _jsonFood({'name': 'Rejected'}),
        ]),
      );
      await expectLater(
        repository.importLibrary(preview, FoodLibraryImportMode.replace),
        throwsA(isA<Exception>()),
      );
      expect(await _state(db), before);
    },
  );

  test(
    'empty replace clears only active library and empty merge does nothing',
    () async {
      final db = database();
      await _seed(db);
      final repository = FoodLibraryRepository(db);
      final preview = await repository.inspectLibrary(_bytes([]));
      expect(preview.foodCount, 0);
      expect(preview.servingCount, 0);
      final before = await _state(db);
      for (final mode in [
        FoodLibraryImportMode.mergeAll,
        FoodLibraryImportMode.mergeDeduplicated,
      ]) {
        final result = await repository.importLibrary(preview, mode);
        expect([result.imported, result.skipped, result.replaced], [0, 0, 0]);
        expect(await _state(db), before);
      }
      final result = await repository.importLibrary(
        preview,
        FoodLibraryImportMode.replace,
      );
      expect([result.imported, result.skipped, result.replaced], [0, 0, 1]);
      final output = _json(await repository.exportLibrary());
      expect(output['foods'], isEmpty);
    },
  );
}

Matcher _failure(FoodLibraryFailure failure, String? path) =>
    isA<FoodLibraryException>()
        .having((error) => error.failure, 'failure', failure)
        .having((error) => error.path, 'path', path);

Map<String, Object?> _jsonFood([Map<String, Object?> changes = const {}]) => {
  'name': 'Oats',
  'category': 'grains',
  'unit': 'g',
  'basisAmount': 100,
  'kcal': _kcal,
  'protein': _protein,
  'fat': _fat,
  'carbs': _carbs,
  ...changes,
};

Uint8List _bytes(List<Object?> foods) => Uint8List.fromList(
  utf8.encode(
    jsonEncode({'format': 'yam-foods', 'version': 1, 'foods': foods}),
  ),
);

Map<String, dynamic> _json(Uint8List bytes) =>
    jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;

StoredUserFood _storedFood(int id, {bool deleted = false}) => StoredUserFood(
  id: _id(id),
  name: 'Oats',
  category: 'grains',
  brand: null,
  description: 'Original note',
  barcode: null,
  basisUnit: 'grams',
  basisAmount: 100,
  displayBasis: 'perHundredGrams',
  energyKcal: _kcal,
  proteinG: _protein,
  fatG: _fat,
  carbsG: _carbs,
  isFavorite: true,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(800),
);

StoredUserServing _storedServing(int id, int foodId, {bool deleted = false}) =>
    StoredUserServing(
      id: _id(id),
      foodId: _id(foodId),
      unit: 'serving',
      label: 'Bowl',
      baseAmount: 80,
      defaultAmount: 1.25,
      createdAt: _created,
      updatedAt: _updated,
      deletedAt: deleted ? _deleted : null,
      deviceId: _id(800),
    );

StoredRemoteFood _remote() => StoredRemoteFood(
  id: _id(30),
  source: 'open_food_facts',
  sourceCode: '000111',
  name: 'Remote milk',
  brand: null,
  category: 'grains',
  basisUnit: 'grams',
  basisAmount: 100,
  energyKcal: _kcal,
  proteinG: _protein,
  fatG: _fat,
  carbsG: _carbs,
  lastAmount: 137.125,
  isFavorite: true,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: null,
  deviceId: _id(800),
);

Future<void> _identity(YamDatabase db) => db.batch((batch) {
  batch.insertAll(db.installationValues, [
    InstallationValuesCompanion.insert(key: 'deviceId', value: _id(900)),
    InstallationValuesCompanion.insert(key: 'keep', value: 'installation-only'),
  ]);
});

Future<void> _seed(YamDatabase db) async {
  await _identity(db);
  await db.batch((batch) {
    batch.insertAll(db.userFoods, [
      _storedFood(1).copyWith(barcode: const Value('001')),
      _storedFood(2, deleted: true),
    ]);
    batch.insertAll(db.userServings, [
      _storedServing(10, 1),
      _storedServing(11, 1, deleted: true),
    ]);
    batch.insert(db.remoteFoods, _remote());
    batch.insert(
      db.diaryEntries,
      StoredDiaryEntry(
        id: _id(40),
        diaryDay: '2025-01-01',
        mealId: 'breakfast',
        foodId: _id(1),
        foodName: 'Historical oats',
        brand: 'Old brand',
        baseUnit: 'grams',
        basisAmount: 80,
        kcalPerBasis: _kcal,
        proteinPerBasis: _protein,
        fatPerBasis: _fat,
        carbsPerBasis: _carbs,
        servingsSnapshot:
            '[ {"id":"grams","unit":"grams","label":null,"baseAmount":1.0}, '
            '{"id":"${_id(10)}","unit":"servings","label":"Old bowl","baseAmount":80.0} ]',
        servingId: _id(10),
        amount: 1.25,
        canonicalQuantity: 100,
        energyKcal: _kcal * 1.25,
        proteinG: _protein * 1.25,
        fatG: _fat * 1.25,
        carbsG: _carbs * 1.25,
        createdAt: _created,
        updatedAt: _updated,
        deletedAt: null,
        deviceId: _id(800),
      ),
    );
    batch.insert(
      db.goalVersions,
      StoredGoalVersion(
        id: _id(50),
        effectiveDay: '2025-01-01',
        goal: 'maintain',
        calorieTarget: 2137,
        proteinTarget: 101,
        fatTarget: 73,
        carbsTarget: 265,
        targetWeightKg: 67.1234567890123,
        createdAt: _created,
        updatedAt: _updated,
        deletedAt: null,
        deviceId: _id(800),
      ),
    );
    batch.insert(
      db.weightEntries,
      StoredWeightEntry(
        id: _id(60),
        localDay: '2025-01-01',
        weightKg: 68.1234567890123,
        source: 'manual',
        createdAt: _created,
        updatedAt: _updated,
        deletedAt: null,
        deviceId: _id(800),
      ),
    );
  });
}

Future<Map<String, List<Map<String, dynamic>>>> _state(YamDatabase db) async {
  List<Map<String, dynamic>> sorted(
    Iterable<Map<String, dynamic>> rows, [
    String key = 'id',
  ]) =>
      rows.toList()
        ..sort((a, b) => (a[key] as String).compareTo(b[key] as String));
  return {
    'userFoods': sorted(
      (await db.select(db.userFoods).get()).map((row) => row.toJson()),
    ),
    'userServings': sorted(
      (await db.select(db.userServings).get()).map((row) => row.toJson()),
    ),
    'diary': sorted(
      (await db.select(db.diaryEntries).get()).map((row) => row.toJson()),
    ),
    'goals': sorted(
      (await db.select(db.goalVersions).get()).map((row) => row.toJson()),
    ),
    'weights': sorted(
      (await db.select(db.weightEntries).get()).map((row) => row.toJson()),
    ),
    'remote': sorted(
      (await db.select(db.remoteFoods).get()).map((row) => row.toJson()),
    ),
    'installation': sorted(
      (await db.select(db.installationValues).get()).map((row) => row.toJson()),
      'key',
    ),
  };
}
