import '../../../core/widgets/glass/glass_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../order/domain/order_models.dart';
import '../../order/domain/payment_status.dart';
import '../../order/presentation/order_labels.dart';
import '../../auth/application/auth_controller.dart';
import '../application/admin_order_providers.dart';
import 'widgets/confirm_dialog.dart';
import '../domain/admin_order_models.dart';
import 'admin_order_widgets.dart';

/// Admin: buyurtma tafsiloti va amallar (qabul qilish, bekor qilish, tayyor, yo'lda, topshirildi).
class AdminOrderDetailScreen extends ConsumerStatefulWidget {
  const AdminOrderDetailScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<AdminOrderDetailScreen> createState() => _AdminOrderDetailScreenState();
}

class _AdminOrderDetailScreenState extends ConsumerState<AdminOrderDetailScreen> {
  bool _busy = false;

  Future<void> _run(Future<AdminOrder> Function() call) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final updated = await call();
      ref.read(adminOrderListProvider.notifier).applyUpdated(updated);
      ref.invalidate(adminOrderDetailProvider(widget.orderId));
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminOrderUpdated)));
    } catch (e) {
      // Boshqa admin holatni o'zgartirgan bo'lishi mumkin: eng so'nggi holatni qayta yuklaymiz.
      ref.invalidate(adminOrderDetailProvider(widget.orderId));
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _advance(AdminOrder order, OrderStatus to) {
    return _run(() => ref.read(adminOrdersRepositoryProvider).advance(order.id, to));
  }

  Future<void> _refund(AdminOrder order) async {
    final l10n = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l10n.adminOrderRefundTitle,
      message: l10n.adminOrderRefundMessage,
      confirmLabel: l10n.adminOrderRefundConfirm,
    );
    if (!ok || !mounted) return;
    await _run(() => ref.read(adminOrdersRepositoryProvider).refund(order.id));
  }

  Future<void> _cancel(AdminOrder order) async {
    final reason = await showDialog<String>(
      context: context,
      builder: (_) => const _CancelReasonDialog(),
    );
    if (reason == null || !mounted) return;
    await _run(() => ref.read(adminOrdersRepositoryProvider).cancel(order.id, reason));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(adminOrderDetailProvider(widget.orderId));
    final order = detail.valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Text(order == null ? l10n.adminTabOrders : l10n.adminOrderTitle(order.number)),
      ),
      body: detail.when(
        loading: () => order == null
            ? const Center(child: CircularProgressIndicator())
            : _Content(order: order),
        error: (e, _) {
          if (order != null) return _Content(order: order);
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(adminOrderDetailProvider(widget.orderId)),
          );
        },
        data: (o) => _Content(order: o),
      ),
      bottomNavigationBar: order == null ? null : _actionBar(context, order),
    );
  }

  Widget? _actionBar(BuildContext context, AdminOrder order) {
    final l10n = context.l10n;
    final c = context.colors;
    final next = order.nextStatus;
    // Pulni qaytarish faqat do'kon egasiga ruxsat etiladi.
    final isOwner = ref.watch(authControllerProvider).user?.isOwner ?? false;
    final canRefund = isOwner &&
        order.paymentMethod == PaymentMethod.online &&
        order.paymentStatus == PaymentStatus.paid;
    if (next == null && !order.canCancel && !canRefund) return null;

    final showCashHint = next == OrderStatus.delivered &&
        order.paymentMethod == PaymentMethod.cash &&
        order.paymentStatus == PaymentStatus.unpaid;

    return GlassBottomBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showCashHint)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Text(
                  l10n.adminOrderCashHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textSecondary),
                ),
              ),
            if (next != null)
              AppButton(
                label: _actionLabel(l10n, next),
                icon: orderActionIcon(next),
                isLoading: _busy,
                onPressed: _busy ? null : () => _advance(order, next),
              ),
            if (next != null && order.canCancel) const SizedBox(height: AppSpacing.sm),
            if (order.canCancel)
              AppButton(
                label: l10n.adminOrderCancel,
                variant: AppButtonVariant.secondary,
                onPressed: _busy ? null : () => _cancel(order),
              ),
            if (canRefund) ...[
              if (next != null || order.canCancel) const SizedBox(height: AppSpacing.sm),
              AppButton(
                label: l10n.adminOrderRefund,
                variant: AppButtonVariant.secondary,
                onPressed: _busy ? null : () => _refund(order),
              ),
            ],
          ],
        ),
    );
  }

  String _actionLabel(AppLocalizations l10n, OrderStatus to) => switch (to) {
        OrderStatus.accepted => l10n.adminOrderAccept,
        OrderStatus.ready => l10n.adminOrderMarkReady,
        OrderStatus.onTheWay => l10n.adminOrderMarkOnTheWay,
        _ => l10n.adminOrderMarkDelivered,
      };
}

class _Content extends StatelessWidget {
  const _Content({required this.order});

  final AdminOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final when = order.scheduledAt;
    final phone = order.phone ?? order.customer.phone;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            AppBadge(label: orderStatusLabel(l10n, order.status), tone: orderStatusTone(order.status)),
            AppBadge(
              label: paymentStatusLabel(l10n, order.paymentStatus),
              tone: paymentStatusTone(order.paymentStatus),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _Section(
          title: l10n.adminOrderCustomer,
          children: [
            Text(order.customer.fullName, style: text.titleSmall),
            if (phone != null && phone.isNotEmpty) _Line(label: l10n.profilePhone, value: phone),
            if (order.fulfillment == FulfillmentType.delivery && (order.address ?? '').isNotEmpty)
              _Line(label: l10n.checkoutAddress, value: order.address!),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: l10n.adminOrderDetails,
          children: [
            if (when != null) _Line(label: l10n.orderScheduledFor, value: context.formatDateTime(when)),
            _Line(label: l10n.adminOrderReceiving, value: fulfillmentLabel(l10n, order.fulfillment)),
            _Line(label: l10n.adminOrderPayment, value: paymentMethodLabel(l10n, order.paymentMethod)),
            if ((order.customerNote ?? '').isNotEmpty)
              _Line(label: l10n.adminOrderNote, value: order.customerNote!),
          ],
        ),
        if (order.status == OrderStatus.cancelled && (order.cancelReason ?? '').isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _Section(
            title: l10n.adminOrderCancelReasonTitle,
            children: [Text(order.cancelReason!, style: text.bodyMedium?.copyWith(color: c.error))],
          ),
        ],
        const SizedBox(height: AppSpacing.md),
        _Section(
          title: l10n.adminOrderItems,
          children: [
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
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Text(context.formatPrice(item.lineTotal), style: text.bodyMedium),
                  ],
                ),
              ),
            const Divider(),
            _Line(label: l10n.adminOrderSubtotal, value: context.formatPrice(order.subtotal)),
            if (order.deliveryFee > 0)
              _Line(label: l10n.adminOrderDeliveryFee, value: context.formatPrice(order.deliveryFee)),
            if (order.discount > 0)
              _Line(label: l10n.adminOrderDiscount, value: '−${context.formatPrice(order.discount)}'),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(child: Text(l10n.adminOrderTotal, style: text.titleSmall)),
                Text(context.formatPrice(order.total), style: text.titleSmall),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
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
      padding: const EdgeInsets.only(top: 4),
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

class _CancelReasonDialog extends StatefulWidget {
  const _CancelReasonDialog();

  @override
  State<_CancelReasonDialog> createState() => _CancelReasonDialogState();
}

class _CancelReasonDialogState extends State<_CancelReasonDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.adminOrderCancelTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminOrderCancelMessage),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 300,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(labelText: l10n.adminOrderCancelReasonLabel),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: _controller,
          builder: (context, value, _) {
            final reason = value.text.trim();
            return TextButton(
              onPressed: reason.isEmpty ? null : () => Navigator.of(context).pop(reason),
              child: Text(
                l10n.adminOrderCancelConfirm,
                style: TextStyle(color: reason.isEmpty ? null : context.colors.error),
              ),
            );
          },
        ),
      ],
    );
  }
}
