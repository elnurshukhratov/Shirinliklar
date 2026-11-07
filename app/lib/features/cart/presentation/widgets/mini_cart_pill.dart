import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../application/cart_controller.dart';

/// Dock ustidagi mini-savat: "3 ta · 84 000 so'm". Bosilganda Savat tabiga o'tadi.
class MiniCartPill extends ConsumerWidget {
  const MiniCartPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    final count = ref.watch(cartProvider.select((s) => s.count));
    final total = ref.watch(cartProvider.select((s) => s.total));
    final summary = context.l10n.dockCartSummary(count, context.formatPrice(total));

    return Semantics(
      button: true,
      label: summary,
      excludeSemantics: true,
      child: Pressable(
        haptic: true,
        onTap: onTap,
        child: GlassContainer(
          level: GlassLevel.chip,
          borderRadius: AppRadius.borderPill,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.shopping_bag_rounded, size: 20, color: c.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  summary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(14, FontWeight.w700, numeric: true).copyWith(color: c.textPrimary),
                ),
                const SizedBox(width: AppSpacing.xs),
                Icon(Icons.chevron_right_rounded, size: 20, color: c.textSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}