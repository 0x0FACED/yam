import 'dart:convert';
import 'dart:isolate';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

part 'food_library_codec.dart';

const int maxFoodLibraryFileBytes = 64 * 1024 * 1024;

const int _maxFoodLibraryFoods = 50000;
const int _maxFoodLibraryServings = 250000;

enum FoodLibraryImportMode { replace, mergeDeduplicated, mergeAll }

enum FoodLibraryFailure { invalidFile, unsupportedVersion, tooLarge }

class FoodLibraryException implements Exception {
  const FoodLibraryException(this.failure, {this.path});

  final FoodLibraryFailure failure;

  /// A JSON location, never a value or a fragment of the supplied file.
  final String? path;

  @override
  String toString() =>
      'FoodLibraryException(${failure.name}${path == null ? '' : ', $path'})';
}

final class FoodLibraryPreview {
  FoodLibraryPreview._(this._data);

  final _FoodLibraryData _data;

  int get foodCount => _data.foods.length;
  int get servingCount => _data.servingCount;
}

class FoodLibraryImportResult {
  const FoodLibraryImportResult({
    required this.imported,
    required this.skipped,
    required this.replaced,
  });

  final int imported;
  final int skipped;
  final int replaced;
}

class FoodLibraryRepository {
  FoodLibraryRepository(this._database);

  final YamDatabase _database;

  Future<Uint8List> exportLibrary() async {
    final snapshot = await _database.transaction(() async {
      final foods =
          await (_database.select(_database.userFoods)
                ..where((food) => food.deletedAt.isNull())
                ..orderBy([(food) => OrderingTerm.asc(food.rowId)]))
              .get();
      // Joining avoids an IN list large enough to exceed SQLite's bind limit.
      final servingRows =
          await (_database.select(_database.userServings).join([
                  innerJoin(
                    _database.userFoods,
                    _database.userFoods.id.equalsExp(
                          _database.userServings.foodId,
                        ) &
                        _database.userFoods.deletedAt.isNull(),
                    useColumns: false,
                  ),
                ])
                ..where(_database.userServings.deletedAt.isNull())
                ..orderBy([OrderingTerm.asc(_database.userServings.rowId)]))
              .get();
      return _FoodLibrarySnapshot(foods, [
        for (final row in servingRows) row.readTable(_database.userServings),
      ]);
    });
    return _encodeLibraryInBackground(snapshot);
  }

  Future<FoodLibraryPreview> inspectLibrary(Uint8List bytes) async {
    if (bytes.length > maxFoodLibraryFileBytes) {
      throw const FoodLibraryException(FoodLibraryFailure.tooLarge);
    }
    return FoodLibraryPreview._(await _decodeLibraryInBackground(bytes));
  }

  Future<FoodLibraryImportResult> importLibrary(
    FoodLibraryPreview preview,
    FoodLibraryImportMode mode,
  ) => _database.transaction(() async {
    final now = DateTime.now().toUtc();
    var replaced = 0;
    var skipped = 0;
    var foods = preview._data.foods;

    if (mode == FoodLibraryImportMode.mergeDeduplicated) {
      final existing = await (_database.select(
        _database.userFoods,
      )..where((food) => food.deletedAt.isNull())).get();
      final keys = {
        for (final food in existing)
          _foodKey(
            name: food.name,
            brand: food.brand,
            unit: food.basisUnit,
            basisAmount: food.basisAmount,
            kcal: food.energyKcal,
            protein: food.proteinG,
            fat: food.fatG,
            carbs: food.carbsG,
          ),
      };
      foods = [
        for (final food in foods)
          if (keys.add(food.key)) food,
      ];
      skipped = preview.foodCount - foods.length;
    }

    if (mode == FoodLibraryImportMode.replace) {
      // Only active user products and their active portions become tombstones.
      // Diary entries retain their independent historical food snapshots.
      final activeFoods = _database.selectOnly(_database.userFoods)
        ..addColumns([_database.userFoods.id])
        ..where(_database.userFoods.deletedAt.isNull());
      await (_database.update(_database.userServings)..where(
            (serving) =>
                serving.deletedAt.isNull() &
                serving.foodId.isInQuery(activeFoods),
          ))
          .write(
            UserServingsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
      replaced =
          await (_database.update(
            _database.userFoods,
          )..where((food) => food.deletedAt.isNull())).write(
            UserFoodsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    }

    if (foods.isNotEmpty) {
      const uuid = Uuid();
      final deviceId = await _database.installationDeviceId(uuid);
      await _database.batch((batch) {
        for (final food in foods) {
          final foodId = uuid.v7();
          batch.insert(
            _database.userFoods,
            UserFoodsCompanion.insert(
              id: foodId,
              name: food.name,
              category: food.category,
              brand: Value(food.brand),
              barcode: Value(food.barcode),
              description: Value(food.description),
              basisUnit: food.basis.name,
              basisAmount: food.basisAmount,
              displayBasis: food.displayBasis.name,
              energyKcal: food.kcal,
              proteinG: food.protein,
              fatG: food.fat,
              carbsG: food.carbs,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
            ),
          );
          for (final serving in food.servings) {
            batch.insert(
              _database.userServings,
              UserServingsCompanion.insert(
                id: uuid.v7(),
                foodId: foodId,
                unit: serving.unit.name,
                label: Value(serving.label),
                baseAmount: serving.baseAmount,
                defaultAmount: serving.defaultAmount,
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
              ),
            );
          }
        }
      });
    }
    return FoodLibraryImportResult(
      imported: foods.length,
      skipped: skipped,
      replaced: replaced,
    );
  });
}

typedef _FoodKey = (
  String,
  String,
  String,
  double,
  double,
  double,
  double,
  double,
);

final _dedupWhitespace = RegExp(r'\s+');

String _normalizedFoodText(String? value) =>
    (value ?? '').trim().replaceAll(_dedupWhitespace, ' ').toLowerCase();

_FoodKey _foodKey({
  required String name,
  required String? brand,
  required String unit,
  required double basisAmount,
  required double kcal,
  required double protein,
  required double fat,
  required double carbs,
}) => (
  _normalizedFoodText(name),
  _normalizedFoodText(brand),
  unit,
  basisAmount,
  kcal,
  protein,
  fat,
  carbs,
);

class _FoodLibrarySnapshot {
  const _FoodLibrarySnapshot(this.foods, this.servings);

  final List<StoredUserFood> foods;
  final List<StoredUserServing> servings;
}

class _FoodLibraryData {
  _FoodLibraryData(List<_LibraryFood> foods)
    : foods = List.unmodifiable(foods),
      servingCount = foods.fold(
        0,
        (count, food) => count + food.servings.length,
      );

  final List<_LibraryFood> foods;
  final int servingCount;
}

class _LibraryFood {
  _LibraryFood({
    required this.name,
    required this.category,
    required this.brand,
    required this.barcode,
    required this.description,
    required this.basis,
    required this.basisAmount,
    required this.displayBasis,
    required this.kcal,
    required this.protein,
    required this.fat,
    required this.carbs,
    required List<_LibraryServing> servings,
  }) : servings = List.unmodifiable(servings);

  final String name;
  final String category;
  final String? brand;
  final String? barcode;
  final String? description;
  final CustomFoodBasis basis;
  final double basisAmount;
  final CustomFoodDisplayBasis displayBasis;
  final double kcal;
  final double protein;
  final double fat;
  final double carbs;
  final List<_LibraryServing> servings;

  _FoodKey get key => _foodKey(
    name: name,
    brand: brand,
    unit: basis.name,
    basisAmount: basisAmount,
    kcal: kcal,
    protein: protein,
    fat: fat,
    carbs: carbs,
  );

  Map<String, Object?> toJson() => {
    'name': name,
    'category': category,
    'unit': basis == CustomFoodBasis.grams ? 'g' : 'ml',
    'basisAmount': basisAmount,
    'kcal': kcal,
    'protein': protein,
    'fat': fat,
    'carbs': carbs,
    if (brand != null) 'brand': brand,
    if (barcode != null) 'barcode': barcode,
    if (description != null) 'description': description,
    'displayBasis': displayBasis == CustomFoodDisplayBasis.perServing
        ? 'perServing'
        : 'per100',
    'servings': [for (final serving in servings) serving.toJson()],
  };
}

class _LibraryServing {
  const _LibraryServing({
    required this.unit,
    required this.baseAmount,
    required this.defaultAmount,
    required this.label,
  });

  final CustomServingUnit unit;
  final double baseAmount;
  final double defaultAmount;
  final String? label;

  Map<String, Object?> toJson() => {
    'unit': unit.name,
    'baseAmount': baseAmount,
    'defaultAmount': defaultAmount,
    if (label != null) 'label': label,
  };
}
