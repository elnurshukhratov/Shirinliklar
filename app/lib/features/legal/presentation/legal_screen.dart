import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../domain/legal_content.dart';

/// Maxfiylik siyosati yoki pulni qaytarish qoidalari sahifasi (kirmasdan ham ochiladi).
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final sections = legalSections(doc, lang);
    final title = doc == LegalDoc.privacy ? l10n.legalPrivacyTitle : l10n.legalRefundTitle;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SelectionArea(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              l10n.legalLastUpdated(context.formatDate(kLegalUpdatedAt)),
              style: text.bodySmall?.copyWith(color: c.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < sections.length; i++) ...[
              Text('${i + 1}. ${sections[i].title}', style: text.titleMedium),
              const SizedBox(height: AppSpacing.sm),
              Text(sections[i].body, style: text.bodyMedium?.copyWith(height: 1.5)),
              const SizedBox(height: AppSpacing.xl),
            ],
          ],
        ),
      ),
    );
  }
}
