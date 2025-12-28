import 'package:travelapp/utils/app_config.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenMapService {
  final _apiServices = NetworkApiServices();

  Future<List<Map<String, String>>> getLocationSuggestions(String query) async {
    try {
      final url = '${AppConfig.openMapApiUrl}?text=$query&apikey=${AppConfig.openMapApiKey}';
      
      dynamic response = await _apiServices.getGetApiResponse(url);
      
      List<dynamic> items = [];
      if (response is List) {
         items = response;
      } else if (response is Map && response['features'] is List) {
         items = (response['features'] as List).map((e) => e['properties']).toList();
      }

      return items.map<Map<String, String>>((item) {
        final name = item['name']?.toString() ?? '';
        
        // Try to find the most specific "city" like field
        final city = item['city']?.toString() ?? 
                     item['town']?.toString() ?? 
                     item['village']?.toString() ?? 
                     item['district']?.toString() ??
                     item['county']?.toString() ?? 
                     item['state']?.toString() ?? '';
                     
        final country = item['country']?.toString() ?? '';
        final street = item['street']?.toString() ?? '';
        
        // Use label or address or display_name as base
        String address = item['label']?.toString() ?? 
                         item['address']?.toString() ?? 
                         item['display_name']?.toString() ?? '';
        
        // If we found specific components, let's build a nice string
        if (city.isNotEmpty || country.isNotEmpty || street.isNotEmpty) {
           List<String> parts = [];
           if (street.isNotEmpty) parts.add(street);
           if (city.isNotEmpty) parts.add(city);
           if (country.isNotEmpty) parts.add(country);
           
           if (parts.isNotEmpty) {
             address = parts.join(", ");
           }
        }

        return {
          'name': name,
          'address': address
        };
      }).where((e) => e['name']!.isNotEmpty).toList();
      
    } catch (e) {
      print("OpenMap Error: $e");
      return [];
    }
  }
}
