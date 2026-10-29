import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/state_views.dart';
import '../../order/domain/order_models.dart';
import '../../order/presentation/order_labels.dart';
import '../application/admin_order_providers.dart';
import '../domain/admin_order_models.dart';
import 'admin_order_widgets.dart';
import 'widgets/store_status_card.dart';

/// Admin: buyurtmalar ro'yxati va holat bo'yicha filtr.
class AdminOrdersTab extends ConsumerStatefulWidget {
  const AdminOrdersTab({super.key});

  @override
  ConsumerState<AdminOrdersTab> createState() => _AdminOrdersTabState();
}

class _AdminOrdersTabState extends ConsumerState<AdminOrdersTab> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 300) {
        ref.read(adminOrderListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(adminOrderListProvider);
    final notifier = ref.read(adminOrderListProvider.notifier);

    return Column(
      children: [
        const StoreStatusCard(),
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            children: [
              AppChip(
                label: l10n.adminOrdersFilterAll,
                selected: state.status == null,
                onTap: () => notifier.setStatus(null),
              ),
              for (final s in OrderStatus.values) ...[
                const SizedBox(width: AppSpacing.sm),
                AppChip(
                  label: orderStatusLabel(l10n, s),
                  selected: state.status == s,
                  onTap: () => notifier.setStatus(s),
                ),
              ],
            ],
          ),
        ),
        if (state.loading && state.items.isNotEmpty) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _body(context, state, notifier)),
      ],
    );
  }

  Widget _body(BuildContext context, AdminOrderListState state, AdminOrderListController notifier) {
    final l10n = context.l10n;

    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: notifier.refresh,
      );
    }
    if (state.items.isEmpty) {
      return RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 360,
              child: EmptyState(
                title: l10n.adminOrdersEmptyTitle,
                message: l10n.adminOrdersEmptyMessage,
                icon: Icons.receipt_long_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
        itemCount: state.items.length + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final order = state.items[i];
          return _OrderTile(
            order: order,
            onTap: () async {
              await context.push(AppRoutes.adminOrder(order.id));
              if (context.mounted) notifier.refresh();
            },
          );
        },
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  const _OrderTile({required this.order, required this.onTap});

  final AdminOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final when = order.scheduledAt ?? order.createdAt;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.adminOrderTitle(order.number), style: text.titleSmall)),
              AppBadge(label: orderStatusLabel(l10n, order.status), tone: orderStatusTone(order.status)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            order.customer.fullName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.schedule_rounded, size: 16, color: c.textSecondary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  context.formatDateTime(when),
                  style: text.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
              Text(context.formatPrice(order.total), style: text.titleSmall?.copyWith(color: c.primary)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: 4,
            children: [
              AppBadge(label: fulfillmentLabel(l10n, order.fulfillment)),
              AppBadge(
                label: paymentStatusLabel(l10n, order.paymentStatus),
                tone: paymentStatusTone(order.paymentStatus),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
