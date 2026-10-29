import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// [onChanged] berilsa yulduzchalar bosiladi (1–5), aks holda faqat ko'rsatadi.
class RatingStars extends StatelessWidget {
  const RatingStars({
    super.key,
    required this.value,
    this.size = 18,
    this.onChanged,
  });

  final double value;
  final double size;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final color = context.colors.primary;

    final stars = List.generate(5, (i) {
      final IconData icon;
      if (value >= i + 1) {
        icon = Icons.star_rounded;
      } else if (value >= i + 0.5) {
        icon = Icons.star_half_rounded;
      } else {
        icon = Icons.star_outline_rounded;
      }
      final star = Icon(icon, size: size, color: color);
      if (onChanged == null) return star;
      return InkResponse(
        onTap: () => onChanged!(i + 1),
        radius: size,
        child: Padding(padding: const EdgeInsets.all(4), child: star),
      );
    });

    return Semantics(
      label: '${value.toStringAsFixed(1)} / 5',
      excludeSemantics: true,
      child: Row(mainAxisSize: MainAxisSize.min, children: stars),
    );
  }
}
