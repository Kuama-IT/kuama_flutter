import 'package:dio/dio.dart';
import 'package:kuama_flutter/src/shared/utils/pretty_formatter.dart';
import 'package:logging/logging.dart';

class LoggerInterceptor with Interceptor {
  final Logger logger;

  final bool canHeaders;

  LoggerInterceptor({
    Logger? logger,
    this.canHeaders = true,
  }) : logger = logger ?? Logger('Kuama.Data.Dio');

  void show(Map<String, dynamic> msg) {
    logger.finer(PrettyObject(msg));
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final request = options;
    show({
      'Request(${request.method}): ${request.uri}': _mapData(request.data),
      if (canHeaders) 'Headers': request.headers,
    });
    if (!handler.isCompleted) handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    show(_mapResponse(response));
    if (!handler.isCompleted) handler.next(response);
  }

  @override
  void onError(DioError error, ErrorInterceptorHandler handler) {
    show({
      'DioError(${error.type})': error.message,
      if (error is Error) 'StackTrace': (error as Error).stackTrace,
      if (error.response != null) ..._mapResponse(error.response!),
    });
    if (!handler.isCompleted) handler.next(error);
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
      'Response(${response.requestOptions.method}|${response.statusCode}): ${response.requestOptions.uri}':
          _mapData(response.data),
      if (canHeaders) 'Headers': _mapHeaders(response.headers.map),
    };
  }
}
