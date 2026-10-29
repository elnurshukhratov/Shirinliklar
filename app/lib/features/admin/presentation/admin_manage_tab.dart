import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';

/// Faqat do'kon egasi uchun: statistika, promokodlar va xodimlarni boshqarish bo'limlariga kirish.
class AdminManageTab extends StatelessWidget {
  const AdminManageTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        _ManageCard(
          icon: Icons.insights_outlined,
          title: l10n.adminStatsTitle,
          subtitle: l10n.adminManageStatsHint,
          onTap: () => context.push(AppRoutes.adminStats),
        ),
        const SizedBox(height: AppSpacing.md),
        _ManageCard(
          icon: Icons.sell_outlined,
          title: l10n.adminPromosTitle,
          subtitle: l10n.adminManagePromosHint,
          onTap: () => context.push(AppRoutes.adminPromos),
        ),
        const SizedBox(height: AppSpacing.md),
        _ManageCard(
          icon: Icons.group_outlined,
          title: l10n.adminStaffTitle,
          subtitle: l10n.adminManageStaffHint,
          onTap: () => context.push(AppRoutes.adminStaff),
        ),
      ],
    );
  }
}

class _ManageCard extends StatelessWidget {
  const _ManageCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: c.secondary, borderRadius: AppRadius.borderBase),
            child: Icon(icon, color: c.primary),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: text.titleSmall),
                const SizedBox(height: 2),
                Text(subtitle, style: text.bodySmall?.copyWith(color: c.textSecondary, height: 1.35)),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: c.border),
        ],
      ),
    );
  }
}
