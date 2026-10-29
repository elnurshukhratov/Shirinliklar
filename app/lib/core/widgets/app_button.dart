import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';
import 'glass/glass_container.dart';

enum AppButtonVariant { primary, secondary, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = onPressed != null && !isLoading;

    final Color fg;
    switch (variant) {
      case AppButtonVariant.primary:
        fg = c.onCta;
      case AppButtonVariant.secondary:
        fg = c.textPrimary;
      case AppButtonVariant.text:
        fg = c.primary;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (icon != null)
          Icon(icon, size: 20, color: fg),
        if (isLoading || icon != null) const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(color: fg, fontSize: 15),
          ),
        ),
      ],
    );

    final radius = AppRadius.borderPill;
    final inner = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 54),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
        child: Center(widthFactor: 1, child: content),
      ),
    );

    Widget surface;
    switch (variant) {
      case AppButtonVariant.primary:
        // Faqat asosiy harakat rangli: yarim shaffof olcha tint.
        surface = GlassContainer(
          level: GlassLevel.floating,
          tint: c.cta,
          blur: false,
          borderRadius: radius,
          child: inner,
        );
      case AppButtonVariant.secondary:
        surface = GlassContainer(
          level: GlassLevel.floating,
          blur: false,
          shadow: false,
          borderRadius: radius,
          child: inner,
        );
      case AppButtonVariant.text:
        surface = inner;
    }

    final button = AnimatedOpacity(
      duration: AppMotion.of(context, AppMotion.fast),
      opacity: onPressed == null ? 0.5 : 1,
      child: Stack(
        // Shisha sirt ham tugmaning to'liq kengligini egallashi uchun (bosiladigan joy bilan bir xil).
        fit: StackFit.passthrough,
        children: [
          surface,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: enabled ? onPressed : null,
                splashColor: Colors.white.withValues(alpha: 0.18),
                highlightColor: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: label,
      excludeSemantics: true,
      child: expanded ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
