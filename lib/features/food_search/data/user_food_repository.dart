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

  Future<List<SavedUserFood>> loadFoods() => watchFoods().first;

  Future<bool> barcodeExists(String barcode) async {
    final existing =
        await (database.select(database.userFoods)..where(
              (food) => food.barcode.equals(barcode) & food.deletedAt.isNull(),
            ))
            .getSingleOrNull();
    return existing != null;
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
