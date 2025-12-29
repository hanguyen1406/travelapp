import 'package:flutter/material.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/models/user_model.dart';

class AddExpenseScreen extends StatefulWidget {
  final int tripId;
  final Expense? editingExpense;

  const AddExpenseScreen({Key? key, required this.tripId, this.editingExpense})
    : super(key: key);

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();

  String selectedCategory = 'Nhà nghỉ';
  User? selectedPaidBy;
  String splitType = 'Chia đều';
  List<User> selectedMembers = [];
  List<User> tripMembers = [];
  bool isLoading = false;

  final List<String> categories = [
    'Nhà nghỉ',
    'Khách sạn',
    'Dự chuyên',
    'Hoạt động',
    'Shopping',
    'Khác',
  ];

  final Map<String, IconData> categoryIcons = {
    'Nhà nghỉ': Icons.hotel,
    'Khách sạn': Icons.bed,
    'Dự chuyên': Icons.directions_car,
    'Hoạt động': Icons.sports_bar,
    'Shopping': Icons.shopping_bag,
    'Khác': Icons.category,
  };

  final Map<String, Color> categoryColors = {
    'Nhà nghỉ': const Color(0xFFFF9800),
    'Khách sạn': const Color(0xFF2196F3),
    'Dự chuyên': const Color(0xFFE91E63),
    'Hoạt động': const Color(0xFF4CAF50),
    'Shopping': const Color(0xFFFFC107),
    'Khác': const Color(0xFF9C27B0),
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _loadTripMembers();
    if (widget.editingExpense != null) {
      _loadExpenseData();
    }
  }

  void _loadTripMembers() {
    // Mock data - Replace with actual API call
    setState(() {
      tripMembers = [
        User(
          id: 1,
          username: 'user1',
          name: 'Sarah',
          surname: 'Doe',
          email: 'sarah@example.com',
        ),
        User(
          id: 2,
          username: 'user2',
          name: 'Mia',
          surname: 'Johnson',
          email: 'mia@example.com',
        ),
        User(
          id: 3,
          username: 'user3',
          name: 'Lia',
          surname: 'Smith',
          email: 'lia@example.com',
        ),
        User(
          id: 4,
          username: 'user4',
          name: 'John',
          surname: 'Brown',
          email: 'john@example.com',
        ),
      ];

      selectedPaidBy = tripMembers.first;
      selectedMembers = List.from(tripMembers);
    });
  }

  void _loadExpenseData() {
    final expense = widget.editingExpense!;
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toString();
    _descriptionController.text = expense.description;
    selectedCategory = expense.category;
    selectedPaidBy = tripMembers.firstWhere(
      (m) => m.id == expense.paidById,
      orElse: () => tripMembers.first,
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _saveExpense() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập tiêu đề chi phí')),
      );
      return;
    }

    if (_amountController.text.isEmpty ||
        double.tryParse(_amountController.text) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    if (selectedMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất một thành viên')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final amount = double.parse(_amountController.text);
      final splitAmount = amount / selectedMembers.length;

      final expenseData = {
        'tripId': widget.tripId,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'category': selectedCategory,
        'amount': amount,
        'date': DateTime.now().toIso8601String(),
        'paidBy': selectedPaidBy!.name,
        'paidById': selectedPaidBy!.id,
        'paymentStatus': 'Pending',
        'splits': selectedMembers
            .map(
              (member) => {
                'userId': member.id,
                'userName': member.name,
                'amount': splitAmount,
                'paid': false,
              },
            )
            .toList(),
      };

      // Simulate saving - in production, this would call the API
      await Future.delayed(const Duration(seconds: 1));

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tạo chi phí thành công')));
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: ${e.toString()}')));
    } finally {
      setState(() => isLoading = false);
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
          'Thêm chi phí',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount Input
                  _buildAmountSection(),
                  const SizedBox(height: 24),

                  // Description
                  _buildDescriptionSection(),
                  const SizedBox(height: 24),

                  // Category Selection
                  _buildCategorySection(),
                  const SizedBox(height: 24),

                  // Who Paid
                  _buildWhoPaidSection(),
                  const SizedBox(height: 24),

                  // Split Method
                  _buildSplitMethodSection(),
                  const SizedBox(height: 24),

                  // Member Selection
                  _buildMemberSelectionSection(),
                  const SizedBox(height: 32),

                  // Save Button
                  _buildSaveButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giá',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            children: [
              const Text(
                '\$ ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              Expanded(
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '0',
                    hintStyle: TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
              const Text(
                'đ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nó dùng để làm gì?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(Icons.description_outlined, color: Colors.grey[400]),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Vị dụ: Bữa tối tại nhà hàng hải sản',
                    hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Phân loại',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: categories.map((category) {
            final isSelected = selectedCategory == category;
            return GestureDetector(
              onTap: () => setState(() => selectedCategory = category),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? categoryColors[category]! : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      categoryIcons[category],
                      size: 28,
                      color: isSelected
                          ? Colors.white
                          : categoryColors[category],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildWhoPaidSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ai đã trả tiền?',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButton<User>(
            value: selectedPaidBy,
            isExpanded: true,
            underline: const SizedBox(),
            items: tripMembers.map((user) {
              return DropdownMenuItem(
                value: user,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: _getCategoryColor(user.id),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(user.name),
                    ],
                  ),
                ),
              );
            }).toList(),
            onChanged: (User? user) {
              setState(() => selectedPaidBy = user);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSplitMethodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cách chia',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Text(
                'Chia đều',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMemberSelectionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Chi những thành viên được chọn',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!, width: 1),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: tripMembers.map((member) {
              final isSelected = selectedMembers.contains(member);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      selectedMembers.remove(member);
                    } else {
                      selectedMembers.add(member);
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF0066FF)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF0066FF)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: _getCategoryColor(member.id),
                        child: Text(
                          member.name[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveExpense,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0066FF),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          widget.editingExpense != null ? 'Cập nhật chi phí' : 'Thêm chi phí',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(int userId) {
    final colors = [
      const Color(0xFF0066FF),
      const Color(0xFFFF6B6B),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFD93D),
    ];
    return colors[userId % colors.length];
  }
}
