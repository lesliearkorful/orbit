import 'package:postgres/postgres.dart';

import 'entity.dart';
import '../database/database_service.dart';
import '../database/managed/attributes.dart';
import '../database/managed/query.dart';
import '../helpers.dart';
import '../service/sl.dart';

abstract class Model<E extends Entity> {
  PostgreSQLConnection db = sl.get<DatabaseService>().connection;
  final E entity;
  Model(this.entity);

  String get _table => entity.table;

  String get _primaryKey => entity.primaryKey;

  String _queryKeys(Iterable<String> list) {
    return list.map((v) => camelToSnakeCase(v)).join(', ');
  }

  String _queryValues(Iterable<String> list) {
    return list.map((v) => '@' + camelToSnakeCase(v)).join(', ');
  }

  Future<E?> create(E entity) async {
    final map = entity.toJson(snakeCase: true);
    map.removeWhere((key, value) => value == null);
    final res = await db.query(
      'INSERT INTO $_table (${_queryKeys(map.keys)}) VALUES (${_queryValues(map.keys)}) RETURNING *',
      substitutionValues: map,
    );
    if (res.isEmpty) return null;
    entity.fromJson(res.first.toColumnMap().withCamelCaseKeys);
    return entity;
  }

  Future<List<E>> getAll({
    Where? where,
    String rowOrder = RowOrder.desc,
  }) async {
    final res = await db.query(
      'SELECT * FROM $_table ${where?.sql ?? ''} ORDER BY $_primaryKey $rowOrder',
      substitutionValues: where?.substitutionValues,
    );
    return res.map((r) {
      final entity = instantiate<E>(E);
      entity.fromJson(r.toColumnMap().withCamelCaseKeys);
      return entity;
    }).toList();
  }

  Future<E?> getOne(Where where) async {
    final res = await db.query(
      'SELECT * FROM $_table ${where.sql}',
      substitutionValues: where.substitutionValues,
    );
    if (res.isEmpty) return null;
    final entity = instantiate<E>(E);
    entity.fromJson(res.first.toColumnMap().withCamelCaseKeys);
    return entity;
  }

  Future<E?> update(
    UpdateEntity body,
    Where where,
  ) async {
    final subsValues = where.substitutionValues;
    var setString = '';
    body.value?.forEach((key, value) {
      final columnName = camelToSnakeCase(key);
      var subsKey = '$columnName';
      if (subsValues!.containsKey(subsKey)) {
        final list = subsValues.keys.where((k) => k == subsKey);
        subsKey = columnName + '_${list.length + 1}';
      }
      setString += '$columnName = @$subsKey, ';
      subsValues.addAll({subsKey: value});
    });
    setString = setString.trimRight();
    if (setString.endsWith(',')) {
      setString = setString.substring(0, setString.length - 1);
    }
    final res = await db.query(
      'UPDATE $_table SET $setString ${where.sql} RETURNING *',
      substitutionValues: subsValues,
    );
    final entity = instantiate<E>(E);
    entity.fromJson(res.first.toColumnMap().withCamelCaseKeys);
    return entity;
  }

  Future<bool> delete(Where where) async {
    final res = await db.query(
      'DELETE FROM $_table ${where.sql} RETURNING *',
      substitutionValues: where.substitutionValues,
    );
    if (res.isEmpty) return false;
    return true;
  }
}
