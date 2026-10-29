import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../favorites/presentation/favorite_button.dart';
import '../../domain/catalog_models.dart';
import 'catalog_format.dart';
import 'product_image.dart';

/// Bosh sahifadagi mahsulot kartasi: rasm, nom, narx, mavjud miqdor va o'rtacha baho.
class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final CatalogProduct product;
  final VoidCallback onTap;

  /// Rasmdan pastdagi matn qismining (kattalashtirilmagan) balandligi.
  static const double infoHeight = 128;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final soldOut = !product.inStock;

    return AppCard(
      padding: const EdgeInsets.all(6),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Rasm kartaning ichida yumaloq "oyna" sifatida turadi (concentric radius).
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.card - 6),
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
              fit: StackFit.expand,
              children: [
                ProductImage(url: product.mainImage),
                if (soldOut) ColoredBox(color: c.background.withAlpha(150)),
                if (soldOut)
                  Positioned(
                    top: AppSpacing.sm,
                    left: AppSpacing.sm,
                    child: AppBadge(label: l10n.catalogOutOfStock, tone: AppBadgeTone.error),
                  ),
                Positioned(
                  top: AppSpacing.sm,
                  right: AppSpacing.sm,
                  child: FavoriteButton(productId: product.id),
                ),
              ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name.forLanguage(lang),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall,
                  ),
                  const Spacer(),
                  Text(
                    context.formatPrice(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleMedium?.copyWith(color: c.primary),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      if (product.reviewsCount > 0) ...[
                        Icon(Icons.star_rounded, size: 16, color: c.primary),
                        const SizedBox(width: 2),
                        Text(formatRating(context, product.averageRating), style: text.labelMedium),
                      ],
                      const Spacer(),
                      if (!soldOut)
                        Flexible(
                          child: Text(
                            l10n.piecesCount(product.stock),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.labelMedium?.copyWith(color: c.textSecondary),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
