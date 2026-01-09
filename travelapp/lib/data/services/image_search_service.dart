import 'package:travelapp/utils/app_config.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/data/network/base_api_services.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Added

class ImageSearchService {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<String?> fetchImageFromGoogle(String query) async {
    try {
      final token = await _getToken();
      // Using AppConfig.baseUrl which usually maps to /api or similar.
      // User changed it to /images/search manually, assuming Controller is mapped there.
      // If controller is @RequestMapping("/api/images"), then URL is /api/images/search.
      // AppConfig.baseUrl usually is hostname/api.
      // So combined: hostname/api/images/search.
      // User's change was: ${AppConfig.baseUrl}/images/search.
      // If baseUrl is .../api, this becomes .../api/images/search. This is correct if Controller is @RequestMapping("/images").
      // BUT Controller is @RequestMapping("/api/images").
      // So if baseUrl is .../api, we should use /images/search?
      // Wait. If baseUrl ends in /api, and we append /images/search, result is .../api/images/search.
      // The Controller uses @RequestMapping("/api/images").
      // So the FULL path is .../api/images/search.
      // This implies we need to append just "/images/search" to the base .../api.
      
      String url = '${AppConfig.baseUrl}/images/search?query=${Uri.encodeComponent(query)}';
      
      dynamic response;
      if (token != null) {
          response = await _apiServices.getGetApiResponseWithToken(url, token);
      } else {
          // Fallback or explicit error - but if user wants token, we should probably fail or try without?
          // Let's try to get it, if null, try without token or return null.
          // Since user explicitly asked for token, best to send it if available.
          response = await _apiServices.getGetApiResponse(url);
      }

      if (response != null && response is Map && response.containsKey('imageUrl')) {
          return response['imageUrl'];
      }
    } catch (e) {
      print('Error fetching image from backend: $e');
    }
    return null;
  }
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
}
