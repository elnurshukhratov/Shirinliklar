import '../../../core/widgets/glass/glass_bottom_bar.dart';
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
import '../domain/order_models.dart';
import 'order_labels.dart';
import 'reorder_action.dart';
import 'widgets/order_status_timeline.dart';

/// Mijoz: buyurtma tafsiloti, holat chizig'i va (qabul qilinishidan oldin) bekor qilish.
class MyOrderDetailScreen extends ConsumerStatefulWidget {
  const MyOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<MyOrderDetailScreen> createState() => _MyOrderDetailScreenState();
}

class _MyOrderDetailScreenState extends ConsumerState<MyOrderDetailScreen> {
  bool _busy = false;

  Future<void> _pay() async {
    await context.push(AppRoutes.pay(widget.orderId));
    if (!mounted) return;
    ref.invalidate(myOrderDetailProvider(widget.orderId));
  }

  Future<void> _reorder() async {
    setState(() => _busy = true);
    try {
      await reorderToCart(context, ref, widget.orderId);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancel() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.orderCancelTitle),
        content: Text(l10n.orderCancelMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.orderCancelKeep),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.orderCancelConfirm, style: TextStyle(color: ctx.colors.error)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(orderRepositoryProvider).cancel(widget.orderId);
      ref.invalidate(myOrdersProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderCancelDone)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      // Muvaffaqiyatsiz bo'lsa ham eng so'nggi holatni ko'rsatamiz (admin qabul qilgan bo'lishi mumkin).
      ref.invalidate(myOrderDetailProvider(widget.orderId));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(myOrderDetailProvider(widget.orderId));
    final order = detail.valueOrNull;

    return Scaffold(
      appBar: AppBar(title: Text(order == null ? l10n.myOrdersTitle : l10n.orderNumber(order.number))),
      body: detail.when(
        loading: () =>
            order == null ? const Center(child: CircularProgressIndicator()) : _Content(order: order),
        error: (e, _) {
          if (order != null) return _Content(order: order);
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(myOrderDetailProvider(widget.orderId)),
          );
        },
        data: (o) => _Content(order: o),
      ),
      bottomNavigationBar: (order != null && (order.canCancel || order.canPay || order.canReorder))
          ? GlassBottomBar(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (order.canPay)
                      AppButton(
                        label: l10n.payPayOnline,
                        icon: Icons.credit_card_rounded,
                        onPressed: _busy ? null : _pay,
                      ),
                    if (order.canReorder)
                      AppButton(
                        label: l10n.orderReorderAction,
                        icon: Icons.replay_rounded,
                        isLoading: _busy,
                        onPressed: _busy ? null : _reorder,
                      ),
                    if (order.canPay && order.canCancel) const SizedBox(height: AppSpacing.sm),
                    if (order.canCancel)
                      AppButton(
                        label: l10n.orderCancelAction,
                        variant: AppButtonVariant.secondary,
                        isLoading: _busy,
                        onPressed: _busy ? null : _cancel,
                      ),
                  ],
                ),
            )
          : null,
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.order});

  final MyOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final when = order.scheduledAt;
    final cancelled = order.status == OrderStatus.cancelled;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.lg),
          child: cancelled
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppBadge(label: orderStatusLabel(l10n, order.status), tone: AppBadgeTone.error),
                      if ((order.cancelReason ?? '').isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(order.cancelReason!, style: text.bodyMedium),
                      ],
                    ],
                  ),
                )
              : OrderStatusTimeline(steps: order.steps, current: order.status),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              if (when != null) _Line(label: l10n.orderScheduledFor, value: context.formatDateTime(when)),
              _Line(label: l10n.checkoutFulfillmentSection, value: fulfillmentLabel(l10n, order.fulfillment)),
              if (order.fulfillment == FulfillmentType.delivery && (order.address ?? '').isNotEmpty)
                _Line(label: l10n.checkoutAddress, value: order.address!),
              _Line(label: l10n.checkoutPaymentSection, value: paymentMethodLabel(l10n, order.paymentMethod)),
              _Line(label: l10n.myOrderPaymentStatus, value: paymentStatusLabel(l10n, order.paymentStatus)),
              if ((order.customerNote ?? '').isNotEmpty)
                _Line(label: l10n.checkoutNote, value: order.customerNote!),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.myOrderItems, style: text.labelLarge?.copyWith(color: c.textSecondary)),
              const SizedBox(height: AppSpacing.sm),
              for (final item in order.items)
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.productName, style: text.bodyMedium),
                            if (item.variants.isNotEmpty)
                              Text(
                                item.variants.map((v) => v.forLanguage(lang)).join(', '),
                                style: text.bodySmall?.copyWith(color: c.textSecondary),
                              ),
                            Text(
                              '${item.quantity} × ${context.formatPrice(item.unitPrice)}',
                              style: text.bodySmall?.copyWith(color: c.textSecondary),
                            ),
                            if (order.canReview && item.productId != null)
                              Padding(
                                padding: const EdgeInsets.only(top: AppSpacing.xs),
                                child: AppButton(
                                  label: l10n.orderRateItem,
                                  icon: Icons.star_outline_rounded,
                                  variant: AppButtonVariant.text,
                                  expanded: false,
                                  onPressed: () => context.push(AppRoutes.review(item.productId!)),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Text(context.formatPrice(item.lineTotal), style: text.bodyMedium),
                    ],
                  ),
                ),
              const Divider(),
              _Line(label: l10n.myOrderSubtotal, value: context.formatPrice(order.subtotal)),
              if (order.deliveryFee > 0)
                _Line(label: l10n.checkoutDeliveryFee, value: context.formatPrice(order.deliveryFee)),
              if (order.discount > 0)
                _Line(label: l10n.adminOrderDiscount, value: '−${context.formatPrice(order.discount)}'),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(child: Text(l10n.productTotal, style: text.titleSmall)),
                  Text(context.formatPrice(order.total), style: text.titleSmall?.copyWith(color: c.primary)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 4, child: Text(label, style: text.bodySmall?.copyWith(color: c.textSecondary))),
          Expanded(flex: 6, child: Text(value, textAlign: TextAlign.end, style: text.bodyMedium)),
        ],
      ),
    );
  }
}
