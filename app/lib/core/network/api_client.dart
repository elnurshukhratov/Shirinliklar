import 'package:dio/dio.dart';

import '../config/app_config.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();

/// So'rov vaqtinchalik xatoga uchraganda (server qayta ishga tushayotgan paytda) qanday qayta uriniladi.
enum RetryPolicy {
  /// Qayta urinilmaydi.
  none,

  /// Faqat ulanish o'rnatilmagan bo'lsa (so'rov serverga yetmagan) — har qanday so'rov uchun xavfsiz.
  connectOnly,

  /// Ulanish xatosi, vaqt tugashi va 502/503/504 — faqat takrorlanganda zarar qilmaydigan so'rovlar (GET, login).
  idempotent,
}

/// Qayta urinishlar orasidagi kutish: server qayta ishga tushishiga vaqt beradi (jami ~14 soniya).
const _retryDelays = [Duration(seconds: 1), Duration(seconds: 3), Duration(seconds: 5), Duration(seconds: 5)];

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
      _send<T>(() => _dio.get(path, queryParameters: query), retry: RetryPolicy.idempotent);

  /// [retry] — login kabi takrorlash xavfsiz so'rovlar uchun [RetryPolicy.idempotent] bering.
  Future<T> post<T>(String path, {Object? body, RetryPolicy retry = RetryPolicy.connectOnly}) =>
      _send<T>(() => _dio.post(path, data: body), retry: retry);

  Future<T> put<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.put(path, data: body));

  Future<T> patch<T>(String path, {Object? body}) =>
      _send<T>(() => _dio.patch(path, data: body));

  Future<T> delete<T>(String path) => _send<T>(() => _dio.delete(path));

  Future<T> _send<T>(
    Future<Response<dynamic>> Function() request, {
    RetryPolicy retry = RetryPolicy.none,
  }) async {
    var attempt = 0;
    while (true) {
      try {
        return await _sendOnce<T>(request);
      } on ApiException catch (e) {
        if (attempt >= _retryDelays.length || !_shouldRetry(e, retry)) rethrow;
        await Future<void>.delayed(_retryDelays[attempt]);
        attempt += 1;
      }
    }
  }

  bool _shouldRetry(ApiException e, RetryPolicy policy) {
    switch (policy) {
      case RetryPolicy.none:
        return false;
      case RetryPolicy.connectOnly:
        return e.code == 'NETWORK_ERROR' && e.neverReachedServer;
      case RetryPolicy.idempotent:
        return e.code == 'NETWORK_ERROR' || e.code == 'SERVICE_UNAVAILABLE' || e.code == 'SERVER_RESTARTING';
    }
  }

  Future<T> _sendOnce<T>(Future<Response<dynamic>> Function() request) async {
    try {
      final response = await request();
      final body = response.data;
      if (body is Map<String, dynamic> && body['success'] == true) {
        return body['data'] as T;
      }
      throw const ApiException(code: 'BAD_RESPONSE', message: 'BAD_RESPONSE');
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final body = e.response?.data;
      if (body is Map<String, dynamic> && body['error'] is Map<String, dynamic>) {
        final err = body['error'] as Map<String, dynamic>;
        throw ApiException(
          code: (err['code'] ?? 'UNKNOWN').toString(),
          message: (err['message'] ?? 'UNKNOWN').toString(),
          status: status,
          details: err['details'],
        );
      }
      // Server qayta ishga tushayotganda proxy (nginx/Caddy) JSON emas, HTML bilan 502/503/504 qaytaradi.
      if (status == 502 || status == 503 || status == 504) {
        throw ApiException(code: 'SERVICE_UNAVAILABLE', message: 'SERVER_RESTARTING', status: status);
      }
      final neverReached = e.type == DioExceptionType.connectionError || e.type == DioExceptionType.connectionTimeout;
      final isNetwork = neverReached ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
      throw ApiException(
        code: isNetwork ? 'NETWORK_ERROR' : 'UNKNOWN',
        message: isNetwork ? 'NETWORK_ERROR' : 'UNKNOWN',
        status: status,
        neverReachedServer: neverReached,
      );
    }
  }
}