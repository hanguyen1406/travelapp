import 'package:flutter/foundation.dart';

class AppConfig {
  // Use different URLs based on platform
  // For Android emulator: 10.0.2.2 (special IP pointing to host)
  // For Web/Browser: localhost
  // For physical device: use actual backend IP
  static String get baseUrl {
    if (kIsWeb) {
      // Web platform - use localhost
      return 'http://localhost:8080/api';
    } else {
      // Mobile/emulator - use 10.0.2.2 for Android emulator
      return 'http://10.0.2.2:8080/api';
    }
  }

  // OpenMap Config
  static const String openMapApiKey = "EvckMG80oLeHRhw93ZjYiqztcBvApSEP";
  static const String openMapApiUrl =
      "https://mapapis.openmap.vn/v1/autocomplete";
}
