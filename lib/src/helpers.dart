import 'dart:convert';
import 'dart:developer';
import 'dart:mirrors';

import 'package:recase/recase.dart';
import 'package:shelf/shelf.dart';

import '../src/module/entity.dart';

String Params(String name) => '<$name|.*>';

void handleError(dynamic e) {
  log('$e', stackTrace: StackTrace.current);
}

String camelToSnakeCase(String camelCase) {
  final rc = ReCase(camelCase);
  return rc.snakeCase;
}

String snakeToCamelCase(String snakeCase) {
  final rc = ReCase(snakeCase);
  return rc.camelCase;
}

extension ParseDbMap on Map<String, dynamic> {
  Map<String, dynamic> get withCamelCaseKeys {
    // ignore: unnecessary_this
    return this.map((key, value) {
      return MapEntry(snakeToCamelCase(key), value);
    });
  }
}

class ApiError {
  final String property;
  final Object message;
  ApiError({required this.property, required this.message});

  Map<String, Object?> toJson() {
    return {'property': property, 'message': message};
  }
}

String _encodeJson(dynamic j) {
  return jsonEncode(j, toEncodable: (o) {
    if (o == null) return null;
    if (o is Entity) return o.toJson();
    if (o is DateTime) return o.toIso8601String();
    return o.toString();
  });
}

String dataResponse(Object? data) {
  return _encodeJson({'data': data});
}

String errorResponse(List<ApiError> errors) {
  return _encodeJson({
    'errors': errors.map((e) => e.toJson()).toList(),
  });
}

Future<Map<String, Object?>> decodeBody(Request req) async {
  return jsonDecode(await req.readAsString());
}

T instantiate<T>(Type type) {
  return reflectClass(type).newInstance(Symbol(''), []).reflectee;
}
