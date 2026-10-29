import 'package:flutter/foundation.dart';

import '../../admin/domain/admin_models.dart';

DateTime _date(Object? v) => DateTime.parse(v as String).toLocal();

/// Mahsulot sahifasida hamma ko'radigan sharh.
@immutable
class Review {
  const Review({
    required this.id,
    required this.rating,
    required this.text,
    required this.authorName,
    required this.adminReply,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id'] as String,
        rating: (json['rating'] as num).toInt(),
        text: json['text'] as String?,
        authorName: json['authorName'] as String?,
        adminReply: json['adminReply'] as String?,
        createdAt: _date(json['createdAt']),
      );

  final String id;
  final int rating;
  final String? text;
  final String? authorName;
  final String? adminReply;
  final DateTime createdAt;
}

/// Mijozning o'z sharhi (admin yashirgan bo'lsa ham o'zi ko'radi).
@immutable
class MyReview {
  const MyReview({
    required this.id,
    required this.productId,
    required this.rating,
    required this.text,
    required this.isHidden,
    required this.adminReply,
    required this.createdAt,
  });

  factory MyReview.fromJson(Map<String, dynamic> json) => MyReview(
        id: json['id'] as String,
        productId: json['productId'] as String,
        rating: (json['rating'] as num).toInt(),
        text: json['text'] as String?,
        isHidden: json['isHidden'] == true,
        adminReply: json['adminReply'] as String?,
        createdAt: _date(json['createdAt']),
      );

  final String id;
  final String productId;
  final int rating;
  final String? text;
  final bool isHidden;
  final String? adminReply;
  final DateTime createdAt;
}

/// Mijozning shu mahsulotga munosabati: sharh qoldira oladimi va sharhi bormi.
@immutable
class MyReviewState {
  const MyReviewState({required this.canReview, required this.review});

  factory MyReviewState.fromJson(Map<String, dynamic> json) => MyReviewState(
        canReview: json['canReview'] == true,
        review: json['review'] == null ? null : MyReview.fromJson(json['review'] as Map<String, dynamic>),
      );

  final bool canReview;
  final MyReview? review;
}

@immutable
class AdminReview {
  const AdminReview({
    required this.id,
    required this.rating,
    required this.text,
    required this.isHidden,
    required this.adminReply,
    required this.createdAt,
    required this.productId,
    required this.productName,
    required this.userName,
    required this.userEmail,
  });

  factory AdminReview.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>;
    final user = json['user'] as Map<String, dynamic>;
    return AdminReview(
      id: json['id'] as String,
      rating: (json['rating'] as num).toInt(),
      text: json['text'] as String?,
      isHidden: json['isHidden'] == true,
      adminReply: json['adminReply'] as String?,
      createdAt: _date(json['createdAt']),
      productId: product['id'] as String,
      productName: LocalizedText.fromJson(product['name']),
      userName: user['name'] as String?,
      userEmail: user['email'] as String,
    );
  }

  final String id;
  final int rating;
  final String? text;
  final bool isHidden;
  final String? adminReply;
  final DateTime createdAt;
  final String productId;
  final LocalizedText productName;
  final String? userName;
  final String userEmail;
}

enum ReviewVisibility {
  all('all'),
  visible('visible'),
  hidden('hidden');

  const ReviewVisibility(this.api);
  final String api;
}
