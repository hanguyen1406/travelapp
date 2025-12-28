class ChecklistItem {
  int id;
  int tripId;
  String title;
  String? description;
  bool completed;
  int? assignedToUserId;
  String? assignedToUserName;
  String? assignedToUserAvatar;
  DateTime createdAt;
  DateTime? updatedAt;

  ChecklistItem({
    required this.id,
    required this.tripId,
    required this.title,
    this.description,
    required this.completed,
    this.assignedToUserId,
    this.assignedToUserName,
    this.assignedToUserAvatar,
    required this.createdAt,
    this.updatedAt,
  });

  factory ChecklistItem.fromJson(Map<String, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as int,
      tripId: json['tripId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      completed: json['completed'] as bool? ?? false,
      assignedToUserId: json['assignedToUserId'] as int?,
      assignedToUserName: json['assignedToUserName'] as String?,
      assignedToUserAvatar: json['assignedToUserAvatar'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'title': title,
      'description': description,
      'completed': completed,
      'assignedToUserId': assignedToUserId,
      'assignedToUserName': assignedToUserName,
      'assignedToUserAvatar': assignedToUserAvatar,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ChecklistSummary {
  int totalItems;
  int completedItems;
  int tripId;

  ChecklistSummary({
    required this.totalItems,
    required this.completedItems,
    required this.tripId,
  });

  int get progress => totalItems == 0 ? 0 : (completedItems * 100 ~/ totalItems);

  factory ChecklistSummary.fromJson(Map<String, dynamic> json) {
    return ChecklistSummary(
      totalItems: json['totalItems'] as int,
      completedItems: json['completedItems'] as int,
      tripId: json['tripId'] as int,
    );
  }
}
