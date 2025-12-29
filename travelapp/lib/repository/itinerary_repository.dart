import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/models/itinerary_model.dart';
import 'package:travelapp/utils/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItineraryRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<List<Itinerary>> getItineraries(int tripId, int? userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      String url = '${AppConfig.baseUrl}/trips/$tripId/itineraries';
      if (userId != null) {
        url += '?userId=$userId';
      }

      dynamic response = await _apiServices.getGetApiResponseWithToken(url, token);
      List<dynamic> data = response;
      return data.map((json) => Itinerary.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Itinerary> createItinerary(int tripId, Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      dynamic response = await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/trips/$tripId/itineraries',
        data,
        token
      );
      return Itinerary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Itinerary> voteItinerary(int itineraryId, int userId, bool vote) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = {
        'userId': userId,
        'vote': vote,
      };
      
      dynamic response = await _apiServices.getPostApiResponseWithToken(
        '${AppConfig.baseUrl}/itineraries/$itineraryId/vote',
        body,
        token
      );
      return Itinerary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
