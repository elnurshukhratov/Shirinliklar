import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'expand_backdrop.dart';

/// Kengayish boshlanadigan joy: manba kartaning ekrandagi to'rtburchagi va burchak radiusi.
/// go_router `extra` orqali uzatiladi (qarang: [ExpandNavigation.pushExpanded]).
@immutable
class ExpandOrigin {
  const ExpandOrigin({
    required this.rect,
    this.radius = 28,
    this.sourceKey,
    this.image,
    this.surfaceColor,
    this.insideBackdrop = false,
  });

  /// Karta ochilish paytidagi ekran koordinatalaridagi joyi.
  final Rect rect;

  /// Kartaning burchak radiusi.
  final double radius;

  /// Yig'ilishda kartaning joyini qayta o'lchash uchun (ro'yxat skroll bo'lgan bo'lishi mumkin).
  final GlobalKey? sourceKey;

  /// Umumiy element (rasm): karta ishlatgan AYNAN shu provider, shuning uchun birinchi kadrdayoq tayyor.
  final ImageProvider? image;

  /// Kengayish boshidagi sirt rangi (karta rasmi bo'lmasa yoki pill uchun).
  final Color? surfaceColor;

  /// Manba orqa sahifa o'ramida ([ExpandBackdrop]) turibdimi (o'lchashda masshtab tuzatiladi).
  final bool insideBackdrop;

  /// [key] ning ekrandagi to'rtburchagi; vidjet qurilmagan bo'lsa null.
  static Rect? rectOf(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }

  /// Manba kartaning hozirgi joyi (orqa sahifa kichraygan bo'lsa, tuzatilgan). Ekranda yo'q bo'lsa null.
  Rect? measureNow(Size screen) {
    final key = sourceKey;
    if (key == null) return null;
    final raw = rectOf(key);
    if (raw == null) return null;
    if (!insideBackdrop) return raw;
    final s = expandBackdropScale(expandBackdropProgress.value);
    if (s == 1) return raw;
    final c = screen.center(Offset.zero);
    return Rect.fromPoints(c + (raw.topLeft - c) / s, c + (raw.bottomRight - c) / s);
  }
}

extension ExpandNavigation on BuildContext {
  /// [location] sahifasini [sourceKey] kartasidan kengayib ochadi.
  /// Sahifa `expandPage` bilan qurilgan bo'lishi kerak; aks holda oddiy o'tish ishlaydi.
  Future<T?> pushExpanded<T extends Object?>(
    String location, {
    required GlobalKey sourceKey,
    double radius = 28,
    ImageProvider? image,
    Color? surfaceColor,
  }) {
    final rect = ExpandOrigin.rectOf(sourceKey);
    final inBackdrop = findAncestorWidgetOfExactType<ExpandBackdrop>() != null;
    return GoRouter.of(this).push<T>(
      location,
      extra: rect == null
          ? null
          : ExpandOrigin(
              rect: rect,
              radius: radius,
              sourceKey: sourceKey,
              image: image,
              surfaceColor: surfaceColor,
              insideBackdrop: inBackdrop,
            ),
    );
  }
}