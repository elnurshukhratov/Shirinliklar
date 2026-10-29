import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/state_views.dart';
import '../application/order_providers.dart';
import '../domain/my_order_models.dart';
import '../domain/order_models.dart';
import '../domain/payment_status.dart';
import 'widgets/animated_check.dart';

enum _Phase { ready, starting, waiting, checking, unconfirmed }

/// Onlayn to'lov: to'lov sahifasini ochadi, ilovaga qaytganda holatni serverdan tekshiradi.
/// Oldindan to'lash (buyurtma berilgach) ham, olayotganda to'lash ham shu ekran orqali.
class PaymentScreen extends ConsumerStatefulWidget {
  const PaymentScreen({super.key, required this.orderId});

  final String orderId;

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> with WidgetsBindingObserver {
  _Phase _phase = _Phase.ready;
  Object? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Mijoz to'lov sahifasidan ilovaga qaytdi.
    if (state == AppLifecycleState.resumed && _phase == _Phase.waiting) _verify();
  }

  Future<void> _start() async {
    final l10n = context.l10n;
    setState(() {
      _phase = _Phase.starting;
      _error = null;
      _message = null;
    });
    try {
      final url = await ref.read(orderRepositoryProvider).startPayment(widget.orderId);
      final opened = await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      if (!mounted) return;
      setState(() {
        _phase = opened ? _Phase.waiting : _Phase.ready;
        if (!opened) _message = l10n.payCannotOpen;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.ready;
        _error = e;
      });
    }
  }

  /// To'lov tizimi tasdig'i bir necha soniya kechikishi mumkin, shuning uchun bir necha marta so'raymiz.
  Future<void> _verify() async {
    setState(() => _phase = _Phase.checking);
    final repo = ref.read(orderRepositoryProvider);
    for (var i = 0; i < 4; i++) {
      try {
        final MyOrder order = await repo.myOrder(widget.orderId);
        if (!mounted) return;
        if (order.paymentStatus == PaymentStatus.paid) {
          ref.invalidate(myOrdersProvider);
          ref.invalidate(myOrderDetailProvider(widget.orderId));
          return;
        }
      } catch (_) {
        // Tarmoq xatosi: keyingi urinishda qayta so'raymiz.
      }
      if (i < 3) await Future<void>.delayed(const Duration(seconds: 2));
      if (!mounted) return;
    }
    setState(() => _phase = _Phase.unconfirmed);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = ref.watch(myOrderDetailProvider(widget.orderId));
    final order = detail.valueOrNull;

    Widget body;
    if (order == null) {
      if (detail.hasError) {
        final err = describeError(l10n, detail.error!);
        body = ErrorState(
          title: err.title,
          message: err.message,
          retryLabel: l10n.commonRetry,
          onRetry: () => ref.invalidate(myOrderDetailProvider(widget.orderId)),
        );
      } else {
        body = const Center(child: CircularProgressIndicator());
      }
    } else if (order.paymentStatus == PaymentStatus.paid) {
      body = _PayView(
        header: const AnimatedCheck(),
        title: l10n.paySuccessTitle,
        message: l10n.paySuccessMessage,
        actions: [
          AppButton(
            label: l10n.commonOk,
            onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
          ),
        ],
      );
    } else if (order.status == OrderStatus.cancelled || order.status == OrderStatus.delivered) {
      body = ErrorState(
        title: l10n.errorGenericTitle,
        message: l10n.errorPaymentNotAllowed,
        icon: Icons.credit_card_off_outlined,
      );
    } else {
      body = _buildFlow(context, order);
    }

    return Scaffold(appBar: AppBar(title: Text(l10n.payTitle)), body: body);
  }

  Widget _buildFlow(BuildContext context, MyOrder order) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    switch (_phase) {
      case _Phase.starting:
        return _PayView(spinner: true, title: l10n.payOpening);
      case _Phase.checking:
        return _PayView(spinner: true, title: l10n.payChecking);
      case _Phase.waiting:
        return _PayView(
          icon: Icons.hourglass_top_rounded,
          title: l10n.payWaitingTitle,
          message: l10n.payWaitingMessage,
          actions: [
            AppButton(label: l10n.payCheck, onPressed: _verify),
            AppButton(label: l10n.payRetry, variant: AppButtonVariant.text, onPressed: _start),
          ],
        );
      case _Phase.unconfirmed:
        return _PayView(
          icon: Icons.error_outline_rounded,
          tint: c.error,
          title: l10n.payPendingTitle,
          message: l10n.payPendingMessage,
          actions: [
            AppButton(label: l10n.payCheck, onPressed: _verify),
            AppButton(label: l10n.payRetry, variant: AppButtonVariant.secondary, onPressed: _start),
          ],
        );
      case _Phase.ready:
        final errorText = _error != null ? describeError(l10n, _error!).message : _message;
        return _PayView(
          icon: Icons.credit_card_rounded,
          title: context.formatPrice(order.total),
          message: l10n.payReadyMessage,
          extra: errorText == null
              ? null
              : Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Text(
                    errorText,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(color: c.error),
                  ),
                ),
          actions: [
            AppButton(
              label: _error != null ? l10n.payRetry : l10n.payProceed,
              icon: Icons.lock_outline_rounded,
              onPressed: _start,
            ),
          ],
        );
    }
  }
}

class _PayView extends StatelessWidget {
  const _PayView({
    this.icon,
    this.header,
    this.spinner = false,
    this.tint,
    required this.title,
    this.message,
    this.extra,
    this.actions = const [],
  });

  final IconData? icon;
  final Widget? header;
  final bool spinner;
  final Color? tint;
  final String title;
  final String? message;
  final Widget? extra;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (header != null)
              header!
            else if (spinner)
              const SizedBox(width: 48, height: 48, child: CircularProgressIndicator())
            else if (icon != null)
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: c.secondary, shape: BoxShape.circle),
                child: Icon(icon, size: 40, color: tint ?? c.primary),
              ),
            const SizedBox(height: AppSpacing.xl),
            Text(title, textAlign: TextAlign.center, style: text.headlineSmall),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: text.bodyMedium?.copyWith(color: c.textSecondary, height: 1.4),
              ),
            ],
            if (extra != null) extra!,
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xl),
              for (var i = 0; i < actions.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.sm),
                actions[i],
              ],
            ],
          ],
        ),
      ),
    );
  }
}
