import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_badge.dart';
import '../../../../core/widgets/app_chip.dart';
import '../../../../core/widgets/expand/expand_scope.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/rating_stars.dart';
import '../../../admin/domain/admin_models.dart';
import '../../../review/presentation/product_reviews_section.dart';
import '../../domain/catalog_models.dart';
import 'catalog_format.dart';

/// Galereya ustiga chiqadigan shisha varaq (yuqori radius 36): nom (Unbounded), narx, baho,
/// variantlar, tavsif, sharhlar. Varaq pastdan siljib chiqadi, bo'limlar ketma-ket paydo bo'ladi.
class ProductInfoSheet extends StatelessWidget {
  const ProductInfoSheet({
    super.key,
    required this.product,
    required this.selected,
    required this.unitPrice,
    required this.onPick,
    required this.minHeight,
    required this.bottomSpace,
  });

  final CatalogProduct product;
  final Map<VariantGroup, String?> selected;
  final double unitPrice;
  final void Function(VariantGroup group, CatalogVariant variant) onPick;
  final double minHeight;

  /// Pastdagi yopishqoq panel uchun bo'sh joy.
  final double bottomSpace;

  static const double radius = 36;

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
    final p = product;

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
                selected: selected[group] == v.id,
                onTap: () => onPick(group, v),
              ),
          ],
        ),
      );
    }

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (categoryName != null && categoryName.isNotEmpty) AppBadge(label: categoryName),
            const Spacer(),
            if (p.inStock)
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline_rounded, size: 18, color: c.success),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        l10n.productInStock(p.stock),
                        overflow: TextOverflow.ellipsis,
                        style: text.bodyMedium?.copyWith(color: c.success, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
              )
            else
              AppBadge(label: l10n.catalogOutOfStock, tone: AppBadgeTone.error),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(p.name.forLanguage(lang), style: text.headlineMedium),
        const SizedBox(height: AppSpacing.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                context.formatPrice(unitPrice),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.price(24).copyWith(color: c.primary),
              ),
            ),
            if (p.reviewsCount > 0) ...[
              RatingStars(value: p.averageRating, size: 16),
              const SizedBox(width: AppSpacing.sm),
              Text(formatRating(context, p.averageRating), style: text.labelLarge),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          p.reviewsCount > 0 ? l10n.productReviewsCount(p.reviewsCount) : l10n.productNoReviews,
          style: text.bodyMedium?.copyWith(color: c.textSecondary),
        ),
      ],
    );

    return ExpandReveal(
      start: 0.15,
      end: 0.7,
      offset: 64,
      fade: false,
      child: GlassContainer(
        level: GlassLevel.panel,
        shadow: false,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(radius)),
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: minHeight),
          child: Padding(
            padding: EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, bottomSpace),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: c.textSecondary.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                ExpandReveal(index: 0, child: header),
                ExpandReveal(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      variantGroup(VariantGroup.size, l10n.adminVariantSize),
                      variantGroup(VariantGroup.cream, l10n.adminVariantCream),
                      variantGroup(VariantGroup.inscription, l10n.adminVariantInscription),
                    ],
                  ),
                ),
                ExpandReveal(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (description.isNotEmpty) section(l10n.productDescription, body(description)),
                      if (ingredients.isNotEmpty) section(l10n.productIngredients, body(ingredients)),
                      if (allergens.isNotEmpty)
                        section(
                          l10n.productAllergens,
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              color: c.secondary.withValues(alpha: 0.5),
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
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                const Divider(),
                const SizedBox(height: AppSpacing.lg),
                ExpandReveal(index: 3, child: ProductReviewsSection(product: p)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}