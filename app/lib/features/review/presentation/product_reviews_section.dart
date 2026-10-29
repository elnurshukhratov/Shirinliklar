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
import '../../admin/presentation/widgets/confirm_dialog.dart';
import '../../catalog/domain/catalog_models.dart';
import '../application/review_providers.dart';
import '../domain/review_models.dart';
import 'widgets/review_tile.dart';

/// Mahsulot sahifasidagi sharhlar bo'limi: o'z sharhi, sharh qoldirish tugmasi va boshqalarning izohlari.
class ProductReviewsSection extends ConsumerStatefulWidget {
  const ProductReviewsSection({super.key, required this.product});

  final CatalogProduct product;

  @override
  ConsumerState<ProductReviewsSection> createState() => _ProductReviewsSectionState();
}

class _ProductReviewsSectionState extends ConsumerState<ProductReviewsSection> {
  bool _busy = false;

  String get _productId => widget.product.id;

  void _openForm() {
    context.push(AppRoutes.review(_productId), extra: widget.product.name);
  }

  Future<void> _delete(MyReview review) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final ok = await confirmDialog(
      context,
      title: l10n.reviewDeleteTitle,
      message: l10n.reviewDeleteMessage,
      confirmLabel: l10n.commonDelete,
    );
    if (!ok || !mounted) return;

    setState(() => _busy = true);
    try {
      await ref.read(reviewRepositoryProvider).delete(review.id);
      messenger.showSnackBar(SnackBar(content: Text(l10n.reviewDeleted)));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      if (mounted) {
        refreshAfterReviewChange(ref, _productId);
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    final mine = ref.watch(myReviewStateProvider(_productId)).valueOrNull;
    final list = ref.watch(productReviewsProvider(_productId));
    final own = mine?.review;
    final others = list.items.where((r) => r.id != own?.id).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.reviewsTitle, style: text.titleMedium),
        const SizedBox(height: AppSpacing.md),
        if (own != null)
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.reviewsYourReview, style: text.labelMedium?.copyWith(color: c.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                ReviewTile(
                  authorLabel: l10n.reviewsYou,
                  rating: own.rating,
                  date: own.createdAt,
                  text: own.text,
                  adminReply: own.adminReply,
                  trailing: own.isHidden ? AppBadge(label: l10n.adminReviewHiddenBadge, tone: AppBadgeTone.error) : null,
                ),
                if (own.isHidden) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(l10n.reviewsHiddenNotice, style: text.bodySmall?.copyWith(color: c.textSecondary)),
                ],
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    AppButton(
                      label: l10n.commonEdit,
                      icon: Icons.edit_outlined,
                      variant: AppButtonVariant.secondary,
                      expanded: false,
                      onPressed: _busy ? null : _openForm,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    AppButton(
                      label: l10n.commonDelete,
                      icon: Icons.delete_outline_rounded,
                      variant: AppButtonVariant.text,
                      expanded: false,
                      isLoading: _busy,
                      onPressed: _busy ? null : () => _delete(own),
                    ),
                  ],
                ),
              ],
            ),
          )
        else if (mine != null && mine.canReview)
          AppButton(
            label: l10n.reviewsLeave,
            icon: Icons.star_outline_rounded,
            variant: AppButtonVariant.secondary,
            onPressed: _openForm,
          )
        else if (mine != null)
          Text(l10n.reviewsOnlyBuyers, style: text.bodySmall?.copyWith(color: c.textSecondary)),
        const SizedBox(height: AppSpacing.lg),
        if (list.loading && list.items.isEmpty)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.lg),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (list.error != null && list.items.isEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: AppButton(
              label: l10n.commonRetry,
              icon: Icons.refresh_rounded,
              variant: AppButtonVariant.text,
              expanded: false,
              onPressed: () => ref.read(productReviewsProvider(_productId).notifier).refresh(),
            ),
          )
        else if (others.isEmpty && own == null)
          Text(l10n.reviewsEmpty, style: text.bodyMedium?.copyWith(color: c.textSecondary))
        else ...[
          for (final r in others) ...[
            ReviewTile(
              authorLabel: r.authorName ?? l10n.reviewsAnonymous,
              rating: r.rating,
              date: r.createdAt,
              text: r.text,
              adminReply: r.adminReply,
            ),
            const Divider(height: AppSpacing.xl),
          ],
          if (list.hasMore)
            Align(
              alignment: Alignment.centerLeft,
              child: AppButton(
                label: l10n.reviewsShowMore,
                variant: AppButtonVariant.text,
                expanded: false,
                isLoading: list.loadingMore,
                onPressed: () => ref.read(productReviewsProvider(_productId).notifier).loadMore(),
              ),
            ),
        ],
      ],
    );
  }
}
