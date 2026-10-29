import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_chip.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/glass/glass_bottom_bar.dart';
import '../../../core/widgets/state_views.dart';
import '../../auth/application/auth_controller.dart';
import '../../cart/application/cart_controller.dart';
import '../../promo/application/promo_controller.dart';
import '../../store/presentation/store_closed_banner.dart';
import '../application/order_providers.dart';
import '../domain/order_models.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _phone;
  late final TextEditingController _address;
  final _note = TextEditingController();

  FulfillmentType _fulfillment = FulfillmentType.pickup;
  PaymentMethod _payment = PaymentMethod.cash;
  DateTime? _scheduled;
  bool _scheduleError = false;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authControllerProvider).user;
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _phone.dispose();
    _address.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickSchedule(CheckoutOptions options) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);

    final now = DateTime.now();
    final min = now.add(Duration(minutes: options.minLeadMinutes));
    final last = now.add(Duration(days: options.maxDaysAhead));
    final current = _scheduled;
    final initial = current == null || current.isBefore(min) ? min : current;

    final date = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(min.year, min.month, min.day),
      lastDate: last,
    );
    if (date == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: (ctx, child) => MediaQuery(
        data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (time == null || !mounted) return;

    final picked = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    if (picked.isBefore(min) || picked.isAfter(last)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.checkoutScheduleTooSoon(options.minLeadMinutes))));
      return;
    }
    setState(() {
      _scheduled = picked;
      _scheduleError = false;
    });
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final cart = ref.read(cartProvider.notifier);
    final scheduled = _scheduled;

    setState(() => _scheduleError = scheduled == null);
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid || scheduled == null) return;

    setState(() => _submitting = true);
    try {
      final order = await ref.read(orderRepositoryProvider).create(
            items: ref.read(cartProvider).items,
            fulfillment: _fulfillment,
            paymentMethod: _payment,
            scheduledAt: scheduled,
            phone: _phone.text.trim(),
            address: _address.text.trim(),
            note: _note.text.trim(),
            promoCode: ref.read(appliedPromoProvider)?.code,
          );
      cart.clear();
      if (mounted) router.go(AppRoutes.orderSuccess, extra: order);
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(describeError(l10n, e).message)));
      if (e is ApiException && e.message == 'ITEMS_CHANGED') {
        await cart.validate();
        if (mounted) router.pop();
      }
      // Promokod shu orada yaroqsiz bo'lib qolgan bo'lsa, u olib tashlanadi va jami summa yangilanadi.
      if (e is ApiException && e.message.startsWith('PROMO_')) {
        ref.read(appliedPromoProvider.notifier).clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cart = ref.watch(cartProvider);
    final options = ref.watch(checkoutOptionsProvider);

    Widget body() {
      if (cart.items.isEmpty && !_submitting) {
        return EmptyState(
          title: l10n.cartEmptyTitle,
          message: l10n.cartEmptyMessage,
          icon: Icons.shopping_bag_outlined,
          actionLabel: l10n.cartGoToCatalog,
          onAction: () => context.go(AppRoutes.home),
        );
      }
      return options.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) {
          final err = describeError(l10n, e);
          return ErrorState(
            title: err.title,
            message: err.message,
            retryLabel: l10n.commonRetry,
            onRetry: () => ref.invalidate(checkoutOptionsProvider),
          );
        },
        data: (o) => _form(context, o, cart),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.checkoutTitle)),
      body: body(),
    );
  }

  Widget _section(BuildContext context, String title, Widget child) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }

  Widget _form(BuildContext context, CheckoutOptions o, CartState cart) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final lang = Localizations.localeOf(context).languageCode;
    final isDelivery = _fulfillment == FulfillmentType.delivery;
    final fee = isDelivery ? o.deliveryFee : 0.0;
    final discount = ref.watch(appliedPromoProvider)?.discountFor(cart.total) ?? 0.0;
    final total = cart.total - discount + fee;

    String? phoneValidator(String? v) {
      final s = (v ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
      return RegExp(r'^\+?\d{9,15}$').hasMatch(s) ? null : l10n.phoneInvalid;
    }

    return Column(
      children: [
        Expanded(
          child: Form(
            key: _formKey,
            child: ListView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.xl),
              children: [
                if (!o.acceptingOrders)
                  const StoreClosedNotice(margin: EdgeInsets.only(top: AppSpacing.sm)),
                _section(
                  context,
                  l10n.checkoutOrderSection,
                  AppCard(
                    child: Column(
                      children: [
                        for (final item in cart.items)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    '${item.quantity} × ${item.name.forLanguage(lang)}',
                                    style: text.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Text(context.formatPrice(item.lineTotal), style: text.titleSmall),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                _section(context, l10n.checkoutScheduleSection, _scheduleField(context, o)),
                _section(
                  context,
                  l10n.checkoutFulfillmentSection,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppChip(
                        label: l10n.fulfillmentPickup,
                        icon: Icons.storefront_outlined,
                        selected: !isDelivery,
                        onTap: () => setState(() => _fulfillment = FulfillmentType.pickup),
                      ),
                      AppChip(
                        label: l10n.fulfillmentDelivery,
                        icon: Icons.local_shipping_outlined,
                        selected: isDelivery,
                        onTap: () => setState(() => _fulfillment = FulfillmentType.delivery),
                      ),
                    ],
                  ),
                ),
                if (isDelivery)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.md),
                    child: AppTextField(
                      controller: _address,
                      label: l10n.checkoutAddress,
                      hint: l10n.profileAddressHint,
                      textInputAction: TextInputAction.next,
                      maxLines: 2,
                      validator: (v) => (v ?? '').trim().isEmpty ? l10n.fieldRequired : null,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: AppTextField(
                    controller: _phone,
                    label: l10n.profilePhone,
                    hint: l10n.profilePhoneHint,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    validator: phoneValidator,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: AppTextField(
                    controller: _note,
                    label: l10n.checkoutNote,
                    hint: l10n.checkoutNoteHint,
                    maxLines: 3,
                    maxLength: 500,
                  ),
                ),
                _section(
                  context,
                  l10n.checkoutPaymentSection,
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: [
                      AppChip(
                        label: l10n.paymentCash,
                        icon: Icons.payments_outlined,
                        selected: _payment == PaymentMethod.cash,
                        onTap: () => setState(() => _payment = PaymentMethod.cash),
                      ),
                      AppChip(
                        label: l10n.paymentOnline,
                        icon: Icons.credit_card_rounded,
                        selected: _payment == PaymentMethod.online,
                        onTap: () => setState(() => _payment = PaymentMethod.online),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(child: Text(l10n.checkoutSubtotal, style: text.bodyMedium)),
                    Text(context.formatPrice(cart.total), style: text.titleSmall),
                  ],
                ),
                if (discount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.promoDiscountLabel, style: text.bodyMedium)),
                      Text(
                        '−${context.formatPrice(discount)}',
                        style: text.titleSmall?.copyWith(color: c.success),
                      ),
                    ],
                  ),
                ],
                if (isDelivery) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(child: Text(l10n.checkoutDeliveryFee, style: text.bodyMedium)),
                      Text(context.formatPrice(fee), style: text.titleSmall),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        GlassBottomBar(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text(l10n.productTotal, style: text.titleMedium)),
                  AnimatedSwitcher(
                    duration: AppMotion.of(context),
                    transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                    child: Text(
                      context.formatPrice(total),
                      key: ValueKey(total),
                      style: text.titleLarge?.copyWith(color: c.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton(
                label: l10n.checkoutPlaceOrder,
                isLoading: _submitting,
                onPressed: (_submitting || !o.acceptingOrders) ? null : _submit,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _scheduleField(BuildContext context, CheckoutOptions o) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final scheduled = _scheduled;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: AppMotion.of(context),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: AppRadius.borderBase,
            border: Border.all(color: _scheduleError ? c.error : c.border),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: AppRadius.borderBase,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _pickSchedule(o),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
                child: Row(
                  children: [
                    Icon(Icons.event_outlined, color: c.primary),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text(
                        scheduled == null ? l10n.checkoutSchedulePick : context.formatDateTime(scheduled),
                        style: text.bodyLarge?.copyWith(
                          color: scheduled == null ? c.textSecondary : c.textPrimary,
                          fontWeight: scheduled == null ? FontWeight.w400 : FontWeight.w700,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: c.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (_scheduleError)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: AppSpacing.md),
            child: Text(l10n.checkoutScheduleRequired, style: text.bodySmall?.copyWith(color: c.error)),
          ),
      ],
    );
  }
}
