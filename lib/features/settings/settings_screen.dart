import 'package:flutter/material.dart';

// Riverpod के ConsumerStatefulWidget, ConsumerState और ref के लिए।
import 'package:flutter_riverpod/flutter_riverpod.dart';

// App की centralized spacing और design values।
import 'package:learn_flutter_api/app/theme/design_tokens.dart';

// Reusable button widget।
import 'package:learn_flutter_api/core/widgets/app_button.dart';

// Reusable card widget।
import 'package:learn_flutter_api/core/widgets/app_card.dart';

// App का common layout और navigation।
import 'package:learn_flutter_api/core/widgets/app_scaffold.dart';

// Theme, API endpoint और refresh interval वाले providers।
import 'package:learn_flutter_api/providers/settings_provider.dart';

/// Settings Screen:
/// यूज़र को theme, refresh interval और API endpoint बदलने देती है।
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  /// इस widget की mutable state को manage करने के लिए State object बनाएँ।
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // TextField के text को पढ़ने और नियंत्रित करने के लिए controller।
  // late का अर्थ है कि variable को बाद में, उपयोग से पहले initialize करेंगे।
  // final का अर्थ है कि controller reference को दोबारा assign नहीं करेंगे।
  late final TextEditingController _endpointController;

  // URL गलत होने पर error message यहाँ store होगा।
  // शुरुआत में null यानी कोई validation error नहीं है।
  String? _endpointError;

  @override
  void initState() {
    super.initState();

    // Settings खुलने पर provider से वर्तमान API endpoint पढ़ें।
    // उसी value को TextField में शुरुआती text के रूप में दिखाएँ।
    _endpointController = TextEditingController(
      text: ref.read(apiEndpointProvider),
    );
  }

  @override
  void dispose() {
    // Controller अब उपयोग में नहीं है, इसलिए उसे dispose करें।
    // इससे उससे जुड़े resources सही तरह release होते हैं।
    _endpointController.dispose();

    super.dispose();
  }

  /// TextField में दिए गए endpoint को validate और save करता है।
  void _saveEndpoint() {
    // Text के आगे-पीछे के whitespace हटाएँ।
    // tryParse गलत URL पर null दे सकता है।
    final uri = Uri.tryParse(_endpointController.text.trim());

    // URL की basic validation:
    // 1. URI parse होनी चाहिए।
    // 2. Scheme मौजूद होना चाहिए।
    // 3. Host खाली नहीं होना चाहिए।
    // 4. Scheme केवल HTTP या HTTPS होना चाहिए।
    if (uri == null ||
        !uri.hasScheme ||
        uri.host.isEmpty ||
        (uri.scheme != 'http' && uri.scheme != 'https')) {
      // Error message दिखाने के लिए widget की local state बदलें।
      // setState के कारण UI दोबारा build होगी।
      setState(() {
        _endpointError = 'Enter a valid HTTP or HTTPS URL.';
      });

      // Invalid URL को save नहीं करना है।
      return;
    }

    // URL सही है, इसलिए Riverpod provider के notifier से endpoint save करें।
    // setEndpoint() की वास्तविक implementation settings_provider.dart में होगी।
    ref.read(apiEndpointProvider.notifier).setEndpoint(uri.toString());

    // पुराना validation error हटाएँ।
    setState(() {
      _endpointError = null;
    });

    // यूज़र को सफलता का message दिखाएँ।
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('API endpoint updated.')));
  }

  @override
  Widget build(BuildContext context) {
    // Theme mode को watch करें।
    // Provider बदलने पर Settings UI नई value के साथ rebuild होगी।
    final themeMode = ref.watch(themeModeProvider);

    // वर्तमान auto-refresh interval को watch करें।
    // null का अर्थ है कि auto-refresh बंद है।
    final refreshInterval = ref.watch(refreshIntervalProvider);

    // Common AppScaffold में Settings screen का content रखें।
    return AppScaffold(
      title: 'Settings',
      route: '/settings',

      // Content लंबा होने पर scroll करने दें।
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen का मुख्य heading।
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),

            const SizedBox(height: DesignTokens.space2),

            // Settings का छोटा विवरण।
            Text(
              'Adjust the appearance and connection for this dashboard.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: DesignTokens.space5),

            // Card 1: Appearance और Refresh settings।
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Appearance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 8),

                  // ThemeMode के लिए dropdown।
                  DropdownButtonFormField<ThemeMode>(
                    // Theme बदलने पर dropdown को नई key मिलती है।
                    // इससे selected value को नए themeMode से synchronize करने में मदद मिलती है।
                    key: ValueKey(themeMode),

                    // वर्तमान selected theme।
                    initialValue: themeMode,

                    decoration: const InputDecoration(labelText: 'Theme'),

                    // यूज़र के लिए उपलब्ध theme विकल्प।
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

                    // यूज़र theme बदलता है तो provider update करें।
                    onChanged: (value) {
                      // Null value को ignore करें।
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

                  // API polling interval के लिए dropdown।
                  DropdownButtonFormField<int>(
                    // null interval को 0 से represent करें।
                    // ValueKey बदलने पर dropdown नई selected value के साथ rebuild होगा।
                    key: ValueKey(refreshInterval?.inSeconds ?? 0),

                    // null = Off; अन्यथा seconds में interval।
                    initialValue: refreshInterval?.inSeconds ?? 0,

                    decoration: const InputDecoration(
                      labelText: 'Poll API for new data',
                    ),

                    items: const [
                      // 0 का अर्थ है auto-refresh बंद।
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

                    // Selected seconds को Duration में बदलकर provider में save करें।
                    onChanged: (seconds) {
                      if (seconds != null) {
                        ref
                            .read(refreshIntervalProvider.notifier)
                            .setInterval(
                              // 0 को null में बदलें, ताकि Timer बंद हो।
                              seconds == 0 ? null : Duration(seconds: seconds),
                            );
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: DesignTokens.space4),

            // Card 2: API connection settings।
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'API connection',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 6),

                  // यूज़र को endpoint और physical device के LAN IP की जानकारी।
                  Text(
                    'Set the full /api1 URL. For a physical device, use your computer’s LAN IP address.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: DesignTokens.space4),

                  // API URL edit करने के लिए TextField।
                  TextField(
                    // Controller TextField का text manage करता है।
                    controller: _endpointController,

                    // URL टाइप करने पर उपयुक्त keyboard दिखाने का संकेत।
                    keyboardType: TextInputType.url,

                    // Keyboard पर Done दबाने पर save करने का प्रयास।
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveEndpoint(),

                    decoration: InputDecoration(
                      labelText: 'API endpoint',

                      // URL का उदाहरण।
                      hintText: 'http://192.168.1.10:8081/api1',

                      // Validation error होने पर TextField के नीचे दिखेगा।
                      errorText: _endpointError,
                    ),
                  ),

                  const SizedBox(height: DesignTokens.space4),

                  // Endpoint save करने का button।
                  AppButton(
                    label: 'Save endpoint',
                    icon: Icons.save_outlined,
                    onPressed: _saveEndpoint,
                  ),

                  const SizedBox(height: DesignTokens.space3),

                  // Demo token को command line से देने की जानकारी।
                  // Real credentials को client application में hardcode न करें।
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
