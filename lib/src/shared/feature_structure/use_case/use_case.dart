import 'dart:async';

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

abstract class UseCase<TParams, TResult> extends UseCaseBase<TParams, Future<TResult>> {
  @override
  Future<TResult> call(TParams params) async {
    UseCaseBase.observer.onCall(this, params);
    try {
      final result = await onCall(params);
      UseCaseBase.observer.onResult(this, params, result);
      return result;
    } on Failure catch (failure, stackTrace) {
      UseCaseBase.observer.onFailure(this, params, failure, stackTrace);
      rethrow;
    } catch (error, stackTrace) {
      final failure = mapErrorToFailure(params, error, stackTrace);
      throw failure;
    }
  }

  @visibleForTesting
  @visibleForOverriding
  Future<TResult> onCall(TParams params);
}

abstract class StreamUseCase<TParams, TResult> extends UseCaseBase<TParams, Stream<TResult>> {
  @override
  Stream<TResult> call(TParams params) {
    return onCall(params).onErrorResume((error, stackTrace) {
      if (error is Failure) {
        return Stream.error(error, stackTrace);
      }
      final failure = mapErrorToFailure(params, error, stackTrace);
      return Stream.error(failure, stackTrace);
    });
  }

  @visibleForTesting
  @visibleForOverriding
  Stream<TResult> onCall(TParams params);
}

class ProgressSnapshot<TResult> extends Equatable {
  final double progress;
  final TResult? _result;

  bool get hasResult => _result != null;
  TResult get result => _result!;

  const ProgressSnapshot({
    required this.progress,
    TResult? result,
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
    return onCall(params);
  }

  @visibleForTesting
  @visibleForOverriding
  Stream<ProgressSnapshot<TResult>> onCall(TParams params);
}

extension StreamFailureExtension<T> on Stream<T> {
  Stream<T> onFailureResume(Stream<T> Function(Failure failure) onFailure) {
    return onErrorResume((error, stackTrace) {
      if (error is Failure) {
        return onFailure(error);
      }
      return Stream.error(error, stackTrace);
    });
  }
}

extension StreamSubscriptionExtension<T> on StreamSubscription<T> {
  StreamSubscription<T> onFailure(FutureOr<bool?> Function(Failure failure) onFailure) {
    onError((error, stackTrace) {
      if (error is Failure) {
        final res = onFailure(error);
        if (res != false) return;
      }
      Zone.current.handleUncaughtError(error, stackTrace);
    });
    return this;
  }
}
