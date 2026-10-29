import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/glass/glass_icon_button.dart';
import '../../application/cart_controller.dart';

/// Savat belgisi: son oshganda belgi bir marta sekin kattalashib qaytadi, son silliq almashadi.
class CartIconButton extends ConsumerStatefulWidget {
  const CartIconButton({super.key, this.overMedia = false});

  /// Fotosurat ustida turganda (masalan, mahsulot sahifasi) shisha to'liqroq qoplaydi.
  final bool overMedia;

  @override
  ConsumerState<CartIconButton> createState() => _CartIconButtonState();
}

class _CartIconButtonState extends ConsumerState<CartIconButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: AppMotion.slow);

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.25).chain(CurveTween(curve: AppMotion.curve)), weight: 50),
    TweenSequenceItem(tween: Tween(begin: 1.25, end: 1.0).chain(CurveTween(curve: Curves.easeInOut)), weight: 50),
  ]).animate(_controller);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _bump() {
    if (AppMotion.reduced(context)) return;
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(cartProvider.select((s) => s.count), (previous, next) {
      if (next > (previous ?? 0)) _bump();
    });

    final count = ref.watch(cartProvider.select((s) => s.count));
    final c = context.colors;
    final label = count > 99 ? '99+' : '$count';

    return GlassIconButton(
      tooltip: context.l10n.cartTitle,
      overMedia: widget.overMedia,
      onPressed: () => context.push(AppRoutes.cart),
      badge: AnimatedOpacity(
        duration: AppMotion.of(context, AppMotion.fast),
        opacity: count > 0 ? 1 : 0,
        child: Container(
          constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          alignment: Alignment.center,
          decoration: BoxDecoration(color: c.cta, borderRadius: BorderRadius.circular(9)),
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.fast),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: Text(
              label,
              key: ValueKey(label),
              style: TextStyle(color: c.onCta, fontSize: 11, fontWeight: FontWeight.w800, height: 1.1),
            ),
          ),
        ),
      ),
      child: ScaleTransition(scale: _scale, child: const Icon(Icons.shopping_bag_outlined)),
    );
  }
}
