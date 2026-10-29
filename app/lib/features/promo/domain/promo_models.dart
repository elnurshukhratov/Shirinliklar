import 'package:flutter/foundation.dart';

/// Savatda qo'llangan promokod. Chegirma serverdagi qoida bilan bir xil hisoblanadi:
/// yetkazish narxiga qo'llanmaydi va mahsulotlar summasidan oshmaydi.
@immutable
class AppliedPromo {
  const AppliedPromo({
    required this.code,
    this.discountPercent,
    this.discountAmount,
    this.expiresAt,
  });

  factory AppliedPromo.fromJson(Map<String, dynamic> json) => AppliedPromo(
        code: json['code'] as String,
        discountPercent: (json['discountPercent'] as num?)?.toInt(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String).toLocal(),
      );

  final String code;
  final int? discountPercent;
  final double? discountAmount;
  final DateTime? expiresAt;

  double discountFor(double subtotal) {
    double discount = 0;
    if (discountPercent != null) {
      discount = (subtotal * discountPercent! / 100).roundToDouble();
    } else if (discountAmount != null) {
      discount = discountAmount!;
    }
    if (discount < 0) return 0;
    return discount > subtotal ? subtotal : discount;
  }
}
