import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/l10n/locale_provider.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/theme/glass_settings.dart';
import '../../../core/theme/theme_mode_provider.dart';
import '../../../core/widgets/glass/glass_panel.dart';
import '../../../core/widgets/glass/glass_switch.dart';
import '../../../core/widgets/glass/reveal.dart';

/// Sozlamalar: har bir guruh shisha panelda, til va mavzu esa siljiydigan segment tanlagichda.
/// Bo'limlar yuqoridan pastga ketma-ket paydo bo'ladi.
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
        padding: EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.xxl + MediaQuery.paddingOf(context).bottom,
        ),
        children: [
          Reveal(
            index: 0,
            child: _Section(
              title: l10n.settingsLanguage,
              icon: Icons.translate_rounded,
              child: GlassSegmented<Locale>(
                options: languages,
                value: locale,
                onChanged: (v) => ref.read(localeProvider.notifier).setLocale(v),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Reveal(
            index: 1,
            child: _Section(
              title: l10n.settingsTheme,
              icon: Icons.contrast_rounded,
              child: GlassSegmented<ThemeMode>(
                options: themes,
                value: themeMode,
                onChanged: (v) => ref.read(themeModeProvider.notifier).setMode(v),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Reveal(
            index: 2,
            child: GlassPanel(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
              children: [
                GlassSwitchTile(
                  title: l10n.settingsReduceTransparency,
                  subtitle: l10n.settingsReduceTransparencyHint,
                  value: reducedGlass,
                  onChanged: (v) => ref.read(glassReducedProvider.notifier).set(v),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Reveal(
            index: 3,
            child: _Section(
              title: l10n.legalSectionTitle,
              icon: Icons.verified_user_outlined,
              child: GlassPanel(
                children: [
                  GlassPanelTile(
                    title: l10n.legalPrivacyTitle,
                    icon: Icons.lock_outline_rounded,
                    onTap: () => context.push(AppRoutes.legalPrivacy),
                  ),
                  GlassPanelTile(
                    title: l10n.legalRefundTitle,
                    icon: Icons.assignment_return_outlined,
                    onTap: () => context.push(AppRoutes.legalRefund),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.icon, required this.child});

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Row(
            children: [
              Icon(icon, size: 18, color: c.textSecondary),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
