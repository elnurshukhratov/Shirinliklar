import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/expand/expand_origin.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../../cart/presentation/quick_add.dart';
import '../../../favorites/presentation/favorite_button.dart';
import '../../domain/catalog_models.dart';
import 'product_image.dart';

/// Yangi mahsulot kartasi: to'liq rasm (radius 28), pastki chapda narx (shisha chip),
/// o'ng pastda "+" (tez qo'shish), yuqorida yurak; nom rasm ostida, karta foni yo'q.
/// Bosilganda [onTap] bo'lmasa, mahsulot sahifasiga kartadan kengayib ochiladi.
class ProductCard extends ConsumerStatefulWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.aspectRatio = 1,
  });

  final CatalogProduct product;

  /// Berilsa, kengayish o'rniga shu chaqiriladi.
  final VoidCallback? onTap;

  /// Rasm nisbati: masonry'da navbatma-navbat 0.8 (4:5) va 1 (1:1).
  final double aspectRatio;

  /// Rasm ostidagi nom qismining (kattalashtirilmagan) balandligi: qat'iy balandlikli setkalar uchun.
  static const double infoHeight = 52;

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> {
  final GlobalKey _imageKey = GlobalKey(debugLabel: 'productCardImage');

  void _open() {
    final custom = widget.onTap;
    if (custom != null) {
      custom();
      return;
    }
    final rect = ExpandOrigin.rectOf(_imageKey);
    final url = widget.product.mainImage;
    ImageProvider? image;
    if (rect != null && url != null && url.isNotEmpty) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      image = ResizeImage(NetworkImage(url), width: (rect.width * dpr).round());
    }
    context.pushExpanded<void>(
      AppRoutes.product(widget.product.id),
      sourceKey: _imageKey,
      radius: AppRadius.panel,
      image: image,
      surfaceColor: context.colors.secondary,
    );
  }

  void _quickAdd() => quickAddToCart(context, ref, widget.product, sourceKey: _imageKey);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final p = widget.product;
    final soldOut = !p.inStock;
    final name = p.name.forLanguage(lang);

    // Ichidagi tugmalar (sevimli, savatga) alohida semantik tugun bo'lib qolishi kerak:
    // shuning uchun bolalar yashirilmaydi, faqat nom matni takrorlanmasligi uchun o'chiriladi.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: true,
      label: name,
      onTap: _open,
      child: Pressable(
        onTap: _open,
        scale: 0.97,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              key: _imageKey,
              aspectRatio: widget.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.panel),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ProductImage(url: p.mainImage),
                        if (soldOut) ColoredBox(color: c.background.withValues(alpha: 0.58)),
                      ],
                    ),
                  ),
                  Positioned(
                    top: AppSpacing.sm,
                    right: AppSpacing.sm,
                    child: FavoriteButton(productId: p.id),
                  ),
                  if (soldOut)
                    Center(child: _SoldOutBadge(label: l10n.catalogOutOfStock)),
                  Positioned(
                    left: AppSpacing.sm,
                    right: soldOut ? AppSpacing.sm : 52,
                    bottom: AppSpacing.sm,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _PriceChip(text: context.formatPrice(p.price)),
                    ),
                  ),
                  if (!soldOut)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: _AddButton(label: l10n.productAddToCart, onTap: _quickAdd),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, AppSpacing.sm, 4, 0),
              child: ExcludeSemantics(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall?.copyWith(color: soldOut ? c.textSecondary : null),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  const _PriceChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GlassContainer(
      level: GlassLevel.chip,
      blur: false,
      shadow: false,
      overMedia: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          text,
          maxLines: 1,
          style: AppTypography.price(12.5).copyWith(color: c.textPrimary),
        ),
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        haptic: true,
        scale: 0.88,
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Center(
            child: GlassContainer(
              level: GlassLevel.chip,
              blur: false,
              shadow: false,
              tint: c.cta,
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Icon(Icons.add_rounded, size: 22, color: c.onCta),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SoldOutBadge extends StatelessWidget {
  const _SoldOutBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GlassContainer(
      level: GlassLevel.chip,
      blur: false,
      shadow: false,
      overMedia: true,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.error),
      ),
    );
  }
}