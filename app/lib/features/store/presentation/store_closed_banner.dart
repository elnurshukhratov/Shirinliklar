import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../application/store_providers.dart';

/// Do'kon bugun buyurtma qabul qilmasa, mijozga ko'rsatiladigan ogohlantirish.
class StoreClosedNotice extends StatelessWidget {
  const StoreClosedNotice({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      margin: margin,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: c.secondary.withAlpha(140),
        borderRadius: AppRadius.borderBase,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storefront_outlined, size: 22, color: c.error),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.storeClosedTitle, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(l10n.storeClosedMessage, style: text.bodySmall?.copyWith(color: c.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Do'kon yopiq bo'lsagina ko'rinadi, aks holda hech narsa chizmaydi.
class StoreClosedBanner extends ConsumerWidget {
  const StoreClosedBanner({super.key, this.margin = EdgeInsets.zero});

  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(storeStatusProvider).valueOrNull;
    if (status == null || status.acceptingOrders) return const SizedBox.shrink();
    return StoreClosedNotice(margin: margin);
  }
}
