import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../order/domain/order_models.dart';
import '../data/admin_orders_repository.dart';
import '../domain/admin_order_models.dart';
import '../../../core/network/load_more_cooldown.dart';

final adminOrdersRepositoryProvider = Provider<AdminOrdersRepository>(
  (ref) => AdminOrdersRepository(ref.watch(apiClientProvider)),
);

final adminOrderDetailProvider = FutureProvider.autoDispose.family<AdminOrder, String>(
  (ref, id) => ref.watch(adminOrdersRepositoryProvider).order(id),
);

@immutable
class AdminOrderListState {
  const AdminOrderListState({
    this.items = const [],
    this.status,
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<AdminOrder> items;

  /// null — barcha holatlar.
  final OrderStatus? status;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  AdminOrderListState copyWith({
    List<AdminOrder>? items,
    OrderStatus? status,
    bool clearStatus = false,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return AdminOrderListState(
      items: items ?? this.items,
      status: clearStatus ? null : (status ?? this.status),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AdminOrderListController extends StateNotifier<AdminOrderListState> {
  AdminOrderListController(this._repo) : super(const AdminOrderListState()) {
    refresh();
  }

  static const _limit = 20;
  final AdminOrdersRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.orders(status: state.status, page: 1, limit: _limit);
      if (!mounted || token != _token) return;
      state = state.copyWith(items: rows, page: 1, hasMore: rows.length >= _limit, loading: false);
    } catch (e) {
      if (!mounted || token != _token) return;
      state = state.copyWith(loading: false, error: e);
    }
  }

  final _cooldown = LoadMoreCooldown();

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore || state.error != null || _cooldown.active) return;
    final token = _token;
    final next = state.page + 1;
    state = state.copyWith(loadingMore: true);
    try {
      final rows = await _repo.orders(status: state.status, page: next, limit: _limit);
      if (!mounted || token != _token) return;
      final known = state.items.map((e) => e.id).toSet();
      state = state.copyWith(
        items: [...state.items, ...rows.where((e) => !known.contains(e.id))],
        page: next,
        hasMore: rows.length >= _limit,
        loadingMore: false,
      );
    } catch (_) {
      if (!mounted || token != _token) return;
      state = state.copyWith(loadingMore: false);
      _cooldown.fail();
    }
  }

  void setStatus(OrderStatus? status) {
    if (status == state.status) return;
    state = state.copyWith(status: status, clearStatus: status == null, items: const []);
    refresh();
  }

  /// Buyurtma o'zgargach ro'yxatni qayta yuklamasdan yangilaydi (filtrga mos kelmasa olib tashlaydi).
  void applyUpdated(AdminOrder order) {
    final filter = state.status;
    if (filter != null && order.status != filter) {
      state = state.copyWith(items: state.items.where((e) => e.id != order.id).toList());
      return;
    }
    state = state.copyWith(items: [for (final e in state.items) e.id == order.id ? order : e]);
  }
}

final adminOrderListProvider =
    StateNotifierProvider.autoDispose<AdminOrderListController, AdminOrderListState>(
  (ref) => AdminOrderListController(ref.watch(adminOrdersRepositoryProvider)),
);
