// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_food_database.dart';

// ignore_for_file: type=lint
class $UserFoodsTable extends UserFoods
    with TableInfo<$UserFoodsTable, StoredUserFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _barcodeMeta = const VerificationMeta(
    'barcode',
  );
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
    'barcode',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _basisUnitMeta = const VerificationMeta(
    'basisUnit',
  );
  @override
  late final GeneratedColumn<String> basisUnit = GeneratedColumn<String>(
    'basis_unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _basisAmountMeta = const VerificationMeta(
    'basisAmount',
  );
  @override
  late final GeneratedColumn<double> basisAmount = GeneratedColumn<double>(
    'basis_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _displayBasisMeta = const VerificationMeta(
    'displayBasis',
  );
  @override
  late final GeneratedColumn<String> displayBasis = GeneratedColumn<String>(
    'display_basis',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _energyKcalMeta = const VerificationMeta(
    'energyKcal',
  );
  @override
  late final GeneratedColumn<double> energyKcal = GeneratedColumn<double>(
    'energy_kcal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<double> proteinG = GeneratedColumn<double>(
    'protein_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatGMeta = const VerificationMeta('fatG');
  @override
  late final GeneratedColumn<double> fatG = GeneratedColumn<double>(
    'fat_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsGMeta = const VerificationMeta('carbsG');
  @override
  late final GeneratedColumn<double> carbsG = GeneratedColumn<double>(
    'carbs_g',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    brand,
    barcode,
    basisUnit,
    basisAmount,
    displayBasis,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    isFavorite,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredUserFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('barcode')) {
      context.handle(
        _barcodeMeta,
        barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta),
      );
    }
    if (data.containsKey('basis_unit')) {
      context.handle(
        _basisUnitMeta,
        basisUnit.isAcceptableOrUnknown(data['basis_unit']!, _basisUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_basisUnitMeta);
    }
    if (data.containsKey('basis_amount')) {
      context.handle(
        _basisAmountMeta,
        basisAmount.isAcceptableOrUnknown(
          data['basis_amount']!,
          _basisAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_basisAmountMeta);
    }
    if (data.containsKey('display_basis')) {
      context.handle(
        _displayBasisMeta,
        displayBasis.isAcceptableOrUnknown(
          data['display_basis']!,
          _displayBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayBasisMeta);
    }
    if (data.containsKey('energy_kcal')) {
      context.handle(
        _energyKcalMeta,
        energyKcal.isAcceptableOrUnknown(data['energy_kcal']!, _energyKcalMeta),
      );
    } else if (isInserting) {
      context.missing(_energyKcalMeta);
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    } else if (isInserting) {
      context.missing(_proteinGMeta);
    }
    if (data.containsKey('fat_g')) {
      context.handle(
        _fatGMeta,
        fatG.isAcceptableOrUnknown(data['fat_g']!, _fatGMeta),
      );
    } else if (isInserting) {
      context.missing(_fatGMeta);
    }
    if (data.containsKey('carbs_g')) {
      context.handle(
        _carbsGMeta,
        carbsG.isAcceptableOrUnknown(data['carbs_g']!, _carbsGMeta),
      );
    } else if (isInserting) {
      context.missing(_carbsGMeta);
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredUserFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredUserFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      barcode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}barcode'],
      ),
      basisUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis_unit'],
      )!,
      basisAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basis_amount'],
      )!,
      displayBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_basis'],
      )!,
      energyKcal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_kcal'],
      )!,
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_g'],
      )!,
      fatG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_g'],
      )!,
      carbsG: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_g'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $UserFoodsTable createAlias(String alias) {
    return $UserFoodsTable(attachedDatabase, alias);
  }
}

class StoredUserFood extends DataClass implements Insertable<StoredUserFood> {
  final String id;
  final String name;
  final String category;
  final String? brand;
  final String? barcode;
  final String basisUnit;
  final double basisAmount;
  final String displayBasis;
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredUserFood({
    required this.id,
    required this.name,
    required this.category,
    this.brand,
    this.barcode,
    required this.basisUnit,
    required this.basisAmount,
    required this.displayBasis,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    if (!nullToAbsent || barcode != null) {
      map['barcode'] = Variable<String>(barcode);
    }
    map['basis_unit'] = Variable<String>(basisUnit);
    map['basis_amount'] = Variable<double>(basisAmount);
    map['display_basis'] = Variable<String>(displayBasis);
    map['energy_kcal'] = Variable<double>(energyKcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['fat_g'] = Variable<double>(fatG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  UserFoodsCompanion toCompanion(bool nullToAbsent) {
    return UserFoodsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      barcode: barcode == null && nullToAbsent
          ? const Value.absent()
          : Value(barcode),
      basisUnit: Value(basisUnit),
      basisAmount: Value(basisAmount),
      displayBasis: Value(displayBasis),
      energyKcal: Value(energyKcal),
      proteinG: Value(proteinG),
      fatG: Value(fatG),
      carbsG: Value(carbsG),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredUserFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredUserFood(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      brand: serializer.fromJson<String?>(json['brand']),
      barcode: serializer.fromJson<String?>(json['barcode']),
      basisUnit: serializer.fromJson<String>(json['basisUnit']),
      basisAmount: serializer.fromJson<double>(json['basisAmount']),
      displayBasis: serializer.fromJson<String>(json['displayBasis']),
      energyKcal: serializer.fromJson<double>(json['energyKcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'brand': serializer.toJson<String?>(brand),
      'barcode': serializer.toJson<String?>(barcode),
      'basisUnit': serializer.toJson<String>(basisUnit),
      'basisAmount': serializer.toJson<double>(basisAmount),
      'displayBasis': serializer.toJson<String>(displayBasis),
      'energyKcal': serializer.toJson<double>(energyKcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'fatG': serializer.toJson<double>(fatG),
      'carbsG': serializer.toJson<double>(carbsG),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredUserFood copyWith({
    String? id,
    String? name,
    String? category,
    Value<String?> brand = const Value.absent(),
    Value<String?> barcode = const Value.absent(),
    String? basisUnit,
    double? basisAmount,
    String? displayBasis,
    double? energyKcal,
    double? proteinG,
    double? fatG,
    double? carbsG,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredUserFood(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    brand: brand.present ? brand.value : this.brand,
    barcode: barcode.present ? barcode.value : this.barcode,
    basisUnit: basisUnit ?? this.basisUnit,
    basisAmount: basisAmount ?? this.basisAmount,
    displayBasis: displayBasis ?? this.displayBasis,
    energyKcal: energyKcal ?? this.energyKcal,
    proteinG: proteinG ?? this.proteinG,
    fatG: fatG ?? this.fatG,
    carbsG: carbsG ?? this.carbsG,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredUserFood copyWithCompanion(UserFoodsCompanion data) {
    return StoredUserFood(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      brand: data.brand.present ? data.brand.value : this.brand,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      basisUnit: data.basisUnit.present ? data.basisUnit.value : this.basisUnit,
      basisAmount: data.basisAmount.present
          ? data.basisAmount.value
          : this.basisAmount,
      displayBasis: data.displayBasis.present
          ? data.displayBasis.value
          : this.displayBasis,
      energyKcal: data.energyKcal.present
          ? data.energyKcal.value
          : this.energyKcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredUserFood(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('basisUnit: $basisUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('displayBasis: $displayBasis, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    brand,
    barcode,
    basisUnit,
    basisAmount,
    displayBasis,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    isFavorite,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredUserFood &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.brand == this.brand &&
          other.barcode == this.barcode &&
          other.basisUnit == this.basisUnit &&
          other.basisAmount == this.basisAmount &&
          other.displayBasis == this.displayBasis &&
          other.energyKcal == this.energyKcal &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class UserFoodsCompanion extends UpdateCompanion<StoredUserFood> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String?> brand;
  final Value<String?> barcode;
  final Value<String> basisUnit;
  final Value<double> basisAmount;
  final Value<String> displayBasis;
  final Value<double> energyKcal;
  final Value<double> proteinG;
  final Value<double> fatG;
  final Value<double> carbsG;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const UserFoodsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    this.basisUnit = const Value.absent(),
    this.basisAmount = const Value.absent(),
    this.displayBasis = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserFoodsCompanion.insert({
    required String id,
    required String name,
    required String category,
    this.brand = const Value.absent(),
    this.barcode = const Value.absent(),
    required String basisUnit,
    required double basisAmount,
    required String displayBasis,
    required double energyKcal,
    required double proteinG,
    required double fatG,
    required double carbsG,
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       basisUnit = Value(basisUnit),
       basisAmount = Value(basisAmount),
       displayBasis = Value(displayBasis),
       energyKcal = Value(energyKcal),
       proteinG = Value(proteinG),
       fatG = Value(fatG),
       carbsG = Value(carbsG),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredUserFood> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? brand,
    Expression<String>? barcode,
    Expression<String>? basisUnit,
    Expression<double>? basisAmount,
    Expression<String>? displayBasis,
    Expression<double>? energyKcal,
    Expression<double>? proteinG,
    Expression<double>? fatG,
    Expression<double>? carbsG,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (brand != null) 'brand': brand,
      if (barcode != null) 'barcode': barcode,
      if (basisUnit != null) 'basis_unit': basisUnit,
      if (basisAmount != null) 'basis_amount': basisAmount,
      if (displayBasis != null) 'display_basis': displayBasis,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserFoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String?>? brand,
    Value<String?>? barcode,
    Value<String>? basisUnit,
    Value<double>? basisAmount,
    Value<String>? displayBasis,
    Value<double>? energyKcal,
    Value<double>? proteinG,
    Value<double>? fatG,
    Value<double>? carbsG,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return UserFoodsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      brand: brand ?? this.brand,
      barcode: barcode ?? this.barcode,
      basisUnit: basisUnit ?? this.basisUnit,
      basisAmount: basisAmount ?? this.basisAmount,
      displayBasis: displayBasis ?? this.displayBasis,
      energyKcal: energyKcal ?? this.energyKcal,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (basisUnit.present) {
      map['basis_unit'] = Variable<String>(basisUnit.value);
    }
    if (basisAmount.present) {
      map['basis_amount'] = Variable<double>(basisAmount.value);
    }
    if (displayBasis.present) {
      map['display_basis'] = Variable<String>(displayBasis.value);
    }
    if (energyKcal.present) {
      map['energy_kcal'] = Variable<double>(energyKcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<double>(proteinG.value);
    }
    if (fatG.present) {
      map['fat_g'] = Variable<double>(fatG.value);
    }
    if (carbsG.present) {
      map['carbs_g'] = Variable<double>(carbsG.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserFoodsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('brand: $brand, ')
          ..write('barcode: $barcode, ')
          ..write('basisUnit: $basisUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('displayBasis: $displayBasis, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserServingsTable extends UserServings
    with TableInfo<$UserServingsTable, StoredUserServing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserServingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _foodIdMeta = const VerificationMeta('foodId');
  @override
  late final GeneratedColumn<String> foodId = GeneratedColumn<String>(
    'food_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_foods (id)',
    ),
  );
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
    'unit',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _baseAmountMeta = const VerificationMeta(
    'baseAmount',
  );
  @override
  late final GeneratedColumn<double> baseAmount = GeneratedColumn<double>(
    'base_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultAmountMeta = const VerificationMeta(
    'defaultAmount',
  );
  @override
  late final GeneratedColumn<double> defaultAmount = GeneratedColumn<double>(
    'default_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    foodId,
    unit,
    label,
    baseAmount,
    defaultAmount,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_servings';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredUserServing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('unit')) {
      context.handle(
        _unitMeta,
        unit.isAcceptableOrUnknown(data['unit']!, _unitMeta),
      );
    } else if (isInserting) {
      context.missing(_unitMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    }
    if (data.containsKey('base_amount')) {
      context.handle(
        _baseAmountMeta,
        baseAmount.isAcceptableOrUnknown(data['base_amount']!, _baseAmountMeta),
      );
    } else if (isInserting) {
      context.missing(_baseAmountMeta);
    }
    if (data.containsKey('default_amount')) {
      context.handle(
        _defaultAmountMeta,
        defaultAmount.isAcceptableOrUnknown(
          data['default_amount']!,
          _defaultAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultAmountMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StoredUserServing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredUserServing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      unit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unit'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      ),
      baseAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}base_amount'],
      )!,
      defaultAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_amount'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
    );
  }

  @override
  $UserServingsTable createAlias(String alias) {
    return $UserServingsTable(attachedDatabase, alias);
  }
}

class StoredUserServing extends DataClass
    implements Insertable<StoredUserServing> {
  final String id;
  final String foodId;
  final String unit;
  final String? label;
  final double baseAmount;
  final double defaultAmount;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredUserServing({
    required this.id,
    required this.foodId,
    required this.unit,
    this.label,
    required this.baseAmount,
    required this.defaultAmount,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['food_id'] = Variable<String>(foodId);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || label != null) {
      map['label'] = Variable<String>(label);
    }
    map['base_amount'] = Variable<double>(baseAmount);
    map['default_amount'] = Variable<double>(defaultAmount);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  UserServingsCompanion toCompanion(bool nullToAbsent) {
    return UserServingsCompanion(
      id: Value(id),
      foodId: Value(foodId),
      unit: Value(unit),
      label: label == null && nullToAbsent
          ? const Value.absent()
          : Value(label),
      baseAmount: Value(baseAmount),
      defaultAmount: Value(defaultAmount),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredUserServing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredUserServing(
      id: serializer.fromJson<String>(json['id']),
      foodId: serializer.fromJson<String>(json['foodId']),
      unit: serializer.fromJson<String>(json['unit']),
      label: serializer.fromJson<String?>(json['label']),
      baseAmount: serializer.fromJson<double>(json['baseAmount']),
      defaultAmount: serializer.fromJson<double>(json['defaultAmount']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'foodId': serializer.toJson<String>(foodId),
      'unit': serializer.toJson<String>(unit),
      'label': serializer.toJson<String?>(label),
      'baseAmount': serializer.toJson<double>(baseAmount),
      'defaultAmount': serializer.toJson<double>(defaultAmount),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredUserServing copyWith({
    String? id,
    String? foodId,
    String? unit,
    Value<String?> label = const Value.absent(),
    double? baseAmount,
    double? defaultAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredUserServing(
    id: id ?? this.id,
    foodId: foodId ?? this.foodId,
    unit: unit ?? this.unit,
    label: label.present ? label.value : this.label,
    baseAmount: baseAmount ?? this.baseAmount,
    defaultAmount: defaultAmount ?? this.defaultAmount,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredUserServing copyWithCompanion(UserServingsCompanion data) {
    return StoredUserServing(
      id: data.id.present ? data.id.value : this.id,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      unit: data.unit.present ? data.unit.value : this.unit,
      label: data.label.present ? data.label.value : this.label,
      baseAmount: data.baseAmount.present
          ? data.baseAmount.value
          : this.baseAmount,
      defaultAmount: data.defaultAmount.present
          ? data.defaultAmount.value
          : this.defaultAmount,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredUserServing(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('unit: $unit, ')
          ..write('label: $label, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('defaultAmount: $defaultAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    foodId,
    unit,
    label,
    baseAmount,
    defaultAmount,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredUserServing &&
          other.id == this.id &&
          other.foodId == this.foodId &&
          other.unit == this.unit &&
          other.label == this.label &&
          other.baseAmount == this.baseAmount &&
          other.defaultAmount == this.defaultAmount &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class UserServingsCompanion extends UpdateCompanion<StoredUserServing> {
  final Value<String> id;
  final Value<String> foodId;
  final Value<String> unit;
  final Value<String?> label;
  final Value<double> baseAmount;
  final Value<double> defaultAmount;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const UserServingsCompanion({
    this.id = const Value.absent(),
    this.foodId = const Value.absent(),
    this.unit = const Value.absent(),
    this.label = const Value.absent(),
    this.baseAmount = const Value.absent(),
    this.defaultAmount = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserServingsCompanion.insert({
    required String id,
    required String foodId,
    required String unit,
    this.label = const Value.absent(),
    required double baseAmount,
    required double defaultAmount,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       foodId = Value(foodId),
       unit = Value(unit),
       baseAmount = Value(baseAmount),
       defaultAmount = Value(defaultAmount),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredUserServing> custom({
    Expression<String>? id,
    Expression<String>? foodId,
    Expression<String>? unit,
    Expression<String>? label,
    Expression<double>? baseAmount,
    Expression<double>? defaultAmount,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (foodId != null) 'food_id': foodId,
      if (unit != null) 'unit': unit,
      if (label != null) 'label': label,
      if (baseAmount != null) 'base_amount': baseAmount,
      if (defaultAmount != null) 'default_amount': defaultAmount,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserServingsCompanion copyWith({
    Value<String>? id,
    Value<String>? foodId,
    Value<String>? unit,
    Value<String?>? label,
    Value<double>? baseAmount,
    Value<double>? defaultAmount,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return UserServingsCompanion(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      unit: unit ?? this.unit,
      label: label ?? this.label,
      baseAmount: baseAmount ?? this.baseAmount,
      defaultAmount: defaultAmount ?? this.defaultAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      deviceId: deviceId ?? this.deviceId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (baseAmount.present) {
      map['base_amount'] = Variable<double>(baseAmount.value);
    }
    if (defaultAmount.present) {
      map['default_amount'] = Variable<double>(defaultAmount.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserServingsCompanion(')
          ..write('id: $id, ')
          ..write('foodId: $foodId, ')
          ..write('unit: $unit, ')
          ..write('label: $label, ')
          ..write('baseAmount: $baseAmount, ')
          ..write('defaultAmount: $defaultAmount, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InstallationValuesTable extends InstallationValues
    with TableInfo<$InstallationValuesTable, InstallationValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InstallationValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'installation_values';
  @override
  VerificationContext validateIntegrity(
    Insertable<InstallationValue> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  InstallationValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InstallationValue(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $InstallationValuesTable createAlias(String alias) {
    return $InstallationValuesTable(attachedDatabase, alias);
  }
}

class InstallationValue extends DataClass
    implements Insertable<InstallationValue> {
  final String key;
  final String value;
  const InstallationValue({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  InstallationValuesCompanion toCompanion(bool nullToAbsent) {
    return InstallationValuesCompanion(key: Value(key), value: Value(value));
  }

  factory InstallationValue.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InstallationValue(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  InstallationValue copyWith({String? key, String? value}) =>
      InstallationValue(key: key ?? this.key, value: value ?? this.value);
  InstallationValue copyWithCompanion(InstallationValuesCompanion data) {
    return InstallationValue(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InstallationValue(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InstallationValue &&
          other.key == this.key &&
          other.value == this.value);
}

class InstallationValuesCompanion extends UpdateCompanion<InstallationValue> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const InstallationValuesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InstallationValuesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<InstallationValue> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InstallationValuesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return InstallationValuesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InstallationValuesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$UserFoodDatabase extends GeneratedDatabase {
  _$UserFoodDatabase(QueryExecutor e) : super(e);
  $UserFoodDatabaseManager get managers => $UserFoodDatabaseManager(this);
  late final $UserFoodsTable userFoods = $UserFoodsTable(this);
  late final $UserServingsTable userServings = $UserServingsTable(this);
  late final $InstallationValuesTable installationValues =
      $InstallationValuesTable(this);
  late final Index userFoodsHistory = Index(
    'user_foods_history',
    'CREATE INDEX user_foods_history ON user_foods (deleted_at, created_at)',
  );
  late final Index userFoodsName = Index(
    'user_foods_name',
    'CREATE INDEX user_foods_name ON user_foods (name)',
  );
  late final Index userServingsFood = Index(
    'user_servings_food',
    'CREATE INDEX user_servings_food ON user_servings (food_id, deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userFoods,
    userServings,
    installationValues,
    userFoodsHistory,
    userFoodsName,
    userServingsFood,
  ];
}

typedef $$UserFoodsTableCreateCompanionBuilder =
    UserFoodsCompanion Function({
      required String id,
      required String name,
      required String category,
      Value<String?> brand,
      Value<String?> barcode,
      required String basisUnit,
      required double basisAmount,
      required String displayBasis,
      required double energyKcal,
      required double proteinG,
      required double fatG,
      required double carbsG,
      Value<bool> isFavorite,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$UserFoodsTableUpdateCompanionBuilder =
    UserFoodsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<String?> brand,
      Value<String?> barcode,
      Value<String> basisUnit,
      Value<double> basisAmount,
      Value<String> displayBasis,
      Value<double> energyKcal,
      Value<double> proteinG,
      Value<double> fatG,
      Value<double> carbsG,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

final class $$UserFoodsTableReferences
    extends
        BaseReferences<_$UserFoodDatabase, $UserFoodsTable, StoredUserFood> {
  $$UserFoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserServingsTable, List<StoredUserServing>>
  _userServingsRefsTable(_$UserFoodDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.userServings,
        aliasName: $_aliasNameGenerator(
          db.userFoods.id,
          db.userServings.foodId,
        ),
      );

  $$UserServingsTableProcessedTableManager get userServingsRefs {
    final manager = $$UserServingsTableTableManager(
      $_db,
      $_db.userServings,
    ).filter((f) => f.foodId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_userServingsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserFoodsTableFilterComposer
    extends Composer<_$UserFoodDatabase, $UserFoodsTable> {
  $$UserFoodsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get basisUnit => $composableBuilder(
    column: $table.basisUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayBasis => $composableBuilder(
    column: $table.displayBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> userServingsRefs(
    Expression<bool> Function($$UserServingsTableFilterComposer f) f,
  ) {
    final $$UserServingsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userServings,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserServingsTableFilterComposer(
            $db: $db,
            $table: $db.userServings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserFoodsTableOrderingComposer
    extends Composer<_$UserFoodDatabase, $UserFoodsTable> {
  $$UserFoodsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get barcode => $composableBuilder(
    column: $table.barcode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get basisUnit => $composableBuilder(
    column: $table.basisUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayBasis => $composableBuilder(
    column: $table.displayBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatG => $composableBuilder(
    column: $table.fatG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsG => $composableBuilder(
    column: $table.carbsG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserFoodsTableAnnotationComposer
    extends Composer<_$UserFoodDatabase, $UserFoodsTable> {
  $$UserFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<String> get basisUnit =>
      $composableBuilder(column: $table.basisUnit, builder: (column) => column);

  GeneratedColumn<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get displayBasis => $composableBuilder(
    column: $table.displayBasis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energyKcal => $composableBuilder(
    column: $table.energyKcal,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get fatG =>
      $composableBuilder(column: $table.fatG, builder: (column) => column);

  GeneratedColumn<double> get carbsG =>
      $composableBuilder(column: $table.carbsG, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  Expression<T> userServingsRefs<T extends Object>(
    Expression<T> Function($$UserServingsTableAnnotationComposer a) f,
  ) {
    final $$UserServingsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.userServings,
      getReferencedColumn: (t) => t.foodId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserServingsTableAnnotationComposer(
            $db: $db,
            $table: $db.userServings,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserFoodsTableTableManager
    extends
        RootTableManager<
          _$UserFoodDatabase,
          $UserFoodsTable,
          StoredUserFood,
          $$UserFoodsTableFilterComposer,
          $$UserFoodsTableOrderingComposer,
          $$UserFoodsTableAnnotationComposer,
          $$UserFoodsTableCreateCompanionBuilder,
          $$UserFoodsTableUpdateCompanionBuilder,
          (StoredUserFood, $$UserFoodsTableReferences),
          StoredUserFood,
          PrefetchHooks Function({bool userServingsRefs})
        > {
  $$UserFoodsTableTableManager(_$UserFoodDatabase db, $UserFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                Value<String> basisUnit = const Value.absent(),
                Value<double> basisAmount = const Value.absent(),
                Value<String> displayBasis = const Value.absent(),
                Value<double> energyKcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserFoodsCompanion(
                id: id,
                name: name,
                category: category,
                brand: brand,
                barcode: barcode,
                basisUnit: basisUnit,
                basisAmount: basisAmount,
                displayBasis: displayBasis,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                Value<String?> brand = const Value.absent(),
                Value<String?> barcode = const Value.absent(),
                required String basisUnit,
                required double basisAmount,
                required String displayBasis,
                required double energyKcal,
                required double proteinG,
                required double fatG,
                required double carbsG,
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => UserFoodsCompanion.insert(
                id: id,
                name: name,
                category: category,
                brand: brand,
                barcode: barcode,
                basisUnit: basisUnit,
                basisAmount: basisAmount,
                displayBasis: displayBasis,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserFoodsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({userServingsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (userServingsRefs) db.userServings],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (userServingsRefs)
                    await $_getPrefetchedData<
                      StoredUserFood,
                      $UserFoodsTable,
                      StoredUserServing
                    >(
                      currentTable: table,
                      referencedTable: $$UserFoodsTableReferences
                          ._userServingsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserFoodsTableReferences(
                            db,
                            table,
                            p0,
                          ).userServingsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.foodId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserFoodDatabase,
      $UserFoodsTable,
      StoredUserFood,
      $$UserFoodsTableFilterComposer,
      $$UserFoodsTableOrderingComposer,
      $$UserFoodsTableAnnotationComposer,
      $$UserFoodsTableCreateCompanionBuilder,
      $$UserFoodsTableUpdateCompanionBuilder,
      (StoredUserFood, $$UserFoodsTableReferences),
      StoredUserFood,
      PrefetchHooks Function({bool userServingsRefs})
    >;
typedef $$UserServingsTableCreateCompanionBuilder =
    UserServingsCompanion Function({
      required String id,
      required String foodId,
      required String unit,
      Value<String?> label,
      required double baseAmount,
      required double defaultAmount,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$UserServingsTableUpdateCompanionBuilder =
    UserServingsCompanion Function({
      Value<String> id,
      Value<String> foodId,
      Value<String> unit,
      Value<String?> label,
      Value<double> baseAmount,
      Value<double> defaultAmount,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

final class $$UserServingsTableReferences
    extends
        BaseReferences<
          _$UserFoodDatabase,
          $UserServingsTable,
          StoredUserServing
        > {
  $$UserServingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserFoodsTable _foodIdTable(_$UserFoodDatabase db) =>
      db.userFoods.createAlias(
        $_aliasNameGenerator(db.userServings.foodId, db.userFoods.id),
      );

  $$UserFoodsTableProcessedTableManager get foodId {
    final $_column = $_itemColumn<String>('food_id')!;

    final manager = $$UserFoodsTableTableManager(
      $_db,
      $_db.userFoods,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_foodIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$UserServingsTableFilterComposer
    extends Composer<_$UserFoodDatabase, $UserServingsTable> {
  $$UserServingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  $$UserFoodsTableFilterComposer get foodId {
    final $$UserFoodsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.userFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFoodsTableFilterComposer(
            $db: $db,
            $table: $db.userFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserServingsTableOrderingComposer
    extends Composer<_$UserFoodDatabase, $UserServingsTable> {
  $$UserServingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unit => $composableBuilder(
    column: $table.unit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  $$UserFoodsTableOrderingComposer get foodId {
    final $$UserFoodsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.userFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFoodsTableOrderingComposer(
            $db: $db,
            $table: $db.userFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserServingsTableAnnotationComposer
    extends Composer<_$UserFoodDatabase, $UserServingsTable> {
  $$UserServingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<double> get baseAmount => $composableBuilder(
    column: $table.baseAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultAmount => $composableBuilder(
    column: $table.defaultAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  $$UserFoodsTableAnnotationComposer get foodId {
    final $$UserFoodsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.foodId,
      referencedTable: $db.userFoods,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserFoodsTableAnnotationComposer(
            $db: $db,
            $table: $db.userFoods,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$UserServingsTableTableManager
    extends
        RootTableManager<
          _$UserFoodDatabase,
          $UserServingsTable,
          StoredUserServing,
          $$UserServingsTableFilterComposer,
          $$UserServingsTableOrderingComposer,
          $$UserServingsTableAnnotationComposer,
          $$UserServingsTableCreateCompanionBuilder,
          $$UserServingsTableUpdateCompanionBuilder,
          (StoredUserServing, $$UserServingsTableReferences),
          StoredUserServing,
          PrefetchHooks Function({bool foodId})
        > {
  $$UserServingsTableTableManager(
    _$UserFoodDatabase db,
    $UserServingsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserServingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserServingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserServingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> unit = const Value.absent(),
                Value<String?> label = const Value.absent(),
                Value<double> baseAmount = const Value.absent(),
                Value<double> defaultAmount = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => UserServingsCompanion(
                id: id,
                foodId: foodId,
                unit: unit,
                label: label,
                baseAmount: baseAmount,
                defaultAmount: defaultAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String foodId,
                required String unit,
                Value<String?> label = const Value.absent(),
                required double baseAmount,
                required double defaultAmount,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => UserServingsCompanion.insert(
                id: id,
                foodId: foodId,
                unit: unit,
                label: label,
                baseAmount: baseAmount,
                defaultAmount: defaultAmount,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$UserServingsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({foodId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (foodId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.foodId,
                                referencedTable: $$UserServingsTableReferences
                                    ._foodIdTable(db),
                                referencedColumn: $$UserServingsTableReferences
                                    ._foodIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$UserServingsTableProcessedTableManager =
    ProcessedTableManager<
      _$UserFoodDatabase,
      $UserServingsTable,
      StoredUserServing,
      $$UserServingsTableFilterComposer,
      $$UserServingsTableOrderingComposer,
      $$UserServingsTableAnnotationComposer,
      $$UserServingsTableCreateCompanionBuilder,
      $$UserServingsTableUpdateCompanionBuilder,
      (StoredUserServing, $$UserServingsTableReferences),
      StoredUserServing,
      PrefetchHooks Function({bool foodId})
    >;
typedef $$InstallationValuesTableCreateCompanionBuilder =
    InstallationValuesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$InstallationValuesTableUpdateCompanionBuilder =
    InstallationValuesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$InstallationValuesTableFilterComposer
    extends Composer<_$UserFoodDatabase, $InstallationValuesTable> {
  $$InstallationValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InstallationValuesTableOrderingComposer
    extends Composer<_$UserFoodDatabase, $InstallationValuesTable> {
  $$InstallationValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InstallationValuesTableAnnotationComposer
    extends Composer<_$UserFoodDatabase, $InstallationValuesTable> {
  $$InstallationValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$InstallationValuesTableTableManager
    extends
        RootTableManager<
          _$UserFoodDatabase,
          $InstallationValuesTable,
          InstallationValue,
          $$InstallationValuesTableFilterComposer,
          $$InstallationValuesTableOrderingComposer,
          $$InstallationValuesTableAnnotationComposer,
          $$InstallationValuesTableCreateCompanionBuilder,
          $$InstallationValuesTableUpdateCompanionBuilder,
          (
            InstallationValue,
            BaseReferences<
              _$UserFoodDatabase,
              $InstallationValuesTable,
              InstallationValue
            >,
          ),
          InstallationValue,
          PrefetchHooks Function()
        > {
  $$InstallationValuesTableTableManager(
    _$UserFoodDatabase db,
    $InstallationValuesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InstallationValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InstallationValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InstallationValuesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InstallationValuesCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => InstallationValuesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InstallationValuesTableProcessedTableManager =
    ProcessedTableManager<
      _$UserFoodDatabase,
      $InstallationValuesTable,
      InstallationValue,
      $$InstallationValuesTableFilterComposer,
      $$InstallationValuesTableOrderingComposer,
      $$InstallationValuesTableAnnotationComposer,
      $$InstallationValuesTableCreateCompanionBuilder,
      $$InstallationValuesTableUpdateCompanionBuilder,
      (
        InstallationValue,
        BaseReferences<
          _$UserFoodDatabase,
          $InstallationValuesTable,
          InstallationValue
        >,
      ),
      InstallationValue,
      PrefetchHooks Function()
    >;

class $UserFoodDatabaseManager {
  final _$UserFoodDatabase _db;
  $UserFoodDatabaseManager(this._db);
  $$UserFoodsTableTableManager get userFoods =>
      $$UserFoodsTableTableManager(_db, _db.userFoods);
  $$UserServingsTableTableManager get userServings =>
      $$UserServingsTableTableManager(_db, _db.userServings);
  $$InstallationValuesTableTableManager get installationValues =>
      $$InstallationValuesTableTableManager(_db, _db.installationValues);
}
