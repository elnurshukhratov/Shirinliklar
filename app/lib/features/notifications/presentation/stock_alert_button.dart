import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/app_button.dart';
import '../application/push_service.dart';
import '../application/stock_alert_providers.dart';

/// Tugagan mahsulot sahifasida: «Mavjud bo'lganda xabar bering» (qayta bosilsa, obuna bekor bo'ladi).
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
    final async = ref.watch(stockAlertProvider(widget.productId));
    final subscribed = async.valueOrNull ?? false;
    final loading = _busy || (async.isLoading && !async.hasValue);

    return AppButton(
      label: subscribed ? l10n.stockAlertSubscribed : l10n.stockAlertNotifyMe,
      icon: subscribed ? Icons.notifications_active_rounded : Icons.notifications_none_rounded,
      variant: subscribed ? AppButtonVariant.secondary : AppButtonVariant.primary,
      isLoading: loading,
      onPressed: loading ? null : () => _toggle(subscribed),
    );
  }
}
