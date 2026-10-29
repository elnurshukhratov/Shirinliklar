import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_text_field.dart';
import '../application/promo_controller.dart';

/// Savatda promokod kiritish: kod tekshiriladi va chegirma ko'rsatiladi.
class PromoSection extends ConsumerStatefulWidget {
  const PromoSection({super.key, required this.subtotal});

  /// Mahsulotlar summasi (yetkazish narxisiz).
  final double subtotal;

  @override
  ConsumerState<PromoSection> createState() => _PromoSectionState();
}

class _PromoSectionState extends ConsumerState<PromoSection> {
  final _controller = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    final code = _controller.text.trim();
    if (code.isEmpty || _busy) return;
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;

    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(appliedPromoProvider.notifier).apply(code, widget.subtotal);
      if (!mounted) return;
      _controller.clear();
      setState(() => _busy = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = describeError(l10n, e).message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final promo = ref.watch(appliedPromoProvider);

    return AnimatedSwitcher(
      duration: AppMotion.of(context),
      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
      child: promo != null
          ? AppCard(
              key: const ValueKey('applied'),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: c.success),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(promo.code, style: text.titleSmall?.copyWith(letterSpacing: 0.6)),
                        const SizedBox(height: 2),
                        Text(
                          l10n.promoApplied(context.formatPrice(promo.discountFor(widget.subtotal))),
                          style: text.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: l10n.promoRemove,
                    icon: Icon(Icons.close_rounded, color: c.textSecondary),
                    onPressed: ref.read(appliedPromoProvider.notifier).clear,
                  ),
                ],
              ),
            )
          : Column(
              key: const ValueKey('input'),
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _controller,
                        hint: l10n.promoHint,
                        textInputAction: TextInputAction.done,
                        maxLength: 40,
                        prefixIcon: const Icon(Icons.sell_outlined),
                        enabled: !_busy,
                        onSubmitted: (_) => _apply(),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: AppButton(
                        label: l10n.promoApply,
                        expanded: false,
                        isLoading: _busy,
                        variant: AppButtonVariant.secondary,
                        onPressed: _apply,
                      ),
                    ),
                  ],
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: AppSpacing.md),
                    child: Text(_error!, style: text.bodySmall?.copyWith(color: c.error)),
                  ),
              ],
            ),
    );
  }
}
