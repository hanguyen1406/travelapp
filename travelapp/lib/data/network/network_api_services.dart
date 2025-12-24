import 'dart:convert';
import 'package:http/http.dart' as http;
import 'base_api_services.dart';

class NetworkApiService extends BaseApiServices {
  static const String baseUrl = 'http://10.0.2.2:8080/api'; // For Android emulator
  // For iOS simulator or real device, use: 'http://localhost:8080/api'

  @override
  Future<dynamic> getApi(String url) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl + url),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<dynamic> postApi(String url, dynamic data) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<dynamic> postApiWithToken(String url, dynamic data, String token) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  @override
  Future<dynamic> getApiWithToken(String url, String token) async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl + url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  dynamic _handleResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
      case 201:
        return jsonDecode(response.body);
      case 400:
        throw Exception(
          jsonDecode(response.body)['message'] ?? 'Bad Request',
        );
      case 401:
        throw Exception('Unauthorized');
      case 403:
        throw Exception('Forbidden');
      case 404:
        throw Exception('Not Found');
      case 500:
        throw Exception('Internal Server Error');
      default:
        throw Exception('Unknown error occurred');
    }
  }
}
