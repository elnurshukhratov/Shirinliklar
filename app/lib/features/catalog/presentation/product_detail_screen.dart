import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/expand/expand_scope.dart';
import '../../../core/widgets/glass/glass_container.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import '../../../core/widgets/skeleton.dart';
import '../../../core/widgets/state_views.dart';
import '../../admin/domain/admin_models.dart';
import '../../cart/application/cart_controller.dart';
import '../../cart/domain/cart_models.dart';
import '../../favorites/presentation/favorite_button.dart';
import '../application/catalog_providers.dart';
import '../domain/catalog_models.dart';
import 'widgets/product_bottom_bar.dart';
import 'widgets/product_gallery.dart';
import 'widgets/product_info_sheet.dart';

/// To'liq ekranli mahsulot sahifasi (dock yashirin): tepada ~55% galereya, pastdan shisha varaq,
/// yopishqoq shisha panel va suzuvchi shisha doiralar (orqaga, yurak).
/// Router'da `expandPage` bilan ochiladi: kartadan kengayadi, pastga tortib yopiladi.
class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  /// Galereya ekranning shu ulushini egallaydi.
  static const double galleryFraction = 0.55;

  /// Varaq galereya ustiga shuncha chiqib turadi.
  static const double overlap = ProductInfoSheet.radius;

  /// Umumiy rasm kengayib boradigan to'rtburchak (router'ga beriladi).
  static Rect galleryRect(Size screen) =>
      Rect.fromLTWH(0, 0, screen.width, screen.height * galleryFraction);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final async = ref.watch(catalogProductProvider(productId));
    final placeholder = ExpandScope.maybeOf(context)?.origin?.image;
    final top = MediaQuery.paddingOf(context).top;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          async.when(
            loading: () => _LoadingBody(placeholder: placeholder),
            error: (e, _) {
              final err = describeError(l10n, e);
              return SafeArea(
                child: ErrorState(
                  title: err.title,
                  message: err.message,
                  retryLabel: l10n.commonRetry,
                  onRetry: () => ref.invalidate(catalogProductProvider(productId)),
                ),
              );
            },
            data: (product) => _ProductView(product: product, placeholder: placeholder),
          ),
          Positioned(
            top: top + AppSpacing.sm,
            left: AppSpacing.sm,
            child: ExpandReveal(
              start: 0.5,
              end: 0.85,
              offset: 0,
              child: GlassIconButton(
                tooltip: l10n.commonBack,
                overMedia: true,
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Icon(Icons.arrow_back_rounded),
              ),
            ),
          ),
          Positioned(
            top: top + AppSpacing.sm,
            right: AppSpacing.sm,
            child: ExpandReveal(
              start: 0.5,
              end: 0.85,
              offset: 0,
              child: FavoriteButton(productId: productId, overlay: false),
            ),
          ),
        ],
      ),
    );
  }
}

/// Ma'lumot kelguncha: kartadagi rasm (bo'lsa) va varaq skeleti.
class _LoadingBody extends StatelessWidget {
  const _LoadingBody({this.placeholder});

  final ImageProvider? placeholder;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    final galleryH = height * ProductDetailScreen.galleryFraction;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: galleryH,
          child: ProductGallery(
            images: const [],
            height: galleryH,
            placeholder: placeholder,
            loading: true,
          ),
        ),
        Positioned(
          top: galleryH - ProductDetailScreen.overlap,
          left: 0,
          right: 0,
          child: GlassContainer(
            level: GlassLevel.panel,
            shadow: false,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(ProductInfoSheet.radius)),
            child: const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: AppSpacing.xl),
                  Skeleton(width: 90, height: 22, borderRadius: BorderRadius.all(Radius.circular(11))),
                  SizedBox(height: AppSpacing.md),
                  Skeleton(width: 240, height: 26),
                  SizedBox(height: AppSpacing.md),
                  Skeleton(width: 140, height: 20),
                  SizedBox(height: AppSpacing.xl),
                  Skeleton(height: 14),
                  SizedBox(height: AppSpacing.sm),
                  Skeleton(height: 14),
                  SizedBox(height: AppSpacing.sm),
                  Skeleton(width: 180, height: 14),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductView extends ConsumerStatefulWidget {
  const _ProductView({required this.product, this.placeholder});

  final CatalogProduct product;
  final ImageProvider? placeholder;

  @override
  ConsumerState<_ProductView> createState() => _ProductViewState();
}

class _ProductViewState extends ConsumerState<_ProductView> {
  /// Har bir guruh uchun tanlangan variant. O'lcham va krem turi doim tanlangan turadi,
  /// yozuv ixtiyoriy.
  late final Map<VariantGroup, String?> _selected;
  final ScrollController _scroll = ScrollController();

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

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  List<String> get _variantIds => _selected.values.whereType<String>().toList();

  double get _unitPrice {
    var total = _product.price;
    for (final v in _product.variants) {
      if (_selected[v.group] == v.id) total += v.priceDelta;
    }
    return total < 0 ? 0 : total;
  }

  String get _lineKey => CartItem.keyFor(_product.id, _variantIds);

  ProductSelection get _selection => ProductSelection(
        product: _product,
        variantIds: _variantIds,
        unitPrice: _unitPrice,
      );

  void _pick(VariantGroup group, CatalogVariant variant) {
    setState(() {
      final current = _selected[group] == variant.id;
      _selected[group] = current && group == VariantGroup.inscription ? null : variant.id;
    });
  }

  void _notify(AddResult result, {bool firstAdd = false}) {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom + 96;

    switch (result) {
      case AddResult.added:
        HapticFeedback.lightImpact();
        if (!firstAdd) return;
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(l10n.cartAdded),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, bottom),
            action: SnackBarAction(label: l10n.cartOpen, onPressed: () => router.go(AppRoutes.cart)),
          ));
      case AddResult.limitReached:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.cartStockLimit(_product.stock))));
      case AddResult.outOfStock:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.catalogOutOfStock)));
    }
  }

  void _add() {
    final key = _lineKey;
    final first = ref.read(cartProvider).items.every((e) => e.key != key);
    final result = ref.read(cartProvider.notifier).add(_selection);
    _notify(result, firstAdd: first);
  }

  void _increase() {
    final result = ref.read(cartProvider.notifier).add(_selection);
    if (result != AddResult.added) _notify(result);
  }

  void _decrease() {
    final key = _lineKey;
    final cart = ref.read(cartProvider.notifier);
    final qty = ref
        .read(cartProvider)
        .items
        .where((e) => e.key == key)
        .fold<int>(0, (sum, e) => sum + e.quantity);
    if (qty <= 1) {
      cart.remove(key);
    } else {
      cart.setQuantity(key, qty - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _product;
    final mq = MediaQuery.of(context);
    final galleryH = mq.size.height * ProductDetailScreen.galleryFraction;
    final sheetTop = galleryH - ProductDetailScreen.overlap;
    final barSpace = 112 + mq.padding.bottom;

    final key = _lineKey;
    final lineQty = ref.watch(cartProvider.select(
      (s) => s.items.where((e) => e.key == key).fold<int>(0, (sum, e) => sum + e.quantity),
    ));
    final productQty = ref.watch(cartProvider.select(
      (s) => s.items.where((e) => e.productId == p.id).fold<int>(0, (sum, e) => sum + e.quantity),
    ));
    final canIncrease = productQty < p.stock && lineQty < CartController.maxPerLine;

    return Stack(
      children: [
        Positioned.fill(
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
            // Clamping: tepada pastga tortish "yopish" harakati sifatida ExpandHost'ga yetib boradi.
            child: CustomScrollView(
              controller: _scroll,
              physics: const ClampingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: galleryH,
                        child: ClipRect(
                          child: AnimatedBuilder(
                            animation: _scroll,
                            child: ProductGallery(
                              images: p.images,
                              height: galleryH,
                              placeholder: widget.placeholder,
                              soldOut: !p.inStock,
                              indicatorBottom: ProductDetailScreen.overlap + 14,
                            ),
                            builder: (context, child) {
                              // Vertikal parallax: galereya skrollga qaraganda sekinroq ketadi.
                              final y = _scroll.hasClients
                                  ? _scroll.offset.clamp(0.0, galleryH).toDouble() * 0.45
                                  : 0.0;
                              return Transform.translate(offset: Offset(0, y), child: child);
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: sheetTop),
                        child: ProductInfoSheet(
                          product: p,
                          selected: _selected,
                          unitPrice: _unitPrice,
                          onPick: _pick,
                          minHeight: mq.size.height - sheetTop,
                          bottomSpace: barSpace,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ExpandReveal(
            start: 0.5,
            end: 0.9,
            offset: 28,
            child: ProductBottomBar(
              productId: p.id,
              total: _unitPrice * (lineQty > 0 ? lineQty : 1),
              quantity: lineQty,
              inStock: p.inStock,
              canIncrease: canIncrease,
              onAdd: _add,
              onIncrease: _increase,
              onDecrease: _decrease,
            ),
          ),
        ),
      ],
    );
  }
}