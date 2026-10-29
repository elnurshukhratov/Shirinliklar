import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import 'glass_container.dart';

/// Yumaloq shisha ikonka tugmasi (AppBar, rasm ustida). Bosilganda yengil kichrayadi
/// va shisha yorishadi; "harakatni kamaytirish" yoqilgan bo'lsa faqat rang o'zgaradi.
class GlassIconButton extends StatefulWidget {
  const GlassIconButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.tooltip,
    this.size = 44,
    this.blur = false,
    this.overMedia = false,
    this.badge,
    this.margin = const EdgeInsets.symmetric(horizontal: 4),
  });

  /// Odatda `Icon`, lekin belgi (badge) bilan Stack ham bo'lishi mumkin.
  final Widget child;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  /// Kichik tugmalar uchun odatda kerak emas (ular tagida kontent siljimaydi).
  final bool blur;

  /// Fotosurat ustida turgan tugma: shisha to'liqroq qoplaydi.
  final bool overMedia;

  /// Burchakdagi belgi (masalan, savat soni). Shisha kesilishidan tashqarida chiziladi.
  final Widget? badge;
  final EdgeInsetsGeometry margin;

  @override
  State<GlassIconButton> createState() => _GlassIconButtonState();
}

class _GlassIconButtonState extends State<GlassIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final reduced = AppMotion.reduced(context);
    final scale = _pressed && !reduced ? 0.92 : 1.0;

    return Padding(
      padding: widget.margin,
      child: Semantics(
        button: true,
        enabled: widget.onPressed != null,
        label: widget.tooltip,
        excludeSemantics: true,
        child: Tooltip(
          message: widget.tooltip,
          child: AnimatedScale(
            scale: scale,
            duration: AppMotion.of(context, AppMotion.fast),
            curve: AppMotion.curve,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: widget.onPressed == null ? null : (_) => setState(() => _pressed = true),
                  onTapCancel: () => setState(() => _pressed = false),
                  onTapUp: (_) => setState(() => _pressed = false),
                  onTap: widget.onPressed,
                  child: GlassContainer(
                    level: GlassLevel.floating,
                    blur: widget.blur,
                    shadow: false,
                    strong: _pressed,
                    overMedia: widget.overMedia,
                    borderRadius: BorderRadius.circular(widget.size / 2),
                    child: SizedBox(
                      width: widget.size,
                      height: widget.size,
                      child: Center(
                        child: IconTheme(
                          data: IconThemeData(color: c.textPrimary, size: 22),
                          child: widget.child,
                        ),
                      ),
                    ),
                  ),
                ),
                if (widget.badge != null) Positioned(right: -2, top: -2, child: widget.badge!),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
