import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/network/network_api_services.dart';
import '../data/request/login_request.dart';
import '../data/request/signup_request.dart';
import '../data/response/login_response.dart';
import '../data/response/message_response.dart';

class AuthViewModel extends ChangeNotifier {
  final NetworkApiService _apiService = NetworkApiService();

  bool _isLoading = false;
  String? _token;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  bool get isLoading => _isLoading;
  String? get token => _token;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  AuthViewModel() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    notifyListeners();
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _token = token;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final loginRequest = LoginRequest(
        username: username,
        password: password,
      );

      final response = await _apiService.postApi(
        '/auth/login',
        loginRequest.toJson(),
      );

      _loginResponse = LoginResponse.fromJson(response);
      if (_loginResponse?.token != null) {
        await _saveToken(_loginResponse!.token!);
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(
    String name,
    String surname,
    String username,
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final signupRequest = SignupRequest(
        name: name,
        surname: surname,
        username: username,
        email: email,
        password: password,
        phone: phone,
      );

      final response = await _apiService.postApi(
        '/auth/register',
        signupRequest.toJson(),
      );

      final messageResponse = MessageResponse.fromJson(response);
      if (messageResponse.message != null) {
        _errorMessage = messageResponse.message;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _token = null;
    _loginResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }
}
