class Itinerary {
  final int id;
  final String title;
  final String description;
  final DateTime? activityDate;
  final String activityTime;
  final String locationName;
  final double locationLat;
  final double locationLng;
  final int dayNumber;
  final String status;
  final int tripId;
  final int suggestedById;
  final String suggestedByName;
  final int upVotes;
  final int downVotes;
  final bool? userVote; // null, true, false
  final DateTime? createdAt;

  Itinerary({
    required this.id,
    required this.title,
    required this.description,
    this.activityDate,
    required this.activityTime,
    required this.locationName,
    this.locationLat = 0.0,
    this.locationLng = 0.0,
    required this.dayNumber,
    required this.status,
    required this.tripId,
    required this.suggestedById,
    required this.suggestedByName,
    this.upVotes = 0,
    this.downVotes = 0,
    this.userVote,
    this.createdAt,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      activityDate: json['activityDate'] != null ? DateTime.parse(json['activityDate']) : null,
      activityTime: json['activityTime'] ?? '',
      locationName: json['locationName'] ?? '',
      locationLat: (json['locationLat'] ?? 0).toDouble(),
      locationLng: (json['locationLng'] ?? 0).toDouble(),
      dayNumber: json['dayNumber'] ?? 1,
      status: json['status'] ?? 'PENDING',
      tripId: json['tripId'] ?? 0,
      suggestedById: json['suggestedById'] ?? 0,
      suggestedByName: json['suggestedByName'] ?? '',
      upVotes: json['upVotes'] ?? 0,
      downVotes: json['downVotes'] ?? 0,
      userVote: json['userVote'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'activityDate': activityDate?.toIso8601String(),
      'activityTime': activityTime,
      'locationName': locationName,
      'locationLat': locationLat,
      'locationLng': locationLng,
      'dayNumber': dayNumber,
      'tripId': tripId,
      'suggestedById': suggestedById,
    };
  }
}
