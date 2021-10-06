import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:kuama_flutter/src/shared/feature_structure/use_case/use_case.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:kuama_flutter/src/shared/utils/logger.dart';

/// Listen for all events of a use case, such as start, completion, errors and failures
///
/// You can override a UseCaseObserver with `UseCase.observer = MyUseCaseObserver();`
class UseCaseObserver {
  const UseCaseObserver();

  factory UseCaseObserver.log({Logger? logger}) = _UseCaseObserverLogger;

  /// Called when use case is called/start
  void onCall(UseCaseBase useCase, dynamic params) {}

  /// Called when use case complete with or without result
  void onResult(UseCaseBase useCase, dynamic params, dynamic result) {}

  /// Called when use case throw a [Failure]
  void onFailure(UseCaseBase useCase, dynamic params, Failure failure, StackTrace stackTrace) {}

  /// Called when use case throw a error
  void onError(UseCaseBase useCase, dynamic params, Object error, StackTrace stackTrace) {}
}

class _UseCaseObserverLogger extends UseCaseObserver {
  final Logger logger;

  _UseCaseObserverLogger({
    Logger? logger,
  }) : logger = logger ?? Logger('Kuama.UseCase');

  @override
  void onFailure(UseCaseBase useCase, params, Failure failure, StackTrace stackTrace) {
    logger.w(Debuggable({'UseCaseError($runtimeType)': params}), failure, stackTrace);
  }

  @override
  void onError(UseCaseBase useCase, params, Object error, StackTrace stackTrace) {
    logger.e(Debuggable({'UseCaseFailure($runtimeType)': params}), error, stackTrace);
  }
}
