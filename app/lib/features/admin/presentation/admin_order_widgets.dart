import 'package:flutter/material.dart';

import '../../../core/widgets/app_badge.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../order/domain/order_models.dart';
import '../../order/domain/payment_status.dart';

/// Buyurtma holati nishonining rangi.
AppBadgeTone orderStatusTone(OrderStatus status) => switch (status) {
      OrderStatus.pending => AppBadgeTone.neutral,
      OrderStatus.accepted => AppBadgeTone.primary,
      OrderStatus.ready || OrderStatus.onTheWay || OrderStatus.delivered => AppBadgeTone.success,
      OrderStatus.cancelled => AppBadgeTone.error,
    };

String paymentStatusLabel(AppLocalizations l10n, PaymentStatus status) => switch (status) {
      PaymentStatus.unpaid => l10n.paymentStatusUnpaid,
      PaymentStatus.paid => l10n.paymentStatusPaid,
      PaymentStatus.refunded => l10n.paymentStatusRefunded,
    };

AppBadgeTone paymentStatusTone(PaymentStatus status) => switch (status) {
      PaymentStatus.unpaid => AppBadgeTone.neutral,
      PaymentStatus.paid => AppBadgeTone.success,
      PaymentStatus.refunded => AppBadgeTone.primary,
    };

/// Admin amal tugmasi uchun belgi: keyingi holatga qarab.
IconData orderActionIcon(OrderStatus to) => switch (to) {
      OrderStatus.accepted => Icons.check_rounded,
      OrderStatus.ready => Icons.inventory_2_outlined,
      OrderStatus.onTheWay => Icons.delivery_dining_rounded,
      _ => Icons.done_all_rounded,
    };
