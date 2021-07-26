import 'model.dart';

abstract class Service<M extends Model> {
  M model;
  Service({required this.model});

  // Future<T?> create<T>(T entity) async {
  //   return model.create(entity);
  // }

  // Future<T?> update();

  // Future<T?> findOne();

  // Future<List<T>> find();

  // Future<bool> delete();
}
