import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case_observer.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';

class UnhandledUseCaseError {
  final UseCaseBase<dynamic, dynamic> useCase;
  final dynamic params;
  final Object error;
  final StackTrace stackTrace;

  UnhandledUseCaseError(this.useCase, this.params, this.error, this.stackTrace);

  @override
  String toString() =>
      'The use case (${useCase}) failed to complete the job due to an unexpected error\n$params\n$error\n$stackTrace';
}

/// Recover a use case that has failed by transforming it into failure
typedef UseCaseHealer = Failure? Function(
    UseCaseBase useCase, dynamic params, Object error, StackTrace stackTrace);

abstract class UseCaseBase<TParams, TResult> {
  /// Listen all the errors and failures that are emitted by any use case
  static UseCaseObserver observer = const UseCaseObserver();

  /// You can catch use case exceptions and convert them to failure
  static UseCaseHealer healer = defaultHealer;

  static Failure? defaultHealer(
      UseCaseBase useCase, dynamic params, Object error, StackTrace stackTrace) {
    return null;
  }

  TResult call(TParams params);

  @protected
  Failure mapErrorToFailure(TParams params, Object error, StackTrace stackTrace) {
    if (error is Failure) {
      observer.onFailure(this, params, error, stackTrace);
      return error;
    }

    observer.onError(this, params, error, stackTrace);
    final failure = healer(this, params, error, stackTrace);
    if (failure == null) throw UnhandledUseCaseError(this, params, error, stackTrace);
    return failure;
  }

  @override
  String toString() => '$runtimeType';
}

abstract class UseCase<TParams, TResult>
    extends UseCaseBase<TParams, Future<Either<Failure, TResult>>> {
  @override
  Future<Either<Failure, TResult>> call(TParams params) async {
    UseCaseBase.observer.onCall(this, params);
    try {
      final result = await tryCall(params);
      UseCaseBase.observer.onResult(this, params, result);
      return result;
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

  const ProgressSnapshot({
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
