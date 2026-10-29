import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../store/application/store_providers.dart';
import 'confirm_dialog.dart';

/// Admin: «bugun buyurtma qabul qilmaymiz» tugmasi (kun oxirigacha amal qiladi).
class StoreStatusCard extends ConsumerStatefulWidget {
  const StoreStatusCard({super.key});

  @override
  ConsumerState<StoreStatusCard> createState() => _StoreStatusCardState();
}

class _StoreStatusCardState extends ConsumerState<StoreStatusCard> {
  bool _busy = false;

  Future<void> _toggle(bool accepting) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    // Qabul qilishni to'xtatish — mijozlarga ta'sir qiladi, shuning uchun tasdiqlanadi.
    if (!accepting) {
      final ok = await confirmDialog(
        context,
        title: l10n.adminStorePauseTitle,
        message: l10n.adminStorePauseMessage,
        confirmLabel: l10n.adminStorePauseConfirm,
      );
      if (!ok || !mounted) return;
    }

    setState(() => _busy = true);
    try {
      await ref.read(storeRepositoryProvider).setPaused(!accepting);
      ref.invalidate(storeStatusProvider);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final status = ref.watch(storeStatusProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
      child: status.when(
        loading: () => const SizedBox(height: 4, child: LinearProgressIndicator(minHeight: 2)),
        error: (_, __) => Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () => ref.invalidate(storeStatusProvider),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(l10n.commonRetry),
          ),
        ),
        data: (s) => AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Icon(
                s.acceptingOrders ? Icons.storefront_outlined : Icons.do_not_disturb_on_outlined,
                color: s.acceptingOrders ? c.success : c.error,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.adminStoreAccepting, style: text.titleSmall),
                    Text(
                      s.acceptingOrders ? l10n.adminStoreOpenHint : l10n.adminStorePausedHint,
                      style: text.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                  ],
                ),
              ),
              Switch(
                value: s.acceptingOrders,
                onChanged: _busy ? null : _toggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
