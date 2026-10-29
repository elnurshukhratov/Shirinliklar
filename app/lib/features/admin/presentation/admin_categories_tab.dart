import '../../../core/widgets/glass/glass_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'category_editor_sheet.dart';
import 'widgets/confirm_dialog.dart';

/// Toifa qo'shish yoki tahrirlash oynasini ochadi.
Future<void> openCategoryEditor(
  BuildContext context,
  WidgetRef ref, {
  AdminCategory? category,
}) async {
  final saved = await showGlassSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (_) => CategoryEditorSheet(category: category),
  );
  if (saved == true) ref.invalidate(adminCategoriesProvider);
}

enum _CategoryAction { edit, toggle, delete }

class AdminCategoriesTab extends ConsumerWidget {
  const AdminCategoriesTab({super.key, this.readOnly = false});

  /// Xodim toifalarni faqat ko'ra oladi: tahrirlash, yashirish va o'chirish faqat do'kon egasiga.
  final bool readOnly;

  Future<void> _onAction(
    BuildContext context,
    WidgetRef ref,
    _CategoryAction action,
    AdminCategory cat,
  ) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(adminRepositoryProvider);

    switch (action) {
      case _CategoryAction.edit:
        await openCategoryEditor(context, ref, category: cat);
      case _CategoryAction.toggle:
        try {
          await repo.saveCategory(id: cat.id, body: {'isActive': !cat.isActive});
          ref.invalidate(adminCategoriesProvider);
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
      case _CategoryAction.delete:
        final ok = await confirmDialog(
          context,
          title: l10n.adminCategoryDeleteTitle,
          message: l10n.adminCategoryDeleteMessage,
          confirmLabel: l10n.commonDelete,
        );
        if (!ok) return;
        try {
          await repo.deleteCategory(cat.id);
          ref.invalidate(adminCategoriesProvider);
          messenger.showSnackBar(SnackBar(content: Text(l10n.adminCategoryDeleted)));
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final categories = ref.watch(adminCategoriesProvider);

    return categories.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final err = describeError(l10n, e);
        return ErrorState(
          title: err.title,
          message: err.message,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(adminCategoriesProvider),
        );
      },
      data: (list) {
        if (list.isEmpty) {
          return EmptyState(
            title: l10n.adminCategoriesEmptyTitle,
            message: l10n.adminCategoriesEmptyMessage,
            icon: Icons.category_outlined,
          );
        }
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminCategoriesProvider);
            await ref.read(adminCategoriesProvider.future);
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 96),
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final cat = list[i];
              return AppCard(
                onTap: readOnly ? null : () => _onAction(context, ref, _CategoryAction.edit, cat),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cat.name.forLanguage(lang), style: text.titleSmall),
                          const SizedBox(height: 4),
                          Wrap(
                            spacing: 6,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                l10n.adminCategoryProducts(cat.productsCount),
                                style: text.bodySmall?.copyWith(color: c.textSecondary),
                              ),
                              if (!cat.isActive) AppBadge(label: l10n.adminBadgeHidden),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!readOnly)
                      PopupMenuButton<_CategoryAction>(
                      onSelected: (a) => _onAction(context, ref, a, cat),
                      itemBuilder: (_) => [
                        PopupMenuItem(value: _CategoryAction.edit, child: Text(l10n.commonEdit)),
                        PopupMenuItem(
                          value: _CategoryAction.toggle,
                          child: Text(cat.isActive ? l10n.adminHide : l10n.adminShow),
                        ),
                        PopupMenuItem(
                          value: _CategoryAction.delete,
                          child: Text(l10n.commonDelete, style: TextStyle(color: c.error)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}