import 'package:flutter/foundation.dart';
import 'package:travelapp/models/trip_model.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/repository/trip_repository.dart';

class TripViewModel extends ChangeNotifier {
  final TripRepository _tripRepository = TripRepository();

  List<Trip> _trips = [];
  Trip? _currentTrip;
  bool _isLoading = false;
  String? _error;

  List<Trip> get trips => _trips;
  Trip? get currentTrip => _currentTrip;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTrips(int userId) async {
    _setLoading(true);
    _error = null;
    try {
      _trips = await _tripRepository.getTrips(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchTripDetail(int id) async {
    _setLoading(true);
    _error = null;
    try {
      _currentTrip = await _tripRepository.getTripDetail(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<Trip?> createTrip(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      Trip newTrip = await _tripRepository.createTrip(data);
      return newTrip;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addMember(int tripId, Map<String, dynamic> body) async {
    _setLoading(true);
    _error = null;
    try {
      _currentTrip = await _tripRepository.addMember(tripId, body);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<List<User>> searchUsers(String query) async {
    try {
      return await _tripRepository.searchUsers(query);
    } catch (e) {
      return [];
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
