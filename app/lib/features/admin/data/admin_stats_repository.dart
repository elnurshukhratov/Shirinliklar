import '../../../core/network/api_client.dart';
import '../domain/admin_stats_models.dart';

class AdminStatsRepository {
  AdminStatsRepository(this._api);

  final ApiClient _api;

  Future<StatsOverview> overview() async {
    final data = await _api.get<Map<String, dynamic>>('/admin/stats/overview');
    return StatsOverview.fromJson(data);
  }

  Future<List<CustomerStat>> customers() async {
    final data = await _api.get<List<dynamic>>('/admin/stats/customers', query: {'page': 1, 'limit': 50});
    return data.map((e) => CustomerStat.fromJson(e as Map<String, dynamic>)).toList();
  }
}
