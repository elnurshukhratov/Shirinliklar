import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../application/auth_controller.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _busy = false;

  Future<void> _confirmDelete() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final controller = ref.read(authControllerProvider.notifier);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.profileDeleteTitle),
        content: Text(l10n.profileDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(
              l10n.commonDelete,
              style: TextStyle(color: dialogContext.colors.error),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      await controller.deleteAccount();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final user = ref.watch(authControllerProvider).user;

    if (user == null) return const Scaffold();

    String valueOrNotSet(String? v) => (v == null || v.trim().isEmpty) ? l10n.profileNotSet : v;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profileTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Center(
            child: Container(
              width: 88,
              height: 88,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: c.secondary, shape: BoxShape.circle),
              child: Text(user.initials, style: text.headlineSmall?.copyWith(color: c.textPrimary)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            user.fullName.isEmpty ? user.email : user.fullName,
            textAlign: TextAlign.center,
            style: text.titleLarge,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            user.email,
            textAlign: TextAlign.center,
            style: text.bodyMedium?.copyWith(color: c.textSecondary),
          ),
          if (user.username != null) ...[
            const SizedBox(height: 2),
            Text(
              '@${user.username}',
              textAlign: TextAlign.center,
              style: text.bodyMedium?.copyWith(color: c.textSecondary),
            ),
          ],
          if (user.isAdmin) ...[
            const SizedBox(height: AppSpacing.md),
            Center(child: AppBadge(
                label: user.isOwner ? l10n.profileRoleOwner : l10n.profileRoleStaff,
                tone: AppBadgeTone.primary,
              ),),
          ],
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: l10n.profilePhone, value: valueOrNotSet(user.phone)),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(label: l10n.profileAddress, value: valueOrNotSet(user.address)),
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(label: l10n.profileLandmark, value: valueOrNotSet(user.landmark)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            label: l10n.commonEdit,
            icon: Icons.edit_outlined,
            variant: AppButtonVariant.secondary,
            onPressed: _busy ? null : () => context.push(AppRoutes.profileEdit),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _ActionTile(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.myOrdersTitle,
                  onTap: () => context.push(AppRoutes.myOrders),
                ),
                Divider(height: 1, color: c.border),
                _ActionTile(
                  icon: Icons.favorite_border_rounded,
                  label: l10n.favoritesTitle,
                  onTap: () => context.push(AppRoutes.favorites),
                ),
                Divider(height: 1, color: c.border),
                _ActionTile(
                  icon: Icons.lock_outline_rounded,
                  label: l10n.credentialsTitle,
                  onTap: () => context.push(AppRoutes.profileCredentials),
                ),
                Divider(height: 1, color: c.border),
                _ActionTile(
                  icon: Icons.settings_outlined,
                  label: l10n.settingsTitle,
                  onTap: () => context.push(AppRoutes.settings),
                ),
                if (user.isAdmin) ...[
                  Divider(height: 1, color: c.border),
                  _ActionTile(
                    icon: Icons.admin_panel_settings_outlined,
                    label: l10n.profileAdminPanel,
                    onTap: () => context.push(AppRoutes.admin),
                  ),
                ],
                Divider(height: 1, color: c.border),
                _ActionTile(
                  icon: Icons.logout_rounded,
                  label: l10n.authSignOut,
                  onTap: _busy ? null : () => ref.read(authControllerProvider.notifier).signOut(),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppButton(
            label: l10n.profileDeleteAccount,
            variant: AppButtonVariant.text,
            isLoading: _busy,
            onPressed: _confirmDelete,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: text.labelMedium?.copyWith(color: c.textSecondary)),
        const SizedBox(height: 2),
        Text(value, style: text.bodyLarge),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;

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
              Icon(icon, color: c.primary),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyLarge)),
              Icon(Icons.chevron_right_rounded, color: c.border),
            ],
          ),
        ),
      ),
    );
  }
}