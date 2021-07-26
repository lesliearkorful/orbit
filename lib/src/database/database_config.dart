import 'package:postgres/postgres.dart';

class DatabaseConfig {
  int port;
  String host;
  String databaseName;
  String username;
  String password;
  bool useSSL;
  String scheme;

  DatabaseConfig({
    required this.databaseName,
    required this.host,
    required this.password,
    required this.port,
    required this.username,
    this.useSSL = false,
    this.scheme = '',
  });

  factory DatabaseConfig.fromUrl(String url) {
    final uri = Uri.parse(url);
    return DatabaseConfig(
      scheme: uri.scheme,
      port: uri.port,
      host: uri.host,
      databaseName: uri.pathSegments.first,
      username: uri.userInfo.split(':').first,
      password: uri.userInfo.split(':').last,
    );
  }

  PostgreSQLConnection get connection {
    return PostgreSQLConnection(
      host,
      port,
      databaseName,
      username: username,
      password: password,
      useSSL: useSSL,
    );
  }

  @override
  String toString() {
    return Uri(
      scheme: scheme,
      userInfo: '$username:$password',
      host: host,
      port: port,
      pathSegments: [databaseName],
    ).toString();
  }
}
