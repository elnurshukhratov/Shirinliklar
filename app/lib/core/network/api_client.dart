import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();

/// Backenddagi umumiy javob formatini ({success, data, meta | error}) o'qiydi.
class ApiClient {
  ApiClient({TokenProvider? tokenProvider, Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            )) {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final token = await tokenProvider?.call();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
  }

  final Dio _dio;

  Future<T> get<T>(String path, {Map<String, dynamic>? query}) =>
      _send<T>(() => _dio.get(path, queryParameters: query));

  Future<T> post<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.post(path, data: body));

  Future<T> put<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.put(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.patch(path, data: body));

  Future<T> delete<T>(String path) => _send<T>(() => _dio.delete(path));

  Future<T> _send<T>(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) {
        return body['data'] as T;
      }
      throw const ApiException(code: 'BAD_RESPONSE', message: 'BAD_RESPONSE');
    } on DioException catch (e) {
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
        final err = body['error'] as Map<String, dynamic>;
        throw ApiException(
          code: (err['code'] ?? 'UNKNOWN').toString(),
          message: (err['message'] ?? 'UNKNOWN').toString(),
          status: e.response?.statusCode,
          details: err['details'],
        );
      }
      final isNetwork = e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      throw ApiException(
        code: isNetwork ? 'NETWORK_ERROR' : 'UNKNOWN',
        message: isNetwork ? 'NETWORK_ERROR' : 'UNKNOWN',
        status: e.response?.statusCode,
      );
    }
  }
}
