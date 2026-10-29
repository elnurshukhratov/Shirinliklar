import 'package:flutter/foundation.dart';

/// Uch tilli matn: { uz, en, ru }.
@immutable
class LocalizedText {
  const LocalizedText({this.uz = '', this.en = '', this.ru = ''});

  factory LocalizedText.fromJson(Object? json) {
    final m = json is Map ? json : const <String, dynamic>{};
    String s(String k) => (m[k] as String?) ?? '';
    return LocalizedText(uz: s('uz'), en: s('en'), ru: s('ru'));
  }

  final String uz;
  final String en;
  final String ru;

  Map<String, String> toJson() => {'uz': uz, 'en': en, 'ru': ru};

  /// Berilgan til bo'sh bo'lsa o'zbekcha qaytariladi.
  String forLanguage(String code) {
    final v = switch (code) {
      'en' => en,
      'ru' => ru,
      _ => uz,
    };
    return v.isNotEmpty ? v : uz;
  }
}

enum VariantGroup {
  size('SIZE'),
  cream('CREAM'),
  inscription('INSCRIPTION');

  const VariantGroup(this.api);
  final String api;

  static VariantGroup fromApi(String? v) =>
      VariantGroup.values.firstWhere((g) => g.api == v, orElse: () => VariantGroup.size);
}

@immutable
class AdminVariant {
  const AdminVariant({
    required this.id,
    required this.group,
    required this.name,
    required this.priceDelta,
    required this.sortOrder,
    required this.isActive,
  });

  factory AdminVariant.fromJson(Map<String, dynamic> json) => AdminVariant(
        id: json['id'] as String,
        group: VariantGroup.fromApi(json['group'] as String?),
        name: LocalizedText.fromJson(json['name']),
        priceDelta: (json['priceDelta'] as num).toDouble(),
        sortOrder: (json['sortOrder'] as num).toInt(),
        isActive: json['isActive'] == true,
      );

  final String id;
  final VariantGroup group;
  final LocalizedText name;
  final double priceDelta;
  final int sortOrder;
  final bool isActive;
}

@immutable
class AdminProduct {
  const AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.allergens,
    required this.price,
    required this.stock,
    required this.images,
    required this.isActive,
    required this.categoryId,
    required this.variants,
  });

  factory AdminProduct.fromJson(Map<String, dynamic> json) => AdminProduct(
        id: json['id'] as String,
        name: LocalizedText.fromJson(json['name']),
        description: LocalizedText.fromJson(json['description']),
        ingredients: LocalizedText.fromJson(json['ingredients']),
        allergens: LocalizedText.fromJson(json['allergens']),
        price: (json['price'] as num).toDouble(),
        stock: (json['stock'] as num).toInt(),
        images: ((json['images'] as List?) ?? const []).cast<String>(),
        isActive: json['isActive'] == true,
        categoryId: json['categoryId'] as String?,
        variants: ((json['variants'] as List?) ?? const [])
            .map((e) => AdminVariant.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  final String id;
  final LocalizedText name;
  final LocalizedText description;
  final LocalizedText ingredients;
  final LocalizedText allergens;
  final double price;
  final int stock;
  final List<String> images;
  final bool isActive;
  final String? categoryId;
  final List<AdminVariant> variants;
}

@immutable
class AdminCategory {
  const AdminCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    required this.isActive,
    required this.productsCount,
  });

  factory AdminCategory.fromJson(Map<String, dynamic> json) => AdminCategory(
        id: json['id'] as String,
        name: LocalizedText.fromJson(json['name']),
        sortOrder: (json['sortOrder'] as num).toInt(),
        isActive: json['isActive'] == true,
        productsCount: (json['productsCount'] as num?)?.toInt() ?? 0,
      );

  final String id;
  final LocalizedText name;
  final int sortOrder;
  final bool isActive;
  final int productsCount;
}