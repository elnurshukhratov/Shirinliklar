import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class AdminImage extends StatelessWidget {
  const AdminImage({super.key, this.url, required this.size});

  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    Widget placeholder() => Container(
          width: size,
          height: size,
          color: c.secondary,
          child: Icon(Icons.cookie_outlined, color: c.textSecondary, size: size * 0.4),
        );

    if (url == null || url!.isEmpty) return placeholder();

    return Image.network(
      url!,
      width: size,
      height: size,
      fit: BoxFit.cover,
      cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
      errorBuilder: (_, __, ___) => placeholder(),
    );
  }
}