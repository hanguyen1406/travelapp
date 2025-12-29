import 'package:travelapp/data/network/network_api_services.dart';
import 'package:travelapp/models/expense_model.dart';

class ExpenseRepository {
  final NetworkApiServices _apiService = NetworkApiServices();
  final String baseUrl =
      'http://localhost:8080/api'; // Update with your API URL

  Future<List<Expense>> getExpenses(int tripId) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/trips/$tripId/expenses',
      );
      List<Expense> expenses = [];
      if (response is List) {
        expenses = response.map((e) => Expense.fromJson(e)).toList();
      }
      return expenses;
    } catch (e) {
      throw Exception('Lỗi tải danh sách chi phí: $e');
    }
  }

  Future<Expense> getExpenseDetail(int expenseId) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/expenses/$expenseId',
      );
      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi tải chi tiết chi phí: $e');
    }
  }

  Future<Expense> createExpense(Map<String, dynamic> data) async {
    try {
      final response = await _apiService.getPostApiResponse(
        '$baseUrl/expenses',
        data,
      );
      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi tạo chi phí: $e');
    }
  }

  Future<Expense> updateExpense(
    int expenseId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _apiService.getPutApiResponse(
        '$baseUrl/expenses/$expenseId',
        data,
      );
      return Expense.fromJson(response);
    } catch (e) {
      throw Exception('Lỗi cập nhật chi phí: $e');
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    try {
      await _apiService.getDeleteApiResponse('$baseUrl/expenses/$expenseId');
      return true;
    } catch (e) {
      throw Exception('Lỗi xóa chi phí: $e');
    }
  }

  Future<Map<String, dynamic>> getExpenseStats(int tripId) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/trips/$tripId/expenses/stats',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Lỗi tải thống kê chi phí: $e');
    }
  }

  Future<List<Expense>> getExpensesByCategory(
    int tripId,
    String category,
  ) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/trips/$tripId/expenses?category=$category',
      );
      List<Expense> expenses = [];
      if (response is List) {
        expenses = response.map((e) => Expense.fromJson(e)).toList();
      }
      return expenses;
    } catch (e) {
      throw Exception('Lỗi tải chi phí theo danh mục: $e');
    }
  }

  Future<Map<String, dynamic>> getBalance(int tripId, int userId) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/trips/$tripId/expenses/balance/$userId',
      );
      return response as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Lỗi tải số dư: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getSettlements(int tripId) async {
    try {
      final response = await _apiService.getGetApiResponse(
        '$baseUrl/trips/$tripId/expenses/settlements',
      );
      List<Map<String, dynamic>> settlements = [];
      if (response is List) {
        settlements = response.cast<Map<String, dynamic>>();
      }
      return settlements;
    } catch (e) {
      throw Exception('Lỗi tải thông tin thanh toán: $e');
    }
  }
}
