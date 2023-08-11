import 'package:dio/dio.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:rxdart/rxdart.dart';

/// Keep the same basic structure of [Error]/[Exception]
abstract class Failure with Debuggable {
  final ErrorAndStackTrace? error;

  Failure({this.error});

  /// Explains the cause of the failure and how to fix it
  String get message => onMessage;

  /// DEPRECATED: Implement [message]
  ///
  /// Explain the causes of the failure and how to fix it,
  /// avoid using the error data for the explanation
  // Correct name: onCollectDebugMessage
  String get onMessage => '';

  /// DEPRECATED: Create your base Failure and mix it with [Debuggable]
  ///
  /// This method is used to collect a debug information
  @override
  Map<String, dynamic> collectDebugInfo() {
    final e = error?.error;
    final st = error?.stackTrace;

    return {
      ...toLogMessages(),
      if (e != null) ...(e is Debuggable ? e.collectDebugInfo() : {'Fault': e}),
      if (st != null) 'FaultStackTrace': st,
    };
  }

  /// DEPRECATED: Create your base Failure and mix it with [Debuggable]
  ///
  /// Collect as much failure data as possible, avoid using the failure data
  // Correct name: onCollectDebugInfo
  Map<String, dynamic> toLogMessages() => {'Failure(${runtimeType})': message};

  /// This is string is used to show error on console
  @override
  String toString() {
    final e = error?.error;
    final st = error?.stackTrace;

    final buffer = StringBuffer('Failure($runtimeType): ${message}');
    if (e != null) buffer.write(e);
    if (st != null) buffer.write(st);
    return buffer.toString();
  }
}

class UnhandledFailure<TParams> extends Failure {
  UnhandledFailure(Object error, StackTrace stackTrace)
      : super(error: ErrorAndStackTrace(error, stackTrace));

  @override
  String get onMessage => 'Unhandled error. See the error and the stackTrace below';
}

/// Extend or use this class for all errors/exceptions given by classes that use an HttpClient
class HttpClientFailure extends Failure {
  final DioException dioException;

  HttpClientFailure({
    required DioException error,
    required StackTrace stackTrace,
  })  : dioException = error,
        super(error: ErrorAndStackTrace(error, stackTrace));

  @override
  String get onMessage {
    final request = dioException.requestOptions;
    final response = dioException.response;

    var msg = 'An unhandled error of the Dio http client.';
    msg += '\nThe errore was caused by ${request.method}:${request.uri}';
    if (response != null) {
      msg += '\nThe server responded with ${response.statusCode}:${response.data}';
    }
    return msg;
  }

  @override
  Map<String, dynamic> toLogMessages() {
    final request = dioException.requestOptions;
    final response = dioException.response;
    return {
      '$runtimeType(${error.runtimeType}) ${request.uri}': request.data,
      if (response != null)
        'Response(${response.runtimeType}): ${response.statusCode}': response.data,
    };
  }
}
