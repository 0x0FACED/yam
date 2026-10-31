import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/backup/data/backup_repository.dart';
import 'package:yam/features/diary/data/diary_repository.dart';

final _created = DateTime.utc(2025, 1, 1, 12);
final _deleted = DateTime.utc(2025, 1, 2, 12);
final _updated = DateTime.utc(2025, 1, 3, 12);
String _id(int value) =>
    '019a0000-0000-7000-8000-${value.toRadixString(16).padLeft(12, '0')}';

void main() {
  YamDatabase database() {
    final db = YamDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    return db;
  }

  test(
    'replace roundtrips every persisted field, tombstone and exact snapshot',
    () async {
      final source = database();
      await _seed(source);
      final original = await _state(source);
      final bytes = await BackupRepository(source).exportBackup();
      expect(_jsonFiles(bytes)['manifest.json']['formatVersion'], 3);
      final destination = database();
      await _identity(destination, _id(901));
      await destination.into(destination.userFoods).insert(_food(100));
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(bytes);
      expect(preview.exportedAt.isUtc, isTrue);
      expect(_counts(preview.counts), [2, 2, 2, 2, 2, 2]);
      expect(preview.counts.total, 12);
      final result = await repository.importBackup(
        preview,
        BackupImportMode.replace,
      );
      expect(_counts(result.imported), [2, 2, 2, 2, 2, 2]);
      expect(result.skipped.total, 0);
      expect(await _state(destination), original);
      expect(await destination.installationDeviceId(const Uuid()), _id(901));
      expect(
        (await destination.select(destination.installationValues).get()).any(
          (row) => row.key == 'keep' && row.value == 'installation-only',
        ),
        isTrue,
      );

      final entries = await DiaryRepository(
        destination,
      ).watchDay(DateTime(2025, 1, 1)).first;
      expect(entries, hasLength(1));
      expect(entries.single.food.name, 'Historical oats');
      expect(entries.single.food.serving(_id(3)).baseAmount, 80);
      expect(entries.single.nutrition.kcal, 251.1234567890123 * 1.25);
      final catalog = await destination.select(destination.userFoods).get();
      expect(
        catalog.firstWhere((row) => row.id == _id(1)).name,
        'Edited catalog oats',
      );
      expect(
        catalog.firstWhere((row) => row.id == _id(1)).energyKcal,
        246.1234567890123,
      );
      expect(
        catalog.firstWhere((row) => row.id == _id(1)).description,
        '  1. Mix oats.\n\n2. Rest overnight.\r\n3. Serve. 🥣  ',
      );
      expect(
        catalog.firstWhere((row) => row.id == _id(2)).description,
        'Deleted recipe\nKeep this note too.',
      );
      expect(
        (await destination.select(destination.remoteFoods).get())
            .first
            .lastAmount,
        137.1234567890123,
      );
    },
  );

  test('roundtrips non-preset food categories unchanged', () async {
    final source = database();
    await _seed(source);
    await (source.update(source.userFoods)
          ..where((food) => food.deletedAt.isNull()))
        .write(const UserFoodsCompanion(category: Value('Homemade bowls')));
    await (source.update(source.userFoods)
          ..where((food) => food.deletedAt.isNotNull()))
        .write(const UserFoodsCompanion(category: Value('Seasonal dishes 🥣')));
    await source
        .update(source.remoteFoods)
        .write(
          const RemoteFoodsCompanion(
            category: Value('provider.custom/category'),
          ),
        );
    final before = await _state(source);
    final bytes = await BackupRepository(source).exportBackup();
    final destination = database();
    final repository = BackupRepository(destination);
    await repository.importBackup(
      await repository.inspectBackup(bytes),
      BackupImportMode.replace,
    );
    expect(await _state(destination), before);
    expect(await _state(source), before);
  });

  for (final mode in BackupImportMode.values) {
    test(
      'v3 ${mode.name} preserves repeated barcodes and exact numbers',
      () async {
        final source = database();
        await _seed(source);
        await _seedDuplicateBarcodes(source);
        final before = await _state(source);
        final bytes = await BackupRepository(source).exportBackup();
        expect(_jsonFiles(bytes)['manifest.json']['formatVersion'], 3);
        final destination = database();
        final repository = BackupRepository(destination);
        final preview = await repository.inspectBackup(bytes);
        expect(_counts(preview.counts), [3, 3, 2, 2, 2, 2]);
        final result = await repository.importBackup(preview, mode);
        expect(_counts(result.imported), [3, 3, 2, 2, 2, 2]);
        expect(result.skipped.total, 0);
        expect(await _state(destination), before);
        expect(await _state(source), before);
        final roundtrip = database();
        final reader = BackupRepository(roundtrip);
        await reader.importBackup(
          await reader.inspectBackup(await repository.exportBackup()),
          BackupImportMode.replace,
        );
        expect(await _state(roundtrip), before);
        final repeat = await repository.importBackup(
          preview,
          BackupImportMode.supplement,
        );
        expect(repeat.imported.total, 0);
        expect(repeat.skipped.total, 14);
      },
    );
  }

  for (final deleted in [false, true]) {
    test(
      'supplement skips every repeated incoming barcode conflicting with an existing ${deleted ? 'tombstone' : 'product'}',
      () async {
        final source = database();
        await _seed(source);
        await _seedDuplicateBarcodes(source);
        final destination = database();
        final existing = _food(100, barcode: '001', deleted: deleted);
        await destination.into(destination.userFoods).insert(existing);
        final before = await destination.select(destination.userFoods).get();
        final repository = BackupRepository(destination);
        final preview = await repository.inspectBackup(
          await BackupRepository(source).exportBackup(),
        );
        final result = await repository.importBackup(
          preview,
          BackupImportMode.supplement,
        );
        expect(_counts(result.imported), [0, 0, 2, 2, 2, 2]);
        expect(_counts(result.skipped), [3, 3, 0, 0, 0, 0]);
        expect(await destination.select(destination.userFoods).get(), before);
        expect(
          await destination.select(destination.userServings).get(),
          isEmpty,
        );
      },
    );
  }

  for (final version in [1, 2]) {
    test(
      'v$version still rejects duplicate barcodes before mutation',
      () async {
        final source = database();
        await _seed(source);
        final files = _jsonFiles(await BackupRepository(source).exportBackup());
        files['manifest.json']['formatVersion'] = version;
        _rows(files, 'user_foods.json').last['barcode'] = '001';
        final destination = database();
        await _seed(destination);
        final before = await _state(destination);
        await expectLater(
          BackupRepository(destination).inspectBackup(_pack(files)),
          throwsA(
            isA<BackupException>().having(
              (error) => error.failure,
              'failure',
              BackupFailure.invalidFile,
            ),
          ),
        );
        expect(await _state(destination), before);
      },
    );
  }

  test(
    'legacy v1 descriptions default to null without losing other fields',
    () async {
      final source = database();
      await _seed(source);
      final expected = await _state(source);
      for (final row in expected['userFoods']!) {
        row['description'] = null;
      }
      final files = _jsonFiles(await BackupRepository(source).exportBackup());
      files['manifest.json']['formatVersion'] = 1;
      for (final row in _rows(files, 'user_foods.json')) {
        row.remove('description');
      }
      final bytes = _pack(files);

      for (final mode in BackupImportMode.values) {
        final destination = database();
        final repository = BackupRepository(destination);
        final preview = await repository.inspectBackup(bytes);
        final result = await repository.importBackup(preview, mode);
        expect(result.imported.total, 12);
        expect(result.skipped.total, 0);
        expect(await _state(destination), expected, reason: mode.name);
        final exported = _jsonFiles(await repository.exportBackup());
        expect(exported['manifest.json']['formatVersion'], 3);
        expect(
          _rows(exported, 'user_foods.json').every(
            (row) =>
                row.containsKey('description') && row['description'] == null,
          ),
          isTrue,
        );
      }
    },
  );

  for (final version in [1, 2, 3]) {
    test(
      'v$version imports additional fields and reexports all known data',
      () async {
        final source = database();
        await _seed(source);
        final expected = await _state(source);
        final files = _jsonFiles(await BackupRepository(source).exportBackup());
        files['manifest.json']['formatVersion'] = version;
        files['manifest.json']['futureMetadata'] = {'optional': true};
        files['manifest.json']['counts']['futureCounter'] = 0;
        if (version == 1) {
          for (final row in _rows(files, 'user_foods.json')) {
            row.remove('description');
          }
          for (final row in expected['userFoods']!) {
            row['description'] = null;
          }
        }
        for (final file in files.entries) {
          if (file.key == 'manifest.json') continue;
          for (final row in file.value as List) {
            (row as Map<String, dynamic>)['futureOptional'] = {
              'text': 'Not understood by this version',
              'enabled': true,
            };
          }
        }
        for (final row in _rows(files, 'diary_entries.json')) {
          final servings =
              jsonDecode(row['servingsSnapshot'] as String) as List;
          for (final serving in servings) {
            (serving as Map<String, dynamic>)['futureOptional'] =
                'portion note';
          }
          row['servingsSnapshot'] = jsonEncode(servings);
          expected['diaryEntries']!.singleWhere(
            (entry) => entry['id'] == row['id'],
          )['servingsSnapshot'] = row['servingsSnapshot'];
        }

        for (final mode in BackupImportMode.values) {
          final destination = database();
          final repository = BackupRepository(destination);
          await repository.importBackup(
            await repository.inspectBackup(_pack(files)),
            mode,
          );
          expect(await _state(destination), expected, reason: mode.name);

          final roundtrip = database();
          final reader = BackupRepository(roundtrip);
          await reader.importBackup(
            await reader.inspectBackup(await repository.exportBackup()),
            BackupImportMode.replace,
          );
          expect(await _state(roundtrip), expected, reason: mode.name);
        }
      },
    );
  }

  test(
    'absent nullable fields default to null without losing required data',
    () async {
      final source = database();
      await _seed(source);
      final expected = await _state(source);
      final files = _jsonFiles(await BackupRepository(source).exportBackup());
      for (final file in files.entries) {
        if (file.key == 'manifest.json') continue;
        for (final row in (file.value as List).cast<Map<String, dynamic>>()) {
          for (final key in [
            'brand',
            'barcode',
            'description',
            'label',
            'deletedAt',
          ]) {
            if (row.containsKey(key) && row[key] == null) row.remove(key);
          }
        }
      }
      for (final row in _rows(files, 'user_foods.json')) {
        row.remove('brand');
        row.remove('barcode');
        row.remove('description');
      }
      for (final row in expected['userFoods']!) {
        row['brand'] = null;
        row['barcode'] = null;
        row['description'] = null;
      }
      for (final row in _rows(files, 'user_servings.json')) {
        row.remove('label');
      }
      for (final row in expected['userServings']!) {
        row['label'] = null;
      }
      for (final row in _rows(files, 'diary_entries.json')) {
        final servings = jsonDecode(row['servingsSnapshot'] as String) as List;
        for (final serving in servings) {
          (serving as Map<String, dynamic>).remove('label');
        }
        row['servingsSnapshot'] = jsonEncode(servings);
        expected['diaryEntries']!.singleWhere(
          (entry) => entry['id'] == row['id'],
        )['servingsSnapshot'] = row['servingsSnapshot'];
      }
      final destination = database();
      final repository = BackupRepository(destination);
      await repository.importBackup(
        await repository.inspectBackup(_pack(files)),
        BackupImportMode.replace,
      );
      expect(await _state(destination), expected);
      final diary = await DiaryRepository(
        destination,
      ).watchDay(DateTime(2025, 1, 1)).first;
      expect(diary.single.food.serving(_id(3)).label, isNull);
    },
  );

  test(
    'supplement preserves edits and tombstones, skips natural-key parents and their children',
    () async {
      final source = database();
      await _seed(source);
      final destination = database();
      await _identity(destination, _id(901));
      await destination
          .into(destination.userFoods)
          .insert(
            _food(
              1,
              name: 'Local edit',
              barcode: '111',
              description: 'Local recipe\nDo not overwrite.',
            ),
          );
      await destination
          .into(destination.userFoods)
          .insert(_food(20, barcode: '002', deleted: true));
      await destination
          .into(destination.userServings)
          .insert(_serving(3, 1, baseAmount: 42));
      await destination
          .into(destination.goalVersions)
          .insert(_goal(7, deleted: true));
      await destination
          .into(destination.weightEntries)
          .insert(_weight(9, kg: 77.777));
      await destination
          .into(destination.remoteFoods)
          .insert(_remote(22, code: '000111', deleted: true));
      final before = await _state(destination);
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(source).exportBackup(),
      );
      final result = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(_counts(result.imported), [0, 0, 2, 1, 1, 1]);
      expect(_counts(result.skipped), [2, 2, 0, 1, 1, 1]);
      final after = await _state(destination);
      for (final entry in before.entries) {
        for (final row in entry.value) {
          expect(after[entry.key], contains(equals(row)));
        }
      }
      expect(after['userFoods'], hasLength(2));
      expect(after['userServings'], hasLength(1));
      expect(
        (await DiaryRepository(
          destination,
        ).watchDay(DateTime(2025, 1, 1)).first).single.food.name,
        'Historical oats',
      );
      final repeat = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(repeat.imported.total, 0);
      expect(repeat.skipped.total, 12);
      expect(await _state(destination), after);
      expect(await destination.installationDeviceId(const Uuid()), _id(901));

      await repository.importBackup(preview, BackupImportMode.replace);
      expect(await _state(destination), await _state(source));
      expect(await destination.installationDeviceId(const Uuid()), _id(901));
    },
  );

  test(
    'supplement adds absent products with their servings and is idempotent',
    () async {
      final source = database();
      await _seed(source);
      final destination = database();
      await destination
          .into(destination.userFoods)
          .insert(_food(100, barcode: '100'));
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(source).exportBackup(),
      );
      final result = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(result.imported.total, 12);
      expect(result.skipped.total, 0);
      expect(
        await destination.select(destination.userFoods).get(),
        hasLength(3),
      );
      expect(
        await destination.select(destination.userServings).get(),
        hasLength(2),
      );
      final repeat = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(repeat.imported.total, 0);
      expect(repeat.skipped.total, 12);
    },
  );

  test(
    'a serving UUID collision skips the whole new per-serving product',
    () async {
      final source = database();
      await _identity(source, _id(900));
      await source
          .into(source.userFoods)
          .insert(
            _food(1).copyWith(displayBasis: 'perServing', basisAmount: 80),
          );
      await source
          .into(source.userServings)
          .insert(_serving(3, 1, baseAmount: 80));
      await source
          .into(source.userServings)
          .insert(_serving(4, 1, baseAmount: 40));
      final destination = database();
      await _identity(destination, _id(901));
      await destination
          .into(destination.userFoods)
          .insert(_food(100, deleted: true));
      await destination
          .into(destination.userServings)
          .insert(_serving(3, 100, baseAmount: 33, deleted: true));
      final before = await _state(destination);
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(source).exportBackup(),
      );
      final result = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(result.imported.total, 0);
      expect(_counts(result.skipped), [1, 2, 0, 0, 0, 0]);
      expect(await _state(destination), before);
      final exported = await repository.inspectBackup(
        await repository.exportBackup(),
      );
      expect(_counts(exported.counts), [1, 1, 0, 0, 0, 0]);
    },
  );

  test(
    'preview retains validated immutable state independently of caller bytes',
    () async {
      final source = database();
      await _seed(source);
      final bytes = await BackupRepository(source).exportBackup();
      final destination = database();
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(bytes);
      bytes.fillRange(0, bytes.length, 0);
      await repository.importBackup(preview, BackupImportMode.replace);
      expect(await _state(destination), await _state(source));
    },
  );

  test(
    'clock rollback timestamps roundtrip without imposing chronological order',
    () async {
      final source = database();
      await _seed(source);
      final rolledBack = DateTime.utc(2024, 1, 1, 12);
      final olderDeletion = DateTime.utc(2023, 1, 1, 12);
      for (final table in [
        'user_foods',
        'user_servings',
        'diary_entries',
        'goal_versions',
        'weight_entries',
        'remote_foods',
      ]) {
        await source.customStatement('UPDATE $table SET updated_at = ?', [
          rolledBack.millisecondsSinceEpoch ~/ 1000,
        ]);
      }
      await (source.update(source.userFoods)
            ..where((row) => row.id.equals(_id(2))))
          .write(UserFoodsCompanion(deletedAt: Value(olderDeletion)));
      final original = await _state(source);
      expect(
        original['userFoods']!.first['updatedAt'],
        rolledBack.millisecondsSinceEpoch,
      );
      expect(
        original['userFoods']!.last['deletedAt'],
        olderDeletion.millisecondsSinceEpoch,
      );
      final destination = database();
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(source).exportBackup(),
      );
      await repository.importBackup(preview, BackupImportMode.replace);
      expect(await _state(destination), original);
    },
  );

  test(
    'empty replace clears all entities but never installation values',
    () async {
      final empty = database();
      final destination = database();
      await _seed(destination);
      final identity = await destination.installationDeviceId(const Uuid());
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(empty).exportBackup(),
      );
      expect(preview.counts.total, 0);
      final noChange = await repository.importBackup(
        preview,
        BackupImportMode.supplement,
      );
      expect(noChange.imported.total, 0);
      expect((await _state(destination))['goals'], hasLength(2));
      await repository.importBackup(preview, BackupImportMode.replace);
      expect(
        (await _state(destination)).values.every((rows) => rows.isEmpty),
        isTrue,
      );
      expect(await destination.installationDeviceId(const Uuid()), identity);
    },
  );

  test(
    'replace rolls back deletions and earlier inserts when SQLite rejects a later row',
    () async {
      final source = database();
      await _seed(source);
      final destination = database();
      await _seed(destination);
      await destination.into(destination.userFoods).insert(_food(100));
      final before = await _state(destination);
      final repository = BackupRepository(destination);
      final preview = await repository.inspectBackup(
        await BackupRepository(source).exportBackup(),
      );
      await destination.customStatement(
        "CREATE TRIGGER fail_backup_weight BEFORE INSERT ON weight_entries "
        "BEGIN SELECT RAISE(ABORT, 'forced import failure'); END",
      );
      await expectLater(
        repository.importBackup(preview, BackupImportMode.replace),
        throwsA(anything),
      );
      expect(await _state(destination), before);
      expect(await destination.installationDeviceId(const Uuid()), _id(900));
    },
  );

  test(
    'invalid, future, corrupt and inconsistent archives never mutate SQLite',
    () async {
      final source = database();
      await _seed(source);
      final bytes = await BackupRepository(source).exportBackup();
      final destination = database();
      await _seed(destination);
      final before = await _state(destination);
      final repository = BackupRepository(destination);
      final mutations = <String, void Function(Map<String, dynamic>)>{
        'missing serving parent': (files) =>
            _rows(files, 'user_servings.json').first['foodId'] = _id(999),
        'duplicate entity ID': (files) =>
            _rows(files, 'weight_entries.json').last['id'] = _id(9),
        'invalid barcode': (files) =>
            _rows(files, 'user_foods.json').last['barcode'] = '12x34',
        'duplicate provider key': (files) =>
            _rows(files, 'remote_foods.json').last['sourceCode'] = '000111',
        'negative nutrition': (files) =>
            _rows(files, 'user_foods.json').first['energyKcal'] = -1,
        'wrong numeric type': (files) =>
            _rows(files, 'weight_entries.json').first['weightKg'] = '68',
        'non-string description': (files) =>
            _rows(files, 'user_foods.json').first['description'] = 123,
        'non-string brand': (files) =>
            _rows(files, 'user_foods.json').first['brand'] = false,
        'invalid optional timestamp': (files) =>
            _rows(files, 'weight_entries.json').first['deletedAt'] = 123,
        'zero quantity': (files) =>
            _rows(files, 'diary_entries.json').first['amount'] = 0,
        'empty category': (files) =>
            _rows(files, 'user_foods.json').first['category'] = '',
        'unknown serving unit': (files) =>
            _rows(files, 'user_servings.json').first['unit'] = 'unknown',
        'unknown base unit': (files) =>
            _rows(files, 'remote_foods.json').first['basisUnit'] = 'ounces',
        'unknown provider': (files) =>
            _rows(files, 'remote_foods.json').first['source'] = 'unknown',
        'unknown meal': (files) =>
            _rows(files, 'diary_entries.json').first['mealId'] = 'unknown',
        'unknown goal': (files) =>
            _rows(files, 'goal_versions.json').first['goal'] = 'unknown',
        'unknown weight source': (files) =>
            _rows(files, 'weight_entries.json').first['source'] = 'unknown',
        'bad UUID': (files) =>
            _rows(files, 'weight_entries.json').first['id'] = 'not-a-uuid',
        'rollover date': (files) =>
            _rows(files, 'diary_entries.json').first['diaryDay'] = '2025-02-30',
        'non-UTC metadata': (files) =>
            _rows(files, 'weight_entries.json').first['updatedAt'] =
                '2025-01-03T12:00:00.000',
        'missing selected snapshot serving': (files) =>
            _rows(files, 'diary_entries.json').first['servingId'] = 'absent',
        'duplicate snapshot serving': (files) {
          final row = _rows(files, 'diary_entries.json').first;
          final servings =
              jsonDecode(row['servingsSnapshot'] as String) as List;
          servings.add(servings.first);
          row['servingsSnapshot'] = jsonEncode(servings);
        },
        'incoherent snapshot base unit': (files) {
          final row = _rows(files, 'diary_entries.json').first;
          final servings =
              jsonDecode(row['servingsSnapshot'] as String) as List;
          (servings.first as Map)['unit'] = 'milliliters';
          row['servingsSnapshot'] = jsonEncode(servings);
        },
        'incoherent quantity': (files) =>
            _rows(files, 'diary_entries.json').first['canonicalQuantity'] = 101,
        'incoherent nutrition': (files) =>
            _rows(files, 'diary_entries.json').first['energyKcal'] = 999,
        'invalid display basis': (files) =>
            _rows(files, 'user_foods.json').first['basisAmount'] = 80,
        'missing field': (files) =>
            _rows(files, 'weight_entries.json').first.remove('weightKg'),
        'missing food name': (files) =>
            _rows(files, 'user_foods.json').first.remove('name'),
        'missing nutrition': (files) =>
            _rows(files, 'user_foods.json').first.remove('energyKcal'),
        'missing favorite state': (files) =>
            _rows(files, 'user_foods.json').first.remove('isFavorite'),
        'missing serving unit': (files) =>
            _rows(files, 'user_servings.json').first.remove('unit'),
        'missing creation metadata': (files) =>
            _rows(files, 'weight_entries.json').first.remove('createdAt'),
        'missing diary snapshot': (files) =>
            _rows(files, 'diary_entries.json').first.remove('servingsSnapshot'),
        'missing goal target': (files) =>
            _rows(files, 'goal_versions.json').first.remove('calorieTarget'),
        'missing manifest version': (files) =>
            (files['manifest.json'] as Map).remove('formatVersion'),
        'missing table count': (files) =>
            (files['manifest.json']['counts'] as Map).remove('weights'),
        'mismatched counts': (files) =>
            (files['manifest.json']['counts'] as Map)['weights'] = 200,
        'missing member': (files) => files.remove('weight_entries.json'),
        'path member': (files) =>
            files['../manifest.json'] = files.remove('manifest.json'),
      };
      for (final mutation in mutations.entries) {
        final files = _jsonFiles(bytes);
        mutation.value(files);
        await expectLater(
          repository.inspectBackup(_pack(files)),
          throwsA(
            isA<BackupException>().having(
              (error) => error.failure,
              'failure',
              BackupFailure.invalidFile,
            ),
          ),
          reason: mutation.key,
        );
        expect(await _state(destination), before, reason: mutation.key);
      }
      final nonfinite = _jsonFiles(bytes);
      _rows(nonfinite, 'user_foods.json').first['energyKcal'] = 123456789;
      final rawFoodJson = jsonEncode(
        nonfinite['user_foods.json'],
      ).replaceFirst('"energyKcal":123456789', '"energyKcal":1e400');
      await expectLater(
        repository.inspectBackup(
          _pack(nonfinite, rawJson: {'user_foods.json': rawFoodJson}),
        ),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.invalidFile,
          ),
        ),
      );
      final future = _jsonFiles(bytes);
      future['manifest.json']['formatVersion'] = 4;
      await expectLater(
        repository.inspectBackup(_pack(future)),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.unsupportedVersion,
          ),
        ),
      );
      await expectLater(
        repository.inspectBackup(Uint8List.fromList([1, 2, 3])),
        throwsA(isA<BackupException>()),
      );
      final corrupt = _pack(_jsonFiles(bytes), compress: false);
      final view = ByteData.sublistView(corrupt);
      final firstDataOffset =
          30 +
          view.getUint16(26, Endian.little) +
          view.getUint16(28, Endian.little);
      corrupt[firstDataOffset] ^= 1;
      await expectLater(
        repository.inspectBackup(corrupt),
        throwsA(isA<BackupException>()),
      );
      expect(await _state(destination), before);
    },
  );

  test(
    'bounded envelopes reject oversized declarations and lying inflate sizes',
    () async {
      final source = database();
      await _seed(source);
      final bytes = await BackupRepository(source).exportBackup();
      final repository = BackupRepository(database());
      final oversized = Uint8List.fromList(bytes);
      _setFirstSize(oversized, 128 * 1024 * 1024 + 1);
      await expectLater(
        repository.inspectBackup(oversized),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.tooLarge,
          ),
        ),
      );
      final lying = Uint8List.fromList(bytes);
      _setFirstSize(lying, 1);
      await expectLater(
        repository.inspectBackup(lying),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.invalidFile,
          ),
        ),
      );
      await expectLater(
        repository.inspectBackup(Uint8List(maxBackupFileBytes + 1)),
        throwsA(
          isA<BackupException>().having(
            (error) => error.failure,
            'failure',
            BackupFailure.tooLarge,
          ),
        ),
      );
    },
  );
}

List<int> _counts(BackupCounts value) => [
  value.userFoods,
  value.userServings,
  value.diaryEntries,
  value.goals,
  value.weights,
  value.remoteFoods,
];

Future<void> _identity(YamDatabase database, String deviceId) async {
  await database
      .into(database.installationValues)
      .insert(
        InstallationValuesCompanion.insert(key: 'deviceId', value: deviceId),
      );
  await database
      .into(database.installationValues)
      .insert(
        InstallationValuesCompanion.insert(
          key: 'keep',
          value: 'installation-only',
        ),
      );
}

StoredUserFood _food(
  int id, {
  String name = 'Edited catalog oats',
  String? barcode,
  String? description,
  bool deleted = false,
}) => StoredUserFood(
  id: _id(id),
  name: name,
  category: 'grains',
  brand: 'Brand',
  barcode: barcode,
  description: description,
  basisUnit: 'grams',
  basisAmount: 100,
  displayBasis: 'perHundredGrams',
  energyKcal: 246.1234567890123,
  proteinG: 9.1234567890123,
  fatG: 3.333333333333333,
  carbsG: 42.9876543210987,
  isFavorite: true,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(900),
);

StoredUserServing _serving(
  int id,
  int foodId, {
  double baseAmount = 63.125,
  bool deleted = false,
}) => StoredUserServing(
  id: _id(id),
  foodId: _id(foodId),
  unit: 'serving',
  label: 'Bowl · миска',
  baseAmount: baseAmount,
  defaultAmount: 1.375,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(900),
);

StoredGoalVersion _goal(int id, {bool deleted = false}) => StoredGoalVersion(
  id: _id(id),
  effectiveDay: '2025-01-01',
  goal: 'maintain',
  calorieTarget: 2137,
  proteinTarget: 101,
  fatTarget: 73,
  carbsTarget: 265,
  targetWeightKg: 67.1234567890123,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(900),
);

StoredWeightEntry _weight(
  int id, {
  double kg = 68.1234567890123,
  bool deleted = false,
}) => StoredWeightEntry(
  id: _id(id),
  localDay: '2025-01-01',
  weightKg: kg,
  source: 'manual',
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(900),
);

StoredRemoteFood _remote(
  int id, {
  required String code,
  bool deleted = false,
}) => StoredRemoteFood(
  id: _id(id),
  source: 'open_food_facts',
  sourceCode: code,
  name: 'Remote milk',
  brand: null,
  category: 'dairy',
  basisUnit: 'grams',
  basisAmount: 100,
  energyKcal: 47.1234567890123,
  proteinG: 3.333333333333333,
  fatG: 1.111111111111111,
  carbsG: 4.444444444444444,
  lastAmount: 137.1234567890123,
  isFavorite: true,
  createdAt: _created,
  updatedAt: _updated,
  deletedAt: deleted ? _deleted : null,
  deviceId: _id(900),
);

Future<void> _seed(YamDatabase database) async {
  await _identity(database, _id(900));
  final diary = StoredDiaryEntry(
    id: _id(5),
    diaryDay: '2025-01-01',
    mealId: 'breakfast',
    foodId: _id(1),
    foodName: 'Historical oats',
    brand: 'Old brand',
    baseUnit: 'grams',
    basisAmount: 80,
    kcalPerBasis: 251.1234567890123,
    proteinPerBasis: 10.1234567890123,
    fatPerBasis: 4.9876543210987,
    carbsPerBasis: 37.1234567890123,
    servingsSnapshot:
        '[ {"id":"grams","unit":"grams","label":null,"baseAmount":1.0}, '
        '{"id":"${_id(3)}","unit":"servings","label":"Old bowl · миска","baseAmount":80.0} ]',
    servingId: _id(3),
    amount: 1.25,
    canonicalQuantity: 100,
    energyKcal: 251.1234567890123 * 1.25,
    proteinG: 10.1234567890123 * 1.25,
    fatG: 4.9876543210987 * 1.25,
    carbsG: 37.1234567890123 * 1.25,
    createdAt: _created,
    updatedAt: _updated,
    deletedAt: null,
    deviceId: _id(900),
  );
  await database.batch((batch) {
    batch.insertAll(database.userFoods, [
      _food(
        1,
        barcode: '001',
        description: '  1. Mix oats.\n\n2. Rest overnight.\r\n3. Serve. 🥣  ',
      ),
      _food(
        2,
        barcode: '002',
        deleted: true,
        description: 'Deleted recipe\nKeep this note too.',
      ),
    ]);
    batch.insertAll(database.userServings, [
      _serving(3, 1),
      _serving(4, 2, deleted: true),
    ]);
    batch.insertAll(database.diaryEntries, [
      diary,
      diary.copyWith(
        id: _id(6),
        deletedAt: Value(_deleted),
        foodId: 'off:000111',
      ),
    ]);
    batch.insertAll(database.goalVersions, [_goal(7), _goal(8, deleted: true)]);
    batch.insertAll(database.weightEntries, [
      _weight(9),
      _weight(10, deleted: true),
    ]);
    batch.insertAll(database.remoteFoods, [
      _remote(11, code: '000111'),
      _remote(12, code: '000222', deleted: true),
    ]);
  });
}

Future<void> _seedDuplicateBarcodes(YamDatabase database) async {
  await (database.update(database.userFoods)
        ..where((food) => food.id.equals(_id(2))))
      .write(const UserFoodsCompanion(barcode: Value('001')));
  await database
      .into(database.userFoods)
      .insert(
        _food(
          13,
          barcode: '001',
          description: '  Duplicate barcode, distinct product.  ',
        ).copyWith(displayBasis: 'perServing', basisAmount: 63.1234567890123),
      );
  await database
      .into(database.userServings)
      .insert(_serving(14, 13, baseAmount: 63.1234567890123));
}

Future<Map<String, List<Map<String, dynamic>>>> _state(
  YamDatabase database,
) async {
  List<Map<String, dynamic>> sorted(Iterable<Map<String, dynamic>> values) =>
      values.toList()
        ..sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
  return {
    'userFoods': sorted(
      (await database.select(database.userFoods).get()).map(
        (row) => row.toJson(),
      ),
    ),
    'userServings': sorted(
      (await database.select(database.userServings).get()).map(
        (row) => row.toJson(),
      ),
    ),
    'diaryEntries': sorted(
      (await database.select(database.diaryEntries).get()).map(
        (row) => row.toJson(),
      ),
    ),
    'goals': sorted(
      (await database.select(database.goalVersions).get()).map(
        (row) => row.toJson(),
      ),
    ),
    'weights': sorted(
      (await database.select(database.weightEntries).get()).map(
        (row) => row.toJson(),
      ),
    ),
    'remoteFoods': sorted(
      (await database.select(database.remoteFoods).get()).map(
        (row) => row.toJson(),
      ),
    ),
  };
}

Map<String, dynamic> _jsonFiles(Uint8List bytes) => {
  for (final file in ZipDecoder().decodeBytes(bytes))
    file.name: jsonDecode(utf8.decode(file.readBytes()!)),
};

List<Map<String, dynamic>> _rows(Map<String, dynamic> files, String name) =>
    (files[name] as List).cast<Map<String, dynamic>>();

Uint8List _pack(
  Map<String, dynamic> files, {
  bool compress = true,
  Map<String, String> rawJson = const {},
}) {
  final archive = Archive();
  for (final entry in files.entries) {
    final file = ArchiveFile.bytes(
      entry.key,
      utf8.encode(rawJson[entry.key] ?? jsonEncode(entry.value)),
    );
    if (!compress) file.compression = CompressionType.none;
    archive.add(file);
  }
  return ZipEncoder().encodeBytes(archive);
}

void _setFirstSize(Uint8List bytes, int size) {
  final data = ByteData.sublistView(bytes);
  final centralOffset = data.getUint32(bytes.length - 22 + 16, Endian.little);
  final localOffset = data.getUint32(centralOffset + 42, Endian.little);
  data.setUint32(centralOffset + 24, size, Endian.little);
  data.setUint32(localOffset + 22, size, Endian.little);
}
