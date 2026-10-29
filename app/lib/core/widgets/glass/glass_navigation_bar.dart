import 'package:flutter/material.dart';

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

/// Suzuvchi shisha navigatsiya paneli. Tanlangan element ichida yarim shaffof
/// olcha "tabletka" suriladi. Ekran burchaklariga concentric (katta radius).
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

    return SafeArea(
      top: false,
      child: Padding(
        padding: margin,
        child: GlassContainer(
          level: GlassLevel.bar,
          borderRadius: BorderRadius.circular(AppRadius.bar + 4),
          padding: const EdgeInsets.all(6),
          child: SizedBox(
            height: 62 * scale,
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: Semantics(
                      button: true,
                      selected: i == selectedIndex,
                      label: items[i].label,
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => onSelected(i),
                        child: AnimatedContainer(
                          duration: AppMotion.of(context),
                          curve: AppMotion.curve,
                          decoration: BoxDecoration(
                            color: i == selectedIndex ? c.cta.withValues(alpha: 0.22) : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppRadius.bar - 2),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                i == selectedIndex ? items[i].selectedIcon : items[i].icon,
                                size: 24,
                                color: i == selectedIndex ? c.primary : c.textSecondary,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                items[i].label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelSmall?.copyWith(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: i == selectedIndex ? c.primary : c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
