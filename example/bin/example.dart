import 'dart:io';

import 'package:example/account/account.controller.dart';
import 'package:orbit/orbit.dart';
import 'package:shelf/shelf.dart';

void main() async {
  final remoteDB = Platform.environment['DATABASE_URL'];
  final localDB = 'postgres://lesliearkorful:password@localhost:4040/postgres';

  await Orbit.initialize(
    databaseUrl: remoteDB ?? localDB,
    useSSL: remoteDB != null,
  );

  final app = await Orbit.create(
    controllers: [
      AccountController(),
    ],
  );

  app.port = int.parse(Platform.environment['PORT'] ?? '8080');
  app.address = InternetAddress.anyIPv4.address;

  app.router.get('/', (_) {
    return Response.ok(dataResponse({'message': 'Welcome to Orbit'}));
  });

  final server = await app.serve();
  print('Serving at http://${server.address.host}:${server.port}');
}
