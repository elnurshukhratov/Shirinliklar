import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/state_views.dart';
import '../../admin/domain/admin_models.dart';
import '../application/review_providers.dart';
import '../domain/review_models.dart';

/// «Baho va izoh qoldirish» ekrani: yangi sharh yozish yoki mavjudini tahrirlash.
class ReviewFormScreen extends ConsumerStatefulWidget {
  const ReviewFormScreen({super.key, required this.productId, this.productName});

  final String productId;
  final LocalizedText? productName;

  @override
  ConsumerState<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends ConsumerState<ReviewFormScreen> {
  final _text = TextEditingController();
  int _rating = 0;
  bool _filled = false;
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /// Mavjud sharh bo'lsa, maydonlar bir marta to'ldiriladi.
  void _fillFrom(MyReview? review) {
    if (_filled) return;
    _filled = true;
    if (review != null) {
      _rating = review.rating;
      _text.text = review.text ?? '';
    }
  }

  Future<void> _submit(MyReview? existing) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final repo = ref.read(reviewRepositoryProvider);

    setState(() => _saving = true);
    try {
      if (existing == null) {
        await repo.create(productId: widget.productId, rating: _rating, text: _text.text);
      } else {
        await repo.update(existing.id, rating: _rating, text: _text.text);
      }
      if (!mounted) return;
      refreshAfterReviewChange(ref, widget.productId);
      messenger.showSnackBar(SnackBar(
        content: Text(existing == null ? l10n.reviewFormSent : l10n.reviewFormUpdated),
      ));
      if (router.canPop()) router.pop();
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
      // Sharh allaqachon bo'lishi mumkin — eng so'nggi holatni qayta yuklaymiz.
      ref.invalidate(myReviewStateProvider(widget.productId));
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final async = ref.watch(myReviewStateProvider(widget.productId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          async.valueOrNull?.review != null ? l10n.reviewFormEditTitle : l10n.reviewFormTitle,
        ),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(myReviewStateProvider(widget.productId)),
          );
        },
        data: (state) {
          if (!state.canReview) {
            return EmptyState(
              title: l10n.reviewFormNotAllowedTitle,
              message: l10n.errorReviewNotAllowed,
              icon: Icons.star_outline_rounded,
            );
          }
          _fillFrom(state.review);
          final name = widget.productName?.forLanguage(lang);

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              if (name != null && name.isNotEmpty) ...[
                Text(name, style: textTheme.titleLarge),
                const SizedBox(height: AppSpacing.xl),
              ],
              Text(l10n.reviewFormRatingLabel, style: textTheme.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              Center(
                child: RatingStars(
                  value: _rating.toDouble(),
                  size: 44,
                  onChanged: _saving ? null : (v) => setState(() => _rating = v),
                ),
              ),
              if (_rating == 0) ...[
                const SizedBox(height: AppSpacing.sm),
                Center(
                  child: Text(
                    l10n.reviewFormRatingRequired,
                    style: textTheme.bodySmall?.copyWith(color: c.textSecondary),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                controller: _text,
                label: l10n.reviewFormTextLabel,
                hint: l10n.reviewFormTextHint,
                maxLines: 5,
                maxLength: 1000,
                keyboardType: TextInputType.multiline,
                enabled: !_saving,
              ),
              const SizedBox(height: AppSpacing.xl),
              AppButton(
                label: state.review == null ? l10n.reviewFormSubmit : l10n.commonSave,
                isLoading: _saving,
                onPressed: _rating == 0 ? null : () => _submit(state.review),
              ),
            ],
          );
        },
      ),
    );
  }
}
