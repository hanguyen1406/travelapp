import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/repository/expense_repository.dart';

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

  // Data State
  String selectedCategory = 'Đồ ăn';
  User? selectedPaidBy;
  String splitMethod = 'EVEN'; // EVEN, SELECTED, CUSTOM
  List<User> selectedSplitMembers = []; // For SELECTED method
  Map<int, TextEditingController> customAmountControllers =
      {}; // For CUSTOM method
  bool isLoading = false;
  List<User> tripMembers = []; // Cache trip members

  // Categories Configuration
  final List<Map<String, dynamic>> categories = [
    {'name': 'Đồ ăn', 'icon': Icons.restaurant, 'color': Color(0xFFE91E63)},
    {'name': 'Khách sạn', 'icon': Icons.hotel, 'color': Color(0xFFFF9800)},
    {
      'name': 'Di chuyển',
      'icon': Icons.directions_car,
      'color': Color(0xFF9C27B0),
    },
    {
      'name': 'Hoạt động',
      'icon': Icons.local_activity,
      'color': Color(0xFF2196F3),
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Color(0xFFFFC107),
    },
    {'name': 'Khác', 'icon': Icons.credit_card, 'color': Color(0xFF607D8B)},
  ];

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_onAmountChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _onAmountChanged() {
    setState(() {});
  }

  void _initializeData() {
    final tripViewModel = Provider.of<TripViewModel>(context, listen: false);
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);

    print('🔍 [AddExpense] Initializing data for trip ${widget.tripId}');
    print('👤 [AddExpense] Current user: ${authViewModel.userId}');
    print(
      '📌 [AddExpense] currentTrip: ${tripViewModel.currentTrip?.id}, Expected: ${widget.tripId}',
    );

    // Always fetch fresh trip data to ensure we get members for current user
    print('⬇️ [AddExpense] Fetching trip detail (forced fresh load)...');
    tripViewModel
        .fetchTripDetail(widget.tripId)
        .then((_) {
          print(
            '✅ [AddExpense] Trip fetched: ${tripViewModel.currentTrip?.members.length} members',
          );
          for (var m in (tripViewModel.currentTrip?.members ?? [])) {
            print('   - Member: ${m.id} - ${m.name}');
          }
          _setupInitialValues(tripViewModel.currentTrip?.members ?? []);
        })
        .catchError((e) {
          print('❌ [AddExpense] Error fetching trip: $e');
        });
  }

  void _setupInitialValues(List<User> members) {
    if (!mounted) return;
    final authViewModel = Provider.of<AuthViewModel>(context, listen: false);
    final currentUserId = authViewModel.userId;

    print(
      '📝 [AddExpense] Setup initial values with ${members.length} members',
    );
    print('👤 [AddExpense] Current user ID: $currentUserId');
    for (var m in members) {
      print('   - Member: ${m.id} - ${m.name}');
    }

    setState(() {
      tripMembers = members;

      // Select current user as payer, not first member
      if (currentUserId != null) {
        try {
          selectedPaidBy = members.firstWhere((m) => m.id == currentUserId);
          print(
            '✅ [AddExpense] Selected current user ${selectedPaidBy?.name} as payer',
          );
        } catch (e) {
          // Fallback to first member if current user not in list
          if (members.isNotEmpty) {
            selectedPaidBy = members.first;
            print(
              '⚠️ [AddExpense] Current user not in members, using first: ${selectedPaidBy?.name}',
            );
          }
        }
      } else if (members.isNotEmpty) {
        selectedPaidBy = members.first;
      }

      // Initialize selected members as all members by default
      selectedSplitMembers = List.from(members);

      // Initialize custom controllers
      for (var member in members) {
        customAmountControllers[member.id] = TextEditingController(text: '');
      }

      if (widget.editingExpense != null) {
        final e = widget.editingExpense!;
        _amountController.text = e.amount.toStringAsFixed(0);
        _descriptionController.text = e.description;
        selectedCategory = e.category;
        try {
          selectedPaidBy = members.firstWhere((m) => m.id == e.paidById);
        } catch (_) {}

        splitMethod = e.splitMethod;
        // Recover split logic could be complex, for now we keep defaults or try to parse
        // If needed we can parse e.splits to populate selectedSplitMembers or customAmountControllers
      }
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    for (var controller in customAmountControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (_amountController.text.isEmpty) return;
    double? totalAmount = double.tryParse(
      _amountController.text.replaceAll(',', ''),
    );
    if (totalAmount == null || totalAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập số tiền hợp lệ')),
      );
      return;
    }

    if (selectedPaidBy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn người trả tiền')),
      );
      return;
    }

    // Validation for specific split methods
    if (splitMethod == 'SELECTED' && selectedSplitMembers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 thành viên để chia'),
        ),
      );
      return;
    }

    if (splitMethod == 'CUSTOM') {
      double checksum = 0;
      customAmountControllers.forEach((key, controller) {
        double val = double.tryParse(controller.text) ?? 0;
        checksum += val;
      });

      // Allow small floating point error discrepancy
      if ((checksum - totalAmount).abs() > 1000) {
        // Tolerance 1000 VND
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Tổng tiền chia (${checksum.toStringAsFixed(0)}) không khớp với tổng chi phí (${totalAmount.toStringAsFixed(0)})',
            ),
          ),
        );
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      List<ExpenseSplit> splits = [];

      if (splitMethod == 'EVEN') {
        double splitAmount = totalAmount / tripMembers.length;
        double percentage = 100.0 / tripMembers.length;
        splits = tripMembers
            .map(
              (m) => ExpenseSplit(
                expenseId: 0,
                userId: m.id,
                shareAmount: splitAmount,
                sharePercentage: percentage,
                isPaid: false,
              ),
            )
            .toList();
      } else if (splitMethod == 'SELECTED') {
        double splitAmount = totalAmount / selectedSplitMembers.length;
        double percentage = 100.0 / selectedSplitMembers.length;
        // Iterate over ALL trip members. If they are in selected list, they get share. Else 0.
        // Backend might expect only involved members or all with 0.
        // Usually simpler to send all, or just involved. Let's send only involved for clean data,
        // but for 'paid' status safety, maybe backend needs all.
        // Let's assume we create splits only for those who owe money.
        splits = selectedSplitMembers
            .map(
              (m) => ExpenseSplit(
                expenseId: 0,
                userId: m.id,
                shareAmount: splitAmount,
                sharePercentage: percentage,
                isPaid: false,
              ),
            )
            .toList();
      } else if (splitMethod == 'CUSTOM') {
        splits = [];
        double totalPercentage = 0;
        for (var member in tripMembers) {
          double amount =
              double.tryParse(
                customAmountControllers[member.id]?.text ?? '0',
              ) ??
              0;
          if (amount > 0) {
            double percentage = (amount / totalAmount) * 100;
            splits.add(
              ExpenseSplit(
                expenseId: 0,
                userId: member.id,
                shareAmount: amount,
                sharePercentage: percentage,
                isPaid: false,
              ),
            );
            totalPercentage += percentage;
          }
        }
      }

      final newExpense = Expense(
        id: widget.editingExpense?.id ?? 0,
        tripId: widget.tripId,
        title: _descriptionController.text.isNotEmpty
            ? _descriptionController.text
            : selectedCategory,
        description: _descriptionController.text,
        category: selectedCategory,
        amount: totalAmount,
        currency: 'VND',
        date: DateTime.now(),
        paidBy: selectedPaidBy!.name,
        paidById: selectedPaidBy!.id,
        splitMethod: splitMethod,
        splits: splits,
      );

      await ExpenseRepository.createExpense(newExpense);

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error saving expense: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thêm chi phí',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Price Section (Same as before)
                const Text(
                  'Giá',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '\$ ',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: '0',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                      const Text(
                        ' đ',
                        style: TextStyle(fontSize: 20, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 2. Description Section (Same as before)
                const Text(
                  'Nó dùng để làm gì?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.receipt_long_outlined,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _descriptionController,
                          style: const TextStyle(fontSize: 14),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Ví dụ: Bữa tối tại nhà hàng hải sản',
                            hintStyle: TextStyle(color: Colors.grey),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Category Section (Same as before)
                const Text(
                  'Phân loại',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1.5,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    final isSelected = selectedCategory == cat['name'];
                    return InkWell(
                      onTap: () =>
                          setState(() => selectedCategory = cat['name']),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF1976D2)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.transparent
                                : Colors.grey[300]!,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              cat['icon'],
                              color: isSelected ? Colors.white : cat['color'],
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cat['name'],
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // 4. Paid By Section (Same as before)
                const Text(
                  'Ai đã trả tiền?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: _showPayerSelectionDialog,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        if (selectedPaidBy != null)
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.blue[100],
                            child: Text(
                              selectedPaidBy!.name.isNotEmpty
                                  ? selectedPaidBy!.name[0]
                                  : '?',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blue,
                              ),
                            ),
                          )
                        else
                          const Icon(Icons.person_outline, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            selectedPaidBy?.name ?? 'Chọn người trả',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 5. Split Method Section
                const Text(
                  'Cách chia',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                _buildSplitOption(
                  title: 'Chia đều',
                  subtitle: 'Giữa tất cả các thành viên chuyến đi',
                  icon: Icons.groups,
                  value: 'EVEN',
                ),
                const SizedBox(height: 10),
                _buildSplitOption(
                  title: 'Chỉ những thành viên được chọn',
                  subtitle: 'Chọn người bạn muốn chia tài sản cùng',
                  icon: Icons.checklist,
                  value: 'SELECTED',
                ),
                const SizedBox(height: 10),
                _buildSplitOption(
                  title: 'Số tiền tùy chỉnh',
                  subtitle: 'Đặt số tiền chia tùy chỉnh',
                  icon: Icons.attach_money,
                  value: 'CUSTOM',
                ),

                // 6. Dynamic Split Details UI
                if (splitMethod == 'SELECTED')
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildMemberSelectionList(),
                  ),

                if (splitMethod == 'CUSTOM')
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: _buildCustomAmountList(),
                  ),

                const SizedBox(height: 100),
              ],
            ),
          ),

          // Bottom Button (Same as before)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Thêm chi phí',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required String value,
  }) {
    final isSelected = splitMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() => splitMethod = value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1976D2) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected ? Colors.white70 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberSelectionList() {
    return Column(
      children: tripMembers.map((member) {
        final isSelected = selectedSplitMembers.contains(member);
        return CheckboxListTile(
          value: isSelected,
          onChanged: (val) {
            setState(() {
              if (val == true) {
                selectedSplitMembers.add(member);
              } else {
                selectedSplitMembers.remove(member);
              }
            });
          },
          title: Text(member.name),
          secondary: CircleAvatar(child: Text(member.name[0])),
          contentPadding: EdgeInsets.zero,
          activeColor: const Color(0xFF1976D2),
        );
      }).toList(),
    );
  }

  Widget _buildCustomAmountList() {
    return Column(
      children: tripMembers.map((member) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              CircleAvatar(child: Text(member.name[0])),
              const SizedBox(width: 12),
              Expanded(child: Text(member.name)),
              SizedBox(
                width: 120,
                child: TextField(
                  controller: customAmountControllers[member.id],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '0',
                    suffixText: 'đ',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showPayerSelectionDialog() {
    print(
      '💰 [AddExpense] Showing payer selection with ${tripMembers.length} members',
    );
    for (var m in tripMembers) {
      print('   - ${m.id}: ${m.name}');
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Chọn người trả tiền',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: tripMembers.length,
                  itemBuilder: (context, index) {
                    final member = tripMembers[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text(member.name[0])),
                      title: Text(member.name),
                      trailing: selectedPaidBy?.id == member.id
                          ? const Icon(Icons.check, color: Colors.blue)
                          : null,
                      onTap: () {
                        setState(() => selectedPaidBy = member);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
