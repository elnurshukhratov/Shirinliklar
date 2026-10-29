import '../../../core/network/api_client.dart';
import '../../order/domain/order_models.dart';
import '../domain/admin_order_models.dart';

class AdminOrdersRepository {
  AdminOrdersRepository(this._api);

  final ApiClient _api;

  Future<List<AdminOrder>> orders({OrderStatus? status, required int page, int limit = 20}) async {
    final data = await _api.get<List<dynamic>>('/admin/orders', query: {
      if (status != null) 'status': status.api,
      'page': page,
      'limit': limit,
    });
    return data.map((e) => AdminOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminOrder> order(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/admin/orders/$id');
    return AdminOrder.fromJson(json);
  }

  /// [to] — keyingi holat: accepted, ready, onTheWay yoki delivered.
  Future<AdminOrder> advance(String id, OrderStatus to) async {
    final path = switch (to) {
      OrderStatus.accepted => 'accept',
      OrderStatus.ready => 'ready',
      OrderStatus.onTheWay => 'on-the-way',
      OrderStatus.delivered => 'delivered',
      _ => throw ArgumentError('Unsupported status: $to'),
    };
    final json = await _api.post<Map<String, dynamic>>('/admin/orders/$id/$path');
    return AdminOrder.fromJson(json);
  }

  Future<AdminOrder> cancel(String id, String reason) async {
    final json = await _api.post<Map<String, dynamic>>('/admin/orders/$id/cancel', body: {'reason': reason});
    return AdminOrder.fromJson(json);
  }

  Future<AdminOrder> refund(String id) async {
    final json = await _api.post<Map<String, dynamic>>('/admin/orders/$id/refund');
    return AdminOrder.fromJson(json);
  }
}
