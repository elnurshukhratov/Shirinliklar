import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass/glass_bottom_bar.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../../notifications/presentation/stock_alert_button.dart';

/// Yopishqoq shisha panel: jami narx + "Savatga" tugmasi. Bosilganda tugma o'z joyida
/// "− n +" hisoblagichga morf bo'ladi (prujina bilan torayadi); miqdor 0 ga tushsa, qaytadi.
/// Tugagan mahsulotda tugma o'rnida [StockAlertButton].
class ProductBottomBar extends StatelessWidget {
  const ProductBottomBar({
    super.key,
    required this.productId,
    required this.total,
    required this.quantity,
    required this.inStock,
    required this.canIncrease,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  final String productId;

  /// Ko'rsatiladigan jami narx.
  final double total;

  /// Tanlangan variantlar bilan savatdagi miqdor (0 bo'lsa tugma ko'rinadi).
  final int quantity;
  final bool inStock;
  final bool canIncrease;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

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
                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                child: Text(
                  context.formatPrice(total),
                  key: ValueKey(total),
                  style: AppTypography.price(19).copyWith(color: c.primary),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: inStock
                ? _MorphButton(
                    quantity: quantity,
                    canIncrease: canIncrease,
                    onAdd: onAdd,
                    onIncrease: onIncrease,
                    onDecrease: onDecrease,
                  )
                : StockAlertButton(productId: productId),
          ),
        ],
      ),
    );
  }
}

class _MorphButton extends StatelessWidget {
  const _MorphButton({
    required this.quantity,
    required this.canIncrease,
    required this.onAdd,
    required this.onIncrease,
    required this.onDecrease,
  });

  final int quantity;
  final bool canIncrease;
  final VoidCallback onAdd;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;

  static const double _height = 54;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final inCart = quantity > 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final full = constraints.maxWidth;
        final compact = math.min(full, 168.0);

        return Align(
          alignment: Alignment.centerRight,
          child: SpringBuilder(
            value: inCart ? 1 : 0,
            description: AppMotion.smooth,
            builder: (context, v, _) {
              final t = v.clamp(0.0, 1.0).toDouble();
              return SizedBox(
                width: lerpDouble(full, compact, t),
                height: _height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.lerp(c.cta, Colors.white, 0.14)!, c.cta],
                    ),
                    borderRadius: AppRadius.borderPill,
                    boxShadow: AppShadows.tinted(c.cta, strength: 0.32),
                  ),
                  child: Stack(
                    children: [
                      // "Savatga" yorlig'i: morf boshida so'nadi.
                      Positioned.fill(
                        child: Opacity(
                          opacity: (1 - t * 2).clamp(0.0, 1.0).toDouble(),
                          child: IgnorePointer(
                            ignoring: inCart,
                            child: Semantics(
                              button: true,
                              label: l10n.productAddToCart,
                              excludeSemantics: true,
                              child: Pressable(
                                haptic: true,
                                scale: 0.97,
                                onTap: onAdd,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.shopping_bag_outlined, size: 20, color: c.onCta),
                                      const SizedBox(width: AppSpacing.sm),
                                      Flexible(
                                        child: Text(
                                          l10n.productAddToCart,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: text.labelLarge?.copyWith(
                                            color: c.onCta,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w800,
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
                      ),
                      // "− n +" hisoblagichi: morfning ikkinchi yarmida paydo bo'ladi.
                      Positioned.fill(
                        child: Opacity(
                          opacity: ((t - 0.5) * 2).clamp(0.0, 1.0).toDouble(),
                          child: IgnorePointer(
                            ignoring: !inCart,
                            child: Row(
                              children: [
                                _StepButton(
                                  icon: Icons.remove_rounded,
                                  label: l10n.productQuantityMinus,
                                  onTap: onDecrease,
                                ),
                                Expanded(
                                  child: Semantics(
                                    label: l10n.piecesCount(quantity),
                                    excludeSemantics: true,
                                    child: Center(
                                      child: AnimatedSwitcher(
                                        duration: AppMotion.of(context, AppMotion.fast),
                                        transitionBuilder: (child, animation) => FadeTransition(
                                          opacity: animation,
                                          child: SlideTransition(
                                            position: Tween<Offset>(
                                              begin: const Offset(0, 0.4),
                                              end: Offset.zero,
                                            ).animate(animation),
                                            child: child,
                                          ),
                                        ),
                                        child: Text(
                                          '$quantity',
                                          key: ValueKey(quantity),
                                          style: AppTypography.price(17).copyWith(color: c.onCta),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                _StepButton(
                                  icon: Icons.add_rounded,
                                  label: l10n.productQuantityPlus,
                                  onTap: canIncrease ? onIncrease : null,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        haptic: true,
        scale: 0.88,
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 54,
          child: Center(
            child: Icon(
              icon,
              size: 24,
              color: onTap == null ? c.onCta.withValues(alpha: 0.4) : c.onCta,
            ),
          ),
        ),
      ),
    );
  }
}