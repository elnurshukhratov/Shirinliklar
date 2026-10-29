import 'package:flutter/foundation.dart';

enum PromoStatus {
  active,
  inactive,
  expired,
  exhausted;

  static PromoStatus fromApi(String? v) => switch (v) {
        'INACTIVE' => PromoStatus.inactive,
        'EXPIRED' => PromoStatus.expired,
        'EXHAUSTED' => PromoStatus.exhausted,
        _ => PromoStatus.active,
      };
}

@immutable
class AdminPromo {
  const AdminPromo({
    required this.id,
    required this.code,
    required this.usedCount,
    required this.isActive,
    required this.status,
    this.discountPercent,
    this.discountAmount,
    this.expiresAt,
    this.usageLimit,
  });

  factory AdminPromo.fromJson(Map<String, dynamic> json) => AdminPromo(
        id: json['id'] as String,
        code: json['code'] as String,
        discountPercent: (json['discountPercent'] as num?)?.toInt(),
        discountAmount: (json['discountAmount'] as num?)?.toDouble(),
        expiresAt: json['expiresAt'] == null ? null : DateTime.parse(json['expiresAt'] as String).toLocal(),
        usageLimit: (json['usageLimit'] as num?)?.toInt(),
        usedCount: (json['usedCount'] as num?)?.toInt() ?? 0,
        isActive: json['isActive'] != false,
        status: PromoStatus.fromApi(json['status'] as String?),
      );

  final String id;
  final String code;

  /// Foiz yoki aniq summa — ulardan faqat bittasi bo'ladi.
  final int? discountPercent;
  final double? discountAmount;
  final DateTime? expiresAt;
  final int? usageLimit;
  final int usedCount;
  final bool isActive;
  final PromoStatus status;

  bool get isPercent => discountPercent != null;
}
