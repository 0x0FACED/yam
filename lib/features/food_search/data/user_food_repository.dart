import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/food_search/domain/custom_food.dart';

class SavedUserFood {
  const SavedUserFood(this.food, this.servings);

  final StoredUserFood food;
  final List<StoredUserServing> servings;
}

class UserFoodRepository {
  UserFoodRepository(this.database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final YamDatabase database;
  final Uuid _uuid;

  Stream<List<SavedUserFood>> watchFoods() {
    final query =
        database.select(database.userFoods).join([
            leftOuterJoin(
              database.userServings,
              database.userServings.foodId.equalsExp(database.userFoods.id) &
                  database.userServings.deletedAt.isNull(),
            ),
          ])
          ..where(database.userFoods.deletedAt.isNull())
          ..orderBy([OrderingTerm.desc(database.userFoods.createdAt)]);

    return query.watch().map((rows) {
      final foods = <String, StoredUserFood>{};
      final servings = <String, List<StoredUserServing>>{};
      for (final row in rows) {
        final food = row.readTable(database.userFoods);
        foods[food.id] = food;
        final serving = row.readTableOrNull(database.userServings);
        if (serving != null) {
          (servings[food.id] ??= []).add(serving);
        }
      }
      return [
        for (final food in foods.values)
          SavedUserFood(food, List.unmodifiable(servings[food.id] ?? const [])),
      ];
    });
  }

  Future<List<SavedUserFood>> loadFoods() => database.transaction(() async {
    final foods =
        await (database.select(database.userFoods)
              ..where((food) => food.deletedAt.isNull())
              ..orderBy([(food) => OrderingTerm.desc(food.createdAt)]))
            .get();
    if (foods.isEmpty) return const [];

    final servings =
        await (database.select(database.userServings)..where(
              (serving) =>
                  serving.foodId.isIn([for (final food in foods) food.id]) &
                  serving.deletedAt.isNull(),
            ))
            .get();
    final servingsByFood = <String, List<StoredUserServing>>{};
    for (final serving in servings) {
      (servingsByFood[serving.foodId] ??= []).add(serving);
    }
    return [
      for (final food in foods)
        SavedUserFood(
          food,
          List.unmodifiable(servingsByFood[food.id] ?? const []),
        ),
    ];
  });

  Future<List<String>> loadBrands() async {
    final userQuery = database.selectOnly(database.userFoods)
      ..addColumns([database.userFoods.brand])
      ..where(database.userFoods.deletedAt.isNull());
    final remoteQuery = database.selectOnly(database.remoteFoods)
      ..addColumns([database.remoteFoods.brand])
      ..where(database.remoteFoods.deletedAt.isNull());
    final userRows = await userQuery.get();
    final remoteRows = await remoteQuery.get();
    final brandsByKey = <String, String>{};

    for (final brand in [
      ...userRows.map((row) => row.read(database.userFoods.brand)),
      ...remoteRows.map((row) => row.read(database.remoteFoods.brand)),
    ]) {
      final trimmed = brand?.trim();
      if (trimmed == null || trimmed.isEmpty) continue;
      final key = trimmed.toLowerCase();
      final existing = brandsByKey[key];
      if (existing == null || trimmed.compareTo(existing) < 0) {
        brandsByKey[key] = trimmed;
      }
    }

    final brands = brandsByKey.values.toList()
      ..sort((a, b) {
        final order = a.toLowerCase().compareTo(b.toLowerCase());
        return order != 0 ? order : a.compareTo(b);
      });
    return brands;
  }

  static List<String> matchingBrands(
    List<String> brands,
    String prefix, {
    int limit = 5,
  }) {
    final query = prefix.trim().toLowerCase();
    if (query.isEmpty || limit <= 0) return const [];
    return brands
        .where((brand) => brand.toLowerCase().startsWith(query))
        .take(limit)
        .toList();
  }

  Future<bool> barcodeExists(String barcode, {String? excludingFoodId}) async {
    final existing =
        await (database.select(database.userFoods)..where(
              (food) => food.barcode.equals(barcode) & food.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return existing != null && existing.id != excludingFoodId;
  }

  Future<String> create(CustomFoodDraft draft) async {
    draft.validate();
    final id = _uuid.v7();
    final now = DateTime.now().toUtc();
    await database.transaction(() async {
      final deviceId = await database.installationDeviceId(_uuid);
      await database
          .into(database.userFoods)
          .insert(
            UserFoodsCompanion.insert(
              id: id,
              name: draft.name.trim(),
              category: draft.category,
              brand: Value(
                draft.brand?.trim().isEmpty == true
                    ? null
                    : draft.brand?.trim(),
              ),
              barcode: Value(
                draft.barcode?.trim().isEmpty == true
                    ? null
                    : draft.barcode?.trim(),
              ),
              basisUnit: draft.basis.name,
              basisAmount: draft.basisAmount,
              displayBasis: draft.displayBasis.name,
              energyKcal: draft.energyKcal,
              proteinG: draft.proteinG,
              fatG: draft.fatG,
              carbsG: draft.carbsG,
              createdAt: now,
              updatedAt: now,
              deviceId: deviceId,
            ),
          );
      for (final serving in draft.servings) {
        await database
            .into(database.userServings)
            .insert(
              UserServingsCompanion.insert(
                id: _uuid.v7(),
                foodId: id,
                unit: serving.unit.name,
                label: Value(
                  serving.label?.trim().isEmpty == true
                      ? null
                      : serving.label?.trim(),
                ),
                baseAmount: serving.baseAmount,
                defaultAmount: serving.defaultAmount,
                createdAt: now,
                updatedAt: now,
                deviceId: deviceId,
              ),
            );
      }
    });
    return id;
  }

  Future<bool> update(String id, CustomFoodDraft draft) async {
    final now = DateTime.now().toUtc();

    return database.transaction(() async {
      final food =
          await (database.select(database.userFoods)
                ..where((food) => food.id.equals(id) & food.deletedAt.isNull()))
              .getSingleOrNull();
      if (food == null) return false;
      draft.validate();
      final activeServings =
          await (database.select(database.userServings)..where(
                (serving) =>
                    serving.foodId.equals(id) & serving.deletedAt.isNull(),
              ))
              .get();
      final servingsById = {
        for (final serving in activeServings) serving.id: serving,
      };
      final requestedIds = <String>{};
      for (final serving in draft.servings) {
        final existingId = serving.existingId;
        if (existingId != null && !requestedIds.add(existingId)) {
          throw ArgumentError('A serving ID cannot be used more than once');
        }
      }
      if (requestedIds.any(
        (servingId) => !servingsById.containsKey(servingId),
      )) {
        throw ArgumentError('Serving does not belong to this active food');
      }

      final hasNewServings = draft.servings.any(
        (serving) => serving.existingId == null,
      );
      final deviceId = hasNewServings
          ? await database.installationDeviceId(_uuid)
          : null;

      await (database.update(
        database.userFoods,
      )..where((food) => food.id.equals(id) & food.deletedAt.isNull())).write(
        UserFoodsCompanion(
          name: Value(draft.name.trim()),
          category: Value(draft.category),
          brand: Value(
            draft.brand?.trim().isEmpty == true ? null : draft.brand?.trim(),
          ),
          barcode: Value(
            draft.barcode?.trim().isEmpty == true
                ? null
                : draft.barcode?.trim(),
          ),
          basisUnit: Value(draft.basis.name),
          basisAmount: Value(draft.basisAmount),
          displayBasis: Value(draft.displayBasis.name),
          energyKcal: Value(draft.energyKcal),
          proteinG: Value(draft.proteinG),
          fatG: Value(draft.fatG),
          carbsG: Value(draft.carbsG),
          updatedAt: Value(now),
        ),
      );

      for (final serving in draft.servings) {
        final label = serving.label?.trim().isEmpty == true
            ? null
            : serving.label?.trim();
        final existingId = serving.existingId;
        if (existingId == null) {
          await database
              .into(database.userServings)
              .insert(
                UserServingsCompanion.insert(
                  id: _uuid.v7(),
                  foodId: id,
                  unit: serving.unit.name,
                  label: Value(label),
                  baseAmount: serving.baseAmount,
                  defaultAmount: serving.defaultAmount,
                  createdAt: now,
                  updatedAt: now,
                  deviceId: deviceId!,
                ),
              );
          continue;
        }

        final existing = servingsById[existingId]!;
        if (existing.unit != serving.unit.name ||
            existing.label != label ||
            existing.baseAmount != serving.baseAmount ||
            existing.defaultAmount != serving.defaultAmount) {
          await (database.update(database.userServings)..where(
                (row) => row.id.equals(existingId) & row.foodId.equals(id),
              ))
              .write(
                UserServingsCompanion(
                  unit: Value(serving.unit.name),
                  label: Value(label),
                  baseAmount: Value(serving.baseAmount),
                  defaultAmount: Value(serving.defaultAmount),
                  updatedAt: Value(now),
                ),
              );
        }
      }

      final removedServingIds = activeServings
          .map((serving) => serving.id)
          .where((servingId) => !requestedIds.contains(servingId))
          .toList();
      if (removedServingIds.isNotEmpty) {
        await (database.update(
          database.userServings,
        )..where((serving) => serving.id.isIn(removedServingIds))).write(
          UserServingsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
        );
      }
      return true;
    });
  }

  Future<void> setFavorite(String id, bool favorite) async {
    await (database.update(
      database.userFoods,
    )..where((food) => food.id.equals(id) & food.deletedAt.isNull())).write(
      UserFoodsCompanion(
        isFavorite: Value(favorite),
        updatedAt: Value(DateTime.now().toUtc()),
      ),
    );
  }

  Future<void> delete(String id) async {
    final now = DateTime.now().toUtc();
    await database.transaction(() async {
      final updated =
          await (database.update(database.userFoods)
                ..where((food) => food.id.equals(id) & food.deletedAt.isNull()))
              .write(
                UserFoodsCompanion(
                  deletedAt: Value(now),
                  updatedAt: Value(now),
                  barcode: const Value(null),
                ),
              );
      if (updated == 0) return;
      await (database.update(database.userServings)..where(
            (serving) => serving.foodId.equals(id) & serving.deletedAt.isNull(),
          ))
          .write(
            UserServingsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
          );
    });
  }
}
