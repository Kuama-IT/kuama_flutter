import 'dart:async';

import 'package:dio/dio.dart';

class AsyncDio {
  final Dio _dio;

  AsyncDio({
    Dio? dio,
  }) : _dio = dio ?? Dio();

  /// [Dio.options]
  BaseOptions get options => _dio.options;
  set options(BaseOptions options) => _dio.options = options;

  /// [Dio.interceptors]
  Interceptors get interceptors => _dio.interceptors;

  /// [Dio.httpClientAdapter]
  HttpClientAdapter get httpClientAdapter => _dio.httpClientAdapter;
  set httpClientAdapter(HttpClientAdapter httpClientAdapter) =>
      _dio.httpClientAdapter = httpClientAdapter;

  /// [Dio.transformer]
  Transformer get transformer => _dio.transformer;
  set transformer(Transformer transformer) => _dio.transformer = transformer;

  /// [Dio.close]
  void close({bool force = false}) => _dio.close(force: force);

  /// [Dio.get]
  Stream<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'GET'),
    );
  }

  /// [Dio.post]
  Stream<Response<T>> post<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'POST'),
    );
  }

  /// [Dio.put]
  Stream<Response<T>> put<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'PUT'),
    );
  }

  /// [Dio.head]
  Stream<Response<T>> head<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'HEAD'),
    );
  }

  /// [Dio.delete]
  Stream<Response<T>> delete<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'DELETE'),
    );
  }

  /// [Dio.patch]
  Stream<Response<T>> patch<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return request(
      path,
      data: data,
      queryParameters: queryParameters,
      options: (options ?? Options()).copyWith(method: 'PATH'),
    );
  }

  static bool canEmitSendProgress = false;
  static bool canEmitReceiveProgress = false;

  /// [Dio.request]
  Stream<Response<T>> request<T>(
    String path, {
    data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool? canEmitSendProgress,
    bool? canEmitReceiveProgress,
  }) {
    final subject = StreamController<Response<T>>.broadcast();

    late final CancelToken cancelToken;
    subject
      ..onListen = () async {
        cancelToken = CancelToken();
        try {
          final resp = await _dio.request<T>(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
            cancelToken: cancelToken,
          );
          if (subject.isClosed) return;
          subject.add(resp);
        } catch (error, stackTrace) {
          if (subject.isClosed) rethrow;
          subject.addError(error, stackTrace);
        } finally {
          await subject.close();
        }
      }
      ..onCancel = () async {
        cancelToken.cancel();
        await subject.close();
      };

    return subject.stream;
  }
}
