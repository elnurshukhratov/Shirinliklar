import '../../../core/network/api_client.dart';
import '../domain/review_models.dart';

class ReviewRepository {
  ReviewRepository(this._api);

  final ApiClient _api;

  Future<List<Review>> productReviews(String productId, {required int page, int limit = 10}) async {
    final data = await _api.get<List<dynamic>>(
      '/reviews/product/$productId',
      query: {'page': page, 'limit': limit},
    );
    return data.map((e) => Review.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MyReviewState> mine(String productId) async {
    final json = await _api.get<Map<String, dynamic>>('/reviews/product/$productId/mine');
    return MyReviewState.fromJson(json);
  }

  Future<MyReview> create({required String productId, required int rating, String? text}) async {
    final json = await _api.post<Map<String, dynamic>>('/reviews', body: {
      'productId': productId,
      'rating': rating,
      'text': (text == null || text.trim().isEmpty) ? null : text.trim(),
    });
    return MyReview.fromJson(json);
  }

  Future<MyReview> update(String id, {required int rating, String? text}) async {
    final json = await _api.patch<Map<String, dynamic>>('/reviews/$id', body: {
      'rating': rating,
      'text': (text == null || text.trim().isEmpty) ? null : text.trim(),
    });
    return MyReview.fromJson(json);
  }

  Future<void> delete(String id) async {
    await _api.delete<Map<String, dynamic>>('/reviews/$id');
  }
}

class AdminReviewsRepository {
  AdminReviewsRepository(this._api);

  final ApiClient _api;

  Future<List<AdminReview>> list({
    required ReviewVisibility visibility,
    required int page,
    int limit = 20,
  }) async {
    final data = await _api.get<List<dynamic>>('/admin/reviews', query: {
      'visibility': visibility.api,
      'page': page,
      'limit': limit,
    });
    return data.map((e) => AdminReview.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AdminReview> setHidden(String id, {required bool hidden}) async {
    final json = await _api.post<Map<String, dynamic>>('/admin/reviews/$id/${hidden ? 'hide' : 'show'}');
    return AdminReview.fromJson(json);
  }

  Future<AdminReview> reply(String id, String reply) async {
    final json = await _api.put<Map<String, dynamic>>('/admin/reviews/$id/reply', body: {'reply': reply.trim()});
    return AdminReview.fromJson(json);
  }

  Future<AdminReview> deleteReply(String id) async {
    final json = await _api.delete<Map<String, dynamic>>('/admin/reviews/$id/reply');
    return AdminReview.fromJson(json);
  }
}
