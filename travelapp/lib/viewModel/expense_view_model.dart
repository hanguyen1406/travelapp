import 'package:flutter/foundation.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/repository/expense_repository.dart';

class ExpenseViewModel extends ChangeNotifier {
  final ExpenseRepository _expenseRepository = ExpenseRepository();

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
      _expenses = await _expenseRepository.getExpenses(tripId);
      _calculateTotals();
      _filterExpenses();
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchExpenseDetail(int expenseId) async {
    _setLoading(true);
    _error = null;
    try {
      _currentExpense = await _expenseRepository.getExpenseDetail(expenseId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createExpense(Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      final newExpense = await _expenseRepository.createExpense(data);
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

  Future<bool> updateExpense(int expenseId, Map<String, dynamic> data) async {
    _setLoading(true);
    _error = null;
    try {
      final updatedExpense = await _expenseRepository.updateExpense(
        expenseId,
        data,
      );
      final index = _expenses.indexWhere((e) => e.id == expenseId);
      if (index != -1) {
        _expenses[index] = updatedExpense;
      }
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
      await _expenseRepository.deleteExpense(expenseId);
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
    // TODO: Calculate user expense based on current user ID
    _userExpense = _expenses.fold(0, (sum, expense) {
      if (expense.splits.isNotEmpty) {
        final userSplit = expense.splits.firstWhere(
          (split) => split.userId == 0, // Replace 0 with actual user ID
          orElse: () => ExpenseSplit(
            id: 0,
            expenseId: 0,
            userId: 0,
            userName: '',
            amount: 0,
            paid: false,
          ),
        );
        return sum + userSplit.amount;
      }
      return sum;
    });
  }

  Future<Map<String, dynamic>> getExpenseStats() async {
    try {
      return await _expenseRepository.getExpenseStats(_currentTripId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  Future<Map<String, dynamic>> getBalance(int userId) async {
    try {
      return await _expenseRepository.getBalance(_currentTripId, userId);
    } catch (e) {
      _error = e.toString();
      return {};
    }
  }

  Future<List<Map<String, dynamic>>> getSettlements() async {
    try {
      return await _expenseRepository.getSettlements(_currentTripId);
    } catch (e) {
      _error = e.toString();
      return [];
    }
  }
}
