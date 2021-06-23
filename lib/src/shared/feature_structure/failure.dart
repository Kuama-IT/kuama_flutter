import 'package:kuama_flutter/src/shared/feature_structure/fault.dart';
import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';
import 'package:rxdart/rxdart.dart';

abstract class Failure with PrettyObject {
  final StackTrace stackTrace = StackTrace.current;
  final ErrorAndStackTrace? error;

  Failure({this.error});

  /// Message that can be shown to the user to inform him of the problem
  String get message {
    final err = error?.error;
    return err is Fault ? err.message : onMessage;
  }

  String get onMessage;

  @override
  Map<String, dynamic> toPrettyMap() {
    final err = error;

    return {
      if (err != null)
        ...(err is PrettyObject ? toPrettyMap() : {'Error(${error.runtimeType})': '$error'}),
      'Failure(${runtimeType})': '${message}\n${stackTrace}',
    };
  }

  @override
  String toString() {
    final buffer = StringBuffer();
    if (error != null) {
      buffer.write(error!.error);
      if (error!.stackTrace != null) buffer.write(error!.stackTrace);
    }
    buffer.write('Fault($runtimeType): $message');
    buffer.write(stackTrace);
    return buffer.toString();
  }
}

class UnhandledFailure extends Failure {
  UnhandledFailure(Object error, StackTrace? stackTrace)
      : super(error: ErrorAndStackTrace(error, stackTrace));

  @override
  String get onMessage => 'App Crashed';
}

/// Extend or use this class for all errors/exceptions given by classes that use an HttpClient
class HttpClientFailure extends Failure {
  HttpClientFailure({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get onMessage => 'Http client error';
}

/// Extend or use this class for all errors/exceptions given by classes that use a current platform
/// (MethodChannel/EventChannel)
class PlatformFailure extends Failure {
  PlatformFailure({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get onMessage => 'Platform error';
}
