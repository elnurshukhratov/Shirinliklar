import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/expand/expand_origin.dart';
import '../../../../core/widgets/glass/glass_container.dart';
import '../../../../core/widgets/glass/pressable.dart';
import '../../../auth/domain/app_user.dart';

/// Bosh sahifa tepasi: salom + manzil pill'i (shisha) va avatar. Katta AppBar yo'q.
/// Bildirishnomalar markazi (ekran va backend) hozircha yo'q, shuning uchun hech narsa qilmaydigan
/// qo'ng'iroq tugmasi ko'rsatilmaydi.
class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key, required this.user});

  final AppUser? user;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final top = MediaQuery.paddingOf(context).top;

    final first = user?.firstName?.trim();
    final name = (first != null && first.isNotEmpty) ? first : (user?.username?.trim() ?? '');
    final greeting = name.isEmpty ? l10n.homeGreetingGuest : l10n.homeGreeting(name);

    final address = user?.address?.trim();
    final hasAddress = address != null && address.isNotEmpty;

    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.lg, top + AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Semantics(
                    button: true,
                    label: hasAddress ? address : l10n.homeAddressEmpty,
                    excludeSemantics: true,
                    child: Pressable(
                      scale: 0.97,
                      haptic: true,
                      onTap: () => context.push(AppRoutes.profileEdit),
                      child: GlassContainer(
                        level: GlassLevel.chip,
                        blur: false,
                        shadow: false,
                        padding: const EdgeInsets.fromLTRB(10, 8, 12, 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.location_on_rounded, size: 18, color: c.primary),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                hasAddress ? address : l10n.homeAddressEmpty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: text.labelMedium,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: c.textSecondary),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Semantics(
            button: true,
            label: l10n.profileTitle,
            excludeSemantics: true,
            child: Pressable(
              haptic: true,
              scale: 0.92,
              onTap: () => context.go(AppRoutes.profile),
              child: Container(
                width: 44,
                height: 44,
                margin: const EdgeInsets.only(left: 4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.lerp(c.cta, Colors.white, 0.14)!, c.cta],
                  ),
                  boxShadow: AppShadows.tinted(c.cta, strength: 0.26),
                ),
                child: Text(
                  user?.initials ?? '?',
                  style: AppTypography.display(14).copyWith(color: c.onCta),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Qidiruv paneli (shisha pill). Bosilganda butun ekranga kengayadi (qidiruv sahifasi).
class HomeSearchPill extends StatefulWidget {
  const HomeSearchPill({super.key});

  @override
  State<HomeSearchPill> createState() => _HomeSearchPillState();
}

class _HomeSearchPillState extends State<HomeSearchPill> {
  final GlobalKey _key = GlobalKey(debugLabel: 'homeSearchPill');

  void _open() {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    context.pushExpanded<void>(
      AppRoutes.search,
      sourceKey: _key,
      radius: 26,
      surfaceColor: dark ? Color.lerp(c.surface, Colors.white, 0.08)! : c.surface,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
      child: Semantics(
        button: true,
        label: l10n.catalogSearchHint,
        excludeSemantics: true,
        child: Pressable(
          scale: 0.985,
          onTap: _open,
          child: SizedBox(
            key: _key,
            height: 52,
            child: GlassContainer(
              level: GlassLevel.floating,
              blur: false,
              borderRadius: AppRadius.borderPill,
              child: Row(
                children: [
                  const SizedBox(width: AppSpacing.lg),
                  Icon(Icons.search_rounded, color: c.textSecondary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      l10n.catalogSearchHint,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyLarge?.copyWith(color: c.textSecondary),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}