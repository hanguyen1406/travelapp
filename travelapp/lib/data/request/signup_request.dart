class SignupRequest {
  final String name;
  final String surname;
  final String username;
  final String email;
  final String password;
  final String phone;

  SignupRequest({
    required this.name,
    required this.surname,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'surname': surname,
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
    };
  }
}
