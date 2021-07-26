import 'package:orbit/orbit.dart';
import 'package:shelf/shelf.dart';

abstract class Controller<E extends Entity, S extends Service<Model<E>>> {
  S service;
  String? prefix;
  Controller({required this.service, this.prefix});

  Handler get handler;
}
