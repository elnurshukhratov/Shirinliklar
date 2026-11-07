import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';

/// Yuklanish vaqtidagi yengil kulrang blok. Harakat kamaytirilganda qimirlamaydi.
class Skeleton extends StatefulWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 14,
    this.borderRadius,
  });

  final double? width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return ExcludeSemantics(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          // Yorug'lik chizig'i chapdan o'ngga o'tadi (harakat kamaytirilganda to'xtab turadi).
          final t = _controller.value * 3 - 1.5;
          return Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment(t - 0.9, -0.3),
                end: Alignment(t + 0.9, 0.3),
                colors: [c.skeletonBase, c.skeletonHighlight, c.skeletonBase],
                stops: const [0.25, 0.5, 0.75],
              ),
              borderRadius: widget.borderRadius ?? AppRadius.borderSmall,
            ),
          );
        },
      ),
    );
  }
}

/// Mahsulot kartasi yuklanayotgandagi ko'rinish: to'liq rasm (radius 28) va nom ostida ikki qator.
/// [aspectRatio] masonry uchun navbatma-navbat 0.8 (4:5) va 1 (1:1).
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key, this.aspectRatio = 1});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: aspectRatio,
          child: const SizedBox.expand(
            child: Skeleton(
              height: double.infinity,
              borderRadius: BorderRadius.all(Radius.circular(AppRadius.panel)),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Skeleton(height: 14),
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Skeleton(width: 72, height: 14),
        ),
      ],
    );
  }
}