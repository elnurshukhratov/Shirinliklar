import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skeleton.dart';

/// Yuklanayotganda skelet ko'rsatadigan mahsulot rasmi. Berilgan joyni to'liq to'ldiradi.
class ProductImage extends StatelessWidget {
  const ProductImage({super.key, this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget placeholder() => Container(
          color: c.secondary,
          alignment: Alignment.center,
          child: Icon(Icons.cookie_outlined, color: c.textSecondary, size: 40),
        );

    final src = url;
    if (src == null || src.isEmpty) return SizedBox.expand(child: placeholder());

    return LayoutBuilder(
      builder: (context, constraints) {
        final dpr = MediaQuery.devicePixelRatioOf(context);
        final width = constraints.maxWidth.isFinite ? (constraints.maxWidth * dpr).round() : null;
        return SizedBox.expand(
          child: Image.network(
            src,
            fit: BoxFit.cover,
            cacheWidth: width,
            loadingBuilder: (context, child, progress) => progress == null
                ? child
                : const SizedBox.expand(
                    child: Skeleton(height: double.infinity, borderRadius: BorderRadius.zero),
                  ),
            errorBuilder: (_, __, ___) => placeholder(),
          ),
        );
      },
    );
  }
}
