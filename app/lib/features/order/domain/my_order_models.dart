import 'package:flutter/foundation.dart';

import '../../admin/domain/admin_models.dart';
import 'order_models.dart';
import 'payment_status.dart';

@immutable
class MyOrderItem {
  const MyOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.variants,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory MyOrderItem.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    final rawVariants = options is Map ? options['variants'] : null;
    return MyOrderItem(
      id: json['id'] as String,
      productId: json['productId'] as String?,
      productName: json['productName'] as String,
      variants: [
        if (rawVariants is List)
          for (final v in rawVariants)
            if (v is Map) LocalizedText.fromJson(v['name']),
      ],
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      lineTotal: (json['lineTotal'] as num).toDouble(),
    );
  }

  final String id;

  /// Mahsulot keyinchalik o'chirilgan bo'lsa null.
  final String? productId;
  final String productName;
  final List<LocalizedText> variants;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
}

@immutable
class MyOrder {
  const MyOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.fulfillment,
    required this.scheduledAt,
    required this.customerNote,
    required this.address,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.cancelReason,
    required this.items,
    required this.createdAt,
  });

  factory MyOrder.fromJson(Map<String, dynamic> json) => MyOrder(
        id: json['id'] as String,
        number: (json['number'] as num).toInt(),
        status: OrderStatus.fromApi(json['status'] as String?),
        paymentMethod: PaymentMethod.fromApi(json['paymentMethod'] as String?),
        paymentStatus: PaymentStatus.fromApi(json['paymentStatus'] as String?),
        fulfillment: FulfillmentType.fromApi(json['fulfillment'] as String?),
        scheduledAt:
            json['scheduledAt'] == null ? null : DateTime.parse(json['scheduledAt'] as String).toLocal(),
        customerNote: json['customerNote'] as String?,
        address: json['address'] as String?,
        subtotal: (json['subtotal'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        cancelReason: json['cancelReason'] as String?,
        items: ((json['items'] as List?) ?? const [])
            .map((e) => MyOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(json['createdAt'] as String).toLocal(),
      );

  final String id;
  final int number;
  final OrderStatus status;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final FulfillmentType fulfillment;
  final DateTime? scheduledAt;
  final String? customerNote;
  final String? address;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? cancelReason;
  final List<MyOrderItem> items;
  final DateTime createdAt;

  /// Gorizontal bosqichli chiziq: yetkazib berishda "Yo'lda" bosqichi ham bor.
  List<OrderStatus> get steps => [
        OrderStatus.pending,
        OrderStatus.accepted,
        OrderStatus.ready,
        if (fulfillment == FulfillmentType.delivery) OrderStatus.onTheWay,
        OrderStatus.delivered,
      ];

  /// Sharh faqat topshirilgan buyurtmadagi mahsulotga qoldiriladi.
  bool get canReview => status == OrderStatus.delivered;

  /// Mijoz faqat admin qabul qilishidan oldin bekor qila oladi.
  bool get canCancel => status == OrderStatus.pending;

  /// Topshirilgan buyurtmani bir bosishda savatga qaytarish mumkin.
  bool get canReorder => status == OrderStatus.delivered;

  /// Onlayn to'lov tanlangan va hali to'lanmagan bo'lsa, istalgan payt to'lash mumkin.
  bool get canPay =>
      paymentMethod == PaymentMethod.online &&
      paymentStatus == PaymentStatus.unpaid &&
      status != OrderStatus.cancelled &&
      status != OrderStatus.delivered;
}
