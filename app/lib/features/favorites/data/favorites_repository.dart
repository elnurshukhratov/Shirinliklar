import '../../../core/network/api_client.dart';
import '../../catalog/domain/catalog_models.dart';

class FavoritesRepository {
  FavoritesRepository(this._api);

  final ApiClient _api;

  Future<List<String>> ids() async {
    final data = await _api.get<List<dynamic>>('/favorites/ids');
    return data.cast<String>();
  }

  Future<List<CatalogProduct>> list({required int page, int limit = 20}) async {
    final data = await _api.get<List<dynamic>>('/favorites', query: {'page': page, 'limit': limit});
    return data.map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> add(String productId) async {
    await _api.put<Map<String, dynamic>>('/favorites/$productId');
  }

  Future<void> remove(String productId) async {
    await _api.delete<Map<String, dynamic>>('/favorites/$productId');
  }
}
