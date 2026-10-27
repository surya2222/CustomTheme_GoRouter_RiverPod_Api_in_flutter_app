# Candleboard: complete build and code guide

This guide explains how the Flutter stock-candle dashboard is assembled,
how its data moves from FastAPI to the chart, how to run and test it,
and includes the complete current application source and relevant
platform configuration.

## About the requested line count

The current Dart files in `lib/` and `test/` contain **1,686 physical
lines**, five fewer than the 1,691 lines mentioned in the request.
Counts can differ slightly depending on whether blank lines and final
newline characters are included. This guide includes every current Dart
application and test file, plus the dependency manifest, Android and iOS
network configuration, and the supplied FastAPI server module. Generated
files and dependency lock-file contents are intentionally omitted;
`pubspec.lock` records exact resolved package versions and is maintained
by Flutter.

The source listings below are copied from the files as they exist now.
Treat the project files as the editable source of truth; regenerate this
guide's listings after changing the application code.

## 1. What the app does

The app calls the existing authenticated `GET /api1` endpoint and
renders the single OHLC candle returned by the server. It does not
create fake candles or turn repeated API responses into a claimed
historical series. The dashboard polls every five seconds by default
because this API does not provide a WebSocket, server-sent events, or
another change-notification mechanism. Polling can be changed or turned
off in Settings.

The UI provides:

-   Dashboard: responsive candle chart, OHLC values, online/offline
    state, last update time, manual refresh, loading, and retryable
    error states.
-   Candle details: timestamp and all four OHLC values for the latest
    response.
-   Settings: system/light/dark theme, polling interval, and
    configurable API endpoint.

## 2. Requirements and dependencies

Install Flutter with Dart 3.13 or later and a platform toolchain for the
target you want to run. From the Flutter project directory, resolve
packages:

``` powershell
flutter pub get
```

`pubspec.yaml` declares the app's packages:

-    

Keep `pubspec.lock` with the app so builds use the resolved compatible
versions. Use `flutter pub add package_name` when adding or upgrading a
direct dependency, then inspect the package API for the installed
version before integrating it.

## 3. Create the project structure

The code is organized by feature and responsibility:

``` text
lib/
  main.dart                         App entry point
  app/
    app.dart                        MaterialApp.router and theme selection
    router.dart                     GoRouter route definitions
    theme/
      app_theme.dart                Central light and dark Material 3 themes
      design_tokens.dart            Breakpoints, spacing, and chart colors
  core/
    responsive/
      responsive_layout.dart        Width-based mobile/tablet/desktop choice
    widgets/                        Shared UI and chart components
  data/
    models/candle.dart              Validated typed API response
    services/candle_api_service.dart HTTP and JSON boundary
    repositories/candle_repository.dart Data access abstraction
  providers/
    candle_provider.dart            Riverpod API/data state
    settings_provider.dart          Theme, refresh, and endpoint settings
  features/
    dashboard/                      Dashboard route and periodic timer
    candle_details/                  Candle details route
    settings/                        App configuration route
test/
  data/models/                       Candle parsing tests
  data/services/                     HTTP service tests
  widget_test.dart                   UI state, settings, and responsive tests
```

The shared widgets live in `core/widgets`, while feature screens compose
them. This keeps HTTP concerns out of the presentation layer and helps a
visual change to a shared component stay consistent across routes.

## 4. Understand the data path

When `main()` runs, it mounts the app beneath a Riverpod
`ProviderScope`. `StockDashboardApp` watches the selected theme and
builds `MaterialApp.router` with the GoRouter configuration.

When the dashboard reads `candleProvider`, `CandleController.build()`
calls the repository. The repository delegates to `CandleApiService`,
which sends an HTTP GET with `Authorization: Bearer <token>` and an
`Accept: application/json` header. The request has a 15-second timeout.

The service rejects non-success status codes, reports HTTP 401
distinctly, and decodes only a JSON object. `Candle.fromJson` validates
the ISO timestamp, requires finite numeric prices, and checks that the
high and low contain the open and close. An invalid response becomes an
explicit error state, not a placeholder candle.

The Riverpod async state is rendered by the dashboard as loading, error,
or data. In the data state, one `CandlestickSpot` is created from the
returned OHLC values. A touch tooltip also exposes those same values.
OHLC summary and details screens use the same typed candle.

## 5. How automatic refresh works

`RefreshIntervalController` supplies a five-second default. The
dashboard subscribes to setting changes, cancels its previous `Timer`,
and starts a new periodic timer when an interval is selected. The timer
calls `CandleController.refresh()`. Leaving the dashboard cancels the
timer in `dispose()`.

The controller guards requests with `_requestInProgress`, so an
automatic poll does not overlap an unfinished manual or scheduled
request. Refresh errors are kept in Riverpod state and displayed with
retry; an API failure never becomes invented candle data. The server
generates a random candle per request, so every poll may return a
different candle even though there is no push event.

## 6. Responsive layout and design system

`DesignTokens` centralizes colors, spacing, chart dimensions, and
default width breakpoints. `ResponsiveLayout` uses both `LayoutBuilder`
and `MediaQuery.sizeOf` so it can choose a layout even when its parent
width is unbounded. The defaults are mobile below 600 logical pixels,
tablet from 600 through 1023, and desktop from 1024 upward.

`AppTheme` is the single source for light and dark `ThemeData`, Material
3 `ColorScheme`, text styles, cards, navigation, and input fields.
`AppScaffold` provides a navigation bar on narrow screens and a
navigation rail on wider screens. The chart colors are shared tokens:
green for bullish candles and red for bearish candles.

## 7. Configure and run the FastAPI server

The supplied module is `a4_7api_server_stock.py`, alongside the Flutter
project directory. It returns `time`, `open`, `high`, `low`, and `close`
from `GET /api1` and validates the demo bearer token.

From the directory containing that Python module, run:

``` powershell
python -m uvicorn a4_7api_server_stock:app --host 0.0.0.0 --port 8081 --reload
```

The `0.0.0.0` binding permits testing from a phone on the same trusted
LAN; it exposes the development server on network interfaces, so do not
use it on an untrusted network. CORS is enabled for the supplied dummy
API so a browser can make the request. For a deployed service, allow
only the required web origins and use HTTPS.

## 8. Run on a target platform

From the Flutter project directory:

``` powershell
flutter run
```

Or choose a device explicitly:

``` powershell
flutter run -d android
flutter run -d chrome
flutter run -d windows
```
 
The endpoint defaults are platform-aware:

-   Android emulator uses `http://10.0.2.2:8081/api1`; emulator
    `localhost` is not the development computer.
-   Web and desktop use `http://127.0.0.1:8081/api1` by default.
-   iOS simulator uses `http://127.0.0.1:8081/api1`.
-   A physical phone needs the computer's LAN IP address entered in
    Settings, such as `http://192.168.1.10:8081/api1`. Ensure the
    firewall allows port 8081.

The Android manifest grants internet access and enables cleartext HTTP
for the local development API. The iOS plist permits local network
access. Production deployments should use HTTPS and platform-appropriate
transport security rather than weakening it.

### Demo token and production credentials

The default token is `suryaji` to match the supplied dummy server. To
override it for a local build:

``` powershell
flutter run --dart-define=STOCK_API_TOKEN=your-demo-token
```

`--dart-define` embeds a value in the built client; it is not secret
storage. Never ship a production API secret inside a Flutter
application. Put privileged credentials behind a backend or use an
appropriate user authentication flow.

## 9. Test and validate

Run static analysis and the automated test suite:

``` powershell
flutter analyze
flutter test
```

The tests cover:

-   Valid and invalid candle JSON, including inconsistent OHLC ranges.
-   Authorization header, successful response, HTTP 401/503, and
    malformed JSON.
-   Initial loading, data display, and actionable API errors.
-   Five-second automatic polling with the default settings.
-   Theme selection and mobile/tablet/desktop sizing without overflow.

Build outputs can also be checked for supported local toolchains:

``` powershell
# flutter build web --release
# flutter build apk --debug
```

Windows desktop builds need Visual Studio with the Desktop development
with C++ workload. iOS builds require macOS and Xcode. A successful
widget test is not a substitute for exercising the API from each real
device/network.

## 10. Troubleshooting

  -----------------------------------------------------------------------
  Symptom                             Checks
  ----------------------------------- -----------------------------------
  HTTP 401                            Confirm the configured token
                                      matches the server token.

  Connection refused or timeout       Start Uvicorn, check port 8501,
                                      firewall, endpoint, and LAN
                                      reachability.

  Android cannot reach host           Use the emulator's `10.0.2.2`
                                      address; on a physical phone use
                                      the computer LAN IP.

  Web request blocked                 Check the API CORS response and the
                                      browser origin.

  Chart has no data                   Inspect the HTTP response fields
                                      and JSON types; this endpoint
                                      provides one candle only.

  Windows build fails                 Install Visual Studio with Desktop
                                      development with C++.

  iOS build unavailable               Use macOS with Xcode and CocoaPods
                                      configured.
  -----------------------------------------------------------------------

## 11. Complete current source and configuration

The listings in this section are the full contents of the current
application Dart files under `lib/`, all Dart tests under `test/`,
`pubspec.yaml`, the Android app manifest, the iOS `Info.plist`, and the
supplied FastAPI server module. Each heading is the path relative to the
Flutter project, except the backend module, which is in the parent
directory.

The complete source listings are appended below.

```{=html}
<!-- FULL_SOURCE_CODE_START -->
```
# हिंदी में सीखें: हर file का उद्देश्य और Core Logic

यह भाग source code पढ़ते समय साथ-साथ पढ़ने के लिए है। पहले file का उद्देश्य समझें,
फिर code में उसी flow को खोजें। App का मुख्य data flow है:

`main.dart` → `app.dart` → `router.dart` → Screen → Riverpod
Provider/Controller → Repository → API Service → FastAPI → `Candle`
model → Provider state → UI/Chart.

-   **Model:** JSON को typed, validated Dart object बनाता है।
-   **Service:** HTTP request, headers, status codes और JSON decoding
    संभालती है।
-   **Repository:** data source तक पहुँचने का abstraction देती है।
-   **Provider/Controller:** dependencies और asynchronous state को
    manage करता है।
-   **Screen:** loading/error/data को widgets में बदलती है।
-   **Reusable widget:** shared UI behavior और appearance को एक जगह रखता
    है।
-   **Theme/design tokens:** colors, spacing और typography को केंद्रीकृत करते
    हैं।
-   **Tests:** expected behavior को automatic तरीके से verify करते हैं।

## पढ़ने का सुझाया गया क्रम

1.  `main.dart` और `app.dart` --- app कैसे start होती है।
2.  `router.dart` और `app_scaffold.dart` --- navigation कैसे होती है।
3.  `candle.dart` --- API data का model और validation।
4.  `candle_api_service.dart` और `candle_repository.dart` --- network से
    data कैसे आता है।
5.  `settings_provider.dart` और `candle_provider.dart` --- Riverpod
    state और dependencies।
6.  `candle_chart.dart`, `ohlc_summary.dart` और dashboard screen ---
    data UI में कैसे दिखता है।
7.  Settings, theme, responsive widgets और tests।

> Learning tip: हर file के लिए तीन सवाल पूछें: यह file क्या जिम्मेदारी निभाती
> है? इसे कौन call करता है? इसका output कौन इस्तेमाल करता है?

------------------------------------------------------------------------

### हिंदी में Core Logic

यह file app की मुख्य UI configuration है। `StockDashboardApp` एक
`ConsumerWidget` है, इसलिए यह Riverpod providers को पढ़ सकता है।
`ref.watch(themeModeProvider)` theme mode में बदलाव सुनता है; value बदलते ही
widget दोबारा build होता है। `MaterialApp.router` Flutter के सामान्य
`MaterialApp` के बजाय GoRouter को routing control देता है। `theme`,
`darkTheme` और `themeMode` मिलकर light/dark/system theme चुनते हैं।

**याद रखें:** यहाँ business logic या API request न रखें। यह file app के
अलग-अलग global हिस्सों को जोड़ती है।

### `lib/app/app.dart` (22 lines)

``` dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ऐप में Navigation और Routes की configuration
import 'package:learn_flutter_api/app/router.dart';

// ऐप की Light और Dark Theme की configuration
import 'package:learn_flutter_api/app/theme/app_theme.dart';

// Theme Mode को manage करने वाला Riverpod Provider
import 'package:learn_flutter_api/providers/settings_provider.dart';

/// StockDashboardApp पूरे Flutter ऐप का मुख्य Widget है।
///
/// ConsumerWidget का उपयोग इसलिए किया गया है क्योंकि
/// इस Widget को Riverpod Provider से डेटा पढ़ना है।
class StockDashboardApp extends ConsumerWidget {
  const StockDashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    // themeModeProvider से वर्तमान Theme Mode प्राप्त करें।
    //
    // ref.watch() Provider को observe करता है।
    // जब Theme Mode बदलता है, तो यह Widget दोबारा build होता है।
    //
    // संभावित मान:
    // ThemeMode.system -> डिवाइस की Theme का उपयोग
    // ThemeMode.light  -> Light Theme
    // ThemeMode.dark   -> Dark Theme
    final themeMode = ref.watch(themeModeProvider);

    // MaterialApp.router ऐप का मुख्य Material Design Widget है।
    // इसका routerConfig GoRouter के माध्यम से Navigation संभालता है।
    return MaterialApp.router(

      // ऐप का नाम; इसे ऐप की पहचान के लिए इस्तेमाल किया जाता है।
      title: 'Candleboard',

      // Debug Mode में ऊपर दाईं ओर दिखने वाला DEBUG Banner छिपाएँ।
      debugShowCheckedModeBanner: false,

      // Light Mode के लिए Theme Configuration।
      // इसकी परिभाषा app_theme.dart में है।
      theme: AppTheme.light,

      // Dark Mode के लिए Theme Configuration।
      // इसकी परिभाषा भी app_theme.dart में है।
      darkTheme: AppTheme.dark,

      // Riverpod से प्राप्त वर्तमान Theme Mode लागू करें।
      //
      // यह तय करता है कि Light Theme, Dark Theme
      // या System Theme में से कौन-सी Theme इस्तेमाल होगी।
      themeMode: themeMode,

      // GoRouter की configuration लागू करें।
      // इससे अलग-अलग स्क्रीन और Routes के बीच Navigation होता है।
      routerConfig: appRouter,
    );
  }
}


### हिंदी में Core Logic

यह navigation का single source of truth है। `GoRouter` तय करता है कि
कौन-सा URL/path किस screen को खोलेगा। `/` Dashboard, `/candle` details और
`/settings` settings खोलते हैं। `name` route को नाम से refer करने में मदद करता
है, जबकि `context.go('/candle')` route बदलता है।

**याद रखें:** नई screen जोड़ने पर route यहाँ जोड़ें और navigation destinations
भी `AppScaffold` में update करें।

### `lib/app/router.dart` (25 lines)

``` dart
import 'package:go_router/go_router.dart';
import 'package:learn_flutter_api/features/candle_details/candle_details_screen.dart';
import 'package:learn_flutter_api/features/dashboard/dashboard_screen.dart';
import 'package:learn_flutter_api/features/settings/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: '/candle',
      name: 'candle',
      builder: (context, state) => const CandleDetailsScreen(),
    ),
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);
```

### हिंदी में Core Logic

`AppTheme` light और dark `ThemeData` बनाने की जिम्मेदारी निभाता है।
`_createTheme()` को `Brightness` मिलता है; उसी से background, text और
borders के रंग तय होते हैं। `ColorScheme.fromSeed()` seed color से Material 3
palette बनाता है। `cardTheme`, `appBarTheme`, navigation themes और input
theme default styling को एक जगह रखते हैं।

**क्यों उपयोगी है?** किसी shared component का look बदलने के लिए हर screen
edit करने के बजाय theme बदल सकते हैं। जहाँ कोई रंग `DesignTokens` से आना चाहिए,
वहाँ hardcoded रंग बढ़ाने से बचें।

### `lib/app/theme/app_theme.dart` (84 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

abstract final class AppTheme {
  static final light = _createTheme(Brightness.light);
  static final dark = _createTheme(Brightness.dark);

  static ThemeData _createTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF4969E8),
      brightness: brightness,
      surface: isDark ? const Color(0xFF1A212C) : Colors.white,
    );
    final border = BorderSide(
      color: isDark ? const Color(0xFF303A48) : const Color(0xFFE7EBF1),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: isDark
          ? DesignTokens.darkBackground
          : DesignTokens.lightBackground,
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: isDark ? const Color(0xFFE8ECF2) : const Color(0xFF202938),
        displayColor: isDark
            ? const Color(0xFFF5F7FB)
            : const Color(0xFF202938),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.cardRadius),
          side: border,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: isDark ? DesignTokens.darkBackground : Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF202938),
          fontWeight: FontWeight.w700,
          fontSize: 18,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : null,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.primary.withValues(alpha: 0.12),
        labelType: NavigationRailLabelType.all,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF141B24) : const Color(0xFFF7F8FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.smallRadius),
          borderSide: border,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(DesignTokens.smallRadius),
          borderSide: border,
        ),
      ),
      dividerColor: isDark ? const Color(0xFF303A48) : const Color(0xFFE7EBF1),
    );
  }
}
```

### हिंदी में Core Logic

यह design system के स्थिर values का संग्रह है: responsive breakpoints,
maximum content width, chart height, spacing, radius और bullish/bearish
chart colors। `static const` values compile-time constants हैं, इसलिए इन्हें
बिना object बनाए access किया जा सकता है।

**उदाहरण:** सभी cards का radius बदलना हो तो `cardRadius` बदलें। यह तभी सभी
जगह लागू होगा जब widgets उसी token का उपयोग करें।

### `lib/app/theme/design_tokens.dart` (25 lines)

``` dart
import 'package:flutter/material.dart';

abstract final class DesignTokens {
  static const mobileBreakpoint = 600.0;
  static const tabletBreakpoint = 1024.0;
  static const contentMaxWidth = 1440.0;
  static const chartHeight = 280.0;
  static const chartAxisWidth = 54.0;
  static const ohlcValueWidth = 92.0;

  static const space1 = 4.0;
  static const space2 = 8.0;
  static const space3 = 12.0;
  static const space4 = 16.0;
  static const space5 = 24.0;
  static const space6 = 32.0;

  static const cardRadius = 20.0;
  static const smallRadius = 12.0;
  static const chartBullish = Color(0xFF16A673);
  static const chartBearish = Color(0xFFE05260);
  static const chartGrid = Color(0xFF8A96A8);
  static const lightBackground = Color(0xFFF5F7FA);
  static const darkBackground = Color(0xFF10151D);
}
```

### हिंदी में Core Logic

`ScreenSize` तीन layout categories बताता है: mobile, tablet और desktop।
`sizeFor(width)` breakpoint देखकर category लौटाता है। `LayoutBuilder`
parent की उपलब्ध width देता है; यदि वह bounded न हो तो code `MediaQuery` की
screen width लेता है। `builder` callback screen को चुनी हुई category देता है।

**महत्वपूर्ण:** 600/1024 values logical pixels हैं, physical screen inches
नहीं। Responsive UI का निर्णय available width से होना चाहिए।

### `lib/core/responsive/responsive_layout.dart` (29 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

enum ScreenSize { mobile, tablet, desktop }

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({required this.builder, super.key});

  final Widget Function(BuildContext context, ScreenSize size) builder;

  static ScreenSize sizeFor(double width) {
    if (width < DesignTokens.mobileBreakpoint) return ScreenSize.mobile;
    if (width < DesignTokens.tabletBreakpoint) return ScreenSize.tablet;
    return ScreenSize.desktop;
  }

  @override
  Widget build(BuildContext context) {
    final mediaWidth = MediaQuery.sizeOf(context).width;
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : mediaWidth;
        return builder(context, sizeFor(width));
      },
    );
  }
}
```

### हिंदी में Core Logic

`AppButton` Flutter के `FilledButton.icon` को reusable wrapper में बदलता है।
हर उपयोग करने वाली screen label, callback और optional icon देती है।
`isLoading == true` होने पर button disable हो जाता है और icon की जगह छोटा
progress indicator दिखता है। इससे loading के दौरान accidental repeated taps
कम होते हैं।

**केंद्रीय बदलाव:** button का padding, shape और colors theme के component
styles में रखें, ताकि सभी buttons एक जैसे रहें।

### `lib/core/widgets/app_button.dart` (30 lines)

``` dart
import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: isLoading ? null : onPressed,
      icon: isLoading
          ? const SizedBox.square(
              dimension: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(icon ?? Icons.refresh_rounded, size: 18),
      label: Text(label),
    );
  }
}
```

### हिंदी में Core Logic

`AppCard` एक shared `Card` और उसके अंदर consistent `Padding` देता है।
`child` में कोई भी widget रखा जा सकता है। Default padding
`DesignTokens.space5` से आती है, लेकिन जरूरत पर किसी खास card को अलग padding
दी जा सकती है।

**फायदा:** हर screen में बार-बार `Card` + `Padding` लिखने की जरूरत नहीं और
card styling एक जगह से नियंत्रित होती है।

### `lib/core/widgets/app_card.dart` (18 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.space5),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(padding: padding, child: child),
  );
}
```

### `lib/core/widgets/app_error_view.dart` (41 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/core/widgets/app_button.dart';
import 'package:learn_flutter_api/core/widgets/app_card.dart';
import 'package:learn_flutter_api/core/widgets/app_status_indicator.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({required this.message, required this.onRetry, super.key});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: AppCard(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 460),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 14),
            Text(
              'Could not load candle',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            const AppStatusIndicator(isOnline: false),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            AppButton(label: 'Try again', onPressed: onRetry),
          ],
        ),
      ),
    ),
  );
}
```

### हिंदी में Core Logic

यह tooltip सहित `IconButton` का छोटा reusable wrapper है। Caller icon,
tooltip और `onPressed` callback देता है। Tooltip accessibility और mouse
hover पर action समझने में मदद करता है। `onPressed: null` होने पर Flutter
button disabled रखता है।

**उपयोग:** refresh, settings और open-details जैसे icon actions में एक
consistent pattern।

### `lib/core/widgets/app_icon_button.dart` (18 lines)

``` dart
import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  const AppIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) =>
      IconButton(onPressed: onPressed, tooltip: tooltip, icon: Icon(icon));
}
```

### `lib/core/widgets/app_loading.dart` (27 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/core/widgets/app_card.dart';

class AppLoading extends StatelessWidget {
  const AppLoading({super.key});

  @override
  Widget build(BuildContext context) => const Center(
    child: AppCard(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: DesignTokens.space6,
          vertical: DesignTokens.space5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: DesignTokens.space4),
            Text('Connecting to stock API...'),
          ],
        ),
      ),
    ),
  );
}
```

### हिंदी में Core Logic

`AppScaffold` सभी routes के लिए common page frame बनाता है: app bar,
title, actions, content area और navigation। `_destinations` में navigation
items एक सूची में हैं। `_selectedIndex` current route के अनुसार selected item
निकालता है और `_navigate()` `context.go()` से route बदलता है। Narrow
screens पर bottom `NavigationBar`, wider screens पर `NavigationRail`
दिखता है। `ConstrainedBox` content को बहुत चौड़ा फैलने से रोकता है।

**एक जगह बदलाव:** navigation label/icon/path बदलने पर `_destinations` और
router paths को साथ में सही रखें।

### `lib/core/widgets/app_scaffold.dart` (118 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    required this.title,
    required this.route,
    required this.child,
    this.actions = const [],
    super.key,
  });

  final String title;
  final String route;
  final Widget child;
  final List<Widget> actions;

  static const _destinations = [
    _Destination('Overview', '/', Icons.space_dashboard_outlined),
    _Destination('Candle', '/candle', Icons.candlestick_chart_outlined),
    _Destination('Settings', '/settings', Icons.tune_rounded),
  ];

  int get _selectedIndex {
    final index = _destinations.indexWhere(
      (destination) => destination.route == route,
    );
    return index < 0 ? 0 : index;
  }

  void _navigate(BuildContext context, int index) {
    final destination = _destinations[index];
    if (route != destination.route) context.go(destination.route);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isWide = width >= DesignTokens.mobileBreakpoint;
    final content = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: DesignTokens.contentMaxWidth),
      child: child,
    );
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              Icons.candlestick_chart_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Flexible(
              child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
        actions: actions,
      ),
      body: SafeArea(
        top: false,
        child: isWide
            ? Row(
                children: [
                  NavigationRail(
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) => _navigate(context, index),
                    destinations: _destinations
                        .map(
                          (destination) => NavigationRailDestination(
                            icon: Icon(destination.icon),
                            label: Text(destination.label),
                          ),
                        )
                        .toList(),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(DesignTokens.space5),
                        child: content,
                      ),
                    ),
                  ),
                ],
              )
            : Padding(
                padding: const EdgeInsets.all(DesignTokens.space4),
                child: content,
              ),
      ),
      bottomNavigationBar: isWide
          ? null
          : NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) => _navigate(context, index),
              destinations: _destinations
                  .map(
                    (destination) => NavigationDestination(
                      icon: Icon(destination.icon),
                      label: destination.label,
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _Destination {
  const _Destination(this.label, this.route, this.icon);

  final String label;
  final String route;
  final IconData icon;
}
```

### हिंदी में Core Logic

यह `isOnline` boolean के आधार पर online/offline text और color चुनता है।
`Semantics` screen reader को status बताता है। Container, dot और text
मिलकर छोटा status badge बनाते हैं।

**सीमा:** dashboard में इसे online दिखाना तभी सही है जब API request सफल हुई
हो; केवल widget का होना server की वास्तविक स्थिति की जाँच नहीं करता।

### `lib/core/widgets/app_status_indicator.dart` (41 lines)

``` dart
import 'package:flutter/material.dart';

class AppStatusIndicator extends StatelessWidget {
  const AppStatusIndicator({required this.isOnline, super.key});

  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? const Color(0xFF16A673) : const Color(0xFFE05260);
    return Semantics(
      label: isOnline ? 'API online' : 'API offline',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Text(
              isOnline ? 'API online' : 'API offline',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### हिंदी में Core Logic

यह file `fl_chart` का `CandlestickChart` बनाती है।
`candle.close >= candle.open` होने पर candle bullish मानी जाती है, अन्यथा
bearish। OHLC values को `CandlestickSpot` में map किया जाता है।
`high - low` chart range है; उसके आधार पर vertical padding रखी जाती है ताकि
candle chart की सीमा से चिपके नहीं। Axes, grid, timestamp label और touch
tooltip भी यहीं configure होते हैं।

**सीमा:** इस code में एक ही `CandlestickSpot` है, इसलिए यह single candle
दिखाता है---historical series नहीं। Chart colors `DesignTokens` से आते हैं।

### `lib/core/widgets/candle_chart.dart` (109 lines)

``` dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/data/models/candle.dart';

class CandleChart extends StatelessWidget {
  const CandleChart({required this.candle, super.key});

  final Candle candle;

  @override
  Widget build(BuildContext context) {
    final isBullish = candle.close >= candle.open;
    final color = isBullish
        ? DesignTokens.chartBullish
        : DesignTokens.chartBearish;
    final range = candle.high - candle.low;
    final padding = range == 0 ? candle.high.abs() * 0.02 : range * 0.25;
    final chartText =
        Theme.of(context).textTheme.labelSmall?.color ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final dateFormat = DateFormat('MMM d');
    final chart = CandlestickChart(
      CandlestickChartData(
        candlestickSpots: [
          CandlestickSpot(
            x: 1,
            open: candle.open,
            high: candle.high,
            low: candle.low,
            close: candle.close,
          ),
        ],
        minX: 0,
        maxX: 2,
        minY: candle.low - padding,
        maxY: candle.high + padding,
        gridData: FlGridData(
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: DesignTokens.chartGrid.withValues(alpha: 0.18),
            strokeWidth: 1,
            dashArray: [4, 4],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: DesignTokens.chartAxisWidth,
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  value.toStringAsFixed(2),
                  style: TextStyle(color: chartText, fontSize: 10),
                ),
              ),
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 1,
              reservedSize: 30,
              getTitlesWidget: (value, meta) => value == 1
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        dateFormat.format(candle.time.toLocal()),
                        style: TextStyle(color: chartText, fontSize: 11),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),
        candlestickTouchData: CandlestickTouchData(
          enabled: true,
          touchSpotThreshold: 16,
          touchTooltipData: CandlestickTouchTooltipData(
            getTooltipItems: (painter, spot, index) => CandlestickTooltipItem(
              'O ${spot.open.toStringAsFixed(2)}  H ${spot.high.toStringAsFixed(2)}\n'
              'L ${spot.low.toStringAsFixed(2)}  C ${spot.close.toStringAsFixed(2)}',
              textStyle: TextStyle(color: Colors.white, fontSize: 11),
            ),
            getTooltipColor: (spot) => color,
          ),
        ),
      ),
      duration: const Duration(milliseconds: 220),
    );
    return SizedBox(
      height: DesignTokens.chartHeight,
      child: Semantics(
        label:
            'Single server-provided candlestick, open ${candle.open}, high ${candle.high}, low ${candle.low}, close ${candle.close}',
        child: chart,
      ),
    );
  }
}
```

### हिंदी में Core Logic

`OhlcSummary` एक candle लेकर OPEN, HIGH, LOW और CLOSE values को `Wrap` में
दिखाता है। `Wrap` कम width पर items को अगली line में ले जा सकता है। अंदर का
`_Value` private reusable sub-widget है, जो label और formatted number
दिखाता है। `toStringAsFixed(2)` price को दो decimal places में दिखाता है।

**ध्यान दें:** `HIGH` और `LOW` की accent color candle direction से तय होती
है; यह केवल visual emphasis है, अलग signal नहीं।

### `lib/core/widgets/ohlc_summary.dart` (62 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/data/models/candle.dart';

class OhlcSummary extends StatelessWidget {
  const OhlcSummary({required this.candle, super.key});

  final Candle candle;

  @override
  Widget build(BuildContext context) {
    final isBullish = candle.close >= candle.open;
    final accent = isBullish
        ? DesignTokens.chartBullish
        : DesignTokens.chartBearish;
    return Wrap(
      spacing: 20,
      runSpacing: 18,
      children: [
        _Value(label: 'OPEN', value: candle.open, color: null),
        _Value(label: 'HIGH', value: candle.high, color: accent),
        _Value(label: 'LOW', value: candle.low, color: accent),
        _Value(label: 'CLOSE', value: candle.close, color: accent),
      ],
    );
  }
}

class _Value extends StatelessWidget {
  const _Value({required this.label, required this.value, required this.color});

  final String label;
  final double value;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: DesignTokens.ohlcValueWidth,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            letterSpacing: 1.1,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value.toStringAsFixed(2),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    ),
  );
}
```

### हिंदी में Core Logic

`Candle` एक typed data model है। इसके fields `final` हैं, इसलिए object बनने के
बाद values बदली नहीं जा सकतीं। `Candle.fromJson()` raw JSON map को
validate करके model में बदलता है। Timestamp string होना चाहिए और parse होनी
चाहिए; prices finite numbers होने चाहिए। अंत में OHLC consistency जाँची जाती
है: high, open/close से कम नहीं और low, open/close से अधिक नहीं हो सकता।

**यह validation क्यों जरूरी है?** गलत API response chart को बिगाड़ सकता है;
model उसे UI तक पहुँचने से पहले reject करता है।

### `lib/data/models/candle.dart` (50 lines)

``` dart
class Candle {
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  factory Candle.fromJson(Map<String, dynamic> json) {
    final timeValue = json['time'];
    if (timeValue is! String) {
      throw const FormatException(
        'Candle field "time" must be an ISO 8601 string.',
      );
    }

    final time = DateTime.tryParse(timeValue);
    if (time == null) {
      throw const FormatException('Candle field "time" is not a valid date.');
    }

    double readPrice(String key) {
      final value = json[key];
      if (value is! num || !value.isFinite) {
        throw FormatException('Candle field "$key" must be a finite number.');
      }
      return value.toDouble();
    }

    final open = readPrice('open');
    final high = readPrice('high');
    final low = readPrice('low');
    final close = readPrice('close');
    if (high < low ||
        high < open ||
        high < close ||
        low > open ||
        low > close) {
      throw const FormatException('Candle OHLC values are inconsistent.');
    }
    return Candle(time: time, open: open, high: high, low: low, close: close);
  }
}
```

### हिंदी में Core Logic

Repository UI/provider और concrete API service के बीच abstraction है।
`fetchLatest()` service से candle प्राप्त करता है और आगे देता है। अभी यह छोटा
wrapper है, लेकिन भविष्य में cache, database या अलग data source जोड़ने पर UI को
बदलने की जरूरत कम होगी।

**याद रखें:** API request का detail service में रखें; data source coordination
repository में रखें।

### `lib/data/repositories/candle_repository.dart` (10 lines)

``` dart
import 'package:learn_flutter_api/data/models/candle.dart';
import 'package:learn_flutter_api/data/services/candle_api_service.dart';

class CandleRepository {
  const CandleRepository(this._service);

  final CandleApiService _service;

  Future<Candle> fetchLatest() => _service.fetchCandle();
}
```

### `lib/data/services/candle_api_service.dart` (50 lines)

``` dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:learn_flutter_api/data/models/candle.dart';

class CandleApiException implements Exception {
  const CandleApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CandleApiService {
  const CandleApiService(this._client, this._endpoint, this._token);

  final http.Client _client;
  final Uri _endpoint;
  final String _token;

  Future<Candle> fetchCandle() async {
    final responseFuture = _client.get(
      _endpoint,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );
    final response = await responseFuture.timeout(const Duration(seconds: 15));
    if (response.statusCode == 401) {
      throw const CandleApiException(
        'The API rejected the token (HTTP 401). Check the demo token or server configuration.',
      );
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CandleApiException('The API returned HTTP ${response.statusCode}.');
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return Candle.fromJson(decoded);
    } on FormatException catch (error) {
      throw CandleApiException('Invalid candle response: ${error.message}');
    }
  }
}
```

### हिंदी में Core Logic

यह `ConsumerWidget` `candleProvider` को watch करता है और async state को
तीन branches में बदलता है: loading, error और data। Error पर shared
`AppErrorView` retry callback लेता है। Data पर timestamp format करके
`OhlcSummary` दिखाया जाता है। Screen वही typed candle इस्तेमाल करती है जो
dashboard इस्तेमाल करता है---अलग से दूसरी API request logic नहीं लिखती।

**सीख:** `AsyncValue.when()` asynchronous state को UI में साफ़-साफ़ संभालने का
तरीका है।

### `lib/features/candle_details/candle_details_screen.dart` (59 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/core/widgets/app_card.dart';
import 'package:learn_flutter_api/core/widgets/app_error_view.dart';
import 'package:learn_flutter_api/core/widgets/app_loading.dart';
import 'package:learn_flutter_api/core/widgets/app_scaffold.dart';
import 'package:learn_flutter_api/core/widgets/ohlc_summary.dart';
import 'package:learn_flutter_api/providers/candle_provider.dart';

class CandleDetailsScreen extends ConsumerWidget {
  const CandleDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final candle = ref.watch(candleProvider);
    final controller = ref.read(candleProvider.notifier);
    return AppScaffold(
      title: 'Candle details',
      route: '/candle',
      child: candle.when(
        loading: () => const AppLoading(),
        error: (error, stackTrace) => AppErrorView(
          message: error.toString(),
          onRetry: () => controller.refresh(),
        ),
        data: (snapshot) => SingleChildScrollView(
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Latest server candle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: DesignTokens.space2),
                Text(
                  DateFormat('EEEE, MMMM d, y · HH:mm:ss')
                      .format(snapshot.candle.time.toLocal()),
                ),
                const SizedBox(height: DesignTokens.space5),
                OhlcSummary(candle: snapshot.candle),
                const SizedBox(height: DesignTokens.space5),
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
```

### हिंदी में Core Logic

यह मुख्य screen है और `ConsumerStatefulWidget` है क्योंकि इसे Riverpod state के
साथ periodic `Timer` भी manage करना है। `initState()` refresh interval
provider को listen करता है और timer शुरू करता है। Setting बदलने पर पुराना
timer cancel होता है और नया interval लागू होता है; `dispose()` screen हटने
पर timer cancel करता है। `ref.watch(candleProvider)` state changes पर UI
rebuild करता है, जबकि `ref.read(...notifier)` refresh action चलाता है।

Dashboard loading/error/data branches दिखाता है। Data state में
`ResponsiveLayout` से screen category मिलती है; desktop/tablet पर chart और
summary side-by-side, mobile पर vertically दिखते हैं। `_ChartCard`,
`_SummaryCard`, `_MobileDashboard` और `_DesktopDashboard`
screen-specific composition को छोटे हिस्सों में बाँटते हैं।

**महत्वपूर्ण logic:** polling सिर्फ API को फिर से पूछती है। क्योंकि endpoint हर
request पर एक random candle देता है, app repeated responses को historical
candle series के रूप में claim नहीं करता।

### `lib/features/dashboard/dashboard_screen.dart` (275 lines)

``` dart
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
```

### हिंदी में Core Logic

यह `ConsumerStatefulWidget` है क्योंकि API URL के लिए
`TextEditingController` चाहिए। `initState()` current endpoint से field
भरता है और `dispose()` controller साफ करता है। `_saveEndpoint()` URL
parse/validate करता है; invalid URL पर error text सेट होता है, valid URL पर
`apiEndpointProvider` update होता है और SnackBar confirmation दिखता है।

Theme dropdown `themeModeProvider` को update करता है। Refresh dropdown
`refreshIntervalProvider` को seconds में duration देता है; `0` का अर्थ
polling off है। Dashboard interval provider को सुनकर timer पुनः schedule
करता है।

**ध्यान दें:** इस implementation में settings providers memory state हैं; app
restart के बाद values persist करने के लिए अलग persistence solution चाहिए।

### `lib/features/settings/settings_screen.dart` (195 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_api/app/theme/design_tokens.dart';
import 'package:learn_flutter_api/core/widgets/app_button.dart';
import 'package:learn_flutter_api/core/widgets/app_card.dart';
import 'package:learn_flutter_api/core/widgets/app_scaffold.dart';
import 'package:learn_flutter_api/providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _endpointController;
  String? _endpointError;

  @override
  void initState() {
    super.initState();
    _endpointController = TextEditingController(
      text: ref.read(apiEndpointProvider),
    );
  }

  @override
  void dispose() {
    _endpointController.dispose();
    super.dispose();
  }

  void _saveEndpoint() {
    final uri = Uri.tryParse(_endpointController.text.trim());
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      setState(() => _endpointError = 'Enter a valid HTTP or HTTPS URL.');
      return;
    }
    ref.read(apiEndpointProvider.notifier).setEndpoint(uri.toString());
    setState(() => _endpointError = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('API endpoint updated.')));
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final refreshInterval = ref.watch(refreshIntervalProvider);
    return AppScaffold(
      title: 'Settings',
      route: '/settings',
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: DesignTokens.space2),
            Text(
              'Adjust the appearance and connection for this dashboard.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: DesignTokens.space5),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<ThemeMode>(
                    key: ValueKey(themeMode),
                    initialValue: themeMode,
                    decoration: const InputDecoration(labelText: 'Theme'),
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('System'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Light'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Dark'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        ref.read(themeModeProvider.notifier).setMode(value);
                      }
                    },
                  ),
                  const SizedBox(height: DesignTokens.space5),
                  Text(
                    'Refresh',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    key: ValueKey(refreshInterval?.inSeconds ?? 0),
                    initialValue: refreshInterval?.inSeconds ?? 0,
                    decoration: const InputDecoration(
                      labelText: 'Poll API for new data',
                    ),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('Off')),
                      DropdownMenuItem(
                        value: 5,
                        child: Text('Every 5 seconds'),
                      ),
                      DropdownMenuItem(
                        value: 15,
                        child: Text('Every 15 seconds'),
                      ),
                      DropdownMenuItem(
                        value: 30,
                        child: Text('Every 30 seconds'),
                      ),
                      DropdownMenuItem(value: 60, child: Text('Every minute')),
                    ],
                    onChanged: (seconds) {
                      if (seconds != null) {
                        ref
                            .read(refreshIntervalProvider.notifier)
                            .setInterval(
                              seconds == 0 ? null : Duration(seconds: seconds),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space4),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API connection',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set the full /api1 URL. For a physical device, use your computer’s LAN IP address.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  TextField(
                    controller: _endpointController,
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveEndpoint(),
                    decoration: InputDecoration(
                      labelText: 'API endpoint',
                      hintText: 'http://192.168.1.10:8081/api1',
                      errorText: _endpointError,
                    ),
                  ),
                  const SizedBox(height: DesignTokens.space4),
                  AppButton(
                    label: 'Save endpoint',
                    icon: Icons.save_outlined,
                    onPressed: _saveEndpoint,
                  ),
                  const SizedBox(height: DesignTokens.space3),
                  Text(
                    'The demo token is supplied with --dart-define=STOCK_API_TOKEN. '
                    'Do not embed real credentials in a client application.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### हिंदी में Core Logic

यह Dart app का entry point है। `main()` सबसे पहले `runApp()` चलाता है।
`ProviderScope` Riverpod providers के लिए container उपलब्ध कराता है; इसके
बिना `ConsumerWidget` providers नहीं पढ़ पाएँगे। इसके अंदर `StockDashboardApp`
शुरू होता है।

**याद रखें:** app-wide Riverpod usage के लिए `ProviderScope` को root पर
रखना सामान्य pattern है।

### `lib/main.dart` (7 lines)

``` dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_flutter_api/app/app.dart';

void main() {
  runApp(const ProviderScope(child: StockDashboardApp()));
}
```

### `lib/providers/candle_provider.dart` (83 lines)

``` dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:learn_flutter_api/data/models/candle.dart';
import 'package:learn_flutter_api/data/repositories/candle_repository.dart';
import 'package:learn_flutter_api/data/services/candle_api_service.dart';
import 'package:learn_flutter_api/providers/settings_provider.dart';

const apiToken = String.fromEnvironment(
  'STOCK_API_TOKEN',
  defaultValue: 'suryaji',
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final candleApiServiceProvider = Provider<CandleApiService>((ref) {
  final endpoint = ref.watch(apiEndpointProvider);
  final uri = Uri.tryParse(endpoint);
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw const FormatException(
      'The configured API endpoint is not a valid URL.',
    );
  }
  return CandleApiService(ref.watch(httpClientProvider), uri, apiToken);
});

final candleRepositoryProvider = Provider<CandleRepository>(
  (ref) => CandleRepository(ref.watch(candleApiServiceProvider)),
);

final candleProvider = AsyncNotifierProvider<CandleController, CandleSnapshot>(
  CandleController.new,
);

class CandleSnapshot {
  const CandleSnapshot({required this.candle, required this.fetchedAt});

  final Candle candle;
  final DateTime fetchedAt;
}

class CandleController extends AsyncNotifier<CandleSnapshot> {
  bool _requestInProgress = false;

  @override
  Future<CandleSnapshot> build() {
    ref.watch(candleRepositoryProvider);
    return _fetchSnapshot();
  }

  Future<void> refresh() async {
    if (_requestInProgress) return;
    state = const AsyncLoading<CandleSnapshot>();
    state = await AsyncValue.guard(_fetchSnapshot);
  }

  Future<CandleSnapshot> _fetchSnapshot() async {
    if (_requestInProgress) {
      throw StateError('A candle request is already in progress.');
    }
    _requestInProgress = true;
    try {
      final candle = await ref.read(candleRepositoryProvider).fetchLatest();
      return CandleSnapshot(candle: candle, fetchedAt: DateTime.now());
    } on http.ClientException {
      throw const CandleApiException(
        'The network request failed. Check that the server is running, and '
        'verify the API endpoint and network connection.',
      );
    } on TimeoutException {
      throw const CandleApiException(
        'The API request timed out. Check the connection and try again.',
      );
    } finally {
      _requestInProgress = false;
    }
  }
}
```

### हिंदी में Core Logic

यह file global settings के लिए Riverpod `NotifierProvider`s देती है।
`themeModeProvider` system/light/dark choice, `refreshIntervalProvider`
`Duration?` और `apiEndpointProvider` URL string रखता है। `null` refresh
interval का मतलब polling बंद। Controllers की setter methods `state` बदलती
हैं; जो widgets `ref.watch()` करते हैं वे नए value पर rebuild/listen करते हैं।

**महत्वपूर्ण:** provider state अभी memory में रहती है, persistent storage में
नहीं।

### `lib/providers/settings_provider.dart` (41 lines)

``` dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = NotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);
final refreshIntervalProvider =
    NotifierProvider<RefreshIntervalController, Duration?>(
      RefreshIntervalController.new,
    );
final apiEndpointProvider = NotifierProvider<ApiEndpointController, String>(
  ApiEndpointController.new,
);

class ThemeModeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void setMode(ThemeMode mode) => state = mode;
}

class RefreshIntervalController extends Notifier<Duration?> {
  @override
  Duration? build() => const Duration(seconds: 5);

  void setInterval(Duration? interval) => state = interval;
}

class ApiEndpointController extends Notifier<String> {
  @override
  String build() {
    if (kIsWeb) return 'http://127.0.0.1:8081/api1';
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'http://10.0.2.2:8081/api1',
      _ => 'http://127.0.0.1:8081/api1',
    };
  }

  void setEndpoint(String endpoint) => state = endpoint;
}
```

### हिंदी में Core Logic

ये unit tests `Candle.fromJson()` को valid और invalid data के साथ जाँचते हैं।
Valid JSON सही fields बनाता है; malformed timestamp, non-number prices या
inconsistent high/low पर `FormatException` अपेक्षित है। इससे data validation
UI या live server पर निर्भर हुए बिना test हो सकती है।

### `test/data/models/candle_test.dart` (42 lines)

``` dart
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_flutter_api/data/models/candle.dart';

void main() {
  group('Candle.fromJson', () {
    test('parses the documented ISO timestamp and numeric OHLC values', () {
      final candle = Candle.fromJson({
        'time': '2026-10-25T10:20:30',
        'open': 120,
        'high': 128.5,
        'low': 115.25,
        'close': 124.75,
      });

      expect(candle.time, DateTime(2026, 10, 25, 10, 20, 30));
      expect(candle.open, 120);
      expect(candle.high, 128.5);
      expect(candle.low, 115.25);
      expect(candle.close, 124.75);
    });

    test('rejects missing or incorrectly typed fields', () {
      expect(
        () => Candle.fromJson({'time': 'not-a-date'}),
        throwsA(isA<FormatException>()),
      );
    });

    test('rejects inconsistent OHLC values', () {
      expect(
        () => Candle.fromJson({
          'time': '2026-10-25T10:20:30Z',
          'open': 121,
          'high': 120,
          'low': 119,
          'close': 120,
        }),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
```

### हिंदी में Core Logic

ये tests real network के बजाय mocked HTTP client से API service को जाँचते हैं।
इससे request URL/headers, success response, 401, अन्य HTTP errors और
malformed JSON के cases repeatably verify होते हैं। Token header का test
सुनिश्चित करता है कि `Authorization: Bearer ...` सही भेजा जा रहा है।

**फायदा:** server चालू किए बिना API behavior की regression testing संभव है।

### `test/data/services/candle_api_service_test.dart` (94 lines)

``` dart
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learn_flutter_api/data/services/candle_api_service.dart';

void main() {
  const responseBody = '''
    {"time":"2026-10-25T10:20:30","open":120,"high":128,"low":115,"close":124}
  ''';

  test('sends a Bearer token and parses a successful response', () async {
    late http.Request capturedRequest;
    final client = MockClient((request) async {
      capturedRequest = request;
      return http.Response(responseBody, 200);
    });
    final service = CandleApiService(
      client,
      Uri.parse('http://localhost:8081/api1'),
      'test-token',
    );

    final candle = await service.fetchCandle();

    expect(capturedRequest.headers['authorization'], 'Bearer test-token');
    expect(candle.close, 124);
    client.close();
  });

  test('returns a useful error for unauthorized requests', () async {
    final client = MockClient(
      (_) async => http.Response('{"detail":"Unauthorized"}', 401),
    );
    final service = CandleApiService(
      client,
      Uri.parse('http://localhost:8081/api1'),
      'wrong-token',
    );

    await expectLater(
      service.fetchCandle(),
      throwsA(
        isA<CandleApiException>().having(
          (error) => error.message,
          'message',
          contains('HTTP 401'),
        ),
      ),
    );
    client.close();
  });

  test('rejects invalid JSON and non-success HTTP status codes', () async {
    final badJsonClient = MockClient(
      (_) async => http.Response('{invalid', 200),
    );
    final badJsonService = CandleApiService(
      badJsonClient,
      Uri.parse('http://localhost:8081/api1'),
      'test-token',
    );
    await expectLater(
      badJsonService.fetchCandle(),
      throwsA(
        isA<CandleApiException>().having(
          (error) => error.message,
          'message',
          contains('Invalid candle response'),
        ),
      ),
    );
    badJsonClient.close();

    final serverErrorClient = MockClient(
      (_) async => http.Response('Unavailable', 503),
    );
    final serverErrorService = CandleApiService(
      serverErrorClient,
      Uri.parse('http://localhost:8081/api1'),
      'test-token',
    );
    await expectLater(
      serverErrorService.fetchCandle(),
      throwsA(
        isA<CandleApiException>().having(
          (error) => error.message,
          'message',
          contains('HTTP 503'),
        ),
      ),
    );
    serverErrorClient.close();
  });
}
```

### हिंदी में Core Logic

Widget tests UI को test environment में चलाकर loading, data/error
presentation, settings/theme changes और responsive widths जाँचते हैं। ये
tests यह सुनिश्चित करने में मदद करते हैं कि shared widgets या layout बदलने पर UI
टूटे नहीं।

**सीमा:** widget tests असली फोन की network reachability, firewall या
browser CORS को पूरी तरह replace नहीं करते; इनकी manual platform testing भी
जरूरी है।

### `test/widget_test.dart` (131 lines)

``` dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:learn_flutter_api/app/app.dart';
import 'package:learn_flutter_api/core/responsive/responsive_layout.dart';
import 'package:learn_flutter_api/features/settings/settings_screen.dart';
import 'package:learn_flutter_api/providers/candle_provider.dart';
import 'package:learn_flutter_api/providers/settings_provider.dart';

const _responseBody =
    '{"time":"2026-10-25T10:20:30","open":120,"high":128,"low":115,"close":124}';

Widget _app(http.Client client) => ProviderScope(
  overrides: [httpClientProvider.overrideWithValue(client)],
  child: const StockDashboardApp(),
);

void main() {
  testWidgets('polls the API automatically using the default interval', (
    tester,
  ) async {
    var requestCount = 0;
    final client = MockClient((_) async {
      requestCount++;
      final close = 121 + requestCount;
      return http.Response(
        '{"time":"2026-10-25T10:20:${requestCount.toString().padLeft(2, '0')}",'
        '"open":120,"high":128,"low":115,"close":$close}',
        200,
      );
    });

    final container = ProviderContainer();
    expect(container.read(refreshIntervalProvider), const Duration(seconds: 5));
    container.dispose();

    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();
    expect(requestCount, 1);

    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    expect(requestCount, 2);

    await tester.pumpWidget(const SizedBox.shrink());
    client.close();
  });

  testWidgets('shows loading then renders the API candle', (tester) async {
    final response = Completer<http.Response>();
    final client = MockClient((_) => response.future);
    await tester.pumpWidget(_app(client));
    expect(find.text('Connecting to stock API...'), findsOneWidget);

    response.complete(http.Response(_responseBody, 200));
    await tester.pumpAndSettle();

    expect(find.text('Market snapshot'), findsOneWidget);
    expect(
      find.text('Single candle returned by the server · not historical data'),
      findsOneWidget,
    );
    expect(find.text('128.00'), findsOneWidget);
    client.close();
  });

  testWidgets('shows an actionable error for an unauthorized API response', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response('{"detail":"Unauthorized"}', 401),
    );
    await tester.pumpWidget(_app(client));
    await tester.pumpAndSettle();

    expect(find.text('Could not load candle'), findsOneWidget);
    expect(find.textContaining('HTTP 401'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    client.close();
  });

  testWidgets('allows selecting a theme in settings', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );

    await tester.tap(find.byType(DropdownButtonFormField<ThemeMode>).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark').last);
    await tester.pumpAndSettle();

    expect(container.read(themeModeProvider), ThemeMode.dark);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'renders the chart without overflow at phone, tablet, and desktop widths',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      final client = MockClient((_) async => http.Response(_responseBody, 200));

      for (final width in [390.0, 800.0, 1440.0]) {
        tester.view.physicalSize = Size(width, 1000);
        await tester.pumpWidget(_app(client));
        await tester.pumpAndSettle();
        expect(find.text('Latest candle'), findsOneWidget);
        final exception = tester.takeException();
        expect(exception, isNull, reason: 'logical width $width');
      }

      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      client.close();
    },
  );

  test('uses configured responsive width breakpoints', () {
    expect(ResponsiveLayout.sizeFor(390), ScreenSize.mobile);
    expect(ResponsiveLayout.sizeFor(800), ScreenSize.tablet);
    expect(ResponsiveLayout.sizeFor(1440), ScreenSize.desktop);
  });
}
```

### हिंदी में Core Logic

यह Flutter package manifest है। `name`, SDK constraints, dependencies और
dev dependencies यहीं घोषित होते हैं। `flutter_riverpod`, `go_router`,
`http`, `fl_chart` और `intl` runtime features के लिए हैं; `flutter_test` और
lint package development/testing के लिए हैं। `flutter pub get` इन
dependencies को resolve करता है।

**याद रखें:** dependency बदलने पर `pubspec.lock` को भी version control में रखें
ताकि builds में resolved versions consistent रहें।

### `pubspec.yaml` (94 lines)

``` yaml
name: learn_flutter_api
description: "A new Flutter project."
# The following line prevents the package from being accidentally published to
# pub.dev using `flutter pub publish`. This is preferred for private packages.
publish_to: 'none' # Remove this line if you wish to publish to pub.dev

# The following defines the version and build number for your application.
# A version number is three numbers separated by dots, like 1.2.43
# followed by an optional build number separated by a +.
# Both the version and the builder number may be overridden in flutter
# build by specifying --build-name and --build-number, respectively.
# In Android, build-name is used as versionName while build-number used as versionCode.
# Read more about Android versioning at https://developer.android.com/studio/publish/versioning
# In iOS, build-name is used as CFBundleShortVersionString while build-number is used as CFBundleVersion.
# Read more about iOS versioning at
# https://developer.apple.com/library/archive/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html
# In Windows, build-name is used as the major, minor, and patch parts
# of the product and file versions while build-number is used as the build suffix.
version: 1.0.0+1

environment:
  sdk: ^3.13.5

# Dependencies specify other packages that your package needs in order to work.
# To automatically upgrade your package dependencies to the latest versions
# consider running `flutter pub upgrade --major-versions`. Alternatively,
# dependencies can be manually updated by changing the version numbers below to
# the latest version available on pub.dev. To see which dependencies have newer
# versions available, run `flutter pub outdated`.
dependencies:
  flutter:
    sdk: flutter

  # The following adds the Cupertino Icons font to your application.
  # Use with the CupertinoIcons class for iOS style icons.
  cupertino_icons: ^1.0.8
  flutter_riverpod: ^3.4.3
  go_router: ^18.1.1
  http: ^1.6.0
  fl_chart: ^1.3.0
  intl: ^0.20.3

dev_dependencies:
  flutter_test:
    sdk: flutter

  # The "flutter_lints" package below contains a set of recommended lints to
  # encourage good coding practices. The lint set provided by the package is
  # activated in the `analysis_options.yaml` file located at the root of your
  # package. See that file for information about deactivating specific lint
  # rules and activating additional ones.
  flutter_lints: ^6.0.0

# For information on the generic Dart part of this file, see the
# following page: https://dart.dev/tools/pub/pubspec

# The following section is specific to Flutter packages.
flutter:

  # The following line ensures that the Material Icons font is
  # included with your application, so that you can use the icons in
  # the material Icons class.
  uses-material-design: true

  # To add assets to your application, add an assets section, like this:
  # assets:
  #   - images/a_dot_burr.jpeg
  #   - images/a_dot_ham.jpeg

  # An image asset can refer to one or more resolution-specific "variants", see
  # https://flutter.dev/to/resolution-aware-images

  # For details regarding adding assets from package dependencies, see
  # https://flutter.dev/to/asset-from-package

  # To add custom fonts to your application, add a fonts section here,
  # in this "flutter" section. Each entry in this list should have a
  # "family" key with the font family name, and a "fonts" key with a
  # list giving the asset and other descriptors for the font. For
  # example:
  # fonts:
  #   - family: Schyler
  #     fonts:
  #       - asset: fonts/Schyler-Regular.ttf
  #       - asset: fonts/Schyler-Italic.ttf
  #         style: italic
  #   - family: Trajan Pro
  #     fonts:
  #       - asset: fonts/TrajanPro.ttf
  #       - asset: fonts/TrajanPro_Bold.ttf
  #         weight: 700
  #
  # For details regarding fonts from package dependencies,
  # see https://flutter.dev/to/font-from-package
```

### हिंदी में Core Logic

Android manifest app की platform-level permissions और configuration
बताता है। Local API access के लिए Internet permission और development HTTP
configuration आवश्यक हो सकती है। Cleartext HTTP केवल local development के
लिए है; production में HTTPS अपनाएँ और transport security को अनावश्यक रूप से
कमजोर न करें।

### `android/app/src/main/AndroidManifest.xml` (47 lines)

``` xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.INTERNET" />
    <application
        android:label="Candleboard"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="true">
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:taskAffinity=""
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">
            <!-- Specifies an Android theme to apply to this Activity as soon as
                 the Android process has started. This theme is visible to the user
                 while the Flutter UI initializes. After that, this theme continues
                 to determine the Window background behind the Flutter UI. -->
            <meta-data
              android:name="io.flutter.embedding.android.NormalTheme"
              android:resource="@style/NormalTheme"
              />
            <intent-filter>
                <action android:name="android.intent.action.MAIN"/>
                <category android:name="android.intent.category.LAUNCHER"/>
            </intent-filter>
        </activity>
        <!-- Don't delete the meta-data below.
             This is used by the Flutter tool to generate GeneratedPluginRegistrant.java -->
        <meta-data
            android:name="flutterEmbedding"
            android:value="2" />
    </application>
    <!-- Required to query activities that can process text, see:
         https://developer.android.com/training/package-visibility and
         https://developer.android.com/reference/android/content/Intent#ACTION_PROCESS_TEXT.

         In particular, this is used by the Flutter engine in io.flutter.plugin.text.ProcessTextPlugin. -->
    <queries>
        <intent>
            <action android:name="android.intent.action.PROCESS_TEXT"/>
            <data android:mimeType="text/plain"/>
        </intent>
    </queries>
</manifest>
```

### हिंदी में Core Logic

यह iOS app की platform configuration file है। Local network/development
HTTP requests के लिए इसमें network transport settings हो सकती हैं। iOS
permissions और App Transport Security settings को केवल आवश्यक सीमा तक खोलें।
Production API के लिए HTTPS और सही deployment configuration इस्तेमाल करें।

### `ios/Runner/Info.plist` (77 lines)

``` xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CADisableMinimumFrameDurationOnPhone</key>
    <true/>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>Candleboard</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>learn_flutter_api</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>$(FLUTTER_BUILD_NAME)</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>$(FLUTTER_BUILD_NUMBER)</string>
    <key>LSRequiresIPhoneOS</key>
    <true/>
    <key>NSLocalNetworkUsageDescription</key>
    <string>Connect to your configured local stock API server.</string>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsLocalNetworking</key>
        <true/>
    </dict>
    <key>UIApplicationSceneManifest</key>
    <dict>
        <key>UIApplicationSupportsMultipleScenes</key>
        <false/>
        <key>UISceneConfigurations</key>
        <dict>
            <key>UIWindowSceneSessionRoleApplication</key>
            <array>
                <dict>
                    <key>UISceneClassName</key>
                    <string>UIWindowScene</string>
                    <key>UISceneConfigurationName</key>
                    <string>flutter</string>
                    <key>UISceneDelegateClassName</key>
                    <string>$(PRODUCT_MODULE_NAME).SceneDelegate</string>
                    <key>UISceneStoryboardFile</key>
                    <string>Main</string>
                </dict>
            </array>
        </dict>
    </dict>
    <key>UIApplicationSupportsIndirectInputEvents</key>
    <true/>
    <key>UILaunchStoryboardName</key>
    <string>LaunchScreen</string>
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
</dict>
</plist>
```

### हिंदी में Core Logic

यह supplied FastAPI dummy backend है। `FastAPI()` app बनाता है और
`HTTPBearer` request के Authorization header से Bearer credentials पढ़ता है।
`/api1` route token verify करता है; mismatch होने पर HTTP 401 देता है। Valid
token पर random close, open, high और low calculate करके timestamp सहित
JSON response लौटाता है। `/` route server status और endpoint list देता है।

**महत्वपूर्ण:** यह dummy server हर request पर नई random candle बनाता है। यह
वास्तविक market feed या historical database नहीं है। Physical device से
testing के लिए server को reachable network interface पर bind करना और
firewall configure करना पड़ सकता है; untrusted network पर development
server expose न करें।

### `../a4_7api_server_stock.py` (87 lines)

``` python
# ==================================================
# 🔹 Imports
# ===============================================

# Start with:
# python -m uvicorn a4_7api_server_stock:app --host 127.0.0.1 --port 8081 --reload

import random
from datetime import datetime

from fastapi import FastAPI, HTTPException, Depends
from fastapi.middleware.cors import CORSMiddleware
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from pydantic import BaseModel


# ==================================================
# 🔹 FastAPI App
# ==================================================

app = FastAPI(title="Stock API", version="1.0.0")
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["GET"],
    allow_headers=["Authorization"],
)


# ==================================================
# 🔹 Security
# ==================================================

security = HTTPBearer()

API_TOKEN = "suryaji"


# ==================================================
# 🔹 Response Schema
# ==================================================


class CandleDataResponse(BaseModel):
    time: datetime
    open: float
    high: float
    low: float
    close: float


# ==================================================
# 🔹 Candle Data API
# ==================================================
@app.get("/api1", response_model=CandleDataResponse)
# Generates a new random candle on every request.
def get_random_candle(credentials: HTTPAuthorizationCredentials = Depends(security)):
    if credentials.credentials != API_TOKEN:
        raise HTTPException(status_code=401, detail="Unauthorized")

    close = round(random.uniform(100, 150), 2)
    open_price = close + random.randint(-15, 15)
    high = max(open_price, close) + random.randint(1, 5)
    low = min(open_price, close) - random.randint(1, 5)
    return {
        "time": datetime.now(),
        "open": round(open_price, 2),
        "high": round(high, 2),
        "low": round(low, 2),
        "close": close,
    }


# ==================================================
# 🔹 Root
# ==================================================


@app.get("/")
# Purpose: Executes the root workflow.
def root():

    return {
        "status": "online",
        "message": "stock API Server is running",
        "endpoints": ["/api1"],
    }
```

# हिंदी में Quick Revision: मुख्य concepts

-   **`const`:** compile-time constant; जहाँ संभव हो immutable
    configuration के लिए।
-   **`final`:** variable को एक बार assign किया जा सकता है।
-   **`Future<T>`:** ऐसा asynchronous operation जो बाद में `T` value या
    error देगा।
-   **`async` / `await`:** asynchronous code को पढ़ने योग्य क्रम में लिखने का
    तरीका।
-   **`Provider`:** dependency या value उपलब्ध कराता है।
-   **`ref.watch`:** value बदलने पर consumer को update/rebuild कराता है।
-   **`ref.read`:** एक बार value या notifier पढ़ता है, आमतौर पर action के
    लिए।
-   **`AsyncValue`:** loading, error और data states का representation।
-   **`ConsumerWidget`:** ऐसा widget जो Riverpod providers पढ़ता है।
-   **`ConsumerStatefulWidget`:** Riverpod access के साथ local
    lifecycle/state की जरूरत होने पर।
-   **`dispose()`:** timer/controller/client जैसे resources साफ करने का
    lifecycle point।
-   **`BuildContext`:** widget tree में location/context; theme,
    navigation और inherited values तक पहुँच देता है।
-   **`ColorScheme`:** Material 3 roles वाले colors का semantic
    collection।
-   **`LayoutBuilder`:** parent से उपलब्ध layout constraints पढ़ता है।
-   **`MediaQuery`:** app window/screen की dimensions और accessibility
    settings बताता है।
-   **`GoRouter`:** paths और screens के बीच navigation को manage करता है।
-   **`HTTP 401`:** request authentication credentials स्वीकार नहीं हुए।
-   **`OHLC`:** Open, High, Low, Close---एक candle की चार प्रमुख price
    values।
-   **Polling:** निश्चित interval पर API को बार-बार request करना; यह
    WebSocket push नहीं है।

## एक end-to-end request को याद रखें

1.  Dashboard `candleProvider` को watch करता है।
2.  `CandleController` repository को call करता है।
3.  Repository API service से `fetchCandle()` करवाता है।
4.  Service endpoint पर Bearer token के साथ GET भेजती है।
5.  FastAPI JSON response देता है।
6.  `Candle.fromJson()` timestamp, numbers और OHLC consistency validate
    करता है।
7.  Riverpod state में `CandleSnapshot` आता है।
8.  Dashboard `CandleChart` और `OhlcSummary` को वही typed candle देता है।

अगर API fail हो, तो fake candle न बनाएं: error state दिखाएँ और retry उपलब्ध
रखें।
