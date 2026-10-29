import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../domain/order_models.dart';
import 'order_labels.dart';
import 'widgets/animated_check.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key, required this.order});

  final PlacedOrder order;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    Widget row(String label, Widget value) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Text(label, style: text.bodyMedium?.copyWith(color: c.textSecondary))),
              const SizedBox(width: AppSpacing.md),
              Flexible(child: Align(alignment: Alignment.centerRight, child: value)),
            ],
          ),
        );

    Widget valueText(String v) => Text(v, textAlign: TextAlign.right, style: text.titleSmall);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.xl),
                children: [
                  const SizedBox(height: AppSpacing.xxl),
                  const Center(child: AnimatedCheck()),
                  const SizedBox(height: AppSpacing.xl),
                  Text(l10n.orderSuccessTitle, textAlign: TextAlign.center, style: text.headlineSmall),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.orderSuccessMessage,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.4),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  AppCard(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Column(
                      children: [
                        row(l10n.orderNumber(order.number), AppBadge(label: orderStatusLabel(l10n, order.status), tone: AppBadgeTone.primary)),
                        if (order.scheduledAt != null)
                          row(l10n.orderScheduledFor, valueText(context.formatDateTime(order.scheduledAt!))),
                        row(l10n.checkoutFulfillmentSection, valueText(fulfillmentLabel(l10n, order.fulfillment))),
                        row(l10n.checkoutPaymentSection, valueText(paymentMethodLabel(l10n, order.paymentMethod))),
                        if (order.deliveryFee > 0)
                          row(l10n.checkoutDeliveryFee, valueText(context.formatPrice(order.deliveryFee))),
                        const Divider(height: AppSpacing.xl),
                        row(
                          l10n.productTotal,
                          Text(context.formatPrice(order.total), style: text.titleMedium?.copyWith(color: c.primary)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (order.paymentMethod == PaymentMethod.online) ...[
                    AppButton(
                      label: l10n.payNow,
                      icon: Icons.credit_card_rounded,
                      onPressed: () => context.push(AppRoutes.pay(order.id)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                  AppButton(
                    label: l10n.orderBackHome,
                    variant: order.paymentMethod == PaymentMethod.online
                        ? AppButtonVariant.secondary
                        : AppButtonVariant.primary,
                    onPressed: () => context.go(AppRoutes.home),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
