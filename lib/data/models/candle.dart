class Candle {
  /// Candle Model:
  /// यह class एक Candlestick की जानकारी रखती है।
  ///
  /// OHLC का अर्थ:
  /// Open  = कैंडल खुलने का प्राइस
  /// High  = उस कैंडल का सबसे अधिक प्राइस
  /// Low   = उस कैंडल का सबसे कम प्राइस
  /// Close = कैंडल बंद होने का प्राइस

  // const constructor:
  // जब सभी values compile-time constants हों,
  // तो इस constructor से constant object बनाया जा सकता है।
  const Candle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });

  // final का अर्थ है कि object बनने के बाद इन fields
  // को दोबारा कोई दूसरी value assign नहीं कर सकते।
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;

  // Factory constructor:
  // JSON Map को Candle object में बदलता है।
  // साथ ही गलत data मिलने पर FormatException देता है।
  factory Candle.fromJson(Map<String, dynamic> json) {
    // JSON से time की value प्राप्त करें।
    final timeValue = json['time'];

    // जाँचें कि time String है या नहीं।
    // is! का अर्थ है "इस type का नहीं है"।
    if (timeValue is! String) {
      throw const FormatException(
        'Candle field "time" must be an ISO 8601 string.',
      );
    }

    // String को DateTime में बदलने का प्रयास।
    // गलत date होने पर tryParse null देता है।
    final time = DateTime.tryParse(timeValue);

    // यदि date convert नहीं हुई, तो error दें।
    if (time == null) {
      throw const FormatException('Candle field "time" is not a valid date.');
    }

    // Local helper function:
    // JSON से किसी OHLC price को पढ़ती है और validate करती है।
    double readPrice(String key) {
      // key के आधार पर price प्राप्त करें।
      // उदाहरण: json['open'] या json['high']
      final value = json[key];

      // num में int और double दोनों शामिल होते हैं।
      // isFinite NaN और Infinity जैसी values को रोकता है।
      if (value is! num || !value.isFinite) {
        throw FormatException('Candle field "$key" must be a finite number.');
      }

      // Price को double में बदलकर return करें।
      // उदाहरण: 250 को 250.0 बनाया जा सकता है।
      return value.toDouble();
    }

    // सभी चार prices पढ़ें और validate करें।
    final open = readPrice('open');
    final high = readPrice('high');
    final low = readPrice('low');
    final close = readPrice('close');

    // OHLC values के बीच logical consistency जाँचें।
    if (high < low ||
        high < open ||
        high < close ||
        low > open ||
        low > close) {
      throw const FormatException('Candle OHLC values are inconsistent.');
    }

    // सभी values सही हैं, इसलिए Candle object बनाएँ।
    return Candle(time: time, open: open, high: high, low: low, close: close);
  }
}
