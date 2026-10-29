import '../../../core/network/api_client.dart';
import '../domain/catalog_models.dart';

class CatalogRepository {
  CatalogRepository(this._api);

  final ApiClient _api;

  Future<List<CatalogCategory>> categories() async {
    final data = await _api.get<List<dynamic>>('/categories');
    return data.map((e) => CatalogCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<CatalogProduct>> products({
    String? search,
    String? categoryId,
    required int page,
    int limit = 20,
  }) async {
    final data = await _api.get<List<dynamic>>('/products', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (categoryId != null) 'categoryId': categoryId,
      'page': page,
      'limit': limit,
    });
    return data.map((e) => CatalogProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<CatalogProduct> product(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/products/$id');
    return CatalogProduct.fromJson(json);
  }
}
