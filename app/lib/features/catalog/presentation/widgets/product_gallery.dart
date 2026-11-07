import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_motion.dart';
import '../../../../core/widgets/expand/expand_scope.dart';
import '../../../../core/widgets/skeleton.dart';
import 'product_image.dart';

/// Mahsulot galereyasi: PageView, gorizontal parallax va chiziqcha indikatorlar.
/// Kartadan kengayishda birinchi rasm umumiy element sifatida kelgani uchun, galereya
/// kengayish tugagach (progress ~0.99) almashib ko'rinadi.
class ProductGallery extends StatefulWidget {
  const ProductGallery({
    super.key,
    required this.images,
    required this.height,
    this.placeholder,
    this.loading = false,
    this.soldOut = false,
    this.indicatorBottom = 16,
  });

  final List<String> images;
  final double height;

  /// Birinchi sahifa uchun darhol ko'rinadigan rasm (kartadan kelgan provider).
  final ImageProvider? placeholder;

  /// Ma'lumot hali kelmagan: rasm o'rnida skelet.
  final bool loading;
  final bool soldOut;
  final double indicatorBottom;

  @override
  State<ProductGallery> createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  final PageController _pc = PageController();

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasOrigin = ExpandScope.maybeOf(context)?.hasOrigin ?? false;
    final count = widget.images.isEmpty ? 1 : widget.images.length;

    return ExpandReveal(
      start: hasOrigin ? 0.985 : 0.1,
      end: hasOrigin ? 0.99 : 0.6,
      offset: 0,
      child: SizedBox(
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pc,
              itemCount: count,
              itemBuilder: (context, i) => _ParallaxPage(
                controller: _pc,
                index: i,
                child: _GalleryImage(
                  url: widget.images.isEmpty ? null : widget.images[i],
                  placeholder: i == 0 ? widget.placeholder : null,
                  loading: widget.loading,
                ),
              ),
            ),
            if (widget.soldOut)
              IgnorePointer(child: ColoredBox(color: c.background.withValues(alpha: 0.35))),
            if (count > 1)
              Positioned(
                left: 0,
                right: 0,
                bottom: widget.indicatorBottom,
                child: IgnorePointer(child: _Dashes(controller: _pc, count: count)),
              ),
          ],
        ),
      ),
    );
  }
}

double _pageOf(PageController controller) {
  if (controller.hasClients && controller.position.haveDimensions) {
    return controller.page ?? 0.0;
  }
  return 0.0;
}

/// Rasm sahifadan sekinroq suriladi (parallax). Tinch holatda masshtab 1: umumiy element bilan bir xil.
class _ParallaxPage extends StatelessWidget {
  const _ParallaxPage({required this.controller, required this.index, required this.child});

  final PageController controller;
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return AnimatedBuilder(
      animation: controller,
      child: child,
      builder: (context, child) {
        final delta = (_pageOf(controller) - index).clamp(-1.0, 1.0).toDouble();
        return ClipRect(
          child: Transform.translate(
            offset: Offset(delta * width * 0.12, 0),
            child: Transform.scale(scale: 1 + 0.3 * delta.abs(), child: child),
          ),
        );
      },
    );
  }
}

class _GalleryImage extends StatelessWidget {
  const _GalleryImage({this.url, this.placeholder, this.loading = false});

  final String? url;
  final ImageProvider? placeholder;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final src = url;
    final hold = placeholder;

    if (src == null || src.isEmpty) {
      if (hold != null) {
        return Image(
          image: hold,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          gaplessPlayback: true,
        );
      }
      if (loading) {
        return const SizedBox.expand(
          child: Skeleton(height: double.infinity, borderRadius: BorderRadius.zero),
        );
      }
      return const ProductImage();
    }

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final width = (MediaQuery.sizeOf(context).width * dpr).round();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (hold != null)
          Image(image: hold, fit: BoxFit.cover, gaplessPlayback: true)
        else
          const Skeleton(height: double.infinity, borderRadius: BorderRadius.zero),
        Image.network(
          src,
          fit: BoxFit.cover,
          cacheWidth: width,
          gaplessPlayback: true,
          frameBuilder: (context, child, frame, sync) {
            if (sync) return child;
            return AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: AppMotion.of(context, AppMotion.slow),
              child: child,
            );
          },
          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

/// Chiziqcha indikatorlar: faol sahifa uzayadi, o'tish paytida silliq o'zgaradi.
class _Dashes extends StatelessWidget {
  const _Dashes({required this.controller, required this.count});

  final PageController controller;
  final int count;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final page = _pageOf(controller);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < count; i++)
              Builder(builder: (context) {
                final t = (1 - (page - i).abs()).clamp(0.0, 1.0).toDouble();
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  width: 8 + 16 * t,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5 + 0.5 * t),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4),
                    ],
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}