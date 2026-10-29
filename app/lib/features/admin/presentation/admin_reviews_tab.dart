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
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/state_views.dart';
import '../../catalog/application/catalog_providers.dart';
import '../../review/application/review_providers.dart';
import '../../review/domain/review_models.dart';
import '../../review/presentation/widgets/review_tile.dart';
import 'widgets/confirm_dialog.dart';

/// Admin: izohlar ro'yxati — nomaqbulini yashirish va javob yozish.
class AdminReviewsTab extends ConsumerStatefulWidget {
  const AdminReviewsTab({super.key});

  @override
  ConsumerState<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends ConsumerState<AdminReviewsTab> {
  final _scroll = ScrollController();
  final _busy = <String>{};

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.hasClients && _scroll.position.extentAfter < 300) {
        ref.read(adminReviewListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  /// Bitta amalni bajaradi, natijani ro'yxatga qo'yadi, xatoni xabar sifatida ko'rsatadi.
  Future<void> _run(AdminReview review, Future<AdminReview> Function() action, {bool affectsRating = false}) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy.add(review.id));
    try {
      final updated = await action();
      if (!mounted) return;
      ref.read(adminReviewListProvider.notifier).replace(updated);
      if (affectsRating) {
        // Yashirilgan izoh o'rtacha bahoga kirmaydi — katalog kartalari yangilansin.
        ref.invalidate(catalogListProvider);
        ref.invalidate(catalogProductProvider(review.productId));
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      if (mounted) setState(() => _busy.remove(review.id));
    }
  }

  Future<void> _toggleHidden(AdminReview review) async {
    final l10n = context.l10n;
    final repo = ref.read(adminReviewsRepositoryProvider);

    if (!review.isHidden) {
      final ok = await confirmDialog(
        context,
        title: l10n.adminReviewHideTitle,
        message: l10n.adminReviewHideMessage,
        confirmLabel: l10n.adminReviewHide,
      );
      if (!ok || !mounted) return;
    }
    await _run(
      review,
      () => repo.setHidden(review.id, hidden: !review.isHidden),
      affectsRating: true,
    );
  }

  Future<void> _reply(AdminReview review) async {
    final repo = ref.read(adminReviewsRepositoryProvider);
    final text = await showGlassSheet<String>(
      context: context,
      builder: (_) => _ReplySheet(initial: review.adminReply ?? ''),
    );
    if (text == null || text.trim().isEmpty || !mounted) return;
    await _run(review, () => repo.reply(review.id, text));
  }

  Future<void> _deleteReply(AdminReview review) async {
    final l10n = context.l10n;
    final repo = ref.read(adminReviewsRepositoryProvider);
    final ok = await confirmDialog(
      context,
      title: l10n.adminReviewReplyDeleteTitle,
      message: l10n.adminReviewReplyDeleteMessage,
      confirmLabel: l10n.commonDelete,
    );
    if (!ok || !mounted) return;
    await _run(review, () => repo.deleteReply(review.id));
  }

  String _filterLabel(ReviewVisibility v) {
    final l10n = context.l10n;
    return switch (v) {
      ReviewVisibility.all => l10n.adminReviewsFilterAll,
      ReviewVisibility.visible => l10n.adminReviewsFilterVisible,
      ReviewVisibility.hidden => l10n.adminReviewsFilterHidden,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminReviewListProvider);
    final notifier = ref.read(adminReviewListProvider.notifier);

    return Column(
      children: [
        SizedBox(
          height: 56,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            children: [
              for (final v in ReviewVisibility.values) ...[
                if (v != ReviewVisibility.all) const SizedBox(width: AppSpacing.sm),
                AppChip(
                  label: _filterLabel(v),
                  selected: state.visibility == v,
                  onTap: () => notifier.setVisibility(v),
                ),
              ],
            ],
          ),
        ),
        if (state.loading && state.items.isNotEmpty) const LinearProgressIndicator(minHeight: 2),
        Expanded(child: _body(context, state, notifier)),
      ],
    );
  }

  Widget _body(BuildContext context, AdminReviewListState state, AdminReviewListController notifier) {
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
      return RefreshIndicator(
        onRefresh: notifier.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(
              height: 360,
              child: EmptyState(
                title: l10n.adminReviewsEmptyTitle,
                message: l10n.adminReviewsEmptyMessage,
                icon: Icons.rate_review_outlined,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: notifier.refresh,
      child: ListView.separated(
        controller: _scroll,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
        itemCount: state.items.length + (state.loadingMore ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= state.items.length) {
            return const Padding(
              padding: EdgeInsets.all(AppSpacing.lg),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final review = state.items[i];
          return _ReviewCard(
            review: review,
            busy: _busy.contains(review.id),
            onToggleHidden: () => _toggleHidden(review),
            onReply: () => _reply(review),
            onDeleteReply: () => _deleteReply(review),
          );
        },
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.review,
    required this.busy,
    required this.onToggleHidden,
    required this.onReply,
    required this.onDeleteReply,
  });

  final AdminReview review;
  final bool busy;
  final VoidCallback onToggleHidden;
  final VoidCallback onReply;
  final VoidCallback onDeleteReply;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final hasReply = (review.adminReply ?? '').trim().isNotEmpty;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            review.productName.forLanguage(lang),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.labelLarge?.copyWith(color: c.textSecondary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ReviewTile(
            authorLabel: review.userName ?? review.userEmail,
            rating: review.rating,
            date: review.createdAt,
            text: review.text,
            adminReply: review.adminReply,
            trailing: review.isHidden ? AppBadge(label: l10n.adminReviewHiddenBadge, tone: AppBadgeTone.error) : null,
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.xs,
            children: [
              AppButton(
                label: review.isHidden ? l10n.adminReviewShow : l10n.adminReviewHide,
                icon: review.isHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                variant: AppButtonVariant.secondary,
                expanded: false,
                onPressed: busy ? null : onToggleHidden,
              ),
              AppButton(
                label: hasReply ? l10n.adminReviewReplyEdit : l10n.adminReviewReply,
                icon: Icons.reply_rounded,
                variant: AppButtonVariant.secondary,
                expanded: false,
                onPressed: busy ? null : onReply,
              ),
              if (hasReply)
                AppButton(
                  label: l10n.adminReviewReplyDelete,
                  icon: Icons.delete_outline_rounded,
                  variant: AppButtonVariant.text,
                  expanded: false,
                  onPressed: busy ? null : onDeleteReply,
                ),
            ],
          ),
          if (busy) const Padding(
            padding: EdgeInsets.only(top: AppSpacing.sm),
            child: LinearProgressIndicator(minHeight: 2),
          ),
        ],
      ),
    );
  }
}

class _ReplySheet extends StatefulWidget {
  const _ReplySheet({required this.initial});

  final String initial;

  @override
  State<_ReplySheet> createState() => _ReplySheetState();
}

class _ReplySheetState extends State<_ReplySheet> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.adminReviewReply, style: text.titleMedium),
          const SizedBox(height: AppSpacing.md),
          AppTextField(
            controller: _controller,
            hint: l10n.adminReviewReplyHint,
            maxLines: 5,
            maxLength: 1000,
            keyboardType: TextInputType.multiline,
          ),
          const SizedBox(height: AppSpacing.lg),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, __) => AppButton(
              label: l10n.commonSave,
              onPressed: value.text.trim().isEmpty ? null : () => Navigator.of(context).pop(_controller.text),
            ),
          ),
        ],
      ),
    );
  }
}
