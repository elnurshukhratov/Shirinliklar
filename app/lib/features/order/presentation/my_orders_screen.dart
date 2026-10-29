import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../admin/presentation/admin_order_widgets.dart';
import '../application/order_providers.dart';
import '../domain/my_order_models.dart';
import 'order_labels.dart';
import 'reorder_action.dart';

/// Mijoz: "Buyurtmalarim" — barcha buyurtmalar va ularning holati.
class MyOrdersScreen extends ConsumerStatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  ConsumerState<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends ConsumerState<MyOrdersScreen> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 300) {
        ref.read(myOrdersProvider.notifier).loadMore();
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
    final state = ref.watch(myOrdersProvider);
    final notifier = ref.read(myOrdersProvider.notifier);

    Widget body;
    if (state.loading && state.items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      body = ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: notifier.refresh,
      );
    } else if (state.items.isEmpty) {
      body = EmptyState(
        title: l10n.myOrdersEmptyTitle,
        message: l10n.myOrdersEmptyMessage,
        icon: Icons.receipt_long_outlined,
        actionLabel: l10n.myOrdersBrowse,
        onAction: () => context.go(AppRoutes.home),
      );
    } else {
      body = RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView.separated(
          controller: _scroll,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(AppSpacing.lg),
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
                await context.push(AppRoutes.myOrder(order.id));
                // Tafsilotda bekor qilingan bo'lishi mumkin: ro'yxat yangilanadi.
                if (context.mounted) notifier.refresh();
              },
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.myOrdersTitle)),
      body: body,
    );
  }
}

class _OrderTile extends ConsumerStatefulWidget {
  const _OrderTile({required this.order, required this.onTap});

  final MyOrder order;
  final VoidCallback onTap;

  @override
  ConsumerState<_OrderTile> createState() => _OrderTileState();
}

class _OrderTileState extends ConsumerState<_OrderTile> {
  bool _busy = false;

  Future<void> _reorder() async {
    setState(() => _busy = true);
    try {
      await reorderToCart(context, ref, widget.order.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final onTap = widget.onTap;
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
              Expanded(child: Text(l10n.orderNumber(order.number), style: text.titleSmall)),
              AppBadge(label: orderStatusLabel(l10n, order.status), tone: orderStatusTone(order.status)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            order.items.map((e) => '${e.productName} × ${e.quantity}').join(', '),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.md),
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
          if (order.canReorder) ...[
            const SizedBox(height: AppSpacing.sm),
            AppButton(
              label: l10n.orderReorderAction,
              icon: Icons.replay_rounded,
              variant: AppButtonVariant.secondary,
              isLoading: _busy,
              onPressed: _busy ? null : _reorder,
            ),
          ],
        ],
      ),
    );
  }
}
