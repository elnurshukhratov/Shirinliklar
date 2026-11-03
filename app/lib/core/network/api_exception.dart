class ApiException implements Exception {
  const ApiException({
    required this.code,
    required this.message,
    this.status,
    this.details,
    this.neverReachedServer = false,
  });

  final String code;
  final String message;
  final int? status;
  final Object? details;

  /// true — so'rov serverga umuman yetib bormagan (ulanish o'rnatilmagan), shuning uchun uni takrorlash xavfsiz.
  final bool neverReachedServer;

  @override
  String toString() => 'ApiException($code, $message)';
}