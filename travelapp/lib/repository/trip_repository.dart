import 'package:shared_preferences/shared_preferences.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/utils/app_config.dart';

class TripRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  final String _tripsUrl = '${AppConfig.baseUrl}/trips';
  
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }
  
  Future<List<Trip>> getTrips(int userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      final url = '$_tripsUrl/user/$userId';
      dynamic response = await _apiServices.getGetApiResponseWithToken(url, token);
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

  Future<Trip> createTrip(Map<String, dynamic> data) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      dynamic response = await _apiServices.getPostApiResponseWithToken(_tripsUrl, data, token);
      return Trip.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Trip> addMember(int tripId, Map<String, dynamic> body) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      dynamic response = await _apiServices.getPostApiResponseWithToken(
          '$_tripsUrl/$tripId/members', body, token);
      return Trip.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
  Future<List<User>> searchUsers(String query) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      final url = '${AppConfig.baseUrl}/users/search?query=$query';
      dynamic response = await _apiServices.getGetApiResponseWithToken(url, token);
      List<dynamic> data = response;
      return data.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      // Return empty list on error or handle differently
      return [];
    }
  }
  Future<bool> deleteTrip(int id) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }
      
      await _apiServices.getDeleteApiResponseWithToken('$_tripsUrl/$id', token);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}

