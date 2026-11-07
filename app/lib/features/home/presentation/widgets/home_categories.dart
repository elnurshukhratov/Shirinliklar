import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../../catalog/domain/catalog_models.dart';

/// Kategoriyalar: gorizontal shisha chiplar. Tanlash mavjud filtr mantiqiga ([onSelect]) ulanadi.
class HomeCategories extends StatelessWidget {
  const HomeCategories({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CatalogCategory> categories;
  final String? selectedId;
  final ValueChanged<String?> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: categories.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) {
          if (i == 0) {
            return Center(
              child: _GlassChip(
                label: l10n.catalogAllCategories,
                selected: selectedId == null,
                onTap: () => onSelect(null),
              ),
            );
          }
          final category = categories[i - 1];
          return Center(
            child: _GlassChip(
              label: category.name.forLanguage(lang),
              selected: selectedId == category.id,
              onTap: () => onSelect(category.id),
            ),
          );
        },
      ),
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        haptic: true,
        scale: 0.95,
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 44),
          child: GlassContainer(
            level: GlassLevel.chip,
            blur: false,
            shadow: false,
            tint: selected ? c.cta : null,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 11),
            child: Center(
              widthFactor: 1,
              child: Text(
                label,
                maxLines: 1,
                style: text.labelLarge?.copyWith(color: selected ? c.onCta : c.textPrimary),
              ),
            ),
          ),
        ),
      ),
    );
  }
}