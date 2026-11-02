import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  static const int port = 5000;
  static String? _customBaseUrl;

  /// Dynamic override at runtime (e.g. for switching between USB adb reverse, emulator, or Wi-Fi IP)
  static void setCustomBaseUrl(String url) {
    _customBaseUrl = url;
  }

  /// Default base URL:
  /// 1. Explicit runtime override if set
  /// 2. Build-time `--dart-define=API_URL=...`
  /// 3. Web / Desktop: http://localhost:5000/api
  /// 4. Android (USB reverse proxy or emulator):
  ///    - With 'adb reverse tcp:5000 tcp:5000' over USB: http://127.0.0.1:5000/api
  ///    - Fallback: http://10.0.2.2:5000/api
  static String get defaultBaseUrl {
    if (_customBaseUrl != null && _customBaseUrl!.isNotEmpty) {
      return _customBaseUrl!;
    }

    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        // When using 'adb reverse tcp:5000 tcp:5000' over USB, 127.0.0.1 forwards directly to PC
        // You can also pass --dart-define=API_URL=http://10.0.2.2:5000/api for emulator
        return 'http://127.0.0.1:$port/api';
      }
    } catch (_) {
      // In case Platform is unavailable in tests
    }

    return 'http://localhost:$port/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
