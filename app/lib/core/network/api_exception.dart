class ApiException implements Exception {
  const ApiException({required this.code, required this.message, this.status, this.details});

  final String code;
  final String message;
  final int? status;
  final Object? details;

  @override
  String toString() => 'ApiException($code, $message)';
}
