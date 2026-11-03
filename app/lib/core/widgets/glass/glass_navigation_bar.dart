import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_tokens.dart';
import 'glass_container.dart';

class GlassNavItem {
  const GlassNavItem({required this.icon, required this.selectedIcon, required this.label});

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Suzuvchi shisha navigatsiya paneli (kapsula). Tanlangan element ortida yarim shaffof olcha
/// "suyuqlik" indikatori tanlovga qarab sirpanib o'tadi; belgi esa yengil sakraydi.
/// Ekran burchaklariga concentric (katta radius). Har bir element kamida 48 dp balandlikda.
class GlassNavigationBar extends StatelessWidget {
  const GlassNavigationBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.margin = const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
  });

  final List<GlassNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 1.3);
    final n = items.length;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final align = n <= 1 ? 0.0 : -1 + 2 * selectedIndex / (n - 1);

    return SafeArea(
      top: false,
      child: Padding(
        padding: margin,
        child: GlassContainer(
          level: GlassLevel.bar,
          borderRadius: BorderRadius.circular(AppRadius.bar + 6),
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 62 * scale,
            child: Stack(
              children: [
                // Sirpanuvchi indikator.
                Positioned.fill(
                  child: AnimatedAlign(
                    duration: AppMotion.of(context, const Duration(milliseconds: 360)),
                    curve: AppMotion.spring,
                    alignment: Alignment(align, 0),
                    child: FractionallySizedBox(
                      widthFactor: 1 / n,
                      heightFactor: 1,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppRadius.bar),
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              c.cta.withValues(alpha: dark ? 0.34 : 0.20),
                              c.cta.withValues(alpha: dark ? 0.20 : 0.10),
                            ],
                          ),
                          border: Border.all(color: c.cta.withValues(alpha: dark ? 0.45 : 0.28)),
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < n; i++)
                      Expanded(
                        child: Semantics(
                          button: true,
                          selected: i == selectedIndex,
                          label: items[i].label,
                          excludeSemantics: true,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (i != selectedIndex) HapticFeedback.selectionClick();
                              onSelected(i);
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                AnimatedScale(
                                  scale: i == selectedIndex ? 1.1 : 1.0,
                                  duration: AppMotion.of(context, const Duration(milliseconds: 280)),
                                  curve: AppMotion.spring,
                                  child: Icon(
                                    i == selectedIndex ? items[i].selectedIcon : items[i].icon,
                                    size: 24,
                                    color: i == selectedIndex ? c.primary : c.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  items[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: text.labelSmall?.copyWith(
                                    color: i == selectedIndex ? c.primary : c.textSecondary,
                                    fontWeight: i == selectedIndex ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
