import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/core/responsive/responsive_layout.dart';
import 'package:learn_flutter_api/core/widgets/app_button.dart';
import 'package:learn_flutter_api/core/widgets/app_card.dart';
import 'package:learn_flutter_api/core/widgets/app_error_view.dart';
import 'package:learn_flutter_api/core/widgets/app_loading.dart';
import 'package:learn_flutter_api/core/widgets/app_scaffold.dart';
import 'package:learn_flutter_api/core/widgets/app_status_indicator.dart';
import 'package:learn_flutter_api/core/widgets/candle_chart.dart';
import 'package:learn_flutter_api/core/widgets/ohlc_summary.dart';
import 'package:learn_flutter_api/providers/candle_provider.dart';
import 'package:learn_flutter_api/providers/settings_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    ref.listenManual(refreshIntervalProvider, (previous, next) {
      _scheduleRefresh(next);
    });
    _scheduleRefresh(ref.read(refreshIntervalProvider));
  }

  // This timer keeps the dashboard in sync with the configured polling interval
  // so the screen keeps fetching the latest server-side candle without manual input.
  void _scheduleRefresh(Duration? interval) {
    _refreshTimer?.cancel();
    if (interval != null) {
      _refreshTimer = Timer.periodic(
        interval,
        (_) => ref.read(candleProvider.notifier).refresh(),
      );
    }
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final candleState = ref.watch(candleProvider);
    final controller = ref.read(candleProvider.notifier);
    final isRefreshing = candleState.isLoading;
    return AppScaffold(
      title: 'Stock dashboard',
      route: '/',
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: AppButton(
            label: 'Refresh',
            icon: Icons.refresh_rounded,
            isLoading: isRefreshing,
            onPressed: () => controller.refresh(),
          ),
        ),
      ],
      child: ResponsiveLayout(
        builder: (context, size) => candleState.when(
          loading: () => const AppLoading(),
          error: (error, stackTrace) => AppErrorView(
            message: error.toString(),
            onRetry: () => controller.refresh(),
          ),
          data: (snapshot) {
            // The dashboard switches between a wide layout and a stacked mobile layout
            // depending on the current screen width, while keeping the single candle
            // view consistent across both states.
            final isWide = size != ScreenSize.mobile;
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PageHeading(
                    lastUpdated: snapshot.fetchedAt,
                    isRefreshing: isRefreshing,
                  ),
                  const SizedBox(height: DesignTokens.space5),
                  if (isWide)
                    _DesktopDashboard(snapshot: snapshot)
                  else
                    _MobileDashboard(snapshot: snapshot),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({required this.lastUpdated, required this.isRefreshing});

  final DateTime lastUpdated;
  final bool isRefreshing;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16,
    runSpacing: 12,
    crossAxisAlignment: WrapCrossAlignment.center,
    alignment: WrapAlignment.spaceBetween,
    children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market snapshot',
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 5),
          Text(
            'One live candle from your connected API',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppStatusIndicator(isOnline: true),
          const SizedBox(width: 12),
          Text(
            isRefreshing
                ? 'Updating...'
                : 'Updated ${DateFormat.jm().format(lastUpdated)}',
            style: Theme.of(context).textTheme.labelMedium,
          ),
        ],
      ),
    ],
  );
}

class _DesktopDashboard extends StatelessWidget {
  const _DesktopDashboard({required this.snapshot});

  final CandleSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(flex: 7, child: _ChartCard(snapshot: snapshot)),
      const SizedBox(width: DesignTokens.space4),
      Expanded(flex: 3, child: _SummaryCard(snapshot: snapshot)),
    ],
  );
}

class _MobileDashboard extends StatelessWidget {
  const _MobileDashboard({required this.snapshot});

  final CandleSnapshot snapshot;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _ChartCard(snapshot: snapshot),
      const SizedBox(height: DesignTokens.space4),
      _SummaryCard(snapshot: snapshot),
    ],
  );
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.snapshot});

  final CandleSnapshot snapshot;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest candle',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('EEE, MMM d · HH:mm:ss')
                        .format(snapshot.candle.time.toLocal()),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Open candle details',
              onPressed: () => context.go('/candle'),
              icon: const Icon(Icons.open_in_new_rounded),
            ),
          ],
        ),
        const SizedBox(height: 14),
        CandleChart(candle: snapshot.candle),
        const SizedBox(height: 4),
        Text(
          'Single candle returned by the server · not historical data',
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
        ),
      ],
    ),
  );
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.snapshot});

  final CandleSnapshot snapshot;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'OHLC summary',
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 22),
        OhlcSummary(candle: snapshot.candle),
        const SizedBox(height: 18),
        const Divider(height: 1),
        const SizedBox(height: 16),
        Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Each refresh requests a new server-generated candle.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
