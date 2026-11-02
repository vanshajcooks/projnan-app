import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  ApiConfig._();

  /// Default API port for Probon backend
  static const int port = 5000;

  /// Default base URL depending on platform:
  /// - Android Emulator: http://10.0.2.2:5000/api
  /// - Web / Desktop / Tests: http://localhost:5000/api
  /// Can be overridden at runtime or build-time via `--dart-define=API_URL=...`
  static String get defaultBaseUrl {
    const fromEnv = String.fromEnvironment('API_URL');
    if (fromEnv.isNotEmpty) return fromEnv;

    if (kIsWeb) {
      return 'http://localhost:$port/api';
    }

    try {
      if (Platform.isAndroid) {
        // Standard Android emulator loopback to host machine
        return 'http://10.0.2.2:$port/api';
      }
    } catch (_) {
      // In case Platform is unavailable in tests
    }

    return 'http://localhost:$port/api';
  }

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 15);
}
