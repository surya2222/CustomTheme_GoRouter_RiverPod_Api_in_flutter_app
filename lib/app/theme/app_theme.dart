import 'package:flutter/material.dart';
// Flutter के Material Design widgets, ThemeData, ColorScheme,
// Colors, TextStyle और अन्य UI components उपलब्ध कराता है।

import 'package:learn_flutter_api/app/theme/design_tokens.dart';

// पूरे app में साझा Design Tokens जैसे background colors
// और border radius को एक ही जगह से उपयोग करने के लिए।

// abstract final class:
// यह class केवल static members रखने के लिए बनाई गई है।
// इसका object नहीं बनाया जा सकता और इसे extend या implement भी नहीं किया जा सकता।
abstract final class AppTheme {
  // Light Theme को एक बार create करके static variable में रखा जाता है।
  // Brightness.light का अर्थ है कि app Light Mode में चलेगा।
  static final light = _createTheme(Brightness.light);

  // Dark Theme को एक बार create करके static variable में रखा जाता है।
  // Brightness.dark का अर्थ है कि app Dark Mode में चलेगा।
  static final dark = _createTheme(Brightness.dark);

  // Private method:
  // "_" से शुरू होने के कारण इसे इसी Dart library के अंदर access किया जा सकता है।
  //
  // Brightness parameter तय करता है कि Light या Dark Theme बनानी है।
  // ThemeData पूरे Flutter app की visual configuration रखता है।
  static ThemeData _createTheme(Brightness brightness) {
    // Check करता है कि दी गई brightness Dark Mode है या नहीं।
    // Dark होने पर true, अन्यथा false मिलेगा।
    final isDark = brightness == Brightness.dark;

    // ColorScheme app के मुख्य रंगों का व्यवस्थित समूह है।
    // seedColor से Flutter संबंधित colors generate करता है।
    // brightness के अनुसार generated colors Light या Dark Mode के अनुकूल होते हैं।
    // surface cards और अन्य surfaces के लिए background color है।
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4969E8), // App का मुख्य नीला रंग।
      brightness: brightness, // Light या Dark color scheme।
      surface: isDark
          ? const Color(0xFF1A212C) // Dark Mode का surface color।
          : Colors.white, // Light Mode का surface color।
    );

    // BorderSide से borders का रंग तय किया जाता है।
    // Ternary operator (? :) के माध्यम से Light और Dark Mode का रंग चुना जाता है।
    final border = BorderSide(
      color: isDark
          ? const Color(0xFF303A48) // Dark Mode border।
          : const Color(0xFFE7EBF1), // Light Mode border।
    );

    // ThemeData app की सभी प्रमुख visual settings को एक जगह रखता है।
    return ThemeData(
      // Material Design 3 के UI behavior और components को enable करता है।
      useMaterial3: true,

      // Theme की brightness सेट करता है।
      brightness: brightness,

      // App के components को ऊपर बनाया गया ColorScheme देता है।
      colorScheme: scheme,

      // Scaffold यानी सामान्य page का background color सेट करता है।
      scaffoldBackgroundColor: isDark
          ? DesignTokens.darkBackground
          : DesignTokens.lightBackground,

      // पूरे app के text styles का आधार निर्धारित करता है।
      // ThemeData(brightness: brightness).textTheme से default text styles मिलते हैं।
      // apply() से सभी संबंधित text styles के colors customize किए जाते हैं।
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: isDark
            ? const Color(0xFFE8ECF2) // Dark Mode में सामान्य text।
            : const Color(0xFF202938), // Light Mode में सामान्य text।

        displayColor: isDark
            ? const Color(0xFFF5F7FB) // Dark Mode में बड़े/display text।
            : const Color(0xFF202938), // Light Mode में बड़े/display text।
      ),

      // CardThemeData app के Card widgets का common design निर्धारित करता है।
      cardTheme: CardThemeData(
        color: scheme.surface, // Card का background।
        elevation: 0, // Card के नीचे shadow नहीं होगी।
        margin: EdgeInsets.zero, // Default outer margin हटाता है।
        // Card का आकार और border एक साथ निर्धारित करता है।
        shape: RoundedRectangleBorder(
          // DesignTokens से card का corner radius लिया जाता है।
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),

          // Card के चारों ओर ऊपर बनाया गया border लागू होता है।
          side: border,
        ),
      ),

      // AppBar की पूरी app-wide styling।
      appBarTheme: AppBarTheme(
        // Light और Dark Mode के अनुसार AppBar का background।
        backgroundColor: isDark ? DesignTokens.darkBackground : Colors.white,

        // AppBar पर Material 3 का अतिरिक्त surface tint हटाता है।
        surfaceTintColor: Colors.transparent,

        // AppBar की elevation यानी shadow हटाता है।
        elevation: 0,

        // Title को बाईं तरफ रखने की configuration।
        centerTitle: false,

        // AppBar के title का text style।
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF202938),

          // Title को bold बनाता है।
          fontWeight: FontWeight.w700,

          // Title का font size 18 logical pixels है।
          fontSize: 18,
        ),
      ),

      // Bottom Navigation Bar का common design।
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,

        // Selected navigation item के पीछे हल्का primary color।
        // withValues(alpha: 0.12) लगभग 12% opacity देता है।
        indicatorColor: scheme.primary.withValues(alpha: 0.12),

        elevation: 0,

        // Navigation labels की styling को उनकी state के अनुसार बदलता है।
        // resolveWith() को current WidgetState की list मिलती है।
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,

            // Selected item का label bold होगा।
            // Unselected item के लिए default font weight उपयोग होगा।
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : null,
          ),
        ),
      ),

      // बड़ी screen पर उपयोग होने वाले NavigationRail का design।
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,

        // Selected navigation item के पीछे हल्का रंग।
        indicatorColor: scheme.primary.withValues(alpha: 0.12),

        // सभी navigation items के labels दिखाता है।
        labelType: NavigationRailLabelType.all,
      ),

      // TextField और TextFormField की common styling।
      inputDecorationTheme: InputDecorationTheme(
        // Input के background को filled style देता है।
        filled: true,

        // Light और Dark Mode के अनुसार input background।
        fillColor: isDark ? const Color(0xFF141B24) : const Color(0xFFF7F8FA),

        // सामान्य input border।
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.smallRadius),
          borderSide: border,
        ),

        // Enabled लेकिन unfocused input का border।
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.smallRadius),
          borderSide: border,
        ),
      ),

      // Divider widget का default color।
      // इसका उपयोग sections के बीच separator दिखाने के लिए होता है।
      dividerColor: isDark ? const Color(0xFF303A48) : const Color(0xFFE7EBF1),
    );
  }
}
