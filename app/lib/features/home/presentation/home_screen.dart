import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_shell.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass/reveal.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import '../../store/presentation/store_closed_banner.dart';
import 'widgets/home_categories.dart';
import 'widgets/home_header.dart';
import 'widgets/home_hero.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 400) {
        ref.read(catalogListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Tanlangan: yuklangan mahsulotlar ichidan mavjudlari, baho bo'yicha (baho yo'q bo'lsa — ro'yxat tartibida).
  List<CatalogProduct> _featured(List<CatalogProduct> items) {
    final available = items.where((p) => p.inStock).toList();
    final indexed = {for (var i = 0; i < available.length; i++) available[i].id: i};
    available.sort((a, b) {
      final byRating = b.averageRating.compareTo(a.averageRating);
      return byRating != 0 ? byRating : indexed[a.id]!.compareTo(indexed[b.id]!);
    });
    return available.take(6).toList();
  }

  void _scrollToTop() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      0,
      duration: AppMotion.of(context, AppMotion.slow),
      curve: AppMotion.curve,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(catalogListProvider);
    final notifier = ref.read(catalogListProvider.notifier);
    final categories = ref.watch(catalogCategoriesProvider).valueOrNull ?? const <CatalogCategory>[];
    final user = ref.watch(authControllerProvider).user;
    final lang = Localizations.localeOf(context).languageCode;

    // Bosh tab qayta bosilganda ro'yxat tepaga aylanadi (dock'dagi tab qayta bosilishi).
    ref.listen<(int, int)>(tabReselectedProvider, (prev, next) {
      if (next.$1 == 0) _scrollToTop();
    });

    final showHome = state.search.isEmpty && state.categoryId == null;
    final featured = showHome ? _featured(state.items) : const <CatalogProduct>[];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: RefreshIndicator(
          onRefresh: notifier.refresh,
          edgeOffset: MediaQuery.paddingOf(context).top,
          child: CustomScrollView(
            controller: _scroll,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: HomeTopBar(user: user)),
              const SliverToBoxAdapter(child: HomeSearchPill()),
              const SliverToBoxAdapter(
                child: StoreClosedBanner(
                  margin: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                ),
              ),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(child: HomeHero(products: featured, lang: lang)),
              SliverToBoxAdapter(
                child: HomeCategories(
                  categories: categories,
                  selectedId: state.categoryId,
                  onSelect: notifier.setCategory,
                ),
              ),
              if (state.loading && state.items.isNotEmpty)
                const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
              ..._content(context, state, notifier),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, CatalogListState state, CatalogListController notifier) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom + AppSpacing.lg;

    if (state.loading && state.items.isEmpty) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, bottomInset),
          sliver: SliverMasonryGrid.count(
            crossAxisCount: 2,
            mainAxisSpacing: AppSpacing.lg,
            crossAxisSpacing: AppSpacing.md,
            childCount: 6,
            itemBuilder: (context, i) => SkeletonCard(aspectRatio: i.isEven ? 0.8 : 1),
          ),
        ),
      ];
    }

    if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: ErrorState(
              title: err.title,
              message: err.message,
              retryLabel: l10n.commonRetry,
              onRetry: notifier.refresh,
            ),
          ),
        ),
      ];
    }

    if (state.items.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: state.categoryId != null || state.search.isNotEmpty
                ? EmptyState(
                    title: l10n.noResultsTitle,
                    message: l10n.noResultsMessage,
                    icon: Icons.search_off_rounded,
                  )
                : EmptyState(title: l10n.catalogEmptyTitle, message: l10n.catalogEmptyMessage),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          state.loadingMore ? 0 : bottomInset,
        ),
        // 2 ustunli masonry: rasm balandliklari navbatma-navbat 4:5 va 1:1.
        sliver: SliverMasonryGrid.count(
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.lg,
          crossAxisSpacing: AppSpacing.md,
          childCount: state.items.length,
          itemBuilder: (context, i) {
            final product = state.items[i];
            return Reveal(
              key: ValueKey(product.id),
              index: i % 6,
              child: ProductCard(
                product: product,
                aspectRatio: i.isEven ? 0.8 : 1,
              ),
            );
          },
        ),
      ),
      if (state.loadingMore)
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, bottomInset),
            child: const Center(child: CircularProgressIndicator()),
          ),
        ),
    ];
  }
}