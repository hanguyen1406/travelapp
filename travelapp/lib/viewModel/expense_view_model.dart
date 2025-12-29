import 'package:flutter/foundation.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/repository/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  List<Expense> _expenses = [];
  List<Expense> _filteredExpenses = [];
  Expense? _currentExpense;
  bool _isLoading = false;
  String? _error;
  double _totalExpense = 0.0;
  double _userExpense = 0.0;
  int _currentTripId = 0;
  String _selectedCategory = 'Tất cả';

  List<Expense> get expenses => _expenses;
  List<Expense> get filteredExpenses => _filteredExpenses;
  Expense? get currentExpense => _currentExpense;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalExpense => _totalExpense;
  double get userExpense => _userExpense;
  String get selectedCategory => _selectedCategory;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> fetchExpenses(int tripId) async {
    _currentTripId = tripId;
    _setLoading(true);
    _error = null;
    try {
      _expenses = await ExpenseRepository.getExpenses(tripId);
      _calculateTotals();
      _filterExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // Not strictly needed if AddExpense uses Repository directly, but kept for compatibility
  Future<bool> createExpense(Expense expense) async {
    _setLoading(true);
    _error = null;
    try {
      final newExpense = await ExpenseRepository.createExpense(expense);
      _expenses.add(newExpense);
      _calculateTotals();
      _filterExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteExpense(int expenseId) async {
    _setLoading(true);
    _error = null;
    try {
      await ExpenseRepository.deleteExpense(expenseId);
      _expenses.removeWhere((e) => e.id == expenseId);
      _calculateTotals();
      _filterExpenses();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _filterExpenses();
  }

  void _filterExpenses() {
    if (_selectedCategory == 'Tất cả') {
      _filteredExpenses = _expenses;
    } else {
      _filteredExpenses = _expenses
          .where((e) => e.category == _selectedCategory)
          .toList();
    }
    notifyListeners();
  }

  void _calculateTotals() {
    _totalExpense = _expenses.fold(0, (sum, expense) => sum + expense.amount);
    
    // Placeholder logic for user expense until authentication context is fully integrated
    // In a real scenario, compare expense.paidById with currentUser.id
    _userExpense = 0.0; 
  }

  // Placeholder methods for missing Repository features to prevent build errors
  // If these features are needed, they should be implemented in ExpenseRepository first.

  Future<void> fetchExpenseDetail(int expenseId) async {
    // Not implemented in Repository yet
  }

  Future<bool> updateExpense(int expenseId, Map<String, dynamic> data) async {
     // Not implemented in Repository yet
     return false;
  }

  Future<Map<String, dynamic>> getExpenseStats() async {
     return {};
  }

  Future<Map<String, dynamic>> getBalance(int userId) async {
     return {};
  }

  Future<List<Map<String, dynamic>>> getSettlements() async {
     return [];
  }
}
