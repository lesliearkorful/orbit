import 'package:get_it/get_it.dart';

import '../database/database_service.dart';

GetIt sl = GetIt.instance;

void setupServiceLocator() {
  print('Setting up service locator');
  sl.registerLazySingleton<DatabaseService>(() => DatabaseService());
}
