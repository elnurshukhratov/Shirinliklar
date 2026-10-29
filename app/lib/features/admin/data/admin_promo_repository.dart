import '../../../core/network/api_client.dart';
import '../domain/admin_promo_models.dart';

class AdminPromoRepository {
  AdminPromoRepository(this._api);

  final ApiClient _api;

  Future<List<AdminPromo>> list() async {
    final data = await _api.get<List<dynamic>>('/admin/promos', query: {'page': 1, 'limit': 100});
    return data.map((e) => AdminPromo.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// [id] bo'lsa tahrirlanadi, bo'lmasa yangi promokod yaratiladi.
  Future<AdminPromo> save({String? id, required Map<String, dynamic> body}) async {
    final json = id == null
        ? await _api.post<Map<String, dynamic>>('/admin/promos', body: body)
        : await _api.patch<Map<String, dynamic>>('/admin/promos/$id', body: body);
    return AdminPromo.fromJson(json);
  }

  Future<void> delete(String id) async {
    await _api.delete<Map<String, dynamic>>('/admin/promos/$id');
  }
}
