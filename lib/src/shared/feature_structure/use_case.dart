import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';

class UseCaseError {
  final Object error;
  final StackTrace stackTrace;

  UseCaseError(this.error, this.stackTrace);

  @override
  String toString() => '$runtimeType\n$error\n$stackTrace';
}

abstract class UseCase<TParams, TResult> {
  Stream<Either<Failure, TResult>> call(TParams params) async* {
    try {
      await for (final result in tryCall(params)) {
        yield result;
      }
    } catch (error, stackTrace) {
      // Trigger error only during debug mode
      assert(() {
        throw UseCaseError(error, stackTrace);
      }());
      lg.warning(() {
        return PrettyObject({
          'Error in UseCase($runtimeType)': '$error\n$stackTrace',
          'Params': params,
        });
      });
      yield Left(UnhandledFailure(error, stackTrace));
    }
  }

  Stream<Either<Failure, TResult>> tryCall(TParams params);
}

/// Converts the current value<T> of the Stream to Right<T> or Left<T>
extension EitherOnStream<T> on Stream<T> {
  Stream<Either<TLeft, T>> toRight<TLeft>() => map(right);

  Stream<Either<T, TRight>> toLeft<TRight>() => map(left);
}

abstract class Params extends Equatable {
  const Params();

  @override
  bool? get stringify => true;
}

class NoParams extends Params {
  const NoParams._();

  static const _instance = NoParams._();

  factory NoParams() => _instance;

  @override
  final List<Object?> props = const <Object?>[];
}

abstract class ParamsBase extends Params {
  const ParamsBase(this.props);

  @override
  bool? get stringify => true;

  @override
  final List<Object?> props;
}
