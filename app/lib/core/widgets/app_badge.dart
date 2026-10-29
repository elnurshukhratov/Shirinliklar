import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';

enum AppBadgeTone { neutral, primary, success, error }

class AppBadge extends StatelessWidget {
  const AppBadge({super.key, required this.label, this.tone = AppBadgeTone.neutral});

  final String label;
  final AppBadgeTone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final Color bg;
    final Color fg;
    switch (tone) {
      case AppBadgeTone.neutral:
        bg = c.secondary;
        fg = c.textPrimary;
      case AppBadgeTone.primary:
        bg = c.cta;
        fg = c.onCta;
      case AppBadgeTone.success:
        bg = c.success;
        fg = dark ? c.background : Colors.white;
      case AppBadgeTone.error:
        bg = c.error;
        fg = dark ? c.background : Colors.white;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: AppRadius.borderPill),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
      ),
    );
  }
}
