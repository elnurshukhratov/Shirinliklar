import 'package:flutter/foundation.dart';

enum FulfillmentType {
  pickup('PICKUP'),
  delivery('DELIVERY');

  const FulfillmentType(this.api);
  final String api;

  static FulfillmentType fromApi(String? v) =>
      FulfillmentType.values.firstWhere((e) => e.api == v, orElse: () => FulfillmentType.pickup);
}

enum PaymentMethod {
  cash('CASH'),
  online('ONLINE');

  const PaymentMethod(this.api);
  final String api;

  static PaymentMethod fromApi(String? v) =>
      PaymentMethod.values.firstWhere((e) => e.api == v, orElse: () => PaymentMethod.cash);
}

enum OrderStatus {
  pending('PENDING'),
  accepted('ACCEPTED'),
  cancelled('CANCELLED'),
  ready('READY'),
  onTheWay('ON_THE_WAY'),
  delivered('DELIVERED');

  const OrderStatus(this.api);
  final String api;

  static OrderStatus fromApi(String? v) =>
      OrderStatus.values.firstWhere((e) => e.api == v, orElse: () => OrderStatus.pending);
}

@immutable
class CheckoutOptions {
  const CheckoutOptions({
    required this.deliveryFee,
    required this.minLeadMinutes,
    required this.maxDaysAhead,
    this.acceptingOrders = true,
  });

  factory CheckoutOptions.fromJson(Map<String, dynamic> json) => CheckoutOptions(
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        minLeadMinutes: (json['minLeadMinutes'] as num).toInt(),
        maxDaysAhead: (json['maxDaysAhead'] as num).toInt(),
        acceptingOrders: json['acceptingOrders'] != false,
      );

  final double deliveryFee;
  final int minLeadMinutes;
  final int maxDaysAhead;

  /// false — do'kon bugun buyurtma qabul qilmaydi.
  final bool acceptingOrders;
}

@immutable
class PlacedOrder {
  const PlacedOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.fulfillment,
    required this.paymentMethod,
    required this.scheduledAt,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
  });

  factory PlacedOrder.fromJson(Map<String, dynamic> json) => PlacedOrder(
        id: json['id'] as String,
        number: (json['number'] as num).toInt(),
        status: OrderStatus.fromApi(json['status'] as String?),
        fulfillment: FulfillmentType.fromApi(json['fulfillment'] as String?),
        paymentMethod: PaymentMethod.fromApi(json['paymentMethod'] as String?),
        scheduledAt: json['scheduledAt'] == null ? null : DateTime.parse(json['scheduledAt'] as String).toLocal(),
        subtotal: (json['subtotal'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
      );

  final String id;
  final int number;
  final OrderStatus status;
  final FulfillmentType fulfillment;
  final PaymentMethod paymentMethod;
  final DateTime? scheduledAt;
  final double subtotal;
  final double deliveryFee;
  final double total;
}
