// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connectivity_preferences.dart';

// **************************************************************************
// IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, non_constant_identifier_names, constant_identifier_names, invalid_use_of_protected_member, unnecessary_cast, prefer_const_constructors, lines_longer_than_80_chars, require_trailing_commas, inference_failure_on_function_invocation, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_checks, join_return_with_assignment, prefer_final_locals, avoid_js_rounded_ints, avoid_positional_boolean_parameters, always_specify_types

extension GetConnectivityPreferencesCollection on Isar {
  IsarCollection<ConnectivityPreferences> get connectivityPreferences =>
      this.collection();
}

const ConnectivityPreferencesSchema = CollectionSchema(
  name: r'ConnectivityPreferences',
  id: 8890632586138862953,
  properties: {
    r'displayMode': PropertySchema(
      id: 0,
      name: r'displayMode',
      type: IsarType.long,
    ),
    r'displayModeName': PropertySchema(
      id: 1,
      name: r'displayModeName',
      type: IsarType.string,
    ),
    r'isEnabled': PropertySchema(
      id: 2,
      name: r'isEnabled',
      type: IsarType.bool,
    ),
    r'lastUpdated': PropertySchema(
      id: 3,
      name: r'lastUpdated',
      type: IsarType.dateTime,
    ),
    r'playSoundOnChange': PropertySchema(
      id: 4,
      name: r'playSoundOnChange',
      type: IsarType.bool,
    ),
    r'showNotifications': PropertySchema(
      id: 5,
      name: r'showNotifications',
      type: IsarType.bool,
    ),
    r'showWhenOnline': PropertySchema(
      id: 6,
      name: r'showWhenOnline',
      type: IsarType.bool,
    ),
    r'vibrateOnDisconnect': PropertySchema(
      id: 7,
      name: r'vibrateOnDisconnect',
      type: IsarType.bool,
    )
  },
  estimateSize: _connectivityPreferencesEstimateSize,
  serialize: _connectivityPreferencesSerialize,
  deserialize: _connectivityPreferencesDeserialize,
  deserializeProp: _connectivityPreferencesDeserializeProp,
  idName: r'id',
  indexes: {
    r'isEnabled': IndexSchema(
      id: 1854025363566937220,
      name: r'isEnabled',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'isEnabled',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    ),
    r'displayMode': IndexSchema(
      id: 7802327087567506506,
      name: r'displayMode',
      unique: false,
      replace: false,
      properties: [
        IndexPropertySchema(
          name: r'displayMode',
          type: IndexType.value,
          caseSensitive: false,
        )
      ],
    )
  },
  links: {},
  embeddedSchemas: {},
  getId: _connectivityPreferencesGetId,
  getLinks: _connectivityPreferencesGetLinks,
  attach: _connectivityPreferencesAttach,
  version: '3.1.0+1',
);

int _connectivityPreferencesEstimateSize(
  ConnectivityPreferences object,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.displayModeName.length * 3;
  return bytesCount;
}

void _connectivityPreferencesSerialize(
  ConnectivityPreferences object,
  IsarWriter writer,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  writer.writeLong(offsets[0], object.displayMode);
  writer.writeString(offsets[1], object.displayModeName);
  writer.writeBool(offsets[2], object.isEnabled);
  writer.writeDateTime(offsets[3], object.lastUpdated);
  writer.writeBool(offsets[4], object.playSoundOnChange);
  writer.writeBool(offsets[5], object.showNotifications);
  writer.writeBool(offsets[6], object.showWhenOnline);
  writer.writeBool(offsets[7], object.vibrateOnDisconnect);
}

ConnectivityPreferences _connectivityPreferencesDeserialize(
  Id id,
  IsarReader reader,
  List<int> offsets,
  Map<Type, List<int>> allOffsets,
) {
  final object = ConnectivityPreferences(
    displayMode: reader.readLongOrNull(offsets[0]) ?? 0,
    isEnabled: reader.readBoolOrNull(offsets[2]) ?? true,
    playSoundOnChange: reader.readBoolOrNull(offsets[4]) ?? false,
    showNotifications: reader.readBoolOrNull(offsets[5]) ?? true,
    showWhenOnline: reader.readBoolOrNull(offsets[6]) ?? false,
    vibrateOnDisconnect: reader.readBoolOrNull(offsets[7]) ?? false,
  );
  object.id = id;
  object.lastUpdated = reader.readDateTime(offsets[3]);
  return object;
}

P _connectivityPreferencesDeserializeProp<P>(
  IsarReader reader,
  int propertyId,
  int offset,
  Map<Type, List<int>> allOffsets,
) {
  switch (propertyId) {
    case 0:
      return (reader.readLongOrNull(offset) ?? 0) as P;
    case 1:
      return (reader.readString(offset)) as P;
    case 2:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 3:
      return (reader.readDateTime(offset)) as P;
    case 4:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 5:
      return (reader.readBoolOrNull(offset) ?? true) as P;
    case 6:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    case 7:
      return (reader.readBoolOrNull(offset) ?? false) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _connectivityPreferencesGetId(ConnectivityPreferences object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _connectivityPreferencesGetLinks(
    ConnectivityPreferences object) {
  return [];
}

void _connectivityPreferencesAttach(
    IsarCollection<dynamic> col, Id id, ConnectivityPreferences object) {
  object.id = id;
}

extension ConnectivityPreferencesQueryWhereSort
    on QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QWhere> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterWhere>
      anyId() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(const IdWhereClause.any());
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterWhere>
      anyIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'isEnabled'),
      );
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterWhere>
      anyDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        const IndexWhereClause.any(indexName: r'displayMode'),
      );
    });
  }
}

extension ConnectivityPreferencesQueryWhere on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QWhereClause> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: id,
        upper: id,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> idNotEqualTo(Id id) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            )
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            );
      } else {
        return query
            .addWhereClause(
              IdWhereClause.greaterThan(lower: id, includeLower: false),
            )
            .addWhereClause(
              IdWhereClause.lessThan(upper: id, includeUpper: false),
            );
      }
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> idGreaterThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.greaterThan(lower: id, includeLower: include),
      );
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> idLessThan(Id id, {bool include = false}) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(
        IdWhereClause.lessThan(upper: id, includeUpper: include),
      );
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> idBetween(
    Id lowerId,
    Id upperId, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IdWhereClause.between(
        lower: lowerId,
        includeLower: includeLower,
        upper: upperId,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> isEnabledEqualTo(bool isEnabled) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'isEnabled',
        value: [isEnabled],
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> isEnabledNotEqualTo(bool isEnabled) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isEnabled',
              lower: [],
              upper: [isEnabled],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isEnabled',
              lower: [isEnabled],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isEnabled',
              lower: [isEnabled],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'isEnabled',
              lower: [],
              upper: [isEnabled],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> displayModeEqualTo(int displayMode) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.equalTo(
        indexName: r'displayMode',
        value: [displayMode],
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> displayModeNotEqualTo(int displayMode) {
    return QueryBuilder.apply(this, (query) {
      if (query.whereSort == Sort.asc) {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'displayMode',
              lower: [],
              upper: [displayMode],
              includeUpper: false,
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'displayMode',
              lower: [displayMode],
              includeLower: false,
              upper: [],
            ));
      } else {
        return query
            .addWhereClause(IndexWhereClause.between(
              indexName: r'displayMode',
              lower: [displayMode],
              includeLower: false,
              upper: [],
            ))
            .addWhereClause(IndexWhereClause.between(
              indexName: r'displayMode',
              lower: [],
              upper: [displayMode],
              includeUpper: false,
            ));
      }
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> displayModeGreaterThan(
    int displayMode, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'displayMode',
        lower: [displayMode],
        includeLower: include,
        upper: [],
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> displayModeLessThan(
    int displayMode, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'displayMode',
        lower: [],
        upper: [displayMode],
        includeUpper: include,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterWhereClause> displayModeBetween(
    int lowerDisplayMode,
    int upperDisplayMode, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addWhereClause(IndexWhereClause.between(
        indexName: r'displayMode',
        lower: [lowerDisplayMode],
        includeLower: includeLower,
        upper: [upperDisplayMode],
        includeUpper: includeUpper,
      ));
    });
  }
}

extension ConnectivityPreferencesQueryFilter on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QFilterCondition> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayMode',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeGreaterThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayMode',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeLessThan(
    int value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayMode',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeBetween(
    int lower,
    int upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayMode',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameGreaterThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameLessThan(
    String value, {
    bool include = false,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameBetween(
    String lower,
    String upper, {
    bool includeLower = true,
    bool includeUpper = true,
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'displayModeName',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.startsWith(
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.endsWith(
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
          QAfterFilterCondition>
      displayModeNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.contains(
        property: r'displayModeName',
        value: value,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
          QAfterFilterCondition>
      displayModeNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.matches(
        property: r'displayModeName',
        wildcard: pattern,
        caseSensitive: caseSensitive,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'displayModeName',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> displayModeNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        property: r'displayModeName',
        value: '',
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> idEqualTo(Id value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> idGreaterThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> idLessThan(
    Id value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'id',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> idBetween(
    Id lower,
    Id upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'id',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> isEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'isEnabled',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> lastUpdatedEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> lastUpdatedGreaterThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.greaterThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> lastUpdatedLessThan(
    DateTime value, {
    bool include = false,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.lessThan(
        include: include,
        property: r'lastUpdated',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> lastUpdatedBetween(
    DateTime lower,
    DateTime upper, {
    bool includeLower = true,
    bool includeUpper = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.between(
        property: r'lastUpdated',
        lower: lower,
        includeLower: includeLower,
        upper: upper,
        includeUpper: includeUpper,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> playSoundOnChangeEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'playSoundOnChange',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> showNotificationsEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showNotifications',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> showWhenOnlineEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'showWhenOnline',
        value: value,
      ));
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences,
      QAfterFilterCondition> vibrateOnDisconnectEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(FilterCondition.equalTo(
        property: r'vibrateOnDisconnect',
        value: value,
      ));
    });
  }
}

extension ConnectivityPreferencesQueryObject on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QFilterCondition> {}

extension ConnectivityPreferencesQueryLinks on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QFilterCondition> {}

extension ConnectivityPreferencesQuerySortBy
    on QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QSortBy> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByDisplayModeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayModeName', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByDisplayModeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayModeName', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByPlaySoundOnChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playSoundOnChange', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByPlaySoundOnChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playSoundOnChange', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByShowNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByShowWhenOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWhenOnline', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByShowWhenOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWhenOnline', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByVibrateOnDisconnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrateOnDisconnect', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      sortByVibrateOnDisconnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrateOnDisconnect', Sort.desc);
    });
  }
}

extension ConnectivityPreferencesQuerySortThenBy on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QSortThenBy> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByDisplayModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayMode', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByDisplayModeName() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayModeName', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByDisplayModeNameDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'displayModeName', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'id', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByIsEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'isEnabled', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByLastUpdatedDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'lastUpdated', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByPlaySoundOnChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playSoundOnChange', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByPlaySoundOnChangeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'playSoundOnChange', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByShowNotificationsDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showNotifications', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByShowWhenOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWhenOnline', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByShowWhenOnlineDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'showWhenOnline', Sort.desc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByVibrateOnDisconnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrateOnDisconnect', Sort.asc);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QAfterSortBy>
      thenByVibrateOnDisconnectDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(r'vibrateOnDisconnect', Sort.desc);
    });
  }
}

extension ConnectivityPreferencesQueryWhereDistinct on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QDistinct> {
  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByDisplayMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayMode');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByDisplayModeName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'displayModeName',
          caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByIsEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'isEnabled');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByLastUpdated() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'lastUpdated');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByPlaySoundOnChange() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'playSoundOnChange');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByShowNotifications() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showNotifications');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByShowWhenOnline() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'showWhenOnline');
    });
  }

  QueryBuilder<ConnectivityPreferences, ConnectivityPreferences, QDistinct>
      distinctByVibrateOnDisconnect() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(r'vibrateOnDisconnect');
    });
  }
}

extension ConnectivityPreferencesQueryProperty on QueryBuilder<
    ConnectivityPreferences, ConnectivityPreferences, QQueryProperty> {
  QueryBuilder<ConnectivityPreferences, int, QQueryOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'id');
    });
  }

  QueryBuilder<ConnectivityPreferences, int, QQueryOperations>
      displayModeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayMode');
    });
  }

  QueryBuilder<ConnectivityPreferences, String, QQueryOperations>
      displayModeNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'displayModeName');
    });
  }

  QueryBuilder<ConnectivityPreferences, bool, QQueryOperations>
      isEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'isEnabled');
    });
  }

  QueryBuilder<ConnectivityPreferences, DateTime, QQueryOperations>
      lastUpdatedProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'lastUpdated');
    });
  }

  QueryBuilder<ConnectivityPreferences, bool, QQueryOperations>
      playSoundOnChangeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'playSoundOnChange');
    });
  }

  QueryBuilder<ConnectivityPreferences, bool, QQueryOperations>
      showNotificationsProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showNotifications');
    });
  }

  QueryBuilder<ConnectivityPreferences, bool, QQueryOperations>
      showWhenOnlineProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'showWhenOnline');
    });
  }

  QueryBuilder<ConnectivityPreferences, bool, QQueryOperations>
      vibrateOnDisconnectProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addPropertyName(r'vibrateOnDisconnect');
    });
  }
}
