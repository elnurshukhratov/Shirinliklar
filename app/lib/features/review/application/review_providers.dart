import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../catalog/application/catalog_providers.dart';
import '../data/review_repository.dart';
import '../domain/review_models.dart';
import '../../../core/network/load_more_cooldown.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>(
  (ref) => ReviewRepository(ref.watch(apiClientProvider)),
);

final adminReviewsRepositoryProvider = Provider<AdminReviewsRepository>(
  (ref) => AdminReviewsRepository(ref.watch(apiClientProvider)),
);

/// Mijozning shu mahsulotga sharhi va sharh qoldirish huquqi.
final myReviewStateProvider = FutureProvider.autoDispose.family<MyReviewState, String>(
  (ref, productId) => ref.watch(reviewRepositoryProvider).mine(productId),
);

/// Sharh o'zgargach mahsulot sahifasi, katalog kartalari (o'rtacha baho) va sharhlar yangilanadi.
void refreshAfterReviewChange(WidgetRef ref, String productId) {
  ref.invalidate(myReviewStateProvider(productId));
  ref.invalidate(productReviewsProvider(productId));
  ref.invalidate(catalogProductProvider(productId));
  ref.invalidate(catalogListProvider);
}

@immutable
class ProductReviewsState {
  const ProductReviewsState({
    this.items = const [],
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<Review> items;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  ProductReviewsState copyWith({
    List<Review>? items,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return ProductReviewsState(
      items: items ?? this.items,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class ProductReviewsController extends StateNotifier<ProductReviewsState> {
  ProductReviewsController(this._repo, this._productId) : super(const ProductReviewsState()) {
    refresh();
  }

  static const _limit = 10;
  final ReviewRepository _repo;
  final String _productId;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.productReviews(_productId, page: 1, limit: _limit);
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
      final rows = await _repo.productReviews(_productId, page: next, limit: _limit);
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

final productReviewsProvider =
    StateNotifierProvider.autoDispose.family<ProductReviewsController, ProductReviewsState, String>(
  (ref, productId) => ProductReviewsController(ref.watch(reviewRepositoryProvider), productId),
);

@immutable
class AdminReviewListState {
  const AdminReviewListState({
    this.items = const [],
    this.visibility = ReviewVisibility.all,
    this.page = 1,
    this.hasMore = true,
    this.loading = true,
    this.loadingMore = false,
    this.error,
  });

  final List<AdminReview> items;
  final ReviewVisibility visibility;
  final int page;
  final bool hasMore;
  final bool loading;
  final bool loadingMore;
  final Object? error;

  AdminReviewListState copyWith({
    List<AdminReview>? items,
    ReviewVisibility? visibility,
    int? page,
    bool? hasMore,
    bool? loading,
    bool? loadingMore,
    Object? error,
    bool clearError = false,
  }) {
    return AdminReviewListState(
      items: items ?? this.items,
      visibility: visibility ?? this.visibility,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
      loading: loading ?? this.loading,
      loadingMore: loadingMore ?? this.loadingMore,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AdminReviewListController extends StateNotifier<AdminReviewListState> {
  AdminReviewListController(this._repo) : super(const AdminReviewListState()) {
    refresh();
  }

  static const _limit = 20;
  final AdminReviewsRepository _repo;
  int _token = 0;

  Future<void> refresh() async {
    final token = ++_token;
    state = state.copyWith(loading: true, loadingMore: false, clearError: true);
    try {
      final rows = await _repo.list(visibility: state.visibility, page: 1, limit: _limit);
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
      final rows = await _repo.list(visibility: state.visibility, page: next, limit: _limit);
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

  void setVisibility(ReviewVisibility v) {
    if (v == state.visibility) return;
    state = state.copyWith(visibility: v, items: const []);
    refresh();
  }

  /// Serverdan kelgan yangilangan sharhni ro'yxatdagi o'rniga qo'yadi.
  /// Tanlangan filtrga endi mos kelmasa, ro'yxatdan olib tashlanadi.
  void replace(AdminReview updated) {
    final v = state.visibility;
    final keep = v == ReviewVisibility.all ||
        (v == ReviewVisibility.hidden && updated.isHidden) ||
        (v == ReviewVisibility.visible && !updated.isHidden);
    state = state.copyWith(
      items: [
        for (final r in state.items)
          if (r.id != updated.id)
            r
          else if (keep)
            updated,
      ],
    );
  }
}

final adminReviewListProvider =
    StateNotifierProvider.autoDispose<AdminReviewListController, AdminReviewListState>(
  (ref) => AdminReviewListController(ref.watch(adminReviewsRepositoryProvider)),
);
