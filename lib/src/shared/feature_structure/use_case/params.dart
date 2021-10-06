import 'package:equatable/equatable.dart';

/// Use it to declare the parameters of a use case
abstract class Params extends Equatable {
  const Params();

  @override
  bool? get stringify => true;
}

/// Use it to declare a use case that doesn't need parameters to be called
class NoParams extends Params {
  const NoParams._();

  static const _instance = NoParams._();

  factory NoParams() => _instance;

  @override
  final List<Object?> props = const <Object?>[];
}
