import '../../../l10n/gen/app_localizations.dart';
import '../domain/order_models.dart';

String orderStatusLabel(AppLocalizations l10n, OrderStatus status) => switch (status) {
      OrderStatus.pending => l10n.orderStatusPending,
      OrderStatus.accepted => l10n.orderStatusAccepted,
      OrderStatus.cancelled => l10n.orderStatusCancelled,
      OrderStatus.ready => l10n.orderStatusReady,
      OrderStatus.onTheWay => l10n.orderStatusOnTheWay,
      OrderStatus.delivered => l10n.orderStatusDelivered,
    };

String paymentMethodLabel(AppLocalizations l10n, PaymentMethod method) => switch (method) {
      PaymentMethod.cash => l10n.paymentCash,
      PaymentMethod.online => l10n.paymentOnline,
    };

String fulfillmentLabel(AppLocalizations l10n, FulfillmentType type) => switch (type) {
      FulfillmentType.pickup => l10n.fulfillmentPickup,
      FulfillmentType.delivery => l10n.fulfillmentDelivery,
    };
