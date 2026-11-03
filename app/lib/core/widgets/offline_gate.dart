import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n_extensions.dart';
import '../network/connectivity_provider.dart';
import 'state_views.dart';

/// Internet yo'q bo'lsa, ilovaning butun ekrani yopiladi va ulanish qaytganda o'zi ochiladi.
class OfflineGate extends ConsumerWidget {
  const OfflineGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offline = ref.watch(isOfflineProvider).valueOrNull ?? false;

    return Stack(
      children: [
        child,
        if (offline)
          Positioned.fill(
            child: Scaffold(
              body: SafeArea(
                child: ErrorState(
                  title: context.l10n.errorNetworkTitle,
                  message: context.l10n.errorNetworkMessage,
                  retryLabel: context.l10n.commonRetry,
                  onRetry: () => ref.invalidate(isOfflineProvider),
                ),
              ),
            ),
          ),
      ],
    );
  }
}