import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/models/itinerary_model.dart';
import 'package:travelapp/utils/app_config.dart';

class ItineraryRepository {
  final BaseApiServices _apiServices = NetworkApiServices();

  Future<List<Itinerary>> getItineraries(int tripId) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse('${AppConfig.baseUrl}/trips/$tripId/itineraries');
      List<dynamic> data = response;
      return data.map((json) => Itinerary.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Itinerary> createItinerary(int tripId, Map<String, dynamic> data) async {
    try {
      dynamic response = await _apiServices.getPostApiResponse(
        '${AppConfig.baseUrl}/trips/$tripId/itineraries',
        data,
      );
      return Itinerary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Itinerary> voteItinerary(int itineraryId, int userId, bool vote) async {
    try {
      final body = {
        'userId': userId,
        'vote': vote,
      };
      dynamic response = await _apiServices.getPostApiResponse(
        '${AppConfig.baseUrl}/itineraries/$itineraryId/vote',
        body,
      );
      return Itinerary.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
