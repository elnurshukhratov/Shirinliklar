import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/admin_repository.dart';
import '../domain/admin_models.dart';
import '../../../core/network/load_more_cooldown.dart';

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(apiClientProvider)),
);

final adminCategoriesProvider = FutureProvider.autoDispose<List<AdminCategory>>(
  (ref) => ref.watch(adminRepositoryProvider).categories(),
);

@immutable
class ProductListState {
  const ProductListState({
    this.items = const [],
    this.search = '',
    this.showHidden = false,
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<AdminProduct> items;
  final String search;
  final bool showHidden;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  ProductListState copyWith({
    List<AdminProduct>? items,
    String? search,
    bool? showHidden,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return ProductListState(
      items: items ?? this.items,
      search: search ?? this.search,
      showHidden: showHidden ?? this.showHidden,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductListController extends StateNotifier<ProductListState> {
  ProductListController(this._repo) : super(const ProductListState()) {
    refresh();
  }

  static const _limit = 20;
  final AdminRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.products(
        search: state.search,
        showHidden: state.showHidden,
        page: 1,
        limit: _limit,
      );
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
      final rows = await _repo.products(
        search: state.search,
        showHidden: state.showHidden,
        page: next,
        limit: _limit,
      );
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

  void setSearch(String value) {
    final v = value.trim();
    if (v == state.search) return;
    state = state.copyWith(search: v);
    refresh();
  }

  void setShowHidden(bool value) {
    if (value == state.showHidden) return;
    state = state.copyWith(showHidden: value);
    refresh();
  }

  /// Mahsulot o'zgargach ro'yxatni qayta yuklamasdan yangilaydi.
  void applyUpdated(AdminProduct p) {
    if (!state.showHidden && !p.isActive) {
      remove(p.id);
      return;
    }
    state = state.copyWith(items: [for (final e in state.items) e.id == p.id ? p : e]);
  }

  void remove(String id) {
    state = state.copyWith(items: state.items.where((e) => e.id != id).toList());
  }
}

final adminProductListProvider =
    StateNotifierProvider.autoDispose<ProductListController, ProductListState>(
  (ref) => ProductListController(ref.watch(adminRepositoryProvider)),
);