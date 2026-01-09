import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travelapp/models/expense_model.dart';
import 'package:travelapp/models/user_model.dart';
import 'package:travelapp/repository/expense_repository.dart';
import 'package:travelapp/viewModel/auth_view_model.dart';
import 'package:travelapp/viewModel/trip_view_model.dart';

class BalanceSettlementScreen extends StatefulWidget {
  final int tripId;

  const BalanceSettlementScreen({Key? key, required this.tripId})
    : super(key: key);

  @override
  State<BalanceSettlementScreen> createState() =>
      _BalanceSettlementScreenState();
}

class _BalanceSettlementScreenState extends State<BalanceSettlementScreen>
    with WidgetsBindingObserver {
  bool isLoading = true;
  bool dataLoaded = false; // Track if data has been loaded
  double userBalance = 0;
  double totalDebt = 0;
  double totalPayment = 0; // Amount others owe me

  List<Settlement> settlements = [];
  Map<String, bool> settledStatus =
      {}; // TODO: Persist this if needed, for now local

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    try {
      final authVM = Provider.of<AuthViewModel>(context, listen: false);
      final tripVM = Provider.of<TripViewModel>(context, listen: false);

      final currentUserId = authVM.userId;
      if (currentUserId == null) {
        // Fallback or error
        setState(() => isLoading = false);
        return;
      }

      // Ensure we have members mapping
      Map<int, User> membersMap = {};
      if (tripVM.currentTrip != null &&
          tripVM.currentTrip!.id == widget.tripId) {
        for (var m in tripVM.currentTrip!.members) {
          membersMap[m.id] = m;
        }
      } else {
        // Fetch trip if not current
        await tripVM.fetchTripDetail(widget.tripId);
        if (tripVM.currentTrip != null) {
          for (var m in tripVM.currentTrip!.members) {
            membersMap[m.id] = m;
          }
        }
      }

      // Try to load from API first (better accuracy)
      try {
        final balanceData = await ExpenseRepository.getBalance(
          widget.tripId,
          currentUserId,
        );
        print('✅ [BalanceSu] Loaded balance from API');

        // Parse balance data
        _loadBalanceFromAPI(balanceData, membersMap, currentUserId);
        setState(() => dataLoaded = true);
      } catch (apiError) {
        print(
          '⚠️ [BalanceSu] API call failed, falling back to local calculation: $apiError',
        );

        // Fallback: Fetch expenses and calculate locally
        final expenses = await ExpenseRepository.getExpenses(widget.tripId);
        print('🔍 [BalanceSu] Fetched ${expenses.length} expenses');
        for (var e in expenses) {
          print(
            '  - Exp ${e.id}: ${e.amount} paid by ${e.paidById}. Splits: ${e.splits.length}',
          );
          for (var s in e.splits) {
            print('    - Split to ${s.userId}: ${s.shareAmount}');
          }
        }

        _calculateBalances(expenses, currentUserId, membersMap);
        setState(() => dataLoaded = true);

        _calculateBalances(expenses, currentUserId, membersMap);
      }
    } catch (e) {
      print('Error loading balance data: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _loadBalanceFromAPI(
    Map<String, dynamic> balanceData,
    Map<int, User> membersMap,
    int myId,
  ) {
    if (!mounted) return;

    try {
      settlements = [];

      // Get user balance
      userBalance = (balanceData['userBalance'] ?? 0).toDouble();
      totalDebt = (balanceData['totalOwed'] ?? 0).toDouble();
      totalPayment = (balanceData['totalToReceive'] ?? 0).toDouble();

      print(
        '💰 [BalanceSu API] Balance: $userBalance, Debt: $totalDebt, Payment: $totalPayment',
      );

      print('📊 [BalanceSu API] Full response: $balanceData');

      // Parse settlements from API
      final List<dynamic> settlementsList = balanceData['settlements'] ?? [];
      print('📋 [BalanceSu API] Settlements count: ${settlementsList.length}');

      for (var settleData in settlementsList) {
        final fromUserId = (settleData['fromUserId'] ?? 0).toInt();
        final toUserId = (settleData['toUserId'] ?? 0).toInt();
        final amount = (settleData['amount'] ?? 0).toDouble();
        final fromUserName = settleData['fromUserName'] ?? 'User $fromUserId';
        final toUserName = settleData['toUserName'] ?? 'User $toUserId';

        String fromDisplay = fromUserId == myId ? 'Bạn' : fromUserName;
        String toDisplay = toUserId == myId ? 'Bạn' : toUserName;
        String fromAvatar = fromUserId == myId
            ? 'You'
            : (fromUserName.isNotEmpty ? fromUserName[0] : '?');
        String toAvatar = toUserId == myId
            ? 'You'
            : (toUserName.isNotEmpty ? toUserName[0] : '?');

        print(
          '➕ [BalanceSu API] Adding settlement: $fromDisplay -> $toDisplay: $amount',
        );

        settlements.add(
          Settlement(
            id: settlements.length,
            from: fromDisplay,
            to: toDisplay,
            amount: amount,
            status: SettlementStatus.pending,
            fromAvatar: fromAvatar,
            toAvatar: toAvatar,
          ),
        );
      }

      print('✅ [BalanceSu API] Parsed settlements: ${settlements.length}');
      setState(() {});
    } catch (e) {
      print('❌ [BalanceSu] Error parsing API response: $e');
      print('🔍 [BalanceSu] Raw data: $balanceData');
      rethrow;
    }
  }

  void _calculateBalances(
    List<Expense> expenses,
    int myId,
    Map<int, User> members,
  ) {
    print(
      '🧮 [_calculateBalances] MyId: $myId. Members: ${members.keys.toList()}',
    );

    // 1. Calculate Net Balances
    Map<int, double> balances = {};

    // Initialize 0 for all known members (important for graph)
    members.keys.forEach((id) => balances[id] = 0.0);

    for (var expense in expenses) {
      // Payer paid (+)
      balances[expense.paidById] =
          (balances[expense.paidById] ?? 0) + expense.amount;

      // Splitters consume (-)
      for (var split in expense.splits) {
        balances[split.userId] =
            (balances[split.userId] ?? 0) - split.shareAmount;
      }
    }

    print('  -> Raw Balances: $balances');

    // 2. Simplify Debts (Greedy Algorithm)
    List<_Debt> debts = [];
    List<int> debtors = balances.keys
        .where((k) => (balances[k] ?? 0) < -1)
        .toList(); // Tolerance 1
    List<int> creditors = balances.keys
        .where((k) => (balances[k] ?? 0) > 1)
        .toList();

    print('  -> Debtors: $debtors');
    print('  -> Creditors: $creditors');

    // Sort by magnitude to optimize matching (optional, but good practice)
    debtors.sort(
      (a, b) => balances[a]!.compareTo(balances[b]!),
    ); // Ascending (most negative first)
    creditors.sort(
      (a, b) => balances[b]!.compareTo(balances[a]!),
    ); // Descending (most positive first)

    int i = 0; // debtor index
    int j = 0; // creditor index

    while (i < debtors.length && j < creditors.length) {
      int debtorId = debtors[i];
      int creditorId = creditors[j];

      double debtAmount = -(balances[debtorId]!);
      double creditAmount = balances[creditorId]!;

      double settlementAmount = debtAmount < creditAmount
          ? debtAmount
          : creditAmount;

      if (settlementAmount > 1) {
        // Filter tiny amounts
        debts.add(_Debt(debtorId, creditorId, settlementAmount));
      }

      balances[debtorId] = (balances[debtorId]! + settlementAmount);
      balances[creditorId] = (balances[creditorId]! - settlementAmount);

      if (balances[debtorId]!.abs() < 1) i++;
      if (balances[creditorId]!.abs() < 1) j++;
    }

    // 3. Filter for My View
    settlements = [];
    double myNetBalance =
        balances[myId] ??
        0; // This is remaining AFTER simplification? No, logic above modifies 'balances' map as it goes.
    // Wait, I need the ORIGINAL net balance for the top card "Net Status".
    // The simplification loop destroys the balances map to 0.
    // So I should calculate totals first.

    // Re-re-calculate simpler stats
    userBalance = 0;
    totalDebt = 0;
    totalPayment = 0;

    // Recalulate correct "User Balance" logic:
    // User Balance = (Total Paid) - (Fair Share).
    // This is exactly what I calculated in step 1 before muting it.
    // I should have saved Step 1 state.
    // However, after simplification, 'debts' list contains all I need.

    for (var debt in debts) {
      String fromName = members[debt.from]?.name ?? 'User ${debt.from}';
      String toName = members[debt.to]?.name ?? 'User ${debt.to}';
      String fromAvatar = fromName.isNotEmpty ? fromName[0] : '?';
      String toAvatar = toName.isNotEmpty ? toName[0] : '?';

      if (debt.from == myId) {
        // I owe someone
        totalDebt += debt.amount;
        settlements.add(
          Settlement(
            id: settlements.length,
            from: 'Bạn',
            to: toName,
            amount: debt.amount,
            status: SettlementStatus.pending,
            fromAvatar: 'You',
            toAvatar: toAvatar,
          ),
        );
      } else if (debt.to == myId) {
        // Someone owes me
        totalPayment += debt.amount;
        settlements.add(
          Settlement(
            id: settlements.length,
            from: fromName,
            to: 'Bạn',
            amount: debt.amount,
            status: SettlementStatus.pending,
            fromAvatar: fromAvatar,
            toAvatar: 'You',
          ),
        );
      }
    }

    userBalance = totalPayment - totalDebt;
  }

  void _toggleSettlement(int id) {
    setState(() {
      settledStatus[id.toString()] = !(settledStatus[id.toString()] ?? false);
    });
  }

  void _sendPaymentReminder() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã gửi nhắc nhở thanh toán')));
  }

  void _exportBankTransfer() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã sao chép thông tin chuyển khoản')),
    );
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0', 'vi_VN');
    return '${formatter.format(amount)}đ';
  }

  Color _getAvatarColor(String initials) {
    if (initials == 'You' || initials == 'Bạn') return Colors.blue;
    final colors = [
      const Color(0xFF4ECDC4),
      const Color(0xFFFF6B6B),
      const Color(0xFFFFD93D),
      const Color(0xFF6BCB77),
      const Color(0xFF4D96FF),
    ];
    return colors[initials.hashCode % colors.length];
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
          'Tóm tắt số dư',
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
                  // Balance Summary Card
                  _buildBalanceSummaryCard(),
                  const SizedBox(height: 20),

                  // Stats Row
                  _buildStatsRow(),
                  const SizedBox(height: 24),

                  // Settlement Details Header
                  if (settlements.isEmpty && dataLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 48,
                              color: Colors.green,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tất cả khoản nợ đã được thanh toán!',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (settlements.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Chi tiết thanh toán',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    // Settlement Items
                    _buildSettlementList(),
                    const SizedBox(height: 24),

                    // Info Note
                    _buildInfoNote(),
                    const SizedBox(height: 24),
                  ],

                  // Action Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceSummaryCard() {
    final isPositive = userBalance >= 0;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isPositive
              ? [const Color(0xFF4ECDC4), const Color(0xFF45B7AA)]
              : [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (isPositive ? const Color(0xFF4ECDC4) : const Color(0xFFFF6B6B))
                    .withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Số dư ròng của bạn',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${isPositive ? '+' : ''}${_formatCurrency(userBalance.abs())}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isPositive
                  ? 'Bạn sẽ nhận được tổng cộng ${_formatCurrency(userBalance)}'
                  : 'Bạn sẽ phải trả tổng cộng ${_formatCurrency(userBalance.abs())}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Nợ',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(totalDebt),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87, // Fixed color for visibility
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Thanh toán',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatCurrency(totalPayment),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettlementList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: Column(
        children: settlements.asMap().entries.map((entry) {
          final index = entry.key;
          final settlement = entry.value;
          final isSettled = settledStatus[settlement.id.toString()] ?? false;

          return Column(
            children: [
              if (index > 0) Divider(height: 1, color: Colors.grey[200]),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // From Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getAvatarColor(settlement.fromAvatar),
                      child: Text(
                        settlement.fromAvatar == 'You' ||
                                settlement.fromAvatar == 'Bạn'
                            ? 'You'
                            : settlement.fromAvatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Arrow
                    Column(
                      children: [
                        Icon(
                          Icons.arrow_forward,
                          size: 20,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                    const SizedBox(width: 12),

                    // To Avatar
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: _getAvatarColor(settlement.toAvatar),
                      child: Text(
                        settlement.toAvatar == 'You' ||
                                settlement.toAvatar == 'Bạn'
                            ? 'You'
                            : settlement.toAvatar,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Settlement Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${settlement.from} nợ ${settlement.to}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatCurrency(settlement.amount),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _getAvatarColor(settlement.fromAvatar),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Checkbox
                    GestureDetector(
                      onTap: () => _toggleSettlement(settlement.id),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: isSettled
                              ? const Color(0xFF0066FF)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSettled
                                ? const Color(0xFF0066FF)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: isSettled
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 16,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7FF),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF0066FF), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nhấn vào biểu tương đầu tích để đánh dấu thanh toán đã được hoàn tất',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _sendPaymentReminder,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0066FF),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Gửi nhắc nhở thanh toán',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: _exportBankTransfer,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  'Xuất sang Chuyển khoản Ngân hàng',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class Settlement {
  final int id;
  final String from;
  final String to;
  final double amount;
  final SettlementStatus status;
  final String fromAvatar;
  final String toAvatar;

  Settlement({
    required this.id,
    required this.from,
    required this.to,
    required this.amount,
    required this.status,
    required this.fromAvatar,
    required this.toAvatar,
  });
}

class _Debt {
  final int from; // Debtor
  final int to; // Creditor
  final double amount;

  _Debt(this.from, this.to, this.amount);
}

enum SettlementStatus { pending, settled, cancelled }
