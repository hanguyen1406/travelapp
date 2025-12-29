import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/view/bill/AddExpense.dart';
import 'package:travelapp/view/bill/BalanceSu.dart';

class ExpenseListScreen extends StatefulWidget {
  final int tripId;

  const ExpenseListScreen({Key? key, required this.tripId}) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late List<ExpenseItem> expenses = [];
  late List<ExpenseItem> filteredExpenses = [];
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
    'Dị lệ',
  ];

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    setState(() => isLoading = true);
    try {
      // TODO: Fetch expenses from API using TripViewModel
      // For now, using mock data
      await Future.delayed(const Duration(milliseconds: 500));
      _initializeMockData();
      _filterExpenses();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _initializeMockData() {
    expenses = [
      ExpenseItem(
        id: 1,
        title: 'Đặt khu du lịch biến',
        category: 'Nhà nghỉ',
        amount: 1200000,
        description: 'Hotel booking',
        date: DateTime(2024, 12, 10),
        paymentStatus: 'Bạn thanh toán',
        paidBy: 'Bạn',
        splitWith: 4,
        icon: Icons.hotel,
      ),
      ExpenseItem(
        id: 2,
        title: 'Ăn tối tại bãi biển',
        category: 'Đồ ăn',
        amount: 450000,
        description: 'Dinner at beach',
        date: DateTime(2024, 12, 15),
        paymentStatus: 'Hiểu thanh toán',
        paidBy: 'Bạn',
        splitWith: 4,
        icon: Icons.restaurant,
      ),
    ];

    totalExpense = expenses.fold(0, (sum, item) => sum + item.amount);
    userExpense = expenses.fold(
      0,
      (sum, item) => sum + (item.paidBy == 'Bạn' ? item.amount : 0),
    );
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
    setState(() {});
  }

  void _onCategoryChanged(String category) {
    setState(() => selectedCategory = category);
    _filterExpenses();
  }

  void _addExpense() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(tripId: widget.tripId),
      ),
    ).then((_) {
      // Reload expenses when returning from add screen
      _loadExpenses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Chi phí',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
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
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Summary Card
                  _buildSummaryCard(),

                  // Category Tabs
                  _buildCategoryTabs(),

                  // Expense List
                  _buildExpenseList(),
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
                    'Bạn đã chi',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatCurrency(userExpense)}đ',
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
                    '$expenseCount thành phần',
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
                    'View Balances',
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

  Widget _buildExpenseList() {
    if (filteredExpenses.isEmpty) {
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

    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: filteredExpenses.map((expense) {
          return _buildExpenseCard(expense);
        }).toList(),
      ),
    );
  }

  Widget _buildExpenseCard(ExpenseItem expense) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            expense.icon,
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
              expense.paymentStatus,
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              '${expense.category} • Split với ${expense.splitWith} người',
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
      case 'Nhà nghỉ':
        return const Color(0xFFFF9800);
      case 'Đồ ăn':
        return const Color(0xFFE91E63);
      case 'Hoạt động':
        return const Color(0xFF2196F3);
      case 'Dị lệ':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF0066FF);
    }
  }

  void _showExpenseDetail(ExpenseItem expense) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => ExpenseDetailSheet(expense: expense),
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

class ExpenseItem {
  final int id;
  final String title;
  final String category;
  final double amount;
  final String description;
  final DateTime date;
  final String paymentStatus;
  final String paidBy;
  final int splitWith;
  final IconData icon;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.category,
    required this.amount,
    required this.description,
    required this.date,
    required this.paymentStatus,
    required this.paidBy,
    required this.splitWith,
    required this.icon,
  });

  factory ExpenseItem.fromJson(Map<String, dynamic> json) {
    return ExpenseItem(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      paymentStatus: json['paymentStatus'] ?? '',
      paidBy: json['paidBy'] ?? '',
      splitWith: json['splitWith'] ?? 1,
      icon: Icons.receipt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'amount': amount,
      'description': description,
      'date': date.toIso8601String(),
      'paymentStatus': paymentStatus,
      'paidBy': paidBy,
      'splitWith': splitWith,
    };
  }
}

class ExpenseDetailSheet extends StatelessWidget {
  final ExpenseItem expense;

  const ExpenseDetailSheet({Key? key, required this.expense}) : super(key: key);

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
          Text(
            expense.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildDetailRow('Danh mục', expense.category),
          _buildDetailRow('Số tiền', '${_formatCurrency(expense.amount)}đ'),
          _buildDetailRow(
            'Ngày',
            DateFormat('dd/MM/yyyy').format(expense.date),
          ),
          _buildDetailRow('Chi trả bởi', expense.paidBy),
          _buildDetailRow('Chia sẻ với', '${expense.splitWith} người'),
          _buildDetailRow('Trạng thái', expense.paymentStatus),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Đóng'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Edit expense
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Chỉnh sửa'),
                ),
              ),
            ],
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
