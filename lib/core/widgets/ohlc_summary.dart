// FontFeature.tabularFigures() के लिए FontFeature import करता है।

import 'package:flutter/material.dart';
// Flutter के UI widgets, TextStyle, Wrap, Column और अन्य components।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';
// Centralized design values, जैसे OHLC value की width और candle colors।

import 'package:learn_flutter_api/data/models/candle.dart';

// Candle model जिसमें open, high, low और close prices उपलब्ध हैं।

// एक candle की चारों OHLC values दिखाने वाला reusable widget।
class OhlcSummary extends StatelessWidget {
  // Constructor में candle data देना जरूरी है।
  const OhlcSummary({required this.candle, super.key});

  // जिस candle की prices दिखानी हैं, उसका data।
  final Candle candle;

  @override
  Widget build(BuildContext context) {
    // Close >= Open होने पर candle bullish मानी जाती है।
    final isBullish = candle.close >= candle.open;

    // Bullish होने पर हरा, bearish होने पर लाल रंग।
    final accent = isBullish
        ? DesignTokens.chartBullish
        : DesignTokens.chartBearish;

    // Wrap बच्चों को horizontal direction में रखता है।
    // जगह कम होने पर अगले बच्चों को अगली line में भेज देता है।
    return Wrap(
      // एक ही line में items के बीच horizontal gap।
      spacing: 20,

      // अलग-अलग lines के बीच vertical gap।
      runSpacing: 18,

      children: [
        // OPEN का रंग default text color से लिया जाएगा।
        _Value(label: 'OPEN', value: candle.open, color: null),

        // HIGH की value को bullish/bearish accent color में दिखाएँ।
        _Value(label: 'HIGH', value: candle.high, color: accent),

        // LOW की value को भी accent color में दिखाएँ।
        _Value(label: 'LOW', value: candle.low, color: accent),

        // CLOSE की value को भी accent color में दिखाएँ।
        _Value(label: 'CLOSE', value: candle.close, color: accent),
      ],
    );
  }
}

// एक label और उसकी numeric value दिखाने वाला private widget।
// इसे इसी Dart library के बाहर सीधे access नहीं किया जा सकता।
class _Value extends StatelessWidget {
  // Label, numeric value और optional color constructor से मिलते हैं।
  const _Value({required this.label, required this.value, required this.color});

  // उदाहरण: OPEN, HIGH, LOW या CLOSE।
  final String label;

  // संबंधित price।
  final double value;

  // Value का optional रंग। null होने पर default text color इस्तेमाल होगा।
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    // हर value item की width DesignTokens से निर्धारित होती है।
    width: DesignTokens.ohlcValueWidth,

    // Label और price को vertical direction में रखता है।
    child: Column(
      // सभी बच्चों को बाईं तरफ align करता है।
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        // OPEN/HIGH/LOW/CLOSE का छोटा label।
        Text(
          label,

          // Theme से labelSmall style लेकर उसे customize करते हैं।
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            // Label का रंग current theme से लिया जाता है।
            color: Theme.of(context).colorScheme.onSurfaceVariant,

            // अक्षरों के बीच थोड़ा extra अंतर।
            letterSpacing: 1.1,

            // Label को bold बनाता है।
            fontWeight: FontWeight.w700,
          ),
        ),

        // Label और price के बीच 6 pixels की vertical जगह।
        const SizedBox(height: 6),

        // Numeric price दिखाता है।
        Text(
          // Price को दो decimal places में format करता है।
          // उदाहरण: 25432.50
          value.toStringAsFixed(2),

          // Theme के titleMedium style को customize करते हैं।
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            // दिए गए accent color का उपयोग करता है।
            // null होने पर inherited/default text color रहेगा।
            color: color,

            // Price को bold बनाता है।
            fontWeight: FontWeight.w700,

            // सभी digits की width समान रखता है।
            // इससे अलग-अलग prices की alignment बेहतर होती है।
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}
