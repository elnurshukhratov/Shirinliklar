import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/glass/pressable.dart';
import '../application/push_service.dart';
import '../application/stock_alert_providers.dart';

/// Tugagan mahsulot sahifasida: «Mavjud bo'lganda xabar bering» (qayta bosilsa, obuna bekor bo'ladi).
/// Yopishqoq shisha panelga mos pilyulasimon tugma: obuna bo'lmaganda CTA gradienti,
/// obuna bo'lganda yashil ohangdagi yumshoq ko'rinish.
class StockAlertButton extends ConsumerStatefulWidget {
  const StockAlertButton({super.key, required this.productId});

  final String productId;

  @override
  ConsumerState<StockAlertButton> createState() => _StockAlertButtonState();
}

class _StockAlertButtonState extends ConsumerState<StockAlertButton> {
  bool _busy = false;

  Future<void> _toggle(bool subscribed) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final repo = ref.read(stockAlertRepositoryProvider);
    final push = ref.read(pushServiceProvider);

    setState(() => _busy = true);
    try {
      if (subscribed) {
        await repo.unsubscribe(widget.productId);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.stockAlertCancelled)));
      } else {
        final allowed = await push.requestPermission();
        await repo.subscribe(widget.productId);
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(
            content: Text(allowed ? l10n.stockAlertDone : l10n.stockAlertNoPermission),
          ));
      }
    } catch (e) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
    } finally {
      ref.invalidate(stockAlertProvider(widget.productId));
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final async = ref.watch(stockAlertProvider(widget.productId));
    final subscribed = async.valueOrNull ?? false;
    final loading = _busy || (async.isLoading && !async.hasValue);

    final label = subscribed ? l10n.stockAlertSubscribed : l10n.stockAlertNotifyMe;
    final fg = subscribed ? c.success : c.onCta;

    return Semantics(
      button: true,
      enabled: !loading,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        haptic: true,
        scale: 0.97,
        onTap: loading ? null : () => _toggle(subscribed),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: subscribed
                ? null
                : LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color.lerp(c.cta, Colors.white, 0.14)!, c.cta],
                  ),
            color: subscribed ? c.success.withValues(alpha: 0.16) : null,
            borderRadius: AppRadius.borderPill,
            border: subscribed ? Border.all(color: c.success.withValues(alpha: 0.5)) : null,
            boxShadow: subscribed ? const [] : AppShadows.tinted(c.cta, strength: 0.32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
                )
              else
                Icon(
                  subscribed ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
                  size: 20,
                  color: fg,
                ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.labelLarge?.copyWith(color: fg, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}