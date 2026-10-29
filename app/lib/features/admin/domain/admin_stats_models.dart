import 'package:flutter/foundation.dart';

@immutable
class SalesPoint {
  const SalesPoint({required this.key, required this.orders, required this.revenue});

  factory SalesPoint.fromJson(Map<String, dynamic> json) => SalesPoint(
        key: json['key'] as String,
        orders: (json['orders'] as num?)?.toInt() ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  /// Kun uchun «2026-10-29», oy uchun «2026-10».
  final String key;
  final int orders;
  final double revenue;

  /// Kalitni sanaga aylantiradi (oy uchun 1-kun olinadi).
  DateTime get date {
    final p = key.split('-').map(int.parse).toList();
    return DateTime(p[0], p[1], p.length > 2 ? p[2] : 1);
  }
}

@immutable
class TopProduct {
  const TopProduct({required this.name, required this.quantity, required this.revenue});

  factory TopProduct.fromJson(Map<String, dynamic> json) => TopProduct(
        name: json['name'] as String,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
        revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      );

  final String name;
  final int quantity;
  final double revenue;
}

@immutable
class StatsOverview {
  const StatsOverview({
    required this.today,
    required this.month,
    required this.daily,
    required this.monthly,
    required this.topProducts,
  });

  factory StatsOverview.fromJson(Map<String, dynamic> json) {
    List<SalesPoint> points(String k) =>
        (json[k] as List<dynamic>).map((e) => SalesPoint.fromJson(e as Map<String, dynamic>)).toList();
    return StatsOverview(
      today: SalesPoint.fromJson(json['today'] as Map<String, dynamic>),
      month: SalesPoint.fromJson(json['month'] as Map<String, dynamic>),
      daily: points('daily'),
      monthly: points('monthly'),
      topProducts: (json['topProducts'] as List<dynamic>)
          .map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  final SalesPoint today;
  final SalesPoint month;
  final List<SalesPoint> daily;
  final List<SalesPoint> monthly;
  final List<TopProduct> topProducts;
}

@immutable
class CustomerStat {
  const CustomerStat({
    required this.id,
    required this.email,
    required this.orders,
    required this.spent,
    this.firstName,
    this.lastName,
    this.phone,
    this.lastOrderAt,
  });

  factory CustomerStat.fromJson(Map<String, dynamic> json) => CustomerStat(
        id: json['id'] as String,
        email: json['email'] as String,
        firstName: json['firstName'] as String?,
        lastName: json['lastName'] as String?,
        phone: json['phone'] as String?,
        orders: (json['orders'] as num?)?.toInt() ?? 0,
        spent: (json['spent'] as num?)?.toDouble() ?? 0,
        lastOrderAt:
            json['lastOrderAt'] == null ? null : DateTime.parse(json['lastOrderAt'] as String).toLocal(),
      );

  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final int orders;
  final double spent;
  final DateTime? lastOrderAt;

  String get fullName => [firstName, lastName]
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .join(' ');
}
