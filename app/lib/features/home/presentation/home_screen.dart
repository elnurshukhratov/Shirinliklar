import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/widgets/glass/reveal.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/brand_mark.dart';
import '../../../core/widgets/glass/glass_container.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import '../../../core/widgets/glass/glass_navigation_bar.dart';
import '../../../core/widgets/glass/glass_search_bar.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../cart/presentation/widgets/cart_icon_button.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/widgets/catalog_format.dart';
import '../../catalog/presentation/widgets/product_card.dart';
import '../../catalog/presentation/widgets/product_image.dart';
import '../../store/presentation/store_closed_banner.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  /// Suzuvchi dock balandligi (tarkibiy qismlar + zaxira): ro'yxat ostida bo'sh joy qoldirish uchun.
  static const double _dockSpace = 112;

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
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(catalogListProvider.notifier).setSearch(value);
    });
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

  void _onDock(int i) {
    switch (i) {
      case 0:
        if (_scroll.hasClients) {
          _scroll.animateTo(
            0,
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.curve,
          );
        }
      case 1:
        context.push(AppRoutes.favorites);
      case 2:
        context.push(AppRoutes.myOrders);
      case 3:
        context.push(AppRoutes.profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(catalogListProvider);
    final notifier = ref.read(catalogListProvider.notifier);
    final categories = ref.watch(catalogCategoriesProvider).valueOrNull ?? const [];
    final lang = Localizations.localeOf(context).languageCode;
    // Qidiruvda klaviatura ochilganda dock klaviatura ustiga chiqib, ro'yxatni yopmasligi uchun yashiriladi.
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        extendBody: true,
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final showHome = state.search.isEmpty && state.categoryId == null;
                    final featured = showHome ? _featured(state.items) : const <CatalogProduct>[];

                    Widget header = SliverPersistentHeader(
                      pinned: true,
                      delegate: _FilterHeaderDelegate(
                        controller: _searchController,
                        hint: l10n.catalogSearchHint,
                        onSearch: _onSearchChanged,
                        chips: [
                          AppChip(
                            label: l10n.catalogAllCategories,
                            selected: state.categoryId == null,
                            onTap: () => notifier.setCategory(null),
                          ),
                          for (final category in categories)
                            AppChip(
                              label: category.name.forLanguage(lang),
                              selected: state.categoryId == category.id,
                              onTap: () => notifier.setCategory(category.id),
                            ),
                        ],
                      ),
                    );

                    return RefreshIndicator(
                      onRefresh: notifier.refresh,
                      edgeOffset: 0,
                      child: CustomScrollView(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverToBoxAdapter(child: _Hero(compact: !showHome)),
                          const SliverToBoxAdapter(
                            child: StoreClosedBanner(
                              margin: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                            ),
                          ),
                          if (featured.isNotEmpty)
                            SliverToBoxAdapter(child: _FeaturedRow(products: featured, lang: lang)),
                          header,
                          if (state.loading && state.items.isNotEmpty)
                            const SliverToBoxAdapter(child: LinearProgressIndicator(minHeight: 2)),
                          ..._content(context, state, notifier, width),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            if (!keyboardOpen)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: GlassNavigationBar(
                  selectedIndex: 0,
                  onSelected: _onDock,
                  items: [
                    GlassNavItem(
                      icon: Icons.storefront_outlined,
                      selectedIcon: Icons.storefront_rounded,
                      label: l10n.navHome,
                    ),
                    GlassNavItem(
                      icon: Icons.favorite_border_rounded,
                      selectedIcon: Icons.favorite_rounded,
                      label: l10n.favoritesTitle,
                    ),
                    GlassNavItem(
                      icon: Icons.receipt_long_outlined,
                      selectedIcon: Icons.receipt_long_rounded,
                      label: l10n.myOrdersTitle,
                    ),
                    GlassNavItem(
                      icon: Icons.person_outline_rounded,
                      selectedIcon: Icons.person_rounded,
                      label: l10n.profileTitle,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> _content(
    BuildContext context,
    CatalogListState state,
    CatalogListController notifier,
    double width,
  ) {
    final l10n = context.l10n;
    final bottomInset = _dockSpace + MediaQuery.paddingOf(context).bottom;

    if (state.loading && state.items.isEmpty) {
      return [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, bottomInset),
          sliver: SliverGrid(
            gridDelegate: _gridDelegate(context, width),
            delegate: SliverChildBuilderDelegate((_, __) => const SkeletonCard(), childCount: 6),
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
            child: state.search.isNotEmpty
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
          AppSpacing.sm,
          AppSpacing.lg,
          state.loadingMore ? 0 : bottomInset,
        ),
        sliver: SliverGrid(
          gridDelegate: _gridDelegate(context, width),
          delegate: SliverChildBuilderDelegate(
            (context, i) {
              final product = state.items[i];
              return Reveal(
                key: ValueKey(product.id),
                index: i % 6,
                child: ProductCard(
                  product: product,
                  onTap: () => context.push(AppRoutes.product(product.id)),
                ),
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
    ];
  }
}

/// Yuqori qism: brend + harakat tugmalari, va (qidiruvsiz holatda) katta hero kartasi.
class _Hero extends ConsumerWidget {
  const _Hero({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final isAdmin = ref.watch(authControllerProvider).user?.isAdmin ?? false;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const BrandMark(size: 44, shadow: false),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  AppConfig.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleLarge,
                ),
              ),
              const CartIconButton(),
              if (isAdmin)
                GlassIconButton(
                  tooltip: l10n.profileAdminPanel,
                  onPressed: () => context.push(AppRoutes.admin),
                  child: const Icon(Icons.admin_panel_settings_outlined),
                ),
              GlassIconButton(
                tooltip: l10n.settingsTitle,
                onPressed: () => context.push(AppRoutes.settings),
                child: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: AppSpacing.lg),
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: _HeroCard(),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  Widget _orb(Color color, double size, double alpha) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [color.withValues(alpha: alpha), color.withValues(alpha: 0)],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final dark = Theme.of(context).brightness == Brightness.dark;

    // Tokenlardan to'q gradient (kunda qulupnay -> chuqur, tunda uzum -> tun); ustida mint va oq
    // nur dog'lari. Matn har doim to'q fonda: oq rangda yuqori kontrast.
    final heroStart = dark ? c.ambientA : c.cta;
    final deep = dark
        ? Color.lerp(c.ambientA, c.background, 0.55)!
        : Color.lerp(c.cta, c.textPrimary, 0.7)!;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppMotion.of(context, const Duration(milliseconds: 650)),
      curve: AppMotion.emphasized,
      builder: (context, t, child) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: child),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: AppRadius.borderBar,
          boxShadow: AppShadows.tinted(c.cta, strength: dark ? 0.24 : 0.28),
        ),
        child: ClipRRect(
          borderRadius: AppRadius.borderBar,
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [heroStart, deep],
                    ),
                  ),
                ),
              ),
              Positioned(right: -64, bottom: -78, child: _orb(c.mint, 220, 0.42)),
              Positioned(left: -56, top: -86, child: _orb(Colors.white, 190, 0.20)),
              SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xxl, AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.authLoginTitle,
                        style: text.headlineMedium?.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        l10n.authLoginSubtitle,
                        style: text.bodyMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// «Tanlangan shirinliklar»: katta fotosurat va ustida shisha ma'lumot paneli.
class _FeaturedRow extends StatelessWidget {
  const _FeaturedRow({required this.products, required this.lang});

  final List<CatalogProduct> products;
  final String lang;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          child: Text(l10n.homeFeatured, style: text.titleLarge),
        ),
        SizedBox(
          height: 270 + 24 * (scale - 1),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: products.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
            itemBuilder: (context, i) {
              final p = products[i];
              return _FeaturedCard(
                product: p,
                lang: lang,
                onTap: () => context.push(AppRoutes.product(p.id)),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.product, required this.lang, required this.onTap});

  final CatalogProduct product;
  final String lang;
  final VoidCallback onTap;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final product = widget.product;
    final pressed = _pressed && !AppMotion.reduced(context);

    return Semantics(
      button: true,
      label: product.name.forLanguage(widget.lang),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: pressed ? 0.97 : 1,
          duration: AppMotion.of(context, AppMotion.fast),
          curve: pressed ? AppMotion.curve : AppMotion.springCurve,
          child: SizedBox(
            width: 214,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: AppRadius.borderBar,
                boxShadow: AppShadows.lifted(c),
              ),
              child: ClipRRect(
                borderRadius: AppRadius.borderBar,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ProductImage(url: product.mainImage),
                    Positioned(
                      left: AppSpacing.sm,
                      right: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: GlassContainer(
                        level: GlassLevel.floating,
                        blur: false,
                        overMedia: true,
                        shadow: false,
                        borderRadius: BorderRadius.circular(AppRadius.card - 4),
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              product.name.forLanguage(widget.lang),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.titleSmall,
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.formatPrice(product.price),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: text.titleMedium?.copyWith(color: c.primary),
                                  ),
                                ),
                                if (product.reviewsCount > 0) ...[
                                  Icon(Icons.star_rounded, size: 16, color: c.accent),
                                  const SizedBox(width: 2),
                                  Text(
                                    formatRating(context, product.averageRating),
                                    style: text.labelMedium,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Yopishib turuvchi qidiruv va kategoriyalar. Kontent ostiga kirganda shisha panelga aylanadi.
class _FilterHeaderDelegate extends SliverPersistentHeaderDelegate {
  _FilterHeaderDelegate({
    required this.controller,
    required this.hint,
    required this.onSearch,
    required this.chips,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onSearch;
  final List<Widget> chips;

  static const double _extent = 8 + 52 + 10 + 44 + 12;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedSwitcher(
          duration: AppMotion.of(context, AppMotion.fast),
          child: overlapsContent
              ? const GlassContainer(
                  key: ValueKey('frosted'),
                  level: GlassLevel.bar,
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
                  child: SizedBox.expand(),
                )
              : const SizedBox.expand(key: ValueKey('clear')),
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: GlassSearchBar(controller: controller, hint: hint, onChanged: onSearch),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                itemCount: chips.length,
                separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (_, i) => chips[i],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ],
    );
  }

  @override
  bool shouldRebuild(covariant _FilterHeaderDelegate old) => true;
}
