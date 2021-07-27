import 'package:orbit/orbit.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'account.model.dart';
import 'account.service.dart';

class AccountController extends Controller<Account, AccountService> {
  AccountController() : super(service: AccountService(), prefix: '/accounts');

  @override
  Handler get handler {
    final router = Router();

    router.post('/', (Request req) async {
      try {
        final body = Account();
        body.fromJson(await decodeBody(req));
        final account = Account();
        account.accountName = body.accountName;
        account.accountNumber = body.accountNumber;
        account.currency = body.currency;
        account.balance = body.balance;
        final res = await service.model.create(account);
        return Response.ok(dataResponse(res));
      } catch (e) {
        handleError(e);
        return Response.internalServerError(
          body: errorResponse([
            ApiError(property: 'server', message: '$e'),
          ]),
        );
      }
    });

    router.get('/all', (Request req) async {
      try {
        final res = await service.model.getAll();
        return Response.ok(dataResponse(res));
      } catch (e) {
        handleError(e);
        return Response.internalServerError(
          body: errorResponse([
            ApiError(property: 'server', message: '$e'),
          ]),
        );
      }
    });

    router.get('/<id>', (Request req, String id) async {
      try {
        final res = await service.model.getOne(Where('id', isEqualto, id));
        if (res == null) {
          return Response.notFound(dataResponse({'data': res}));
        }
        return Response.ok(dataResponse(res));
      } catch (e) {
        handleError(e);
        return Response.internalServerError(
          body: errorResponse([
            ApiError(property: 'server', message: '$e'),
          ]),
        );
      }
    });

    router.patch('/<id>', (Request req, String id) async {
      try {
        final json = await decodeBody(req);
        final res = await service.model.update(
          UpdateEntity(Account(), json),
          Where('id', isEqualto, id),
        );
        if (res == null) {
          return Response.notFound(dataResponse(res));
        }
        return Response.ok(dataResponse(res));
      } catch (e) {
        handleError(e);
        return Response.internalServerError(
          body: errorResponse([
            ApiError(property: 'server', message: '$e'),
          ]),
        );
      }
    });

    router.delete('/<id>', (Request req, String id) async {
      try {
        final res = await service.model.delete(Where('id', isEqualto, id));
        return Response.ok(dataResponse(res));
      } catch (e) {
        handleError(e);
        return Response.internalServerError(
          body: errorResponse([
            ApiError(property: 'server', message: '$e'),
          ]),
        );
      }
    });

    return router;
  }
}
