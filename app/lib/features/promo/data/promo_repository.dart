import '../../../core/network/api_client.dart';
import '../domain/promo_models.dart';

class PromoRepository {
  PromoRepository(this._api);

  final ApiClient _api;

  /// Kodni tekshiradi. Yaroqsiz bo'lsa ApiException (PROMO_NOT_FOUND, PROMO_EXPIRED, PROMO_LIMIT_REACHED).
  Future<AppliedPromo> validate(String code, double subtotal) async {
    final json = await _api.post<Map<String, dynamic>>(
      '/promo/validate',
      body: {'code': code, 'subtotal': subtotal},
    );
    return AppliedPromo.fromJson(json);
  }
}
