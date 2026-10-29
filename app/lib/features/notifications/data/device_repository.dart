import '../../../core/network/api_client.dart';

class DeviceRepository {
  DeviceRepository(this._api);

  final ApiClient _api;

  Future<void> register({required String token, required String platform, required String language}) async {
    await _api.post<Map<String, dynamic>>('/devices', body: {
      'token': token,
      'platform': platform,
      'language': language,
    });
  }

  Future<void> unregister(String token) async {
    await _api.post<Map<String, dynamic>>('/devices/unregister', body: {'token': token});
  }
}

class StockAlertRepository {
  StockAlertRepository(this._api);

  final ApiClient _api;

  Future<bool> isSubscribed(String productId) async {
    final json = await _api.get<Map<String, dynamic>>('/stock-alerts/$productId');
    return json['subscribed'] == true;
  }

  Future<void> subscribe(String productId) async {
    await _api.put<Map<String, dynamic>>('/stock-alerts/$productId');
  }

  Future<void> unsubscribe(String productId) async {
    await _api.delete<Map<String, dynamic>>('/stock-alerts/$productId');
  }
}
