import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/network/network_api_services.dart';
import '../data/request/login_request.dart';
import '../data/request/signup_request.dart';
import '../data/response/login_response.dart';
import '../data/response/message_response.dart';
import '../utils/app_config.dart';
import '../models/user_model.dart';
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
    final username = prefs.getString('auth_username');
    final email = prefs.getString('auth_email');
    
    if (_token != null && _userId != null && username != null) {
      // Reconstruct basic LoginResponse to restore session data
      _loginResponse = LoginResponse(
        token: _token,
        id: _userId,
        username: username,
        email: email ?? '',
        user: UserLoginData(
          id: _userId!,
          username: username,
          email: email ?? '',
          name: '',
          surname: '',
        ),
      );
    }
    notifyListeners();
  }

  Future<void> _saveToken(String token, int userId, User? user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('auth_user_id', userId);
    if (user != null) {
      await prefs.setString('auth_username', user.username);
      // await prefs.setString('auth_email', user.email); // email is already saved? no wait.
      await prefs.setString('auth_email', user.email);
    }
    _token = token;
    _userId = userId;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _token = null; // Clear previous state
    _userId = null;
    _loginResponse = null;
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
      
      // Normalize: If API returns flat structure (root fields) but no nested 'user' object,
      // create the 'user' object so the rest of the app can use it consistently.
      if (_loginResponse?.user == null && _loginResponse?.token != null) {
          _loginResponse = LoginResponse(
            token: _loginResponse!.token,
            type: _loginResponse!.type,
            id: _loginResponse!.id,
            username: _loginResponse!.username,
            email: _loginResponse!.email,
            name: _loginResponse!.name,
            surname: _loginResponse!.surname,
            roles: _loginResponse!.roles,
            user: UserLoginData(
              id: _loginResponse!.id,
              username: _loginResponse!.username,
              email: _loginResponse!.email,
              name: _loginResponse!.name,
              surname: _loginResponse!.surname,
            )
          );
      }
      
      if (_loginResponse?.token != null && _loginResponse?.id != null) {
        // Map UserLoginData (from response) to User (model)
        User? userModel;
        if (_loginResponse?.user != null) {
           userModel = User(
             id: _loginResponse!.user!.id ?? _loginResponse!.id!,
             username: _loginResponse!.user!.username ?? '',
             email: _loginResponse!.user!.email ?? '',
             name: _loginResponse!.user!.name ?? '',
             surname: _loginResponse!.user!.surname ?? '',
           );
        } else {
           // Fallback (redundant now due to normalization, but safe to keep)
           userModel = User(
             id: _loginResponse!.id!,
             username: _loginResponse!.username ?? '',
             email: _loginResponse!.email ?? '',
             name: _loginResponse!.name ?? '',
             surname: _loginResponse!.surname ?? '',
           );
        }
        
        await _saveToken(_loginResponse!.token!, _loginResponse!.id!, userModel);
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

  Future<User?> fetchUserDetails(int id) async {
    try {
      if (_token == null) {
        throw Exception('No authentication token found');
      }
      final response = await _apiService.getGetApiResponseWithToken(
        '${AppConfig.baseUrl}/users/id/$id',
        _token!,
      );
      
      // Parse User from response
      final user = User.fromJson(response);
      
      // Update local storage/cache if needed
      if (_loginResponse != null) {
          // Update the user object inside loginResponse
          _loginResponse = LoginResponse(
            token: _loginResponse!.token,
            id: _loginResponse!.id,
            username: user.username,
            email: user.email,
            user: UserLoginData(
              id: user.id,
              username: user.username,
              email: user.email,
              name: user.name,
              surname: user.surname,
            ),
          );
          // Persist
          await _saveToken(_loginResponse!.token!, id, user);
      }
      return user;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
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

      final response = await _apiService.getGetApiResponseWithToken(
        '${AppConfig.baseUrl}/users/profile/${_loginResponse!.user!.username}',
        _token!,
      );

      return UserProfile.fromJson(response);
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return null;
    }
  }
}

