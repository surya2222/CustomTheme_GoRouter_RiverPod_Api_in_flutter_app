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
