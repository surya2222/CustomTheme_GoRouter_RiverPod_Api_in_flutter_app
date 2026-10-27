import 'package:flutter/material.dart';

// Flutter के Material Design components और Color class का उपयोग करने के लिए।

// abstract final class:
// यह एक utility class है, जिसका object नहीं बनाया जा सकता
// और जिसे दूसरी class extend या implement नहीं कर सकती।
abstract final class DesignTokens {
  // ─────────────────────────────────────────────
  // 1. RESPONSIVE DESIGN BREAKPOINTS
  // ─────────────────────────────────────────────

  // 600 logical pixels से कम width वाले layout के लिए
  // mobile layout चुनने में उपयोग किया जा सकता है।
  static const mobileBreakpoint = 600.0;

  // 1024 logical pixels से कम width तक tablet layout
  // निर्धारित करने में उपयोग किया जा सकता है।
  static const tabletBreakpoint = 1024.0;

  // Main content की maximum width 1440 logical pixels।
  // बड़ी screen पर content को बहुत अधिक फैलने से रोकता है।
  static const contentMaxWidth = 1440.0;

  // ─────────────────────────────────────────────
  // 2. CHART DIMENSIONS
  // ─────────────────────────────────────────────

  // Candlestick chart की निर्धारित height।
  static const chartHeight = 280.0;

  // Chart के price axis के लिए निर्धारित width।
  // उदाहरण: दाईं तरफ price labels दिखाने के लिए।
  static const chartAxisWidth = 54.0;

  // OHLC values दिखाने वाले section की निर्धारित width।
  // OHLC = Open, High, Low, Close।
  static const ohlcValueWidth = 92.0;

  // ─────────────────────────────────────────────
  // 3. SPACING SCALE
  // ─────────────────────────────────────────────

  // सबसे छोटी spacing: 4 logical pixels।
  // उदाहरण: icon और text के बीच छोटा gap।
  static const space1 = 4.0;

  // Spacing: 8 logical pixels।
  // उदाहरण: छोटे UI elements के बीच gap।
  static const space2 = 8.0;

  // Spacing: 12 logical pixels।
  // उदाहरण: form fields या widgets के बीच gap।
  static const space3 = 12.0;

  // Spacing: 16 logical pixels।
  // उदाहरण: सामान्य padding।
  static const space4 = 16.0;

  // Spacing: 24 logical pixels।
  // उदाहरण: cards के बीच या section की padding।
  static const space5 = 24.0;

  // Spacing: 32 logical pixels।
  // उदाहरण: बड़े sections के बीच दूरी।
  static const space6 = 32.0;

  // ─────────────────────────────────────────────
  // 4. BORDER RADIUS
  // ─────────────────────────────────────────────

  // बड़े cards के corners को 20 logical pixels तक गोल करता है।
  // AppTheme में CardThemeData के अंदर उपयोग किया जा सकता है।
  static const cardRadius = 20.0;

  // छोटे components, जैसे TextField के corners का radius।
  static const smallRadius = 12.0;

  // ─────────────────────────────────────────────
  // 5. CHART COLORS
  // ─────────────────────────────────────────────

  // Bullish candle का रंग: हरा।
  // सामान्यतः बढ़ती कीमत या positive movement दिखाने के लिए।
  static const chartBullish = Color(0xFF16A673);

  // Bearish candle का रंग: लाल।
  // सामान्यतः गिरती कीमत या negative movement दिखाने के लिए।
  static const chartBearish = Color(0xFFE05260);

  // Chart grid lines का रंग।
  // Grid lines chart में price और time को पढ़ने में मदद करती हैं।
  static const chartGrid = Color(0xFF8A96A8);

  // ─────────────────────────────────────────────
  // 6. APP BACKGROUND COLORS
  // ─────────────────────────────────────────────

  // Light Theme में page background का हल्का gray color।
  // AppTheme में scaffoldBackgroundColor के लिए उपयोग होता है।
  static const lightBackground = Color(0xFFF5F7FA);

  // Dark Theme में page background का गहरा navy color।
  // Dark Mode में आंखों के लिए आरामदायक contrast बनाने में मदद करता है।
  static const darkBackground = Color(0xFF10151D);
}
