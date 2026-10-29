import 'package:flutter/foundation.dart';

import '../../admin/domain/admin_models.dart';

@immutable
class CatalogCategory {
  const CatalogCategory({required this.id, required this.name});

  factory CatalogCategory.fromJson(Map<String, dynamic> json) => CatalogCategory(
        id: json['id'] as String,
        name: LocalizedText.fromJson(json['name']),
      );

  final String id;
  final LocalizedText name;
}

@immutable
class CatalogVariant {
  const CatalogVariant({
    required this.id,
    required this.group,
    required this.name,
    required this.priceDelta,
  });

  factory CatalogVariant.fromJson(Map<String, dynamic> json) => CatalogVariant(
        id: json['id'] as String,
        group: VariantGroup.fromApi(json['group'] as String?),
        name: LocalizedText.fromJson(json['name']),
        priceDelta: (json['priceDelta'] as num).toDouble(),
      );

  final String id;
  final VariantGroup group;
  final LocalizedText name;
  final double priceDelta;
}

@immutable
class CatalogProduct {
  const CatalogProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.allergens,
    required this.price,
    required this.stock,
    required this.images,
    required this.categoryId,
    required this.categoryName,
    required this.variants,
    required this.averageRating,
    required this.reviewsCount,
  });

  factory CatalogProduct.fromJson(Map<String, dynamic> json) {
    final category = json['category'];
    return CatalogProduct(
      id: json['id'] as String,
      name: LocalizedText.fromJson(json['name']),
      description: LocalizedText.fromJson(json['description']),
      ingredients: LocalizedText.fromJson(json['ingredients']),
      allergens: LocalizedText.fromJson(json['allergens']),
      price: (json['price'] as num).toDouble(),
      stock: (json['stock'] as num).toInt(),
      images: ((json['images'] as List?) ?? const []).cast<String>(),
      categoryId: json['categoryId'] as String?,
      categoryName: category is Map ? LocalizedText.fromJson(category['name']) : null,
      variants: ((json['variants'] as List?) ?? const [])
          .map((e) => CatalogVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText ingredients;
  final LocalizedText allergens;
  final double price;
  final int stock;
  final List<String> images;
  final String? categoryId;
  final LocalizedText? categoryName;
  final List<CatalogVariant> variants;
  final double averageRating;
  final int reviewsCount;

  bool get inStock => stock > 0;
  String? get mainImage => images.isEmpty ? null : images.first;

  List<CatalogVariant> variantsOf(VariantGroup group) =>
      variants.where((v) => v.group == group).toList();
}

/// Mahsulot sahifasida mijoz tanlagan variantlar. Savat bosqichida shu obyekt ishlatiladi.
@immutable
class ProductSelection {
  const ProductSelection({
    required this.product,
    required this.variantIds,
    required this.unitPrice,
    this.quantity = 1,
  });

  final CatalogProduct product;
  final List<String> variantIds;
  final double unitPrice;
  final int quantity;
}
