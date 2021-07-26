import '../../helpers.dart';
import '../../module/entity.dart';

enum _WhereOperator {
  isEqualTo,
  isGreaterThan,
  isLesserThan,
  isLike,
  startsWith,
  endsWith,
  contains,
}

const isEqualto = _WhereOperator.isEqualTo;
const isGreaterThan = _WhereOperator.isGreaterThan;
const isLesserThan = _WhereOperator.isLesserThan;
const isLike = _WhereOperator.isLike;
const startsWith = _WhereOperator.startsWith;
const endsWith = _WhereOperator.endsWith;
const contains = _WhereOperator.contains;

extension _WhereOperatorExt on _WhereOperator {
  static const _searchable = {
    _WhereOperator.isLike,
    _WhereOperator.startsWith,
    _WhereOperator.endsWith,
    _WhereOperator.contains,
  };
  static const _map = {
    _WhereOperator.isEqualTo: '=',
    _WhereOperator.isGreaterThan: '>',
    _WhereOperator.isLesserThan: '<',
    _WhereOperator.isLike: 'LIKE',
    _WhereOperator.startsWith: 'LIKE',
    _WhereOperator.endsWith: 'LIKE',
    _WhereOperator.contains: 'LIKE',
  };

  static bool shouldSearch(_WhereOperator o) {
    return _searchable.contains(o);
  }

  String withPattern(String value) {
    var result = value;
    if (this == _WhereOperator.endsWith) {
      result = '%' + value;
    } else if (this == _WhereOperator.startsWith) {
      result = value + '%';
    } else if (this == _WhereOperator.contains) {
      result = '%' + value + '%';
    }
    return result;
  }

  String get string => _map[this] ?? '';
}

class Where {
  final String _key;
  final Object _value;
  final _WhereOperator _operator;
  Map<String, Object?>? substitutionValues;
  String sql = 'WHERE ';

  Where(this._key, this._operator, this._value) {
    substitutionValues = {};
    _parse(_key, _value, operator: _operator);
  }

  void _parse(
    String key,
    Object value, {
    _WhereOperator operator = _WhereOperator.isEqualTo,
  }) {
    if (key.isEmpty) return;
    final columnName = camelToSnakeCase(key);
    var subsKey = '$columnName';
    if (substitutionValues!.containsKey(subsKey)) {
      final list = substitutionValues!.keys.where((k) => k == subsKey);
      subsKey = columnName + '_${list.length + 1}';
    }
    sql += '$columnName ${operator.string} @$subsKey';
    var subsValue = value;
    if (_WhereOperatorExt.shouldSearch(operator)) {
      subsValue = operator.withPattern(value.toString());
    }
    substitutionValues?.addAll({subsKey: subsValue});
  }

  Where AND(String key, _WhereOperator operator, Object value) {
    sql += ' AND ';
    _parse(key, value, operator: operator);
    return this;
  }

  Where OR(String key, _WhereOperator operator, Object value) {
    sql += ' OR ';
    _parse(key, value, operator: operator);
    return this;
  }

  factory Where.rawQuery(
    String query, {
    Map<String, Object?>? substitutionValues,
  }) {
    return Where('', _WhereOperator.isEqualTo, '')
      ..sql = query
      ..substitutionValues = substitutionValues;
  }
}

class UpdateEntity<T extends Entity> {
  T entity;
  Map<String, Object?>? value;
  UpdateEntity(this.entity, Map<String, Object?> body) {
    entity.fromJson(body);
    final sanitizedBody = <String, Object?>{};
    entity.toJson().forEach((key, value) {
      if (body.containsKey(key)) sanitizedBody[key] = value;
    });
    value = sanitizedBody;
  }
}
