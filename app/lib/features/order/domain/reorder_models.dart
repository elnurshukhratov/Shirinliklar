import 'package:flutter/foundation.dart';

import '../../admin/domain/admin_models.dart';
import '../../cart/domain/cart_models.dart';

/// «Qayta buyurtma» javobi: savatga qo'shishga tayyor qatorlar va qo'shib bo'lmaganlar.
@immutable
class ReorderResult {
  const ReorderResult({
    required this.items,
    required this.unavailable,
    required this.reduced,
  });

  factory ReorderResult.fromJson(Map<String, dynamic> json) {
    CartItem item(Map<String, dynamic> m) {
      final productId = m['productId'] as String;
      final variantIds = ((m['variantIds'] as List?) ?? const []).cast<String>();
      return CartItem(
        key: CartItem.keyFor(productId, variantIds),
        productId: productId,
        name: LocalizedText.fromJson(m['name']),
        image: m['image'] as String?,
        unitPrice: (m['unitPrice'] as num).toDouble(),
        variantIds: variantIds,
        variantNames: [
          for (final v in (m['variants'] as List?) ?? const [])
            if (v is Map) LocalizedText.fromJson(v['name']),
        ],
        stock: (m['stock'] as num).toInt(),
        quantity: (m['quantity'] as num).toInt(),
      );
    }

    return ReorderResult(
      items: [
        for (final e in (json['items'] as List?) ?? const []) item(e as Map<String, dynamic>),
      ],
      unavailable: [
        for (final e in (json['unavailable'] as List?) ?? const []) LocalizedText.fromJson(e),
      ],
      reduced: json['reduced'] as bool? ?? false,
    );
  }

  final List<CartItem> items;

  /// Tugagan, yashirilgan yoki o'chirilgan mahsulotlar nomi.
  final List<LocalizedText> unavailable;

  /// Ba'zi qatorlar miqdori omborga moslab kamaytirilgan.
  final bool reduced;
}
