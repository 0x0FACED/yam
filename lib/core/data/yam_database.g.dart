// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'yam_database.dart';

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

class $DiaryEntriesTable extends DiaryEntries
    with TableInfo<$DiaryEntriesTable, StoredDiaryEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiaryEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diaryDayMeta = const VerificationMeta(
    'diaryDay',
  );
  @override
  late final GeneratedColumn<String> diaryDay = GeneratedColumn<String>(
    'diary_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mealIdMeta = const VerificationMeta('mealId');
  @override
  late final GeneratedColumn<String> mealId = GeneratedColumn<String>(
    'meal_id',
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
  );
  static const VerificationMeta _foodNameMeta = const VerificationMeta(
    'foodName',
  );
  @override
  late final GeneratedColumn<String> foodName = GeneratedColumn<String>(
    'food_name',
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
  static const VerificationMeta _baseUnitMeta = const VerificationMeta(
    'baseUnit',
  );
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
    'base_unit',
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
  static const VerificationMeta _kcalPerBasisMeta = const VerificationMeta(
    'kcalPerBasis',
  );
  @override
  late final GeneratedColumn<double> kcalPerBasis = GeneratedColumn<double>(
    'kcal_per_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinPerBasisMeta = const VerificationMeta(
    'proteinPerBasis',
  );
  @override
  late final GeneratedColumn<double> proteinPerBasis = GeneratedColumn<double>(
    'protein_per_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatPerBasisMeta = const VerificationMeta(
    'fatPerBasis',
  );
  @override
  late final GeneratedColumn<double> fatPerBasis = GeneratedColumn<double>(
    'fat_per_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsPerBasisMeta = const VerificationMeta(
    'carbsPerBasis',
  );
  @override
  late final GeneratedColumn<double> carbsPerBasis = GeneratedColumn<double>(
    'carbs_per_basis',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingsSnapshotMeta = const VerificationMeta(
    'servingsSnapshot',
  );
  @override
  late final GeneratedColumn<String> servingsSnapshot = GeneratedColumn<String>(
    'servings_snapshot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _servingIdMeta = const VerificationMeta(
    'servingId',
  );
  @override
  late final GeneratedColumn<String> servingId = GeneratedColumn<String>(
    'serving_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _canonicalQuantityMeta = const VerificationMeta(
    'canonicalQuantity',
  );
  @override
  late final GeneratedColumn<double> canonicalQuantity =
      GeneratedColumn<double>(
        'canonical_quantity',
        aliasedName,
        false,
        type: DriftSqlType.double,
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
    diaryDay,
    mealId,
    foodId,
    foodName,
    brand,
    baseUnit,
    basisAmount,
    kcalPerBasis,
    proteinPerBasis,
    fatPerBasis,
    carbsPerBasis,
    servingsSnapshot,
    servingId,
    amount,
    canonicalQuantity,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'diary_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredDiaryEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('diary_day')) {
      context.handle(
        _diaryDayMeta,
        diaryDay.isAcceptableOrUnknown(data['diary_day']!, _diaryDayMeta),
      );
    } else if (isInserting) {
      context.missing(_diaryDayMeta);
    }
    if (data.containsKey('meal_id')) {
      context.handle(
        _mealIdMeta,
        mealId.isAcceptableOrUnknown(data['meal_id']!, _mealIdMeta),
      );
    } else if (isInserting) {
      context.missing(_mealIdMeta);
    }
    if (data.containsKey('food_id')) {
      context.handle(
        _foodIdMeta,
        foodId.isAcceptableOrUnknown(data['food_id']!, _foodIdMeta),
      );
    } else if (isInserting) {
      context.missing(_foodIdMeta);
    }
    if (data.containsKey('food_name')) {
      context.handle(
        _foodNameMeta,
        foodName.isAcceptableOrUnknown(data['food_name']!, _foodNameMeta),
      );
    } else if (isInserting) {
      context.missing(_foodNameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('base_unit')) {
      context.handle(
        _baseUnitMeta,
        baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta),
      );
    } else if (isInserting) {
      context.missing(_baseUnitMeta);
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
    if (data.containsKey('kcal_per_basis')) {
      context.handle(
        _kcalPerBasisMeta,
        kcalPerBasis.isAcceptableOrUnknown(
          data['kcal_per_basis']!,
          _kcalPerBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_kcalPerBasisMeta);
    }
    if (data.containsKey('protein_per_basis')) {
      context.handle(
        _proteinPerBasisMeta,
        proteinPerBasis.isAcceptableOrUnknown(
          data['protein_per_basis']!,
          _proteinPerBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinPerBasisMeta);
    }
    if (data.containsKey('fat_per_basis')) {
      context.handle(
        _fatPerBasisMeta,
        fatPerBasis.isAcceptableOrUnknown(
          data['fat_per_basis']!,
          _fatPerBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_fatPerBasisMeta);
    }
    if (data.containsKey('carbs_per_basis')) {
      context.handle(
        _carbsPerBasisMeta,
        carbsPerBasis.isAcceptableOrUnknown(
          data['carbs_per_basis']!,
          _carbsPerBasisMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsPerBasisMeta);
    }
    if (data.containsKey('servings_snapshot')) {
      context.handle(
        _servingsSnapshotMeta,
        servingsSnapshot.isAcceptableOrUnknown(
          data['servings_snapshot']!,
          _servingsSnapshotMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_servingsSnapshotMeta);
    }
    if (data.containsKey('serving_id')) {
      context.handle(
        _servingIdMeta,
        servingId.isAcceptableOrUnknown(data['serving_id']!, _servingIdMeta),
      );
    } else if (isInserting) {
      context.missing(_servingIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('canonical_quantity')) {
      context.handle(
        _canonicalQuantityMeta,
        canonicalQuantity.isAcceptableOrUnknown(
          data['canonical_quantity']!,
          _canonicalQuantityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalQuantityMeta);
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
  StoredDiaryEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredDiaryEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      diaryDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}diary_day'],
      )!,
      mealId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}meal_id'],
      )!,
      foodId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_id'],
      )!,
      foodName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}food_name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      baseUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}base_unit'],
      )!,
      basisAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basis_amount'],
      )!,
      kcalPerBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}kcal_per_basis'],
      )!,
      proteinPerBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}protein_per_basis'],
      )!,
      fatPerBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fat_per_basis'],
      )!,
      carbsPerBasis: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}carbs_per_basis'],
      )!,
      servingsSnapshot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}servings_snapshot'],
      )!,
      servingId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}serving_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      canonicalQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}canonical_quantity'],
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
  $DiaryEntriesTable createAlias(String alias) {
    return $DiaryEntriesTable(attachedDatabase, alias);
  }
}

class StoredDiaryEntry extends DataClass
    implements Insertable<StoredDiaryEntry> {
  final String id;
  final String diaryDay;
  final String mealId;
  final String foodId;
  final String foodName;
  final String? brand;
  final String baseUnit;
  final double basisAmount;
  final double kcalPerBasis;
  final double proteinPerBasis;
  final double fatPerBasis;
  final double carbsPerBasis;
  final String servingsSnapshot;
  final String servingId;
  final double amount;
  final double canonicalQuantity;
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredDiaryEntry({
    required this.id,
    required this.diaryDay,
    required this.mealId,
    required this.foodId,
    required this.foodName,
    this.brand,
    required this.baseUnit,
    required this.basisAmount,
    required this.kcalPerBasis,
    required this.proteinPerBasis,
    required this.fatPerBasis,
    required this.carbsPerBasis,
    required this.servingsSnapshot,
    required this.servingId,
    required this.amount,
    required this.canonicalQuantity,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['diary_day'] = Variable<String>(diaryDay);
    map['meal_id'] = Variable<String>(mealId);
    map['food_id'] = Variable<String>(foodId);
    map['food_name'] = Variable<String>(foodName);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['base_unit'] = Variable<String>(baseUnit);
    map['basis_amount'] = Variable<double>(basisAmount);
    map['kcal_per_basis'] = Variable<double>(kcalPerBasis);
    map['protein_per_basis'] = Variable<double>(proteinPerBasis);
    map['fat_per_basis'] = Variable<double>(fatPerBasis);
    map['carbs_per_basis'] = Variable<double>(carbsPerBasis);
    map['servings_snapshot'] = Variable<String>(servingsSnapshot);
    map['serving_id'] = Variable<String>(servingId);
    map['amount'] = Variable<double>(amount);
    map['canonical_quantity'] = Variable<double>(canonicalQuantity);
    map['energy_kcal'] = Variable<double>(energyKcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['fat_g'] = Variable<double>(fatG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  DiaryEntriesCompanion toCompanion(bool nullToAbsent) {
    return DiaryEntriesCompanion(
      id: Value(id),
      diaryDay: Value(diaryDay),
      mealId: Value(mealId),
      foodId: Value(foodId),
      foodName: Value(foodName),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      baseUnit: Value(baseUnit),
      basisAmount: Value(basisAmount),
      kcalPerBasis: Value(kcalPerBasis),
      proteinPerBasis: Value(proteinPerBasis),
      fatPerBasis: Value(fatPerBasis),
      carbsPerBasis: Value(carbsPerBasis),
      servingsSnapshot: Value(servingsSnapshot),
      servingId: Value(servingId),
      amount: Value(amount),
      canonicalQuantity: Value(canonicalQuantity),
      energyKcal: Value(energyKcal),
      proteinG: Value(proteinG),
      fatG: Value(fatG),
      carbsG: Value(carbsG),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredDiaryEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredDiaryEntry(
      id: serializer.fromJson<String>(json['id']),
      diaryDay: serializer.fromJson<String>(json['diaryDay']),
      mealId: serializer.fromJson<String>(json['mealId']),
      foodId: serializer.fromJson<String>(json['foodId']),
      foodName: serializer.fromJson<String>(json['foodName']),
      brand: serializer.fromJson<String?>(json['brand']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      basisAmount: serializer.fromJson<double>(json['basisAmount']),
      kcalPerBasis: serializer.fromJson<double>(json['kcalPerBasis']),
      proteinPerBasis: serializer.fromJson<double>(json['proteinPerBasis']),
      fatPerBasis: serializer.fromJson<double>(json['fatPerBasis']),
      carbsPerBasis: serializer.fromJson<double>(json['carbsPerBasis']),
      servingsSnapshot: serializer.fromJson<String>(json['servingsSnapshot']),
      servingId: serializer.fromJson<String>(json['servingId']),
      amount: serializer.fromJson<double>(json['amount']),
      canonicalQuantity: serializer.fromJson<double>(json['canonicalQuantity']),
      energyKcal: serializer.fromJson<double>(json['energyKcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
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
      'diaryDay': serializer.toJson<String>(diaryDay),
      'mealId': serializer.toJson<String>(mealId),
      'foodId': serializer.toJson<String>(foodId),
      'foodName': serializer.toJson<String>(foodName),
      'brand': serializer.toJson<String?>(brand),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'basisAmount': serializer.toJson<double>(basisAmount),
      'kcalPerBasis': serializer.toJson<double>(kcalPerBasis),
      'proteinPerBasis': serializer.toJson<double>(proteinPerBasis),
      'fatPerBasis': serializer.toJson<double>(fatPerBasis),
      'carbsPerBasis': serializer.toJson<double>(carbsPerBasis),
      'servingsSnapshot': serializer.toJson<String>(servingsSnapshot),
      'servingId': serializer.toJson<String>(servingId),
      'amount': serializer.toJson<double>(amount),
      'canonicalQuantity': serializer.toJson<double>(canonicalQuantity),
      'energyKcal': serializer.toJson<double>(energyKcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'fatG': serializer.toJson<double>(fatG),
      'carbsG': serializer.toJson<double>(carbsG),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredDiaryEntry copyWith({
    String? id,
    String? diaryDay,
    String? mealId,
    String? foodId,
    String? foodName,
    Value<String?> brand = const Value.absent(),
    String? baseUnit,
    double? basisAmount,
    double? kcalPerBasis,
    double? proteinPerBasis,
    double? fatPerBasis,
    double? carbsPerBasis,
    String? servingsSnapshot,
    String? servingId,
    double? amount,
    double? canonicalQuantity,
    double? energyKcal,
    double? proteinG,
    double? fatG,
    double? carbsG,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredDiaryEntry(
    id: id ?? this.id,
    diaryDay: diaryDay ?? this.diaryDay,
    mealId: mealId ?? this.mealId,
    foodId: foodId ?? this.foodId,
    foodName: foodName ?? this.foodName,
    brand: brand.present ? brand.value : this.brand,
    baseUnit: baseUnit ?? this.baseUnit,
    basisAmount: basisAmount ?? this.basisAmount,
    kcalPerBasis: kcalPerBasis ?? this.kcalPerBasis,
    proteinPerBasis: proteinPerBasis ?? this.proteinPerBasis,
    fatPerBasis: fatPerBasis ?? this.fatPerBasis,
    carbsPerBasis: carbsPerBasis ?? this.carbsPerBasis,
    servingsSnapshot: servingsSnapshot ?? this.servingsSnapshot,
    servingId: servingId ?? this.servingId,
    amount: amount ?? this.amount,
    canonicalQuantity: canonicalQuantity ?? this.canonicalQuantity,
    energyKcal: energyKcal ?? this.energyKcal,
    proteinG: proteinG ?? this.proteinG,
    fatG: fatG ?? this.fatG,
    carbsG: carbsG ?? this.carbsG,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredDiaryEntry copyWithCompanion(DiaryEntriesCompanion data) {
    return StoredDiaryEntry(
      id: data.id.present ? data.id.value : this.id,
      diaryDay: data.diaryDay.present ? data.diaryDay.value : this.diaryDay,
      mealId: data.mealId.present ? data.mealId.value : this.mealId,
      foodId: data.foodId.present ? data.foodId.value : this.foodId,
      foodName: data.foodName.present ? data.foodName.value : this.foodName,
      brand: data.brand.present ? data.brand.value : this.brand,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      basisAmount: data.basisAmount.present
          ? data.basisAmount.value
          : this.basisAmount,
      kcalPerBasis: data.kcalPerBasis.present
          ? data.kcalPerBasis.value
          : this.kcalPerBasis,
      proteinPerBasis: data.proteinPerBasis.present
          ? data.proteinPerBasis.value
          : this.proteinPerBasis,
      fatPerBasis: data.fatPerBasis.present
          ? data.fatPerBasis.value
          : this.fatPerBasis,
      carbsPerBasis: data.carbsPerBasis.present
          ? data.carbsPerBasis.value
          : this.carbsPerBasis,
      servingsSnapshot: data.servingsSnapshot.present
          ? data.servingsSnapshot.value
          : this.servingsSnapshot,
      servingId: data.servingId.present ? data.servingId.value : this.servingId,
      amount: data.amount.present ? data.amount.value : this.amount,
      canonicalQuantity: data.canonicalQuantity.present
          ? data.canonicalQuantity.value
          : this.canonicalQuantity,
      energyKcal: data.energyKcal.present
          ? data.energyKcal.value
          : this.energyKcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredDiaryEntry(')
          ..write('id: $id, ')
          ..write('diaryDay: $diaryDay, ')
          ..write('mealId: $mealId, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('brand: $brand, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('kcalPerBasis: $kcalPerBasis, ')
          ..write('proteinPerBasis: $proteinPerBasis, ')
          ..write('fatPerBasis: $fatPerBasis, ')
          ..write('carbsPerBasis: $carbsPerBasis, ')
          ..write('servingsSnapshot: $servingsSnapshot, ')
          ..write('servingId: $servingId, ')
          ..write('amount: $amount, ')
          ..write('canonicalQuantity: $canonicalQuantity, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    diaryDay,
    mealId,
    foodId,
    foodName,
    brand,
    baseUnit,
    basisAmount,
    kcalPerBasis,
    proteinPerBasis,
    fatPerBasis,
    carbsPerBasis,
    servingsSnapshot,
    servingId,
    amount,
    canonicalQuantity,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredDiaryEntry &&
          other.id == this.id &&
          other.diaryDay == this.diaryDay &&
          other.mealId == this.mealId &&
          other.foodId == this.foodId &&
          other.foodName == this.foodName &&
          other.brand == this.brand &&
          other.baseUnit == this.baseUnit &&
          other.basisAmount == this.basisAmount &&
          other.kcalPerBasis == this.kcalPerBasis &&
          other.proteinPerBasis == this.proteinPerBasis &&
          other.fatPerBasis == this.fatPerBasis &&
          other.carbsPerBasis == this.carbsPerBasis &&
          other.servingsSnapshot == this.servingsSnapshot &&
          other.servingId == this.servingId &&
          other.amount == this.amount &&
          other.canonicalQuantity == this.canonicalQuantity &&
          other.energyKcal == this.energyKcal &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class DiaryEntriesCompanion extends UpdateCompanion<StoredDiaryEntry> {
  final Value<String> id;
  final Value<String> diaryDay;
  final Value<String> mealId;
  final Value<String> foodId;
  final Value<String> foodName;
  final Value<String?> brand;
  final Value<String> baseUnit;
  final Value<double> basisAmount;
  final Value<double> kcalPerBasis;
  final Value<double> proteinPerBasis;
  final Value<double> fatPerBasis;
  final Value<double> carbsPerBasis;
  final Value<String> servingsSnapshot;
  final Value<String> servingId;
  final Value<double> amount;
  final Value<double> canonicalQuantity;
  final Value<double> energyKcal;
  final Value<double> proteinG;
  final Value<double> fatG;
  final Value<double> carbsG;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const DiaryEntriesCompanion({
    this.id = const Value.absent(),
    this.diaryDay = const Value.absent(),
    this.mealId = const Value.absent(),
    this.foodId = const Value.absent(),
    this.foodName = const Value.absent(),
    this.brand = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.basisAmount = const Value.absent(),
    this.kcalPerBasis = const Value.absent(),
    this.proteinPerBasis = const Value.absent(),
    this.fatPerBasis = const Value.absent(),
    this.carbsPerBasis = const Value.absent(),
    this.servingsSnapshot = const Value.absent(),
    this.servingId = const Value.absent(),
    this.amount = const Value.absent(),
    this.canonicalQuantity = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiaryEntriesCompanion.insert({
    required String id,
    required String diaryDay,
    required String mealId,
    required String foodId,
    required String foodName,
    this.brand = const Value.absent(),
    required String baseUnit,
    required double basisAmount,
    required double kcalPerBasis,
    required double proteinPerBasis,
    required double fatPerBasis,
    required double carbsPerBasis,
    required String servingsSnapshot,
    required String servingId,
    required double amount,
    required double canonicalQuantity,
    required double energyKcal,
    required double proteinG,
    required double fatG,
    required double carbsG,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       diaryDay = Value(diaryDay),
       mealId = Value(mealId),
       foodId = Value(foodId),
       foodName = Value(foodName),
       baseUnit = Value(baseUnit),
       basisAmount = Value(basisAmount),
       kcalPerBasis = Value(kcalPerBasis),
       proteinPerBasis = Value(proteinPerBasis),
       fatPerBasis = Value(fatPerBasis),
       carbsPerBasis = Value(carbsPerBasis),
       servingsSnapshot = Value(servingsSnapshot),
       servingId = Value(servingId),
       amount = Value(amount),
       canonicalQuantity = Value(canonicalQuantity),
       energyKcal = Value(energyKcal),
       proteinG = Value(proteinG),
       fatG = Value(fatG),
       carbsG = Value(carbsG),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredDiaryEntry> custom({
    Expression<String>? id,
    Expression<String>? diaryDay,
    Expression<String>? mealId,
    Expression<String>? foodId,
    Expression<String>? foodName,
    Expression<String>? brand,
    Expression<String>? baseUnit,
    Expression<double>? basisAmount,
    Expression<double>? kcalPerBasis,
    Expression<double>? proteinPerBasis,
    Expression<double>? fatPerBasis,
    Expression<double>? carbsPerBasis,
    Expression<String>? servingsSnapshot,
    Expression<String>? servingId,
    Expression<double>? amount,
    Expression<double>? canonicalQuantity,
    Expression<double>? energyKcal,
    Expression<double>? proteinG,
    Expression<double>? fatG,
    Expression<double>? carbsG,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (diaryDay != null) 'diary_day': diaryDay,
      if (mealId != null) 'meal_id': mealId,
      if (foodId != null) 'food_id': foodId,
      if (foodName != null) 'food_name': foodName,
      if (brand != null) 'brand': brand,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (basisAmount != null) 'basis_amount': basisAmount,
      if (kcalPerBasis != null) 'kcal_per_basis': kcalPerBasis,
      if (proteinPerBasis != null) 'protein_per_basis': proteinPerBasis,
      if (fatPerBasis != null) 'fat_per_basis': fatPerBasis,
      if (carbsPerBasis != null) 'carbs_per_basis': carbsPerBasis,
      if (servingsSnapshot != null) 'servings_snapshot': servingsSnapshot,
      if (servingId != null) 'serving_id': servingId,
      if (amount != null) 'amount': amount,
      if (canonicalQuantity != null) 'canonical_quantity': canonicalQuantity,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiaryEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? diaryDay,
    Value<String>? mealId,
    Value<String>? foodId,
    Value<String>? foodName,
    Value<String?>? brand,
    Value<String>? baseUnit,
    Value<double>? basisAmount,
    Value<double>? kcalPerBasis,
    Value<double>? proteinPerBasis,
    Value<double>? fatPerBasis,
    Value<double>? carbsPerBasis,
    Value<String>? servingsSnapshot,
    Value<String>? servingId,
    Value<double>? amount,
    Value<double>? canonicalQuantity,
    Value<double>? energyKcal,
    Value<double>? proteinG,
    Value<double>? fatG,
    Value<double>? carbsG,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return DiaryEntriesCompanion(
      id: id ?? this.id,
      diaryDay: diaryDay ?? this.diaryDay,
      mealId: mealId ?? this.mealId,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      brand: brand ?? this.brand,
      baseUnit: baseUnit ?? this.baseUnit,
      basisAmount: basisAmount ?? this.basisAmount,
      kcalPerBasis: kcalPerBasis ?? this.kcalPerBasis,
      proteinPerBasis: proteinPerBasis ?? this.proteinPerBasis,
      fatPerBasis: fatPerBasis ?? this.fatPerBasis,
      carbsPerBasis: carbsPerBasis ?? this.carbsPerBasis,
      servingsSnapshot: servingsSnapshot ?? this.servingsSnapshot,
      servingId: servingId ?? this.servingId,
      amount: amount ?? this.amount,
      canonicalQuantity: canonicalQuantity ?? this.canonicalQuantity,
      energyKcal: energyKcal ?? this.energyKcal,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
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
    if (diaryDay.present) {
      map['diary_day'] = Variable<String>(diaryDay.value);
    }
    if (mealId.present) {
      map['meal_id'] = Variable<String>(mealId.value);
    }
    if (foodId.present) {
      map['food_id'] = Variable<String>(foodId.value);
    }
    if (foodName.present) {
      map['food_name'] = Variable<String>(foodName.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (basisAmount.present) {
      map['basis_amount'] = Variable<double>(basisAmount.value);
    }
    if (kcalPerBasis.present) {
      map['kcal_per_basis'] = Variable<double>(kcalPerBasis.value);
    }
    if (proteinPerBasis.present) {
      map['protein_per_basis'] = Variable<double>(proteinPerBasis.value);
    }
    if (fatPerBasis.present) {
      map['fat_per_basis'] = Variable<double>(fatPerBasis.value);
    }
    if (carbsPerBasis.present) {
      map['carbs_per_basis'] = Variable<double>(carbsPerBasis.value);
    }
    if (servingsSnapshot.present) {
      map['servings_snapshot'] = Variable<String>(servingsSnapshot.value);
    }
    if (servingId.present) {
      map['serving_id'] = Variable<String>(servingId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (canonicalQuantity.present) {
      map['canonical_quantity'] = Variable<double>(canonicalQuantity.value);
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
    return (StringBuffer('DiaryEntriesCompanion(')
          ..write('id: $id, ')
          ..write('diaryDay: $diaryDay, ')
          ..write('mealId: $mealId, ')
          ..write('foodId: $foodId, ')
          ..write('foodName: $foodName, ')
          ..write('brand: $brand, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('kcalPerBasis: $kcalPerBasis, ')
          ..write('proteinPerBasis: $proteinPerBasis, ')
          ..write('fatPerBasis: $fatPerBasis, ')
          ..write('carbsPerBasis: $carbsPerBasis, ')
          ..write('servingsSnapshot: $servingsSnapshot, ')
          ..write('servingId: $servingId, ')
          ..write('amount: $amount, ')
          ..write('canonicalQuantity: $canonicalQuantity, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalVersionsTable extends GoalVersions
    with TableInfo<$GoalVersionsTable, StoredGoalVersion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalVersionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _effectiveDayMeta = const VerificationMeta(
    'effectiveDay',
  );
  @override
  late final GeneratedColumn<String> effectiveDay = GeneratedColumn<String>(
    'effective_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _goalMeta = const VerificationMeta('goal');
  @override
  late final GeneratedColumn<String> goal = GeneratedColumn<String>(
    'goal',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calorieTargetMeta = const VerificationMeta(
    'calorieTarget',
  );
  @override
  late final GeneratedColumn<int> calorieTarget = GeneratedColumn<int>(
    'calorie_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _proteinTargetMeta = const VerificationMeta(
    'proteinTarget',
  );
  @override
  late final GeneratedColumn<int> proteinTarget = GeneratedColumn<int>(
    'protein_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fatTargetMeta = const VerificationMeta(
    'fatTarget',
  );
  @override
  late final GeneratedColumn<int> fatTarget = GeneratedColumn<int>(
    'fat_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _carbsTargetMeta = const VerificationMeta(
    'carbsTarget',
  );
  @override
  late final GeneratedColumn<int> carbsTarget = GeneratedColumn<int>(
    'carbs_target',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetWeightKgMeta = const VerificationMeta(
    'targetWeightKg',
  );
  @override
  late final GeneratedColumn<double> targetWeightKg = GeneratedColumn<double>(
    'target_weight_kg',
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
    effectiveDay,
    goal,
    calorieTarget,
    proteinTarget,
    fatTarget,
    carbsTarget,
    targetWeightKg,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goal_versions';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredGoalVersion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('effective_day')) {
      context.handle(
        _effectiveDayMeta,
        effectiveDay.isAcceptableOrUnknown(
          data['effective_day']!,
          _effectiveDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveDayMeta);
    }
    if (data.containsKey('goal')) {
      context.handle(
        _goalMeta,
        goal.isAcceptableOrUnknown(data['goal']!, _goalMeta),
      );
    } else if (isInserting) {
      context.missing(_goalMeta);
    }
    if (data.containsKey('calorie_target')) {
      context.handle(
        _calorieTargetMeta,
        calorieTarget.isAcceptableOrUnknown(
          data['calorie_target']!,
          _calorieTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_calorieTargetMeta);
    }
    if (data.containsKey('protein_target')) {
      context.handle(
        _proteinTargetMeta,
        proteinTarget.isAcceptableOrUnknown(
          data['protein_target']!,
          _proteinTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_proteinTargetMeta);
    }
    if (data.containsKey('fat_target')) {
      context.handle(
        _fatTargetMeta,
        fatTarget.isAcceptableOrUnknown(data['fat_target']!, _fatTargetMeta),
      );
    } else if (isInserting) {
      context.missing(_fatTargetMeta);
    }
    if (data.containsKey('carbs_target')) {
      context.handle(
        _carbsTargetMeta,
        carbsTarget.isAcceptableOrUnknown(
          data['carbs_target']!,
          _carbsTargetMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_carbsTargetMeta);
    }
    if (data.containsKey('target_weight_kg')) {
      context.handle(
        _targetWeightKgMeta,
        targetWeightKg.isAcceptableOrUnknown(
          data['target_weight_kg']!,
          _targetWeightKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetWeightKgMeta);
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
  StoredGoalVersion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredGoalVersion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      effectiveDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}effective_day'],
      )!,
      goal: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goal'],
      )!,
      calorieTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}calorie_target'],
      )!,
      proteinTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein_target'],
      )!,
      fatTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}fat_target'],
      )!,
      carbsTarget: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}carbs_target'],
      )!,
      targetWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_weight_kg'],
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
  $GoalVersionsTable createAlias(String alias) {
    return $GoalVersionsTable(attachedDatabase, alias);
  }
}

class StoredGoalVersion extends DataClass
    implements Insertable<StoredGoalVersion> {
  final String id;
  final String effectiveDay;
  final String goal;
  final int calorieTarget;
  final int proteinTarget;
  final int fatTarget;
  final int carbsTarget;
  final double targetWeightKg;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredGoalVersion({
    required this.id,
    required this.effectiveDay,
    required this.goal,
    required this.calorieTarget,
    required this.proteinTarget,
    required this.fatTarget,
    required this.carbsTarget,
    required this.targetWeightKg,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['effective_day'] = Variable<String>(effectiveDay);
    map['goal'] = Variable<String>(goal);
    map['calorie_target'] = Variable<int>(calorieTarget);
    map['protein_target'] = Variable<int>(proteinTarget);
    map['fat_target'] = Variable<int>(fatTarget);
    map['carbs_target'] = Variable<int>(carbsTarget);
    map['target_weight_kg'] = Variable<double>(targetWeightKg);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  GoalVersionsCompanion toCompanion(bool nullToAbsent) {
    return GoalVersionsCompanion(
      id: Value(id),
      effectiveDay: Value(effectiveDay),
      goal: Value(goal),
      calorieTarget: Value(calorieTarget),
      proteinTarget: Value(proteinTarget),
      fatTarget: Value(fatTarget),
      carbsTarget: Value(carbsTarget),
      targetWeightKg: Value(targetWeightKg),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredGoalVersion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredGoalVersion(
      id: serializer.fromJson<String>(json['id']),
      effectiveDay: serializer.fromJson<String>(json['effectiveDay']),
      goal: serializer.fromJson<String>(json['goal']),
      calorieTarget: serializer.fromJson<int>(json['calorieTarget']),
      proteinTarget: serializer.fromJson<int>(json['proteinTarget']),
      fatTarget: serializer.fromJson<int>(json['fatTarget']),
      carbsTarget: serializer.fromJson<int>(json['carbsTarget']),
      targetWeightKg: serializer.fromJson<double>(json['targetWeightKg']),
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
      'effectiveDay': serializer.toJson<String>(effectiveDay),
      'goal': serializer.toJson<String>(goal),
      'calorieTarget': serializer.toJson<int>(calorieTarget),
      'proteinTarget': serializer.toJson<int>(proteinTarget),
      'fatTarget': serializer.toJson<int>(fatTarget),
      'carbsTarget': serializer.toJson<int>(carbsTarget),
      'targetWeightKg': serializer.toJson<double>(targetWeightKg),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredGoalVersion copyWith({
    String? id,
    String? effectiveDay,
    String? goal,
    int? calorieTarget,
    int? proteinTarget,
    int? fatTarget,
    int? carbsTarget,
    double? targetWeightKg,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredGoalVersion(
    id: id ?? this.id,
    effectiveDay: effectiveDay ?? this.effectiveDay,
    goal: goal ?? this.goal,
    calorieTarget: calorieTarget ?? this.calorieTarget,
    proteinTarget: proteinTarget ?? this.proteinTarget,
    fatTarget: fatTarget ?? this.fatTarget,
    carbsTarget: carbsTarget ?? this.carbsTarget,
    targetWeightKg: targetWeightKg ?? this.targetWeightKg,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredGoalVersion copyWithCompanion(GoalVersionsCompanion data) {
    return StoredGoalVersion(
      id: data.id.present ? data.id.value : this.id,
      effectiveDay: data.effectiveDay.present
          ? data.effectiveDay.value
          : this.effectiveDay,
      goal: data.goal.present ? data.goal.value : this.goal,
      calorieTarget: data.calorieTarget.present
          ? data.calorieTarget.value
          : this.calorieTarget,
      proteinTarget: data.proteinTarget.present
          ? data.proteinTarget.value
          : this.proteinTarget,
      fatTarget: data.fatTarget.present ? data.fatTarget.value : this.fatTarget,
      carbsTarget: data.carbsTarget.present
          ? data.carbsTarget.value
          : this.carbsTarget,
      targetWeightKg: data.targetWeightKg.present
          ? data.targetWeightKg.value
          : this.targetWeightKg,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredGoalVersion(')
          ..write('id: $id, ')
          ..write('effectiveDay: $effectiveDay, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('proteinTarget: $proteinTarget, ')
          ..write('fatTarget: $fatTarget, ')
          ..write('carbsTarget: $carbsTarget, ')
          ..write('targetWeightKg: $targetWeightKg, ')
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
    effectiveDay,
    goal,
    calorieTarget,
    proteinTarget,
    fatTarget,
    carbsTarget,
    targetWeightKg,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredGoalVersion &&
          other.id == this.id &&
          other.effectiveDay == this.effectiveDay &&
          other.goal == this.goal &&
          other.calorieTarget == this.calorieTarget &&
          other.proteinTarget == this.proteinTarget &&
          other.fatTarget == this.fatTarget &&
          other.carbsTarget == this.carbsTarget &&
          other.targetWeightKg == this.targetWeightKg &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class GoalVersionsCompanion extends UpdateCompanion<StoredGoalVersion> {
  final Value<String> id;
  final Value<String> effectiveDay;
  final Value<String> goal;
  final Value<int> calorieTarget;
  final Value<int> proteinTarget;
  final Value<int> fatTarget;
  final Value<int> carbsTarget;
  final Value<double> targetWeightKg;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const GoalVersionsCompanion({
    this.id = const Value.absent(),
    this.effectiveDay = const Value.absent(),
    this.goal = const Value.absent(),
    this.calorieTarget = const Value.absent(),
    this.proteinTarget = const Value.absent(),
    this.fatTarget = const Value.absent(),
    this.carbsTarget = const Value.absent(),
    this.targetWeightKg = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalVersionsCompanion.insert({
    required String id,
    required String effectiveDay,
    required String goal,
    required int calorieTarget,
    required int proteinTarget,
    required int fatTarget,
    required int carbsTarget,
    required double targetWeightKg,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       effectiveDay = Value(effectiveDay),
       goal = Value(goal),
       calorieTarget = Value(calorieTarget),
       proteinTarget = Value(proteinTarget),
       fatTarget = Value(fatTarget),
       carbsTarget = Value(carbsTarget),
       targetWeightKg = Value(targetWeightKg),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredGoalVersion> custom({
    Expression<String>? id,
    Expression<String>? effectiveDay,
    Expression<String>? goal,
    Expression<int>? calorieTarget,
    Expression<int>? proteinTarget,
    Expression<int>? fatTarget,
    Expression<int>? carbsTarget,
    Expression<double>? targetWeightKg,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (effectiveDay != null) 'effective_day': effectiveDay,
      if (goal != null) 'goal': goal,
      if (calorieTarget != null) 'calorie_target': calorieTarget,
      if (proteinTarget != null) 'protein_target': proteinTarget,
      if (fatTarget != null) 'fat_target': fatTarget,
      if (carbsTarget != null) 'carbs_target': carbsTarget,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalVersionsCompanion copyWith({
    Value<String>? id,
    Value<String>? effectiveDay,
    Value<String>? goal,
    Value<int>? calorieTarget,
    Value<int>? proteinTarget,
    Value<int>? fatTarget,
    Value<int>? carbsTarget,
    Value<double>? targetWeightKg,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return GoalVersionsCompanion(
      id: id ?? this.id,
      effectiveDay: effectiveDay ?? this.effectiveDay,
      goal: goal ?? this.goal,
      calorieTarget: calorieTarget ?? this.calorieTarget,
      proteinTarget: proteinTarget ?? this.proteinTarget,
      fatTarget: fatTarget ?? this.fatTarget,
      carbsTarget: carbsTarget ?? this.carbsTarget,
      targetWeightKg: targetWeightKg ?? this.targetWeightKg,
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
    if (effectiveDay.present) {
      map['effective_day'] = Variable<String>(effectiveDay.value);
    }
    if (goal.present) {
      map['goal'] = Variable<String>(goal.value);
    }
    if (calorieTarget.present) {
      map['calorie_target'] = Variable<int>(calorieTarget.value);
    }
    if (proteinTarget.present) {
      map['protein_target'] = Variable<int>(proteinTarget.value);
    }
    if (fatTarget.present) {
      map['fat_target'] = Variable<int>(fatTarget.value);
    }
    if (carbsTarget.present) {
      map['carbs_target'] = Variable<int>(carbsTarget.value);
    }
    if (targetWeightKg.present) {
      map['target_weight_kg'] = Variable<double>(targetWeightKg.value);
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
    return (StringBuffer('GoalVersionsCompanion(')
          ..write('id: $id, ')
          ..write('effectiveDay: $effectiveDay, ')
          ..write('goal: $goal, ')
          ..write('calorieTarget: $calorieTarget, ')
          ..write('proteinTarget: $proteinTarget, ')
          ..write('fatTarget: $fatTarget, ')
          ..write('carbsTarget: $carbsTarget, ')
          ..write('targetWeightKg: $targetWeightKg, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightEntriesTable extends WeightEntries
    with TableInfo<$WeightEntriesTable, StoredWeightEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localDayMeta = const VerificationMeta(
    'localDay',
  );
  @override
  late final GeneratedColumn<String> localDay = GeneratedColumn<String>(
    'local_day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    localDay,
    weightKg,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredWeightEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('local_day')) {
      context.handle(
        _localDayMeta,
        localDay.isAcceptableOrUnknown(data['local_day']!, _localDayMeta),
      );
    } else if (isInserting) {
      context.missing(_localDayMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
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
  StoredWeightEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredWeightEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      localDay: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_day'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
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
  $WeightEntriesTable createAlias(String alias) {
    return $WeightEntriesTable(attachedDatabase, alias);
  }
}

class StoredWeightEntry extends DataClass
    implements Insertable<StoredWeightEntry> {
  final String id;
  final String localDay;
  final double weightKg;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredWeightEntry({
    required this.id,
    required this.localDay,
    required this.weightKg,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.deviceId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['local_day'] = Variable<String>(localDay);
    map['weight_kg'] = Variable<double>(weightKg);
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  WeightEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightEntriesCompanion(
      id: Value(id),
      localDay: Value(localDay),
      weightKg: Value(weightKg),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredWeightEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredWeightEntry(
      id: serializer.fromJson<String>(json['id']),
      localDay: serializer.fromJson<String>(json['localDay']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      source: serializer.fromJson<String>(json['source']),
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
      'localDay': serializer.toJson<String>(localDay),
      'weightKg': serializer.toJson<double>(weightKg),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredWeightEntry copyWith({
    String? id,
    String? localDay,
    double? weightKg,
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredWeightEntry(
    id: id ?? this.id,
    localDay: localDay ?? this.localDay,
    weightKg: weightKg ?? this.weightKg,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredWeightEntry copyWithCompanion(WeightEntriesCompanion data) {
    return StoredWeightEntry(
      id: data.id.present ? data.id.value : this.id,
      localDay: data.localDay.present ? data.localDay.value : this.localDay,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoredWeightEntry(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('weightKg: $weightKg, ')
          ..write('source: $source, ')
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
    localDay,
    weightKg,
    source,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredWeightEntry &&
          other.id == this.id &&
          other.localDay == this.localDay &&
          other.weightKg == this.weightKg &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class WeightEntriesCompanion extends UpdateCompanion<StoredWeightEntry> {
  final Value<String> id;
  final Value<String> localDay;
  final Value<double> weightKg;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const WeightEntriesCompanion({
    this.id = const Value.absent(),
    this.localDay = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightEntriesCompanion.insert({
    required String id,
    required String localDay,
    required double weightKg,
    required String source,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       localDay = Value(localDay),
       weightKg = Value(weightKg),
       source = Value(source),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredWeightEntry> custom({
    Expression<String>? id,
    Expression<String>? localDay,
    Expression<double>? weightKg,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (localDay != null) 'local_day': localDay,
      if (weightKg != null) 'weight_kg': weightKg,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? localDay,
    Value<double>? weightKg,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return WeightEntriesCompanion(
      id: id ?? this.id,
      localDay: localDay ?? this.localDay,
      weightKg: weightKg ?? this.weightKg,
      source: source ?? this.source,
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
    if (localDay.present) {
      map['local_day'] = Variable<String>(localDay.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
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
    return (StringBuffer('WeightEntriesCompanion(')
          ..write('id: $id, ')
          ..write('localDay: $localDay, ')
          ..write('weightKg: $weightKg, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('deviceId: $deviceId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemoteFoodsTable extends RemoteFoods
    with TableInfo<$RemoteFoodsTable, StoredRemoteFood> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemoteFoodsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceCodeMeta = const VerificationMeta(
    'sourceCode',
  );
  @override
  late final GeneratedColumn<String> sourceCode = GeneratedColumn<String>(
    'source_code',
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
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
    'brand',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
  static const VerificationMeta _lastAmountMeta = const VerificationMeta(
    'lastAmount',
  );
  @override
  late final GeneratedColumn<double> lastAmount = GeneratedColumn<double>(
    'last_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(100),
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
    source,
    sourceCode,
    name,
    brand,
    category,
    basisUnit,
    basisAmount,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    lastAmount,
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
  static const String $name = 'remote_foods';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoredRemoteFood> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('source_code')) {
      context.handle(
        _sourceCodeMeta,
        sourceCode.isAcceptableOrUnknown(data['source_code']!, _sourceCodeMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceCodeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
        _brandMeta,
        brand.isAcceptableOrUnknown(data['brand']!, _brandMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
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
    if (data.containsKey('last_amount')) {
      context.handle(
        _lastAmountMeta,
        lastAmount.isAcceptableOrUnknown(data['last_amount']!, _lastAmountMeta),
      );
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
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {source, sourceCode},
  ];
  @override
  StoredRemoteFood map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoredRemoteFood(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      sourceCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_code'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      brand: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}brand'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      basisUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}basis_unit'],
      )!,
      basisAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}basis_amount'],
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
      lastAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}last_amount'],
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
  $RemoteFoodsTable createAlias(String alias) {
    return $RemoteFoodsTable(attachedDatabase, alias);
  }
}

class StoredRemoteFood extends DataClass
    implements Insertable<StoredRemoteFood> {
  final String id;
  final String source;
  final String sourceCode;
  final String name;
  final String? brand;
  final String category;
  final String basisUnit;
  final double basisAmount;
  final double energyKcal;
  final double proteinG;
  final double fatG;
  final double carbsG;
  final double lastAmount;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String deviceId;
  const StoredRemoteFood({
    required this.id,
    required this.source,
    required this.sourceCode,
    required this.name,
    this.brand,
    required this.category,
    required this.basisUnit,
    required this.basisAmount,
    required this.energyKcal,
    required this.proteinG,
    required this.fatG,
    required this.carbsG,
    required this.lastAmount,
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
    map['source'] = Variable<String>(source);
    map['source_code'] = Variable<String>(sourceCode);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || brand != null) {
      map['brand'] = Variable<String>(brand);
    }
    map['category'] = Variable<String>(category);
    map['basis_unit'] = Variable<String>(basisUnit);
    map['basis_amount'] = Variable<double>(basisAmount);
    map['energy_kcal'] = Variable<double>(energyKcal);
    map['protein_g'] = Variable<double>(proteinG);
    map['fat_g'] = Variable<double>(fatG);
    map['carbs_g'] = Variable<double>(carbsG);
    map['last_amount'] = Variable<double>(lastAmount);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['device_id'] = Variable<String>(deviceId);
    return map;
  }

  RemoteFoodsCompanion toCompanion(bool nullToAbsent) {
    return RemoteFoodsCompanion(
      id: Value(id),
      source: Value(source),
      sourceCode: Value(sourceCode),
      name: Value(name),
      brand: brand == null && nullToAbsent
          ? const Value.absent()
          : Value(brand),
      category: Value(category),
      basisUnit: Value(basisUnit),
      basisAmount: Value(basisAmount),
      energyKcal: Value(energyKcal),
      proteinG: Value(proteinG),
      fatG: Value(fatG),
      carbsG: Value(carbsG),
      lastAmount: Value(lastAmount),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      deviceId: Value(deviceId),
    );
  }

  factory StoredRemoteFood.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoredRemoteFood(
      id: serializer.fromJson<String>(json['id']),
      source: serializer.fromJson<String>(json['source']),
      sourceCode: serializer.fromJson<String>(json['sourceCode']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String?>(json['brand']),
      category: serializer.fromJson<String>(json['category']),
      basisUnit: serializer.fromJson<String>(json['basisUnit']),
      basisAmount: serializer.fromJson<double>(json['basisAmount']),
      energyKcal: serializer.fromJson<double>(json['energyKcal']),
      proteinG: serializer.fromJson<double>(json['proteinG']),
      fatG: serializer.fromJson<double>(json['fatG']),
      carbsG: serializer.fromJson<double>(json['carbsG']),
      lastAmount: serializer.fromJson<double>(json['lastAmount']),
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
      'source': serializer.toJson<String>(source),
      'sourceCode': serializer.toJson<String>(sourceCode),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String?>(brand),
      'category': serializer.toJson<String>(category),
      'basisUnit': serializer.toJson<String>(basisUnit),
      'basisAmount': serializer.toJson<double>(basisAmount),
      'energyKcal': serializer.toJson<double>(energyKcal),
      'proteinG': serializer.toJson<double>(proteinG),
      'fatG': serializer.toJson<double>(fatG),
      'carbsG': serializer.toJson<double>(carbsG),
      'lastAmount': serializer.toJson<double>(lastAmount),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'deviceId': serializer.toJson<String>(deviceId),
    };
  }

  StoredRemoteFood copyWith({
    String? id,
    String? source,
    String? sourceCode,
    String? name,
    Value<String?> brand = const Value.absent(),
    String? category,
    String? basisUnit,
    double? basisAmount,
    double? energyKcal,
    double? proteinG,
    double? fatG,
    double? carbsG,
    double? lastAmount,
    bool? isFavorite,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? deviceId,
  }) => StoredRemoteFood(
    id: id ?? this.id,
    source: source ?? this.source,
    sourceCode: sourceCode ?? this.sourceCode,
    name: name ?? this.name,
    brand: brand.present ? brand.value : this.brand,
    category: category ?? this.category,
    basisUnit: basisUnit ?? this.basisUnit,
    basisAmount: basisAmount ?? this.basisAmount,
    energyKcal: energyKcal ?? this.energyKcal,
    proteinG: proteinG ?? this.proteinG,
    fatG: fatG ?? this.fatG,
    carbsG: carbsG ?? this.carbsG,
    lastAmount: lastAmount ?? this.lastAmount,
    isFavorite: isFavorite ?? this.isFavorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    deviceId: deviceId ?? this.deviceId,
  );
  StoredRemoteFood copyWithCompanion(RemoteFoodsCompanion data) {
    return StoredRemoteFood(
      id: data.id.present ? data.id.value : this.id,
      source: data.source.present ? data.source.value : this.source,
      sourceCode: data.sourceCode.present
          ? data.sourceCode.value
          : this.sourceCode,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      basisUnit: data.basisUnit.present ? data.basisUnit.value : this.basisUnit,
      basisAmount: data.basisAmount.present
          ? data.basisAmount.value
          : this.basisAmount,
      energyKcal: data.energyKcal.present
          ? data.energyKcal.value
          : this.energyKcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      fatG: data.fatG.present ? data.fatG.value : this.fatG,
      carbsG: data.carbsG.present ? data.carbsG.value : this.carbsG,
      lastAmount: data.lastAmount.present
          ? data.lastAmount.value
          : this.lastAmount,
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
    return (StringBuffer('StoredRemoteFood(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('basisUnit: $basisUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('lastAmount: $lastAmount, ')
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
    source,
    sourceCode,
    name,
    brand,
    category,
    basisUnit,
    basisAmount,
    energyKcal,
    proteinG,
    fatG,
    carbsG,
    lastAmount,
    isFavorite,
    createdAt,
    updatedAt,
    deletedAt,
    deviceId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoredRemoteFood &&
          other.id == this.id &&
          other.source == this.source &&
          other.sourceCode == this.sourceCode &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.basisUnit == this.basisUnit &&
          other.basisAmount == this.basisAmount &&
          other.energyKcal == this.energyKcal &&
          other.proteinG == this.proteinG &&
          other.fatG == this.fatG &&
          other.carbsG == this.carbsG &&
          other.lastAmount == this.lastAmount &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.deviceId == this.deviceId);
}

class RemoteFoodsCompanion extends UpdateCompanion<StoredRemoteFood> {
  final Value<String> id;
  final Value<String> source;
  final Value<String> sourceCode;
  final Value<String> name;
  final Value<String?> brand;
  final Value<String> category;
  final Value<String> basisUnit;
  final Value<double> basisAmount;
  final Value<double> energyKcal;
  final Value<double> proteinG;
  final Value<double> fatG;
  final Value<double> carbsG;
  final Value<double> lastAmount;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> deviceId;
  final Value<int> rowid;
  const RemoteFoodsCompanion({
    this.id = const Value.absent(),
    this.source = const Value.absent(),
    this.sourceCode = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.basisUnit = const Value.absent(),
    this.basisAmount = const Value.absent(),
    this.energyKcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.fatG = const Value.absent(),
    this.carbsG = const Value.absent(),
    this.lastAmount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemoteFoodsCompanion.insert({
    required String id,
    required String source,
    required String sourceCode,
    required String name,
    this.brand = const Value.absent(),
    required String category,
    required String basisUnit,
    required double basisAmount,
    required double energyKcal,
    required double proteinG,
    required double fatG,
    required double carbsG,
    this.lastAmount = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String deviceId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       source = Value(source),
       sourceCode = Value(sourceCode),
       name = Value(name),
       category = Value(category),
       basisUnit = Value(basisUnit),
       basisAmount = Value(basisAmount),
       energyKcal = Value(energyKcal),
       proteinG = Value(proteinG),
       fatG = Value(fatG),
       carbsG = Value(carbsG),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       deviceId = Value(deviceId);
  static Insertable<StoredRemoteFood> custom({
    Expression<String>? id,
    Expression<String>? source,
    Expression<String>? sourceCode,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? basisUnit,
    Expression<double>? basisAmount,
    Expression<double>? energyKcal,
    Expression<double>? proteinG,
    Expression<double>? fatG,
    Expression<double>? carbsG,
    Expression<double>? lastAmount,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? deviceId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (source != null) 'source': source,
      if (sourceCode != null) 'source_code': sourceCode,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (basisUnit != null) 'basis_unit': basisUnit,
      if (basisAmount != null) 'basis_amount': basisAmount,
      if (energyKcal != null) 'energy_kcal': energyKcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (fatG != null) 'fat_g': fatG,
      if (carbsG != null) 'carbs_g': carbsG,
      if (lastAmount != null) 'last_amount': lastAmount,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (deviceId != null) 'device_id': deviceId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemoteFoodsCompanion copyWith({
    Value<String>? id,
    Value<String>? source,
    Value<String>? sourceCode,
    Value<String>? name,
    Value<String?>? brand,
    Value<String>? category,
    Value<String>? basisUnit,
    Value<double>? basisAmount,
    Value<double>? energyKcal,
    Value<double>? proteinG,
    Value<double>? fatG,
    Value<double>? carbsG,
    Value<double>? lastAmount,
    Value<bool>? isFavorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? deviceId,
    Value<int>? rowid,
  }) {
    return RemoteFoodsCompanion(
      id: id ?? this.id,
      source: source ?? this.source,
      sourceCode: sourceCode ?? this.sourceCode,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      basisUnit: basisUnit ?? this.basisUnit,
      basisAmount: basisAmount ?? this.basisAmount,
      energyKcal: energyKcal ?? this.energyKcal,
      proteinG: proteinG ?? this.proteinG,
      fatG: fatG ?? this.fatG,
      carbsG: carbsG ?? this.carbsG,
      lastAmount: lastAmount ?? this.lastAmount,
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
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (sourceCode.present) {
      map['source_code'] = Variable<String>(sourceCode.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (basisUnit.present) {
      map['basis_unit'] = Variable<String>(basisUnit.value);
    }
    if (basisAmount.present) {
      map['basis_amount'] = Variable<double>(basisAmount.value);
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
    if (lastAmount.present) {
      map['last_amount'] = Variable<double>(lastAmount.value);
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
    return (StringBuffer('RemoteFoodsCompanion(')
          ..write('id: $id, ')
          ..write('source: $source, ')
          ..write('sourceCode: $sourceCode, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('basisUnit: $basisUnit, ')
          ..write('basisAmount: $basisAmount, ')
          ..write('energyKcal: $energyKcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('fatG: $fatG, ')
          ..write('carbsG: $carbsG, ')
          ..write('lastAmount: $lastAmount, ')
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

abstract class _$YamDatabase extends GeneratedDatabase {
  _$YamDatabase(QueryExecutor e) : super(e);
  $YamDatabaseManager get managers => $YamDatabaseManager(this);
  late final $UserFoodsTable userFoods = $UserFoodsTable(this);
  late final $UserServingsTable userServings = $UserServingsTable(this);
  late final $InstallationValuesTable installationValues =
      $InstallationValuesTable(this);
  late final $DiaryEntriesTable diaryEntries = $DiaryEntriesTable(this);
  late final $GoalVersionsTable goalVersions = $GoalVersionsTable(this);
  late final $WeightEntriesTable weightEntries = $WeightEntriesTable(this);
  late final $RemoteFoodsTable remoteFoods = $RemoteFoodsTable(this);
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
  late final Index diaryEntriesDay = Index(
    'diary_entries_day',
    'CREATE INDEX diary_entries_day ON diary_entries (diary_day, deleted_at, meal_id)',
  );
  late final Index diaryEntriesRecent = Index(
    'diary_entries_recent',
    'CREATE INDEX diary_entries_recent ON diary_entries (deleted_at, created_at)',
  );
  late final Index goalVersionsDay = Index(
    'goal_versions_day',
    'CREATE INDEX goal_versions_day ON goal_versions (effective_day, deleted_at, created_at)',
  );
  late final Index weightEntriesDay = Index(
    'weight_entries_day',
    'CREATE INDEX weight_entries_day ON weight_entries (local_day, deleted_at, created_at)',
  );
  late final Index remoteFoodsName = Index(
    'remote_foods_name',
    'CREATE INDEX remote_foods_name ON remote_foods (name)',
  );
  late final Index remoteFoodsFavorites = Index(
    'remote_foods_favorites',
    'CREATE INDEX remote_foods_favorites ON remote_foods (is_favorite, deleted_at)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    userFoods,
    userServings,
    installationValues,
    diaryEntries,
    goalVersions,
    weightEntries,
    remoteFoods,
    userFoodsHistory,
    userFoodsName,
    userServingsFood,
    diaryEntriesDay,
    diaryEntriesRecent,
    goalVersionsDay,
    weightEntriesDay,
    remoteFoodsName,
    remoteFoodsFavorites,
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
    extends BaseReferences<_$YamDatabase, $UserFoodsTable, StoredUserFood> {
  $$UserFoodsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$UserServingsTable, List<StoredUserServing>>
  _userServingsRefsTable(_$YamDatabase db) => MultiTypedResultKey.fromTable(
    db.userServings,
    aliasName: $_aliasNameGenerator(db.userFoods.id, db.userServings.foodId),
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
    extends Composer<_$YamDatabase, $UserFoodsTable> {
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
    extends Composer<_$YamDatabase, $UserFoodsTable> {
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
    extends Composer<_$YamDatabase, $UserFoodsTable> {
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
          _$YamDatabase,
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
  $$UserFoodsTableTableManager(_$YamDatabase db, $UserFoodsTable table)
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
      _$YamDatabase,
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
        BaseReferences<_$YamDatabase, $UserServingsTable, StoredUserServing> {
  $$UserServingsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserFoodsTable _foodIdTable(_$YamDatabase db) =>
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
    extends Composer<_$YamDatabase, $UserServingsTable> {
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
    extends Composer<_$YamDatabase, $UserServingsTable> {
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
    extends Composer<_$YamDatabase, $UserServingsTable> {
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
          _$YamDatabase,
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
  $$UserServingsTableTableManager(_$YamDatabase db, $UserServingsTable table)
    : super(
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
      _$YamDatabase,
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
    extends Composer<_$YamDatabase, $InstallationValuesTable> {
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
    extends Composer<_$YamDatabase, $InstallationValuesTable> {
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
    extends Composer<_$YamDatabase, $InstallationValuesTable> {
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
          _$YamDatabase,
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
              _$YamDatabase,
              $InstallationValuesTable,
              InstallationValue
            >,
          ),
          InstallationValue,
          PrefetchHooks Function()
        > {
  $$InstallationValuesTableTableManager(
    _$YamDatabase db,
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
      _$YamDatabase,
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
          _$YamDatabase,
          $InstallationValuesTable,
          InstallationValue
        >,
      ),
      InstallationValue,
      PrefetchHooks Function()
    >;
typedef $$DiaryEntriesTableCreateCompanionBuilder =
    DiaryEntriesCompanion Function({
      required String id,
      required String diaryDay,
      required String mealId,
      required String foodId,
      required String foodName,
      Value<String?> brand,
      required String baseUnit,
      required double basisAmount,
      required double kcalPerBasis,
      required double proteinPerBasis,
      required double fatPerBasis,
      required double carbsPerBasis,
      required String servingsSnapshot,
      required String servingId,
      required double amount,
      required double canonicalQuantity,
      required double energyKcal,
      required double proteinG,
      required double fatG,
      required double carbsG,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$DiaryEntriesTableUpdateCompanionBuilder =
    DiaryEntriesCompanion Function({
      Value<String> id,
      Value<String> diaryDay,
      Value<String> mealId,
      Value<String> foodId,
      Value<String> foodName,
      Value<String?> brand,
      Value<String> baseUnit,
      Value<double> basisAmount,
      Value<double> kcalPerBasis,
      Value<double> proteinPerBasis,
      Value<double> fatPerBasis,
      Value<double> carbsPerBasis,
      Value<String> servingsSnapshot,
      Value<String> servingId,
      Value<double> amount,
      Value<double> canonicalQuantity,
      Value<double> energyKcal,
      Value<double> proteinG,
      Value<double> fatG,
      Value<double> carbsG,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$DiaryEntriesTableFilterComposer
    extends Composer<_$YamDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableFilterComposer({
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

  ColumnFilters<String> get diaryDay => $composableBuilder(
    column: $table.diaryDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get kcalPerBasis => $composableBuilder(
    column: $table.kcalPerBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get proteinPerBasis => $composableBuilder(
    column: $table.proteinPerBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fatPerBasis => $composableBuilder(
    column: $table.fatPerBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get carbsPerBasis => $composableBuilder(
    column: $table.carbsPerBasis,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingsSnapshot => $composableBuilder(
    column: $table.servingsSnapshot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get canonicalQuantity => $composableBuilder(
    column: $table.canonicalQuantity,
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
}

class $$DiaryEntriesTableOrderingComposer
    extends Composer<_$YamDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get diaryDay => $composableBuilder(
    column: $table.diaryDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mealId => $composableBuilder(
    column: $table.mealId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodId => $composableBuilder(
    column: $table.foodId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get foodName => $composableBuilder(
    column: $table.foodName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get baseUnit => $composableBuilder(
    column: $table.baseUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get kcalPerBasis => $composableBuilder(
    column: $table.kcalPerBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get proteinPerBasis => $composableBuilder(
    column: $table.proteinPerBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fatPerBasis => $composableBuilder(
    column: $table.fatPerBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get carbsPerBasis => $composableBuilder(
    column: $table.carbsPerBasis,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingsSnapshot => $composableBuilder(
    column: $table.servingsSnapshot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get servingId => $composableBuilder(
    column: $table.servingId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get canonicalQuantity => $composableBuilder(
    column: $table.canonicalQuantity,
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

class $$DiaryEntriesTableAnnotationComposer
    extends Composer<_$YamDatabase, $DiaryEntriesTable> {
  $$DiaryEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get diaryDay =>
      $composableBuilder(column: $table.diaryDay, builder: (column) => column);

  GeneratedColumn<String> get mealId =>
      $composableBuilder(column: $table.mealId, builder: (column) => column);

  GeneratedColumn<String> get foodId =>
      $composableBuilder(column: $table.foodId, builder: (column) => column);

  GeneratedColumn<String> get foodName =>
      $composableBuilder(column: $table.foodName, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get kcalPerBasis => $composableBuilder(
    column: $table.kcalPerBasis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get proteinPerBasis => $composableBuilder(
    column: $table.proteinPerBasis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fatPerBasis => $composableBuilder(
    column: $table.fatPerBasis,
    builder: (column) => column,
  );

  GeneratedColumn<double> get carbsPerBasis => $composableBuilder(
    column: $table.carbsPerBasis,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingsSnapshot => $composableBuilder(
    column: $table.servingsSnapshot,
    builder: (column) => column,
  );

  GeneratedColumn<String> get servingId =>
      $composableBuilder(column: $table.servingId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get canonicalQuantity => $composableBuilder(
    column: $table.canonicalQuantity,
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$DiaryEntriesTableTableManager
    extends
        RootTableManager<
          _$YamDatabase,
          $DiaryEntriesTable,
          StoredDiaryEntry,
          $$DiaryEntriesTableFilterComposer,
          $$DiaryEntriesTableOrderingComposer,
          $$DiaryEntriesTableAnnotationComposer,
          $$DiaryEntriesTableCreateCompanionBuilder,
          $$DiaryEntriesTableUpdateCompanionBuilder,
          (
            StoredDiaryEntry,
            BaseReferences<_$YamDatabase, $DiaryEntriesTable, StoredDiaryEntry>,
          ),
          StoredDiaryEntry,
          PrefetchHooks Function()
        > {
  $$DiaryEntriesTableTableManager(_$YamDatabase db, $DiaryEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiaryEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiaryEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiaryEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> diaryDay = const Value.absent(),
                Value<String> mealId = const Value.absent(),
                Value<String> foodId = const Value.absent(),
                Value<String> foodName = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> baseUnit = const Value.absent(),
                Value<double> basisAmount = const Value.absent(),
                Value<double> kcalPerBasis = const Value.absent(),
                Value<double> proteinPerBasis = const Value.absent(),
                Value<double> fatPerBasis = const Value.absent(),
                Value<double> carbsPerBasis = const Value.absent(),
                Value<String> servingsSnapshot = const Value.absent(),
                Value<String> servingId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<double> canonicalQuantity = const Value.absent(),
                Value<double> energyKcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiaryEntriesCompanion(
                id: id,
                diaryDay: diaryDay,
                mealId: mealId,
                foodId: foodId,
                foodName: foodName,
                brand: brand,
                baseUnit: baseUnit,
                basisAmount: basisAmount,
                kcalPerBasis: kcalPerBasis,
                proteinPerBasis: proteinPerBasis,
                fatPerBasis: fatPerBasis,
                carbsPerBasis: carbsPerBasis,
                servingsSnapshot: servingsSnapshot,
                servingId: servingId,
                amount: amount,
                canonicalQuantity: canonicalQuantity,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String diaryDay,
                required String mealId,
                required String foodId,
                required String foodName,
                Value<String?> brand = const Value.absent(),
                required String baseUnit,
                required double basisAmount,
                required double kcalPerBasis,
                required double proteinPerBasis,
                required double fatPerBasis,
                required double carbsPerBasis,
                required String servingsSnapshot,
                required String servingId,
                required double amount,
                required double canonicalQuantity,
                required double energyKcal,
                required double proteinG,
                required double fatG,
                required double carbsG,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => DiaryEntriesCompanion.insert(
                id: id,
                diaryDay: diaryDay,
                mealId: mealId,
                foodId: foodId,
                foodName: foodName,
                brand: brand,
                baseUnit: baseUnit,
                basisAmount: basisAmount,
                kcalPerBasis: kcalPerBasis,
                proteinPerBasis: proteinPerBasis,
                fatPerBasis: fatPerBasis,
                carbsPerBasis: carbsPerBasis,
                servingsSnapshot: servingsSnapshot,
                servingId: servingId,
                amount: amount,
                canonicalQuantity: canonicalQuantity,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiaryEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$YamDatabase,
      $DiaryEntriesTable,
      StoredDiaryEntry,
      $$DiaryEntriesTableFilterComposer,
      $$DiaryEntriesTableOrderingComposer,
      $$DiaryEntriesTableAnnotationComposer,
      $$DiaryEntriesTableCreateCompanionBuilder,
      $$DiaryEntriesTableUpdateCompanionBuilder,
      (
        StoredDiaryEntry,
        BaseReferences<_$YamDatabase, $DiaryEntriesTable, StoredDiaryEntry>,
      ),
      StoredDiaryEntry,
      PrefetchHooks Function()
    >;
typedef $$GoalVersionsTableCreateCompanionBuilder =
    GoalVersionsCompanion Function({
      required String id,
      required String effectiveDay,
      required String goal,
      required int calorieTarget,
      required int proteinTarget,
      required int fatTarget,
      required int carbsTarget,
      required double targetWeightKg,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$GoalVersionsTableUpdateCompanionBuilder =
    GoalVersionsCompanion Function({
      Value<String> id,
      Value<String> effectiveDay,
      Value<String> goal,
      Value<int> calorieTarget,
      Value<int> proteinTarget,
      Value<int> fatTarget,
      Value<int> carbsTarget,
      Value<double> targetWeightKg,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$GoalVersionsTableFilterComposer
    extends Composer<_$YamDatabase, $GoalVersionsTable> {
  $$GoalVersionsTableFilterComposer({
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

  ColumnFilters<String> get effectiveDay => $composableBuilder(
    column: $table.effectiveDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proteinTarget => $composableBuilder(
    column: $table.proteinTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fatTarget => $composableBuilder(
    column: $table.fatTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get carbsTarget => $composableBuilder(
    column: $table.carbsTarget,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
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
}

class $$GoalVersionsTableOrderingComposer
    extends Composer<_$YamDatabase, $GoalVersionsTable> {
  $$GoalVersionsTableOrderingComposer({
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

  ColumnOrderings<String> get effectiveDay => $composableBuilder(
    column: $table.effectiveDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goal => $composableBuilder(
    column: $table.goal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proteinTarget => $composableBuilder(
    column: $table.proteinTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fatTarget => $composableBuilder(
    column: $table.fatTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get carbsTarget => $composableBuilder(
    column: $table.carbsTarget,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
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

class $$GoalVersionsTableAnnotationComposer
    extends Composer<_$YamDatabase, $GoalVersionsTable> {
  $$GoalVersionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get effectiveDay => $composableBuilder(
    column: $table.effectiveDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get goal =>
      $composableBuilder(column: $table.goal, builder: (column) => column);

  GeneratedColumn<int> get calorieTarget => $composableBuilder(
    column: $table.calorieTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proteinTarget => $composableBuilder(
    column: $table.proteinTarget,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fatTarget =>
      $composableBuilder(column: $table.fatTarget, builder: (column) => column);

  GeneratedColumn<int> get carbsTarget => $composableBuilder(
    column: $table.carbsTarget,
    builder: (column) => column,
  );

  GeneratedColumn<double> get targetWeightKg => $composableBuilder(
    column: $table.targetWeightKg,
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
}

class $$GoalVersionsTableTableManager
    extends
        RootTableManager<
          _$YamDatabase,
          $GoalVersionsTable,
          StoredGoalVersion,
          $$GoalVersionsTableFilterComposer,
          $$GoalVersionsTableOrderingComposer,
          $$GoalVersionsTableAnnotationComposer,
          $$GoalVersionsTableCreateCompanionBuilder,
          $$GoalVersionsTableUpdateCompanionBuilder,
          (
            StoredGoalVersion,
            BaseReferences<
              _$YamDatabase,
              $GoalVersionsTable,
              StoredGoalVersion
            >,
          ),
          StoredGoalVersion,
          PrefetchHooks Function()
        > {
  $$GoalVersionsTableTableManager(_$YamDatabase db, $GoalVersionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalVersionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalVersionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalVersionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> effectiveDay = const Value.absent(),
                Value<String> goal = const Value.absent(),
                Value<int> calorieTarget = const Value.absent(),
                Value<int> proteinTarget = const Value.absent(),
                Value<int> fatTarget = const Value.absent(),
                Value<int> carbsTarget = const Value.absent(),
                Value<double> targetWeightKg = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalVersionsCompanion(
                id: id,
                effectiveDay: effectiveDay,
                goal: goal,
                calorieTarget: calorieTarget,
                proteinTarget: proteinTarget,
                fatTarget: fatTarget,
                carbsTarget: carbsTarget,
                targetWeightKg: targetWeightKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String effectiveDay,
                required String goal,
                required int calorieTarget,
                required int proteinTarget,
                required int fatTarget,
                required int carbsTarget,
                required double targetWeightKg,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => GoalVersionsCompanion.insert(
                id: id,
                effectiveDay: effectiveDay,
                goal: goal,
                calorieTarget: calorieTarget,
                proteinTarget: proteinTarget,
                fatTarget: fatTarget,
                carbsTarget: carbsTarget,
                targetWeightKg: targetWeightKg,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalVersionsTableProcessedTableManager =
    ProcessedTableManager<
      _$YamDatabase,
      $GoalVersionsTable,
      StoredGoalVersion,
      $$GoalVersionsTableFilterComposer,
      $$GoalVersionsTableOrderingComposer,
      $$GoalVersionsTableAnnotationComposer,
      $$GoalVersionsTableCreateCompanionBuilder,
      $$GoalVersionsTableUpdateCompanionBuilder,
      (
        StoredGoalVersion,
        BaseReferences<_$YamDatabase, $GoalVersionsTable, StoredGoalVersion>,
      ),
      StoredGoalVersion,
      PrefetchHooks Function()
    >;
typedef $$WeightEntriesTableCreateCompanionBuilder =
    WeightEntriesCompanion Function({
      required String id,
      required String localDay,
      required double weightKg,
      required String source,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$WeightEntriesTableUpdateCompanionBuilder =
    WeightEntriesCompanion Function({
      Value<String> id,
      Value<String> localDay,
      Value<double> weightKg,
      Value<String> source,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$WeightEntriesTableFilterComposer
    extends Composer<_$YamDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableFilterComposer({
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

  ColumnFilters<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
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
}

class $$WeightEntriesTableOrderingComposer
    extends Composer<_$YamDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableOrderingComposer({
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

  ColumnOrderings<String> get localDay => $composableBuilder(
    column: $table.localDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
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

class $$WeightEntriesTableAnnotationComposer
    extends Composer<_$YamDatabase, $WeightEntriesTable> {
  $$WeightEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get localDay =>
      $composableBuilder(column: $table.localDay, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);
}

class $$WeightEntriesTableTableManager
    extends
        RootTableManager<
          _$YamDatabase,
          $WeightEntriesTable,
          StoredWeightEntry,
          $$WeightEntriesTableFilterComposer,
          $$WeightEntriesTableOrderingComposer,
          $$WeightEntriesTableAnnotationComposer,
          $$WeightEntriesTableCreateCompanionBuilder,
          $$WeightEntriesTableUpdateCompanionBuilder,
          (
            StoredWeightEntry,
            BaseReferences<
              _$YamDatabase,
              $WeightEntriesTable,
              StoredWeightEntry
            >,
          ),
          StoredWeightEntry,
          PrefetchHooks Function()
        > {
  $$WeightEntriesTableTableManager(_$YamDatabase db, $WeightEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> localDay = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion(
                id: id,
                localDay: localDay,
                weightKg: weightKg,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String localDay,
                required double weightKg,
                required String source,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => WeightEntriesCompanion.insert(
                id: id,
                localDay: localDay,
                weightKg: weightKg,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeightEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$YamDatabase,
      $WeightEntriesTable,
      StoredWeightEntry,
      $$WeightEntriesTableFilterComposer,
      $$WeightEntriesTableOrderingComposer,
      $$WeightEntriesTableAnnotationComposer,
      $$WeightEntriesTableCreateCompanionBuilder,
      $$WeightEntriesTableUpdateCompanionBuilder,
      (
        StoredWeightEntry,
        BaseReferences<_$YamDatabase, $WeightEntriesTable, StoredWeightEntry>,
      ),
      StoredWeightEntry,
      PrefetchHooks Function()
    >;
typedef $$RemoteFoodsTableCreateCompanionBuilder =
    RemoteFoodsCompanion Function({
      required String id,
      required String source,
      required String sourceCode,
      required String name,
      Value<String?> brand,
      required String category,
      required String basisUnit,
      required double basisAmount,
      required double energyKcal,
      required double proteinG,
      required double fatG,
      required double carbsG,
      Value<double> lastAmount,
      Value<bool> isFavorite,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String deviceId,
      Value<int> rowid,
    });
typedef $$RemoteFoodsTableUpdateCompanionBuilder =
    RemoteFoodsCompanion Function({
      Value<String> id,
      Value<String> source,
      Value<String> sourceCode,
      Value<String> name,
      Value<String?> brand,
      Value<String> category,
      Value<String> basisUnit,
      Value<double> basisAmount,
      Value<double> energyKcal,
      Value<double> proteinG,
      Value<double> fatG,
      Value<double> carbsG,
      Value<double> lastAmount,
      Value<bool> isFavorite,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> deviceId,
      Value<int> rowid,
    });

class $$RemoteFoodsTableFilterComposer
    extends Composer<_$YamDatabase, $RemoteFoodsTable> {
  $$RemoteFoodsTableFilterComposer({
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

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
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

  ColumnFilters<double> get lastAmount => $composableBuilder(
    column: $table.lastAmount,
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
}

class $$RemoteFoodsTableOrderingComposer
    extends Composer<_$YamDatabase, $RemoteFoodsTable> {
  $$RemoteFoodsTableOrderingComposer({
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

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get brand => $composableBuilder(
    column: $table.brand,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
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

  ColumnOrderings<double> get lastAmount => $composableBuilder(
    column: $table.lastAmount,
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

class $$RemoteFoodsTableAnnotationComposer
    extends Composer<_$YamDatabase, $RemoteFoodsTable> {
  $$RemoteFoodsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get sourceCode => $composableBuilder(
    column: $table.sourceCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get basisUnit =>
      $composableBuilder(column: $table.basisUnit, builder: (column) => column);

  GeneratedColumn<double> get basisAmount => $composableBuilder(
    column: $table.basisAmount,
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

  GeneratedColumn<double> get lastAmount => $composableBuilder(
    column: $table.lastAmount,
    builder: (column) => column,
  );

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
}

class $$RemoteFoodsTableTableManager
    extends
        RootTableManager<
          _$YamDatabase,
          $RemoteFoodsTable,
          StoredRemoteFood,
          $$RemoteFoodsTableFilterComposer,
          $$RemoteFoodsTableOrderingComposer,
          $$RemoteFoodsTableAnnotationComposer,
          $$RemoteFoodsTableCreateCompanionBuilder,
          $$RemoteFoodsTableUpdateCompanionBuilder,
          (
            StoredRemoteFood,
            BaseReferences<_$YamDatabase, $RemoteFoodsTable, StoredRemoteFood>,
          ),
          StoredRemoteFood,
          PrefetchHooks Function()
        > {
  $$RemoteFoodsTableTableManager(_$YamDatabase db, $RemoteFoodsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemoteFoodsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemoteFoodsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemoteFoodsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<String> sourceCode = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> brand = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> basisUnit = const Value.absent(),
                Value<double> basisAmount = const Value.absent(),
                Value<double> energyKcal = const Value.absent(),
                Value<double> proteinG = const Value.absent(),
                Value<double> fatG = const Value.absent(),
                Value<double> carbsG = const Value.absent(),
                Value<double> lastAmount = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemoteFoodsCompanion(
                id: id,
                source: source,
                sourceCode: sourceCode,
                name: name,
                brand: brand,
                category: category,
                basisUnit: basisUnit,
                basisAmount: basisAmount,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                lastAmount: lastAmount,
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
                required String source,
                required String sourceCode,
                required String name,
                Value<String?> brand = const Value.absent(),
                required String category,
                required String basisUnit,
                required double basisAmount,
                required double energyKcal,
                required double proteinG,
                required double fatG,
                required double carbsG,
                Value<double> lastAmount = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String deviceId,
                Value<int> rowid = const Value.absent(),
              }) => RemoteFoodsCompanion.insert(
                id: id,
                source: source,
                sourceCode: sourceCode,
                name: name,
                brand: brand,
                category: category,
                basisUnit: basisUnit,
                basisAmount: basisAmount,
                energyKcal: energyKcal,
                proteinG: proteinG,
                fatG: fatG,
                carbsG: carbsG,
                lastAmount: lastAmount,
                isFavorite: isFavorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                deviceId: deviceId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemoteFoodsTableProcessedTableManager =
    ProcessedTableManager<
      _$YamDatabase,
      $RemoteFoodsTable,
      StoredRemoteFood,
      $$RemoteFoodsTableFilterComposer,
      $$RemoteFoodsTableOrderingComposer,
      $$RemoteFoodsTableAnnotationComposer,
      $$RemoteFoodsTableCreateCompanionBuilder,
      $$RemoteFoodsTableUpdateCompanionBuilder,
      (
        StoredRemoteFood,
        BaseReferences<_$YamDatabase, $RemoteFoodsTable, StoredRemoteFood>,
      ),
      StoredRemoteFood,
      PrefetchHooks Function()
    >;

class $YamDatabaseManager {
  final _$YamDatabase _db;
  $YamDatabaseManager(this._db);
  $$UserFoodsTableTableManager get userFoods =>
      $$UserFoodsTableTableManager(_db, _db.userFoods);
  $$UserServingsTableTableManager get userServings =>
      $$UserServingsTableTableManager(_db, _db.userServings);
  $$InstallationValuesTableTableManager get installationValues =>
      $$InstallationValuesTableTableManager(_db, _db.installationValues);
  $$DiaryEntriesTableTableManager get diaryEntries =>
      $$DiaryEntriesTableTableManager(_db, _db.diaryEntries);
  $$GoalVersionsTableTableManager get goalVersions =>
      $$GoalVersionsTableTableManager(_db, _db.goalVersions);
  $$WeightEntriesTableTableManager get weightEntries =>
      $$WeightEntriesTableTableManager(_db, _db.weightEntries);
  $$RemoteFoodsTableTableManager get remoteFoods =>
      $$RemoteFoodsTableTableManager(_db, _db.remoteFoods);
}
