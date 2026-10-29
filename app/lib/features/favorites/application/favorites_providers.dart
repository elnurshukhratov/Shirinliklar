import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/favorites_repository.dart';
import '../../../core/network/load_more_cooldown.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => FavoritesRepository(ref.watch(apiClientProvider)),
);

/// Mijozning sevimli mahsulotlari id'lari. Yurakcha bosilganda darhol o'zgaradi,
/// server xato qaytarsa oldingi holatga qaytadi.
class FavoriteIdsController extends StateNotifier<Set<String>> {
  FavoriteIdsController(this._repo) : super(const {}) {
    _load();
  }

  final FavoritesRepository _repo;
  bool _touched = false;

  Future<void> _load() async {
    try {
      final ids = await _repo.ids();
      if (!mounted || _touched) return;
      state = ids.toSet();
    } catch (_) {
      // Yurakchalar bo'sh ko'rinadi; keyingi bosishda holat serverdan to'g'rilanadi.
    }
  }

  Future<void> toggle(String productId) async {
    _touched = true;
    final wasFavorite = state.contains(productId);
    state = wasFavorite ? ({...state}..remove(productId)) : {...state, productId};
    try {
      if (wasFavorite) {
        await _repo.remove(productId);
      } else {
        await _repo.add(productId);
      }
    } catch (_) {
      if (mounted) {
        state = wasFavorite ? {...state, productId} : ({...state}..remove(productId));
      }
      rethrow;
    }
  }
}

final favoriteIdsProvider = StateNotifierProvider<FavoriteIdsController, Set<String>>((ref) {
  // Foydalanuvchi almashganda ro'yxat qaytadan yuklanadi.
  ref.watch(authControllerProvider.select((s) => s.user?.id));
  return FavoriteIdsController(ref.watch(favoritesRepositoryProvider));
});

@immutable
class FavoritesListState {
  const FavoritesListState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<CatalogProduct> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  FavoritesListState copyWith({
    List<CatalogProduct>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return FavoritesListState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Profildagi «Sevimlilar» ro'yxati (sahifalab yuklanadi).
class FavoritesListController extends StateNotifier<FavoritesListState> {
  FavoritesListController(this._repo) : super(const FavoritesListState()) {
    refresh();
  }

  static const _limit = 20;
  final FavoritesRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.list(page: 1, limit: _limit);
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
      final rows = await _repo.list(page: next, limit: _limit);
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

  /// Yurakcha o'chirilganda mahsulot ro'yxatdan darhol olib tashlanadi.
  void removeLocal(String productId) {
    state = state.copyWith(items: state.items.where((e) => e.id != productId).toList());
  }
}

final favoritesListProvider =
    StateNotifierProvider.autoDispose<FavoritesListController, FavoritesListState>(
  (ref) => FavoritesListController(ref.watch(favoritesRepositoryProvider)),
);
