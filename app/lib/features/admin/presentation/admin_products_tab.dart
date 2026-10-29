import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_badge.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../application/admin_providers.dart';
import '../domain/admin_models.dart';
import 'widgets/admin_image.dart';
import 'widgets/confirm_dialog.dart';

enum _ProductAction { edit, toggle, delete }

class AdminProductsTab extends ConsumerStatefulWidget {
  const AdminProductsTab({super.key});

  @override
  ConsumerState<AdminProductsTab> createState() => _AdminProductsTabState();
}

class _AdminProductsTabState extends ConsumerState<AdminProductsTab> {
  final _scroll = ScrollController();
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 300) {
        ref.read(adminProductListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scroll.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(adminProductListProvider.notifier).setSearch(value);
    });
  }

  Future<void> _onAction(_ProductAction action, AdminProduct p) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final notifier = ref.read(adminProductListProvider.notifier);
    final repo = ref.read(adminRepositoryProvider);

    switch (action) {
      case _ProductAction.edit:
        router.push(AppRoutes.adminProduct(p.id));
      case _ProductAction.toggle:
        try {
          final updated = await repo.setProductActive(p.id, !p.isActive);
          notifier.applyUpdated(updated);
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
      case _ProductAction.delete:
        final ok = await confirmDialog(
          context,
          title: l10n.adminDeleteProductTitle,
          message: l10n.adminDeleteProductMessage,
          confirmLabel: l10n.commonDelete,
        );
        if (!ok) return;
        try {
          await repo.deleteProduct(p.id);
          notifier.remove(p.id);
          messenger.showSnackBar(SnackBar(content: Text(l10n.adminProductDeleted)));
        } catch (e) {
          messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(adminProductListProvider);
    final notifier = ref.read(adminProductListProvider.notifier);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 0),
          child: AppTextField(
            controller: _searchController,
            hint: l10n.commonSearch,
            prefixIcon: const Icon(Icons.search_rounded),
            textInputAction: TextInputAction.search,
            onChanged: _onSearchChanged,
          ),
        ),
        SwitchListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          title: Text(l10n.adminShowHidden),
          value: state.showHidden,
          onChanged: notifier.setShowHidden,
        ),
        if (state.loading && state.items.isNotEmpty) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _body(context, state, notifier)),
      ],
    );
  }

  Widget _body(BuildContext context, ProductListState state, ProductListController notifier) {
    final l10n = context.l10n;

    if (state.loading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null && state.items.isEmpty) {
      final err = describeError(l10n, state.error!);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: notifier.refresh,
      );
    }
    if (state.items.isEmpty) {
      return state.search.isNotEmpty
          ? EmptyState(title: l10n.noResultsTitle, message: l10n.noResultsMessage, icon: Icons.search_off_rounded)
          : EmptyState(title: l10n.adminProductsEmptyTitle, message: l10n.adminProductsEmptyMessage);
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 96),
        itemCount: state.items.length + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final p = state.items[i];
          return _ProductTile(
            product: p,
            canDelete: ref.watch(authControllerProvider).user?.isOwner ?? false,
            onAction: (a) => _onAction(a, p),
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  const _ProductTile({required this.product, required this.onAction, required this.canDelete});

  final AdminProduct product;

  /// Mahsulotni o'chirish faqat do'kon egasiga ruxsat etiladi.
  final bool canDelete;
  final ValueChanged<_ProductAction> onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;

    return AppCard(
      onTap: () => onAction(_ProductAction.edit),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: AppRadius.borderSmall,
            child: AdminImage(url: product.images.isEmpty ? null : product.images.first, size: 64),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name.forLanguage(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(context.formatPrice(product.price), style: text.bodyMedium),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.adminStockCount(product.stock),
                      style: text.bodySmall?.copyWith(color: c.textSecondary),
                    ),
                    if (!product.isActive) AppBadge(label: l10n.adminBadgeHidden),
                    if (product.stock == 0)
                      AppBadge(label: l10n.adminBadgeOutOfStock, tone: AppBadgeTone.error),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<_ProductAction>(
            onSelected: onAction,
            itemBuilder: (_) => [
              PopupMenuItem(value: _ProductAction.edit, child: Text(l10n.commonEdit)),
              PopupMenuItem(
                value: _ProductAction.toggle,
                child: Text(product.isActive ? l10n.adminHide : l10n.adminShow),
              ),
              if (canDelete)
                PopupMenuItem(
                  value: _ProductAction.delete,
                  child: Text(l10n.commonDelete, style: TextStyle(color: c.error)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}