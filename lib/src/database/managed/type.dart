import 'dart:mirrors';

import 'attributes.dart';
import 'document.dart';

/// Possible data types for [Column] attributes.
enum ColumnType {
  uuid,

  money,

  serial,

  /// Represented by instances of [int].
  integer,

  /// Represented by instances of [int].
  bigInteger,

  /// Represented by instances of [String].
  string,

  /// Represented by instances of [DateTime].
  datetime,

  /// Represented by instances of [bool].
  boolean,

  /// Represented by instances of [double].
  doublePrecision,

  /// Represented by instances of [Map].
  map,

  /// Represented by instances of [List].
  list,

  /// Represented by instances of [Document]
  document
}

extension ColumnTypeSqlString on ColumnType {
  static final _map = const {
    null: '',
    ColumnType.uuid: 'uuid',
    ColumnType.serial: 'serial',
    ColumnType.integer: 'integer',
    ColumnType.bigInteger: 'bigint',
    ColumnType.doublePrecision: 'double precision',
    ColumnType.money: 'money',
    ColumnType.boolean: 'boolean',
    ColumnType.string: 'text',
    ColumnType.datetime: 'timestamp',
    ColumnType.map: '',
    ColumnType.list: '',
    ColumnType.document: '',
  };

  String? get sqlType {
    return _map[this]?.toUpperCase();
  }
}

/// Complex type storage for [Column] attributes.
class ManagedType {
  /// Creates a new instance from a [ClassMirror].
  ///
  /// [mirror] must be representable by [ColumnType].
  ManagedType(this.mirror) {
    if (mirror.isAssignableTo(reflectType(int))) {
      kind = ColumnType.integer;
    } else if (mirror.isAssignableTo(reflectType(String))) {
      kind = ColumnType.string;
    } else if (mirror.isAssignableTo(reflectType(DateTime))) {
      kind = ColumnType.datetime;
    } else if (mirror.isAssignableTo(reflectType(bool))) {
      kind = ColumnType.boolean;
    } else if (mirror.isAssignableTo(reflectType(double))) {
      kind = ColumnType.doublePrecision;
    } else if (mirror.isSubtypeOf(reflectType(Map))) {
      if (!mirror.typeArguments.first.isAssignableTo(reflectType(String))) {
        throw UnsupportedError(
            "Invalid type '${mirror.reflectedType}' for 'ManagedType'. Key is invalid; must be 'String'.");
      }
      kind = ColumnType.map;
      elements = ManagedType(mirror.typeArguments.last);
    } else if (mirror.isSubtypeOf(reflectType(List))) {
      kind = ColumnType.list;
      elements = ManagedType(mirror.typeArguments.first);
    } else if (mirror.isAssignableTo(reflectType(Document))) {
      kind = ColumnType.document;
    } else if (mirror is ClassMirror && (mirror as ClassMirror).isEnum) {
      kind = ColumnType.string;
      final enumeratedCases =
          (mirror as ClassMirror).getField(#values).reflectee as List<dynamic>;
      enumerationMap = enumeratedCases.fold(<String, dynamic>{}, (m, v) {
        m![v.toString().split('.').last] = v;
        return m;
      });
    } else {
      throw UnsupportedError(
          "Invalid type '${mirror.reflectedType}' for 'ManagedType'.");
    }
  }

  /// Creates a new instance from a [ColumnType];
  ManagedType.fromKind(this.kind) {
    switch (kind) {
      case ColumnType.bigInteger:
        mirror = reflectClass(int);
        break;
      case ColumnType.boolean:
        mirror = reflectClass(bool);
        break;
      case ColumnType.datetime:
        mirror = reflectClass(DateTime);
        break;
      case ColumnType.document:
        mirror = reflectClass(Document);
        break;
      case ColumnType.doublePrecision:
        mirror = reflectClass(double);
        break;
      case ColumnType.integer:
        mirror = reflectClass(int);
        break;
      case ColumnType.string:
        mirror = reflectClass(String);
        break;
      case ColumnType.list:
      case ColumnType.map:
      case ColumnType.money:
      case ColumnType.uuid:
      case ColumnType.serial:
        {
          throw ArgumentError(
              "Cannot instantiate 'ManagedType' from type 'list' or 'map'. Use default constructor.");
        }
    }
  }

  /// The primitive kind of this type.
  ///
  /// All types have a kind. If kind is a map or list, it will also have [elements].
  late ColumnType kind;

  /// The primitive kind of each element of this type.
  ///
  /// If [kind] is a collection (map or list), this value stores the type of each element in the collection.
  /// Keys of map types are always [String].
  ManagedType? elements;

  /// Dart representation of this type.
  late TypeMirror mirror;

  /// Whether this is an enum type.
  bool get isEnumerated => enumerationMap != null;

  /// For enumerated types, this is a map of the name of the option to its Dart enum type.
  Map<String, dynamic>? enumerationMap;

  /// Whether [dartValue] can be assigned to properties with this type.
  bool isAssignableWith(dynamic dartValue) {
    if (dartValue == null) {
      return true;
    }
    return reflect(dartValue).type.isAssignableTo(mirror);
  }

  @override
  String toString() {
    return '$kind';
  }

  static List<Type> get supportedDartTypes {
    return [String, DateTime, bool, int, double, Document];
  }

  static ColumnType get integer => ColumnType.integer;

  static ColumnType get bigInteger => ColumnType.bigInteger;

  static ColumnType get string => ColumnType.string;

  static ColumnType get datetime => ColumnType.datetime;

  static ColumnType get boolean => ColumnType.boolean;

  static ColumnType get doublePrecision => ColumnType.doublePrecision;

  static ColumnType get map => ColumnType.map;

  static ColumnType get list => ColumnType.list;

  static ColumnType get document => ColumnType.document;
}
