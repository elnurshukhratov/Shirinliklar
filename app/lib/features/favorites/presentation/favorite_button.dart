import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/widgets/glass/glass_icon_button.dart';
import '../application/favorites_providers.dart';

/// Yurakcha: mahsulotni sevimlilarga qo'shish yoki olib tashlash.
/// [overlay] rost bo'lsa rasm ustidagi yumaloq tugma, aks holda AppBar uchun oddiy tugma.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.productId, this.overlay = true});

  final String productId;
  final bool overlay;

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(favoriteIdsProvider.notifier).toggle(productId);
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final isFavorite = ref.watch(favoriteIdsProvider.select((ids) => ids.contains(productId)));
    final label = isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd;

    final icon = AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.fast),
      switchInCurve: AppMotion.curve,
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: Icon(
        isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
        key: ValueKey(isFavorite),
        size: 20,
        color: isFavorite ? c.primary : c.textSecondary,
      ),
    );

    if (!overlay) {
      return GlassIconButton(
        tooltip: label,
        overMedia: true,
        onPressed: () => _toggle(context, ref),
        child: icon,
      );
    }

    // Rasm ustida: blur'siz, to'liqroq qoplaydigan shisha (ro'yxatda ko'p nusxa bor).
    return GlassIconButton(
      tooltip: label,
      overMedia: true,
      size: 38,
      margin: EdgeInsets.zero,
      onPressed: () => _toggle(context, ref),
      child: icon,
    );
  }
}
