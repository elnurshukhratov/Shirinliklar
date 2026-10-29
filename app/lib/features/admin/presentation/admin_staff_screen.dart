import '../../../core/widgets/glass/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../application/admin_staff_providers.dart';
import '../domain/staff_models.dart';
import 'widgets/confirm_dialog.dart';

/// Do'kon egasi uchun: xodimlar ro'yxati, qo'shish va olib tashlash.
class AdminStaffScreen extends ConsumerWidget {
  const AdminStaffScreen({super.key});

  Future<void> _add(BuildContext context, WidgetRef ref) async {
    final added = await showGlassSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _StaffAddSheet(),
    );
    if (added == true) ref.invalidate(adminStaffProvider);
  }

  Future<void> _remove(BuildContext context, WidgetRef ref, StaffMember member) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await confirmDialog(
      context,
      title: l10n.adminStaffRemoveTitle,
      message: l10n.adminStaffRemoveMessage(member.email),
      confirmLabel: l10n.adminStaffRemove,
    );
    if (!ok) return;
    try {
      await ref.read(adminStaffRepositoryProvider).remove(member.id);
      ref.invalidate(adminStaffProvider);
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminStaffRemoved)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final staff = ref.watch(adminStaffProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.adminStaffTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _add(context, ref),
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l10n.adminStaffAdd),
      ),
      body: staff.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(adminStaffProvider),
          );
        },
        data: (list) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStaffProvider);
            await ref.read(adminStaffProvider.future);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
            itemCount: list.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              if (i == 0) {
                return Text(
                  l10n.adminStaffHint,
                  style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.4),
                );
              }
              final m = list[i - 1];
              return AppCard(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: c.secondary, shape: BoxShape.circle),
                      child: Text(m.initials, style: text.titleSmall),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (m.fullName.isNotEmpty)
                            Text(m.fullName, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                          Text(
                            m.email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(color: c.textSecondary),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            children: [
                              AppBadge(
                                label: m.isOwner ? l10n.profileRoleOwner : l10n.profileRoleStaff,
                                tone: m.isOwner ? AppBadgeTone.primary : AppBadgeTone.neutral,
                              ),
                              if (!m.isOwner && !m.hasSignedIn) AppBadge(label: l10n.adminStaffNotSignedIn),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!m.isOwner)
                      IconButton(
                        tooltip: l10n.adminStaffRemove,
                        icon: Icon(Icons.person_remove_outlined, color: c.error),
                        onPressed: () => _remove(context, ref, m),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StaffAddSheet extends ConsumerStatefulWidget {
  const _StaffAddSheet();

  @override
  ConsumerState<_StaffAddSheet> createState() => _StaffAddSheetState();
}

class _StaffAddSheetState extends ConsumerState<_StaffAddSheet> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  String? _validate(String? v) {
    final s = (v ?? '').trim();
    if (s.isEmpty) return context.l10n.fieldRequired;
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s) ? null : context.l10n.adminStaffEmailInvalid;
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(adminStaffRepositoryProvider).add(_email.text.trim().toLowerCase());
      messenger.showSnackBar(SnackBar(content: Text(l10n.adminStaffAdded)));
      navigator.pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = describeError(l10n, e).message;
        _busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.adminStaffAdd, style: text.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l10n.adminStaffAddHint,
                style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.4),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppTextField(
                controller: _email,
                label: l10n.adminStaffEmail,
                hint: 'name@gmail.com',
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                maxLength: 254,
                validator: _validate,
                enabled: !_busy,
                autofillHints: const [AutofillHints.email],
                onSubmitted: (_) => _save(),
              ),
              if (_error != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(_error!, style: text.bodyMedium?.copyWith(color: c.error)),
              ],
              const SizedBox(height: AppSpacing.lg),
              AppButton(label: l10n.adminStaffAdd, isLoading: _busy, onPressed: _save),
            ],
          ),
        ),
      ),
    );
  }
}
