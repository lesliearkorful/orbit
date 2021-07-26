import 'package:orbit/orbit.dart';

import 'account.model.dart';

class AccountService extends Service<AccountModel> {
  AccountService() : super(model: AccountModel());

  // Future<List<Map<String, Object?>?>> allUsers() async {
  //   return await model.getAll();
  // }
}
