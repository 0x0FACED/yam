import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import 'package:yam/core/data/yam_database.dart';
import 'package:yam/features/diary/data/diary_repository.dart';
import 'package:yam/features/diary/domain/diary_entry.dart';
import 'package:yam/features/food_search/data/open_food_facts_client.dart';

class RemoteFoodRepository {
  RemoteFoodRepository(this.database, {Uuid? uuid})
    : _uuid = uuid ?? const Uuid();

  final YamDatabase database;
  final Uuid _uuid;

  Stream<List<StoredRemoteFood>> watchFoods() =>
      (database.select(database.remoteFoods)
            ..where((row) => row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
          .watch();

  Future<List<StoredRemoteFood>> loadFoods() =>
      (database.select(database.remoteFoods)
            ..where((row) => row.deletedAt.isNull())
            ..orderBy([(row) => OrderingTerm.desc(row.createdAt)]))
          .get();

  /// The cache and diary snapshot must either both be saved, or neither.
  Future<String> addToDiary(
    OpenFoodFactsProduct product,
    DiaryEntryDraft draft,
  ) => database.transaction(() async {
    await _upsert(product);
    await (database.update(database.remoteFoods)..where(
          (row) =>
              row.source.equals('open_food_facts') &
              row.sourceCode.equals(product.code),
        ))
        .write(RemoteFoodsCompanion(lastAmount: Value(draft.amount)));
    return DiaryRepository(database, uuid: _uuid).create(draft);
  });

  Future<void> setFavorite(OpenFoodFactsProduct product, bool favorite) =>
      database.transaction(() async {
        await _upsert(product);
        await (database.update(database.remoteFoods)..where(
              (row) =>
                  row.source.equals('open_food_facts') &
                  row.sourceCode.equals(product.code),
            ))
            .write(
              RemoteFoodsCompanion(
                isFavorite: Value(favorite),
                updatedAt: Value(DateTime.now().toUtc()),
              ),
            );
      });

  Future<void> _upsert(OpenFoodFactsProduct product) async {
    final now = DateTime.now().toUtc();
    final existing =
        await (database.select(database.remoteFoods)..where(
              (row) =>
                  row.source.equals('open_food_facts') &
                  row.sourceCode.equals(product.code),
            ))
            .getSingleOrNull();
    if (existing != null) {
      // A fresh selection updates future uses, never old diary snapshots.
      await (database.update(
        database.remoteFoods,
      )..where((row) => row.id.equals(existing.id))).write(
        RemoteFoodsCompanion(
          name: Value(product.name),
          brand: Value(product.brand),
          category: Value(product.category),
          energyKcal: Value(product.energyKcal),
          proteinG: Value(product.proteinG),
          fatG: Value(product.fatG),
          carbsG: Value(product.carbsG),
          updatedAt: Value(now),
          deletedAt: const Value(null),
        ),
      );
      return;
    }
    await database
        .into(database.remoteFoods)
        .insert(
          RemoteFoodsCompanion.insert(
            id: _uuid.v7(),
            source: 'open_food_facts',
            sourceCode: product.code,
            name: product.name,
            brand: Value(product.brand),
            category: product.category,
            basisUnit: 'grams',
            basisAmount: 100,
            energyKcal: product.energyKcal,
            proteinG: product.proteinG,
            fatG: product.fatG,
            carbsG: product.carbsG,
            createdAt: now,
            updatedAt: now,
            deviceId: await database.installationDeviceId(_uuid),
          ),
        );
  }
}
