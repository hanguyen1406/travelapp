import '../app_config.dart';
import 'network_api_service.dart';

class OpenMapService {
  static final _network = NetworkApiService();

  static Future<List<String>> getLocationSuggestions(String query) async {
    final url =
        AppConfig.openMapApiUrl +
        '?text=$query&apiKey=${AppConfig.openMapApiKey}';
    final data = await _network.get(url);
    if (data is List) {
      return data
          .map<String>((item) => item['name'] as String? ?? '')
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }
}
