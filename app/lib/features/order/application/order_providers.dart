import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/order_repository.dart';
import '../domain/my_order_models.dart';
import '../domain/order_models.dart';
import '../../../core/network/load_more_cooldown.dart';

final orderRepositoryProvider = Provider<OrderRepository>(
  (ref) => OrderRepository(ref.watch(apiClientProvider)),
);

final checkoutOptionsProvider = FutureProvider.autoDispose<CheckoutOptions>(
  (ref) => ref.watch(orderRepositoryProvider).options(),
);

@immutable
class MyOrdersState {
  const MyOrdersState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<MyOrder> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  MyOrdersState copyWith({
    List<MyOrder>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return MyOrdersState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Mijozning "Buyurtmalarim" ro'yxati (sahifalab yuklanadi).
class MyOrdersController extends StateNotifier<MyOrdersState> {
  MyOrdersController(this._repo) : super(const MyOrdersState()) {
    refresh();
  }

  static const _limit = 20;
  final OrderRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.myOrders(page: 1, limit: _limit);
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
      final rows = await _repo.myOrders(page: next, limit: _limit);
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
}

final myOrdersProvider = StateNotifierProvider.autoDispose<MyOrdersController, MyOrdersState>(
  (ref) => MyOrdersController(ref.watch(orderRepositoryProvider)),
);

final myOrderDetailProvider = FutureProvider.autoDispose.family<MyOrder, String>(
  (ref, id) => ref.watch(orderRepositoryProvider).myOrder(id),
);
