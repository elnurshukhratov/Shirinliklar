import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/widgets/expand/expand_origin.dart';
import '../../admin/domain/admin_models.dart';
import '../../catalog/domain/catalog_models.dart';
import '../application/cart_controller.dart';
import '../application/cart_icon_key.dart';

/// Mahsulot sahifasidagi bilan bir xil standart variantlar (o'lcham va krem — birinchisi, yozuv — yo'q).
ProductSelection _defaultSelection(CatalogProduct p) {
  final ids = <String>[];
  var price = p.price;
  for (final g in VariantGroup.values) {
    if (g == VariantGroup.inscription) continue;
    final options = p.variantsOf(g);
    if (options.isEmpty) continue;
    ids.add(options.first.id);
    price += options.first.priceDelta;
  }
  return ProductSelection(product: p, variantIds: ids, unitPrice: price < 0 ? 0 : price);
}

/// Tez qo'shish: mahsulot rasmi nusxasi dock'dagi savat ikonkasiga yoy bo'ylab uchadi (~500 ms),
/// qo'nganda mavjud `cartProvider.add` chaqiriladi (dock belgisi sakraydi) va sprinkles chiqadi.
/// "Harakatni kamaytirish"da: darhol qo'shiladi va qisqa xabar chiqadi.
Future<void> quickAddToCart(
  BuildContext context,
  WidgetRef ref,
  CatalogProduct product, {
  required GlobalKey sourceKey,
}) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.of(context);
  final colors = context.colors;
  final reduced = AppMotion.reduced(context);
  final cart = ref.read(cartProvider.notifier);
  final selection = _defaultSelection(product);

  void show(String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void report(AddResult result) {
    switch (result) {
      case AddResult.added:
        break;
      case AddResult.limitReached:
        show(l10n.cartStockLimit(product.stock));
      case AddResult.outOfStock:
        show(l10n.catalogOutOfStock);
    }
  }

  // Uchishdan oldin tekshiruv: bo'lmaydigan qo'shishga animatsiya ko'rsatmaymiz.
  if (!product.inStock) {
    report(AddResult.outOfStock);
    return;
  }
  final inCart = ref
      .read(cartProvider)
      .items
      .where((e) => e.productId == product.id)
      .fold<int>(0, (sum, e) => sum + e.quantity);
  if (inCart + 1 > product.stock) {
    report(AddResult.limitReached);
    return;
  }

  final from = ExpandOrigin.rectOf(sourceKey);
  final iconRect = ExpandOrigin.rectOf(ref.read(cartIconKeyProvider));
  final overlay = Overlay.maybeOf(context, rootOverlay: true);

  if (reduced || from == null || iconRect == null || overlay == null) {
    final result = cart.add(selection);
    report(result);
    if (result == AddResult.added && reduced) show(l10n.cartAdded);
    return;
  }

  ImageProvider? image;
  final url = product.mainImage;
  if (url != null && url.isNotEmpty) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    image = ResizeImage(NetworkImage(url), width: (from.width * dpr).round());
  }

  final screen = MediaQuery.sizeOf(context);
  final end = Offset(
    iconRect.center.dx.clamp(24.0, screen.width - 24).toDouble(),
    iconRect.center.dy.clamp(24.0, screen.height - 36).toDouble(),
  );

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _FlyToCart(
      image: image,
      placeholder: colors.secondary,
      from: from.center,
      to: end,
      sprinkleColors: [colors.cta, colors.mint, colors.accent, colors.ambientB, colors.primary],
      onLand: () {
        HapticFeedback.lightImpact();
        report(cart.add(selection));
      },
      onDone: () {
        if (entry.mounted) entry.remove();
      },
    ),
  );
  overlay.insert(entry);
}

class _FlyToCart extends StatefulWidget {
  const _FlyToCart({
    required this.image,
    required this.placeholder,
    required this.from,
    required this.to,
    required this.sprinkleColors,
    required this.onLand,
    required this.onDone,
  });

  final ImageProvider? image;
  final Color placeholder;
  final Offset from;
  final Offset to;
  final List<Color> sprinkleColors;
  final VoidCallback onLand;
  final VoidCallback onDone;

  @override
  State<_FlyToCart> createState() => _FlyToCartState();
}

class _FlyToCartState extends State<_FlyToCart> with TickerProviderStateMixin {
  late final AnimationController _fly =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
  late final AnimationController _burst =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

  @override
  void initState() {
    super.initState();
    _burst.addStatusListener((status) {
      if (status == AnimationStatus.completed) widget.onDone();
    });
    _fly.forward().whenComplete(_land);
  }

  void _land() {
    if (!mounted) return;
    widget.onLand();
    _burst.forward();
  }

  @override
  void dispose() {
    _fly.dispose();
    _burst.dispose();
    super.dispose();
  }

  Offset _bezier(Offset a, Offset b, Offset c, double t) {
    final u = 1 - t;
    return a * (u * u) + b * (2 * u * t) + c * (t * t);
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: Listenable.merge([_fly, _burst]),
        builder: (context, _) {
          final children = <Widget>[];

          if (_fly.value < 1) {
            final t = Curves.easeInOutCubic.transform(_fly.value);
            final a = widget.from;
            final c = widget.to;
            final control = Offset((a.dx + c.dx) / 2, math.min(a.dy, c.dy) - 140);
            final pos = _bezier(a, control, c, t);
            final size = lerpDouble(84, 26, t)!;
            final opacity = t < 0.85 ? 1.0 : (1 - (t - 0.85) / 0.15).clamp(0.0, 1.0).toDouble();
            children.add(
              Positioned(
                left: pos.dx - size / 2,
                top: pos.dy - size / 2,
                width: size,
                height: size,
                child: Opacity(
                  opacity: opacity,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size * 0.3),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.9), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(size * 0.3 - 2),
                      child: widget.image == null
                          ? ColoredBox(color: widget.placeholder)
                          : Image(image: widget.image!, fit: BoxFit.cover, gaplessPlayback: true),
                    ),
                  ),
                ),
              ),
            );
          }

          if (_burst.value > 0) {
            children.add(
              Positioned.fill(
                child: CustomPaint(
                  painter: _SprinklePainter(
                    center: widget.to,
                    t: _burst.value,
                    colors: widget.sprinkleColors,
                  ),
                ),
              ),
            );
          }

          return Stack(children: children);
        },
      ),
    );
  }
}

/// Savat ikonkasi atrofiga sochiladigan 12 ta rangli kapsula.
class _SprinklePainter extends CustomPainter {
  _SprinklePainter({required this.center, required this.t, required this.colors});

  final Offset center;
  final double t;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final e = Curves.easeOutCubic.transform(t);
    final fade = t < 0.6 ? 1.0 : (1 - (t - 0.6) / 0.4).clamp(0.0, 1.0).toDouble();
    const count = 12;

    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi + (i.isEven ? 0.12 : -0.12);
      final dist = lerpDouble(6, 34 + (i % 3) * 8, e)!;
      final p = center + Offset(math.cos(angle), math.sin(angle)) * dist;

      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(angle + math.pi / 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: 3.6, height: 9),
          const Radius.circular(2),
        ),
        Paint()..color = colors[i % colors.length].withValues(alpha: fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_SprinklePainter old) => old.t != t || old.center != center;
}