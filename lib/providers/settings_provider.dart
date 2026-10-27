import 'package:flutter/foundation.dart'; // kIsWeb और defaultTargetPlatform के लिए।
import 'package:flutter/material.dart'; // ThemeMode, Duration आदि Flutter types के लिए।
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Riverpod Notifier APIs।

// ------------------------------------------------------------
// 1. THEME MODE PROVIDER
// ------------------------------------------------------------

// ThemeModeController को Riverpod से जोड़ता है।
// State का type ThemeMode है:
// system, light या dark।
final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

// ------------------------------------------------------------
// 2. REFRESH INTERVAL PROVIDER
// ------------------------------------------------------------

// Auto-refresh interval को manage करता है।
// Duration? का अर्थ है Duration या null दोनों स्वीकार्य हैं।
// null का अर्थ होगा auto-refresh बंद।
final refreshIntervalProvider =
    NotifierProvider<RefreshIntervalController, Duration?>(
      RefreshIntervalController.new,
    );

// ------------------------------------------------------------
// 3. API ENDPOINT PROVIDER
// ------------------------------------------------------------

// API URL को store और update करने वाला provider।
final apiEndpointProvider = NotifierProvider<ApiEndpointController, String>(
  ApiEndpointController.new,
);

// ------------------------------------------------------------
// 4. THEME MODE CONTROLLER
// ------------------------------------------------------------

class ThemeModeController extends Notifier<ThemeMode> {
  // Provider initialize होने पर शुरुआती state तय करें।
  @override
  ThemeMode build() => ThemeMode.system;

  // Theme की state update करें।
  // state बदलने पर इस provider को watch करने वाले widgets
  // नई value के अनुसार rebuild हो सकते हैं।
  void setMode(ThemeMode mode) => state = mode;
}

// ------------------------------------------------------------
// 5. REFRESH INTERVAL CONTROLLER
// ------------------------------------------------------------

class RefreshIntervalController extends Notifier<Duration?> {
  // शुरुआत में auto-refresh हर 5 सेकंड पर होगा।
  @override
  Duration? build() => const Duration(seconds: 5);

  // Interval बदलें।
  // उदाहरण: Duration(seconds: 15)
  // null देने पर auto-refresh बंद किया जा सकता है।
  void setInterval(Duration? interval) => state = interval;
}

// ------------------------------------------------------------
// 6. API ENDPOINT CONTROLLER
// ------------------------------------------------------------

class ApiEndpointController extends Notifier<String> {
  // Provider initialize होने पर शुरुआती API URL लौटाएँ।
  @override
  String build() {
    // यदि App Web पर चल रही है, तो यह URL उपयोग करें।
    if (kIsWeb) return 'http://niftybee.in/api1';

    // Non-Web platforms के लिए target platform जाँचें।
    return switch (defaultTargetPlatform) {
      // Android पर उपयोग होने वाला URL।
      TargetPlatform.android => 'http://niftybee.in/api1',

      // अन्य platforms पर fallback URL।
      _ => 'http://niftybee.in/api1',
    };
  }

  // Settings screen से नया endpoint आने पर state बदलें।
  void setEndpoint(String endpoint) => state = endpoint;
}
