// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SavedSessionsTable extends SavedSessions
    with TableInfo<$SavedSessionsTable, SavedSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavedSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checksumMeta = const VerificationMeta(
    'checksum',
  );
  @override
  late final GeneratedColumn<String> checksum = GeneratedColumn<String>(
    'checksum',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousPayloadMeta = const VerificationMeta(
    'previousPayload',
  );
  @override
  late final GeneratedColumn<String> previousPayload = GeneratedColumn<String>(
    'previous_payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _previousChecksumMeta = const VerificationMeta(
    'previousChecksum',
  );
  @override
  late final GeneratedColumn<String> previousChecksum = GeneratedColumn<String>(
    'previous_checksum',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    slot,
    levelId,
    mode,
    payload,
    checksum,
    previousPayload,
    previousChecksum,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saved_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavedSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('checksum')) {
      context.handle(
        _checksumMeta,
        checksum.isAcceptableOrUnknown(data['checksum']!, _checksumMeta),
      );
    } else if (isInserting) {
      context.missing(_checksumMeta);
    }
    if (data.containsKey('previous_payload')) {
      context.handle(
        _previousPayloadMeta,
        previousPayload.isAcceptableOrUnknown(
          data['previous_payload']!,
          _previousPayloadMeta,
        ),
      );
    }
    if (data.containsKey('previous_checksum')) {
      context.handle(
        _previousChecksumMeta,
        previousChecksum.isAcceptableOrUnknown(
          data['previous_checksum']!,
          _previousChecksumMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  SavedSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavedSession(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      checksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}checksum'],
      )!,
      previousPayload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_payload'],
      ),
      previousChecksum: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_checksum'],
      ),
    );
  }

  @override
  $SavedSessionsTable createAlias(String alias) {
    return $SavedSessionsTable(attachedDatabase, alias);
  }
}

class SavedSession extends DataClass implements Insertable<SavedSession> {
  final String slot;
  final String levelId;
  final String mode;
  final String payload;
  final String checksum;
  final String? previousPayload;
  final String? previousChecksum;
  const SavedSession({
    required this.slot,
    required this.levelId,
    required this.mode,
    required this.payload,
    required this.checksum,
    this.previousPayload,
    this.previousChecksum,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<String>(slot);
    map['level_id'] = Variable<String>(levelId);
    map['mode'] = Variable<String>(mode);
    map['payload'] = Variable<String>(payload);
    map['checksum'] = Variable<String>(checksum);
    if (!nullToAbsent || previousPayload != null) {
      map['previous_payload'] = Variable<String>(previousPayload);
    }
    if (!nullToAbsent || previousChecksum != null) {
      map['previous_checksum'] = Variable<String>(previousChecksum);
    }
    return map;
  }

  SavedSessionsCompanion toCompanion(bool nullToAbsent) {
    return SavedSessionsCompanion(
      slot: Value(slot),
      levelId: Value(levelId),
      mode: Value(mode),
      payload: Value(payload),
      checksum: Value(checksum),
      previousPayload: previousPayload == null && nullToAbsent
          ? const Value.absent()
          : Value(previousPayload),
      previousChecksum: previousChecksum == null && nullToAbsent
          ? const Value.absent()
          : Value(previousChecksum),
    );
  }

  factory SavedSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavedSession(
      slot: serializer.fromJson<String>(json['slot']),
      levelId: serializer.fromJson<String>(json['levelId']),
      mode: serializer.fromJson<String>(json['mode']),
      payload: serializer.fromJson<String>(json['payload']),
      checksum: serializer.fromJson<String>(json['checksum']),
      previousPayload: serializer.fromJson<String?>(json['previousPayload']),
      previousChecksum: serializer.fromJson<String?>(json['previousChecksum']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<String>(slot),
      'levelId': serializer.toJson<String>(levelId),
      'mode': serializer.toJson<String>(mode),
      'payload': serializer.toJson<String>(payload),
      'checksum': serializer.toJson<String>(checksum),
      'previousPayload': serializer.toJson<String?>(previousPayload),
      'previousChecksum': serializer.toJson<String?>(previousChecksum),
    };
  }

  SavedSession copyWith({
    String? slot,
    String? levelId,
    String? mode,
    String? payload,
    String? checksum,
    Value<String?> previousPayload = const Value.absent(),
    Value<String?> previousChecksum = const Value.absent(),
  }) => SavedSession(
    slot: slot ?? this.slot,
    levelId: levelId ?? this.levelId,
    mode: mode ?? this.mode,
    payload: payload ?? this.payload,
    checksum: checksum ?? this.checksum,
    previousPayload: previousPayload.present
        ? previousPayload.value
        : this.previousPayload,
    previousChecksum: previousChecksum.present
        ? previousChecksum.value
        : this.previousChecksum,
  );
  SavedSession copyWithCompanion(SavedSessionsCompanion data) {
    return SavedSession(
      slot: data.slot.present ? data.slot.value : this.slot,
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      mode: data.mode.present ? data.mode.value : this.mode,
      payload: data.payload.present ? data.payload.value : this.payload,
      checksum: data.checksum.present ? data.checksum.value : this.checksum,
      previousPayload: data.previousPayload.present
          ? data.previousPayload.value
          : this.previousPayload,
      previousChecksum: data.previousChecksum.present
          ? data.previousChecksum.value
          : this.previousChecksum,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavedSession(')
          ..write('slot: $slot, ')
          ..write('levelId: $levelId, ')
          ..write('mode: $mode, ')
          ..write('payload: $payload, ')
          ..write('checksum: $checksum, ')
          ..write('previousPayload: $previousPayload, ')
          ..write('previousChecksum: $previousChecksum')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    slot,
    levelId,
    mode,
    payload,
    checksum,
    previousPayload,
    previousChecksum,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavedSession &&
          other.slot == this.slot &&
          other.levelId == this.levelId &&
          other.mode == this.mode &&
          other.payload == this.payload &&
          other.checksum == this.checksum &&
          other.previousPayload == this.previousPayload &&
          other.previousChecksum == this.previousChecksum);
}

class SavedSessionsCompanion extends UpdateCompanion<SavedSession> {
  final Value<String> slot;
  final Value<String> levelId;
  final Value<String> mode;
  final Value<String> payload;
  final Value<String> checksum;
  final Value<String?> previousPayload;
  final Value<String?> previousChecksum;
  final Value<int> rowid;
  const SavedSessionsCompanion({
    this.slot = const Value.absent(),
    this.levelId = const Value.absent(),
    this.mode = const Value.absent(),
    this.payload = const Value.absent(),
    this.checksum = const Value.absent(),
    this.previousPayload = const Value.absent(),
    this.previousChecksum = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavedSessionsCompanion.insert({
    required String slot,
    required String levelId,
    required String mode,
    required String payload,
    required String checksum,
    this.previousPayload = const Value.absent(),
    this.previousChecksum = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : slot = Value(slot),
       levelId = Value(levelId),
       mode = Value(mode),
       payload = Value(payload),
       checksum = Value(checksum);
  static Insertable<SavedSession> custom({
    Expression<String>? slot,
    Expression<String>? levelId,
    Expression<String>? mode,
    Expression<String>? payload,
    Expression<String>? checksum,
    Expression<String>? previousPayload,
    Expression<String>? previousChecksum,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (levelId != null) 'level_id': levelId,
      if (mode != null) 'mode': mode,
      if (payload != null) 'payload': payload,
      if (checksum != null) 'checksum': checksum,
      if (previousPayload != null) 'previous_payload': previousPayload,
      if (previousChecksum != null) 'previous_checksum': previousChecksum,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavedSessionsCompanion copyWith({
    Value<String>? slot,
    Value<String>? levelId,
    Value<String>? mode,
    Value<String>? payload,
    Value<String>? checksum,
    Value<String?>? previousPayload,
    Value<String?>? previousChecksum,
    Value<int>? rowid,
  }) {
    return SavedSessionsCompanion(
      slot: slot ?? this.slot,
      levelId: levelId ?? this.levelId,
      mode: mode ?? this.mode,
      payload: payload ?? this.payload,
      checksum: checksum ?? this.checksum,
      previousPayload: previousPayload ?? this.previousPayload,
      previousChecksum: previousChecksum ?? this.previousChecksum,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (checksum.present) {
      map['checksum'] = Variable<String>(checksum.value);
    }
    if (previousPayload.present) {
      map['previous_payload'] = Variable<String>(previousPayload.value);
    }
    if (previousChecksum.present) {
      map['previous_checksum'] = Variable<String>(previousChecksum.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavedSessionsCompanion(')
          ..write('slot: $slot, ')
          ..write('levelId: $levelId, ')
          ..write('mode: $mode, ')
          ..write('payload: $payload, ')
          ..write('checksum: $checksum, ')
          ..write('previousPayload: $previousPayload, ')
          ..write('previousChecksum: $previousChecksum, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreferencesTable extends Preferences
    with TableInfo<$PreferencesTable, Preference> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreferencesTable(this.attachedDatabase, [this._alias]);
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
  static const String $name = 'preferences';
  @override
  VerificationContext validateIntegrity(
    Insertable<Preference> instance, {
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
  Preference map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Preference(
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
  $PreferencesTable createAlias(String alias) {
    return $PreferencesTable(attachedDatabase, alias);
  }
}

class Preference extends DataClass implements Insertable<Preference> {
  final String key;
  final String value;
  const Preference({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  PreferencesCompanion toCompanion(bool nullToAbsent) {
    return PreferencesCompanion(key: Value(key), value: Value(value));
  }

  factory Preference.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Preference(
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

  Preference copyWith({String? key, String? value}) =>
      Preference(key: key ?? this.key, value: value ?? this.value);
  Preference copyWithCompanion(PreferencesCompanion data) {
    return Preference(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Preference(')
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
      (other is Preference &&
          other.key == this.key &&
          other.value == this.value);
}

class PreferencesCompanion extends UpdateCompanion<Preference> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const PreferencesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreferencesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<Preference> custom({
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

  PreferencesCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return PreferencesCompanion(
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
    return (StringBuffer('PreferencesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LevelProgressTable extends LevelProgress
    with TableInfo<$LevelProgressTable, LevelProgressData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LevelProgressTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _levelIdMeta = const VerificationMeta(
    'levelId',
  );
  @override
  late final GeneratedColumn<String> levelId = GeneratedColumn<String>(
    'level_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _starsMeta = const VerificationMeta('stars');
  @override
  late final GeneratedColumn<int> stars = GeneratedColumn<int>(
    'stars',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestMsMeta = const VerificationMeta('bestMs');
  @override
  late final GeneratedColumn<int> bestMs = GeneratedColumn<int>(
    'best_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cleanMeta = const VerificationMeta('clean');
  @override
  late final GeneratedColumn<bool> clean = GeneratedColumn<bool>(
    'clean',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("clean" IN (0, 1))',
    ),
  );
  static const VerificationMeta _firstCompletedUtcMeta = const VerificationMeta(
    'firstCompletedUtc',
  );
  @override
  late final GeneratedColumn<String> firstCompletedUtc =
      GeneratedColumn<String>(
        'first_completed_utc',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      );
  @override
  List<GeneratedColumn> get $columns => [
    levelId,
    mode,
    stars,
    bestMs,
    clean,
    firstCompletedUtc,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'level_progress';
  @override
  VerificationContext validateIntegrity(
    Insertable<LevelProgressData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('level_id')) {
      context.handle(
        _levelIdMeta,
        levelId.isAcceptableOrUnknown(data['level_id']!, _levelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_levelIdMeta);
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('stars')) {
      context.handle(
        _starsMeta,
        stars.isAcceptableOrUnknown(data['stars']!, _starsMeta),
      );
    } else if (isInserting) {
      context.missing(_starsMeta);
    }
    if (data.containsKey('best_ms')) {
      context.handle(
        _bestMsMeta,
        bestMs.isAcceptableOrUnknown(data['best_ms']!, _bestMsMeta),
      );
    } else if (isInserting) {
      context.missing(_bestMsMeta);
    }
    if (data.containsKey('clean')) {
      context.handle(
        _cleanMeta,
        clean.isAcceptableOrUnknown(data['clean']!, _cleanMeta),
      );
    } else if (isInserting) {
      context.missing(_cleanMeta);
    }
    if (data.containsKey('first_completed_utc')) {
      context.handle(
        _firstCompletedUtcMeta,
        firstCompletedUtc.isAcceptableOrUnknown(
          data['first_completed_utc']!,
          _firstCompletedUtcMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstCompletedUtcMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {levelId};
  @override
  LevelProgressData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LevelProgressData(
      levelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level_id'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      stars: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stars'],
      )!,
      bestMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}best_ms'],
      )!,
      clean: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}clean'],
      )!,
      firstCompletedUtc: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_completed_utc'],
      )!,
    );
  }

  @override
  $LevelProgressTable createAlias(String alias) {
    return $LevelProgressTable(attachedDatabase, alias);
  }
}

class LevelProgressData extends DataClass
    implements Insertable<LevelProgressData> {
  final String levelId;
  final String mode;
  final int stars;
  final int bestMs;
  final bool clean;
  final String firstCompletedUtc;
  const LevelProgressData({
    required this.levelId,
    required this.mode,
    required this.stars,
    required this.bestMs,
    required this.clean,
    required this.firstCompletedUtc,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['level_id'] = Variable<String>(levelId);
    map['mode'] = Variable<String>(mode);
    map['stars'] = Variable<int>(stars);
    map['best_ms'] = Variable<int>(bestMs);
    map['clean'] = Variable<bool>(clean);
    map['first_completed_utc'] = Variable<String>(firstCompletedUtc);
    return map;
  }

  LevelProgressCompanion toCompanion(bool nullToAbsent) {
    return LevelProgressCompanion(
      levelId: Value(levelId),
      mode: Value(mode),
      stars: Value(stars),
      bestMs: Value(bestMs),
      clean: Value(clean),
      firstCompletedUtc: Value(firstCompletedUtc),
    );
  }

  factory LevelProgressData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LevelProgressData(
      levelId: serializer.fromJson<String>(json['levelId']),
      mode: serializer.fromJson<String>(json['mode']),
      stars: serializer.fromJson<int>(json['stars']),
      bestMs: serializer.fromJson<int>(json['bestMs']),
      clean: serializer.fromJson<bool>(json['clean']),
      firstCompletedUtc: serializer.fromJson<String>(json['firstCompletedUtc']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'levelId': serializer.toJson<String>(levelId),
      'mode': serializer.toJson<String>(mode),
      'stars': serializer.toJson<int>(stars),
      'bestMs': serializer.toJson<int>(bestMs),
      'clean': serializer.toJson<bool>(clean),
      'firstCompletedUtc': serializer.toJson<String>(firstCompletedUtc),
    };
  }

  LevelProgressData copyWith({
    String? levelId,
    String? mode,
    int? stars,
    int? bestMs,
    bool? clean,
    String? firstCompletedUtc,
  }) => LevelProgressData(
    levelId: levelId ?? this.levelId,
    mode: mode ?? this.mode,
    stars: stars ?? this.stars,
    bestMs: bestMs ?? this.bestMs,
    clean: clean ?? this.clean,
    firstCompletedUtc: firstCompletedUtc ?? this.firstCompletedUtc,
  );
  LevelProgressData copyWithCompanion(LevelProgressCompanion data) {
    return LevelProgressData(
      levelId: data.levelId.present ? data.levelId.value : this.levelId,
      mode: data.mode.present ? data.mode.value : this.mode,
      stars: data.stars.present ? data.stars.value : this.stars,
      bestMs: data.bestMs.present ? data.bestMs.value : this.bestMs,
      clean: data.clean.present ? data.clean.value : this.clean,
      firstCompletedUtc: data.firstCompletedUtc.present
          ? data.firstCompletedUtc.value
          : this.firstCompletedUtc,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressData(')
          ..write('levelId: $levelId, ')
          ..write('mode: $mode, ')
          ..write('stars: $stars, ')
          ..write('bestMs: $bestMs, ')
          ..write('clean: $clean, ')
          ..write('firstCompletedUtc: $firstCompletedUtc')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(levelId, mode, stars, bestMs, clean, firstCompletedUtc);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LevelProgressData &&
          other.levelId == this.levelId &&
          other.mode == this.mode &&
          other.stars == this.stars &&
          other.bestMs == this.bestMs &&
          other.clean == this.clean &&
          other.firstCompletedUtc == this.firstCompletedUtc);
}

class LevelProgressCompanion extends UpdateCompanion<LevelProgressData> {
  final Value<String> levelId;
  final Value<String> mode;
  final Value<int> stars;
  final Value<int> bestMs;
  final Value<bool> clean;
  final Value<String> firstCompletedUtc;
  final Value<int> rowid;
  const LevelProgressCompanion({
    this.levelId = const Value.absent(),
    this.mode = const Value.absent(),
    this.stars = const Value.absent(),
    this.bestMs = const Value.absent(),
    this.clean = const Value.absent(),
    this.firstCompletedUtc = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LevelProgressCompanion.insert({
    required String levelId,
    required String mode,
    required int stars,
    required int bestMs,
    required bool clean,
    required String firstCompletedUtc,
    this.rowid = const Value.absent(),
  }) : levelId = Value(levelId),
       mode = Value(mode),
       stars = Value(stars),
       bestMs = Value(bestMs),
       clean = Value(clean),
       firstCompletedUtc = Value(firstCompletedUtc);
  static Insertable<LevelProgressData> custom({
    Expression<String>? levelId,
    Expression<String>? mode,
    Expression<int>? stars,
    Expression<int>? bestMs,
    Expression<bool>? clean,
    Expression<String>? firstCompletedUtc,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (levelId != null) 'level_id': levelId,
      if (mode != null) 'mode': mode,
      if (stars != null) 'stars': stars,
      if (bestMs != null) 'best_ms': bestMs,
      if (clean != null) 'clean': clean,
      if (firstCompletedUtc != null) 'first_completed_utc': firstCompletedUtc,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LevelProgressCompanion copyWith({
    Value<String>? levelId,
    Value<String>? mode,
    Value<int>? stars,
    Value<int>? bestMs,
    Value<bool>? clean,
    Value<String>? firstCompletedUtc,
    Value<int>? rowid,
  }) {
    return LevelProgressCompanion(
      levelId: levelId ?? this.levelId,
      mode: mode ?? this.mode,
      stars: stars ?? this.stars,
      bestMs: bestMs ?? this.bestMs,
      clean: clean ?? this.clean,
      firstCompletedUtc: firstCompletedUtc ?? this.firstCompletedUtc,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (levelId.present) {
      map['level_id'] = Variable<String>(levelId.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (stars.present) {
      map['stars'] = Variable<int>(stars.value);
    }
    if (bestMs.present) {
      map['best_ms'] = Variable<int>(bestMs.value);
    }
    if (clean.present) {
      map['clean'] = Variable<bool>(clean.value);
    }
    if (firstCompletedUtc.present) {
      map['first_completed_utc'] = Variable<String>(firstCompletedUtc.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LevelProgressCompanion(')
          ..write('levelId: $levelId, ')
          ..write('mode: $mode, ')
          ..write('stars: $stars, ')
          ..write('bestMs: $bestMs, ')
          ..write('clean: $clean, ')
          ..write('firstCompletedUtc: $firstCompletedUtc, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalletTransactionsTable extends WalletTransactions
    with TableInfo<$WalletTransactionsTable, WalletTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalletTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<int> amount = GeneratedColumn<int>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, reason];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'wallet_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalletTransaction> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalletTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalletTransaction(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}amount'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
    );
  }

  @override
  $WalletTransactionsTable createAlias(String alias) {
    return $WalletTransactionsTable(attachedDatabase, alias);
  }
}

class WalletTransaction extends DataClass
    implements Insertable<WalletTransaction> {
  final String id;
  final int amount;
  final String reason;
  const WalletTransaction({
    required this.id,
    required this.amount,
    required this.reason,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<int>(amount);
    map['reason'] = Variable<String>(reason);
    return map;
  }

  WalletTransactionsCompanion toCompanion(bool nullToAbsent) {
    return WalletTransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      reason: Value(reason),
    );
  }

  factory WalletTransaction.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalletTransaction(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<int>(json['amount']),
      reason: serializer.fromJson<String>(json['reason']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<int>(amount),
      'reason': serializer.toJson<String>(reason),
    };
  }

  WalletTransaction copyWith({String? id, int? amount, String? reason}) =>
      WalletTransaction(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        reason: reason ?? this.reason,
      );
  WalletTransaction copyWithCompanion(WalletTransactionsCompanion data) {
    return WalletTransaction(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      reason: data.reason.present ? data.reason.value : this.reason,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalletTransaction(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, reason);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalletTransaction &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.reason == this.reason);
}

class WalletTransactionsCompanion extends UpdateCompanion<WalletTransaction> {
  final Value<String> id;
  final Value<int> amount;
  final Value<String> reason;
  final Value<int> rowid;
  const WalletTransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.reason = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalletTransactionsCompanion.insert({
    required String id,
    required int amount,
    required String reason,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount),
       reason = Value(reason);
  static Insertable<WalletTransaction> custom({
    Expression<String>? id,
    Expression<int>? amount,
    Expression<String>? reason,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (reason != null) 'reason': reason,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalletTransactionsCompanion copyWith({
    Value<String>? id,
    Value<int>? amount,
    Value<String>? reason,
    Value<int>? rowid,
  }) {
    return WalletTransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      reason: reason ?? this.reason,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<int>(amount.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalletTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('reason: $reason, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$PawDatabase extends GeneratedDatabase {
  _$PawDatabase(QueryExecutor e) : super(e);
  $PawDatabaseManager get managers => $PawDatabaseManager(this);
  late final $SavedSessionsTable savedSessions = $SavedSessionsTable(this);
  late final $PreferencesTable preferences = $PreferencesTable(this);
  late final $LevelProgressTable levelProgress = $LevelProgressTable(this);
  late final $WalletTransactionsTable walletTransactions =
      $WalletTransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    savedSessions,
    preferences,
    levelProgress,
    walletTransactions,
  ];
}

typedef $$SavedSessionsTableCreateCompanionBuilder =
    SavedSessionsCompanion Function({
      required String slot,
      required String levelId,
      required String mode,
      required String payload,
      required String checksum,
      Value<String?> previousPayload,
      Value<String?> previousChecksum,
      Value<int> rowid,
    });
typedef $$SavedSessionsTableUpdateCompanionBuilder =
    SavedSessionsCompanion Function({
      Value<String> slot,
      Value<String> levelId,
      Value<String> mode,
      Value<String> payload,
      Value<String> checksum,
      Value<String?> previousPayload,
      Value<String?> previousChecksum,
      Value<int> rowid,
    });

class $$SavedSessionsTableFilterComposer
    extends Composer<_$PawDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousPayload => $composableBuilder(
    column: $table.previousPayload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get previousChecksum => $composableBuilder(
    column: $table.previousChecksum,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavedSessionsTableOrderingComposer
    extends Composer<_$PawDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get checksum => $composableBuilder(
    column: $table.checksum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousPayload => $composableBuilder(
    column: $table.previousPayload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get previousChecksum => $composableBuilder(
    column: $table.previousChecksum,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavedSessionsTableAnnotationComposer
    extends Composer<_$PawDatabase, $SavedSessionsTable> {
  $$SavedSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get checksum =>
      $composableBuilder(column: $table.checksum, builder: (column) => column);

  GeneratedColumn<String> get previousPayload => $composableBuilder(
    column: $table.previousPayload,
    builder: (column) => column,
  );

  GeneratedColumn<String> get previousChecksum => $composableBuilder(
    column: $table.previousChecksum,
    builder: (column) => column,
  );
}

class $$SavedSessionsTableTableManager
    extends
        RootTableManager<
          _$PawDatabase,
          $SavedSessionsTable,
          SavedSession,
          $$SavedSessionsTableFilterComposer,
          $$SavedSessionsTableOrderingComposer,
          $$SavedSessionsTableAnnotationComposer,
          $$SavedSessionsTableCreateCompanionBuilder,
          $$SavedSessionsTableUpdateCompanionBuilder,
          (
            SavedSession,
            BaseReferences<_$PawDatabase, $SavedSessionsTable, SavedSession>,
          ),
          SavedSession,
          PrefetchHooks Function()
        > {
  $$SavedSessionsTableTableManager(_$PawDatabase db, $SavedSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavedSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavedSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavedSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> slot = const Value.absent(),
                Value<String> levelId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> checksum = const Value.absent(),
                Value<String?> previousPayload = const Value.absent(),
                Value<String?> previousChecksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedSessionsCompanion(
                slot: slot,
                levelId: levelId,
                mode: mode,
                payload: payload,
                checksum: checksum,
                previousPayload: previousPayload,
                previousChecksum: previousChecksum,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String slot,
                required String levelId,
                required String mode,
                required String payload,
                required String checksum,
                Value<String?> previousPayload = const Value.absent(),
                Value<String?> previousChecksum = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavedSessionsCompanion.insert(
                slot: slot,
                levelId: levelId,
                mode: mode,
                payload: payload,
                checksum: checksum,
                previousPayload: previousPayload,
                previousChecksum: previousChecksum,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SavedSessionsTable, SavedSession>(table),
                  BaseReferences<
                    _$PawDatabase,
                    $SavedSessionsTable,
                    SavedSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavedSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PawDatabase,
      $SavedSessionsTable,
      SavedSession,
      $$SavedSessionsTableFilterComposer,
      $$SavedSessionsTableOrderingComposer,
      $$SavedSessionsTableAnnotationComposer,
      $$SavedSessionsTableCreateCompanionBuilder,
      $$SavedSessionsTableUpdateCompanionBuilder,
      (
        SavedSession,
        BaseReferences<_$PawDatabase, $SavedSessionsTable, SavedSession>,
      ),
      SavedSession,
      PrefetchHooks Function()
    >;
typedef $$PreferencesTableCreateCompanionBuilder =
    PreferencesCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$PreferencesTableUpdateCompanionBuilder =
    PreferencesCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$PreferencesTableFilterComposer
    extends Composer<_$PawDatabase, $PreferencesTable> {
  $$PreferencesTableFilterComposer({
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

class $$PreferencesTableOrderingComposer
    extends Composer<_$PawDatabase, $PreferencesTable> {
  $$PreferencesTableOrderingComposer({
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

class $$PreferencesTableAnnotationComposer
    extends Composer<_$PawDatabase, $PreferencesTable> {
  $$PreferencesTableAnnotationComposer({
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

class $$PreferencesTableTableManager
    extends
        RootTableManager<
          _$PawDatabase,
          $PreferencesTable,
          Preference,
          $$PreferencesTableFilterComposer,
          $$PreferencesTableOrderingComposer,
          $$PreferencesTableAnnotationComposer,
          $$PreferencesTableCreateCompanionBuilder,
          $$PreferencesTableUpdateCompanionBuilder,
          (
            Preference,
            BaseReferences<_$PawDatabase, $PreferencesTable, Preference>,
          ),
          Preference,
          PrefetchHooks Function()
        > {
  $$PreferencesTableTableManager(_$PawDatabase db, $PreferencesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => PreferencesCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PreferencesTable, Preference>(table),
                  BaseReferences<_$PawDatabase, $PreferencesTable, Preference>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreferencesTableProcessedTableManager =
    ProcessedTableManager<
      _$PawDatabase,
      $PreferencesTable,
      Preference,
      $$PreferencesTableFilterComposer,
      $$PreferencesTableOrderingComposer,
      $$PreferencesTableAnnotationComposer,
      $$PreferencesTableCreateCompanionBuilder,
      $$PreferencesTableUpdateCompanionBuilder,
      (
        Preference,
        BaseReferences<_$PawDatabase, $PreferencesTable, Preference>,
      ),
      Preference,
      PrefetchHooks Function()
    >;
typedef $$LevelProgressTableCreateCompanionBuilder =
    LevelProgressCompanion Function({
      required String levelId,
      required String mode,
      required int stars,
      required int bestMs,
      required bool clean,
      required String firstCompletedUtc,
      Value<int> rowid,
    });
typedef $$LevelProgressTableUpdateCompanionBuilder =
    LevelProgressCompanion Function({
      Value<String> levelId,
      Value<String> mode,
      Value<int> stars,
      Value<int> bestMs,
      Value<bool> clean,
      Value<String> firstCompletedUtc,
      Value<int> rowid,
    });

class $$LevelProgressTableFilterComposer
    extends Composer<_$PawDatabase, $LevelProgressTable> {
  $$LevelProgressTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bestMs => $composableBuilder(
    column: $table.bestMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get clean => $composableBuilder(
    column: $table.clean,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstCompletedUtc => $composableBuilder(
    column: $table.firstCompletedUtc,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LevelProgressTableOrderingComposer
    extends Composer<_$PawDatabase, $LevelProgressTable> {
  $$LevelProgressTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get levelId => $composableBuilder(
    column: $table.levelId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stars => $composableBuilder(
    column: $table.stars,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bestMs => $composableBuilder(
    column: $table.bestMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get clean => $composableBuilder(
    column: $table.clean,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstCompletedUtc => $composableBuilder(
    column: $table.firstCompletedUtc,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LevelProgressTableAnnotationComposer
    extends Composer<_$PawDatabase, $LevelProgressTable> {
  $$LevelProgressTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get levelId =>
      $composableBuilder(column: $table.levelId, builder: (column) => column);

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get stars =>
      $composableBuilder(column: $table.stars, builder: (column) => column);

  GeneratedColumn<int> get bestMs =>
      $composableBuilder(column: $table.bestMs, builder: (column) => column);

  GeneratedColumn<bool> get clean =>
      $composableBuilder(column: $table.clean, builder: (column) => column);

  GeneratedColumn<String> get firstCompletedUtc => $composableBuilder(
    column: $table.firstCompletedUtc,
    builder: (column) => column,
  );
}

class $$LevelProgressTableTableManager
    extends
        RootTableManager<
          _$PawDatabase,
          $LevelProgressTable,
          LevelProgressData,
          $$LevelProgressTableFilterComposer,
          $$LevelProgressTableOrderingComposer,
          $$LevelProgressTableAnnotationComposer,
          $$LevelProgressTableCreateCompanionBuilder,
          $$LevelProgressTableUpdateCompanionBuilder,
          (
            LevelProgressData,
            BaseReferences<
              _$PawDatabase,
              $LevelProgressTable,
              LevelProgressData
            >,
          ),
          LevelProgressData,
          PrefetchHooks Function()
        > {
  $$LevelProgressTableTableManager(_$PawDatabase db, $LevelProgressTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LevelProgressTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LevelProgressTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LevelProgressTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> levelId = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> stars = const Value.absent(),
                Value<int> bestMs = const Value.absent(),
                Value<bool> clean = const Value.absent(),
                Value<String> firstCompletedUtc = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LevelProgressCompanion(
                levelId: levelId,
                mode: mode,
                stars: stars,
                bestMs: bestMs,
                clean: clean,
                firstCompletedUtc: firstCompletedUtc,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String levelId,
                required String mode,
                required int stars,
                required int bestMs,
                required bool clean,
                required String firstCompletedUtc,
                Value<int> rowid = const Value.absent(),
              }) => LevelProgressCompanion.insert(
                levelId: levelId,
                mode: mode,
                stars: stars,
                bestMs: bestMs,
                clean: clean,
                firstCompletedUtc: firstCompletedUtc,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LevelProgressTable, LevelProgressData>(table),
                  BaseReferences<
                    _$PawDatabase,
                    $LevelProgressTable,
                    LevelProgressData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LevelProgressTableProcessedTableManager =
    ProcessedTableManager<
      _$PawDatabase,
      $LevelProgressTable,
      LevelProgressData,
      $$LevelProgressTableFilterComposer,
      $$LevelProgressTableOrderingComposer,
      $$LevelProgressTableAnnotationComposer,
      $$LevelProgressTableCreateCompanionBuilder,
      $$LevelProgressTableUpdateCompanionBuilder,
      (
        LevelProgressData,
        BaseReferences<_$PawDatabase, $LevelProgressTable, LevelProgressData>,
      ),
      LevelProgressData,
      PrefetchHooks Function()
    >;
typedef $$WalletTransactionsTableCreateCompanionBuilder =
    WalletTransactionsCompanion Function({
      required String id,
      required int amount,
      required String reason,
      Value<int> rowid,
    });
typedef $$WalletTransactionsTableUpdateCompanionBuilder =
    WalletTransactionsCompanion Function({
      Value<String> id,
      Value<int> amount,
      Value<String> reason,
      Value<int> rowid,
    });

class $$WalletTransactionsTableFilterComposer
    extends Composer<_$PawDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableFilterComposer({
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

  ColumnFilters<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalletTransactionsTableOrderingComposer
    extends Composer<_$PawDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableOrderingComposer({
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

  ColumnOrderings<int> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalletTransactionsTableAnnotationComposer
    extends Composer<_$PawDatabase, $WalletTransactionsTable> {
  $$WalletTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);
}

class $$WalletTransactionsTableTableManager
    extends
        RootTableManager<
          _$PawDatabase,
          $WalletTransactionsTable,
          WalletTransaction,
          $$WalletTransactionsTableFilterComposer,
          $$WalletTransactionsTableOrderingComposer,
          $$WalletTransactionsTableAnnotationComposer,
          $$WalletTransactionsTableCreateCompanionBuilder,
          $$WalletTransactionsTableUpdateCompanionBuilder,
          (
            WalletTransaction,
            BaseReferences<
              _$PawDatabase,
              $WalletTransactionsTable,
              WalletTransaction
            >,
          ),
          WalletTransaction,
          PrefetchHooks Function()
        > {
  $$WalletTransactionsTableTableManager(
    _$PawDatabase db,
    $WalletTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalletTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalletTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalletTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> amount = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalletTransactionsCompanion(
                id: id,
                amount: amount,
                reason: reason,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int amount,
                required String reason,
                Value<int> rowid = const Value.absent(),
              }) => WalletTransactionsCompanion.insert(
                id: id,
                amount: amount,
                reason: reason,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WalletTransactionsTable, WalletTransaction>(
                    table,
                  ),
                  BaseReferences<
                    _$PawDatabase,
                    $WalletTransactionsTable,
                    WalletTransaction
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalletTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$PawDatabase,
      $WalletTransactionsTable,
      WalletTransaction,
      $$WalletTransactionsTableFilterComposer,
      $$WalletTransactionsTableOrderingComposer,
      $$WalletTransactionsTableAnnotationComposer,
      $$WalletTransactionsTableCreateCompanionBuilder,
      $$WalletTransactionsTableUpdateCompanionBuilder,
      (
        WalletTransaction,
        BaseReferences<
          _$PawDatabase,
          $WalletTransactionsTable,
          WalletTransaction
        >,
      ),
      WalletTransaction,
      PrefetchHooks Function()
    >;

class $PawDatabaseManager {
  final _$PawDatabase _db;
  $PawDatabaseManager(this._db);
  $$SavedSessionsTableTableManager get savedSessions =>
      $$SavedSessionsTableTableManager(_db, _db.savedSessions);
  $$PreferencesTableTableManager get preferences =>
      $$PreferencesTableTableManager(_db, _db.preferences);
  $$LevelProgressTableTableManager get levelProgress =>
      $$LevelProgressTableTableManager(_db, _db.levelProgress);
  $$WalletTransactionsTableTableManager get walletTransactions =>
      $$WalletTransactionsTableTableManager(_db, _db.walletTransactions);
}
