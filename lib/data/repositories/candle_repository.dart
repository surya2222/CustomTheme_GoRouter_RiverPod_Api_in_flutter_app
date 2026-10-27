import 'package:learn_flutter_api/data/models/candle.dart';

/// Candle API Service को import किया गया है।
/// यह server से candle data fetch करने की जिम्मेदारी निभाती है।
import 'package:learn_flutter_api/data/services/candle_api_service.dart';

/// Candle Model को import किया गया है।
/// यह Candle object और उसके OHLC fields को define करता है।
/// Repository Layer:
/// UI या Provider को सीधे API Service पर निर्भर रहने के बजाय
/// Repository के माध्यम से data प्राप्त करने देता है।
class CandleRepository {
  /// Constructor:
  /// CandleApiService का object बाहर से प्राप्त करता है।
  ///
  /// const constructor का उपयोग तब संभव है जब दी गई dependency
  /// भी const context में बनाई जा सकती हो।
  const CandleRepository(this._service);

  /// API Service का reference।
  ///
  /// private field है क्योंकि नाम की शुरुआत underscore (_) से है।
  /// यह field इस Dart library के बाहर सीधे accessible नहीं है।
  final CandleApiService _service;

  /// Server से latest candle प्राप्त करता है।
  ///
  /// Future<Candle> का अर्थ:
  /// अभी result उपलब्ध न भी हो, लेकिन भविष्य में एक Candle object मिलेगा।
  ///
  /// => एक-line function का shorthand syntax है।
  Future<Candle> fetchLatest() => _service.fetchCandle();
}
