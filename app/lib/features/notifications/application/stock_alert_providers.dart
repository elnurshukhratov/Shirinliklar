import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/device_repository.dart';

final stockAlertRepositoryProvider = Provider<StockAlertRepository>(
  (ref) => StockAlertRepository(ref.watch(apiClientProvider)),
);

/// Mijoz shu tugagan mahsulot qaytganda xabar olishga obuna bo'lganmi.
final stockAlertProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, productId) => ref.watch(stockAlertRepositoryProvider).isSubscribed(productId),
);
