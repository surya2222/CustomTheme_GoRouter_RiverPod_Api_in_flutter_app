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
