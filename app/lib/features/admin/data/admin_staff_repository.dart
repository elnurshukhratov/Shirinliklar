import '../../../core/network/api_client.dart';
import '../domain/staff_models.dart';

class AdminStaffRepository {
  AdminStaffRepository(this._api);

  final ApiClient _api;

  Future<List<StaffMember>> list() async {
    final data = await _api.get<List<dynamic>>('/admin/staff');
    return data.map((e) => StaffMember.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<StaffMember> add(String email) async {
    final json = await _api.post<Map<String, dynamic>>('/admin/staff', body: {'email': email});
    return StaffMember.fromJson(json);
  }

  Future<void> remove(String id) async {
    await _api.delete<Map<String, dynamic>>('/admin/staff/$id');
  }
}
