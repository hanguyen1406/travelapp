import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/network/network_api_services.dart';
import '../data/request/login_request.dart';
import '../data/request/signup_request.dart';
import '../data/response/login_response.dart';
import '../data/response/message_response.dart';
import '../utils/app_config.dart';
import '../view/user/ProfileScreen.dart';

class AuthViewModel extends ChangeNotifier {
  final NetworkApiServices _apiService = NetworkApiServices();

  bool _isLoading = false;
  String? _token;
  int? _userId;
  String? _errorMessage;
  LoginResponse? _loginResponse;

  bool get isLoading => _isLoading;
  String? get token => _token;
  int? get userId => _userId;
  String? get errorMessage => _errorMessage;
  LoginResponse? get loginResponse => _loginResponse;

  AuthViewModel() {
    _loadToken();
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userId = prefs.getInt('auth_user_id');
    notifyListeners();
  }

  Future<void> _saveToken(String token, int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('auth_user_id', userId);
    _token = token;
    _userId = userId;
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

      final response = await _apiService.getPostApiResponse(
        '${AppConfig.baseUrl}/auth/login',
        loginRequest.toJson(),
      );

      _loginResponse = LoginResponse.fromJson(response);
      if (_loginResponse?.token != null && _loginResponse?.id != null) {
        await _saveToken(_loginResponse!.token!, _loginResponse!.id!);
      } else if (_loginResponse?.token != null) {
         // Fallback if id is not directly in the root or user object not present in a specific way
         // Based on LoginResponse model, id is at root.
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

      final response = await _apiService.getPostApiResponse(
        '${AppConfig.baseUrl}/auth/register',
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
    await prefs.remove('auth_user_id');
    _token = null;
    _userId = null;
    _loginResponse = null;
    _errorMessage = null;
    notifyListeners();
  }

  bool isLoggedIn() {
    return _token != null && _token!.isNotEmpty;
  }

  Future<UserProfile?> getUserProfile() async {
    try {
      if (_loginResponse?.user?.username == null) {
        throw Exception('Username not found');
      }

      final response = await _apiService.getGetApiResponse(
        '${AppConfig.baseUrl}/api/users/profile/${_loginResponse!.user!.username}',
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}

