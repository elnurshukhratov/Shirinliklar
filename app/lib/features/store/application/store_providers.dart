import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/store_repository.dart';

final storeRepositoryProvider = Provider<StoreRepository>(
  (ref) => StoreRepository(ref.watch(apiClientProvider)),
);

final storeStatusProvider = FutureProvider.autoDispose<StoreStatus>(
  (ref) => ref.watch(storeRepositoryProvider).status(),
);
