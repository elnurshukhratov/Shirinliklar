import '../../../core/network/api_client.dart';
import '../domain/cart_models.dart';

class CartRepository {
  CartRepository(this._api);

  final ApiClient _api;

  /// Savatni server bilan narx va mavjudlik bo'yicha tekshiradi.
  Future<List<CartCheck>> validate(List<CartItem> items) async {
    final data = await _api.post<Map<String, dynamic>>('/cart/validate', body: {
      'items': [
        for (final i in items)
          {
            'key': i.key,
            'productId': i.productId,
            'variantIds': i.variantIds,
            'quantity': i.quantity,
          },
      ],
    });
    return (data['items'] as List).map((e) => CartCheck.fromJson(e as Map<String, dynamic>)).toList();
  }
}
