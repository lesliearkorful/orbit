import 'dart:mirrors';

import '../database/managed/attributes.dart';
import '../helpers.dart';

class Entity {
  String table = '';

  String primaryKey = '';

  String? dbQuery;

  InstanceMirror get _mirror => reflect(this);

  Map<Symbol, DeclarationMirror> get _declarations => _mirror.type.declarations;

  Entity() {
    final classMirror = _mirror.type;
    final columns = <String>[];
    final alterColumns = <String>[];
    if (classMirror.metadata.isNotEmpty) {
      table = (classMirror.metadata.first.reflectee as Table).name;
    }
    for (final v in classMirror.declarations.values) {
      if (v.metadata.isNotEmpty) {
        if (v.metadata.first.reflectee is Column) {
          final reflectee = v.metadata.first.reflectee as Column;
          final columnName = MirrorSystem.getName(v.simpleName);
          final columnSql = '${camelToSnakeCase(columnName)} $reflectee';
          columns.add(columnSql);
          if (!reflectee.isPrimaryKey) {
            alterColumns.add(
              'ALTER TABLE ${camelToSnakeCase(table)} ADD COLUMN IF NOT EXISTS $columnSql;',
            );
          } else {
            primaryKey = camelToSnakeCase(columnName);
          }
        }
      }
    }
    dbQuery = '''
CREATE TABLE IF NOT EXISTS ${camelToSnakeCase(table)} (
  ${columns.join(',\n  ').trimRight()}
);
${alterColumns.join("\n").trimRight()}
''';
  }

  void fromJson(Map<String, Object?> map) {
    map.forEach((key, value) {
      try {
        final field = _declarations[Symbol(key)] as VariableMirror;
        if (field.metadata.isNotEmpty) {
          if (field.metadata.first.reflectee is Column) {
            final reflectee = field.metadata.first.reflectee as Column;
            if (reflectee.shouldOmitFromJson) return;
          }
        }
        final fieldType = field.type;
        dynamic castValue;
        if (value != null) {
          if (fieldType.isAssignableTo(reflectType(double))) {
            castValue = double.tryParse(value.toString());
          } else if (fieldType.isAssignableTo(reflectType(int))) {
            castValue = int.tryParse(value.toString());
          } else if (fieldType.isAssignableTo(reflectType(DateTime))) {
            castValue = DateTime.tryParse(value.toString());
          } else {
            castValue = value;
          }
        }
        _mirror.setField(Symbol(key), castValue ?? value);
      } catch (e) {
        handleError(e);
      }
    });
  }

  Map<String, Object?> toJson({bool snakeCase = false}) {
    final map = <String, Object?>{};
    try {
      _declarations.forEach((key, value) {
        if (value is VariableMirror) {
          final field = _mirror.getField(key);
          if (value.metadata.isNotEmpty) {
            if (value.metadata.first.reflectee is Column) {
              final reflectee = value.metadata.first.reflectee as Column;
              if (reflectee.shouldOmitFromJson) return;
            }
          }
          if (!field.toString().toLowerCase().contains('null')) {
            var keyString = MirrorSystem.getName(key);
            if (snakeCase) {
              keyString = camelToSnakeCase(MirrorSystem.getName(key));
            }
            map[keyString] = field.reflectee;
          } else {
            var keyString = MirrorSystem.getName(key);
            if (snakeCase) {
              keyString = camelToSnakeCase(MirrorSystem.getName(key));
            }
            map[keyString] = null;
          }
        }
      });
    } catch (e) {
      handleError(e);
    }
    return map;
  }

  @override
  String toString() => toJson().toString();
}
