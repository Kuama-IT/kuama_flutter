import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:kuama_flutter/src/shared/feature_structure/fault.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:rxdart/rxdart.dart';

abstract class Failure with Debuggable {
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
  Map<String, dynamic> collectDebugInfo() {
    final e = error?.error;
    final st = error?.stackTrace;

    return {
      ...toLogMessages(),
      if (e != null) ...(e is Debuggable ? e.collectDebugInfo() : {'Fault': e}),
      if (st != null) 'FaultStackTrace': st,
      'FailureStackTrace': stackTrace,
    };
  }

  Map<String, dynamic> toLogMessages() => {'Failure(${runtimeType})': onMessage};

  @override
  String toString() {
    final e = error?.error;
    final st = error?.stackTrace;

    final buffer = StringBuffer('Failure($runtimeType): $onMessage');
    if (e != null) buffer.write(e);
    if (st != null) buffer.write(st);
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
  final DioError dioError;

  HttpClientFailure({
    required DioError error,
    required StackTrace stackTrace,
  })  : dioError = error,
        super(error: ErrorAndStackTrace(error, stackTrace));

  @override
  String get onMessage => 'Http client error (${dioError.response?.statusCode})';

  @override
  Map<String, dynamic> toLogMessages() {
    final request = dioError.requestOptions;
    final response = dioError.response;
    return {
      '$runtimeType(${dioError.runtimeType})': dioError.toString(),
      'Request(${request.runtimeType}): ${request.uri}': request.data,
      if (response != null) 'Response(${response.runtimeType}): ${response.statusCode}': response,
    };
  }
}

/// Extend or use this class for all errors/exceptions given by classes that use a current platform
/// (MethodChannel/EventChannel)
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
