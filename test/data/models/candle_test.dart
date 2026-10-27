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
