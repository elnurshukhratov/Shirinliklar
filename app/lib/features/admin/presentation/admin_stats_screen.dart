import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/error_messages.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/state_views.dart';
import '../application/admin_stats_providers.dart';
import '../domain/admin_stats_models.dart';

/// Do'kon egasi uchun statistika: savdo (kunlik/oylik), eng ko'p sotiladigan shirinliklar, mijozlar.
class AdminStatsScreen extends StatelessWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.adminStatsTitle),
          bottom: TabBar(
            tabs: [
              Tab(text: l10n.adminStatsTabSales),
              Tab(text: l10n.adminStatsTabTop),
              Tab(text: l10n.adminStatsTabCustomers),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_SalesTab(), _TopTab(), _CustomersTab()],
        ),
      ),
    );
  }
}

Widget _asyncBody<T>(
  BuildContext context,
  WidgetRef ref,
  AsyncValue<T> value,
  ProviderBase<AsyncValue<T>> provider,
  Widget Function(T data) builder,
) {
  final l10n = context.l10n;
  return value.when(
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (e, _) {
      final err = describeError(l10n, e);
      return ErrorState(
        title: err.title,
        message: err.message,
        retryLabel: l10n.commonRetry,
        onRetry: () => ref.invalidate(provider),
      );
    },
    data: builder,
  );
}

// ---------------------------------------------------------------- Savdo

class _SalesTab extends ConsumerStatefulWidget {
  const _SalesTab();

  @override
  ConsumerState<_SalesTab> createState() => _SalesTabState();
}

class _SalesTabState extends ConsumerState<_SalesTab> {
  bool _monthly = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final value = ref.watch(adminStatsOverviewProvider);

    return _asyncBody<StatsOverview>(
      context,
      ref,
      value,
      adminStatsOverviewProvider,
      (data) {
        final points = _monthly ? data.monthly : data.daily;
        final total = points.fold<double>(0, (s, p) => s + p.revenue);
        final orders = points.fold<int>(0, (s, p) => s + p.orders);

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsOverviewProvider);
            await ref.read(adminStatsOverviewProvider.future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              Row(
                children: [
                  Expanded(child: _SummaryCard(label: l10n.adminStatsToday, point: data.today)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: _SummaryCard(label: l10n.adminStatsThisMonth, point: data.month)),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              SegmentedButton<bool>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(value: false, label: Text(l10n.adminStatsDaily)),
                  ButtonSegment(value: true, label: Text(l10n.adminStatsMonthly)),
                ],
                selected: {_monthly},
                onSelectionChanged: (s) => setState(() => _monthly = s.first),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _monthly ? l10n.adminStatsLastMonths(points.length) : l10n.adminStatsLastDays(points.length),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: 4),
                    Text(context.formatPrice(total), style: Theme.of(context).textTheme.titleLarge),
                    Text(
                      l10n.adminStatsOrdersCount(orders),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    _BarChart(points: points, monthly: _monthly),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l10n.adminStatsNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: context.colors.textSecondary, height: 1.4),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.label, required this.point});

  final String label;
  final SalesPoint point;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.bodySmall?.copyWith(color: c.textSecondary)),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(context.formatPrice(point.revenue), style: text.titleMedium),
          ),
          const SizedBox(height: 2),
          Text(
            context.l10n.adminStatsOrdersCount(point.orders),
            style: text.bodySmall?.copyWith(color: c.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Oddiy ustunli diagramma: bitta rang, ustun balandligi eng katta qiymatga nisbatan.
class _BarChart extends StatelessWidget {
  const _BarChart({required this.points, required this.monthly});

  final List<SalesPoint> points;
  final bool monthly;

  static const double _plotHeight = 140;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final tag = Localizations.localeOf(context).toLanguageTag();
    final label = monthly ? DateFormat.MMM(tag) : DateFormat.d(tag);
    final max = points.fold<double>(0, (m, p) => p.revenue > m ? p.revenue : m);
    final duration = AppMotion.reduced(context) ? Duration.zero : AppMotion.slow;

    return SizedBox(
      height: _plotHeight + 24,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (final p in points)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Tooltip(
                  message: '${context.formatDate(p.date)}\n${context.formatPrice(p.revenue)}',
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedContainer(
                        duration: duration,
                        curve: AppMotion.curve,
                        height: max == 0 ? 3 : (_plotHeight * (p.revenue / max)).clamp(3, _plotHeight).toDouble(),
                        decoration: BoxDecoration(
                          color: p.revenue == 0 ? c.border : c.primary,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 16,
                        child: FittedBox(
                          child: Text(label.format(p.date), style: text.labelSmall?.copyWith(color: c.textSecondary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------- Eng ko'p sotilgan

class _TopTab extends ConsumerWidget {
  const _TopTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final value = ref.watch(adminStatsOverviewProvider);

    return _asyncBody<StatsOverview>(
      context,
      ref,
      value,
      adminStatsOverviewProvider,
      (data) {
        final top = data.topProducts;
        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(adminStatsOverviewProvider);
            await ref.read(adminStatsOverviewProvider.future);
          },
          child: top.isEmpty
              ? ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: 360,
                      child: EmptyState(title: l10n.adminStatsTopEmpty, message: l10n.adminStatsTopEmptyHint),
                    ),
                  ],
                )
              : ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  itemCount: top.length,
                  separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, i) {
                    final p = top[i];
                    return AppCard(
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.secondary, shape: BoxShape.circle),
                            child: Text('${i + 1}', style: text.titleSmall),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                                const SizedBox(height: 2),
                                Text(
                                  context.formatPrice(p.revenue),
                                  style: text.bodySmall?.copyWith(color: c.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(l10n.piecesCount(p.quantity), style: text.titleSmall?.copyWith(color: c.primary)),
                        ],
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}

// ------------------------------------------------------------------ Mijozlar

class _CustomersTab extends ConsumerWidget {
  const _CustomersTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final c = context.colors;
    final text = Theme.of(context).textTheme;
    final value = ref.watch(adminCustomersProvider);

    return _asyncBody<List<CustomerStat>>(
      context,
      ref,
      value,
      adminCustomersProvider,
      (list) => RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminCustomersProvider);
          await ref.read(adminCustomersProvider.future);
        },
        child: list.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: 360, child: EmptyState(title: l10n.adminStatsCustomersEmpty)),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                itemCount: list.length,
                separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  final m = list[i];
                  final name = m.fullName.isNotEmpty ? m.fullName : m.email;
                  final contact = [if (m.fullName.isNotEmpty) m.email, if (m.phone != null) m.phone!].join(' · ');
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis, style: text.titleSmall),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Text(context.formatPrice(m.spent), style: text.titleSmall?.copyWith(color: c.primary)),
                          ],
                        ),
                        if (contact.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            contact,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodySmall?.copyWith(color: c.textSecondary),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          m.lastOrderAt == null
                              ? l10n.adminStatsNoOrders
                              : '${l10n.adminStatsOrdersCount(m.orders)} · ${l10n.adminStatsLastOrder(context.formatDate(m.lastOrderAt!))}',
                          style: text.bodySmall?.copyWith(color: c.textSecondary),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
