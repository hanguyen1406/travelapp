import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_config.dart';
import '../models/expense_model.dart';

class ExpenseRepository {
  static String get baseUrl => AppConfig.baseUrl;

  static Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Get all expenses for a trip
  static Future<List<Expense>> getExpenses(int tripId) async {
    try {
      final url = Uri.parse('$baseUrl/expenses/trip/$tripId');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      print('📊 [Expenses] GET $url - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load expenses: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Expenses] Error fetching expenses: $e');
      throw e;
    }
  }

  // Get expenses by category
  static Future<List<Expense>> getExpensesByCategory(
    int tripId,
    String category,
  ) async {
    try {
      final url = Uri.parse(
        '$baseUrl/expenses/category?tripId=$tripId&category=$category',
      );
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((e) => Expense.fromJson(e)).toList();
      } else {
        throw Exception(
          'Failed to load expenses category: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ [Expenses] Error fetching expenses by category: $e');
      throw e;
    }
  }

  // Create expense
  static Future<Expense> createExpense(Expense expense) async {
    try {
      final url = Uri.parse('$baseUrl/expenses/create');
      final headers = await _getAuthHeaders();
      final body = json.encode(expense.toJson());

      final response = await http.post(url, headers: headers, body: body);
      print('📊 [Expenses] POST $url - Status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return Expense.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          'Failed to create expense: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      print('❌ [Expenses] Error creating expense: $e');
      throw e;
    }
  }

  // Delete expense
  static Future<void> deleteExpense(int expenseId) async {
    try {
      final url = Uri.parse('$baseUrl/expenses/$expenseId');
      final headers = await _getAuthHeaders();

      final response = await http.delete(url, headers: headers);
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete expense: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Expenses] Error deleting expense: $e');
      throw e;
    }
  }

  // Get balance for a user in a trip
  static Future<Map<String, dynamic>> getBalance(int tripId, int userId) async {
    try {
      final url = Uri.parse('$baseUrl/balance/trip/$tripId/user/$userId');
      final headers = await _getAuthHeaders();

      final response = await http.get(url, headers: headers);
      print('💰 [Balance] GET $url - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        return json.decode(utf8.decode(response.bodyBytes))
            as Map<String, dynamic>;
      } else {
        throw Exception('Failed to load balance: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Balance] Error fetching balance: $e');
      throw e;
    }
  }
}
