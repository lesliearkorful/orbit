# Orbit

A Dart Backend API Framework with Postgres.

## Usage

A simple usage example:

```dart
import 'package:orbit/orbit.dart';

void main() async {
  final remoteDB = Platform.environment['DATABASE_URL'];
  final localDB = 'postgres://username:password@host:8080/databaseName';

  await Orbit.initialize(databaseUrl: remoteDB ?? localDB);

  final app = await Orbit.create(
    controllers: [
      UserController(),
    ],
  );

  app.port = int.parse(Platform.environment['PORT'] ?? '3000');
  app.address = InternetAddress.anyIPv4.address;

  app.router.get('/', (_) {
    return Response.ok(dataResponse({'message': 'Welcome to Orbit'}));
  });

  final server = await app.serve();
  print('Serving at http://${server.address.host}:${server.port}');
}

```

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: http://example.com/issues/replaceme
