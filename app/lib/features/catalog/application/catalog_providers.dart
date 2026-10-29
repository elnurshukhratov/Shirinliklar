import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/catalog_repository.dart';
import '../domain/catalog_models.dart';
import '../../../core/network/load_more_cooldown.dart';

final catalogRepositoryProvider = Provider<CatalogRepository>(
  (ref) => CatalogRepository(ref.watch(apiClientProvider)),
);

final catalogCategoriesProvider = FutureProvider.autoDispose<List<CatalogCategory>>(
  (ref) => ref.watch(catalogRepositoryProvider).categories(),
);

final catalogProductProvider = FutureProvider.autoDispose.family<CatalogProduct, String>(
  (ref, id) => ref.watch(catalogRepositoryProvider).product(id),
);

@immutable
class CatalogListState {
  const CatalogListState({
    this.items = const [],
    this.search = '',
    this.categoryId,
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<CatalogProduct> items;
  final String search;
  final String? categoryId;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  CatalogListState copyWith({
    List<CatalogProduct>? items,
    String? search,
    String? categoryId,
    bool clearCategory = false,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return CatalogListState(
      items: items ?? this.items,
      search: search ?? this.search,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CatalogListController extends StateNotifier<CatalogListState> {
  CatalogListController(this._repo) : super(const CatalogListState()) {
    refresh();
  }

  static const _limit = 20;
  final CatalogRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.products(
        search: state.search,
        categoryId: state.categoryId,
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
        categoryId: state.categoryId,
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
    state = state.copyWith(search: v, items: const []);
    refresh();
  }

  void setCategory(String? id) {
    if (id == state.categoryId) return;
    state = id == null
        ? state.copyWith(clearCategory: true, items: const [])
        : state.copyWith(categoryId: id, items: const []);
    refresh();
  }
}

final catalogListProvider = StateNotifierProvider.autoDispose<CatalogListController, CatalogListState>(
  (ref) => CatalogListController(ref.watch(catalogRepositoryProvider)),
);
