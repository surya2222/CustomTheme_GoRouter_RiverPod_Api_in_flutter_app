/// Flutter के UI widgets और Material Design components।
library;

import 'package:flutter/material.dart';

/// Riverpod के ConsumerWidget और WidgetRef के लिए।
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// DateTime को readable date/time format में बदलने के लिए।
import 'package:intl/intl.dart';

/// App की centralized spacing और design values।
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

/// Reusable card widget।
import 'package:learn_flutter_api/core/widgets/app_card.dart';

/// Error message और retry button दिखाने वाला widget।
import 'package:learn_flutter_api/core/widgets/app_error_view.dart';

/// Loading indicator दिखाने वाला widget।
import 'package:learn_flutter_api/core/widgets/app_loading.dart';

/// App का common layout और navigation उपलब्ध कराता है।
import 'package:learn_flutter_api/core/widgets/app_scaffold.dart';

/// Open, High, Low और Close prices दिखाता है।
import 'package:learn_flutter_api/core/widgets/ohlc_summary.dart';

/// Candle data प्राप्त करने वाला Riverpod provider।
import 'package:learn_flutter_api/providers/candle_provider.dart';

/// Candle Details Screen:
/// Server से प्राप्त latest candle की जानकारी दिखाती है।
class CandleDetailsScreen extends ConsumerWidget {
  const CandleDetailsScreen({super.key});

  /// build() Flutter को बताता है कि UI कैसे बनानी है।
  ///
  /// context = Theme, navigation और widget tree की जानकारी।
  /// ref     = Riverpod providers से interact करने का माध्यम।
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Provider की वर्तमान state को सुनें।
    // State बदलने पर यह widget दोबारा build हो सकता है।
    final candle = ref.watch(candleProvider);

    // Provider का notifier प्राप्त करें।
    // इसका उपयोग refresh action चलाने के लिए किया जाएगा।
    // ref.read() इस line में provider को watch नहीं करता।
    final controller = ref.read(candleProvider.notifier);

    // App का common scaffold:
    // title, navigation route और मुख्य content निर्धारित करता है।
    return AppScaffold(
      title: 'Candle details',
      route: '/candle',

      // child में screen का मुख्य content दिया जाता है।
      child: candle.when(
        // State 1: Data अभी load हो रहा है।
        // AppLoading reusable loading UI दिखाता है।
        loading: () => const AppLoading(),

        // State 2: Data प्राप्त करने में error आया।
        // Error message और retry action दिखाएँ।
        error: (error, stackTrace) => AppErrorView(
          message: error.toString(),

          // Retry button दबाने पर provider को refresh करें।
          onRetry: () => controller.refresh(),
        ),

        // State 3: Data सफलतापूर्वक प्राप्त हो गया।
        // snapshot में provider द्वारा दिया गया data है।
        data: (snapshot) => SingleChildScrollView(
          child: AppCard(
            child: Column(
              // सभी widgets को बाईं ओर align करें।
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                // Section का title।
                Text(
                  'Latest server candle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),

                // Centralized spacing token।
                const SizedBox(height: DesignTokens.space2),

                // Candle का timestamp readable format में दिखाएँ।
                Text(
                  DateFormat('EEEE, MMMM d, y · HH:mm:ss')
                      .format(snapshot.candle.time.toLocal()),
                ),

                // Title/date और OHLC values के बीच spacing।
                const SizedBox(height: DesignTokens.space5),

                // Candle के Open, High, Low और Close prices दिखाएँ।
                OhlcSummary(candle: snapshot.candle),

                // OHLC summary और information text के बीच spacing।
                const SizedBox(height: DesignTokens.space5),

                // User को endpoint के व्यवहार की जानकारी।
                Text(
                  'This endpoint returns one newly generated candle per request. '
                  'No historical series is provided.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
