import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_tokens.dart';
import 'glass/glass_container.dart';

enum AppButtonVariant { primary, secondary, text }

/// Asosiy harakat tugmasi. Primary — yarim shaffof olcha shisha (rangli yorug'lik soyasi bilan),
/// secondary — oddiy shisha, text — yuzasiz. Bosilganda tugma yengil kichrayadi va
/// qaytishda sakraydi; yengil tebranish (haptic) beriladi.
class AppButton extends StatefulWidget {
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
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final enabled = widget.onPressed != null && !widget.isLoading;
    final variant = widget.variant;

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
        if (widget.isLoading)
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        else if (widget.icon != null)
          Icon(widget.icon, size: 20, color: fg),
        if (widget.isLoading || widget.icon != null) const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
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
          strong: _pressed,
          shadow: enabled,
          borderRadius: radius,
          child: inner,
        );
      case AppButtonVariant.secondary:
        surface = GlassContainer(
          level: GlassLevel.floating,
          blur: false,
          shadow: false,
          strong: _pressed,
          borderRadius: radius,
          child: inner,
        );
      case AppButtonVariant.text:
        surface = inner;
    }

    final scale = _pressed && enabled && !AppMotion.reduced(context) ? 0.97 : 1.0;

    final button = AnimatedOpacity(
      duration: AppMotion.of(context, AppMotion.fast),
      opacity: widget.onPressed == null ? 0.5 : 1,
      child: AnimatedScale(
        scale: scale,
        duration: AppMotion.of(context, const Duration(milliseconds: 180)),
        curve: _pressed ? AppMotion.curve : AppMotion.springCurve,
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
                  onTap: enabled
                      ? () {
                          HapticFeedback.lightImpact();
                          widget.onPressed!();
                        }
                      : null,
                  onHighlightChanged: enabled ? (v) => setState(() => _pressed = v) : null,
                  splashColor: Colors.white.withValues(alpha: 0.18),
                  highlightColor: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      excludeSemantics: true,
      child: widget.expanded ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}
