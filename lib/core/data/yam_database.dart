import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

part 'yam_database.g.dart';

@DataClassName('StoredUserFood')
@TableIndex(name: 'user_foods_history', columns: {#deletedAt, #createdAt})
@TableIndex(name: 'user_foods_name', columns: {#name})
class UserFoods extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get category => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get barcode => text().nullable().unique()();
  TextColumn get basisUnit => text()();
  RealColumn get basisAmount => real()();
  TextColumn get displayBasis => text()();
  RealColumn get energyKcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get fatG => real()();
  RealColumn get carbsG => real()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredUserServing')
@TableIndex(name: 'user_servings_food', columns: {#foodId, #deletedAt})
class UserServings extends Table {
  TextColumn get id => text()();
  TextColumn get foodId => text().references(UserFoods, #id)();
  TextColumn get unit => text()();
  TextColumn get label => text().nullable()();
  RealColumn get baseAmount => real()();
  RealColumn get defaultAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class InstallationValues extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('StoredDiaryEntry')
@TableIndex(
  name: 'diary_entries_day',
  columns: {#diaryDay, #deletedAt, #mealId},
)
@TableIndex(name: 'diary_entries_recent', columns: {#deletedAt, #createdAt})
class DiaryEntries extends Table {
  TextColumn get id => text()();
  TextColumn get diaryDay => text()();
  TextColumn get mealId => text()();
  TextColumn get foodId => text()();
  TextColumn get foodName => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get baseUnit => text()();
  RealColumn get basisAmount => real()();
  RealColumn get kcalPerBasis => real()();
  RealColumn get proteinPerBasis => real()();
  RealColumn get fatPerBasis => real()();
  RealColumn get carbsPerBasis => real()();
  TextColumn get servingsSnapshot => text()();
  TextColumn get servingId => text()();
  RealColumn get amount => real()();
  RealColumn get canonicalQuantity => real()();
  RealColumn get energyKcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get fatG => real()();
  RealColumn get carbsG => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredGoalVersion')
@TableIndex(
  name: 'goal_versions_day',
  columns: {#effectiveDay, #deletedAt, #createdAt},
)
class GoalVersions extends Table {
  TextColumn get id => text()();
  TextColumn get effectiveDay => text()();
  TextColumn get goal => text()();
  IntColumn get calorieTarget => integer()();
  IntColumn get proteinTarget => integer()();
  IntColumn get fatTarget => integer()();
  IntColumn get carbsTarget => integer()();
  RealColumn get targetWeightKg => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredWeightEntry')
@TableIndex(
  name: 'weight_entries_day',
  columns: {#localDay, #deletedAt, #createdAt},
)
class WeightEntries extends Table {
  TextColumn get id => text()();
  TextColumn get localDay => text()();
  RealColumn get weightKg => real()();
  TextColumn get source => text()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('StoredRemoteFood')
@TableIndex(name: 'remote_foods_name', columns: {#name})
@TableIndex(name: 'remote_foods_favorites', columns: {#isFavorite, #deletedAt})
class RemoteFoods extends Table {
  TextColumn get id => text()();
  TextColumn get source => text()();
  TextColumn get sourceCode => text()();
  TextColumn get name => text()();
  TextColumn get brand => text().nullable()();
  TextColumn get category => text()();
  TextColumn get basisUnit => text()();
  RealColumn get basisAmount => real()();
  RealColumn get energyKcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get fatG => real()();
  RealColumn get carbsG => real()();
  RealColumn get lastAmount => real().withDefault(const Constant(100))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  TextColumn get deviceId => text()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {source, sourceCode},
  ];
}

@DriftDatabase(
  tables: [
    UserFoods,
    UserServings,
    InstallationValues,
    DiaryEntries,
    GoalVersions,
    WeightEntries,
    RemoteFoods,
  ],
)
class YamDatabase extends _$YamDatabase {
  YamDatabase(super.executor);

  YamDatabase.open()
    : super(LazyDatabase(() async => driftDatabase(name: 'yam')));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.createTable(diaryEntries);
        await customStatement(
          'CREATE INDEX diary_entries_day ON diary_entries '
          '(diary_day, deleted_at, meal_id)',
        );
        await customStatement(
          'CREATE INDEX diary_entries_recent ON diary_entries '
          '(deleted_at, created_at)',
        );
      }
      if (from < 3) {
        await migrator.createTable(goalVersions);
        await migrator.createTable(weightEntries);
        await customStatement(
          'CREATE INDEX goal_versions_day ON goal_versions '
          '(effective_day, deleted_at, created_at)',
        );
        await customStatement(
          'CREATE INDEX weight_entries_day ON weight_entries '
          '(local_day, deleted_at, created_at)',
        );
      }
      if (from < 4) {
        await migrator.createTable(remoteFoods);
        await customStatement(
          'CREATE INDEX remote_foods_name ON remote_foods (name)',
        );
        await customStatement(
          'CREATE INDEX remote_foods_favorites ON remote_foods '
          '(is_favorite, deleted_at)',
        );
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  Future<String> installationDeviceId(Uuid uuid) async {
    const key = 'deviceId';
    final existing = await (select(
      installationValues,
    )..where((entry) => entry.key.equals(key))).getSingleOrNull();
    if (existing != null) return existing.value;

    await into(installationValues).insert(
      InstallationValuesCompanion.insert(key: key, value: uuid.v7()),
      mode: InsertMode.insertOrIgnore,
    );
    return (await (select(
      installationValues,
    )..where((entry) => entry.key.equals(key))).getSingle()).value;
  }
}
