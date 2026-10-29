import '../../../core/network/api_client.dart';
import '../../cart/domain/cart_models.dart';
import '../domain/my_order_models.dart';
import '../domain/order_models.dart';
import '../domain/reorder_models.dart';

class OrderRepository {
  OrderRepository(this._api);

  final ApiClient _api;

  Future<CheckoutOptions> options() async {
    final json = await _api.get<Map<String, dynamic>>('/orders/options');
    return CheckoutOptions.fromJson(json);
  }

  Future<PlacedOrder> create({
    required List<CartItem> items,
    required FulfillmentType fulfillment,
    required PaymentMethod paymentMethod,
    required DateTime scheduledAt,
    required String phone,
    String? address,
    String? note,
    String? promoCode,
  }) async {
    final json = await _api.post<Map<String, dynamic>>('/orders', body: {
      'items': [
        for (final i in items)
          {'productId': i.productId, 'variantIds': i.variantIds, 'quantity': i.quantity},
      ],
      'fulfillment': fulfillment.api,
      'paymentMethod': paymentMethod.api,
      'scheduledAt': scheduledAt.toUtc().toIso8601String(),
      'phone': phone,
      if (fulfillment == FulfillmentType.delivery && address != null && address.isNotEmpty) 'address': address,
      if (note != null && note.isNotEmpty) 'customerNote': note,
      if (promoCode != null && promoCode.isNotEmpty) 'promoCode': promoCode,
    });
    return PlacedOrder.fromJson(json);
  }

  Future<List<MyOrder>> myOrders({required int page, int limit = 20}) async {
    final data = await _api.get<List<dynamic>>('/orders', query: {'page': page, 'limit': limit});
    return data.map((e) => MyOrder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MyOrder> myOrder(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/orders/$id');
    return MyOrder.fromJson(json);
  }

  Future<MyOrder> cancel(String id) async {
    final json = await _api.post<Map<String, dynamic>>('/orders/$id/cancel');
    return MyOrder.fromJson(json);
  }

  /// «Qayta buyurtma»: topshirilgan buyurtmadagi mahsulotlar hozirgi narx va mavjudlik bilan.
  Future<ReorderResult> reorder(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/orders/$id/reorder');
    return ReorderResult.fromJson(json);
  }

  /// Onlayn to'lov sahifasi manzilini oladi (oldindan to'lash ham, olayotganda to'lash ham shu yo'ldan).
  Future<String> startPayment(String orderId) async {
    final json = await _api.post<Map<String, dynamic>>('/payments/orders/$orderId/start');
    return json['url'] as String;
  }
}
