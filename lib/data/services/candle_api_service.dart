/// JSON encode/decode करने के लिए Dart का built-in package।
library;

import 'dart:convert';

/// HTTP GET request भेजने के लिए http package।
import 'package:http/http.dart' as http;

/// JSON data को Candle object में बदलने वाला Model।
import 'package:learn_flutter_api/data/models/candle.dart';

/// API से संबंधित errors को represent करने वाली custom Exception।
class CandleApiException implements Exception {
  // Error message constructor के माध्यम से प्राप्त होता है।
  const CandleApiException(this.message);

  // Error का message store करता है।
  final String message;

  // Exception को print करने पर केवल message दिखेगा।
  @override
  String toString() => message;
}

/// API Service:
/// इसका काम server से Candle data प्राप्त करना है।
class CandleApiService {
  /// Dependencies constructor के माध्यम से प्राप्त होती हैं।
  ///
  /// _client   = HTTP request भेजने के लिए
  /// _endpoint = API का URL
  /// _token    = API authentication token
  const CandleApiService(this._client, this._endpoint, this._token);

  /// HTTP requests भेजने वाला client।
  /// इसे बाहर से देने पर testing और client management आसान होता है।
  final http.Client _client;

  /// जिस API endpoint पर request भेजनी है।
  /// Uri URL को represent करने वाला Dart type है।
  final Uri _endpoint;

  /// Server को authenticate करने के लिए token।
  final String _token;

  /// Server से एक Candle प्राप्त करता है।
  ///
  /// async के कारण इस function के अंदर await इस्तेमाल कर सकते हैं।
  /// Future<Candle> बताता है कि result बाद में Candle object के रूप में मिलेगा।
  Future<Candle> fetchCandle() async {
    // HTTP GET request भेजें।
    // Authorization header में Bearer Token भेजा जाता है।
    // Accept header बताता है कि हमें JSON response चाहिए।
    final responseFuture = _client.get(
      _endpoint,
      headers: {
        'Authorization': 'Bearer $_token',
        'Accept': 'application/json',
      },
    );

    // Response का इंतजार करें।
    // 15 सेकंड में response नहीं आया तो TimeoutException हो सकती है।
    final response = await responseFuture.timeout(const Duration(seconds: 15));

    // HTTP 401 का अर्थ है कि server ने authentication स्वीकार नहीं किया।
    if (response.statusCode == 401) {
      throw const CandleApiException(
        'The API rejected the token (HTTP 401). Check the demo token or server configuration.',
      );
    }

    // 200 से 299 तक के status codes सामान्यतः successful responses होते हैं।
    // इनके बाहर आने पर custom API exception throw करें।
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw CandleApiException('The API returned HTTP ${response.statusCode}.');
    }

    // Response body को JSON में decode करें और Candle object बनाएँ।
    try {
      // JSON text को Dart data में बदलें।
      final decoded = jsonDecode(response.body);

      // इस API से एक JSON object अपेक्षित है, JSON list नहीं।
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }

      // JSON object को Candle model में बदलें।
      // Candle.fromJson() time और OHLC values की validation करता है।
      return Candle.fromJson(decoded);
    } on FormatException catch (error) {
      // JSON parsing या Candle validation की FormatException को
      // API से संबंधित readable error में बदलें।
      throw CandleApiException('Invalid candle response: ${error.message}');
    }
  }
}
