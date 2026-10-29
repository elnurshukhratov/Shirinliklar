import '../../../core/widgets/glass/glass_bottom_bar.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../admin/domain/admin_models.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/presentation/widgets/cart_icon_button.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../../notifications/presentation/stock_alert_button.dart';
import '../../review/presentation/product_reviews_section.dart';
import '../application/catalog_providers.dart';
import '../domain/catalog_models.dart';
import 'widgets/catalog_format.dart';
import 'widgets/product_image.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(catalogProductProvider(productId));

    return Scaffold(
      // Fotosurat ekranning eng tepasigacha cho'ziladi, boshqaruv tugmalari uning ustida shisha.
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leadingWidth: 60,
        leading: GlassIconButton(
          tooltip: l10n.commonBack,
          margin: const EdgeInsets.only(left: AppSpacing.md),
          overMedia: true,
          onPressed: () => Navigator.of(context).maybePop(),
          child: const Icon(Icons.arrow_back_rounded),
        ),
        actions: [
          FavoriteButton(productId: productId, overlay: false),
          const CartIconButton(overMedia: true),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: async.when(
        loading: () => const _DetailSkeleton(),
        error: (e, _) {
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(catalogProductProvider(productId)),
          );
        },
        data: (product) => _ProductView(product: product),
      ),
    );
  }
}

class _DetailSkeleton extends StatelessWidget {
  const _DetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      children: const [
        AspectRatio(
          aspectRatio: 1,
          child: SizedBox.expand(child: Skeleton(height: double.infinity, borderRadius: BorderRadius.zero)),
        ),
        Padding(
          padding: EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 220, height: 24),
              SizedBox(height: AppSpacing.md),
              Skeleton(width: 140, height: 16),
              SizedBox(height: AppSpacing.xl),
              Skeleton(height: 14),
              SizedBox(height: AppSpacing.sm),
              Skeleton(height: 14),
              SizedBox(height: AppSpacing.sm),
              Skeleton(width: 180, height: 14),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductView extends ConsumerStatefulWidget {
  const _ProductView({required this.product});

  final CatalogProduct product;

  @override
  ConsumerState<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<_ProductView> {
  /// Har bir guruh uchun tanlangan variant. O'lcham va krem turi doim tanlangan turadi,
  /// yozuv ixtiyoriy.
  late final Map<VariantGroup, String?> _selected;

  CatalogProduct get _product => widget.product;

  @override
  void initState() {
    super.initState();
    _selected = {
      for (final g in VariantGroup.values)
        g: g == VariantGroup.inscription || _product.variantsOf(g).isEmpty
            ? null
            : _product.variantsOf(g).first.id,
    };
  }

  List<String> get _variantIds => _selected.values.whereType<String>().toList();

  double get _unitPrice {
    var total = _product.price;
    for (final v in _product.variants) {
      if (_selected[v.group] == v.id) total += v.priceDelta;
    }
    return total < 0 ? 0 : total;
  }

  void _pick(VariantGroup group, CatalogVariant variant) {
    setState(() {
      final current = _selected[group] == variant.id;
      _selected[group] = current && group == VariantGroup.inscription ? null : variant.id;
    });
  }

  void _addToCart() {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    final result = ref.read(cartProvider.notifier).add(ProductSelection(
          product: _product,
          variantIds: _variantIds,
          unitPrice: _unitPrice,
        ));

    final message = switch (result) {
      AddResult.added => l10n.cartAdded,
      AddResult.limitReached => l10n.cartStockLimit(_product.stock),
      AddResult.outOfStock => l10n.catalogOutOfStock,
    };
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(message),
        action: result == AddResult.added
            ? SnackBarAction(label: l10n.cartOpen, onPressed: () => router.push(AppRoutes.cart))
            : null,
      ));
  }

  String _variantLabel(BuildContext context, CatalogVariant v, String lang) {
    final name = v.name.forLanguage(lang);
    if (v.priceDelta == 0) return name;
    final sign = v.priceDelta > 0 ? '+' : '−';
    return '$name · $sign${context.formatPrice(v.priceDelta.abs())}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final p = _product;

    final description = p.description.forLanguage(lang).trim();
    final ingredients = p.ingredients.forLanguage(lang).trim();
    final allergens = p.allergens.forLanguage(lang).trim();
    final categoryName = p.categoryName?.forLanguage(lang);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              child,
            ],
          ),
        );

    Widget body(String value) => Text(value, style: text.bodyMedium?.copyWith(height: 1.5));

    Widget variantGroup(VariantGroup group, String title) {
      final options = p.variantsOf(group);
      if (options.isEmpty) return const SizedBox.shrink();
      return section(
        title,
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            for (final v in options)
              AppChip(
                label: _variantLabel(context, v, lang),
                selected: _selected[group] == v.id,
                onTap: () => _pick(group, v),
              ),
          ],
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: AppSpacing.xl),
            children: [
              _Gallery(images: p.images, soldOut: !p.inStock),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName != null && categoryName.isNotEmpty) ...[
                      AppBadge(label: categoryName),
                      const SizedBox(height: AppSpacing.sm),
                    ],
                    Text(p.name.forLanguage(lang), style: text.headlineSmall),
                    const SizedBox(height: AppSpacing.sm),
                    if (p.reviewsCount > 0)
                      Row(
                        children: [
                          RatingStars(value: p.averageRating),
                          const SizedBox(width: AppSpacing.sm),
                          Flexible(
                            child: Text(
                              '${formatRating(context, p.averageRating)} · ${l10n.productReviewsCount(p.reviewsCount)}',
                              style: text.bodyMedium?.copyWith(color: c.textSecondary),
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        l10n.productNoReviews,
                        style: text.bodyMedium?.copyWith(color: c.textSecondary),
                      ),
                    const SizedBox(height: AppSpacing.md),
                    if (p.inStock)
                      Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 18, color: c.success),
                          const SizedBox(width: 6),
                          Text(
                            l10n.productInStock(p.stock),
                            style: text.bodyMedium?.copyWith(color: c.success, fontWeight: FontWeight.w700),
                          ),
                        ],
                      )
                    else
                      AppBadge(label: l10n.catalogOutOfStock, tone: AppBadgeTone.error),
                    variantGroup(VariantGroup.size, l10n.adminVariantSize),
                    variantGroup(VariantGroup.cream, l10n.adminVariantCream),
                    variantGroup(VariantGroup.inscription, l10n.adminVariantInscription),
                    if (description.isNotEmpty) section(l10n.productDescription, body(description)),
                    if (ingredients.isNotEmpty) section(l10n.productIngredients, body(ingredients)),
                    if (allergens.isNotEmpty)
                      section(
                        l10n.productAllergens,
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          decoration: BoxDecoration(
                            color: c.secondary.withAlpha(110),
                            borderRadius: AppRadius.borderBase,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 20, color: c.error),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(child: body(allergens)),
                            ],
                          ),
                        ),
                      ),
                    const SizedBox(height: AppSpacing.xl),
                    const Divider(),
                    const SizedBox(height: AppSpacing.lg),
                    ProductReviewsSection(product: p),
                  ],
                ),
              ),
            ],
          ),
        ),
        _BottomBar(
          productId: p.id,
          price: _unitPrice,
          enabled: p.inStock,
          onAdd: _addToCart,
        ),
      ],
    );
  }
}

/// Ekranning pastida doim ko'rinib turadigan narx va «Savatga qo'shish» tugmasi.
class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.productId, required this.price, required this.enabled, required this.onAdd});

  final String productId;
  final double price;
  final bool enabled;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return GlassBottomBar(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.productTotal, style: text.labelMedium?.copyWith(color: c.textSecondary)),
                  AnimatedSwitcher(
                    duration: AppMotion.of(context),
                    switchInCurve: AppMotion.curve,
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      context.formatPrice(price),
                      key: ValueKey(price),
                      style: text.titleLarge?.copyWith(color: c.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: enabled
                    ? AppButton(
                        label: l10n.productAddToCart,
                        icon: Icons.shopping_bag_outlined,
                        onPressed: onAdd,
                      )
                    : StockAlertButton(productId: productId),
              ),
            ],
          ),
    );
  }
}

/// Surib ko'riladigan rasmlar galereyasi.
class _Gallery extends StatefulWidget {
  const _Gallery({required this.images, required this.soldOut});

  final List<String> images;
  final bool soldOut;

  @override
  State<_Gallery> createState() => _GalleryState();
}

class _GalleryState extends State<_Gallery> {
  final _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final images = widget.images;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppRadius.sheet)),
      child: AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (images.isEmpty)
            const ProductImage()
          else
            PageView.builder(
              controller: _controller,
              itemCount: images.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (_, i) => ProductImage(url: images[i]),
            ),
          if (widget.soldOut)
            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              child: AppBadge(label: l10n.catalogOutOfStock, tone: AppBadgeTone.error),
            ),
          if (images.length > 1)
            Positioned(
              bottom: AppSpacing.md,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < images.length; i++)
                    AnimatedContainer(
                      duration: AppMotion.of(context),
                      curve: AppMotion.curve,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _index ? 18 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: i == _index ? Colors.white : Colors.white.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
      ),
    );
  }
}
