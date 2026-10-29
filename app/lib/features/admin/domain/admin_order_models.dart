import 'package:flutter/foundation.dart';

import '../../order/domain/order_models.dart';
import '../../order/domain/payment_status.dart';
import 'admin_models.dart';

@immutable
class AdminOrderCustomer {
  const AdminOrderCustomer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.phone,
    required this.email,
  });

  factory AdminOrderCustomer.fromJson(Map<String, dynamic> json) => AdminOrderCustomer(
        id: json['id'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        email: (json['email'] as String?) ?? '',
      );

  final String id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String email;

  String get fullName {
    final name = [firstName, lastName].where((e) => e != null && e.trim().isNotEmpty).join(' ').trim();
    return name.isEmpty ? email : name;
  }
}

@immutable
class AdminOrderItem {
  const AdminOrderItem({
    required this.id,
    required this.productName,
    required this.variants,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
  });

  factory AdminOrderItem.fromJson(Map<String, dynamic> json) {
    final options = json['options'];
    final rawVariants = options is Map ? options['variants'] : null;
    return AdminOrderItem(
      id: json['id'] as String,
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
  final String productName;
  final List<LocalizedText> variants;
  final double unitPrice;
  final int quantity;
  final double lineTotal;
}

@immutable
class AdminOrder {
  const AdminOrder({
    required this.id,
    required this.number,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.fulfillment,
    required this.scheduledAt,
    required this.customerNote,
    required this.address,
    required this.phone,
    required this.subtotal,
    required this.deliveryFee,
    required this.discount,
    required this.total,
    required this.cancelReason,
    required this.items,
    required this.customer,
    required this.createdAt,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) => AdminOrder(
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
        phone: json['phone'] as String?,
        subtotal: (json['subtotal'] as num).toDouble(),
        deliveryFee: (json['deliveryFee'] as num).toDouble(),
        discount: (json['discount'] as num).toDouble(),
        total: (json['total'] as num).toDouble(),
        cancelReason: json['cancelReason'] as String?,
        items: ((json['items'] as List?) ?? const [])
            .map((e) => AdminOrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        customer: AdminOrderCustomer.fromJson(json['customer'] as Map<String, dynamic>),
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
  final String? phone;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double total;
  final String? cancelReason;
  final List<AdminOrderItem> items;
  final AdminOrderCustomer customer;
  final DateTime createdAt;

  /// Keyingi holat: kutilmoqda → qabul qilindi → tayyor → (yo'lda) → topshirildi.
  OrderStatus? get nextStatus => switch (status) {
        OrderStatus.pending => OrderStatus.accepted,
        OrderStatus.accepted => OrderStatus.ready,
        OrderStatus.ready =>
          fulfillment == FulfillmentType.delivery ? OrderStatus.onTheWay : OrderStatus.delivered,
        OrderStatus.onTheWay => OrderStatus.delivered,
        _ => null,
      };

  /// Yakunlangan yoki bekor qilingan buyurtma qayta bekor qilinmaydi.
  bool get canCancel => status != OrderStatus.cancelled && status != OrderStatus.delivered;
}
