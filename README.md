# Orbit

A Dart Backend API Framework with Postgres.

Live demo at https://orbit-dart-server.herokuapp.com/

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

## Heroku deployment

Make sure you have the Heroku CLI installed.

1. Create the app on heroku. You may be asked to log in

```
heroku create orbit-dart-server
```

2. Create a `Procfile` to your project root folder

eg. orbit-server/Procfile

3. Add the web dyno command to the Procfile

```
web: ./dart-sdk/bin/dart example/bin/example.dart
```

4. Connect your Github repo to the app on your Heroku dashboard

5. Add the dart sdk url to the heroku app environment

```
heroku config:set DART_SDK_URL=https://storage.googleapis.com/dart-archive/channels/stable/release/latest/sdk/dartsdk-linux-x64-release.zip
```

6. Add the Dart buildpack for heroku

```
heroku config:add BUILDPACK_URL=https://github.com/igrigorik/heroku-buildpack-dart.git
```

7. Attach a Postgres database from your Heroku dashboard
