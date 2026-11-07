import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/expand/expand_origin.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../../catalog/domain/catalog_models.dart';
import '../../../catalog/presentation/widgets/catalog_format.dart';
import '../../../catalog/presentation/widgets/product_image.dart';
import '../../../favorites/presentation/favorite_button.dart';

/// «Tanlangan shirinliklar»: katta parallax kartalar karuseli. Rasm sahifadan sekinroq suriladi;
/// karta bosilganda mahsulot sahifasiga kartadan kengayib ochiladi.
class HomeHero extends StatefulWidget {
  const HomeHero({super.key, required this.products, required this.lang});

  final List<CatalogProduct> products;
  final String lang;

  @override
  State<HomeHero> createState() => _HomeHeroState();
}

class _HomeHeroState extends State<HomeHero> {
  static const double _fraction = 0.86;

  late final PageController _pc = PageController(viewportFraction: _fraction);

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;
    final width = MediaQuery.sizeOf(context).width;
    final height = (width * _fraction * 1.1).clamp(250.0, 400.0).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.md),
          child: Text(l10n.homeFeatured, style: text.titleLarge),
        ),
        SizedBox(
          height: height,
          child: PageView.builder(
            controller: _pc,
            clipBehavior: Clip.none,
            itemCount: widget.products.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _HeroCard(
                product: widget.products[i],
                index: i,
                controller: _pc,
                lang: widget.lang,
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _HeroCard extends StatefulWidget {
  const _HeroCard({
    required this.product,
    required this.index,
    required this.controller,
    required this.lang,
  });

  final CatalogProduct product;
  final int index;
  final PageController controller;
  final String lang;

  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard> {
  final GlobalKey _key = GlobalKey(debugLabel: 'homeHeroCard');

  double get _page {
    final c = widget.controller;
    if (c.hasClients && c.position.haveDimensions) return c.page ?? c.initialPage.toDouble();
    return c.initialPage.toDouble();
  }

  void _open() {
    final rect = ExpandOrigin.rectOf(_key);
    final url = widget.product.mainImage;
    ImageProvider? image;
    if (rect != null && url != null && url.isNotEmpty) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      image = ResizeImage(NetworkImage(url), width: (rect.width * dpr).round());
    }
    context.pushExpanded<void>(
      AppRoutes.product(widget.product.id),
      sourceKey: _key,
      radius: AppRadius.bar,
      image: image,
      surfaceColor: context.colors.secondary,
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final p = widget.product;
    final name = p.name.forLanguage(widget.lang);
    final cardWidth = MediaQuery.sizeOf(context).width * _HomeHeroState._fraction;

    final reduced = AppMotion.reduced(context);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      button: true,
      label: name,
      onTap: _open,
      child: Pressable(
        scale: 0.98,
        onTap: _open,
        child: DecoratedBox(
          key: _key,
          decoration: BoxDecoration(
            borderRadius: AppRadius.borderBar,
            boxShadow: AppShadows.lifted(c),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.borderBar,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Parallax: rasm sahifadan sekinroq suriladi; tinch holatda masshtab 1.
                AnimatedBuilder(
                  animation: widget.controller,
                  child: ProductImage(url: p.mainImage),
                  builder: (context, child) {
                    if (reduced) return child!;
                    final delta = (_page - widget.index).clamp(-1.0, 1.0).toDouble();
                    return Transform.translate(
                      offset: Offset(delta * cardWidth * 0.1, 0),
                      child: Transform.scale(scale: 1 + 0.25 * delta.abs(), child: child),
                    );
                  },
                ),
                Positioned(
                  top: AppSpacing.md,
                  right: AppSpacing.md,
                  child: FavoriteButton(productId: p.id),
                ),
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
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ExcludeSemantics(
                          child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                context.formatPrice(p.price),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.titleMedium?.copyWith(color: c.primary),
                              ),
                            ),
                            if (p.reviewsCount > 0) ...[
                              Icon(Icons.star_rounded, size: 16, color: c.accent),
                              const SizedBox(width: 2),
                              Text(formatRating(context, p.averageRating), style: text.labelMedium),
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
    );
  }
}