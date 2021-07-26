import 'type.dart';

class RowOrder {
  static const String asc = 'ASC';
  static const String desc = 'DESC';
}

class Table {
  final String name;
  const Table(this.name);
}

class Column {
  const Column({
    bool primaryKey = false,
    ColumnType databaseType = ColumnType.string,
    bool nullable = false,
    String? defaultValue,
    bool unique = false,
    bool indexed = false,
    bool omitInJson = false,
    bool autoincrement = false,
    List<Object> validators = const [],
  })  : isPrimaryKey = primaryKey,
        databaseType = databaseType,
        isNullable = nullable,
        defaultValue = defaultValue,
        isUnique = unique,
        isIndexed = indexed,
        shouldOmitFromJson = omitInJson,
        autoincrement = autoincrement,
        validators = validators;

  final bool isPrimaryKey;
  final ColumnType databaseType;
  final bool isNullable;
  final String? defaultValue;
  final bool isUnique;
  final bool isIndexed;
  final bool shouldOmitFromJson;
  final bool autoincrement;
  final List<Object> validators;

  @override
  String toString() {
    final result = <String>[];
    result.add(databaseType.sqlType ?? '');
    if (isPrimaryKey) result.add('PRIMARY KEY');
    if (isUnique) result.add('UNIQUE');
    if (!isNullable && !isPrimaryKey) result.add('NOT NULL');
    if (defaultValue != null) result.add('DEFAULT $defaultValue');
    return result.join(' ');
  }
}

const Column primaryKey = Column(
  primaryKey: true,
  databaseType: ColumnType.serial,
  autoincrement: true,
);
