import 'package:go_router/go_router.dart';
// GoRouter package को import करता है।
// यह app में declarative navigation और URL-based routing उपलब्ध कराता है।

import 'package:learn_flutter_api/features/candle_details/candle_details_screen.dart';
// Candlestick की details दिखाने वाली screen को import करता है।

import 'package:learn_flutter_api/features/dashboard/dashboard_screen.dart';
// Main Dashboard screen को import करता है।

import 'package:learn_flutter_api/features/settings/settings_screen.dart';

// Settings screen को import करता है।

// appRouter एक global variable है, जिसे app के अलग-अलग हिस्सों में
// navigation configuration के लिए इस्तेमाल किया जा सकता है.
//
// final का मतलब है कि appRouter को दोबारा कोई दूसरी value assign नहीं कर सकते।
final appRouter = GoRouter(
  // App शुरू होने पर सबसे पहले '/' route खुलेगा।
  // इस route पर DashboardScreen दिखाई जाएगी।
  initialLocation: '/',

  // routes में app के सभी उपलब्ध navigation routes की list है।
  routes: [
    // ─────────────────────────────────────────────
    // 1. DASHBOARD ROUTE
    // ─────────────────────────────────────────────

    GoRoute(
      // Dashboard का URL/path।
      path: '/',

      // इस route का unique और readable नाम।
      // Named navigation में इस नाम का उपयोग कर सकते हैं।
      name: 'dashboard',

      // builder route के लिए संबंधित widget बनाता है।
      // context Flutter widget tree का BuildContext है।
      // state में route से संबंधित जानकारी उपलब्ध होती है।
      builder: (context, state) => const DashboardScreen(),
    ),

    // ─────────────────────────────────────────────
    // 2. CANDLE DETAILS ROUTE
    // ─────────────────────────────────────────────
    GoRoute(
      // Candle details screen का path।
      path: '/candle',

      // इस route का नाम।
      name: 'candle',

      // इस path पर जाने पर CandleDetailsScreen खुलेगी।
      builder: (context, state) => const CandleDetailsScreen(),
    ),

    // ─────────────────────────────────────────────
    // 3. SETTINGS ROUTE
    // ─────────────────────────────────────────────
    GoRoute(
      // Settings screen का path।
      path: '/settings',

      // इस route का नाम।
      name: 'settings',

      // इस path पर जाने पर SettingsScreen खुलेगी।
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
