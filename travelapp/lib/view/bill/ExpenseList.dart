import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/repository/expense_repository.dart';
import 'package:travelapp/view/bill/AddExpense.dart';
import 'package:travelapp/view/bill/BalanceSu.dart';

class ExpenseListScreen extends StatefulWidget {
  final int tripId;

  const ExpenseListScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  List<Expense> expenses = [];
  List<Expense> filteredExpenses = [];
  String selectedCategory = 'Tất cả';
  double totalExpense = 0.0;
  double userExpense = 0.0;
  int expenseCount = 0;
  bool isLoading = true;

  final List<String> categories = [
    'Tất cả',
    'Nhà nghỉ',
    'Đồ ăn',
    'Hoạt động',
    'Di chuyển',
    'Shopping',
    'Khác',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      print('💰 [ExpenseList] Loading expenses for trip ${widget.tripId}...');
      final loadedExpenses = await ExpenseRepository.getExpenses(widget.tripId);
      
      if (mounted) {
        setState(() {
          expenses = loadedExpenses;
          _calculateSummary();
          _filterExpenses();
          isLoading = false;
        });
      }
    } catch (e) {
      print('❌ [ExpenseList] Error: $e');
      if (mounted) {
        setState(() {
          expenses = [];
          filteredExpenses = [];
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải chi phí: $e')),
        );
      }
    }
  }

  void _calculateSummary() {
    totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);
    // TODO: Filter user specific expense correctly using logged in user ID
    userExpense = totalExpense; 
    expenseCount = expenses.length;
  }

  void _filterExpenses() {
    if (selectedCategory == 'Tất cả') {
      filteredExpenses = expenses;
    } else {
      filteredExpenses = expenses
          .where((e) => e.category == selectedCategory)
          .toList();
    }
  }

  void _onCategoryChanged(String category) {
    setState(() => selectedCategory = category);
    _filterExpenses();
  }

  Future<void> _addExpense() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(tripId: widget.tripId),
      ),
    );

    if (result == true) {
      _loadExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Chi phí',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0066FF),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _addExpense,
                borderRadius: BorderRadius.circular(50),
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadExpenses,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80), // Space for FAB
                children: [
                  // Summary Card
                  _buildSummaryCard(),

                  // Category Tabs
                  _buildCategoryTabs(),

                  // Expense List
                  if (filteredExpenses.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredExpenses.map((expense) => _buildExpenseCard(expense)),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        backgroundColor: const Color(0xFF0066FF),
        icon: const Icon(Icons.add),
        label: const Text('Thêm chi phí'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.receipt_long, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có chi phí',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total Expense Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng chi phí',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(totalExpense)}đ',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: const Icon(
                  Icons.attach_money,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // User Expense & Count Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tổng số GD',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${expenseCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Số lượng',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$expenseCount mục',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // View Balances Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BalanceSettlementScreen(tripId: widget.tripId),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.visibility, color: Color(0xFF0066FF), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Xem số dư',
                    style: TextStyle(
                      color: Color(0xFF0066FF),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
              onSelected: (value) => _onCategoryChanged(category),
              label: Text(
                category,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              backgroundColor: isSelected
                  ? const Color(0xFF0066FF)
                  : Colors.grey[200],
              side: BorderSide.none,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Expense expense) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _getCategoryColor(expense.category).withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            _getCategoryIcon(expense.category),
            color: _getCategoryColor(expense.category),
            size: 24,
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              expense.paidBy, // paidByName
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${expense.category}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        trailing: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${_formatCurrency(expense.amount)}đ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('MMM dd').format(expense.date),
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        onTap: () => _showExpenseDetail(expense),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Nhà nghỉ': return const Color(0xFFFF9800);
      case 'Đồ ăn': return const Color(0xFFE91E63);
      case 'Hoạt động': return const Color(0xFF2196F3);
      case 'Di chuyển': return const Color(0xFF9C27B0);
      case 'Shopping': return const Color(0xFFFFC107);
      default: return const Color(0xFF0066FF);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Nhà nghỉ': return Icons.hotel;
      case 'Đồ ăn': return Icons.restaurant;
      case 'Hoạt động': return Icons.directions_run;
      case 'Di chuyển': return Icons.directions_car;
      case 'Shopping': return Icons.shopping_bag;
      default: return Icons.category;
    }
  }

  void _showExpenseDetail(Expense expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExpenseDetailSheet(expense: expense, onDelete: () {
          _deleteExpense(expense.id);
      }),
    );
  }

  void _deleteExpense(int expenseId) async {
      try {
          await ExpenseRepository.deleteExpense(expenseId);
          Navigator.pop(context); // Close bottom sheet
          _loadExpenses(); // Refresh list
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đã xóa chi phí')),
          );
      } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
      }
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class ExpenseDetailSheet extends StatelessWidget {
  final Expense expense;
  final VoidCallback onDelete;

  const ExpenseDetailSheet({Key? key, required this.expense, required this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(
                        expense.title,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                ),
                IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                        // Confirm dialog
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                                title: const Text('Xóa chi phí?'),
                                content: const Text('Bạn có chắc chắn muốn xóa chi phí này?'),
                                actions: [
                                    TextButton(
                                        onPressed: () => Navigator.pop(ctx),
                                        child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                        onPressed: () {
                                            Navigator.pop(ctx);
                                            onDelete();
                                        },
                                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                                        child: const Text('Xóa'),
                                    ),
                                ],
                            ),
                        );
                    },
                ),
              ],
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Danh mục', expense.category),
          _buildDetailRow('Số tiền', '${_formatCurrency(expense.amount)}đ'),
          _buildDetailRow(
            'Ngày',
            DateFormat('dd/MM/yyyy').format(expense.date),
          ),
          _buildDetailRow('Chi trả bởi', expense.paidBy),
          _buildDetailRow('Chia cách', expense.splitMethod),
          
          if (expense.description.isNotEmpty)
             _buildDetailRow('Mô tả', expense.description),

          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Đóng'),
            ),
           ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return amount
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
