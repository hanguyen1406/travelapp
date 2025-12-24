import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/data/network/base_api_services.dart';
import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/utils/app_config.dart';

class TripRepository {
  final BaseApiServices _apiServices = NetworkApiServices();
  final String _tripsUrl = '${AppConfig.baseUrl}/trips';
  
  Future<List<Trip>> getTrips() async {
    try {
      dynamic response = await _apiServices.getGetApiResponse(_tripsUrl);
      // response is already decoded json (List<dynamic>)
      List<dynamic> data = response;
      return data.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Trip> getTripDetail(int id) async {
    try {
      dynamic response = await _apiServices.getGetApiResponse('$_tripsUrl/$id');
      return Trip.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
