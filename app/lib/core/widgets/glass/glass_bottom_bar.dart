import 'package:flutter/material.dart';

import '../../theme/app_tokens.dart';
import 'glass_container.dart';

/// Ekran pastidagi suzuvchi shisha harakat paneli (narx + asosiy tugma). Scaffold'ning
/// `bottomNavigationBar` o'rnida yoki Column oxirida ishlatiladi; SafeArea hisobga olingan.
class GlassBottomBar extends StatelessWidget {
  const GlassBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
        child: GlassContainer(
          level: GlassLevel.bar,
          borderRadius: AppRadius.borderBar,
          padding: const EdgeInsets.all(AppSpacing.md),
          child: child,
        ),
      ),
    );
  }
}
