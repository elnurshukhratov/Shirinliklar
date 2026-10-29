import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/admin_staff_repository.dart';
import '../domain/staff_models.dart';

final adminStaffRepositoryProvider = Provider<AdminStaffRepository>(
  (ref) => AdminStaffRepository(ref.watch(apiClientProvider)),
);

final adminStaffProvider = FutureProvider.autoDispose<List<StaffMember>>(
  (ref) => ref.watch(adminStaffRepositoryProvider).list(),
);
