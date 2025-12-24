import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/utils/app_config.dart';

class TripRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  final String _tripsUrl = '${AppConfig.baseUrl}/trips';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<List<Trip>> getTrips() async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getGetApiResponseWithToken(_tripsUrl, token);
      // response is already decoded json (List<dynamic>)
      List<dynamic> data = response;
      return data.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Trip> getTripDetail(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      dynamic response = await _apiServices.getGetApiResponseWithToken('$_tripsUrl/$id', token);
      return Trip.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}

