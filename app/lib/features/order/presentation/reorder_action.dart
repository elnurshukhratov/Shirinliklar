import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../cart/application/cart_controller.dart';
import '../application/order_providers.dart';

/// «Qayta buyurtma»: buyurtmadagi mahsulotlarni hozirgi narx va mavjudlik bilan savatga qaytaradi
/// va savatni ochadi. Tugagan mahsulotlar qo'shilmaydi, bu haqda xabar beriladi.
Future<void> reorderToCart(BuildContext context, WidgetRef ref, String orderId) async {
  final l10n = context.l10n;
  final lang = Localizations.localeOf(context).languageCode;
  final messenger = ScaffoldMessenger.of(context);
  final router = GoRouter.of(context);

  try {
    final result = await ref.read(orderRepositoryProvider).reorder(orderId);
    if (!context.mounted) return;

    final applied = result.items.isEmpty
        ? (added: 0, limited: false)
        : ref.read(cartProvider.notifier).addMany(result.items);

    messenger.hideCurrentSnackBar();
    if (applied.added == 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.orderReorderNothing)));
      return;
    }

    final String message;
    if (result.unavailable.isNotEmpty) {
      final names = result.unavailable.map((e) => e.forLanguage(lang)).join(', ');
      message = l10n.orderReorderPartial(names);
    } else if (result.reduced || applied.limited) {
      message = l10n.orderReorderAdjusted;
    } else {
      message = l10n.orderReorderDone;
    }
    messenger.showSnackBar(SnackBar(content: Text(message)));
    router.push(AppRoutes.cart);
  } catch (e) {
    messenger.showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
  }
}
