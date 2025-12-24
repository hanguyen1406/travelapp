class LoginResponse {
  final String? token;
  final String? type;
  final int? id;
  final String? username;
  final String? email;
  final String? name;
  final String? surname;
  final List<String>? roles;

  LoginResponse({
    this.token,
    this.type,
    this.id,
    this.username,
    this.email,
    this.name,
    this.surname,
    this.roles,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] as String?,
      type: json['type'] as String?,
      id: json['id'] as int?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      name: json['name'] as String?,
      surname: json['surname'] as String?,
      roles: json['roles'] != null ? List<String>.from(json['roles']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'type': type,
      'id': id,
      'username': username,
      'email': email,
      'name': name,
      'surname': surname,
      'roles': roles,
    };
  }
}
