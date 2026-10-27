import 'package:fl_chart/fl_chart.dart';
// fl_chart package से CandlestickChart, chart data,
// axis titles, grid lines और touch tooltips मिलते हैं।

import 'package:flutter/material.dart';
// Flutter के UI widgets और styling के लिए।

import 'package:intl/intl.dart';
// DateTime को readable date format में बदलने के लिए।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';
// Chart की height, colors और axis width जैसे common design values।

import 'package:learn_flutter_api/data/models/candle.dart';

// Candle model जिसमें open, high, low, close और time उपलब्ध हैं।

// एक candle के data को chart में दिखाने वाला reusable widget।
class CandleChart extends StatelessWidget {
  // Constructor में candle data देना जरूरी है।
  const CandleChart({required this.candle, super.key});

  // API/model से प्राप्त एक candle की जानकारी।
  final Candle candle;

  @override
  Widget build(BuildContext context) {
    // Close, Open के बराबर या उससे अधिक है तो bullish candle।
    final isBullish = candle.close >= candle.open;

    // Bullish होने पर हरा, अन्यथा लाल रंग चुनते हैं।
    final color = isBullish
        ? DesignTokens.chartBullish
        : DesignTokens.chartBearish;

    // Candle की पूरी price range निकालते हैं।
    // Range = High - Low।
    final range = candle.high - candle.low;

    // Chart के ऊपर और नीचे अतिरिक्त खाली जगह निर्धारित करते हैं।
    //
    // यदि range शून्य है, तो high की absolute value का 2% उपयोग करें।
    // अन्यथा actual range का 25% उपयोग करें।
    //
    // इससे chart की candle price axis की सीमाओं से चिपकी नहीं रहती।
    final padding = range == 0 ? candle.high.abs() * 0.02 : range * 0.25;

    // Chart के labels का text color Theme से प्राप्त करते हैं।
    //
    // यदि labelSmall style का color null हो, तो
    // colorScheme.onSurfaceVariant fallback के रूप में उपयोग होगा।
    final chartText =
        Theme.of(context).textTheme.labelSmall?.color ??
        Theme.of(context).colorScheme.onSurfaceVariant;

    // Candle की तारीख को 'Oct 26' जैसे format में दिखाने की तैयारी।
    final dateFormat = DateFormat('MMM d');

    // Candlestick chart और उसका configuration तैयार करते हैं।
    final chart = CandlestickChart(
      CandlestickChartData(
        // Chart में candle की price information।
        candlestickSpots: [
          CandlestickSpot(
            // Horizontal axis पर candle का स्थान।
            // यहाँ केवल एक candle है, इसलिए x = 1।
            x: 1,

            // Candle की चार मुख्य prices।
            open: candle.open,
            high: candle.high,
            low: candle.low,
            close: candle.close,
          ),
        ],

        // Horizontal axis की न्यूनतम और अधिकतम सीमा।
        // Candle x = 1 पर है, इसलिए 0 से 2 का range दिया गया है।
        minX: 0,
        maxX: 2,

        // Vertical price axis की न्यूनतम और अधिकतम सीमा।
        // Extra padding candle के ऊपर और नीचे space देती है।
        minY: candle.low - padding,
        maxY: candle.high + padding,

        // Chart की grid lines की configuration।
        gridData: FlGridData(
          // Vertical grid lines नहीं दिखानी हैं।
          drawVerticalLine: false,

          // प्रत्येक horizontal grid line कैसे दिखेगी।
          getDrawingHorizontalLine: (value) => FlLine(
            // Grid का हल्का रंग और 18% opacity।
            color: DesignTokens.chartGrid.withValues(alpha: 0.18),

            // Line की मोटाई।
            strokeWidth: 1,

            // Dashed line: 4 pixels की line और 4 pixels का gap।
            dashArray: [4, 4],
          ),
        ),

        // Chart के चारों ओर default border छिपाता है।
        borderData: FlBorderData(show: false),

        // चारों sides के axis titles नियंत्रित करता है।
        titlesData: FlTitlesData(
          // ऊपर के axis labels छिपाएँ।
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // दाईं तरफ price labels दिखाएँ।
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              // Price labels enable हैं।
              showTitles: true,

              // Price labels के लिए reserved width।
              reservedSize: DesignTokens.chartAxisWidth,

              // हर price value के लिए label widget बनता है।
              getTitlesWidget: (value, meta) => Padding(
                // Label के बाईं तरफ 8 pixels की जगह।
                padding: const EdgeInsets.only(left: 8),

                child: Text(
                  // Price को दो decimal places में दिखाएँ।
                  // उदाहरण: 25432.50
                  value.toStringAsFixed(2),

                  // Theme से प्राप्त text color और 10 font size।
                  style: TextStyle(color: chartText, fontSize: 10),
                ),
              ),
            ),
          ),

          // बाईं तरफ के price labels छिपाएँ।
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),

          // नीचे horizontal axis पर candle की date दिखाएँ।
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,

              // हर 1 unit पर axis tick का interval।
              interval: 1,

              // नीचे के labels के लिए 30 pixels की जगह।
              reservedSize: 30,

              // हर horizontal axis value के लिए widget बनता है।
              getTitlesWidget: (value, meta) => value == 1
                  ? Padding(
                      // Date के ऊपर 8 pixels की जगह।
                      padding: const EdgeInsets.only(top: 8),

                      child: Text(
                        // Candle का local time लेकर date format करें।
                        // उदाहरण: Oct 26
                        dateFormat.format(candle.time.toLocal()),

                        style: TextStyle(color: chartText, fontSize: 11),
                      ),
                    )
                  // x = 1 के अलावा किसी value पर label न दिखाएँ।
                  : const SizedBox.shrink(),
            ),
          ),
        ),

        // Candle को touch करने पर क्या होगा, यह निर्धारित करता है।
        candlestickTouchData: CandlestickTouchData(
          enabled: true,

          // Touch location से candle select करने की threshold।
          touchSpotThreshold: 16,

          // Candle select होने पर tooltip की configuration।
          touchTooltipData: CandlestickTouchTooltipData(
            // Tooltip में Open, High, Low और Close दिखाएँ।
            getTooltipItems: (painter, spot, index) => CandlestickTooltipItem(
              'O ${spot.open.toStringAsFixed(2)}  H ${spot.high.toStringAsFixed(2)}\n'
              'L ${spot.low.toStringAsFixed(2)}  C ${spot.close.toStringAsFixed(2)}',

              // Tooltip का text सफेद और font size 11।
              textStyle: TextStyle(color: Colors.white, fontSize: 11),
            ),

            // Tooltip का background bullish/bearish color होगा।
            getTooltipColor: (spot) => color,
          ),
        ),
      ),

      // Chart changes के animation की अवधि 220 milliseconds।
      duration: const Duration(milliseconds: 220),
    );

    // Chart को निर्धारित height में रखते हैं।
    return SizedBox(
      height: DesignTokens.chartHeight,

      // Screen reader के लिए chart का सारांश।
      child: Semantics(
        label:
            'Single server-provided candlestick, open ${candle.open}, high ${candle.high}, low ${candle.low}, close ${candle.close}',

        // तैयार किया गया candlestick chart दिखाएँ।
        child: chart,
      ),
    );
  }
}
