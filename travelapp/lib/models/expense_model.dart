class Expense {
  final int id;
  final int tripId;
  final String title;
  final String description;
  final String category;
  final double amount;
  final DateTime date;
  final String paidBy;
  final int paidById;
  final String paymentStatus;
  final List<ExpenseSplit> splits;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.tripId,
    required this.title,
    required this.description,
    required this.category,
    required this.amount,
    required this.date,
    required this.paidBy,
    required this.paidById,
    required this.paymentStatus,
    required this.splits,
    this.createdAt,
    this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      tripId: json['tripId'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      paidBy: json['paidBy'] ?? '',
      paidById: json['paidById'] ?? 0,
      paymentStatus: json['paymentStatus'] ?? 'Pending',
      splits: json['splits'] != null
          ? List<ExpenseSplit>.from(
              (json['splits'] as List).map((x) => ExpenseSplit.fromJson(x)),
            )
          : [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
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
      'date': date.toIso8601String(),
      'paidBy': paidBy,
      'paidById': paidById,
      'paymentStatus': paymentStatus,
      'splits': splits.map((x) => x.toJson()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ExpenseSplit {
  final int id;
  final int expenseId;
  final int userId;
  final String userName;
  final double amount;
  final bool paid;

  ExpenseSplit({
    required this.id,
    required this.expenseId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.paid,
  });

  factory ExpenseSplit.fromJson(Map<String, dynamic> json) {
    return ExpenseSplit(
      id: json['id'] ?? 0,
      expenseId: json['expenseId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      paid: json['paid'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'userId': userId,
      'userName': userName,
      'amount': amount,
      'paid': paid,
    };
  }
}
