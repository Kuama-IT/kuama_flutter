import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';
import 'package:rxdart/rxdart.dart';

abstract class Fault with PrettyObject {
  final ErrorAndStackTrace? error;

  Fault({this.error});

  /// Message that can be shown to the user to inform him of the problem
  String get message;

  @override
  Map<String, dynamic> toPrettyMap() {
    return {
      if (error != null) 'Error(${error.runtimeType})': '${error!.error}\n${error!.stackTrace}',
      'Fault(${runtimeType})': '${message}',
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
