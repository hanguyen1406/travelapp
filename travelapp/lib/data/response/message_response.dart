class MessageResponse {
  final String? message;

  MessageResponse({this.message});

  factory MessageResponse.fromJson(Map<String, dynamic> json) {
    return MessageResponse(
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
    };
  }
}
