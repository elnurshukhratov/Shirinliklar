import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/glass_settings.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/app_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final reducedGlass = ref.watch(glassReducedProvider);

    final languages = <(Locale, String)>[
      (AppLocales.uz, l10n.languageUz),
      (AppLocales.en, l10n.languageEn),
      (AppLocales.ru, l10n.languageRu),
    ];
    final themes = <(ThemeMode, String)>[
      (ThemeMode.system, l10n.themeSystem),
      (ThemeMode.light, l10n.themeLight),
      (ThemeMode.dark, l10n.themeDark),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          _Section(
            title: l10n.settingsLanguage,
            children: [
              for (final (value, label) in languages)
                _OptionTile(
                  label: label,
                  selected: value == locale,
                  onTap: () => ref.read(localeProvider.notifier).setLocale(value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: l10n.settingsTheme,
            children: [
              for (final (value, label) in themes)
                _OptionTile(
                  label: label,
                  selected: value == themeMode,
                  onTap: () => ref.read(themeModeProvider.notifier).setMode(value),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: EdgeInsets.zero,
            child: SwitchListTile(
              value: reducedGlass,
              onChanged: (v) => ref.read(glassReducedProvider.notifier).set(v),
              title: Text(l10n.settingsReduceTransparency, style: Theme.of(context).textTheme.bodyLarge),
              subtitle: Text(l10n.settingsReduceTransparencyHint),
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _Section(
            title: l10n.legalSectionTitle,
            children: [
              _LinkTile(label: l10n.legalPrivacyTitle, onTap: () => context.push(AppRoutes.legalPrivacy)),
              _LinkTile(label: l10n.legalRefundTitle, onTap: () => context.push(AppRoutes.legalRefund)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      if (i > 0) rows.add(Divider(height: 1, color: c.border));
      rows.add(children[i]);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: rows),
        ),
      ],
    );
  }
}

class _OptionTile extends StatelessWidget {
  const _OptionTile({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.fast),
                child: Icon(
                  selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                  key: ValueKey(selected),
                  color: selected ? c.primary : c.border,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 14),
          child: Row(
            children: [
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              Icon(Icons.chevron_right_rounded, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}
