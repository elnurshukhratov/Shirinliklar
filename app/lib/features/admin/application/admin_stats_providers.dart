import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/admin_stats_repository.dart';
import '../domain/admin_stats_models.dart';

final adminStatsRepositoryProvider = Provider<AdminStatsRepository>(
  (ref) => AdminStatsRepository(ref.watch(apiClientProvider)),
);

final adminStatsOverviewProvider = FutureProvider.autoDispose<StatsOverview>(
  (ref) => ref.watch(adminStatsRepositoryProvider).overview(),
);

final adminCustomersProvider = FutureProvider.autoDispose<List<CustomerStat>>(
  (ref) => ref.watch(adminStatsRepositoryProvider).customers(),
);
