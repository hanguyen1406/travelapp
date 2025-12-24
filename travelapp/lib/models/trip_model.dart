class Trip {
  final int id;
  final String tripName;
  final String description;
  final String coverImage;
  final int createdById;
  final String createdByName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String currency;
  final DateTime? createdAt;
  final int itineraryCount;
  final int expenseCount;
  final int documentCount;
  final int checklistCount;
  final int memberCount;
  final double totalExpense;

  Trip({
    required this.id,
    required this.tripName,
    required this.description,
    required this.coverImage,
    required this.createdById,
    required this.createdByName,
    this.startDate,
    this.endDate,
    required this.currency,
    this.createdAt,
    this.itineraryCount = 0,
    this.expenseCount = 0,
    this.documentCount = 0,
    this.checklistCount = 0,
    this.memberCount = 0,
    this.totalExpense = 0.0,
  });

  factory Trip.fromJson(Map<String, dynamic> json) {
    return Trip(
      id: json['id'],
      tripName: json['tripName'] ?? '',
      description: json['description'] ?? '',
      coverImage: json['coverImage'] ?? '',
      createdById: json['createdById'] ?? 0,
      createdByName: json['createdByName'] ?? '',
      startDate: json['startDate'] != null ? DateTime.parse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      currency: json['currency'] ?? 'USD',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      itineraryCount: json['itineraryCount'] ?? 0,
      expenseCount: json['expenseCount'] ?? 0,
      documentCount: json['documentCount'] ?? 0,
      checklistCount: json['checklistCount'] ?? 0,
      memberCount: json['memberCount'] ?? 0,
      totalExpense: (json['totalExpense'] ?? 0).toDouble(),
    );
  }
}
