import 'package:flutter/services.dart';
import 'package:kuama_flutter/src/shared/feature_structure/failures/dart_failures.dart';
import 'package:rxdart/rxdart.dart';

/// Extend or use this class for all errors/exceptions given by classes that use a current platform
/// (MethodChannel/EventChannel)
@Deprecated(
    'Anti-pattern classes as it allows for unmanaged failures. Do you prefer [UnhandledFailure]')
class PlatformFailure extends Failure {
  final PlatformException platformError;

  PlatformFailure({
    required PlatformException error,
    required StackTrace stackTrace,
  })  : platformError = error,
        super(error: ErrorAndStackTrace(error, stackTrace));

  @override
  String get onMessage => platformError.message ?? 'Platform error';
}
