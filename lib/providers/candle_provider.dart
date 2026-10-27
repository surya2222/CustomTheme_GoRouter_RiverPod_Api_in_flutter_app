import 'dart:async'; // TimeoutException जैसी async utilities के लिए।

// Riverpod providers और AsyncNotifier के लिए।
import 'package:flutter_riverpod/flutter_riverpod.dart';

// HTTP request और ClientException के लिए।
import 'package:http/http.dart' as http;

// Candle का OHLC data रखने वाला model।
import 'package:learn_flutter_api/data/models/candle.dart';

// API Service और Model के बीच repository layer।
import 'package:learn_flutter_api/data/repositories/candle_repository.dart';

// Server से HTTP request करने वाली service।
import 'package:learn_flutter_api/data/services/candle_api_service.dart';

// API endpoint और अन्य settings के providers।
import 'package:learn_flutter_api/providers/settings_provider.dart';

// ------------------------------------------------------------
// 1. API TOKEN
// ------------------------------------------------------------

// --dart-define से token पढ़ें।
// यदि token नहीं दिया गया, तो 'suryaji' default value होगी।
const apiToken = String.fromEnvironment(
  'STOCK_API_TOKEN',
  defaultValue: 'suryaji',
);

// ------------------------------------------------------------
// 2. HTTP CLIENT PROVIDER
// ------------------------------------------------------------

// HTTP Client को create और share करने वाला Provider।
final httpClientProvider = Provider<http.Client>((ref) {
  // HTTP requests भेजने के लिए Client बनाएँ।
  final client = http.Client();

  // Provider dispose होने पर Client बंद करें।
  // इससे Client के resources सही तरह release होते हैं।
  ref.onDispose(client.close);

  // बनाया हुआ Client अन्य providers को दें।
  return client;
});

// ------------------------------------------------------------
// 3. CANDLE API SERVICE PROVIDER
// ------------------------------------------------------------

// API endpoint, HTTP Client और token से API Service बनाएँ।
final candleApiServiceProvider = Provider<CandleApiService>((ref) {
  // वर्तमान API endpoint पढ़ें।
  // Endpoint बदलने पर यह provider rebuild हो सकता है।
  final endpoint = ref.watch(apiEndpointProvider);

  // String URL को Uri object में बदलने का प्रयास।
  final uri = Uri.tryParse(endpoint);

  // URL की basic validation करें।
  if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
    throw const FormatException(
      'The configured API endpoint is not a valid URL.',
    );
  }

  // HTTP Client, URI और token देकर Service बनाएँ।
  return CandleApiService(ref.watch(httpClientProvider), uri, apiToken);
});

// ------------------------------------------------------------
// 4. CANDLE REPOSITORY PROVIDER
// ------------------------------------------------------------

// Repository को API Service की dependency दें।
final candleRepositoryProvider = Provider<CandleRepository>(
  (ref) => CandleRepository(ref.watch(candleApiServiceProvider)),
);

// ------------------------------------------------------------
// 5. CANDLE ASYNC NOTIFIER PROVIDER
// ------------------------------------------------------------

// यह Provider CandleController को manage करता है।
// इसकी asynchronous state का data type CandleSnapshot है।
final candleProvider = AsyncNotifierProvider<CandleController, CandleSnapshot>(
  CandleController.new,
);

// ------------------------------------------------------------
// 6. CANDLE SNAPSHOT MODEL
// ------------------------------------------------------------

// Candle के साथ data fetch होने का समय भी रखता है।
class CandleSnapshot {
  const CandleSnapshot({required this.candle, required this.fetchedAt});

  // Server से प्राप्त Candle object।
  final Candle candle;

  // App में response प्राप्त होने का समय।
  final DateTime fetchedAt;
}

// ------------------------------------------------------------
// 7. CANDLE CONTROLLER
// ------------------------------------------------------------

class CandleController extends AsyncNotifier<CandleSnapshot> {
  // बताता है कि request पहले से चल रही है या नहीं।
  // शुरुआत में कोई request नहीं चल रही।
  bool _requestInProgress = false;

  // Provider initialize होने पर Riverpod इस method को चलाता है।
  @override
  Future<CandleSnapshot> build() {
    // Repository को watch करें।
    // इसकी dependency बदलने पर controller दोबारा initialize हो सकता है।
    ref.watch(candleRepositoryProvider);

    // पहली Candle fetch करें।
    return _fetchSnapshot();
  }

  // ----------------------------------------------------------
  // 8. MANUAL / AUTOMATIC REFRESH
  // ----------------------------------------------------------

  Future<void> refresh() async {
    // यदि request पहले से चल रही है, तो duplicate refresh न करें।
    if (_requestInProgress) return;

    // UI को Loading state दें।
    state = const AsyncLoading<CandleSnapshot>();

    // Request सफल हो तो Data, असफल हो तो Error state मिलेगी।
    state = await AsyncValue.guard(_fetchSnapshot);
  }

  // ----------------------------------------------------------
  // 9. ACTUAL DATA FETCHING
  // ----------------------------------------------------------

  Future<CandleSnapshot> _fetchSnapshot() async {
    // यदि दूसरी request पहले से चल रही है,
    // तो नई request को error के साथ रोकें।
    if (_requestInProgress) {
      throw StateError('A candle request is already in progress.');
    }

    // अब request चल रही है।
    _requestInProgress = true;

    try {
      // Repository के माध्यम से latest Candle प्राप्त करें।
      final candle = await ref.read(candleRepositoryProvider).fetchLatest();

      // Candle के साथ fetch time रखकर snapshot बनाएँ।
      return CandleSnapshot(candle: candle, fetchedAt: DateTime.now());
    } on http.ClientException {
      // HTTP Client से संबंधित network error को
      // अधिक उपयोगी API error में बदलें।
      throw const CandleApiException(
        'The network request failed. Check that the server is running, and '
        'verify the API endpoint and network connection.',
      );
    } on TimeoutException {
      // Request निर्धारित समय में पूरी नहीं हुई।
      throw const CandleApiException(
        'The API request timed out. Check the connection and try again.',
      );
    } finally {
      // Success या error — दोनों स्थितियों में
      // request flag को reset करना जरूरी है।
      _requestInProgress = false;
    }
  }
}
