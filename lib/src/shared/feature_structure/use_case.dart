import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/services.dart';
import 'package:kuama_flutter/src/_utils/lg.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failure.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

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

@Deprecated('In favour of [Params]')
abstract class ParamsBase extends Params {
  const ParamsBase(this.props);

  @override
  bool? get stringify => true;

  @override
  final List<Object?> props;
}

abstract class UseCaseBase<TParams, TResult> {
  TResult call(TParams params);

  @visibleForOverriding
  Failure onMapErrorToFailure(TParams params, Object error, StackTrace stackTrace) {
    if (error is DioError) {
      return HttpClientFailure(error: error, stackTrace: stackTrace);
    }
    if (error is PlatformException) {
      return PlatformFailure(error: error, stackTrace: stackTrace);
    }

    return UnhandledFailure(error, stackTrace);
  }

  @protected
  Failure mapErrorToFailure(TParams params, Object error, StackTrace stackTrace) {
    if (error is Failure) {
      lg.w(Debuggable({'UseCaseFailure($runtimeType)': params}), error, stackTrace);
      return error;
    }

    final failure = onMapErrorToFailure(params, error, stackTrace);
    lg.w(Debuggable({'UseCaseError($runtimeType)': params}), failure, stackTrace);
    return failure;
  }
}

abstract class UseCase<TParams, TResult>
    extends UseCaseBase<TParams, Future<Either<Failure, TResult>>> {
  @override
  Future<Either<Failure, TResult>> call(TParams params) async {
    try {
      return await tryCall(params);
    } catch (error, stackTrace) {
      return Left(mapErrorToFailure(params, error, stackTrace));
    }
  }

  @visibleForTesting
  @visibleForOverriding
  Future<Either<Failure, TResult>> tryCall(TParams params);
}

abstract class StreamUseCase<TParams, TResult>
    extends UseCaseBase<TParams, Stream<Either<Failure, TResult>>> {
  @override
  Stream<Either<Failure, TResult>> call(TParams params) {
    return tryCall(params).onErrorReturnWith((error, stackTrace) {
      return Left(mapErrorToFailure(params, error, stackTrace));
    });
  }

  @visibleForTesting
  @visibleForOverriding
  Stream<Either<Failure, TResult>> tryCall(TParams params);
}

class ProgressSnapshot<TResult> extends Equatable {
  final double progress;
  final Either<Failure, TResult>? _result;

  bool get hasResult => _result != null;
  Either<Failure, TResult> get result => _result!;

  ProgressSnapshot({
    required this.progress,
    Either<Failure, TResult>? result,
  }) : _result = result;

  @override
  List<Object?> get props => [progress, result];

  @override
  String toString() => '$ProgressSnapshot{progress:$progress,result$_result}';
}

abstract class ProgressUseCase<TParams, TResult>
    extends UseCaseBase<TParams, Stream<ProgressSnapshot<TResult>>> {
  @override
  Stream<ProgressSnapshot<TResult>> call(TParams params) {
    return tryCall(params).onErrorReturnWith((error, stackTrace) {
      return ProgressSnapshot(
        progress: 1.0,
        result: Left(mapErrorToFailure(params, error, stackTrace)),
      );
    });
  }

  @visibleForTesting
  @visibleForOverriding
  Stream<ProgressSnapshot<TResult>> tryCall(TParams params);
}

extension EitherValueExtensions<TLeft, TRight> on Either<TLeft, TRight> {
  TLeft get left => fold((l) => l, (r) => throw 'Not has left value');
  TRight get right => fold((l) => throw 'Not has right value', (r) => r);
}

/// Converts the current value<T> of the Future to Right<T> or Left<T>
extension EitherFutureExtensions<T> on Future<T> {
  Future<Either<TLeft, T>> toRight<TLeft>() => then(right);

  Future<Either<T, TRight>> toLeft<TRight>() => then(left);
}

/// Converts the current value<T> of the Stream to Right<T> or Left<T>
extension EitherStreamExtensions<T> on Stream<T> {
  Stream<Either<TLeft, T>> toRight<TLeft>() => map(right);

  Stream<Either<T, TRight>> toLeft<TRight>() => map(left);
}
