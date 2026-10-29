import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/network/api_client.dart';
import '../domain/admin_models.dart';

class AdminRepository {
  AdminRepository(this._api);

  final ApiClient _api;

  // ---- Mahsulotlar ----

  Future<List<AdminProduct>> products({
    String? search,
    required bool showHidden,
    required int page,
    int limit = 20,
  }) async {
    final data = await _api.get<List<dynamic>>('/admin/products', query: {
      if (search != null && search.isNotEmpty) 'search': search,
      if (!showHidden) 'isActive': 'true',
      'page': page,
      'limit': limit,
    });
    return data.map((e) => AdminProduct.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminProduct> product(String id) async {
    final json = await _api.get<Map<String, dynamic>>('/admin/products/$id');
    return AdminProduct.fromJson(json);
  }

  /// [id] bo'lsa tahrirlanadi, bo'lmasa yangi mahsulot yaratiladi.
  Future<AdminProduct> saveProduct({String? id, required Map<String, dynamic> body}) async {
    final json = id == null
        ? await _api.post<Map<String, dynamic>>('/admin/products', body: body)
        : await _api.patch<Map<String, dynamic>>('/admin/products/$id', body: body);
    return AdminProduct.fromJson(json);
  }

  Future<AdminProduct> setProductActive(String id, bool isActive) async {
    final json = await _api.patch<Map<String, dynamic>>('/admin/products/$id', body: {'isActive': isActive});
    return AdminProduct.fromJson(json);
  }

  Future<void> deleteProduct(String id) async {
    await _api.delete<Map<String, dynamic>>('/admin/products/$id');
  }

  Future<List<String>> uploadImages(List<XFile> files) async {
    final form = FormData();
    for (final f in files) {
      form.files.add(MapEntry(
        'images',
        await MultipartFile.fromFile(
          f.path,
          filename: f.name,
          contentType: DioMediaType.parse(_mimeFor(f.name)),
        ),
      ));
    }
    final data = await _api.post<Map<String, dynamic>>('/admin/uploads/images', body: form);
    return (data['urls'] as List).cast<String>();
  }

  String _mimeFor(String name) {
    final lower = name.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  // ---- Toifalar ----

  Future<List<AdminCategory>> categories() async {
    final data = await _api.get<List<dynamic>>('/admin/categories');
    return data.map((e) => AdminCategory.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminCategory> saveCategory({String? id, required Map<String, dynamic> body}) async {
    final json = id == null
        ? await _api.post<Map<String, dynamic>>('/admin/categories', body: body)
        : await _api.patch<Map<String, dynamic>>('/admin/categories/$id', body: body);
    return AdminCategory.fromJson(json);
  }

  Future<void> deleteCategory(String id) async {
    await _api.delete<Map<String, dynamic>>('/admin/categories/$id');
  }
}