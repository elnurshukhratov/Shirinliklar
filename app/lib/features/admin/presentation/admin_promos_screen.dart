import '../../../core/widgets/glass/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/admin_promo_providers.dart';
import '../domain/admin_promo_models.dart';
import 'promo_editor_sheet.dart';
import 'widgets/confirm_dialog.dart';

/// Promokod qo'shish yoki tahrirlash oynasini ochadi.
Future<void> openPromoEditor(BuildContext context, WidgetRef ref, {AdminPromo? promo}) async {
  final saved = await showGlassSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => PromoEditorSheet(promo: promo),
  );
  if (saved == true) ref.invalidate(adminPromosProvider);
}

enum _PromoAction { edit, toggle, delete }

/// Do'kon egasi uchun promokodlar ro'yxati.
class AdminPromosScreen extends ConsumerWidget {
  const AdminPromosScreen({super.key});

  Future<void> _onAction(BuildContext context, WidgetRef ref, _PromoAction action, AdminPromo promo) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(adminPromoRepositoryProvider);

    switch (action) {
      case _PromoAction.edit:
        await openPromoEditor(context, ref, promo: promo);
      case _PromoAction.toggle:
        try {
          await repo.save(id: promo.id, body: {'isActive': !promo.isActive});
          ref.invalidate(adminPromosProvider);
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
      case _PromoAction.delete:
        final ok = await confirmDialog(
          context,
          title: l10n.adminPromoDeleteTitle,
          message: l10n.adminPromoDeleteMessage(promo.code),
          confirmLabel: l10n.commonDelete,
        );
        if (!ok) return;
        try {
          await repo.delete(promo.id);
          ref.invalidate(adminPromosProvider);
          messenger.showSnackBar(SnackBar(content: Text(l10n.adminPromoDeleted)));
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final promos = ref.watch(adminPromosProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminPromosTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => openPromoEditor(context, ref),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.adminPromoAdd),
      ),
      body: promos.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(adminPromosProvider),
          );
        },
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              title: l10n.adminPromosEmptyTitle,
              message: l10n.adminPromosEmptyMessage,
              icon: Icons.sell_outlined,
              actionLabel: l10n.adminPromoAdd,
              onAction: () => openPromoEditor(context, ref),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(adminPromosProvider);
              await ref.read(adminPromosProvider.future);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) => _PromoTile(
                promo: list[i],
                onAction: (a) => _onAction(context, ref, a, list[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  const _PromoTile({required this.promo, required this.onAction});

  final AdminPromo promo;
  final ValueChanged<_PromoAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    final discount = promo.isPercent
        ? l10n.adminPromoPercentValue(promo.discountPercent!)
        : context.formatPrice(promo.discountAmount ?? 0);
    final usage = promo.usageLimit == null
        ? l10n.adminPromoUsedCount(promo.usedCount)
        : l10n.adminPromoUsedOf(promo.usedCount, promo.usageLimit!);

    final (String label, AppBadgeTone tone) = switch (promo.status) {
      PromoStatus.active => (l10n.adminPromoStatusActive, AppBadgeTone.success),
      PromoStatus.inactive => (l10n.adminPromoStatusInactive, AppBadgeTone.neutral),
      PromoStatus.expired => (l10n.adminPromoStatusExpired, AppBadgeTone.error),
      PromoStatus.exhausted => (l10n.adminPromoStatusExhausted, AppBadgeTone.error),
    };

    return AppCard(
      onTap: () => onAction(_PromoAction.edit),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        promo.code,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium?.copyWith(letterSpacing: 0.6),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppBadge(label: label, tone: tone),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.adminPromoDiscountLine(discount),
                  style: text.bodyMedium?.copyWith(color: c.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  usage,
                  style: text.bodySmall?.copyWith(color: c.textSecondary),
                ),
                if (promo.expiresAt != null)
                  Text(
                    l10n.adminPromoExpiresOn(context.formatDate(promo.expiresAt!)),
                    style: text.bodySmall?.copyWith(color: c.textSecondary),
                  ),
              ],
            ),
          ),
          PopupMenuButton<_PromoAction>(
            onSelected: onAction,
            itemBuilder: (_) => [
              PopupMenuItem(value: _PromoAction.edit, child: Text(l10n.commonEdit)),
              PopupMenuItem(
                value: _PromoAction.toggle,
                child: Text(promo.isActive ? l10n.adminPromoDisable : l10n.adminPromoEnable),
              ),
              PopupMenuItem(
                value: _PromoAction.delete,
                child: Text(l10n.commonDelete, style: TextStyle(color: c.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
