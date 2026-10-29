import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/providers/providers.dart';
import '../../admin/domain/admin_models.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/cart_repository.dart';
import '../domain/cart_models.dart';

enum AddResult { added, limitReached, outOfStock }

@immutable
class CartState {
  const CartState({
    this.items = const [],
    this.removed = const [],
    this.reduced = false,
  });

  final List<CartItem> items;

  /// Tekshiruvda tugagan yoki yashirilgani uchun savatdan chiqarilgan mahsulotlar.
  final List<LocalizedText> removed;

  /// Ombordagi qoldiqqa moslab miqdori kamaytirilgan qatorlar bor.
  final bool reduced;

  int get count => items.fold(0, (sum, i) => sum + i.quantity);
  double get total => items.fold(0.0, (sum, i) => sum + i.lineTotal);
  bool get hasNotice => removed.isNotEmpty || reduced;
}

class CartController extends StateNotifier<CartState> {
  CartController(this._prefs, this._repo) : super(CartState(items: _load(_prefs)));

  static const _key = 'cart_v1';
  static const maxPerLine = 99;

  final SharedPreferences _prefs;
  final CartRepository _repo;

  static List<CartItem> _load(SharedPreferences prefs) {
    final raw = prefs.getString(_key);
    if (raw == null) return const [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
          .where((i) => i.quantity > 0)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  void _persist(List<CartItem> items) {
    _prefs.setString(_key, jsonEncode(items.map((e) => e.toJson()).toList()));
  }

  void _setItems(List<CartItem> items, {List<LocalizedText>? removed, bool? reduced}) {
    state = CartState(
      items: items,
      removed: removed ?? state.removed,
      reduced: reduced ?? state.reduced,
    );
    _persist(items);
  }

  /// Shu qatordan boshqa qatorlarda aynan shu mahsulotdan nechta olinganini hisoblaydi.
  int _takenByOthers(CartItem item) => state.items
      .where((e) => e.productId == item.productId && e.key != item.key)
      .fold(0, (sum, e) => sum + e.quantity);

  /// Qator uchun ruxsat etilgan eng ko'p miqdor (ombor qoldig'i bo'yicha).
  int maxFor(CartItem item) {
    final left = item.stock - _takenByOthers(item);
    return left.clamp(0, maxPerLine).toInt();
  }

  AddResult add(ProductSelection selection) {
    final p = selection.product;
    if (!p.inStock) return AddResult.outOfStock;

    final key = CartItem.keyFor(p.id, selection.variantIds);
    final index = state.items.indexWhere((e) => e.key == key);
    final names = [
      for (final v in p.variants)
        if (selection.variantIds.contains(v.id)) v.name,
    ];

    final fresh = CartItem(
      key: key,
      productId: p.id,
      name: p.name,
      image: p.mainImage,
      unitPrice: selection.unitPrice,
      variantIds: selection.variantIds,
      variantNames: names,
      stock: p.stock,
      quantity: 0,
    );

    final current = index >= 0 ? state.items[index] : fresh;
    final limit = maxFor(current.copyWith(stock: p.stock));
    if (current.quantity + selection.quantity > limit) return AddResult.limitReached;

    final updated = current.copyWith(
      unitPrice: selection.unitPrice,
      stock: p.stock,
      quantity: current.quantity + selection.quantity,
    );
    final items = [...state.items];
    if (index >= 0) {
      items[index] = updated;
    } else {
      items.add(updated);
    }
    _setItems(items);
    return AddResult.added;
  }

  /// Bir nechta qatorni savatga qo'shadi («Qayta buyurtma»). Miqdor ombordagi qoldiqdan oshmaydi.
  /// `added` — qo'shilgan qatorlar soni, `limited` — ombor chegarasi sabab kamaytirilgan yoki o'tkazib yuborilgan.
  ({int added, bool limited}) addMany(List<CartItem> incoming) {
    final items = [...state.items];
    var added = 0;
    var limited = false;

    for (final inc in incoming) {
      final index = items.indexWhere((e) => e.key == inc.key);
      final taken = items
          .where((e) => e.productId == inc.productId && e.key != inc.key)
          .fold<int>(0, (sum, e) => sum + e.quantity);
      final have = index >= 0 ? items[index].quantity : 0;
      final limit = (inc.stock - taken).clamp(0, maxPerLine).toInt();
      final room = limit - have;
      final q = inc.quantity < room ? inc.quantity : room;

      if (q <= 0) {
        limited = true;
        continue;
      }
      if (q < inc.quantity) limited = true;

      final updated = (index >= 0 ? items[index] : inc).copyWith(
        name: inc.name,
        image: inc.image,
        unitPrice: inc.unitPrice,
        variantNames: inc.variantNames,
        stock: inc.stock,
        quantity: have + q,
      );
      if (index >= 0) {
        items[index] = updated;
      } else {
        items.add(updated);
      }
      added++;
    }

    if (added > 0) _setItems(items);
    return (added: added, limited: limited);
  }

  /// Miqdorni o'zgartiradi; ombordan oshib ketmaydi. Qaytgan qiymat — o'rnatilgan miqdor.
  int setQuantity(String key, int quantity) {
    final index = state.items.indexWhere((e) => e.key == key);
    if (index < 0) return 0;
    final item = state.items[index];
    final max = maxFor(item) < 1 ? 1 : maxFor(item);
    final q = quantity.clamp(1, max).toInt();
    final items = [...state.items]..[index] = item.copyWith(quantity: q);
    _setItems(items);
    return q;
  }

  void remove(String key) => _setItems(state.items.where((e) => e.key != key).toList());

  void clear() => _setItems(const []);

  void dismissNotice() {
    state = CartState(items: state.items);
  }

  /// Savatni server bilan solishtiradi. Xato bo'lsa xatoning o'zini qaytaradi, aks holda null.
  Future<Object?> validate() async {
    final sent = state.items;
    if (sent.isEmpty) return null;
    try {
      final checks = await _repo.validate(sent);
      if (!mounted) return null;
      _apply(checks);
      return null;
    } catch (e) {
      return e;
    }
  }

  void _apply(List<CartCheck> checks) {
    final byKey = {for (final c in checks) c.key: c};
    final removed = <LocalizedText>[];
    final kept = <CartItem>[];

    for (final item in state.items) {
      final c = byKey[item.key];
      if (c == null) {
        kept.add(item);
      } else if (c.status != CartCheckStatus.ok) {
        removed.add(item.name);
      } else {
        kept.add(item.copyWith(
          name: c.name,
          image: c.image,
          unitPrice: c.unitPrice,
          variantNames: c.variantNames,
          stock: c.stock,
        ));
      }
    }

    // Bir mahsulotning barcha qatorlari yig'indisi ombordan oshmasligi kerak.
    var reduced = false;
    final left = <String, int>{};
    final result = <CartItem>[];
    for (final item in kept) {
      final remaining = left[item.productId] ?? item.stock;
      final q = [item.quantity, remaining, maxPerLine].reduce((a, b) => a < b ? a : b);
      left[item.productId] = remaining - (q < 0 ? 0 : q);
      if (q <= 0) {
        removed.add(item.name);
        continue;
      }
      if (q < item.quantity) reduced = true;
      result.add(item.copyWith(quantity: q));
    }

    _setItems(result, removed: removed, reduced: reduced);
  }
}

final cartProvider = StateNotifierProvider<CartController, CartState>(
  (ref) => CartController(
    ref.watch(sharedPreferencesProvider),
    CartRepository(ref.watch(apiClientProvider)),
  ),
);
