import 'package:flutter/foundation.dart';

import '../../admin/domain/admin_models.dart';

@immutable
class CartItem {
  const CartItem({
    required this.key,
    required this.productId,
    required this.name,
    required this.image,
    required this.unitPrice,
    required this.variantIds,
    required this.variantNames,
    required this.stock,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
        key: json['key'] as String,
        productId: json['productId'] as String,
        name: LocalizedText.fromJson(json['name']),
        image: json['image'] as String?,
        unitPrice: (json['unitPrice'] as num).toDouble(),
        variantIds: ((json['variantIds'] as List?) ?? const []).cast<String>(),
        variantNames: ((json['variantNames'] as List?) ?? const []).map(LocalizedText.fromJson).toList(),
        stock: (json['stock'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
      );

  /// Bir xil mahsulot va bir xil variantlar to'plami — bitta qator.
  static String keyFor(String productId, List<String> variantIds) {
    final sorted = [...variantIds]..sort();
    return '$productId|${sorted.join(',')}';
  }

  final String key;
  final String productId;
  final LocalizedText name;
  final String? image;
  final double unitPrice;
  final List<String> variantIds;
  final List<LocalizedText> variantNames;
  final int stock;
  final int quantity;

  double get lineTotal => unitPrice * quantity;

  CartItem copyWith({
    LocalizedText? name,
    String? image,
    double? unitPrice,
    List<LocalizedText>? variantNames,
    int? stock,
    int? quantity,
  }) {
    return CartItem(
      key: key,
      productId: productId,
      name: name ?? this.name,
      image: image ?? this.image,
      unitPrice: unitPrice ?? this.unitPrice,
      variantIds: variantIds,
      variantNames: variantNames ?? this.variantNames,
      stock: stock ?? this.stock,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() => {
        'key': key,
        'productId': productId,
        'name': name.toJson(),
        'image': image,
        'unitPrice': unitPrice,
        'variantIds': variantIds,
        'variantNames': variantNames.map((e) => e.toJson()).toList(),
        'stock': stock,
        'quantity': quantity,
      };
}

enum CartCheckStatus {
  ok,
  outOfStock,
  unavailable;

  static CartCheckStatus fromApi(String? v) => switch (v) {
        'OK' => CartCheckStatus.ok,
        'OUT_OF_STOCK' => CartCheckStatus.outOfStock,
        _ => CartCheckStatus.unavailable,
      };
}

/// Serverning bitta savat qatori bo'yicha javobi.
@immutable
class CartCheck {
  const CartCheck({
    required this.key,
    required this.status,
    required this.stock,
    required this.unitPrice,
    this.name,
    this.image,
    this.variantNames,
  });

  factory CartCheck.fromJson(Map<String, dynamic> json) => CartCheck(
        key: json['key'] as String,
        status: CartCheckStatus.fromApi(json['status'] as String?),
        stock: (json['stock'] as num?)?.toInt() ?? 0,
        unitPrice: (json['unitPrice'] as num?)?.toDouble() ?? 0,
        name: json['name'] == null ? null : LocalizedText.fromJson(json['name']),
        image: json['image'] as String?,
        variantNames: json['variants'] == null
            ? null
            : (json['variants'] as List)
                .map((e) => LocalizedText.fromJson((e as Map)['name']))
                .toList(),
      );

  final String key;
  final CartCheckStatus status;
  final int stock;
  final double unitPrice;
  final LocalizedText? name;
  final String? image;
  final List<LocalizedText>? variantNames;
}
