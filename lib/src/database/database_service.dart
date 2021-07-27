import 'package:postgres/postgres.dart';

import '../database/database_config.dart';

class DatabaseService {
  late PostgreSQLConnection connection;

  Future<dynamic> initialize(String url, {bool useSSL = false}) {
    connection = DatabaseConfig.fromUrl(url, useSSL: useSSL).connection;
    print('Connecting to Postgres database...');
    return connection.open();
  }

  void registerEntities(String query) async {
    try {
      print('Creating entities...');
      await connection.execute(query);
      print('Tables created for entities');
    } catch (e) {
      print('$e');
    }
  }
}
