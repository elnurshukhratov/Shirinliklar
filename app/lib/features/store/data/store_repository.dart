import '../../../core/network/api_client.dart';

class StoreStatus {
  const StoreStatus({required this.acceptingOrders, this.pausedUntil});

  factory StoreStatus.fromJson(Map<String, dynamic> json) => StoreStatus(
        acceptingOrders: json['acceptingOrders'] != false,
        pausedUntil:
            json['pausedUntil'] == null ? null : DateTime.parse(json['pausedUntil'] as String).toLocal(),
      );

  final bool acceptingOrders;
  final DateTime? pausedUntil;
}

class StoreRepository {
  StoreRepository(this._api);

  final ApiClient _api;

  Future<StoreStatus> status() async {
    final json = await _api.get<Map<String, dynamic>>('/store/status');
    return StoreStatus.fromJson(json);
  }

  /// Admin: «bugun buyurtma qabul qilmaymiz» (paused = true) yoki qaytadan qabul qilish.
  Future<StoreStatus> setPaused(bool paused) async {
    final json = await _api.post<Map<String, dynamic>>('/admin/store/${paused ? 'pause' : 'resume'}');
    return StoreStatus.fromJson(json);
  }
}
