class Expense {
  final int id;
  final int tripId;
  final String title;
  final String description;
  final String category;
  final double amount;
  final String currency;
  final DateTime date;
  final String paidBy; // paidByName
  final int paidById;
  final String splitMethod;
  final List<ExpenseSplit> splits;
  final DateTime? createdAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.currency,
    required this.date,
    required this.paidBy,
    required this.paidById,
    required this.splitMethod,
    required this.splits,
    this.createdAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      tripId: json['tripId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'VND',
      date: json['expenseDate'] != null
          ? DateTime.parse(json['expenseDate'])
          : (json['date'] != null ? DateTime.parse(json['date']) : DateTime.now()),
      paidBy: json['paidByName'] ?? (json['paidBy'] ?? 'Unknown'),
      paidById: json['paidById'] ?? 0,
      splitMethod: json['splitMethod'] ?? 'EVEN',
      splits: json['splits'] != null
          ? List<ExpenseSplit>.from(
              (json['splits'] as List).map((x) => ExpenseSplit.fromJson(x)),
            )
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'description': description,
      'category': category,
      'amount': amount,
      'currency': currency,
      'expenseDate': date.toIso8601String(),
      'paidByName': paidBy,
      'paidById': paidById,
      'splitMethod': splitMethod,
      'splits': splits.map((x) => x.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
    };
  }
}

class ExpenseSplit {
  final int expenseId;
  final int userId;
  final double shareAmount;
  final double sharePercentage;
  final bool isPaid;

  ExpenseSplit({
    required this.expenseId,
    required this.userId,
    required this.shareAmount,
    required this.sharePercentage,
    required this.isPaid,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      expenseId: json['expenseId'] ?? 0,
      userId: json['userId'] ?? 0,
      shareAmount: (json['shareAmount'] ?? 0).toDouble(),
      sharePercentage: (json['sharePercentage'] ?? 0).toDouble(),
      isPaid: json['isPaid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'expenseId': expenseId,
      'userId': userId,
      'shareAmount': shareAmount,
      'sharePercentage': sharePercentage,
      'isPaid': isPaid,
    };
  }
}
