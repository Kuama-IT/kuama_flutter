import 'package:dio/dio.dart';
import 'package:kuama_flutter/src/shared/utils/debuggable.dart';
import 'package:kuama_flutter/src/shared/utils/logger.dart';

class LogDioInterceptor with Interceptor {
  final Logger logger;

  final bool canLogRequest;
  final bool canLogResponse;
  final bool canLogError;
  final bool canLogHeaders;

  LogDioInterceptor({
    Logger? logger,
    this.canLogRequest = true,
    this.canLogResponse = true,
    this.canLogError = true,
    this.canLogHeaders = false,
  }) : logger = logger ?? Logger('Kuama.Dio');

  void _logRequest(Map<String, dynamic> msg) {
    logger.v(Debuggable(msg));
  }

  void _logResponse(Map<String, dynamic> msg) {
    logger.v(Debuggable(msg));
  }

  void _logError(Map<String, dynamic> msg) {
    logger.w(Debuggable(msg));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (canLogRequest) {
      final request = options;
      _logRequest({
        'DioRequest(${request.method}): ${request.uri}': _mapData(request.data),
        if (canLogHeaders) 'Headers': request.headers,
      });
    }
    if (!handler.isCompleted) handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (canLogResponse) {
      _logResponse(_mapResponse(response));
    }
    if (!handler.isCompleted) handler.next(response);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) {
    if (canLogError) {
      _logError({
        'DioError(${err.type})': err.message,
        if (err.response != null) ..._mapResponse(err.response!),
        if (err is Error) 'DioErrorStackTrace': (err as Error).stackTrace,
      });
    }
    if (!handler.isCompleted) handler.next(err);
  }

  Map<String, dynamic> _mapHeaders(Map<String, List<String>> headers) {
    return headers.map((key, value) => MapEntry(key, value.length == 1 ? value.single : value));
  }

  Object _mapData(Object? data) {
    if (data == null) return 'No data';
    if (data is FormData) return Map.fromEntries(data.files);
    return data;
  }

  Map<String, dynamic> _mapResponse(Response response) {
    return {
      'DioResponse(${response.requestOptions.method}|${response.statusCode}): ${response.requestOptions.uri}':
          _mapData(response.data),
      if (canLogHeaders) 'Headers': _mapHeaders(response.headers.map),
    };
  }
}
