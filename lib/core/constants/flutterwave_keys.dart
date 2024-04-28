import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class FlutterWaveKeys {
  static const _mode = kDebugMode ? 'TEST' : 'LIVE';
  static final public = dotenv.env['FLUTTERWAVE_${_mode}_PUBLIC_KEY']!;
  static final secret = dotenv.env['FLUTTERWAVE_${_mode}_SECRET_KEY']!;
  static final encryption = dotenv.env['FLUTTERWAVE_${_mode}_ENCRYPTION_KEY']!;
}
