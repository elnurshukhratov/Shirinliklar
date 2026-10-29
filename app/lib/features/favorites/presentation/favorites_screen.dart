import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import '../application/favorites_providers.dart';

/// Mijoz: profildagi «Sevimlilar» ro'yxati.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 400) {
        ref.read(favoritesListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  SliverGridDelegate _gridDelegate(BuildContext context, double width) {
    const columns = 2;
    final tileWidth = (width - AppSpacing.lg * 2 - AppSpacing.md * (columns - 1)) / columns;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.6);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      mainAxisExtent: tileWidth + ProductCard.infoHeight * scale,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(favoritesListProvider);
    final notifier = ref.read(favoritesListProvider.notifier);

    // Yurakcha o'chirilsa, mahsulot ro'yxatdan darhol yo'qoladi.
    ref.listen<Set<String>>(favoriteIdsProvider, (prev, next) {
      if (prev == null) return;
      for (final id in prev.difference(next)) {
        notifier.removeLocal(id);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.favoritesTitle)),
      body: LayoutBuilder(
        builder: (context, constraints) => _body(context, state, notifier, constraints.maxWidth),
      ),
    );
  }

  Widget _body(BuildContext context, FavoritesListState state, FavoritesListController notifier, double width) {
    final l10n = context.l10n;
    final bottomInset = MediaQuery.paddingOf(context).bottom + AppSpacing.xl;

    if (state.loading && state.items.isEmpty) {
      return GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, bottomInset),
        gridDelegate: _gridDelegate(context, width),
        itemCount: 4,
        itemBuilder: (_, __) => const SkeletonCard(),
      );
    }

    if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: notifier.refresh,
      );
    }

    if (state.items.isEmpty) {
      return EmptyState(
        title: l10n.favoritesEmptyTitle,
        message: l10n.favoritesEmptyMessage,
        icon: Icons.favorite_border_rounded,
        actionLabel: l10n.favoritesBrowse,
        onAction: () => context.go(AppRoutes.home),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: CustomScrollView(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.md,
              AppSpacing.lg,
              state.loadingMore ? 0 : bottomInset,
            ),
            sliver: SliverGrid(
              gridDelegate: _gridDelegate(context, width),
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final product = state.items[i];
                  return ProductCard(
                    key: ValueKey(product.id),
                    product: product,
                    onTap: () => context.push(AppRoutes.product(product.id)),
                  );
                },
                childCount: state.items.length,
              ),
            ),
          ),
          if (state.loadingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(0, AppSpacing.xl, 0, bottomInset),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}
