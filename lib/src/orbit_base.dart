import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';

import 'module/controller.dart';
import 'database/database_service.dart';
import 'service/sl.dart';

class Orbit {
  Router router = Router();
  int port = 8080;
  String address = 'localhost';

  static Future<void> initialize({String? databaseUrl}) async {
    setupServiceLocator();
    if (databaseUrl == null) return;
    return await sl
        .get<DatabaseService>()
        .initialize(databaseUrl)
        .then((_) => print('Database connected'))
        .catchError((e) => print('error: failed to connect to database\n$e'));
  }

  static Future<Orbit> create({
    List<Controller> controllers = const [],
  }) async {
    final query = controllers.map((c) {
      return c.service.model.entity.dbQuery;
    }).join('\n');
    sl.get<DatabaseService>().registerEntities(query);

    final app = Orbit();
    controllers.forEach((c) {
      if ((c.prefix ?? '').isNotEmpty || c.prefix != '/') {
        print('Mounting ${c.runtimeType} on ${c.prefix}');
        if (!c.prefix!.endsWith('/')) c.prefix = '${c.prefix}/';
        app.router.mount(c.prefix!, c.handler);
      }
    });
    return app;
  }

  Middleware get _responseHandler {
    return createMiddleware(responseHandler: (res) async {
      final response = res.change(headers: {
        'content-type': 'application/json',
        'server': 'Orbit on Dart'
      });
      return response;
    });
  }

  Future<HttpServer> serve({
    SecurityContext? securityContext,
    int? backlog,
    bool shared = false,
  }) async {
    final handler = const Pipeline()
        .addMiddleware(logRequests())
        .addMiddleware(_responseHandler)
        .addHandler(router);
    return await shelf_io.serve(
      handler,
      address,
      port,
      securityContext: securityContext,
      backlog: backlog,
      shared: shared,
    )
      ..autoCompress = true;
  }
}
