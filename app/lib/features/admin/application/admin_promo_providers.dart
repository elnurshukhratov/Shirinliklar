import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/admin_promo_repository.dart';
import '../domain/admin_promo_models.dart';

final adminPromoRepositoryProvider = Provider<AdminPromoRepository>(
  (ref) => AdminPromoRepository(ref.watch(apiClientProvider)),
);

final adminPromosProvider = FutureProvider.autoDispose<List<AdminPromo>>(
  (ref) => ref.watch(adminPromoRepositoryProvider).list(),
);
