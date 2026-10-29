import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../../cart/application/cart_controller.dart';
import '../data/promo_repository.dart';
import '../domain/promo_models.dart';

class PromoController extends StateNotifier<AppliedPromo?> {
  PromoController(this._repo) : super(null);

  final PromoRepository _repo;

  /// Kodni tekshirib qo'llaydi. Xato bo'lsa xatoning o'zi tashlanadi.
  Future<void> apply(String code, double subtotal) async {
    final promo = await _repo.validate(code.trim(), subtotal);
    if (!mounted) return;
    state = promo;
  }

  void clear() => state = null;
}

final appliedPromoProvider = StateNotifierProvider<PromoController, AppliedPromo?>((ref) {
  final controller = PromoController(PromoRepository(ref.watch(apiClientProvider)));
  // Savat bo'shab qolsa (buyurtma berildi yoki hammasi o'chirildi), promokod ham bekor bo'ladi.
  ref.listen<CartState>(cartProvider, (_, next) {
    if (next.items.isEmpty) controller.clear();
  });
  return controller;
});
