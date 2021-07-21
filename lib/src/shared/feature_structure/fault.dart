import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:rxdart/rxdart.dart';

abstract class Fault with Debuggable {
  final ErrorAndStackTrace? error;

  Fault({this.error});

  /// Message that can be shown to the user to inform him of the problem
  String get message;

  @override
  Map<String, dynamic> collectDebugInfo() {
    final e = error?.error;
    final st = error?.stackTrace;

    return {
      ...collectLogMessages(),
      if (e != null) ...(e is Debuggable ? e.collectDebugInfo() : {'Error': e}),
      if (st != null) 'ErrorStackTrace': st,
    };
  }

  Map<String, dynamic> collectLogMessages() => {'Failure(${runtimeType})': message};

  @override
  String toString() {
    final e = error?.error;
    final st = error?.stackTrace;

    final buffer = StringBuffer('Failure($runtimeType): $message');
    if (e != null) buffer.write(e);
    if (st != null) buffer.write(st);
    return buffer.toString();
  }
}

/// Extend or use this class for all errors/exceptions given by classes that use an HttpClient
class HttpClientFault extends Fault {
  HttpClientFault({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get message => 'Http client error';
}

/// Extend or use this class for all errors/exceptions given by classes that use a current platform
/// (MethodChannel/EventChannel)
class PlatformFault extends Fault {
  PlatformFault({ErrorAndStackTrace? error}) : super(error: error);

  @override
  String get message => 'Platform error';
}
