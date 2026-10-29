import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/rating_stars.dart';

/// Bitta sharh: muallif, yulduzcha, sana, matn va do'kon javobi.
class ReviewTile extends StatelessWidget {
  const ReviewTile({
    super.key,
    required this.authorLabel,
    required this.rating,
    required this.date,
    this.text,
    this.adminReply,
    this.trailing,
  });

  final String authorLabel;
  final int rating;
  final DateTime date;
  final String? text;
  final String? adminReply;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final body = (text ?? '').trim();
    final reply = (adminReply ?? '').trim();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                authorLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.titleSmall,
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            RatingStars(value: rating.toDouble(), size: 16),
            const SizedBox(width: AppSpacing.sm),
            Text(
              context.formatDate(date),
              style: textTheme.bodySmall?.copyWith(color: c.textSecondary),
            ),
          ],
        ),
        if (body.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: textTheme.bodyMedium?.copyWith(height: 1.5)),
        ],
        if (reply.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: c.secondary.withAlpha(110),
              borderRadius: AppRadius.borderBase,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.reviewsShopReply,
                  style: textTheme.labelMedium?.copyWith(color: c.primary, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(reply, style: textTheme.bodyMedium?.copyWith(height: 1.5)),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
