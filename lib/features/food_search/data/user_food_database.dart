import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'user_food_database.g.dart';

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

@DriftDatabase(tables: [UserFoods, UserServings, InstallationValues])
class UserFoodDatabase extends _$UserFoodDatabase {
  UserFoodDatabase(super.executor);

  UserFoodDatabase.open()
    : super(LazyDatabase(() async => driftDatabase(name: 'yam')));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (migrator) => migrator.createAll(),
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
